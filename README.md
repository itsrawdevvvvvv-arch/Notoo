<div align="center">

<img src="icon-512.png" width="120" alt="Notoo icon">

# Notoo

**Notes & Canvas — a fast, offline notes app with a real infinite canvas.**

[![Build APK](https://github.com/itsrawdevvvvvv-arch/Notoo/actions/workflows/android.yml/badge.svg)](https://github.com/itsrawdevvvvvv-arch/Notoo/actions/workflows/android.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-4F6B57.svg)](LICENSE)

[**⬇️ Download the APK**](../../releases/latest) · [**🌐 Try it in your browser**](https://itsrawdevvvvvv-arch.github.io/Notoo/)

</div>

---

## Download

Grab the latest build from the [**Releases page**](../../releases/latest):

| File | What it is |
|---|---|
| `Notoo-app-release.apk` | **Install this one.** |
| `Notoo-app-debug.apk` | Same app with debug symbols — useful if something misbehaves. |

Both share the package name `com.notoo.app` and a stable signing key, so **each new
release installs straight over the previous one and keeps all your notes.** You never
need to uninstall first.

**To install:** open the `.apk` on your phone and allow installing from your browser when
prompted (*Settings → Apps → Special access → Install unknown apps*). Android may warn that
the app is from an unknown developer — that is expected for any app installed outside the
Play Store.

**Updating:** just install the newer APK over the old one. Your notes are kept.

> **One exception.** The very first Android build of Notoo (v3.0.x, package
> `com.notoo.app.debug`) was signed with a throwaway key generated on a temporary build
> machine, which can never be reproduced. Android will refuse to update over it. If you have
> that build, export your notes first (**Profile → Export all notes**), install this one, then
> delete the old app and re-import. Every release from here on updates normally.

You can also just open the [web version](https://itsrawdevvvvvv-arch.github.io/Notoo/) — it is
the exact same app, and it installs to your home screen as a PWA (Add to Home screen) and works
offline.

---

## AI connector

Notoo can be driven by an AI assistant. Ask Claude or ChatGPT to *"make a mood
board from these images"* and it builds the board — images laid out in a grid,
a title, and node-style connections between them — and it appears in the app.

It works through **MCP** (the Model Context Protocol). The app and a small
connector server both read and write the same JSON document, so either side sees
the other's changes.

1. Create a **private** GitHub repo and a fine-grained token with **Contents:
   Read and write** for that repo only.
2. In the app: **Profile → AI Connector** → paste the repo and token → **Test**
   → **Send**.
3. Install the connector and point your assistant at it — full instructions in
   [`mcp/README.md`](mcp/README.md).

The connector exposes 24 tools covering the whole app: notes, tags, boards,
text, stickies, shapes, images, stickers, pen strokes, connections, and
backgrounds — plus `create_mood_board` for building a board from a list of
image URLs in one step.

## What it does

**Notes**
- Rich text: bold, italic, underline, headings, lists, checklists, quotes, links, images
- Markdown-style typing: `-` bullet, `1.` numbered, `#` heading, `>` quote, `[]` task
- Pin, star, colour, tag, and a due date with overdue badges
- Type `#anything` in a note and it becomes that note's tag automatically
- Pick **several images at once** — they land one after another in a note, or laid out
  in a tidy non-overlapping grid on a canvas
- Archive (separate from Trash), search, sort, grid/list layout
- Read aloud, print / save as PDF, export as a PNG, JSON backup and restore

**Canvas**
- A genuinely infinite board: pan, pinch-zoom, endless moving background
- Text, sticky notes, images, 9 shapes, and freehand pen drawing
- Move, resize, rotate, lock, duplicate and re-order anything
- 12 background colours × 7 textures (dots, grid, ruled, graph, isometric…)
- Alignment guides that snap objects into line as you drag
- Undo / redo, fit-to-screen, export the whole board as a PNG

**Art**
- **872 stickers** in two styles — hand-drawn and flat — plus **372 interface icons**
- Search, category chips and style tabs in the picker; drop them into a note or onto a canvas
- All bundled offline from real open-source sets (see *Credits* below)

**The rest**
- **36 fonts** built in, plus **add your own** — drop in any `.ttf`, `.otf` or `.woff2`
  from your device and it appears in the font list, saved for next time
- One clean fade transition between screens, plus a reduce-motion switch
- Light, dark, sepia themes and six accent colours
- Command palette (Ctrl/⌘ + K) and keyboard shortcuts
- Works fully offline; all data stays on your device

---

## Running it

It is a single self-contained HTML file. Nothing to build.

```bash
git clone https://github.com/itsrawdevvvvvv-arch/Notoo.git
cd Notoo
# any static server works
python3 -m http.server 8080
# then open http://localhost:8080
```

Opening `index.html` directly from disk also works; only the offline
service worker needs a real server.

## Building the APK

The Android app is a thin native shell that loads the web app from
`assets/index.html`, so there is no separate UI to maintain.

```bash
# bundle the web app into the Android project
mkdir -p android/app/src/main/assets
cp index.html android/app/src/main/assets/index.html

cd android
gradle assembleDebug      # or assembleRelease
```

Requires JDK 17 and the Android SDK. Pushing a tag (`git tag v1.0.0 && git push --tags`)
makes GitHub Actions build both APKs and attach them to the release automatically.

## Project layout

```
index.html                  the entire app (HTML + CSS + JS, no build step)
manifest.webmanifest        PWA manifest
sw.js                       service worker for offline use
icon-*.png, icon.svg        app icons
android/                    Android WebView wrapper
.github/workflows/          APK build + release pipeline
```

## Credits

Notoo bundles artwork from open-source projects. The interface icons and the
sticker library are **not** original to this project:

| Set | What it provides | Licence |
|---|---|---|
| [OpenMoji](https://openmoji.org) | Hand-drawn stickers | CC BY-SA 4.0 |
| [Microsoft Fluent Emoji](https://github.com/microsoft/fluentui-emoji) | Flat stickers | MIT |
| [Lucide](https://lucide.dev) | Interface icons | ISC |
| [Iconify](https://iconify.design) | Packaging and delivery of the icon data | MIT |

The sticker artwork is redistributed unmodified under its own licence (CC BY-SA 4.0 for
OpenMoji), separate from this project's MIT licence on the code. Attribution is also shown
in the app under **Profile → Artwork credits**.

## Android notes

A plain Android WebView is not a browser — file pickers, dialogs, downloads, printing, the
clipboard and text-to-speech all need native code or they quietly do nothing. Notoo's shell
wires all of that up:

| Feature | How it works in the app |
|---|---|
| Insert image | native file picker via `onShowFileChooser` |
| Insert link, new tag | native dialog via `onJsPrompt` |
| Read aloud | Android `TextToSpeech` |
| Print / save as PDF | Android print framework (choose *Save as PDF*) |
| Export image / .txt / backup | written into **Downloads** via `MediaStore` |
| Share, copy text | Android share sheet and clipboard |

## Notes and limitations

- Everything is stored in your browser's / WebView's local storage. There is no account and
  no sync. Use **Profile → Export all notes** to back up.
- Storage is limited to roughly 5 MB, so images are downscaled on insert.
- The APK is signed with a keystore generated for this project and stored as an encrypted
  GitHub Actions secret. It is fine for side-loading; generate your own keystore before
  publishing to an app store.
- Saving exports needs Android 10+ to land in Downloads without asking. On Android 8–9 the app
  asks for storage permission once.
- The 36 fonts load from Google Fonts the first time you open the font picker. Offline, the app
  falls back to the system font — everything else works normally.

## A note on this repository

`main` now holds **Notoo for the web / Android** — the single-file app described above.

An earlier Flutter build of Notoo lived on `main`. It has been preserved in full on the
[`flutter-legacy`](../../tree/flutter-legacy) branch, so nothing was lost. If you want that
version back, check out that branch.

## License

[MIT](LICENSE).
