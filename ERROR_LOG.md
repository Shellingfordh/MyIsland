# Sketchybar Island Error Log

## 2026-03-12
- sketchybarrc: missing line continuation after `script="$HOME/.config/sketchybar/plugins/island.sh"` caused malformed `sketchybar --set` command. Detected before edits and fixed in this change set.

## 2026-03-12 (v1.2 edits)
- Fixed broken quoting in `osascript` calls inside `plugins/island.sh` (prompt dialog and notification) after adding Agent settings and OpenAI dispatch.
