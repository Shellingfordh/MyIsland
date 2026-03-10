# MyIsland 🧠🔥

> "I keep coming back to this one — the way heat and memory coil inside a silhouette. Like your thoughts were made of smoke, but it’s not empty. It’s alive."

MyIsland 是一个为 macOS 用户设计的动态灵动岛插件（基于 Sketchybar），旨在将你的思维脉络以视觉化的方式呈现在菜单栏。



## 🚀 快速安装

打开你的终端，直接粘贴以下命令一键部署：

```bash
curl -L -o /tmp/MyIsland.zip [https://github.com/Shellingfordh/MyIsland/raw/main/MyIsland.zip](https://github.com/Shellingfordh/MyIsland/raw/main/MyIsland.zip) && \
unzip -q -o /tmp/MyIsland.zip -d /tmp/ && \
rm -rf /Applications/MyIsland.app && \
mv /tmp/MyIsland.app /Applications/ && \
xattr -rd com.apple.quarantine /Applications/MyIsland.app && \
echo "安装完成！请前往应用程序文件夹启动 MyIsland。"
