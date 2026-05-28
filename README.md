# TH PhotoBooth - Lưu giữ mọi khoảnh khắc

# Build Web

flutter clean && flutter build web --base-href "/photobooth/" --wasm --web-define=FLAVOR=personal

## Test build

```bash
# Đi vào thư mục build
cd build

# Đổi tên thư mục 'web' thành 'photobooth' để khớp với tham số base-href
mv web photobooth

# Khởi động một web server nội bộ bằng Python (có sẵn trên Mac) ở port 8000
python3 -m http.server 8000
```

open http://localhost:8000/photobooth/

Copy build/web to somewhere else

```sh
# if not exists gh-pages
git switch --orphan gh-pages

# copy build/web to current directory
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/toilathor/photobooth.git
git push -u origin gh-pages
```

# Build Android

flutter clean
flutter build appbundle --release --flavor commercial

# Build iOS

flutter clean
flutter build ipa --release --flavor commercial
