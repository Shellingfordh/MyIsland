# REQUIREMENTS v1.9

## Goals
1. **OSD via native events**: handle `volume_change` and `brightness_change` events for reliable display.
2. **Click behavior**: single click → Siri/agent, double click → Launchpad only.
3. **Language**: UI strings follow system language; Siri greeting is system‑provided.

## Scope
- `sketchybarrc`: subscribe to `volume_change` and `brightness_change`.
- `plugins/island.sh`: handle event payloads and show pill state.
- Docs: README (EN/中文) update.

## Acceptance
- Keyboard volume/brightness changes show in the pill instantly.
- Double click does not trigger single click.
