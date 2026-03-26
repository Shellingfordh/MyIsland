# Sketchybar Island v1.2 需求文档

版本号：`1.2.0`

## 目标
- 单击唤起 Siri、双击唤起 Launchpad（全部 App 界面）
- UI 文案根据系统语言自动切换（英文/中文）
- 增加 Agent 选择与模型设置入口，支持 Siri/Ironclaw/OpenAI/GLM/Custom

## 功能需求
1. 点击交互
- 单击：按当前默认 Agent 执行（默认 Siri）
- 双击：打开 Launchpad
- 右键：打开 Agent 设置对话框

2. 语言适配
- 根据 `AppleLocale` 决定 UI 文案语言
- 非中文系统默认显示英文

3. Agent 接入
- 默认提供 `siri`, `ironclaw`, `openai`, `glm`, `custom`
- 通过 `~/.config/sketchybar/agent.conf` 保存设置
- OpenAI 可自定义模型名，API Key 通过环境变量提供
- Custom 可配置外部命令（支持 {prompt} 占位）

## 约束
- 不改变现有通知/播放器/前台应用逻辑
- 不依赖额外 GUI 框架，使用系统对话框作为设置界面

## 验收要点
- 单击唤起 Siri、双击唤起 Launchpad
- 右键打开设置对话框并生效
- 英文系统环境下 UI 显示英文
- OpenAI / Ironclaw 能接收输入并触发请求
