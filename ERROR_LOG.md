# Sketchybar Island Error Log

## 2026-03-12
- sketchybarrc: missing line continuation after `script="$HOME/.config/sketchybar/plugins/island.sh"` caused malformed `sketchybar --set` command. Detected before edits and fixed in this change set.

## 2026-03-12 (v1.2 edits)
- Fixed broken quoting in `osascript` calls inside `plugins/island.sh` (prompt dialog and notification) after adding Agent settings and OpenAI dispatch.

## 2026-03-12 (DMG installer)
- DMG installer used wrong config path (`MyIsland.app/config` instead of DMG root `config`). Fixed by computing DMG root in installer script.
- `launchctl load` failed with I/O error. Switched to `launchctl bootstrap gui/$UID` + `kickstart`.
- Installer failed to overwrite existing binary due to read-only permissions. Added `rm -f "$BIN_DST"` before copy.
