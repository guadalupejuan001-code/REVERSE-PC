# X01 is required by the next primary APK build

The Workbench/Control APK recipe now overlays the owner's X01 XI curriculum on the verified Android E025 capsule. Fresh installs receive the trained seed; known E025 installations migrate their own candidate state with the native learner. The installer preserves the old executable, old state, transcript and language. Custom executables and pending actions retain their previous protection.

`install-personal-x01.mjs` links only the personal XI prefix and transports the 59 taught records. It preserves the original E025 code path, factual learning and W4u artifact. This change does not promote the separate E038 research capsule into Android or replace a phone's learned state with that research seed. The personal module recognizes its taught short expressions and variants; its requests do not execute arbitrary engineering work.

The version is `E025-Chain-X01-1`. The primary workflow invokes the packager, verifies exact asset hashes, runs a native migration/control test and packages the personalized capsule. Gradle's Workbench/Control asset tasks and the manual test APK script refuse a build if X01 assets are missing or overwritten. The classic/desktop legacy workflow is unchanged; its unrelated flavors do not define the primary APK recipe.

Build locally after reproducing E025 assets:

```bash
node bbyq-interface/install-personal-x01.mjs build/reverse_pc build/e025 build/personal-x01 reverse-os-android/app/src/main/assets
node bbyq-interface/verify-personal-x01.mjs reverse-os-android/app/src/main/assets
node bbyq-interface/tests/personal-x01.mjs build/reverse_pc build/e025 build/personal-x01 build/x01-tests
```

The compressed XI sources and their hashes are in `bbyq-interface/personal-x01`. Generated APK assets are build products and are not checked into source. The Android update validates the lesson bytecode hash before applying it. A namespace collision aborts without replacing the user's old app. An existing valid X01 state is kept so later explicit corrections are not reset.

Local verification covers native capsule execution, old knowledge, quantity stories, W4u requests, stale-request clearing and live-state migration. Device migration and APK compilation are checked by the primary CI workflow; they must not be reported as completed until that run succeeds. No new APK is published by this source change. A future distribution must retain the existing signing identity and use a versionCode above the user's installed version.
