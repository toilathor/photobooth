# Tiêu Chuẩn Thiết Kế Khung Ảnh (Frame Design Guidelines)

Tài liệu này cung cấp các tiêu chuẩn toán học chính xác (kích thước, toạ độ các ô trống) để đội ngũ thiết kế có thể dựa vào đó thiết kế các khung hình (`frame`) cho hệ thống Photobooth.

## 1. Frame 1 Ảnh (1 Slot)

Dành cho thiết kế các khung ảnh có 1 vị trí để đặt ảnh chụp.

* **Kích thước ảnh tổng (Size):** `431 x 560 px`
* **Định dạng:** `.png` (Các vị trí lỗ ảnh phải được làm trong suốt - transparent `alpha = 0`)
* **Kích thước ô ảnh:** `397 x 317 px`

**Toạ độ cụ thể:**
* **Slot 1:** `x: 17, y: 90, width: 397, height: 317`

---

## 2. Frame 3 Ảnh (3 Slots)

Dành cho thiết kế các khung ảnh có 3 vị trí để đặt ảnh chụp của người dùng.

* **Kích thước ảnh tổng (Size):** `880 x 2650 px`
* **Định dạng:** `.png` (Các vị trí lỗ ảnh phải được làm trong suốt - transparent `alpha = 0`)

**Toạ độ cụ thể của các ô ảnh (x, y, width, height):**
* **Slot 1 (Trên cùng):** `x: 59, y: 680, width: 762, height: 557`
* **Slot 2 (Ở giữa):** `x: 61, y: 1293, width: 761, height: 556`
* **Slot 3 (Dưới cùng):** `x: 59, y: 1905, width: 762, height: 556`

---

## 3. Frame 4 Ảnh (4 Slots)

Dành cho thiết kế các khung ảnh có 4 vị trí để đặt ảnh chụp của người dùng.

* **Kích thước ảnh tổng (Size):** `880 x 2650 px`
* **Định dạng:** `.png` (Các vị trí lỗ ảnh phải được làm trong suốt - transparent `alpha = 0`)

**Toạ độ cụ thể của các ô ảnh (x, y, width, height):**
* **Slot 1:** `x: 55, y: 55, width: 770, height: 579`
* **Slot 2:** `x: 55, y: 670, width: 770, height: 594`
* **Slot 3:** `x: 78, y: 1302, width: 747, height: 562`
* **Slot 4:** `x: 55, y: 1902, width: 770, height: 572`

---

## Lưu ý cho Đội Thiết Kế (Design Team)

1. Vui lòng **bắt buộc** phải tuân thủ đúng kích thước `width` x `height` và toạ độ `x, y` của các lỗ trống như tiêu chuẩn trên để ảnh chụp của khách hàng lọt vừa khít 100% vào khung hình.
2. Các phần khoảng trắng giữa các lỗ hoặc các vùng padding viền ngoài có thể chèn hoạ tiết trang trí, graphic elements tự do tuỳ thích (miễn là không lấn vào vùng toạ độ các lỗ trống).
