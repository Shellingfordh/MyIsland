# REQUIREMENTS v1.7

## Goals
1. **Language auto‑localization**: UI text must follow system language (EN/中文) reliably.
2. **OSD takeover**: Volume/Brightness changes (keyboard/scroll) should display in the Island pill.
3. **Manual user behavior**: no auto login, no captcha automation, no cookie injection.
4. **Release packaging**: ship DMG + updated docs in GitHub Release.

## Scope
- `plugins/island.sh`: fix locale detection and ensure consistent localization.
- `plugins/control_watch.sh`: new watcher to detect volume/brightness changes.
- `sketchybarrc`: add watcher item.
- Docs: update README (EN/中文), add v1.7 requirements.

## Acceptance
- Double‑click UI text matches system language.
- Keyboard volume/brightness changes show in pill within 1s.
- Scroll adjustments show in pill immediately.
- Release includes DMG and updated docs.

## Non‑Goals
- Auto login or captcha automation.
- Platform‑specific publishing changes.
