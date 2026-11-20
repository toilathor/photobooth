# Quy trình release

Repo theo git flow:

| Nhánh | Vai trò |
| --- | --- |
| `master` | Code đã phát hành. Mỗi bản release có một tag `vX.Y.Z` trên nhánh này. |
| `develop` | Code đã xong, chờ phát hành. Feature mới rẽ ra từ đây. |
| `feature/<tên>/<việc>` | Một tính năng. Merge vào `develop` qua PR. |
| `release/X.Y.Z` | Chuẩn bị một bản phát hành: nâng version, chỉ sửa bug. |
| `gh-pages` | Bản build web đang chạy ở <https://toilathor.github.io/photobooth/>. Không sửa tay. |

Mọi PR và merge làm trên GitHub. Các lệnh dưới đây chạy trong thư mục `photobooth/`.

## Chọn số version

Version nằm ở dòng `version:` trong `pubspec.yaml`, dạng `X.Y.Z+N`:

- `Z` (patch): chỉ sửa lỗi.
- `Y` (minor): có tính năng mới, ví dụ thêm frame hay tuỳ chọn mới. Đặt `Z` về 0.
- `X` (major): thay đổi lớn làm hỏng cách dùng cũ.
- `N` (build number): luôn tăng 1 sau mỗi lần release, kể cả khi chỉ đổi patch. Store dùng số này để phân biệt bản build.

Ví dụ: `1.1.3+6` → thêm tính năng → `1.2.0+7`.

## Các bước

### 1. Đưa feature vào `develop`

Tạo PR `feature/...` → `develop` trên GitHub rồi merge.

### 2. Tạo nhánh release

```bash
git checkout develop && git pull
```

```bash
git checkout -b release/1.2.0
```

Sửa `version:` trong `pubspec.yaml`, rồi:

```bash
git commit -am "chore(release): 1.2.0"
```

### 3. Kiểm tra

```bash
make verify
```

`make verify` chạy kiểm tra format, `flutter analyze` và toàn bộ test. Phải pass hết mới đi tiếp.

Nếu bản release có thay đổi liên quan đến in (frame, QR, bố cục trang), in thử 1 tờ trên máy DNP DS-RX1HS (giấy 4x6 / 10x15 cm) và xem mép giấy có bị xén vào nội dung không.

Lỗi tìm thấy ở bước này sửa thẳng trên `release/X.Y.Z`. Không thêm tính năng mới vào nhánh này.

```bash
git push -u origin release/1.2.0
```

### 4. Merge release vào `master`

Tạo PR `release/1.2.0` → `master` rồi merge. Chọn **Create a merge commit**, không squash (lý do ở cuối tài liệu).

### 5. Gắn tag

```bash
git checkout master && git pull
```

```bash
git tag -a v1.2.0 -m "v1.2.0" && git push origin v1.2.0
```

Tag phải nằm trên commit đã merge vào `master`, không gắn trên nhánh release.

### 6. Merge ngược về `develop`

Tạo PR `master` → `develop` rồi merge, cũng chọn **Create a merge commit**. Bước này đưa commit nâng version (và các bản sửa ở bước 3) về `develop`.

Sau đó xoá nhánh `release/1.2.0` và nhánh feature, cả trên máy lẫn GitHub.

### 7. Deploy bản web

```bash
make publish-web TAG=v1.2.0
```

Lệnh này build tag đó và commit vào `gh-pages`, nhưng chưa push. Xem lại số file thay đổi in ra, thấy ổn thì push:

```bash
make publish-web TAG=v1.2.0 PUSH=--push
```

(Hoặc chạy lệnh `git push origin <commit>:gh-pages` mà lần chạy trước in ra.)

GitHub Pages cập nhật sau 1–2 phút. Kiểm tra bằng
<https://toilathor.github.io/photobooth/version.json>: phải thấy đúng version vừa release.

## Công cụ `scripts/publish_web.sh`

`make publish-web` gọi script này. Script:

1. Chỉ nhận tag nằm trên `origin/master`, để không vô tình deploy code chưa phát hành.
2. Lấy `GOOGLE_DRIVE_API_KEY` từ biến môi trường, nếu không có thì đọc từ `.env`.
   Key này là key đã giới hạn referrer `https://toilathor.github.io/*` (xem README).
3. Checkout tag vào một worktree tạm, chạy `pub get`, `dart run slang` (sinh file i18n), rồi
   `flutter build web --wasm --base-href /photobooth/ --web-define=FLAVOR=personal`.
4. Checkout `gh-pages` vào một worktree tạm khác, thay toàn bộ nội dung bằng bản
   build mới, giữ lại `env/` và `.gitignore`, rồi commit với nội dung `vX.Y.Z (X.Y.Z+N)`.
5. Push khi có `--push`, sau đó xoá cả hai worktree.

Script không đụng vào thư mục bạn đang làm việc. Bạn có thể chạy nó khi đang ở
nhánh khác hoặc đang có thay đổi chưa commit, mà không mất `.env`, `.fvm` hay
`graphify-out`. (Script cũ `deploy_web.sh` xoá file ngay trong thư mục làm việc,
nên đã bị bỏ.)

## Vì sao không squash khi merge vào `master` / `develop`

Squash gộp các commit thành một commit mới. Khi đó, về mặt lịch sử,
`master` và `develop` không còn chung commit với nhau dù nội dung giống hệt.
Lần release sau, Git so sánh từ một điểm chung cũ, thấy cả hai bên cùng sửa dòng
`version:` và báo conflict. Dùng merge commit cho PR vào `master` và PR merge
ngược về `develop` sẽ tránh được chuyện này. PR feature → `develop` thì squash
thoải mái.

Nếu lỡ squash và gặp conflict ở `pubspec.yaml`: giữ version mới hơn là xong.

## Checklist nhanh

- [ ] PR feature → `develop` đã merge
- [ ] `release/X.Y.Z` từ `develop`, đã nâng `version:` (cả build number)
- [ ] `make verify` pass; in thử nếu có thay đổi liên quan đến in
- [ ] PR release → `master` (merge commit)
- [ ] Tag `vX.Y.Z` trên `master`, đã push
- [ ] PR `master` → `develop` (merge commit), đã xoá nhánh release và feature
- [ ] `make publish-web TAG=vX.Y.Z PUSH=--push`, `version.json` hiển thị đúng
