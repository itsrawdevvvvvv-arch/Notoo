#!/usr/bin/env python3
"""Wire Notoo's stable release signing key into the generated Android project.

CI writes the keystore to android/app/notoo.p12 first; this script then adds a
`release` signing config inside the `android { ... }` block and points the
release build type at it. Run after `flutter create` has produced android/.
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP_DIR = os.path.join(ROOT, "android", "app")

KTS = os.path.join(APP_DIR, "build.gradle.kts")
GROOVY = os.path.join(APP_DIR, "build.gradle")

# Entries that go *inside* signingConfigs { ... }
RELEASE_ENTRY_KTS = """        create("release") {
            storeFile = file("notoo.p12")
            storeType = "PKCS12"
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
"""

RELEASE_ENTRY_GROOVY = """        release {
            storeFile file("notoo.p12")
            storeType "PKCS12"
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
"""


def patch(path: str, kts: bool) -> None:
    if not os.path.exists(path):
        print("skip (missing):", path)
        return
    with open(path, "r", encoding="utf-8") as f:
        src = f.read()

    entry = RELEASE_ENTRY_KTS if kts else RELEASE_ENTRY_GROOVY

    if "signingConfigs" in src:
        idx = src.find("signingConfigs")
        brace = src.find("{", idx)
        if brace == -1:
            print("no signingConfigs brace")
            return
        src = src[:brace + 1] + "\n" + entry + src[brace + 1:]
    else:
        idx = src.find("android {")
        if idx == -1:
            print("no android block in", path)
            return
        brace = src.find("{", idx)
        block = "\n    signingConfigs {\n" + entry + "    }\n"
        src = src[:brace + 1] + block + src[brace + 1:]

    if kts:
        src = src.replace('signingConfigs.getByName("debug")',
                          'signingConfigs.getByName("release")')
    else:
        src = src.replace("signingConfig signingConfigs.debug",
                          "signingConfig signingConfigs.release")

    with open(path, "w", encoding="utf-8") as f:
        f.write(src)

    print("===== patched", path, "=====")
    for i, line in enumerate(src.splitlines(), 1):
        if 1 <= i <= 60:
            print(f"{i:>3} | {line}")
    print("===== end =====")


def main() -> None:
    if os.path.exists(KTS):
        patch(KTS, True)
    elif os.path.exists(GROOVY):
        patch(GROOVY, False)


if __name__ == "__main__":
    main()
