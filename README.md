<div align="center">

<img src="./assets/images/ic_launcher.png" alt="TH PhotoBooth Logo" width="120" />

# TH PhotoBooth

_Lưu giữ mọi khoảnh khắc với trải nghiệm chụp ảnh tuyệt vời_

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Author-toilathor-blue?style=flat-square)](#)

</div>

---

## 🌟 Sự tích ra đời (Giới thiệu)

> _"Do là không có tiền thuê photobooth trong lễ cưới nên tôi tự viết một cái để tự vận hành luôn!"_ 🤵👰‍♂️💸

Vâng, đó chính xác là lý do **TH PhotoBooth** ra đời! Thay vì tốn cả đống tiền đi thuê máy chụp ảnh lấy ngay cho khách khứa trong ngày trọng đại, một lập trình viên hệ "tự lực cánh sinh" (chính là tôi) đã quyết định tự code luôn một cái app.

Và kết quả là chúng ta có một ứng dụng chụp ảnh cực kỳ xịn xò, đa nền tảng (Web, Android, iOS) được xây dựng bằng **Flutter**. Nó mang đến trải nghiệm "sống ảo" không thua kém gì ngoài hàng: hỗ trợ ghép khung hình thả ga, đắp bộ lọc (filter) lừa tình, hoạt động siêu mượt và tự động co giãn từ cái điện thoại bé xíu cho đến cái màn hình to chà bá đặt giữa sảnh tiệc cưới!

### 💡 Bài toán kinh tế: Tự Setup vs Đi Thuê

Để bạn dễ hình dung tại sao mình lại chọn con đường "khổ dâm" này, hãy nhìn vào bài toán chi phí:

- **Giá thị trường (Đi thuê)**: Rơi vào khoảng **5.000.000 VNĐ cho 2-3 tiếng**. Điểm cộng là bạn sẽ có đội ngũ vận hành riêng, thiết bị decor đẹp, có đèn đánh sáng xịn xò. Họ còn chuẩn bị sẵn cho mình các dịch vụ khác như máy in, giấy in ảnh, phụ kiện, sổ lưu niệm, ký cót các kiểu... Nhưng... khá là xót ví! 🥲 Hơn nữa, **khung hình (frame) thường là mẫu có sẵn**, bị gò bó và hiếm khi tuỳ chỉnh được đúng 100% ý thích cá nhân.

- **Tự Setup**:
  - Thuê Camera (máy ảnh): ~400k/ngày (nếu có máu rồi thì khỏi thuê luôn)
  - Dây dợ kết nối (Cáp, cổng chuyển...): Mua đứt ~500k sau không dùng có thể lên các hội nhóm pass lại
  - Màn hình hiển thị: Tận dụng luôn cái Tivi bự ở nhà 📺
  - Máy tính xử lý: Dùng con Laptop Windows cá nhân để truy cập web app
  - Thuê máy in ảnh Canon: ~400k - 500k/ngày
  - Giấy in ảnh & mực: ~800k cho 108 tấm (tuỳ nhu cầu khách khứa mà mua nhiều hay ít) kể cả có thiếu giấy thì vẫn có tính năng tạo QR upload lên Google Drive, nào cần in thì in sau cũng được 🫠
  - Khung ảnh (Frames): **Tự do sáng tạo vô hạn!** Bạn có thể tự vẽ, tự thiết kế hoặc đi gom nhặt các khung ảnh đúng gu, mang đậm dấu ấn cá nhân của hai vợ chồng.
  - _(Tùy chọn)_ Đèn đánh sáng: Có thể thuê thêm nếu muốn lung linh hơn.

  👉 **Tổng thiệt hại**: Chỉ loanh quanh khoảng **hơn 2 triệu VNĐ cho CẢ NGÀY** (thoải mái thời gian, chụp tới bến không bị gò bó 2-3 tiếng).

> 💡 **Góc nhỏ to**: Nói túm lại là, nếu bạn thuộc hệ "thích vọc vạch", muốn tự tay chuẩn bị từng chút một, thiết kế khung ảnh mang đậm chất riêng của hai vợ chồng và chụp tới bến không lo nhìn đồng hồ thì dự án này chính là "chân ái" dành cho bạn! Còn nếu bạn... giàu, thì cứ mạnh dạn vung tiền đi thuê dịch vụ trọn gói cho rảnh nợ nhé, đừng tự làm chi cho mệt! 😂

---

## 🗺️ Roadmap (Định hướng tương lai)

Hiện tại, ứng dụng đang hoạt động cực mượt trên **Web, Android và iOS**.
Tuy nhiên, tham vọng của mình không dừng lại ở đó! Trong tương lai, TH PhotoBooth sẽ "xâm chiếm" **toàn bộ các nền tảng mà Flutter hỗ trợ**, tiến thẳng lên Desktop Native:

- [x] Web (WASM)
- [x] Android
- [x] iOS
- [ ] macOS
- [ ] Windows
- [ ] Linux

---

## 🧱 Kiến trúc Gallery

Gallery tuân thủ Clean Architecture theo feature-first:

- `features/gallery/screens`: màn hình và liên kết UI.
- `features/gallery/providers`: tải dữ liệu, trạng thái và ảnh đang chọn.
- `features/gallery/widgets`: lightbox cùng danh sách thumbnail.
- `models/gallery_file.dart`: model tệp dùng chung.
- `services/gallery_service.dart`: giao tiếp Google Drive API.
- `core/routes/gallery_route.dart`: phân tích hash route của Gallery.

## 🧪 Kiến trúc Test

Thư mục `test` phản chiếu layer của production để mỗi test chỉ đi qua seam cần
kiểm tra:

- `test/features/<feature>/{providers,screens,widgets}`: test từng layer của
  feature.
- `test/core`, `test/components`, `test/services`: test module dùng chung đúng
  theo vị trí production.
- `test/integration`: kiểm tra app boot và luồng kết nối nhiều layer.
- `test/support`: test shell trung lập, không tự khởi tạo provider của feature.

## 🛠️ Yêu cầu môi trường & Cài đặt

- **Flutter SDK**: `3.50.0` (Dart `3.14.0`), quản lý qua [FVM (Flutter Version Management)](https://fvm.app/).
- **Quản lý phiên bản**: Luôn sử dụng tiền tố `fvm flutter` hoặc `fvm dart` để đảm bảo đồng nhất môi trường.
- **Hệ thống Design**: Đã migrate sang `package:material_ui` và `package:cupertino_ui` chuẩn Flutter 3.50.

---

## 🚀 Hướng dẫn Build & Deploy

### 🌐 1. Build cho môi trường Web (WASM)

Ứng dụng hỗ trợ biên dịch sang **WebAssembly (WASM)** với fallback JavaScript tự động, giúp tối ưu tối đa hiệu năng render và xử lý ảnh trên trình duyệt.

Tạo Google Drive API key, giới hạn key cho Google Drive API và HTTP referrer
`https://toilathor.github.io/*`. Sau đó export key trước khi build:

```bash
export GOOGLE_DRIVE_API_KEY="your-restricted-api-key"
fvm flutter clean
fvm flutter build web --base-href "/photobooth/" --wasm \
  --web-define=FLAVOR=personal \
  --dart-define=GOOGLE_DRIVE_API_KEY="$GOOGLE_DRIVE_API_KEY"
```

API key được đóng gói trong ứng dụng web nên không phải secret. Việc giới hạn
API và referrer là bắt buộc để tránh lạm dụng quota.

#### 🧪 Chạy thử Web ở Local

Tạo file cấu hình local rồi thay giá trị mẫu bằng API key:

```bash
cp .env.example .env
```

Cho phép thêm HTTP referrer `http://localhost:5050/*` trên API key dùng để
phát triển. Sau đó chạy cấu hình `Web - Personal` hoặc `Web - Personal (WASM)` trong VS Code hoặc dùng:

```bash
# Chạy Web tiêu chuẩn
fvm flutter run -d chrome --web-port 5050 \
  --web-define=FLAVOR=personal \
  --dart-define-from-file=.env

# Hoặc chạy thử nghiệm với WebAssembly (WASM).
# --no-cross-origin-isolation tắt header COOP same-origin mà dev server tự thêm
# khi chạy --wasm; header đó làm popup đăng nhập Google kẹt ở trang trắng
# accounts.google.com/gsi/transform. GitHub Pages cũng không gửi header này.
fvm flutter run -d chrome --wasm --no-cross-origin-isolation --web-port 5050 \
  --web-define=FLAVOR=personal \
  --dart-define-from-file=.env
```

Để kiểm tra bản build production ở local:

```bash
# Di chuyển vào thư mục build
cd build

# Đổi tên thư mục 'web' thành 'photobooth' để khớp với base-href
mv web photobooth

# Khởi động web server nội bộ (sử dụng Python có sẵn trên Mac/Linux)
python3 -m http.server 8000
```

Mở trình duyệt truy cập: `http://localhost:8000/photobooth/`

#### ☁️ Deploy lên GitHub Pages

```bash
# Tạo mới nhánh gh-pages tinh gọn (nếu chưa có)
git switch --orphan gh-pages

# Commit code trong thư mục build/web
git add .
git commit -m "Deploy Web Build"
git remote add origin https://github.com/toilathor/photobooth.git
git push -u origin gh-pages
```

### 🤖 2. Build cho Android

```bash
flutter clean
flutter build appbundle --release --flavor commercial
```

### 🍎 3. Build cho iOS

```bash
flutter clean
flutter build ipa --release --flavor commercial
```

---

## 🤝 Đóng góp & Phát triển (Contributing)

Dự án này là mã nguồn mở và luôn hoan nghênh sự đóng góp từ cộng đồng!

- Nếu bạn tìm thấy lỗi (bug), vui lòng mở một **[Issue](https://github.com/toilathor/photobooth/issues)**.
- Nếu bạn có ý tưởng tính năng mới, đừng ngần ngại tạo một **Pull Request** hoặc chia sẻ trong phần thảo luận.
- Bác nào thấy ý tưởng hay muốn phát triển thành dịch vụ thương mại thì cho em đớp với nhé, em mồm nhỏ đớp ít thôi 🍻

Cùng nhau, chúng ta sẽ biến TH PhotoBooth thành ứng dụng chụp ảnh tuyệt vời nhất! 🚀

---

## 💖 Ủng hộ dự án

Nếu bạn thấy dự án này hữu ích, giúp bạn tiết kiệm thời gian hoặc mang lại cảm hứng:

- Hãy để lại một **⭐ Star** trên GitHub để tiếp thêm động lực cho mình nhé!
- Chia sẻ ứng dụng này cho bạn bè hoặc trên các mạng xã hội.

---

## 📄 Bản quyền và Giấy phép

Sản phẩm được phát triển với tình yêu thương bởi **toilathor**.  
Dự án được phân phối dưới giấy phép **[MIT License](./LICENSE)**. Bạn có quyền tự do sử dụng, chỉnh sửa và phân phối, nhưng vui lòng tuân thủ việc giữ lại thông báo bản quyền gốc.
