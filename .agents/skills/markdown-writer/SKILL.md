---
name: markdown-writer
description: Hướng dẫn viết và format file Markdown chuẩn để không bị cảnh báo (warnings) từ linter. Mặc định sử dụng khi tạo hoặc sửa các file `.md`.
---

# Viết Markdown Chuẩn

Khi viết hoặc chỉnh sửa các file Markdown (`.md`) trong dự án, đặc biệt là các tài liệu kỹ thuật, test cases, hoặc README, hệ thống AI bắt buộc phải tuân thủ nghiêm ngặt các quy tắc format sau để tránh vi phạm cấu trúc và sinh ra warnings từ linter (`markdownlint`):

1. **Khoảng trắng quanh danh sách (Lists)**
   - Bắt buộc phải có một dòng trống (blank line) trước khi bắt đầu một danh sách (bullet list hoặc numbered list).
   - Bắt buộc phải có một dòng trống sau khi kết thúc một danh sách, trước khi bắt đầu nội dung đoạn văn khác.

2. **Căn lề danh sách lồng nhau (Nested Lists)**
   - Khi tạo danh sách con (nested lists) bên trong danh sách mẹ (bullet list), bắt buộc lùi đầu dòng đúng 2 spaces (không dùng tab, và không lùi 4 spaces) đối với dấu `-` hoặc `*`.

3. **Tiêu đề (Headings)**
   - Phải có chính xác 1 khoảng trắng (space) giữa các dấu `#` và text của tiêu đề (Ví dụ: `## Tiêu đề`).
   - Phải có một dòng trống trước và sau các thẻ Headings (Ngoại trừ dòng đầu tiên của file hoặc khi heading liền sát với thẻ mở/đóng).

4. **Đoạn văn (Paragraphs)**
   - Phân tách các đoạn văn với nhau bằng một dòng trống. Không dùng thẻ `<br>` trừ trường hợp bắt buộc trong bảng.

5. **Code Blocks**
   - Phải luôn khai báo ngôn ngữ của khối code (Ví dụ: ````bash`,````dart`).
   - Bắt buộc có dòng trống trước và sau khối code (code block).

6. **Khoảng trắng thừa (Trailing spaces)**
   - Tuyệt đối không để lại các khoảng trắng thừa ở cuối mỗi dòng.

7. **Định dạng bảng (Tables)**
   - Căn chỉnh các cột trong bảng bằng các khoảng trắng cho đều nhau. Dòng phân cách (delimiter row) phải khớp số lượng cột với dòng tiêu đề.
   - Có dòng trống trước và sau bảng.
   - Tránh để trống hoàn toàn một ô nếu không cần thiết.

Tuân thủ nghiêm ngặt các quy tắc trên bất cứ khi nào khởi tạo file `.md` mới hoặc sửa đổi nội dung bằng tool `multi_replace_file_content` / `write_to_file`.
