---
trigger: always_on
---

Phải kiểm tra xem có bị Deprecated không nếu Deprecated phải xử lí migrate ngay
Không biết phải hỏi, không tự đoán bừa
Rà soát và định rõ kiểu dữ liệu cho các biến, tránh dùng `dynamic` để tăng tính an toàn (Strong Typing)
Các cấu hình quan trọng (nhu số lượng ảnh, đếm ngược, themes, frames, asset paths) phải được quản lý tập trung tại `lib/core/configs`. Tránh tách những hằng số nhỏ lẻ chỉ dùng một lần.
Trước khi commit phải hỏi user xem commit message đã hợp lý chưa. Commit message dùng tiếng Việt, các từ chuyên ngành để tiếng Anh.
Sử dụng thư viện `slang` cho đa ngôn ngữ (i18n). Tuyệt đối không hardcode chuỗi văn bản hiển thị; tất cả phải được quản lý trong `lib/i18n` và truy cập qua biến `t`. Mỗi khi cập nhật file JSON i18n, phải chạy lệnh `dart run slang` để đồng bộ.