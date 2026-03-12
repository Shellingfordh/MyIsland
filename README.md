# MyIsland — macOS Dynamic Island Pill (Next‑Gen Menu Bar)

**English | 中文 (Quick View)**

MyIsland turns your Mac menu bar into a **Dynamic Island‑style pill** for the next generation of MacBooks — even on **notchless** models. It’s a high‑performance Sketchybar configuration that brings **live status**, **music**, **notifications**, **Siri**, **volume/brightness**, and **agent shortcuts** into a clean, always‑on‑top capsule.

MyIsland 将 Mac 菜单栏变成 **药丸灵动岛**，即使是**无刘海 Mac** 也能拥有类似 iPhone Dynamic Island 的体验。基于 Sketchybar，高性能、低干扰、持续显示。

**Popular keywords:** macOS Dynamic Island, MacBook pill, Sketchybar, menu bar widget, live activities, now playing, notifications, Siri, OpenAI agents, notchless Mac.

**中文关键词：** Mac 灵动岛、macOS 药丸、Sketchybar 灵动岛、菜单栏药丸小组件、无刘海 Mac 灵动岛、实时活动、Siri 药丸。

---

## Highlights
- **Dynamic Island pill** anchored to the menu bar (half above, half below)
- **Always on top** — stays visible over fullscreen apps and lock screen
- **Live context**: front app, browser, now playing, notifications
- **Control surface**: volume/brightness via scroll
- **Agent launcher**: Siri / Ironclaw / OpenAI / GLM / Custom command
- **System‑language UI** (English or Chinese)

## 功能亮点
- 药丸中线与 menubar 顶部重合（上半在菜单栏，下半在下方）
- 始终置顶，覆盖全屏应用与锁屏
- 前台 App / 浏览器 / 音乐 / 通知实时反馈
- 滚轮调节音量与亮度
- 右键打开 Agent 设置（Siri / Ironclaw / OpenAI / GLM / 自定义命令）
- UI 自动适配系统语言

## UI & Behavior
- **Single click**: launch default agent (Siri by default)
- **Double click**: open Launchpad
- **Right click**: open Agent settings dialog
- **Scroll**: volume
- **Shift + Scroll**: brightness

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

---

## For Apple (Product Proposal)
**Problem:** Mac users want a glanceable, interactive, non‑intrusive surface that unifies system states, media, and assistant workflows — especially on notch‑less Macs where the menu bar feels under‑utilized.

**MyIsland’s approach:** A minimal pill that sits across the menu bar boundary. It looks native, stays calm when idle, and comes alive only when context changes.

**What makes it Apple‑grade:**
- Sub‑50ms visual updates for core states
- Predictable, quiet UI (no noisy animations by default)
- Strong alignment with Dynamic Island mental model
- Clear support for notch‑less MacBooks

**Potential collaboration paths:**
- **Apple Developer Relations** — present as a UX prototype for menu bar interactions
- **Feedback Assistant** — file under macOS UI/UX or menu bar interaction
- **WWDC Labs / Dev Forums** — request UI/interaction feedback
- **Design critique** — provide a short demo video and a product brief

If you’re an Apple team member and want a short brief or demo, open an issue or contact via GitHub.

---

## Docs
- Technical & version docs: `README_CONFIG.md`
- 中文说明：`README_CN.md`

---

If you want a **Dynamic Island pill for Mac** with a clean, minimal aesthetic — this is it.
