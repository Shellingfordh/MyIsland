# MyIsland — macOS Dynamic Island for SketchyBar

**EN | 中文**  
- English: `README.md`  
- 中文版: `README_CN.md`

A polished **Dynamic Island**-style pill for the **macOS menu bar** using **SketchyBar**. Native‑like visuals, Apple‑style interactions, and **manual user control** (no auto-login, no cookie injection). Designed for **Notch MacBook** and non‑notch devices with adaptive positioning.

**Keywords (natural):** macOS Dynamic Island, SketchyBar, menu bar widget, Apple HIG, native UI, notch bar, productivity, OSD replacement, Siri pill, minimal UI, glassmorphism, macOS customization, menu bar utility, Apple Silicon workflow.

---

## Highlights
- **System-language aware UI** (auto‑localized, optional override).
- **Pill takeover for Volume/Brightness OSD** (native event‑driven display).
- **Flux‑style controls** (toggle, schedule, temperature, movie mode via Night Shift).
- **Notch Productivity Tray** with **Drop Box** (drag files into a folder, auto‑action).
- **Glass layer** toggle for Apple‑style depth.
- **Quick Switch** (fast app launch from the pill menu).
- **Manual user behavior only**: no auto-login, no captcha automation, no cookie injection.

## How it works
- Uses SketchyBar to render a floating pill.
- Reads system state (front app, notifications, volume, brightness) and displays it in the Island.
- All actions are user‑driven and local.

## Install
1. Copy the repo contents to `~/.config/sketchybar/`.
2. Ensure scripts are executable:
   ```bash
   chmod +x ~/.config/sketchybar/sketchybarrc ~/.config/sketchybar/plugins/*.sh
   ```
3. Restart SketchyBar:
   ```bash
   brew services restart sketchybar
   ```

## Controls
- **Single click**: open Siri/agent.
- **Double click**: Launchpad.
- **Scroll**: Volume (normal scroll), Brightness (Shift + scroll).
- **Keyboard volume/brightness**: the pill shows the change automatically.
- **Right click**: Settings, Flux, Tray, Quick Switch, Glass.

## Notch Productivity Tray — Drop Box
This adds a **drag‑and‑drop workflow** without unsafe automation.

1. **Open Drop Box**: right click → `Drop Box` (opens a folder).
2. **Choose target**: right click → `Drop → Downloads/Desktop/Clipboard/AirDrop`.
3. **Drag files into the folder**; the pill confirms the action within ~1s.

Default folder: `~/Downloads/MyIslandDrop` (configurable via `USER_DROP_DIR`).

## Docs
- `README_CONFIG.md`
- `REQUIREMENTS_v2.3.md`

## Notes
- Flux controls use the `nightlight` CLI (opens install page if missing).
- Siri greeting language is controlled by macOS Siri settings.

## Agent Next Evolution (big update idea)
**Agent vNext** should feel like a native macOS assistant, not a chatbot:  
- **Context‑aware**: understands current app, media state, and system focus.  
- **Multimodal**: text + system UI state + visual context (safe, user‑approved).  
- **Action‑guarded**: explicit confirmations, no silent automation.  
- **Privacy‑first**: local by default, minimal data exposure.

## License
GPL-3.0 (see `LICENSE`).
