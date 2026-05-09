---
trigger: always_on
---

Phải kiểm tra xem có bị Deprecated không nếu Deprecated phải xử lí migrate ngay
Không biết phải hỏi, không tự đoán bừa
Rà soát và định rõ kiểu dữ liệu cho các biến, tránh dùng `dynamic` để tăng tính an toàn (Strong Typing)
Các cấu hình quan trọng (như số lượng ảnh, đếm ngược, themes, frames, asset paths) phải được quản lý tập trung tại `lib/core/configs`. Tránh tách những hằng số nhỏ lẻ chỉ dùng một lần.
Trước khi commit phải hỏi user xem commit message đã hợp lý chưa. Commit message dùng tiếng Việt, các từ chuyên ngành để tiếng Anh.