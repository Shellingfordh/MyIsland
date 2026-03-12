# Sketchybar Island 1.0 文档

> 位置：`~/.config/sketchybar`

## 版本
- 当前：1.2.0
- 上一版：1.0

## 1.0 概览
该配置实现一个“Dynamic Island”风格的 Sketchybar 中央胶囊（item: `island`），可根据前台应用/浏览器/音乐播放/通知动态切换文案、图标与流光边框。整体由 `sketchybarrc` 负责布局与事件绑定，`plugins/island.sh` 负责核心逻辑渲染，`plugins/notifier.sh` 负责监听通知中心并触发事件。

核心能力：
- 机型自适配：根据刘海/机型/架构决定整体高度与 Y 偏移
- 前台应用识别：系统/第三方 App 映射表与 Emoji 图标
- 浏览器标签识别：识别视频网站/社交站点等特征并给出状态
- 音乐播放检测：Spotify/Apple Music 等播放器状态
- 通知中心监听：新通知触发短暂提示
- 动态流光边框：基于时间生成颜色序列并做动画

## 目录结构
```
~/.config/sketchybar/
├─ sketchybarrc              # Sketchybar 主配置入口
└─ plugins/
   ├─ island.sh               # Dynamic Island 逻辑/渲染主脚本
   ├─ notifier.sh             # 通知中心监听脚本（sqlite3）
   └─ notifier.sh.x           # 二进制文件（疑似编译产物/旧版）
```

## 启动入口与事件
### 入口：`sketchybarrc`
- 初始化环境与机型参数：
  - `MODEL_NAME`, `ARCH`
  - `HAS_NOTCH`（通过内置显示器属性）
  - `CHECK_TOP_OCCUPIED`（系统进程名正则检测“notch/island”等）
- 计算 UI 尺寸：`BAR_HEIGHT`, `ISLAND_BG_HEIGHT`, `CORNER_RADIUS` 等
- 配置 bar：透明、topmost、sticky、全屏可见
- 添加 item `island`（位置 center）
- 绑定事件：
  - `front_app_switched`, `display_change`, `space_change`, `system_woke`
  - 自定义事件 `notification_occurrence`, `island_update`

> 注意：`sketchybarrc` 中脚本路径写死为 `/Users/majia/...`，实际用户为 `blahbla`。若路径不一致会导致脚本无法执行，应改为当前用户路径或使用 `$HOME`。

### 事件流
1. `sketchybar` 定时/事件触发 `island.sh`
2. `island.sh` 收集状态并渲染 item 属性
3. `notifier.sh` 轮询通知数据库，触发 `notification_occurrence` 事件

## 核心脚本说明
### `plugins/island.sh`
职责：识别环境状态并渲染 `island` item。

关键模块：
1. 环境与机型校准
- 通过 `ioreg` 与 `System Events` 判断刘海与顶部占用
- 根据机型/架构动态计算 `Y_OFFSET` 与 `ICON_Y_FIX`

2. 权限引导
- 首次运行触发 `System Events` 权限弹窗
- 通过 `/tmp/sketchybar_island_auth_done` 标记已授权

3. 流光色引擎
- `RAINBOW` 24 色库 + 呼吸透明度
- `generate_stream()` 生成 CACB 轮转流光序列
- `get_app_color()` 根据 App 或 BundleID 决定色系

4. 状态采集（`get_info`）
- 通知缓存：`/tmp/sketchybar_island_notif`（5 秒有效）
- 前台应用信息：`System Events` 获取 frontmost app
- 播放器检测：Spotify/Apple Music/网易云等
- 浏览器检测：Chrome/Arc/Safari/Edge/FireFox
- App Emoji 映射：大量 bundle id 到 emoji

5. 交互处理
- 点击 island 打开 Launchpad，并短暂改变边框颜色

6. 渲染输出
- `COMMON_ARGS` 统一渲染属性
- 根据状态 `PLAY|GEMINI|WEB|FOCUS|NOTIF|IDLE` 更新 icon/label/颜色
- `--animate sin` 让边框颜色流动

临时文件：
- `/tmp/sketchybar_island_state`：缓存上一状态
- `/tmp/sketchybar_island_auth_done`：权限标记
- `/tmp/sketchybar_island_notif`：通知缓存

### `plugins/notifier.sh`
职责：监听通知中心数据库并触发事件。

- 轮询数据库：`~/Library/Application Support/NotificationCenter/db2/db`
- 读取最新一条通知（app_id/title）
- 新通知触发：
  ```
  sketchybar --trigger notification_occurrence INFO="$title"
  ```
- 轮询间隔：2 秒

### `plugins/notifier.sh.x`
二进制文件，无法直接阅读源码。推测为 `notifier.sh` 的编译版本或旧工具产物，当前配置未使用该文件。

## 功能清单（1.0）
- 动态岛胶囊 UI（居中）
- 刘海/非刘海与架构适配
- 前台 App 名称 + Emoji + 颜色流光
- 浏览器标签识别（视频网站/社交站点/Google/Apple）
- 音乐播放状态显示
- 通知提示（5 秒内显示）
- 单击唤起 Siri，双击唤起 Launchpad

## 1.1 新增功能
- 药丸接管系统通知/音量/亮度的交互入口（滚轮调节）
- 鼠标交互事件订阅：`mouse.clicked`, `mouse.scrolled`
- 菜单栏高度对齐修正（基于 `System Events` 获取菜单栏高度）

## 1.2 新增功能
- 单击唤起 Siri，双击唤起 Launchpad（全部 App 界面）
- 右键打开 Agent 设置界面（系统对话框，含 Custom 命令）
- UI 文字根据系统语言自动适配（中文/英文）
- 新增 Agent 配置文件：`~/.config/sketchybar/agent.conf`（示例：`agent.conf.example`，支持 Custom 命令）

## 运行依赖
- macOS（需要 `osascript` + `System Events` 权限）
- `sketchybar` 已安装并运行
- `sqlite3` 可用（用于通知监听）
- `ioreg`, `sysctl`, `uname` 等系统工具

## 已知问题与注意事项
- **路径硬编码**：`sketchybarrc` 中脚本路径是 `/Users/majia/...`，需改为当前用户路径或 `$HOME`。
- **通知数据库权限**：访问通知数据库可能因系统权限/完整磁盘访问限制失败。
- **`notifier.sh.x` 未使用**：建议确认是否需要保留。
- **顶部占用检测**：依赖进程名正则，可能存在误判或漏判。

## 建议的后续演进方向（1.1+）
- 统一路径为 `$HOME/.config/sketchybar/...`
- 将颜色/应用映射抽出为可配置表
- 浏览器站点识别改为 URL 规则表
- 提供启动/停止 `notifier.sh` 的管理脚本
