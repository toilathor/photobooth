#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "==========================================="
echo "   Build & Deploy Flutter Web to gh-pages  "
echo "==========================================="

echo "1. Cleaning project..."
flutter clean

echo "2. Lấy dependencies và generate code..."
flutter pub get
dart run build_runner build --delete-conflicting-outputs

echo "3. Building for Web (WASM + flavor=personal)..."
flutter build web --base-href "/photobooth/" --wasm --web-define=FLAVOR=personal

# Yêu cầu working directory phải sạch trước khi chuyển nhánh
if [ -n "$(git status --porcelain)" ]; then
    echo "Lỗi: Working directory của bạn đang có thay đổi chưa được commit."
    echo "Vui lòng commit hoặc stash các thay đổi trước khi chạy script để tránh mất mát code."
    exit 1
fi


CURRENT_BRANCH=$(git branch --show-current)

echo "4. Chuẩn bị đưa nội dung sang nhánh gh-pages..."

# =====================================================================
# BƯỚC 1: CHUYỂN SANG GH-PAGES
# =====================================================================
# Kiểm tra xem nhánh gh-pages đã tồn tại chưa
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git checkout gh-pages
else
    # Nếu chưa tồn tại, tạo nhánh mồ côi (không có lịch sử)
    git checkout --orphan gh-pages
fi

# =====================================================================
# BƯỚC 2: SAO LƯU CÁC FILE ĐANG CÓ TRÊN GH-PAGES
# =====================================================================
# Bạn CÓ THỂ điền các thư mục con ở đây (ví dụ: "assets/frames/collected")
# Script sẽ giữ lại các file này của nhánh gh-pages trước khi xoá.
KEEP_FILES=("env" ".gitignore" "assets")

echo "Đang sao lưu các file cần thiết (${KEEP_FILES[*]})..."

TMP_BACKUP=".deploy_backup_tmp"
mkdir -p "$TMP_BACKUP"

for item in "${KEEP_FILES[@]}"; do
    if [ -e "$item" ]; then
        parent_dir=$(dirname "$item")
        mkdir -p "$TMP_BACKUP/$parent_dir"
        mv "$item" "$TMP_BACKUP/$parent_dir/"
    fi
done

# =====================================================================
# BƯỚC 3: DỌN DẸP
# =====================================================================
echo "Đang dọn dẹp nhánh gh-pages..."

# Xoá toàn bộ các file ở thư mục gốc (Ngoại trừ .git, build, và thư mục tạm)
for file in * .*; do
    if [[ "$file" == "." || "$file" == ".." || "$file" == ".git" || "$file" == "build" || "$file" == "$TMP_BACKUP" ]]; then 
        continue 
    fi
    rm -rf "$file"
done

# =====================================================================
# BƯỚC 4: PHỤC HỒI FILE VÀ COPY BẢN BUILD MỚI
# =====================================================================
if [ -d "$TMP_BACKUP" ] && [ "$(ls -A "$TMP_BACKUP" 2>/dev/null)" ]; then
    # Dùng cp -a với /. để đảm bảo copy TẤT CẢ kể cả file ẩn như .gitignore
    cp -a "$TMP_BACKUP"/. ./
fi
rm -rf "$TMP_BACKUP"

# Copy toàn bộ nội dung từ thư mục build ra root của nhánh gh-pages
cp -R build/web/* ./

# Xoá luôn thư mục build đi để nhánh gh-pages hoàn toàn sạch sẽ
rm -rf build

# Đưa các file vào staging
git add .

echo "=========================================================================="
echo "✅ Đã xử lý xong! Bạn hiện đang ở nhánh 'gh-pages' và file đã được staged."
echo "👉 Bạn hãy tự thực hiện commit và push."
echo "   (Ví dụ: git commit -m \"Update\" && git push origin gh-pages)"
echo "Sau khi xong, bạn có thể quay lại nhánh làm việc cũ bằng lệnh:"
echo "   git checkout $CURRENT_BRANCH"
echo "=========================================================================="
