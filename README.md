# MyIsland — macOS Dynamic Island for SketchyBar

A polished **Dynamic Island**-style pill for **macOS menu bar** using **SketchyBar**. Native-like visuals, Apple-style interactions, and **manual user control** (no auto-login, no cookie injection). Designed for **Notch MacBook** and non‑notch devices with adaptive positioning.

**Keywords:** macOS Dynamic Island, SketchyBar, menu bar widget, Apple HIG, native UI, notch bar, productivity, OSD replacement, Siri pill, minimal UI, glassmorphism, macOS customization, menu bar utility, macOS workflow.

---

## Highlights
- **System-language aware UI** (auto‑localized).
- **Pill takeover for Volume/Brightness OSD** (shows system changes in the Island).
- **Manual user behavior only**: no auto-login, no captcha automation, no cookie injection.
- **Smooth animations** and adaptive notch alignment.
- **Multi-profile ready**: works well with separate Chrome profiles.

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
- **Single click**: open agent (Siri/Custom).
- **Double click**: Launchpad.
- **Scroll**: Volume (normal scroll), Brightness (Shift + scroll).
- **Keyboard volume/brightness**: the pill shows the change automatically.

## Docs
- `README_CONFIG.md`
- `REQUIREMENTS_v1.7.md`

## Notes
- For brightness polling, `brightness` CLI is optional (if installed, higher accuracy).

## Next Preview (GitHub Trending inspirations)
- **Now Playing pill** (album art + controls), inspired by menu‑bar music apps.
- **Notch productivity tray** (file drop, clipboard, quick actions), inspired by notch utility apps.
- **Native SwiftUI‑like motion** and glass layers for a more Apple‑consistent look.

## License
GPL-3.0 (see `LICENSE`).
