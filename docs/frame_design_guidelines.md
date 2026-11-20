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

## 3. Frame Tiêu Chuẩn 2 Ảnh (2 Slots) — flavor personal

Dành cho khung có 2 ô ảnh phía trên và ảnh cưới lớn bên dưới (`layout_type: standard`; ở flavor personal chế độ Tiêu Chuẩn là 2 ảnh, ở commercial là 4 ảnh).

- **Kích thước ảnh tổng (Size):** `880 x 2650 px`
- **Định dạng:** `.png` (lỗ ảnh trong suốt, bo góc `36 px`)
- **Toạ độ lỗ trong suốt:** Slot 1 `x: 60, y: 60, width: 760, height: 560`; Slot 2 `x: 60, y: 680, width: 760, height: 560`
- **Render thực tế (bleed 20px):** `x: 40, y: 40` và `x: 40, y: 660`, kích thước `800 x 600 px`
- **Vị trí file:** `assets/frames/personal/standard/standard_<n>.png`, sau đó chạy `dart run lib/helper/update_frames_data.dart personal`
- **Phân loại theo tone màu:** khung personal chia thành 2 category trong `data.json`: `Tone Xanh Rêu` (`standard_1`) và `Tone Đỏ Rượu` (`standard_2`). Khung mới thêm bằng script chưa có category; muốn xếp vào tone nào thì sửa `category_id` và `category` của khung đó trong `data.json`.
- **Khung nhóm personal (`layout_type: group`, 2800x2000):** cô dâu và chú rể (ảnh đã tách nền, cùng tỉ lệ `0.85`) đứng ở hai góc dưới, hiện gần trọn thân người, che lẹm vào mép ô ảnh `140 px`. Ô ảnh trong suốt `1744x1308` tại `(528, 346)`, nằm trong ô render `1804x1353` tại `(498, 323.5)` (khai báo ở `FrameData.group` cho flavor personal). Ảnh tách nền nằm ở `scripts/frame_sources/`, tạo bằng `swift scripts/cutout_subject.swift <ảnh.png> <ra.png>` (Vision, chạy offline). Đổi `FIG_SCALE` hoặc `FIG_OVERLAP` trong `generate_personal_frames.py` thì ô ảnh đổi theo; script in ra `slot` mới để cập nhật `FrameData.group`.
- **Khung nhóm có ô ảnh riêng:** nếu một khung nhóm có vùng ảnh khác mặc định, khai báo `"slot": [x, y, width, height]` (tỉ lệ 4:3, đã tính bleed) cho mục đó trong `data.json`; `FrameData.group` sẽ dùng thay slot mặc định. Ví dụ khung bưu thiếp `group_4.png` dùng `[570, 277.5, 1560, 1170]`. Ảnh khách phủ kín chiều cao khung (khung bản tin HỶ TV) dùng `[66.67, 0, 2666.67, 2000]`, hai dải `86 px` hai bên phải đục.
- **Khung tiêu chuẩn có ô ảnh riêng:** nếu hai ảnh khách không nằm ở vị trí mặc định, khai báo `"slots": [[x, y, width, height], [x, y, width, height]]` (mỗi ảnh một ô, tỉ lệ 4:3, đã tính bleed 20px) cho mục đó trong `data.json`; `FrameData.standard` dùng các ô này khi số ô đúng bằng số ảnh của flavor, sai số ô thì giữ vị trí mặc định. Ví dụ tờ lịch bloc dùng `[[50, 830, 780, 585], [50, 1440, 780, 585]]`.
- **Xem trước nhanh:** `make frame-preview` tạo thumbnail WebP nhỏ (`scripts/frame_preview/thumbs.py`, tự cập nhật khi khung đổi), trang chỉ tải khung gốc khi chạm vào ảnh.
- **Ý tưởng khung mới:** `python3 scripts/generate_group_concepts.py` sinh các ý tưởng khung nhóm và khung tiêu chuẩn (`scripts/generate_standard_concepts.py`) vào `build/frame_concepts` (xem ở tab "ý tưởng" của `make frame-preview`). Khung được duyệt thì khai báo `publish` (tên file, category, `slot`) trong mục `CONCEPTS` (khung tiêu chuẩn: `STANDARD_CONCEPTS`; ý tưởng trả về `(canvas, slots)` thì `slots` được ghi tự động) rồi chạy `python3 scripts/generate_group_concepts.py --publish`: script chép khung vào `assets/frames/personal/group/` hoặc `standard/` và đăng ký vào `data.json` (`filename` là đường dẫn tương đối theo thư mục flavor, ví dụ `group/group_4.png`). Khung nghiêng thì `slot` phải phủ hết bounding box của ô trong suốt (ảnh khách không nghiêng theo). Ý tưởng đã duyệt (có `publish`) thành khung thật và tự rời khỏi tab ý tưởng. Sau khi duyệt một đợt, chỉ giữ ý tưởng đã duyệt: xóa hàm, mục trong `CONCEPTS` của ý tưởng không duyệt, chạy lại script thì file sinh ra của chúng tự bị xóa. Tờ lịch bloc và HỶ TV dùng font hệ thống macOS (Times New Roman, chữ 囍 của Songti SC), nên chỉ sinh lại được trên máy Mac.
- **Sinh khung tự động:** `python3 scripts/generate_personal_frames.py [ảnh_cưới]`

_(Lưu ý: góc dưới bên phải khung có mã QR in đè, nên tránh đặt chữ hoặc chi tiết quan trọng ở đó.)_

---

## Lưu ý cho Đội Thiết Kế (Design Team)

1. Vui lòng **bắt buộc** phải tuân thủ đúng kích thước `width` x `height` và toạ độ `x, y` của các lỗ trống như tiêu chuẩn trên để ảnh chụp của khách hàng lọt vừa khít 100% vào khung hình.
2. Các phần khoảng trắng giữa các lỗ hoặc các vùng padding viền ngoài có thể chèn hoạ tiết trang trí, graphic elements tự do tuỳ thích (miễn là không lấn vào vùng toạ độ các lỗ trống).
