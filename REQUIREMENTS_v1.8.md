# REQUIREMENTS v1.8

## Goals
1. **Double‑click reliability**: prevent accidental single‑click actions (no Siri pop‑up on double click).
2. **Now Playing labeling**: show "Now Playing · Title" in the pill when music is playing.
3. **Language alignment**: UI strings follow system language consistently.
4. **Release assets**: DMG + config zip updated.

## Scope
- `plugins/island.sh`: click debounce improvements + Now Playing label.
- Docs: README (EN/中文) update with next preview + natural hot keywords.
- Release packaging + GitHub release.

## Acceptance
- Double click opens Launchpad only; no Siri popup.
- Music play state shows "Now Playing · {Title}" localized.
- README includes natural keyword‑rich description.
