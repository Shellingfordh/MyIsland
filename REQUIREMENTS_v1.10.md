# REQUIREMENTS v1.10

## Goals
1. **Global Now Playing**: show current track even when Music/Spotify is not frontmost.
2. **Language override**: allow forcing Island UI language via `USER_LANG`.
3. **OSD events**: keep native `volume_change` / `brightness_change` reliability.

## Scope
- `plugins/island.sh`: add global play detection.
- `userconfig.example.sh`: add language override.
- Docs: README (EN/中文) update with natural hot keywords + preview.

## Acceptance
- Music playing shows “Now Playing · Title — Artist”.
- Setting `USER_LANG=en` forces English UI in the pill.
