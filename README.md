# Notoo

[![Latest release](https://img.shields.io/github/v/release/itsrawdevvvvvv-arch/Notoo?color=4F6B57)](https://github.com/itsrawdevvvvvv-arch/Notoo/releases/latest)
[![Stars](https://img.shields.io/github/stars/itsrawdevvvvvv-arch/Notoo?color=4F6B57)](https://github.com/itsrawdevvvvvv-arch/Notoo/stargazers)
[![Platform](https://img.shields.io/badge/platform-Android%209%2B-4F6B57)](#download)
[![License: MIT](https://img.shields.io/badge/License-MIT-4F6B57.svg)](LICENSE)

A warm, editorial notes app for Android 9+ (API 28 and above).

Notoo is a rich-text notes app built around a calm, paper-like design system:
a cream canvas, a muted green accent, pastel note tints, and hand-drawn
accents. It is local-first and private — no account, no cloud, no tracking.

## Download

Grab the latest APK from the **[Releases page](https://github.com/itsrawdevvvvvv-arch/Notoo/releases/latest)**.

If you are not sure which file you need, take **`Notoo-arm64-v8a.apk`** — that
is almost every phone made in the last several years.

| File | For |
|---|---|
| `Notoo-arm64-v8a.apk` | Most modern phones |
| `Notoo-armeabi-v7a.apk` | Older 32-bit phones |
| `Notoo-x86_64.apk` | Emulators / x86 devices |

Open the downloaded APK on your phone and allow installation from your browser
or file manager when Android asks.

## Features

- [x] Rock-solid rich-text typing / editing core (built on `flutter_quill`)
- [x] Home, Folders, Tags, Archive, Trash, Search
- [x] Local-first storage (no account, no cloud required)
- [x] Light / Dark / AMOLED themes + pastel colour accents
- [x] PDF + .txt export (single note **and** all notes)
- [x] Settings: font size + type, view mode, export defaults
- [ ] Selectable editorial asset packs (icons / doodles / imagery)
- [ ] Reminders & notifications (including "remind me…")
- [ ] Custom themed text-selection toolbar (cut / copy / paste / select all)

## Building

The APK is built automatically on GitHub Actions
(`.github/workflows/build.yml`). Every push to `main` produces an APK
artifact, and every version tag (`v1.0.0`, `v1.1.0`, …) publishes a Release
with per-ABI APKs attached.

To build locally:

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

## License

Released under the MIT License — see [LICENSE](LICENSE).
