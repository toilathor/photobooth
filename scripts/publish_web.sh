#!/usr/bin/env bash
# Build bản web từ một tag release rồi đưa lên nhánh gh-pages (GitHub Pages).
#
#   scripts/publish_web.sh v1.2.0          # build + commit vào gh-pages, chưa push
#   scripts/publish_web.sh v1.2.0 --push   # build + commit + push
#
# Build và gh-pages đều chạy trong worktree tạm, nên thư mục làm việc hiện tại
# (nhánh, file chưa commit, .env, .fvm, graphify-out...) không bị đụng tới.
# Quy trình đầy đủ: docs/release.md
set -euo pipefail

TAG="${1:-}"
PUSH="${2:-}"
BASE_HREF="/photobooth/"
# Các file chỉ có trên gh-pages, giữ lại khi thay bản build.
KEEP=("env" ".gitignore")

die() { echo "Lỗi: $*" >&2; exit 1; }

[[ -n "$TAG" ]] || die "thiếu tag. Ví dụ: scripts/publish_web.sh v1.2.0 [--push]"
[[ -z "$PUSH" || "$PUSH" == "--push" ]] || die "tham số thứ hai chỉ nhận --push"

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

git fetch -q --tags origin
git fetch -q origin gh-pages
git rev-parse -q --verify "refs/tags/$TAG" >/dev/null || die "không có tag $TAG"
git merge-base --is-ancestor "$TAG" origin/master \
  || die "$TAG không nằm trên origin/master — chỉ deploy bản đã release"

if [[ -z "${GOOGLE_DRIVE_API_KEY:-}" && -f .env ]]; then
  set -a; . ./.env; set +a
fi
[[ -n "${GOOGLE_DRIVE_API_KEY:-}" ]] \
  || die "chưa có GOOGLE_DRIVE_API_KEY (export hoặc khai báo trong .env)"

FLUTTER="fvm flutter"; DART="fvm dart"
command -v fvm >/dev/null || { FLUTTER="flutter"; DART="dart"; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/publish-web.XXXXXX")"
SRC="$WORK/src"
PAGES="$WORK/pages"
cleanup() {
  git -C "$ROOT" worktree remove --force "$SRC" 2>/dev/null || true
  git -C "$ROOT" worktree remove --force "$PAGES" 2>/dev/null || true
  rm -rf "$WORK"
}
trap cleanup EXIT

echo "==> Build $TAG"
git worktree add -q --detach "$SRC" "$TAG"
(
  cd "$SRC"
  $FLUTTER pub get >/dev/null
  $DART run slang >/dev/null
  $FLUTTER build web --base-href "$BASE_HREF" --wasm \
    --web-define=FLAVOR=personal \
    --dart-define=GOOGLE_DRIVE_API_KEY="$GOOGLE_DRIVE_API_KEY"
)
EXPECTED="$(sed -n 's/^version: *\([0-9.]*\)+\([0-9]*\).*/\1+\2/p' "$SRC/pubspec.yaml")"
echo "    version.json: $(cat "$SRC/build/web/version.json")"

echo "==> Chép vào gh-pages"
git worktree add -q --detach "$PAGES" origin/gh-pages
(
  cd "$PAGES"
  shopt -s dotglob
  for item in *; do
    [[ "$item" == ".git" ]] && continue
    keep=false
    for k in "${KEEP[@]}"; do [[ "$item" == "$k" ]] && keep=true; done
    $keep || rm -rf "$item"
  done
  cp -R "$SRC/build/web/." ./
  git add -A
  if git diff --cached --quiet; then
    echo "    gh-pages đã giống bản build, không có gì để commit."
    exit 0
  fi
  git diff --cached --shortstat
  git commit -q -m "$TAG ($EXPECTED)"
  if [[ "$PUSH" == "--push" ]]; then
    git push -q origin HEAD:gh-pages
    echo "==> Đã push. Kiểm tra sau 1-2 phút:"
    echo "    https://toilathor.github.io${BASE_HREF}version.json"
  else
    COMMIT="$(git rev-parse HEAD)"
    echo "==> Đã commit $COMMIT nhưng CHƯA push. Để push:"
    echo "    git push origin $COMMIT:gh-pages"
  fi
)
