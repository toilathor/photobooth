---
trigger: always_on
---

# Architecture

Dự án tuân thủ Clean Architecture với cách tiếp cận Feature-first. Cấu trúc thư mục tổng thể:

- `lib/core/`: Chứa các cấu hình dùng chung (configs), theme, constants và các thành phần cốt lõi của ứng dụng.
- `lib/features/`: Chứa các tính năng của ứng dụng. Mỗi tính năng được chia thành các thư mục con:
    - `screens/`: Các màn hình UI chính (View Layer).
    - `providers/`: Logic nghiệp vụ và quản lý trạng thái (State Management/Logic Layer).
    - `widgets/`: Các UI component nhỏ, tái sử dụng trong phạm vi tính năng đó.
- `lib/services/`: Chứa các dịch vụ hạ tầng (external APIs, storage, cache, camera interaction).
- `lib/models/`: Các cấu trúc dữ liệu (Data Models) dùng chung.
- `lib/components/`: Các widget dùng chung cho toàn bộ ứng dụng (Global Shared Widgets).
- `lib/i18n/`: Quản lý đa ngôn ngữ.

**Nguyên tắc quan trọng:**
1. **Tách biệt Logic và UI:** `Screen` chỉ lo hiển thị và bắt sự kiện. Toàn bộ logic xử lý, điều phối (coordination) và gọi service phải nằm trong `Provider`.
2. **Giao tiếp qua Callback:** Provider giao tiếp với UI thông qua các callback (`onShowLoading`, `onSuccess`, `onError`) để đảm bảo UI hoàn toàn bị động và dễ test.
3. **Quản lý Service:** Các Provider không trực tiếp gọi API hay Storage mà phải thông qua lớp `Service` hoặc `Factory`.
