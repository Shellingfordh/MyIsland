# MyIsland v1.6 Requirements (Draft)

## Goal
Make the pill feel native on all Macs (with/without notch), stay above fullscreen, and become the unified control hub for system + AI agents.

## Key Features
- Adaptive position engine:
  - Pixel-perfect alignment for all 8 device classes (M/Intel × Air/Pro × Notch/No‑notch).
  - Runtime calibration UI (nudges, save per model) + auto-detect model profile.
- Always-on-top behavior:
  - Ensure pill renders above fullscreen apps and across all spaces.
  - Lock screen visibility support (if system allows), with safe fallback.
- Unified system controls:
  - Notifications, volume, brightness, media, Focus modes.
  - Scroll gestures with modifier handling and consistent labels.
- Agent hub:
  - Unified agent picker (Siri / OpenAI / OpenClaw / Ironclaw / Nanoclaw / Custom).
  - Per-agent settings and model selection with validation.
  - Local / remote routing policy, offline fallback.
- iPhone continuity:
  - Hand off actions to iPhone (Focus, media, Siri prompts).
  - Mirror iPhone Live Activities when possible.

## UX & UI
- English/Chinese localization parity for all labels and prompts.
- Pill height and vertical alignment user-tunable via UI + config.
- Animated transitions that mirror iPhone Dynamic Island timing (spring, 180–220ms).

## Tech Plan
- Introduce `device_profiles.json` with profile overrides per model.
- Add settings UI panel (agent selection, model, offsets, height).
- Implement overlay fix path: check for `topmost`, `sticky`, and reparent to active display when fullscreen changes.

## Success Criteria
- M1 Air alignment correct within ±1px without manual tuning.
- Pill remains visible during fullscreen, Mission Control, and lock screen where permitted.
- 1-click Siri + 2-click Launchpad works reliably on all devices.
- Localizations respect system language (AppleLanguages first).
