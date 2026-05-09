# Photobooth Project TODO List

## ✅ Đã hoàn thành (Completed)
- [x] **Core UI/UX**: Giao diện hiện đại, tối ưu cho màn hình cảm ứng.
- [x] **Auto Capture**: Chụp ảnh tự động với đếm ngược và âm thanh hướng dẫn.
- [x] **Photo Selection**: Cho phép người dùng chọn ảnh giữ lại khi đổi số lượng ảnh chụp.
- [x] **Print Preview**: Mô phỏng in trên giấy Canon KP-108IN (Portrait/Landscape).
- [x] **Cut Guides**: Thêm đường viền hướng dẫn cắt ảnh sau khi in.
- [x] **Video Recap**: 
    - [x] Quay video hậu trường tự động.
    - [x] Chế độ xem "Gắn khung" (Frame Mode) với các đoạn clip ngắn lặp lại.
    - [x] Tối ưu hiển thị Video lấp đầy ô trống (BoxFit.cover).
- [x] **UX Improvements**:
    - [x] Vô hiệu hóa (Disable) các nút cài đặt và xóa ảnh khi đang chụp để tránh bug.
    - [x] Di chuyển thông tin giấy in (Canon KP-108IN) vào vùng lề xé để không ảnh hưởng ảnh chính.
- [x] **Error Handling**: Fix lỗi phân tích mã nguồn (Flutter Analyze).
- [x] **Maintenance**: 
    - [x] Rà soát và định rõ kiểu dữ liệu cho các biến đang dùng `dynamic` để tăng tính an toàn (Strong Typing).
    - [x] Refactor lại hệ thống cấu hình (Configs) để quản lý tập trung.
    - [x] Tách nhỏ các Widget lớn trong `PreviewPanel` và `SettingsPanel` để dễ quản lý.
    - [x] Chuyển đổi các logic xử lý Video sang một Service riêng biệt.
    - [x] Triển khai đa ngôn ngữ (Internationalization - i18n).
    - [x] Xử lý Cache (ảnh/video tạm) để dọn dẹp dung lượng sau mỗi phiên.

## 🚀 Sắp tới (Upcoming)
- [ ] **Tính năng Frame & Content**:
    - [ ] Hệ thống Frame động lấy dữ liệu từ Google Drive.
    - [ ] Tính năng cho phép người dùng đóng góp Frame mới.
    - [ ] Bộ lọc màu (Filters) nâng cao, nghệ thuật hơn.
- [ ] **Cộng đồng (Community)**:
    - [ ] Trang cộng đồng hiển thị các ảnh mẫu người dùng đã chia sẻ để truyền cảm hứng.
- [ ] **Âm thanh (Audio Settings)**:
    - [ ] Thêm nút bật/tắt âm thanh đếm ngược và âm thanh hướng dẫn.
- [ ] **Lệnh in thực tế (Real Printing)**: Kết nối với máy in Canon Selphy hoặc máy in nhiệt qua AirPrint/IPP.
- [ ] **Tính năng chỉnh sửa nâng cao**:
    - [ ] Thêm sticker/emoji vào ảnh.
- [ ] **Chia sẻ (Sharing)**:
    - [ ] Tạo QR Code để người dùng quét và tải ảnh/video về điện thoại.
    - [ ] Tích hợp QR Code trực tiếp lên bản in (giúp tải file gốc/video recap).
    - [ ] Tích hợp Google Drive/Photos API để lưu trữ đám mây.

## 🛠 Bảo trì (Maintenance)
- [ ] **Refactor & Config**:
- [ ] **Hệ thống & Hiệu năng**:
    - [ ] Chia môi trường phát triển bản thương mại và bản cá nhân dùng trên tất cả các nền tảng.
- [ ] Viết Unit Test cho logic tính toán vị trí slots trong Frame.
- [ ] Tối ưu hóa hiệu năng Video Player khi dùng nhiều controller cùng lúc trên Web.
- [ ] Tối ưu khổ giấy cho bản in một tấm (tiết kiệm giấy in nhiệt).
