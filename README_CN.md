# MyIsland — macOS 菜单栏灵动岛 (SketchyBar)

**语言切换 | Language**  
- 中文版: `README_CN.md`  
- English: `README.md`

基于 **SketchyBar** 的 **macOS 灵动岛**风格药丸，强调 **Apple 设计语言**、**原生质感** 与 **手动可控**。适配刘海屏与非刘海设备，居中沉浸，轻量高效。

**关键词（自然融入）：** macOS 灵动岛、SketchyBar、菜单栏小组件、苹果 HIG、原生 UI、刘海、效率工具、系统 OSD 替代、Siri 药丸、极简设计、玻璃拟态、macOS 美化、菜单栏增强、Apple Silicon 工作流。

---

## 亮点
- **自动语言适配**（可选手动覆盖）。
- **接管音量/亮度 OSD**（原生事件驱动显示）。
- **音频微面板**（音量/静音快速查看）。
- **玻璃层**开关（更原生的质感）。
- **快速切换**（从药丸菜单快速打开应用）。
- **手动用户行为**：不自动登录、不自动验证码、不注入 cookies。

## 原理
- SketchyBar 渲染药丸。
- 读取前台应用、通知、音量、亮度等系统状态展示。
- 所有敏感操作由用户手动完成。

## 安装
1. 将仓库内容复制到 `~/.config/sketchybar/`。
2. 授权执行：
   ```bash
   chmod +x ~/.config/sketchybar/sketchybarrc ~/.config/sketchybar/plugins/*.sh
   ```
3. 重启 SketchyBar：
   ```bash
   brew services restart sketchybar
   ```

## 操作
- **单击**：唤起 Siri/代理。
- **双击**：Launchpad。
- **滚轮**：音量（正常滚动），亮度（Shift + 滚动）。
- **键盘音量/亮度**：药丸自动显示变化。
- **右键菜单**：设置、快速切换、玻璃层、音频面板。

## 文档
- `README_CONFIG.md`
- `REQUIREMENTS_v2.1.md`

## 说明
- Siri 的问候语语言由系统 Siri 设置决定。

## Agent 下一阶段（更大的版本设想）
**Agent vNext** 不再是对话框，而是原生系统助理：  
- **上下文感知**：理解当前应用、媒体状态、系统专注模式。  
- **多模态**：文字 + 系统 UI 状态 + 视觉上下文（需用户确认）。  
- **动作守护**：所有关键操作需明确确认。  
- **隐私优先**：默认本地、最小化数据暴露。

## v2.1 预告（stars 驱动）
我们会对齐社区长期受欢迎的方向：**菜单栏正在播放**、**刘海效率托盘**、**玻璃层 UI**、**快捷开关**。灵感来自真实的菜单栏应用生态（音乐、通知、界面美化类），但目标是把这些体验融合成更符合 Apple HIG 的统一灵动岛。

## 许可证
GPL-3.0（见 `LICENSE`）。
