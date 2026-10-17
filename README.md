# Notoo

A warm, editorial notes app for Android 9+ (API 28 and above).

Notoo is a rich-text notes app built around a calm, paper-like design system:
a cream canvas, a muted green accent, pastel note tints, and hand-drawn
accents. It is local-first and private.

## Features (build roadmap)

- [x] Rock-solid rich-text typing / editing core (built on `flutter_quill`)
- [x] Home, Folders, Tags, Archive, Trash, Search navigation
- [x] Local-first storage (no account, no cloud required)
- [x] Light / Dark / AMOLED themes + pastel colour accents
- [ ] PDF + .txt export (single note **and** all notes)
- [ ] Settings: bundled fonts + colour themes + backup/restore
- [ ] Selectable editorial asset packs (icons / doodles / imagery)
- [ ] Reminders & notifications (including natural-language "remind me…")
- [ ] Custom themed text-selection toolbar (cut / copy / paste / select all)

## Building

The APK is built automatically on GitHub Actions (see
`.github/workflows/build.yml`). Every push to `main` produces a release APK
artifact. To build locally:

```bash
flutter pub get
flutter build apk --release
```

## License

Released under the MIT License. Third-party asset licenses are listed in
`CREDITS.md` as packs are added.
