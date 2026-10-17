#!/usr/bin/env python3
"""Wire Notoo's stable release signing key into the generated Android project.

The CI writes the keystore to android/app/notoo.p12 first; this script then
adds a `release` signing config to app/build.gradle(.kts) and points the
release build type at it. Run after `flutter create` has produced android/.
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP_DIR = os.path.join(ROOT, "android", "app")

KTS = os.path.join(APP_DIR, "build.gradle.kts")
GROOVY = os.path.join(APP_DIR, "build.gradle")

RELEASE_CFG_KTS = """        create("release") {
            storeFile = file("notoo.p12")
            storeType = "PKCS12"
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
"""

RELEASE_CFG_GROOVY = """        release {
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

    cfg = RELEASE_CFG_KTS if kts else RELEASE_CFG_GROOVY

    if "signingConfigs" in src:
        idx = src.find("signingConfigs")
        brace = src.find("{", idx)
        nl = src.find("\n", brace)
        src = src[:nl + 1] + cfg + src[nl + 1:]
    else:
        idx = src.find("android {")
        if idx == -1:
            print("no android block in", path)
            return
        nl = src.find("\n", idx)
        block = ("    signingConfigs {\n" + cfg + "    }\n\n")
        src = src[:nl + 1] + block + src[nl + 1:]

    if kts:
        src = src.replace(
            'signingConfig = signingConfigs.getByName("debug")',
            'signingConfig = signingConfigs.getByName("release")')
    else:
        src = src.replace(
            "signingConfig signingConfigs.debug",
            "signingConfig signingConfigs.release")

    with open(path, "w", encoding="utf-8") as f:
        f.write(src)
    print("patched signing in", path)


def main() -> None:
    if os.path.exists(KTS):
        patch(KTS, True)
    if os.path.exists(GROOVY):
        patch(GROOVY, False)


if __name__ == "__main__":
    main()
