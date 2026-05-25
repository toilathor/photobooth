# TH PhotoBooth - Lưu giữ mọi khoảnh khắc

# Build Web 
flutter build web --base-href "/photobooth/" --wasm

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