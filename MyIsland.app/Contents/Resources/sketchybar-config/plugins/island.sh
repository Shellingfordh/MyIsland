#!/bin/bash

# --- 0. 路径与状态初始化 ---
# 2026 增强版：确保在任何环境下路径都正确
STATE_FILE="/tmp/sketchybar_island_state"
AUTH_FLAG="/tmp/sketchybar_island_auth_done"

# 权限诱导：只在第一次手动运行或重置时执行
if [ ! -f "$AUTH_FLAG" ]; then
    # 只做一个最基础的系统权限触发，不轮询所有 App
    osascript -e 'tell application "System Events" to get name of first process' >/dev/null 2>&1
    osascript -e 'display notification "Sketchybar Island Initialized" with title "Island" subtitle "Permissions Checked"'
    touch "$AUTH_FLAG"
fi

# --- 1. 基础计算：修复版丝滑多色流动 ---
TIME=$(date +%s)
TICKS=$((TIME * 1000000000))

# 1. 缓慢旋转角度 (睡眠级呼吸感，每 6 秒转一圈)
ANGLE=$(awk "BEGIN {print ($TIME * 60) % 360}")

# 2. 呼吸 Alpha：确保始终可见，不出现 00 透明
# 范围在 0xcc (80%) 到 0xff (100%) 之间呼吸，防止颜色消失
BREATH=$(awk "BEGIN { s = sin($TIME * 1.5); print (s + 1) / 2 }")
ALPHA_VAL=$(printf "%02x" $(awk "BEGIN {printf \"%d\", 204 + ($BREATH * 51)}"))

# 24位精细色库
RAINBOW=("f87171" "fb7185" "f43f5e" "fb923c" "f97316" "ea580c" "facc15" "eab308" "ca8a04" "4ade80" "22c55e" "16a34a" "2dd4bf" "06b6d4" "0891b2" "38bdf8" "0ea5e9" "0284c7" "818cf8" "6366f1" "4f46e5" "c084fc" "a855f7" "9333ea")

# 3. 核心索引计算：确保它是整数！ (之前的低级错误就在这里)
# 使用 bash 内置取整，防止脚本崩溃
idx_float=$(echo "$TIME * 0.5" | bc -l)
idx_int=${idx_float%.*}
[ -z "$idx_int" ] && idx_int=0

i1=$(( idx_int % 24 ))
i2=$(( (idx_int + 4) % 24 ))  # 跨度调大，让多色对比更明显
i3=$(( (idx_int + 8) % 24 ))
i4=$(( (idx_int + 12) % 24 ))

# 4. 生成多色字符串：采用 0xff 强制高亮，避免 ALPHA 过低
c1="0x${ALPHA_VAL}${RAINBOW[$i1]}"
c2="0x${ALPHA_VAL}${RAINBOW[$i2]}"
c3="0x${ALPHA_VAL}${RAINBOW[$i3]}"
c4="0x${ALPHA_VAL}${RAINBOW[$i4]}"

# 最终流动色串：ABCDCBA 对称排列，实现药丸两头颜色不同且流动丝滑
RAINBOW_BREATH_COLOR="$c1:$c2:$c3:$c4:$c3:$c2:$c1"

# --- 额外修复：单色 App 的追逐流逻辑 ---
# (为了让你在普通 App 下也能看到流动，需确保渲染部分调用的 COLOR 足够亮)

# --- 2. 颜色提取函数 ---
get_app_color() {
    local app_name=$1
    local bundle_id=$2  # 接收从 get_info 传来的变量
    local color=""

    case "$app_name" in
    "Spotify")           color="0xff1db954:0xff083116" ;;
    "WeChat"|"微信")      color="0xff07c160:0xff02381c" ;;
    "Bilibili"|"哔哩哔哩") color="0xff00a1d6:0xff002835" ;;
    "YouTube")           color="0xffff0000:0xff550000" ;;
    "Telegram")          color="0xff0088cc:0xff00293d" ;;
    "Douban"|"豆瓣")      color="0xff0076d6:0xff002340" ;;
    "Kuaishou"|"快手")    color="0xffff5a00:0xff4d1b00" ;;
    "TikTok"|"抖音")      color="0xff69c9d0:0xff1f3d3f" ;;
    "Netease"|"网易云音乐") color="0xffc20c0c:0xff3d0404" ;;
    "WhatsApp")          color="0xff25d366:0xff0b3d1d" ;;
    "Facebook")          color="0xff1877f2:0xff07234a" ;;
    "Twitter"|"X")       color="0xff1da1f2:0xff093049" ;;
    "Instagram")         color="0xfff58529:0xffdd2a7b" ;;
    "LinkedIn")          color="0xff0a66c2:0xff031f3b" ;;
    "Snapchat")          color="0xfffffc00:0xff4d4d00" ;;
    "Netflix")           color="0xffff0000:0xff330000" ;;
    "Amazon Prime")      color="0xff00a8e1:0xff001f2e" ;;
    "Hulu")              color="0xff1ce783:0xff002f20" ;;
    "Disney"|"Disney+")   color="0xff113ccf:0xff00162d" ;;
    "腾讯视频"|"Tencent Video") color="0xff27b3ff:0xff002738" ;;
    "爱奇艺"|"iQIYI")     color="0xff00c63f:0xff002715" ;;
    "优酷"|"Youku"|"土豆")  color="0xff0072e3:0xff001f2a" ;;
    "央视"|"CCTV")        color="0xffe30613:0xff1a0000" ;;
    "Pornhub")           color="0xffff9900:0xff330000" ;;
    "OnlyFans")          color="0xff00b0f0:0xff001f2a" ;;
    "Xvideos")           color="0xffff0000:0xff1a0000" ;;
    "Xhamster")          color="0xffff6600:0xff330000" ;;
    "Redtube")           color="0xffff0000:0xff330000" ;;
    "Vimeo")             color="0xff1ab7ea:0xff001f2a" ;;
    "Dailymotion")       color="0xff0066cc:0xff001f2a" ;;
    "Twitch")            color="0xff6441a5:0xff0d001e" ;;
esac

    if [ -z "$color" ]; then
    case "$bundle_id" in
        "com.apple.finder")           color="0xff1ca3ff:0xff0d4d7a" ;;
        "com.apple.Safari")           color="0xff00a2ff:0xff004d7a" ;;
        "com.apple.mail")             color="0xff007aff:0xff003d7f" ;;
        "com.apple.Maps")             color="0xff34c759:0xff1d5e2a" ;;
        "com.apple.Calendar")         color="0xffff3b30:0xffb00000" ;;
        "com.apple.Contacts")         color="0xff007aff:0xff003d7f" ;;
        "com.apple.Notes")            color="0xffffd60a:0xff7a6605" ;;
        "com.apple.Reminders")        color="0xffff9500:0xff7a4700" ;;
        "com.apple.Music")            color="0xfffa2c19:0xff7a0d08" ;;
        "com.apple.TV")               color="0xffff2d55:0xff7a0d0f" ;;
        "com.apple.Photos")           color="0xffff3b30:0xffc13584" ;;
        "com.apple.Preview")          color="0xff00a2ff:0xff004d7a" ;;
        "com.apple.Maps")             color="0xff34c759:0xff1d5e2a" ;;
        "com.apple.Messenger")        color="0xff34c759:0xff1d5e2a" ;;
        "com.apple.FaceTime")         color="0xff34c759:0xff1d5e2a" ;;
        "com.apple.Calculator")       color="0xffff9500:0xff7a4700" ;;
        "com.apple.QuickTimePlayerX") color="0xff8e8e93:0xff444446" ;;
        "com.apple.ActivityMonitor")  color="0xff34c759:0xff1d5e2a" ;;
        "com.apple.AppStore")         color="0xff007aff:0xff004d7a" ;;
        "com.apple.Wallet")           color="0xff34c759:0xff1d5e2a" ;;
        "com.apple.SystemSettings")   color="0xff8e8e93:0xff444446" ;;
        "com.apple.Terminal")         color="0xffa151d3:0xff4d2665" ;;
        "com.googlecode.iterm2")      color="0xffa151d3:0xff4d2665" ;;
        "com.microsoft.VSCode")       color="0xffa151d3:0xff4d2665" ;;
        "com.apple.Warp")             color="0xffa151d3:0xff4d2665" ;;
        "com.apple.Shadowrocket")     color="0xff3674f6:0xff1a3a7a" ;;
        *)                             color="0xff8e8e93:0xff444446" ;; # 默认系统灰色
    esac
fi

    # 提取主色（去掉 0xff 前缀）
    c1=$(echo $color | cut -d: -f1 | sed 's/0x..//')
    
    # 【核心修改】：不要用 0x00000000，改用主色的低亮度版（例如 alpha 为 22）
    # 这样旋转时是从“高亮”到“暗影”再到“高亮”，而不是从“有”到“无”，视觉上就丝滑了
    echo "0x${ALPHA_VAL}${c1}:0x22${c1}:0x${ALPHA_VAL}${c1}"
}

# --- 3. 核心逻辑判断 (极速优化版) ---
get_info() {
    # 3a. 通知检测 (缓存优先，不改动)
    NOTIF_CACHE="/tmp/sketchybar_island_notif"
    if [ "$SENDER" = "notification_occurrence" ]; then
        echo "$(date +%s)|$INFO" > "$NOTIF_CACHE"
    fi
    if [ -f "$NOTIF_CACHE" ]; then
        NOTIF_DATA=$(cat "$NOTIF_CACHE")
        NOTIF_TIME=$(echo "$NOTIF_DATA" | cut -d'|' -f1)
        NOTIF_MSG=$(echo "$NOTIF_DATA" | cut -d'|' -f2)
        if [ $(( $(date +%s) - NOTIF_TIME )) -lt 5 ]; then
            echo "NOTIF|0xffffffff:0xff888888|$NOTIF_MSG|🔔"; return
        fi
        rm "$NOTIF_CACHE"
    fi

    # 3b. 极速获取前台信息 (合并调用)
    # 一次性拿到当前活跃 App 名、Bundle ID，大大降低延迟
    INFO_RAW=$(osascript -e 'tell application "System Events" to tell (first process whose frontmost is true) to return {name, bundle identifier}' 2>/dev/null)
    FRONT=$(echo "$INFO_RAW" | cut -d',' -f1 | xargs)
    BUNDLE=$(echo "$INFO_RAW" | cut -d',' -f2 | xargs)

    # --- 3c. Music detection (后台播放器) ---

PLAYERS=("Spotify" "Music" "163MUSIC" "QQMusic")

for PLAYER in "${PLAYERS[@]}"; do

STATE=$(osascript <<EOF 2>/dev/null
tell application "$PLAYER"
    if it is running then
        try
            return player state as string
        end try
    end if
end tell
EOF
)

if [[ "$STATE" == "playing" ]]; then

TITLE=$(osascript <<EOF 2>/dev/null
tell application "$PLAYER"
    try
        return name of current track
    end try
end tell
EOF
)

echo "PLAY|$(get_app_color "$PLAYER" "")|$TITLE|🎵"
return

fi

done

    # --- B. 浏览器流光检测 (增强兼容性版) ---
    BROWSERS=("Google Chrome" "Arc" "Safari" "Microsoft Edge" "FireFox" "Chromium" "Tor")
    for B in "${BROWSERS[@]}"; do
        if [[ "$FRONT" == *"$B"* ]]; then
            case "$B" in
                "Safari"*)
                    TITLE=$(osascript -e "tell application \"$B\" to get name of current tab of front window" 2>/dev/null)
                    URL=$(osascript -e "tell application \"$B\" to get URL of current tab of front window" 2>/dev/null)
                    ;;
                "Microsoft Edge"*)
                    # Edge 特供：使用 window 1 的 active tab 逻辑，兼容性最强
                    TITLE=$(osascript -e "tell application \"Microsoft Edge\" to get title of active tab of window 1" 2>/dev/null)
                    URL=$(osascript -e "tell application \"Microsoft Edge\" to get URL of active tab of window 1" 2>/dev/null)
                    ;;
                *)
                    TITLE=$(osascript -e "tell application \"$B\" to get title of active tab of front window" 2>/dev/null)
                    URL=$(osascript -e "tell application \"$B\" to get URL of active tab of front window" 2>/dev/null)
                    ;;
            esac
            
            # 如果上面没抓到标题，做一个最后的兜底方案
            if [ -z "$TITLE" ] || [ "$TITLE" = "missing value" ]; then
                TITLE=$(osascript -e "tell application \"System Events\" to tell process \"$B\" to get name of window 1" 2>/dev/null)
            fi

            # 1. 特殊流光 (Gemini/iCloud)
            if [[ "$TITLE" == *"Gemini"* || "$TITLE" == *"iCloud"* ]]; then
                echo "GEMINI|$RAINBOW_BREATH_COLOR|Gemini AI|G"; return
            fi

            # 2. 全量站点匹配 (禁止省略)
            if [[ "$TITLE" == *"YouTube"* ]]; then
                echo "WEB|$(get_app_color "YouTube" "$BUNDLE")|$TITLE|📺"; return
            elif [[ "$TITLE" == *"Bilibili"* || "$TITLE" == *"哔哩哔哩"* ]]; then
                echo "WEB|$(get_app_color "Bilibili" "$BUNDLE")|$TITLE|📺"; return
            elif [[ "$TITLE" == *"Netflix"* ]]; then
                echo "WEB|$(get_app_color "Netflix" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"Amazon Prime"* || "$TITLE" == *"Prime Video"* ]]; then
                echo "WEB|$(get_app_color "Amazon Prime" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"Hulu"* ]]; then
                echo "WEB|$(get_app_color "Hulu" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"Disney"* || "$TITLE" == *"Disney+"* ]]; then
                echo "WEB|$(get_app_color "Disney" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"Tencent Video"* || "$TITLE" == *"腾讯视频"* ]]; then
                echo "WEB|$(get_app_color "腾讯视频" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"iQIYI"* || "$TITLE" == *"爱奇艺"* ]]; then
                echo "WEB|$(get_app_color "爱奇艺" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"Youku"* || "$TITLE" == *"优酷"* || "$TITLE" == *"土豆"* ]]; then
                echo "WEB|$(get_app_color "优酷" "$BUNDLE")|$TITLE|🎬"; return
            elif [[ "$TITLE" == *"CCTV"* || "$TITLE" == *"央视"* ]]; then
                echo "WEB|$(get_app_color "央视" "$BUNDLE")|$TITLE|📺"; return
            elif [[ "$TITLE" == *"Pornhub"* ]]; then
                echo "WEB|$(get_app_color "Pornhub" "$BUNDLE")|$TITLE|🔞"; return
            elif [[ "$TITLE" == *"OnlyFans"* ]]; then
                echo "WEB|$(get_app_color "OnlyFans" "$BUNDLE")|$TITLE|🔞"; return
            elif [[ "$TITLE" == *"Xvideos"* ]]; then
                echo "WEB|$(get_app_color "Xvideos" "$BUNDLE")|$TITLE|🔞"; return
            elif [[ "$TITLE" == *"Xhamster"* ]]; then
                echo "WEB|$(get_app_color "Xhamster" "$BUNDLE")|$TITLE|🔞"; return
            elif [[ "$TITLE" == *"Redtube"* ]]; then
                echo "WEB|$(get_app_color "Redtube" "$BUNDLE")|$TITLE|🔞"; return
            elif [[ "$TITLE" == *"Vimeo"* ]]; then
                echo "WEB|$(get_app_color "Vimeo" "$BUNDLE")|$TITLE|📺"; return
            elif [[ "$TITLE" == *"Dailymotion"* ]]; then
                echo "WEB|$(get_app_color "Dailymotion" "$BUNDLE")|$TITLE|📺"; return
            elif [[ "$TITLE" == *"Twitch"* ]]; then
                echo "WEB|$(get_app_color "Twitch" "$BUNDLE")|$TITLE|🎮"; return
            elif [[ "$TITLE" == *"Apple Music"* || "$TITLE" == *"Spotify"* ]]; then
                echo "WEB|$(get_app_color "Music" "$BUNDLE")|$TITLE|🎵"; return
            elif [[ "$TITLE" == *"Facebook"* || "$TITLE" == *"Meta"* ]]; then
                echo "WEB|$(get_app_color "Facebook" "$BUNDLE")|$TITLE|⚡"; return
            elif [[ "$TITLE" == *"Instagram"* ]]; then
                echo "WEB|$(get_app_color "Instagram" "$BUNDLE")|$TITLE|⚡"; return
            elif [[ "$TITLE" == *"Twitter"* || "$TITLE" == *"X"* ]]; then
                echo "WEB|$(get_app_color "Twitter" "$BUNDLE")|$TITLE|⚡"; return
            fi

            # 3. 通用 Web (Apple/Google)
            if [[ "$URL" == *"google."* || "$URL" == *"apple.com"* ]]; then
                echo "WEB|$RAINBOW_BREATH_COLOR|$(echo "$TITLE" | cut -c1-20)|🔍"; return
            fi
            
            # 4. 浏览器聚焦状态
            echo "FOCUS|$(get_app_color "$B" "$BUNDLE")|$TITLE|🌐"; return
        fi
    done

    # 3d. 系统/普通 App 智能 Emoji 映射 (超全增强版)
    if [ -n "$FRONT" ]; then
        local app_emoji="📱" # 默认 fallback
        case "$BUNDLE" in
            # --- 系统工具 ---
            "com.apple.finder")           app_emoji="📂" ;;
            "com.apple.SystemSettings")   app_emoji="⚙️" ;;
            "com.apple.ActivityMonitor")  app_emoji="📈" ;;
            "com.apple.Console")          app_emoji="📜" ;;
            "com.apple.DiskUtility")      app_emoji="💽" ;;
            "com.apple.Terminal"|"com.googlecode.iterm2"|"dev.warp.Warp-Main") app_emoji="💻" ;;
            "com.apple.AppStore")         app_emoji="🛍️" ;;
            "com.apple.ArchiveUtility")   app_emoji="📦" ;;
            
            # --- 核心开发工具 ---
            "com.apple.dt.Xcode")         app_emoji="🛠️" ;;
            "com.sublimetext.4"|"com.sublimetext.3") app_emoji="✍️" ;; 
            "com.microsoft.VSCode")       app_emoji="📝" ;;
            "com.apple.Terminal"|"com.googlecode.iterm2"|"dev.warp.Warp-Main") app_emoji="💻" ;;
            "com.postman.postman")        app_emoji="🚀" ;;
            "com.docker.docker")          app_emoji="🐳" ;;
            "com.apple.ActivityMonitor")  app_emoji="📈" ;;
            "com.apple.Console")          app_emoji="📜" ;;
            
            # --- 生产力与办公 ---
            "com.apple.mail")             app_emoji="✉️" ;;
            "com.apple.Calendar")         app_emoji="📅" ;;
            "com.apple.Reminders")        app_emoji="✅" ;;
            "com.apple.Calculator")       app_emoji="🔢" ;;
            "com.apple.iWork.Pages")      app_emoji="📑" ;;
            "com.apple.iWork.Numbers")    app_emoji="📊" ;;
            "com.apple.iWork.Keynote")    app_emoji="📽️" ;;
            "com.microsoft.Word")         app_emoji="📘" ;;
            "com.microsoft.Excel")        app_emoji="📗" ;;
            "com.microsoft.Powerpoint")   app_emoji="📙" ;;
            
            # --- 设计与媒体 ---
            "com.apple.Photos")           app_emoji="🖼️" ;;
            "com.adobe.Photoshop")        app_emoji="🎨" ;;
            "com.adobe.Illustrator")      app_emoji="🖌️" ;;
            "com.figma.Desktop")          app_emoji="🎨" ;;
            "com.apple.QuickTimePlayerX") app_emoji="🎬" ;;
            "com.apple.iMovieApp")        app_emoji="✂️" ;;
            
            # --- 通讯与社交 (海内外大全) ---
            "com.tencent.xinWeChat"|"com.tencent.WeChat") app_emoji="💬" ;;
            "com.tencent.Wework"|"com.tencent.WWApp")     app_emoji="🏢" ;; # 企业微信 (Work WeChat)
            "com.electron.lark")                          app_emoji="🕊️" ;; # 飞书 (Lark)
            "com.tencent.qq")                             app_emoji="🐧" ;;
            "org.telegram.Desktop"|"messenger.telegram.macosx") app_emoji="✈️" ;;
            "com.apple.MobileSMS")                        app_emoji="💬" ;;
            "com.apple.FaceTime")                         app_emoji="📹" ;;
            "com.iwm.douban")                             app_emoji="👥" ;;
            "com.burbn.instagram"|"com.facebook.Instagram") app_emoji="📸" ;; # Instagram
            "com.facebook.Facebook")                      app_emoji="👥" ;; # Facebook
            "com.facebook.Threads")                       app_emoji="🧵" ;; # Threads
            "com.atebits.Tweetie2"|"com.twitter.twitter-mac") app_emoji="🐦" ;; # Twitter/X
            "com.apple.keychainaccess")                   app_emoji="🔑" ;;

            # --- 实用工具 ---
            "com.apple.Safari")           app_emoji="🌐" ;;
            "com.google.Chrome")          app_emoji="🌐" ;;
            "com.apple.Wallpaper")        app_emoji="🌄" ;;
            "com.apple.Shadowrocket")     app_emoji="🚀" ;;
            "com.docker.docker")          app_emoji="🐳" ;;
        esac

        if [[ "$FRONT" == "Finder" ]]; then app_emoji="📂"; fi

        echo "FOCUS|$(get_app_color "$FRONT" "$BUNDLE")|$FRONT|$app_emoji"; return
    fi

    # 3e. IDLE 状态
    echo "IDLE|$RAINBOW_BREATH_COLOR|"
}

# --- 4. 交互处理 (放在渲染前) ---
# --- 4. 交互处理 (点击药丸弹出 Launchpad) ---
if [ "$1" = "CLICK" ]; then

STATE=$(cat /tmp/sketchybar_island_state)

case "$STATE" in

"GEMINI")
open "https://gemini.google.com"
;;

"PLAY")
osascript -e 'tell application "Spotify" to playpause'
;;

"FOCUS")
open -a "Launchpad"
;;

*)
open -a "Launchpad"
;;

esac

exit 0
fi

# --- 5. 最终渲染 ---
STATE_FILE="/tmp/sketchybar_island_state"

# 初始化状态文件
if [ ! -f "$STATE_FILE" ]; then
    echo "INIT" > "$STATE_FILE"
fi

LAST_STATE=$(cat "$STATE_FILE")
DATA=$(get_info)
IFS='|' read -r STATUS COLOR TITLE ICON <<< "$DATA"

FINAL_COLOR="$COLOR"

# --- 修正后的渲染参数 ---
COMMON_ARGS=(
    --set island
    background.drawing=on
    background.border_width=4
    background.corner_radius=17
    background.border_color="$FINAL_COLOR"
    background.border_angle="$ANGLE"
    background.layer=overlay    # 必须是 overlay，否则会被窗口遮挡
    icon.drawing=on
    click_script="$HOME/.config/sketchybar/plugins/island.sh CLICK" # 换成 $HOME
    click_through=off
)

NEW_STATE="${STATUS}_${TITLE}"

# 只有状态变化才修改宽度
if [[ "$NEW_STATE" != "$LAST_STATE" ]]; then

    if [[ $STATUS == "PLAY" || $STATUS == "GEMINI" || $STATUS == "WEB" || $STATUS == "FOCUS" || $STATUS == "NOTIF" ]]; then

        sketchybar --animate tanh 20 "${COMMON_ARGS[@]}" \
            width=dynamic \
            min_width=160 \
            icon="$ICON" \
            icon.padding_left=15 \
            label="$(echo "$TITLE" | cut -c1-28)" \
            label.max_chars=28 \
            label.padding_left=10 \
            label.padding_right=20 \
            label.drawing=on

    else

        sketchybar --animate tanh 20 "${COMMON_ARGS[@]}" \
            width=dynamic \
            min_width=160 \
            icon="" \
            icon.padding_left=20 \
            icon.padding_right=20 \
            label="" \
            label.drawing=off
    fi

    echo "$NEW_STATE" > "$STATE_FILE"

else
    # 状态没变 → 只更新颜色和角度
    sketchybar --set island \
        background.border_color="$FINAL_COLOR" \
        background.border_angle="$ANGLE"
fi

if [ "$1" = "IPHONE" ]; then
    osascript -e 'tell application "Shortcuts" to run shortcut "NotchKit Control"'
    exit 0
fi
