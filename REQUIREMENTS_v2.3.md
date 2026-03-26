# REQUIREMENTS v2.3 (Notch Drop Tray)

## Goals
1. **Notch Productivity Tray (Drop Box)**: drag files into a dedicated folder to trigger actions.
2. **User controls**: right‑click menu to open Drop Box + set target (Downloads/Desktop/Clipboard/AirDrop).
3. **Clear UX**: pill shows confirmation after each drop.

## Scope
- `plugins/drop_watch.sh`: watch Drop Box and execute actions.
- `plugins/island.sh`: settings entries for Drop Box and targets.
- `sketchybarrc`: add drop watcher item.
- Docs: README (EN/中文) usage section.

## Acceptance
- New file in Drop Box triggers action within 1s.
- Target switching works and persists during session.
- README clearly explains drop workflow.
