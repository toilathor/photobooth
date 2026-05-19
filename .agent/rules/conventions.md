---
trigger: always_on
---

# Conventions

- Phải kiểm tra xem có bị Deprecated không nếu Deprecated phải xử lí migrate ngay.
- Không biết phải hỏi, không tự đoán bừa.
- Rà soát và định rõ kiểu dữ liệu cho các biến, tránh dùng `dynamic` để tăng tính an toàn (Strong Typing).
- Các cấu hình quan trọng (như số lượng ảnh, đếm ngược, themes, frames, asset paths) phải được quản lý tập trung tại `lib/core/configs`. Tránh tách những hằng số nhỏ lẻ chỉ dùng một lần.

- **Quy tắc thiết kế Responsive (Mobile/Tablet & Desktop)**:
  - **Nguyên tắc Responsive Tổng quát**: Khi xây dựng bất kỳ tính năng (feature), màn hình (screen) hay thành phần giao diện (widget) mới nào, bắt buộc phải thiết kế thích ứng (responsive) ngay từ đầu cho cả thiết bị di động (Mobile/Tablet) và máy tính để bàn (Desktop). Tuyệt đối không giả định ứng dụng chỉ chạy trên một loại kích thước màn hình cụ thể. Phải liên tục kiểm tra trên các kích thước hẹp/squeezy để đảm bảo không bao giờ xảy ra lỗi tràn giao diện (RenderFlex overflow) hay sai lệch vị trí.
  - Tuyệt đối không dùng widget `Expanded` hoặc `Flexible` trực tiếp bên trong các widget con nằm dưới danh sách cuộn dọc không giới hạn chiều cao (như `SingleChildScrollView`, `ListView`). Thay vào đó, hãy bọc chúng bằng `SizedBox` hoặc `Container` có chiều cao xác định.
  - Khi chia cột bằng `GridView` hoặc `MasonryGridView` trên di động, luôn chỉ định `childAspectRatio` thích ứng hợp lý (ví dụ: `0.72` đến `0.8` đối với ô lưới chứa cả ảnh thumbnail và văn bản nhãn bên dưới) để tránh lỗi tràn pixel dọc (`RenderFlex overflowed on the bottom`).
  - Đối với các hàng nút ngang có nhãn chữ dễ bị tràn trên màn hình hẹp, hãy chuyển đổi sang dạng nhiều dòng (`Column` / `Wrap`) hoặc bọc trong `FittedBox(fit: BoxFit.scaleDown)` kết hợp `mainAxisSize: MainAxisSize.min`.
  - Khi chuyển đổi các widget nhúng platform view (như `CameraPreview` hoặc Native Video Player) giữa các layout chứa Desktop và Mobile khác nhau, bắt buộc phải sử dụng chung một `GlobalKey` duy nhất để giữ nguyên view layer của trình duyệt web, tránh lỗi huỷ engine view (`Trying to render a disposed EngineFlutterView`).
