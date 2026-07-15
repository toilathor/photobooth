# Antigravity Agents Rules

## Architecture

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

---

## Conventions

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

---

## Flavor Rules

This repository maintains two separate app environments: **Personal (Cá nhân)** and **Commercial (Thương mại)**.
The active flavor is managed at compilation time by running:

```bash
dart run tool/switch_flavor.dart [personal|commercial]
```

When working with flavors or configurations in this project, you **MUST** follow these rules:

1. **Do Not Hardcode Environment Values**:
   - Never hardcode the app bundle ID, app name, store titles, or external storage settings.
   - Always reference `AppConfig` or `StorageConfig`.
2. **Localization & Translations**:
   - The header title is dynamic and managed by the switcher script in `lib/i18n/vi.i18n.json` and `lib/i18n/en.i18n.json`.
   - Never hardcode personal references ("Thuý Hền", "Quang Tọ") directly in UI code. Always use translated strings (`t.header.title`).
3. **Adding Flavor Configurations**:
   - If a new environment-specific setting is introduced, update the following:
      1. Add the variable to `lib/core/configs/app_config.dart` or the respective configuration class.
      2. Update `tool/switch_flavor.dart` config map with values for both `personal` and `commercial` flavors.
      3. Add regex logic in `tool/switch_flavor.dart` to rewrite the variables in the config file.
4. **Launcher Icons**:
   - Do not manually edit native launcher assets. Modify `flutter_launcher_icons-personal.yaml` or `flutter_launcher_icons-commercial.yaml` and run the switch script to regenerate icons automatically.

---

## Multi Language (i18n)

Sử dụng thư viện `slang` cho đa ngôn ngữ (i18n).

**Nguyên tắc:**

- Tuyệt đối không hardcode chuỗi văn bản hiển thị.
- Tất cả các chuỗi phải được quản lý trong `lib/i18n/*.i18n.json`.
- Truy cập văn bản qua biến toàn cục `t` (ví dụ: `t.key.subkey`).
- Mỗi khi cập nhật file JSON i18n, phải chạy lệnh `dart run slang` để đồng bộ và generate code.

---

## Workflow & Communication

### Commit

Trước khi commit phải hỏi user xem commit message đã hợp lý chưa.

**Yêu cầu:**

- Commit message dùng tiếng Việt.
- Các từ chuyên ngành giữ nguyên tiếng Anh.

### Tương tác

- Luôn báo cáo tóm tắt công việc sau mỗi bước refactor lớn.
- Nếu có sự thay đổi về cấu trúc thư mục, phải cập nhật tài liệu và thông báo cho người dùng.
