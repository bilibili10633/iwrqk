# IwrQk

![license](https://img.shields.io/github/license/iwrqk/iwrqk.svg)
![total stars](https://img.shields.io/github/stars/iwrqk/iwrqk?label=total%20stars)
![total forks](https://img.shields.io/github/forks/iwrqk/iwrqk?label=total%20forks)

<img src="./doc/icon.png" alt="logo" width="144" height="144" align="right" />

IwrQk is a cross-platform application based on Flutter that is compatible with the new version of Iwara (a video sharing platform).

Now with [Material Design 3](https://m3.material.io/).

## 🚩 Features

- ✅ Download manager (Only for videos)
- ✅ Friends manager
- ⬜ Notification and message manager
- ✅ Follow, subscription, favorite, playlist, comments
- ✅ Forum
- ✅ Player and gallery viewer
- ✅ Login, logout, register
- ✅ Blocklist for tags
- ⬜ Advanced search
- ✅ Discord rich presence (New!)
- ✅ Windows PIP (New!)

## 📱 Screenshots

| ![Preview](./doc/1.png) | ![Preview](./doc/2.png) | ![Preview](./doc/3.png) |
| :---------------------: | :---------------------: | :---------------------: |

## 💻 Contributions

If you are a developer eager to contribute to this project, feel free to submit a pull request! The project also utilizes `slang` for localization, and [contributions to translation](/lib/i18n/strings.i18n.json) are appreciated.

In case you come across any bugs, please report them after ensuring they are not caused by network issues, as Iwara's servers may encounter errors.

Let's collaborate to enhance the Iwara experience together!

Special thanks to [guozhigq/pilipala](https://github.com/guozhigq/pilipala) for the inspiration and player implementation.

## Building and releases

Use Flutter **3.44.5 stable** (Dart 3.12.2), pinned in `mise.toml` and the release workflows. Run `flutter pub get --enforce-lockfile` and `flutter analyze --no-fatal-infos` before building.

Push a `v*` version tag to build and publish Android APKs, a Windows ZIP, and an unsigned iOS IPA to GitHub Releases. Android releases use the repository's existing signing secrets. Manually triggered workflows upload build artifacts without creating a release.

Dependencies are updated to versions compatible with the pinned SDK. `dynamic_color` stays on the 1.x line because 2.x uses the separate `material_ui` widget and color types, while this application uses Flutter Material. `permission_handler` remains on 12.x because 13.x requires Android SDK 37 and AGP 9, beyond this Flutter toolchain. Android builds use Gradle 8.14.6, AGP 8.13.2, Kotlin 2.2.21, and Java 17; iOS CI uses Xcode 26.3 to meet plugin requirements.
