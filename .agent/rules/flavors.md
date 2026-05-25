# Flavor Rules

This repository maintains two separate app environments: **Personal (Cá nhân)** and **Commercial (Thương mại)**.
The active flavor is managed at compilation time by running:
`dart run tool/switch_flavor.dart [personal|commercial]`

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
