# MyIsland — macOS Dynamic Island for SketchyBar

**EN | 中文**  
- English: `README.md`  
- 中文版: `README_CN.md`

A polished **Dynamic Island**-style pill for the **macOS menu bar** using **SketchyBar**. Native‑like visuals, Apple‑style interactions, and **manual user control** (no auto-login, no cookie injection). Designed for **Notch MacBook** and non‑notch devices with adaptive positioning.

**Keywords (natural):** macOS Dynamic Island, SketchyBar, menu bar widget, Apple HIG, native UI, notch bar, productivity, OSD replacement, Siri pill, minimal UI, glassmorphism, macOS customization, menu bar utility, Apple Silicon workflow.

---

## Highlights
- **System-language aware UI** (auto‑localized).
- **Pill takeover for Volume/Brightness OSD** (native event‑driven display).
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
- **Single click**: open Siri/agent.
- **Double click**: Launchpad.
- **Scroll**: Volume (normal scroll), Brightness (Shift + scroll).
- **Keyboard volume/brightness**: the pill shows the change automatically.

## Docs
- `README_CONFIG.md`
- `REQUIREMENTS_v2.0.md`

## Notes
- Siri greeting language is controlled by macOS Siri settings.

## v2.0 Preview (trend‑aligned)
We’re aligning with what the macOS community consistently gravitates toward: **menu‑bar Now Playing**, **notch productivity trays**, **lightweight notifications**, and **quick‑toggle utilities**. Inspiration comes from real‑world menu bar apps (music players, repo switchers, notification hubs), but the goal is to merge those ideas into a single Apple‑HIG‑friendly Dynamic‑Island surface — clean, subtle, and fast.

## License
GPL-3.0 (see `LICENSE`).
