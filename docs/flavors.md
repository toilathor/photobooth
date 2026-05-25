# Environment & Flavor Switcher Guide

To support both **Personal (Cá nhân)** and **Commercial (Thương mại)** environments across all 6 targeted platforms (Android, iOS, macOS, Windows, Linux, Web), a centralized pre-build switcher utility is provided.

This approach ensures zero-maintenance native configuration conflicts, compile-time type safety, and seamless localization mapping.

---

## 1. Environment Configurations

Below is the comparison of settings applied in each flavor:

| Attribute | Personal (Cá nhân) | Commercial (Thương mại) |
| :--- | :--- | :--- |
| **Application / Bundle ID** | `vn.thphotobooth` | `vn.photobooth` |
| **App Display Name (Short)** | `TH PhotoBooth` | `PhotoBooth` |
| **App Title (Full/Web/Desktop)**| `TH PhotoBooth - Lưu giữ mọi khoảnh khắc` | `PhotoBooth - Lưu giữ mọi khoảnh khắc` |
| **Header Title** | `Thuý Hền ❤️ Quang Tọ` | `PhotoBooth` |
| **Theme** | `ThemeConfig.weddingTheme` (Red/Gold, Wedding theme) | `ThemeConfig.lightTheme` (Minimal Modern theme) |
| **External Storage (Google Drive)** | Enabled (`StorageType.googleDrive`) | Disabled (`StorageType.none`) |
| **Launcher Icon** | `assets/images/ic_launcher.jpg` | `assets/images/ic_launcher_commercial.png` (Premium generic design) |

---

## 2. How to Switch Flavors

Always switch the flavor **before** running or building the app:

### Switch to Personal Flavor
```bash
dart run tool/switch_flavor.dart personal
```

### Switch to Commercial Flavor
```bash
dart run tool/switch_flavor.dart commercial
```

---

## 3. How the Switcher Works

The `switch_flavor.dart` script automatically performs the following file manipulations:

1. **Dart Code Configurations**:
   - Updates `lib/core/configs/app_config.dart` (`appName`, `theme`).
   - Updates `lib/core/configs/storage_config.dart` (`activeStorage`).
2. **Localizations**:
   - Modifies `lib/i18n/vi.i18n.json` and `lib/i18n/en.i18n.json` header titles.
   - Runs `dart run slang` to regenerate type-safe translation files.
3. **Platform-level Bundle IDs and Names**:
   - Updates Android namespace, build configurations, and manifest label.
   - Updates iOS & macOS Xcode project configurations and Info.plist bundle IDs.
   - Updates Linux CMake targets and window titles.
   - Updates Windows company name, product details, binary name, executable filename, and launcher title.
   - Updates Web metadata, apple-mobile app settings, tab title, and PWA manifest details.
4. **App Launcher Icons**:
   - Copies the corresponding `flutter_launcher_icons-{flavor}.yaml` file over `flutter_launcher_icons.yaml`.
   - Runs `flutter pub run flutter_launcher_icons` to regenerate native platform assets.
