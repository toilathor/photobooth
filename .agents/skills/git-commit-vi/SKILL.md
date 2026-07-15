---
name: git-commit-vi
description: Thực hiện commit code chuẩn hoá với commit message bằng tiếng Việt, giải thích rõ ràng các thay đổi, giữ nguyên thuật ngữ chuyên ngành và luôn hỏi ý kiến user trước khi thực thi.
---

# Hướng dẫn tạo Commit tiếng Việt chuẩn hoá

Khi người dùng yêu cầu thực hiện commit (ví dụ: "commit code", "tạo commit", "commit những thay đổi"), bạn PHẢI áp dụng quy trình sau:

## 1. Phân tích các thay đổi
- Sử dụng các công cụ dòng lệnh (như `git status`, `git diff --staged`) để rà soát toàn bộ những tập tin đã thay đổi.
- Nhóm các thay đổi lại theo từng thành phần, tính năng hoặc lỗi (feature/bug/chore).

## 2. Soạn thảo Commit Message
- **Ngôn ngữ:** Sử dụng tiếng Việt (rõ ràng, mạch lạc, lịch sự).
- **Thuật ngữ chuyên ngành:** BẮT BUỘC giữ nguyên tiếng Anh cho các từ vựng kỹ thuật chuyên môn (ví dụ: `Provider`, `component`, `refactor`, `build`, `scaleX`, `UI`, `crash`, `state`, v.v...). Tuyệt đối không cố gắng dịch nghĩa các từ này.
- **Cấu trúc:** Sử dụng quy ước Conventional Commits cho tiêu đề.
  - Tiêu đề (Subject): `<type>(<scope>): <mô tả ngắn bằng tiếng Việt>`. Ví dụ: `feat(auth): thêm tính năng đăng nhập`, `fix(camera): sửa lỗi lật gương hiển thị`.
  - Thân bài (Body): Sử dụng các gạch đầu dòng (`-`) để giải thích cụ thể những gì đã thay đổi và tại sao thay đổi (What and Why).

## 3. Xin phép người dùng (Quy tắc bắt buộc)
- TUYỆT ĐỐI KHÔNG tự ý chạy lệnh `git commit` khi chưa có sự xác nhận của người dùng.
- Trình bày (print) bản nháp commit message ra cho người dùng đọc.
- Đặt câu hỏi: "Bạn có đồng ý với commit message này không? Nếu đồng ý, tôi sẽ tiến hành commit." hoặc tương tự.

## 4. Thực thi Commit
- Chỉ khi người dùng đồng ý, sử dụng công cụ (`run_command`) để chạy chuỗi lệnh:
  ```bash
  git add .
  git commit -m "<Nội dung đã thống nhất>"
  ```
- Trả về thông báo hoàn tất commit cho người dùng.
