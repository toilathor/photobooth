# Tiêu Chuẩn Thiết Kế Khung Ảnh (Frame Design Guidelines)

Tài liệu này cung cấp các tiêu chuẩn toán học chính xác (kích thước, toạ độ các ô trống) để đội ngũ thiết kế có thể dựa vào đó thiết kế các khung hình (`frame`) cho hệ thống Photobooth.

## 1. Frame 1 Ảnh (1 Slot)

Dành cho thiết kế các khung ảnh có 1 vị trí để đặt ảnh chụp.

- **Kích thước ảnh tổng (Size):** `431 x 560 px`
- **Định dạng:** `.png` (Các vị trí lỗ ảnh phải được làm trong suốt - transparent `alpha = 0`)
- **Kích thước ô ảnh:** `397 x 317 px`

**Toạ độ cụ thể:**

- **Slot 1:** `x: 17, y: 90, width: 397, height: 317`

---

## 2. Frame 4 Ảnh (4 Slots)

Dành cho thiết kế các khung ảnh có 4 vị trí để đặt ảnh chụp của người dùng.

- **Kích thước ảnh tổng (Size):** `880 x 2650 px`
- **Định dạng:** `.png` (Các vị trí lỗ ảnh phải được làm trong suốt - transparent `alpha = 0`)

**Toạ độ cụ thể của các ô ảnh lỗ trong suốt (x, y, width, height) thiết kế trên file PNG:**

- **Slot 1:** `x: 60, y: 60, width: 760, height: 560`
- **Slot 2:** `x: 60, y: 680, width: 760, height: 560`
- **Slot 3:** `x: 60, y: 1300, width: 760, height: 560`
- **Slot 4:** `x: 60, y: 1920, width: 760, height: 560`

_(Lưu ý: Khoảng cách dọc (gap) giữa các ô lỗ trong thiết kế PNG là 60px)._

### Cơ chế Bleed (Bù viền 20px) cho 4 Slots

Hệ thống áp dụng cơ chế bù viền (padding 20px mỗi cạnh) để tránh hở viền trắng khi ghép ảnh.

- Ảnh người dùng sẽ được phóng (Center Crop) lên kích thước: **800 x 600 px**.
- Toạ độ Render thực tế sẽ lùi về trái/trên 20px (với gap giữa các slot là 20px để chừa chỗ cho viền PNG 60px):
  - **Render Slot 1:** `x: 40, y: 40`
  - **Render Slot 2:** `x: 40, y: 660`
  - **Render Slot 3:** `x: 40, y: 1280`
  - **Render Slot 4:** `x: 40, y: 1900`

---

## Lưu ý cho Đội Thiết Kế (Design Team)

1. Vui lòng **bắt buộc** phải tuân thủ đúng kích thước `width` x `height` và toạ độ `x, y` của các lỗ trống như tiêu chuẩn trên để ảnh chụp của khách hàng lọt vừa khít 100% vào khung hình.
2. Các phần khoảng trắng giữa các lỗ hoặc các vùng padding viền ngoài có thể chèn hoạ tiết trang trí, graphic elements tự do tuỳ thích (miễn là không lấn vào vùng toạ độ các lỗ trống).
