# Android export notes

Application ID: `com.ashenwood.game`
App name: Ashenwood
Orientation: Portrait
Min SDK: 24
Target SDK: 34+

## Setup checklist

1. Install Android Studio and Android SDK Platform-Tools
2. In Godot: Editor → Manage Export Templates → download matching 4.7 templates
3. Project → Export → Add → Android
4. Set package name to `com.ashenwood.game`
5. Enable:
   - Gesture navigation / immersive as desired
   - Arm64-v8a (required)
   - Arm32 optional for older devices
6. Create a debug keystore for smoke tests, release keystore for store builds

Export presets will be generated from the Godot editor after SDK setup (`export_presets.cfg` is gitignored because it often contains machine-local paths).
