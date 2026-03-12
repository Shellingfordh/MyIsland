# MyIsland — macOS 药丸灵动岛（下一代 MacBook 菜单栏）

MyIsland 把 Mac 菜单栏变成 **药丸灵动岛**，即使是 **无刘海 Mac** 也能拥有类似 iPhone Dynamic Island 的体验。基于 Sketchybar，高性能、低干扰、持续显示。

**关键词**：Mac 灵动岛、macOS 药丸、Sketchybar 灵动岛、菜单栏药丸小组件、无刘海 Mac 灵动岛、实时活动、Siri 药丸、OpenAI 代理。

## 功能亮点
- 药丸中线与 menubar 顶部重合（上半在菜单栏，下半在下方）
- 始终置顶，覆盖全屏应用与锁屏
- 前台 App / 浏览器 / 音乐 / 通知实时反馈
- 滚轮调节音量与亮度
- 右键打开 Agent 设置（Siri / Ironclaw / OpenAI / GLM / 自定义命令）
- UI 自动适配系统语言

## UI 与交互
- **单击**：唤起默认 Agent（默认 Siri）
- **双击**：打开 Launchpad
- **右键**：打开 Agent 设置
- **滚轮**：音量
- **Shift + 滚轮**：亮度

## 快速使用
- 配置目录：`~/.config/sketchybar`
- 入口文件：`sketchybarrc`、`plugins/island.sh`
- 重启：
  ```bash
  brew services restart sketchybar
  ```

## Agent 设置
编辑 `~/.config/sketchybar/agent.conf`（示例：`agent.conf.example`）
- `AGENT_PROVIDER` = `siri | ironclaw | openai | glm | custom`
- `CUSTOM_COMMAND` 支持 `{prompt}` 占位符
- OpenAI 需要配置 `OPENAI_API_KEY`

## 用户调节（高度 / 偏移）
可选配置：`~/.config/sketchybar/userconfig.sh`（示例：`userconfig.example.sh`）：
- `USER_BAR_HEIGHT` 或 `USER_BAR_EXTRA`
- `USER_ISLAND_BG_HEIGHT`
- `USER_ISLAND_Y_OFFSET_EXTRA`

---

## 下一版本预告（游戏式）
- **像素校准**：UI 内调节偏移，按机型保存
- **始终置顶**：全屏与多空间持续显示
- **Agent Hub**：Siri / OpenAI / OpenClaw / Ironclaw / Custom 切换
- **连续互通**：与 iPhone 的专注、媒体、实时活动联动

---

## For Apple（产品提案摘要）
**问题：** Mac 用户需要一种低干扰、可感知、可控制的统一入口，能把系统状态、媒体、通知和助手能力整合在菜单栏中，尤其在无刘海 Mac 上更明显。

**MyIsland 的做法：** 用一个跨越菜单栏边界的药丸，让“静态 + 动态”状态自然切换，保持克制与原生感。

**为何适合 Apple：**
- 视觉更新快速、稳定
- UI 情绪克制，避免噪音
- 与 iPhone 灵动岛的认知一致
- 对无刘海机型有明确价值

**建议触达路径：**
- Apple Developer Relations
- Feedback Assistant（macOS UI/UX 或 Menu Bar 类目）
- WWDC Labs / Dev Forums
- 设计团队短视频 + 产品简报

---

## 文档
- 技术文档与版本说明：`README_CONFIG.md`
- 需求路线图：`REQUIREMENTS_v1.1.md` → `REQUIREMENTS_v1.6.md`
- English: `README.md`
