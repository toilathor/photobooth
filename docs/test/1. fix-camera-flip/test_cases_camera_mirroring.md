# Test Cases: Camera Mirroring (Lật gương)

> [!NOTE]
> Bảng test case này giúp chúng ta xác định chính xác hành vi tự nhiên của gói thư viện `camera` trên từng môi trường (Mobile Native, Mobile Web, Desktop Web) trước khi áp dụng logic sửa lỗi triệt để.

## Khái niệm quy ước

- **Ngược (Mirror):** Giống như khi bạn soi gương. (Giơ tay phải lên thì hình trong màn hình cũng giơ tay ở cùng phía đó).
- **Thuận (Unmirrored):** Giống như người khác nhìn bạn. (Giơ tay phải lên thì hình trong màn hình giơ tay ở phía đối diện).

---

## 1. Môi trường 1: Điện thoại thật (Native App iOS / Android)

**Mục đích:** Xác nhận thuật toán `requiresFlip` đã hoạt động chuẩn xác 100% trên Native Mobile.

| Test Case | Camera | Nút Toggle Mirror | Kỳ vọng ở Preview | Kỳ vọng Ảnh / Video ở màn Edit | Kết quả thực tế (User điền) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC1.1** | Camera Trước | OFF (Mặc định) | **Ngược** | **Ngược** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Ngược** giống hệt Preview. |
| **TC1.2** | Camera Trước | ON (Bật lật) | **Thuận** | **Thuận** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Thuận** giống hệt Preview. |
| **TC1.3** | Camera Sau | OFF (Mặc định) | **Thuận** | **Thuận** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Thuận** giống hệt Preview. |
| **TC1.4** | Camera Sau | ON (Bật lật) | **Ngược** | **Ngược** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Ngược** giống hệt Preview. |

---

## 2. Môi trường 2: Trình duyệt Web trên Điện thoại (Mobile Web - Safari/Chrome)

**Mục đích:** Xác định xem Web có tự động lật Camera trước không, và Flutter có nhận diện đúng `lensDirection` hay không.

| Test Case | Camera | Nút Toggle Mirror | Kỳ vọng ở Preview | Kỳ vọng Ảnh / Video ở màn Edit | Kết quả thực tế (User điền) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC2.1** | Camera Trước | OFF (Mặc định) | **Ngược** | **Ngược** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Ngược** giống hệt Preview. |
| **TC2.2** | Camera Trước | ON (Bật lật) | **Thuận** | **Thuận** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Thuận** giống hệt Preview. |
| **TC2.3** | Camera Sau | OFF (Mặc định) | **Thuận** | **Thuận** | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Thuận** giống hệt Preview. |

---

## 3. Môi trường 3: Trình duyệt Web trên Máy tính (Desktop Web)

**Mục đích:** Đánh giá hành vi của Webcam trên Desktop (thường bị nhận diện là `external` thay vì `front`).

| Test Case | Camera | Nút Toggle Mirror | Kỳ vọng ở Preview | Kỳ vọng Ảnh / Video ở màn Edit | Kết quả thực tế (User điền) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC3.1** | Webcam mặc định | OFF (Mặc định) | **Ngược** | Phải giống hệt Preview | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Ngược** giống hệt Preview. |
| **TC3.2** | Webcam mặc định | ON (Bật lật) | **Thuận** | Phải giống hệt Preview | **PASS** - Tất cả Ảnh tĩnh, Video Recap (play/tĩnh) và Full Video đều **Thuận** giống hệt Preview. |
| **TC3.3** | Camera Fuji (Cắm ngoài) | OFF (Mặc định) | Ghi nhận xem nó Ngược hay Thuận | Phải giống hệt Preview | *(Chưa có máy test)* |
| **TC3.4** | Camera Fuji (Cắm ngoài) | ON (Bật lật) | Ghi nhận xem nó Ngược hay Thuận | Phải giống hệt Preview | *(Chưa có máy test)* |

---

## Mẫu Báo Cáo Kết Quả

Bạn có thể sửa trực tiếp vào file này hoặc copy mẫu sau gửi lại cho tôi:

```text
Kết quả Test:
- TC1.1: OK
- TC2.1: Preview hiển thị (Ngược) nhưng Edit thì ảnh (Thuận), video (Thuận). 
- TC3.1: ...
```