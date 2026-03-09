#!/bin/bash
# 创建用户配置目录
mkdir -p ~/Library/Application\ Support/MyIsland

# 拷贝资源（只在第一次运行时）
if [ ! -d ~/Library/Application\ Support/MyIsland/sketchybar-config ]; then
    cp -R "$PWD/Contents/Resources/sketchybar-config" ~/Library/Application\ Support/MyIsland/
fi

# 启动 sketchybar 指定配置目录
sketchybar --config ~/Library/Application\ Support/MyIsland/sketchybar-config/sketchybarrc