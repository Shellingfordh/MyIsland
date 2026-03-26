# REQUIREMENTS v2.0 (Major)

## Vision
Turn MyIsland into a **menu‑bar Dynamic Island system** that feels native to macOS (Apple HIG), unifies **OSD**, **Now Playing**, **notch tray**, and **quick actions**, while keeping **manual user control** and zero account automation.

## Signals (GitHub trendline themes)
- **AI/agent tooling & design systems** are trending heavily.
- **Desktop UX polish** (native motion, HIG‑aligned behavior) is a differentiator.
- **Menu bar productivity** remains popular (music, quick toggles, notifications).

## Goals (v2.0)
1. **System Pill Stack**
   - Unified states: OSD (volume/brightness), Now Playing, Notifications, Focus mode, Quick Toggles.
   - Clear priority & cooldown rules (no flicker).
2. **Notch Productivity Tray**
   - Drop zone (files/text) + quick actions (AirDrop, clipboard, share).
   - Optional mini‑widgets (calendar/clock, battery, network).
3. **Native Motion Layer**
   - Apple‑style easing, subtle scale/blur, and adaptive timing.
   - Consistent animation semantics across states.
4. **Siri + Agent UX**
   - Single click → Siri/agent.
   - Double click → Launchpad.
   - Right click → Settings.
5. **Localization & Accessibility**
   - System language alignment, optional user override.
   - Readable contrast & reduced motion option.
6. **Telemetry‑free & Offline‑first**
   - Local‑only by default, no hidden network calls.

## Scope (Proposed Modules)
- `plugins/island.sh`: state machine, priorities, animation params.
- `plugins/control_watch.sh`: OSD events + debounce.
- `plugins/now_playing.sh`: media polling + album art hook.
- `plugins/notch_tray.sh`: drop zone + quick actions.
- `sketchybarrc`: module orchestration + events.

## Non‑Goals
- Auto login, captcha automation, or cookie injection.
- Hidden telemetry.

## Acceptance Criteria
- Keyboard volume/brightness shows in pill within 300ms.
- Now Playing shows track + artist with stable updates.
- Notch tray accepts drag‑drop with a clear visual affordance.
- All interactions match Apple HIG baseline.

## Release Assets
- DMG + config zip.
- README (EN/中文) with natural‑language keywords and trendline preview.
