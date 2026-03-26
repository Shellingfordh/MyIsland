# REQUIREMENTS v2.1 (Star‑Driven)

## Source
Derived from the full list of starred repositories under `Shellingfordh` (183 repos). Themes with the highest signal: **macOS utilities**, **menu bar UX**, **Dynamic‑Island style UI**, **audio control**, and **HIG‑aligned visual polish**.

Key inspiration clusters from starred repos:
- **Dynamic‑Island UX**: `crissNb/Dynamic-Island-Sketchybar`
- **Audio routing / per‑app volume**: `kyleneideck/BackgroundMusic`
- **Menu bar visual polish**: `bartreardon/GlassBar`
- **Launchpad productivity**: `RoversX/LaunchNext`
- **MacOS utilities / curated lists**: `jaywcjlove/awesome-mac`

## Goals (v2.1)
1. **Audio Micro‑Panel**
   - Lightweight per‑app volume readout (system audio session list).
   - Quick mute / focus mode toggle.
   - Optional: integrate with BackgroundMusic if installed.

2. **Menu Bar Glass Layer**
   - A configurable “glass” backdrop behind the island for Apple‑like depth.
   - Toggle on/off via right‑click menu.

3. **Launchpad Quick Switch**
   - A minimal app switcher view inspired by LaunchNext.
   - Single search input and recent apps list.

4. **Dynamic Island State Engine v2**
   - Consistent priority rules between OSD / Now Playing / Notifications.
   - Clear enter/exit animations per state (HIG‑aligned).

## Scope (Modules)
- `plugins/island.sh`: add state priority + audio micro‑panel trigger.
- `plugins/audio_panel.sh`: detect sessions (if supported) or bridge to BackgroundMusic.
- `plugins/glass_layer.sh`: optional visual layer config.
- `sketchybarrc`: toggles & events.

## Non‑Goals
- Auto login or captcha automation.
- Hidden telemetry.
- Full audio DSP or system‑wide audio capture.

## Acceptance Criteria
- Audio panel shows within 500ms on trigger; no UI flicker.
- Glass layer toggle is instant and persists in user config.
- Launchpad switcher opens within 300ms and closes reliably.

## Release Assets
- DMG + config zip
- README (EN/中文) updated with natural trendline keywords
