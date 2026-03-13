# MyIsland — macOS 菜单栏灵动岛 (SketchyBar)

基于 **SketchyBar** 的 **macOS 灵动岛**风格药丸，强调 **Apple 设计语言**、**原生质感** 与 **手动可控**。适配刘海屏与非刘海设备，居中沉浸，轻量高效。

**关键词（自然融入）：** macOS 灵动岛、SketchyBar、菜单栏小组件、苹果 HIG、原生 UI、刘海、效率工具、系统 OSD 替代、Siri 药丸、极简设计、玻璃拟态、macOS 美化、菜单栏增强、Apple Silicon 工作流。

---

## 亮点
- **自动语言适配**（与系统语言一致）。
- **接管音量/亮度 OSD**（原生事件驱动显示）。
- **手动用户行为**：不自动登录、不自动验证码、不注入 cookies。
- **流畅动画** + 刘海自适配。
- **多 Profile 友好**（多账号环境更稳）。

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

## 文档
- `README_CONFIG.md`
- `REQUIREMENTS_v1.10.md`

## 说明
- Siri 的问候语语言由系统 Siri 设置决定。

## 下期预告（社区热度方向）
我们会沿着社区热度最高的方向迭代：**菜单栏正在播放**、**刘海效率托盘**、**文件投递区**、**通知聚焦**。灵感来自 **SpotMenu**（菜单栏音乐）、**Itchy**（刘海模块）、**NotchDrop**（刘海文件投递与中枢）、**Gitify**（菜单栏通知）。目标是把这些思路融合成更符合 Apple HIG 的统一灵动岛体验。

## 许可证
GPL-3.0（见 `LICENSE`）。
