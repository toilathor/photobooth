# Hướng Dẫn Test Web Trên Mobile

Tài liệu này hướng dẫn cách test giao diện và các tính năng của ứng dụng (dạng Web) trực tiếp trên trình duyệt của thiết bị di động (Mobile Web), thao tác trực tiếp từ máy tính đang code.

Chúng ta sử dụng [ngrok](https://ngrok.com/) để tạo một đường hầm (tunnel), giúp phơi bày (expose) local server ra internet công cộng bằng một URL public.

---

## 1. Yêu cầu (Prerequisites)

- **Python 3**: Dùng để chạy local HTTP server tĩnh (`python3 -m http.server`).
- **Ngrok**: Dùng để tạo public URL.
  - Tải tại: [https://ngrok.com/download](https://ngrok.com/download)
  - Cài qua Homebrew (trên macOS): `brew install ngrok/ngrok/ngrok`
  - (Cần thiết) Đăng nhập và cài đặt auth token: `ngrok config add-authtoken <your_token>`

## 2. Cách chạy siêu nhanh bằng Makefile (Khuyên dùng)

Dự án đã được tích hợp sẵn lệnh trong `Makefile` để tự động hóa toàn bộ quá trình build và host.

Bạn chỉ cần mở Terminal ở thư mục gốc của dự án và chạy:

```bash
make test-web-mobile
```

Quá trình tự động diễn ra:

1. Gõ lệnh build: `flutter build web --web-define=FLAVOR=commercial` (Build phiên bản commercial).
2. Tự động khởi chạy local server trên port `5050` tại thư mục `build/web/`.
3. Khởi chạy `ngrok` để expose port `5050` ra internet, cho phép các máy khác truy cập.

## 3. Xem kết quả

Sau khi lệnh trên chạy thành công, giao diện Terminal của `ngrok` sẽ hiện ra, trong đó có một dòng chứa URL có chữ `Forwarding`. Ví dụ:

```text
Forwarding                    https://xxxx-xxx-xxx.ngrok-free.app -> http://localhost:5050
```

- Hãy lấy đường link bắt đầu bằng `https://...` và gửi sang điện thoại của bạn (qua Zalo, Telegram, AirDrop, v.v.).
- Mở link đó trên Safari hoặc Chrome trên điện thoại để tiến hành test ứng dụng như một người dùng thật.

## 4. Cách tắt quá trình test

Để dừng lại quá trình test:

- Trên bàn phím máy tính (trong cửa sổ Terminal đang chạy `ngrok`), nhấn tổ hợp phím `Ctrl + C`.
- Script đã được lập trình để tự động dọn dẹp và tắt ngầm luôn tiến trình Python HTTP Server đang chạy ẩn, giúp bạn không phải mất công tìm và tắt tiến trình thủ công.
