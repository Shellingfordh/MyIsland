# MyIsland — macOS Dynamic Island Pill (Next‑Gen Menu Bar)

MyIsland turns your Mac menu bar into a **Dynamic Island‑style pill** for the next generation of MacBooks — even on **notchless** models. It’s a high‑performance Sketchybar configuration that brings **live status**, **music**, **notifications**, **Siri**, **volume/brightness**, and **agent shortcuts** into a clean, always‑on‑top capsule.

**Popular keywords:** macOS Dynamic Island, MacBook pill, Sketchybar, menu bar widget, live activities, now playing, notifications, Siri, OpenAI agents, notchless Mac.

## Highlights
- **Dynamic Island pill** anchored to the menu bar (half above, half below)
- **Always on top** — stays visible over fullscreen apps and lock screen
- **Live context**: front app, browser, now playing, notifications
- **Control surface**: volume/brightness via scroll
- **Agent launcher**: Siri / Ironclaw / OpenAI / GLM / Custom command
- **System‑language UI** (English or Chinese)

## Quick Start
- Config lives in `~/.config/sketchybar`
- Main files: `sketchybarrc`, `plugins/island.sh`
- Restart Sketchybar:
  ```bash
  brew services restart sketchybar
  ```

## Agent Setup
Edit `~/.config/sketchybar/agent.conf` (see `agent.conf.example`):
- `AGENT_PROVIDER` = `siri | ironclaw | openai | glm | custom`
- `CUSTOM_COMMAND` supports `{prompt}` placeholder
- For OpenAI, set `OPENAI_API_KEY` in your environment

## Docs
- Technical & version docs: `README_CONFIG.md`
- 中文说明：`README_CN.md`

---

If you want a **Dynamic Island pill for Mac** with a clean, minimal aesthetic — this is it.
