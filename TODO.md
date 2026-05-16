# Photobooth Project TODO List

## ✅ Đã hoàn thành (Completed)
- [x] **Core UI/UX**: Giao diện hiện đại, tối ưu cho màn hình cảm ứng.
- [x] **Auto Capture**: Chụp ảnh tự động với đếm ngược và âm thanh hướng dẫn.
- [x] **Photo Selection**: Cho phép người dùng chọn ảnh giữ lại khi đổi số lượng ảnh chụp.
- [x] **Print Preview**: Mô phỏng in trên giấy Canon KP-108IN (Portrait/Landscape).
- [x] **Cut Guides**: Thêm đường viền hướng dẫn cắt ảnh sau khi in.
- [x] **Video Recap**: 
    - [x] Quay video hậu trường tự động (Silent).
    - [x] Chế độ xem "Gắn khung" (Frame Mode) với các đoạn clip ngắn lặp lại.
    - [x] Tối ưu hiển thị Video lấp đầy ô trống (BoxFit.cover).
    - [x] Giao diện Premium Glassmorphism với đầy đủ điều khiển.
    - [x] Mặc định bật tính năng quay Video Recap.
    - [x] Sửa video controller trong preview recap.
- [x] **Mirror Mode**: Tính năng lật gương cho Camera, Ảnh chụp và Video Recap (đồng bộ trên mọi nền tảng).
- [x] **Sharing (Chia sẻ)**:
    - [x] Tích hợp Google Drive/Photos API để lưu trữ đám mây.
    - [x] Tạo QR Code để người dùng quét và tải ảnh/video về điện thoại.
- [x] **UX Improvements**:
    - [x] Vô hiệu hóa (Disable) các nút khi đang chụp tự động, giữ nguyên khi chụp tay để tránh flicker.
    - [x] Thêm tính năng HỦY chụp tự động (Cancel Auto Capture).
    - [x] Di chuyển nút xem Video Recap ra ngoài header của Preview Panel.
    - [x] Di chuyển thông tin giấy in (Canon KP-108IN) vào vùng lề xé.
- [x] **Error Handling & Bug Fixes**:
    - [x] Fix lỗi hiển thị (tương phản màu) của các nút trong Dialog Chụp lại và Dialog Chọn ảnh.
    - [x] Fix lỗi mất nút In và QR ở màn hình Edit.
    - [x] Fix lỗi phân tích mã nguồn (Flutter Analyze).
- [x] **Maintenance**: 
    - [x] Rà soát và định rõ kiểu dữ liệu cho các biến đang dùng `dynamic` để tăng tính an toàn (Strong Typing).
    - [x] Refactor lại hệ thống cấu hình (Configs) để quản lý tập trung.
    - [x] Tách nhỏ các Widget lớn trong `PreviewPanel` và `SettingsPanel` để dễ quản lý.
    - [x] Chuyển đổi các logic xử lý Video sang một Service riêng biệt.
    - [x] Triển khai đa ngôn ngữ (Internationalization - i18n).
    - [x] Xử lý Cache (ảnh/video tạm) để dọn dẹp dung lượng sau mỗi phiên.
    - [x] Tối ưu khổ giấy cho bản in một tấm (tiết kiệm giấy in nhiệt).
- [x] **Features**:
    - [x] Bộ lọc màu (Filters) nâng cao, tự động sinh từ package colorfilter_generator.

## 🚀 Sắp tới (Upcoming)
- [ ] **Tính năng Frame & Content**:
    - [ ] Hệ thống Frame động lấy dữ liệu từ Google Drive.
    - [ ] Tính năng cho phép người dùng đóng góp Frame mới.
    - [ ] Cho phép zoom trong màn hình edit trong preview panel
- [ ] **Cộng đồng (Community)**:
    - [ ] Trang cộng đồng hiển thị các ảnh mẫu người dùng đã chia sẻ để truyền cảm hứng.
- [ ] **Lệnh in thực tế (Real Printing)**: Kết nối với máy in Canon Selphy hoặc máy in nhiệt qua AirPrint/IPP.
- [ ] **Tính năng chỉnh sửa nâng cao**:
    - [ ] Thêm sticker/emoji vào ảnh.
- [ ] **Chia sẻ (Sharing)**:
    - [ ] Tích hợp QR Code trực tiếp lên bản in (giúp tải file gốc/video recap).

## 🛠 Bảo trì (Maintenance)
- [ ] **Refactor & Config**:
- [ ] **Hệ thống & Hiệu năng**:
    - [ ] Chia môi trường phát triển bản thương mại và bản cá nhân dùng trên tất cả các nền tảng.
- [ ] Viết Unit Test cho logic tính toán vị trí slots trong Frame.
