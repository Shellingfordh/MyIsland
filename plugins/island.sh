#!/bin/bash
# 增加路径定义，防止 osascript 找不到环境
SCRIPT_PATH=$(realpath "$0")
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# User overrides
USER_CONFIG="$HOME/.config/sketchybar/userconfig.sh"
if [ -f "$USER_CONFIG" ]; then
    # shellcheck disable=SC1090
    source "$USER_CONFIG"
fi

# --- 0. 环境与变量初始化 ---
MODEL_NAME=$(sysctl -n hw.model)
ARCH=$(uname -m)
STATE_FILE="/tmp/sketchybar_island_state"
AUTH_FLAG="/tmp/sketchybar_island_auth_done"

# 核心：通过检测内置显示器属性判断是否有“物理刘海” (Notch)
HAS_NOTCH=$(ioreg -n AppleType6Display | grep -i "is-built-in" | grep -i "display-subsystem-id" | wc -l)

# 智能探测：改为正则匹配
CHECK_TOP_OCCUPIED=$(osascript -e 'tell application "System Events" to return exists (first process whose (name matches "(?i).*notch.*|.*island.*|.*dynamic.*|.*nook.*|.*land.*"))' 2>/dev/null)

# --- 0.1 Locale (UI language) ---
APPLE_LANG=$(plutil -extract AppleLanguages.0 raw -o - "$HOME/Library/Preferences/.GlobalPreferences.plist" 2>/dev/null)
APPLE_LOCALE=$(plutil -extract AppleLocale raw -o - "$HOME/Library/Preferences/.GlobalPreferences.plist" 2>/dev/null)
if [ -z "$APPLE_LANG" ]; then
    APPLE_LANG=$(defaults read -g AppleLanguages 2>/dev/null | tr -d '",()' | awk 'NF{print $1; exit}')
fi
if [ -z "$APPLE_LOCALE" ]; then
    APPLE_LOCALE=$(defaults read -g AppleLocale 2>/dev/null | tr -d '",()')
fi
LANG_IS_ZH=0
if [ "${USER_LANG:-}" = "en" ]; then
    LANG_IS_ZH=0
elif [ "${USER_LANG:-}" = "zh" ]; then
    LANG_IS_ZH=1
else
    case "${APPLE_LANG:-${LANG:-}}" in
      zh* ) LANG_IS_ZH=1 ;;
      * )
        case "${APPLE_LOCALE:-}" in
          zh* ) LANG_IS_ZH=1 ;;
        esac
      ;;
    esac
fi

loc() {
    # loc "en" "zh"
    if [ "$LANG_IS_ZH" -eq 1 ]; then
        echo "$2"
    else
        echo "$1"
    fi
}

STR_INIT_TITLE=$(loc "Island" "药丸")
STR_INIT_SUB=$(loc "Permissions & Matrix Checked" "权限与矩阵检查完成")
STR_SIRI=$(loc "Siri" "Siri")
STR_NOW_PLAYING=$(loc "Now Playing" "正在播放")
STR_LAUNCHPAD=$(loc "All Apps" "全部应用")
STR_NOTIFICATION_CENTER=$(loc "Notification Center" "通知中心")
STR_VOLUME=$(loc "Volume" "音量")
STR_BRIGHTNESS=$(loc "Brightness" "亮度")
STR_MUTED=$(loc "Muted" "已静音")
STR_UNMUTED=$(loc "Unmuted" "已取消静音")
STR_BRIGHTNESS_UP=$(loc "Brightness +" "亮度 +")
STR_BRIGHTNESS_DOWN=$(loc "Brightness -" "亮度 -")
STR_AGENT_SET=$(loc "Agent set to" "已设置代理")
STR_OPENAI_KEY_MISSING=$(loc "OpenAI API key missing" "OpenAI API Key 缺失")
STR_IRONCLAW_NOT_FOUND=$(loc "Ironclaw not found" "Ironclaw 未找到")
STR_GLM_NOT_FOUND=$(loc "GLM not found" "GLM 未找到")
STR_PROMPT_IRONCLAW=$(loc "Ironclaw prompt" "Ironclaw 输入")
STR_PROMPT_OPENAI=$(loc "OpenAI prompt" "OpenAI 输入")
STR_PROMPT_GLM=$(loc "GLM prompt" "GLM 输入")
STR_PROMPT_CUSTOM=$(loc "Custom prompt" "自定义输入")

STR_SETTINGS_TITLE=$(loc "Island Agent" "药丸代理")
STR_SETTINGS_PROMPT=$(loc "Select default agent" "选择默认代理")
STR_SETTINGS_OPENAI_MODEL=$(loc "OpenAI model" "OpenAI 模型")
STR_SETTINGS_CUSTOM_CMD=$(loc "Custom agent command" "自定义代理命令")
STR_CUSTOM_CMD_MISSING=$(loc "Custom command missing" "自定义命令缺失")

# --- 0.2 Agent config ---
AGENT_CONF="$HOME/.config/sketchybar/agent.conf"
AGENT_PROVIDER="siri"
OPENAI_MODEL="gpt-4o"
OPENAI_BASE_URL="https://api.openai.com/v1"
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
IRONCLAW_ARGS=""
CUSTOM_COMMAND=""

if [ -f "$AGENT_CONF" ]; then
    # shellcheck disable=SC1090
    source "$AGENT_CONF"
fi

# --- 1. Positioning (driven by sketchybarrc) ---
ISLAND_BG_HEIGHT=${ISLAND_BG_HEIGHT:-38}
CORNER_RADIUS=${CORNER_RADIUS:-18}
ISLAND_Y_OFFSET=${ISLAND_Y_OFFSET:-0}
ICON_Y_FINAL=${ICON_Y_FINAL:-0}
LABEL_Y_FINAL=${LABEL_Y_FINAL:-0}

# --- 2. 权限诱导与初始化通知 ---
# 只在第一次运行或重启时执行，确保 System Events 权限就绪
if [ ! -f "$AUTH_FLAG" ]; then
    # 触发一次 System Events 调用，强制弹出系统权限请求（如果尚未授权）
    osascript -e 'tell application "System Events" to get name of first process' >/dev/null 2>&1
    osascript -e "display notification \"Sketchybar Island Initialized\" with title \"$STR_INIT_TITLE\" subtitle \"$STR_INIT_SUB\""
    touch "$AUTH_FLAG"
fi

# --- 2.1 交互控制与缓存 ---
CONTROL_CACHE="/tmp/sketchybar_island_ctrl"
VOLUME_CACHE="/tmp/sketchybar_island_volume"
BRIGHTNESS_CACHE="/tmp/sketchybar_island_brightness"
STATE_CACHE="/tmp/sketchybar_island_state_v2"
GLASS_FLAG="/tmp/sketchybar_glass_on"

set_control_cache() {
    local msg="$1"
    local icon="$2"
    echo "$(date +%s)|$msg|$icon" > "$CONTROL_CACHE"
}

get_control_cache() {
    if [ -f "$CONTROL_CACHE" ]; then
        local data
        data=$(cat "$CONTROL_CACHE")
        local ts msg icon
        ts=$(echo "$data" | cut -d'|' -f1)
        msg=$(echo "$data" | cut -d'|' -f2)
        icon=$(echo "$data" | cut -d'|' -f3)
        if [ $(( $(date +%s) - ts )) -lt 2 ]; then
            echo "CTRL|$RAINBOW_BREATH_COLOR|$msg|$icon"; return
        fi
        rm -f "$CONTROL_CACHE"
    fi
    echo ""
}

set_control_cache_now() {
    local msg="$1"
    local icon="$2"
    echo "$(date +%s)|$msg|$icon" > "$CONTROL_CACHE"
}

state_priority() {
    case "$1" in
        CTRL) echo 100 ;;
        NOTIF) echo 80 ;;
        PLAY) echo 70 ;;
        FOCUS) echo 50 ;;
        IDLE) echo 10 ;;
        *) echo 0 ;;
    esac
}

should_switch_state() {
    local next="$1"
    local now
    now=$(date +%s)

    if [ ! -f "$STATE_CACHE" ]; then
        echo "$next|$now" > "$STATE_CACHE"
        return 0
    fi

    local last ts
    last=$(cut -d'|' -f1 "$STATE_CACHE")
    ts=$(cut -d'|' -f2 "$STATE_CACHE")
    ts=${ts:-0}

    local p_last p_next
    p_last=$(state_priority "$last")
    p_next=$(state_priority "$next")

    if [ "$p_next" -gt "$p_last" ]; then
        echo "$next|$now" > "$STATE_CACHE"
        return 0
    fi

    if [ $((now - ts)) -ge 1 ]; then
        echo "$next|$now" > "$STATE_CACHE"
        return 0
    fi

    return 1
}

clamp() {
    local v=$1 min=$2 max=$3
    [ "$v" -lt "$min" ] && v=$min
    [ "$v" -gt "$max" ] && v=$max
    echo "$v"
}

adjust_volume() {
    local delta=$1
    local cur new
    cur=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
    cur=${cur:-0}
    new=$((cur + delta))
    new=$(clamp "$new" 0 100)
    osascript -e "set volume output volume $new" >/dev/null 2>&1
    set_control_cache "$STR_VOLUME ${new}%" "🔊"
    echo "$new" > "$VOLUME_CACHE"
}

adjust_brightness() {
    local delta=$1
    if command -v brightness >/dev/null 2>&1; then
        local cur new
        cur=$(brightness -l | awk '/brightness/ {print $4}' | head -n1)
        cur=${cur:-0.7}
        new=$(perl -e '$c=shift;$d=shift;$n=$c+$d; $n=1 if $n>1; $n=0.1 if $n<0.1; printf "%.2f", $n' "$cur" "$delta")
        brightness "$new" >/dev/null 2>&1
        set_control_cache "$STR_BRIGHTNESS $(perl -e 'printf "%d", (shift*100)' "$new")%" "🔆"
        perl -e 'printf "%d", (shift*100)' "$new" > "$BRIGHTNESS_CACHE"
    else
        if [ "$delta" = "0.05" ]; then
            osascript -e 'tell application "System Events" to key code 145' >/dev/null 2>&1
            set_control_cache "$STR_BRIGHTNESS_UP" "🔆"
        else
            osascript -e 'tell application "System Events" to key code 144' >/dev/null 2>&1
            set_control_cache "$STR_BRIGHTNESS_DOWN" "🔅"
        fi
    fi
}

poll_system_controls() {
    local cur_vol cur_bri last_vol last_bri
    cur_vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
    cur_vol=${cur_vol:-0}
    last_vol=$(cat "$VOLUME_CACHE" 2>/dev/null || echo "")
    if [ -n "$last_vol" ] && [ "$cur_vol" != "$last_vol" ]; then
        set_control_cache "$STR_VOLUME ${cur_vol}%" "🔊"
    fi
    echo "$cur_vol" > "$VOLUME_CACHE"

    if command -v brightness >/dev/null 2>&1; then
        cur_bri=$(brightness -l | awk '/brightness/ {print $4}' | head -n1)
        cur_bri=${cur_bri:-0.7}
        cur_bri=$(perl -e 'printf "%d", (shift*100)' "$cur_bri")
        last_bri=$(cat "$BRIGHTNESS_CACHE" 2>/dev/null || echo "")
        if [ -n "$last_bri" ] && [ "$cur_bri" != "$last_bri" ]; then
            set_control_cache "$STR_BRIGHTNESS ${cur_bri}%" "🔆"
        fi
        echo "$cur_bri" > "$BRIGHTNESS_CACHE"
    fi
}

now_ms() {
    perl -MTime::HiRes=time -e 'printf "%d", time()*1000'
}

prompt_user() {
    local prompt_title="$1"
    osascript -e "text returned of (display dialog "'"$prompt_title"'" default answer "")" 2>/dev/null
}

open_app_quick_switch() {
    local app_name
    app_name=$(prompt_user "Quick Switch App Name")
    [ -z "$app_name" ] && return
    open -a "$app_name" >/dev/null 2>&1
    set_control_cache "$app_name" "🚀"
}

show_audio_panel() {
    local vol muted
    vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
    muted=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)
    vol=${vol:-0}
    if [ "$muted" = "true" ]; then
        set_control_cache "$STR_VOLUME ${vol}% ($STR_MUTED)" "🔇"
    else
        set_control_cache "$STR_VOLUME ${vol}%" "🔊"
    fi
}

toggle_mute() {
    local muted
    muted=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)
    if [ "$muted" = "true" ]; then
        osascript -e 'set volume without output muted' >/dev/null 2>&1
        set_control_cache "$STR_VOLUME $STR_UNMUTED" "🔊"
    else
        osascript -e 'set volume with output muted' >/dev/null 2>&1
        set_control_cache "$STR_VOLUME $STR_MUTED" "🔇"
    fi
}

toggle_glass() {
    if [ -f "$GLASS_FLAG" ]; then
        rm -f "$GLASS_FLAG"
        sketchybar --set glass drawing=off
    else
        touch "$GLASS_FLAG"
        sketchybar --set glass drawing=on
    fi
}

open_settings() {
    local choice
    choice=$(osascript -e "choose from list {\"Siri\",\"Ironclaw\",\"OpenAI\",\"GLM\",\"Custom\",\"Quick Switch\",\"Audio Panel\",\"Toggle Mute\",\"Toggle Glass\"} with title \"$STR_SETTINGS_TITLE\" with prompt \"$STR_SETTINGS_PROMPT\"" 2>/dev/null | tr -d '\r')
    [ -z "$choice" ] && return
    [ "$choice" = "false" ] && return

    local model="$OPENAI_MODEL"
    local custom_cmd=""

    if [ "$choice" = "OpenAI" ]; then
        model=$(osascript -e "text returned of (display dialog \"$STR_SETTINGS_OPENAI_MODEL\" default answer \"gpt-4o\")" 2>/dev/null | tr -d '\r')
        [ -z "$model" ] && model="$OPENAI_MODEL"
    fi

    if [ "$choice" = "Custom" ]; then
        custom_cmd=$(osascript -e "text returned of (display dialog \"$STR_SETTINGS_CUSTOM_CMD\" default answer \"\")" 2>/dev/null | tr -d '\r')
    fi

    if [ "$choice" = "Quick Switch" ]; then
        open_app_quick_switch
        return
    fi

    if [ "$choice" = "Audio Panel" ]; then
        show_audio_panel
        return
    fi

    if [ "$choice" = "Toggle Mute" ]; then
        toggle_mute
        return
    fi

    if [ "$choice" = "Toggle Glass" ]; then
        toggle_glass
        return
    fi

    local provider
    provider=$(echo "$choice" | tr "A-Z" "a-z")

    cat > "$AGENT_CONF" <<EOF
AGENT_PROVIDER="$provider"
OPENAI_MODEL="$model"
OPENAI_BASE_URL="$OPENAI_BASE_URL"
CUSTOM_COMMAND="$custom_cmd"
# Set OPENAI_API_KEY in your shell env or add it here if you want it persisted
EOF

    set_control_cache "$STR_AGENT_SET $choice" "⚙️"
}

openai_request() {
    local prompt="$1"
    if [ -z "$OPENAI_API_KEY" ]; then
        set_control_cache "$STR_OPENAI_KEY_MISSING" "⚠️"
        return
    fi
    local payload
    payload=$(python3 - <<'PY2'
import json,sys
model=sys.argv[1]
prompt=sys.argv[2]
print(json.dumps({"model": model, "messages":[{"role":"user","content":prompt}]}))
PY2
"$OPENAI_MODEL" "$prompt")

    local resp
    resp=$(curl -s "$OPENAI_BASE_URL/chat/completions"       -H "Authorization: Bearer $OPENAI_API_KEY"       -H "Content-Type: application/json"       -d "$payload")

    local answer
    answer=$(python3 - <<'PY2'
import json,sys
try:
    data=json.load(sys.stdin)
    msg=data["choices"][0]["message"]["content"]
    print(msg.strip())
except Exception:
    print("OpenAI error")
PY2
<<< "$resp")

    osascript -e 'display notification "'"$answer"'" with title "OpenAI"' >/dev/null 2>&1
    set_control_cache "OpenAI" "✨"
}

ironclaw_request() {
    local prompt="$1"
    if ! command -v ironclaw >/dev/null 2>&1; then
        set_control_cache "$STR_IRONCLAW_NOT_FOUND" "⚠️"
        return
    fi
    ironclaw -m "$prompt" --cli-only --no-onboard $IRONCLAW_ARGS >/dev/null 2>&1 &
    set_control_cache "Ironclaw" "🧠"
}
custom_request() {
    local prompt="$1"
    if [ -z "$CUSTOM_COMMAND" ]; then
        set_control_cache "$STR_CUSTOM_CMD_MISSING" "⚠️"
        return
    fi
    if echo "$CUSTOM_COMMAND" | grep -q "{prompt}"; then
        cmd=${CUSTOM_COMMAND//\{prompt\}/"$prompt"}
    else
        cmd="$CUSTOM_COMMAND $prompt"
    fi
    eval "$cmd" >/dev/null 2>&1 &
    set_control_cache "Custom" "⚙️"
}


glm_request() {
    local prompt="$1"
    if ! command -v glm >/dev/null 2>&1; then
        set_control_cache "$STR_GLM_NOT_FOUND" "⚠️"
        return
    fi
    glm "$prompt" >/dev/null 2>&1 &
    set_control_cache "GLM" "🧪"
}

dispatch_agent() {
    local prompt
    case "$AGENT_PROVIDER" in
        siri)
            open -a "Siri" >/dev/null 2>&1
            set_control_cache "$STR_SIRI" "🌀"
            ;;
        ironclaw)
            prompt=$(prompt_user "$STR_PROMPT_IRONCLAW")
            [ -z "$prompt" ] && return
            ironclaw_request "$prompt"
            ;;
        openai)
            prompt=$(prompt_user "$STR_PROMPT_OPENAI")
            [ -z "$prompt" ] && return
            openai_request "$prompt"
            ;;
        glm)
            prompt=$(prompt_user "$STR_PROMPT_GLM")
            [ -z "$prompt" ] && return
            glm_request "$prompt"
            ;;
        custom)
            prompt=$(prompt_user "$STR_PROMPT_CUSTOM")
            [ -z "$prompt" ] && return
            custom_request "$prompt"
            ;;
        *)
            open -a "Siri" >/dev/null 2>&1
            set_control_cache "$STR_SIRI" "🌀"
            ;;
    esac
}

handle_single_click() {
    dispatch_agent
}

handle_double_click() {
    open -a "Launchpad" >/dev/null 2>&1
    set_control_cache "$STR_LAUNCHPAD" "🗂️"
}

CLICK_FILE="/tmp/sketchybar_island_click"
DOUBLE_CLICK_MS=500

# Fallback for click_script: do nothing to avoid accidental single-click triggers
if [ "$1" = "CLICK" ]; then
    exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
    # Right click opens settings UI
    if [ "$BUTTON" = "right" ] || [ "$BUTTON" = "2" ] || [ "$BUTTON" = "3" ] || [ "$BUTTON" = "secondary" ]; then
        open_settings
        exit 0
    fi

    # If sketchybar provides click count, honor it
    click_count="${CLICK_COUNT:-${CLICKED:-${COUNT:-}}}"
    if [ -n "$click_count" ] && [ "$click_count" -ge 2 ]; then
        rm -f "$CLICK_FILE"
        handle_double_click
        exit 0
    fi

    now=$(now_ms)
    if [ -f "$CLICK_FILE" ]; then
        last=$(cat "$CLICK_FILE")
        if [ $((now - last)) -le $DOUBLE_CLICK_MS ]; then
            rm -f "$CLICK_FILE"
            handle_double_click
            exit 0
        fi
    fi

    echo "$now" > "$CLICK_FILE"
    ( sleep 0.5; if [ -f "$CLICK_FILE" ] && [ "$(cat "$CLICK_FILE")" = "$now" ]; then rm -f "$CLICK_FILE"; handle_single_click; fi ) &
    exit 0
fi
if [ "$SENDER" = "mouse.scrolled" ]; then
    delta=${SCROLL_DELTA:-0}
    if echo "$MODIFIER" | grep -qi "shift"; then
        if [ "$delta" -gt 0 ]; then
            adjust_brightness "0.05"
        else
            adjust_brightness "-0.05"
        fi
    else
        if [ "$delta" -gt 0 ]; then
            adjust_volume 6
        else
            adjust_volume -6
        fi
    fi
fi

# SketchyBar native events (volume/brightness)
if [ "$SENDER" = "volume_change" ]; then
    vol="${INFO:-}"
    if [ -z "$vol" ]; then
        vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
    fi
    vol=${vol:-0}
    set_control_cache_now "$STR_VOLUME ${vol}%" "🔊"
    echo "$vol" > "$VOLUME_CACHE"
    sketchybar --trigger island_update
    exit 0
fi

if [ "$SENDER" = "brightness_change" ]; then
    bri="${INFO:-}"
    if [ -z "$bri" ]; then
        if command -v brightness >/dev/null 2>&1; then
            bri=$(brightness -l | awk '/brightness/ {print $4}' | head -n1)
            bri=${bri:-0.7}
            bri=$(perl -e 'printf "%d", (shift*100)' "$bri")
        else
            bri=50
        fi
    fi
    set_control_cache_now "$STR_BRIGHTNESS ${bri}%" "🔆"
    echo "$bri" > "$BRIGHTNESS_CACHE"
    sketchybar --trigger island_update
    exit 0
fi

poll_system_controls

# --- 1. 基础计算：流光引擎核心 ---
TIME=$(date +%s)
BREATH=$(awk "BEGIN { s = sin($TIME * 1.5); print (s + 1) / 2 }")
ALPHA_VAL=$(printf "%02x" $(awk "BEGIN {printf \"%d\", 204 + ($BREATH * 51)}"))

# 24位精细色库
RAINBOW=("f87171" "fb7185" "f43f5e" "fb923c" "f97316" "ea580c" "facc15" "eab308" "ca8a04" "4ade80" "22c55e" "16a34a" "2dd4bf" "06b6d4" "0891b2" "38bdf8" "0ea5e9" "0284c7" "818cf8" "6366f1" "4f46e5" "c084fc" "a855f7" "9333ea")
# --- 核心索引计算：确保它是整数！ ---
idx_int=$(( (TIME) / 2 ))
i1=$(( idx_int % 24 ))
i2=$(( (idx_int + 1) % 24 ))
i3=$(( (idx_int + 2) % 24 ))
i4=$(( (idx_int + 3) % 24 ))

c1_raw="0x${ALPHA_VAL}${RAINBOW[$i1]}"
c2_raw="0x${ALPHA_VAL}${RAINBOW[$i2]}"
c3_raw="0x${ALPHA_VAL}${RAINBOW[$i3]}"
c4_raw="0x${ALPHA_VAL}${RAINBOW[$i4]}"

# 形成：c1-c2-c3-c4-c3-c2-c1 的极窄色系流动
RAINBOW_BREATH_COLOR="$c1_raw:$c2_raw:$c3_raw:$c4_raw:$c3_raw:$c2_raw:$c1_raw"
# 根据十六进制色值找最接近的色库索引 (普适性转换)
# --- 修正索引定位：让它更精准地找到色库中的位置 ---
find_nearest_idx() {
    local target=$1
    # 提取 RGB 的前两位进行估算
    local r_hex=${target:0:2}
    local g_hex=${target:2:2}
    local b_hex=${target:4:2}
    local r=$((16#$r_hex))
    local g=$((16#$g_hex))
    local b=$((16#$b_hex))

    # 简易色相映射：将 App 颜色归类到 24 位色库的索引
    if [ $r -gt $g ] && [ $r -gt $b ]; then echo 2;    # 红色系 (索引 2)
    elif [ $r -gt $g ] && [ $b -gt $g ]; then echo 22; # 紫/粉系 (索引 22)
    elif [ $g -gt $r ] && [ $g -gt $b ]; then echo 11; # 绿色系 (索引 11)
    elif [ $g -gt $r ] && [ $b -gt $r ]; then echo 14; # 青/蓝系 (索引 14)
    elif [ $b -gt $r ] && [ $b -gt $g ]; then echo 17; # 蓝色系 (索引 17)
    else echo 18; fi
}

# --- 1. 真·流光追逐引擎 (CACB 苹果流体版：三色独立，C 位主宰) ---
generate_stream() {
    local hex=$1
    local center_idx=$(find_nearest_idx "$hex")
    
    # 1. 关键：将采样步长拉开到 5 和 8，确保 A/B/C 三个索引完全处于色轮的不同象限
    # 这样能从物理上保证三个色系绝不混淆
    local i_a=$(( (center_idx - 5 + 24) % 24 )) 
    local i_c=$(( center_idx % 24 ))             
    local i_b=$(( (center_idx + 8 + 24) % 24 )) 
    
    # 2. 颜色提取：引入微弱的明度差，增强三色独立性
    # 即使在同一个色环，由于 alpha 的细微波动，视觉上也会形成三层流光
    local c_a="0x${ALPHA_VAL}${RAINBOW[$i_a]}"
    local c_c="0x${ALPHA_VAL}${RAINBOW[$i_c]}"
    local c_b="0x${ALPHA_VAL}${RAINBOW[$i_b]}"
    
    # 3. 构造 9 点“流体传送带” (CACB 轮转)
    # 通过 1:1 的 C 间隔，强制让 A 和 B 变成掠过的细丝
    # 结构：C - A - C - B - C - A - C - B - C
    local base_stream="$c_c:$c_a:$c_c:$c_b:$c_c:$c_a:$c_c:$c_b:$c_c"
    
    # 4. 物理位移：通过 date 产生的偏移量，在 9 个点中进行切片采样
    # 这样做颜色是“滚”起来的，而不是“跳”起来的
    local offset=$(( $(date +%s) % 5 ))
    
    case $offset in
        # 每一帧都保证 C 占据 3 个槽位（首、中、尾），AB 各占 1 个，实现 C 位最高频
        0) echo "$c_c:$c_a:$c_c:$c_b:$c_c" ;; # 经典 CACB
        1) echo "$c_a:$c_c:$c_b:$c_c:$c_a" ;; # 序列滚动
        2) echo "$c_c:$c_b:$c_c:$c_a:$c_c" ;; # 轴心偏移
        3) echo "$c_b:$c_c:$c_a:$c_c:$c_b" ;; # 镜像回归
        4) echo "$c_c:$c_a:$c_c:$c_b:$c_c" ;; # 回到起始
    esac
}

# --- 2. 颜色提取函数 (流光溢彩修正版) ---
get_app_color() {
    local app_name="$1"
    local bundle_id="$2"
    local base_color="818cf8" 

    if [[ "$bundle_id" == com.apple.* ]]; then
        # 系统应用直接返回全局彩虹流
        echo "$RAINBOW_BREATH_COLOR"
        return
    else
        case "$app_name" in
    "Spotify")           base_color="1db954" ;;
    "WeChat"|"微信")      base_color="07c160" ;;
    "Bilibili"|"哔哩哔哩") base_color="00a1d6" ;;
    "YouTube")           base_color="ff0000" ;;
    "Telegram")          base_color="0088cc" ;;
    "Douban"|"豆瓣")      base_color="0076d6" ;;
    "Kuaishou"|"快手")    base_color="ff5a00" ;;
    "TikTok"|"抖音")      base_color="69c9d0" ;;
    "Netease"|"网易云音乐") base_color="c20c0c" ;;
    "WhatsApp")          base_color="25d366" ;;
    "Facebook")          base_color="1877f2" ;;
    "Twitter"|"X")       base_color="1da1f2" ;;
    "Instagram")         base_color="f58529" ;;
    "LinkedIn")          base_color="0a66c2" ;;
    "Snapchat")          base_color="fffc00" ;;
    "Netflix")           base_color="ff0000" ;;
    "Amazon Prime")      base_color="00a8e1" ;;
    "Hulu")              base_color="1ce783" ;;
    "Disney"|"Disney+")   base_color="113ccf" ;;
    "腾讯视频"|"Tencent Video") base_color="27b3ff" ;;
    "爱奇艺"|"iQIYI")     base_color="00c63f" ;;
    "优酷"|"Youku"|"土豆") base_color="0072e3" ;;
    "央视"|"CCTV")        base_color="e30613" ;;
    "Pornhub")           base_color="ff9900" ;;
    "OnlyFans")          base_color="00b0f0" ;;
    "Xvideos")           base_color="ff0000" ;;
    "Xhamster")          base_color="ff6600" ;;
    "Redtube")           base_color="ff0000" ;;
    "Vimeo")             base_color="1ab7ea" ;;
    "Dailymotion")       base_color="0066cc" ;;
    "Twitch")            base_color="6441a5" ;;
    *) base_color="818cf8" ;;
    esac
    fi

    # --- 逻辑 B：严格窄色域追逐 ---
# --- 逻辑 B：直接调用增强型流光生成器 ---
    generate_stream "$base_color"
}
# 预生成的 IDLE/Gemini 专用色流 (不再是全色域七彩)
IDLE_STREAM=$(generate_stream "818cf8")
GEMINI_STREAM=$(generate_stream "c084fc")

# --- 3. 核心逻辑判断 (极速优化版) ---
get_info() {
    # 0. 控制态优先（音量/亮度/Siri/通知中心）
    local ctrl
    ctrl=$(get_control_cache)
    if [ -n "$ctrl" ]; then
        if should_switch_state "CTRL"; then
            echo "$ctrl"
        fi
        return
    fi
    # 0.5 全局播放检测（不依赖前台）
    local play_state title artist
    play_state=$(osascript -e 'tell application "Spotify" to if it is running then player state as string else "stopped"' 2>/dev/null)
    if [ "$play_state" = "playing" ]; then
        title=$(osascript -e 'tell application "Spotify" to name of current track' 2>/dev/null)
        artist=$(osascript -e 'tell application "Spotify" to artist of current track' 2>/dev/null)
        if should_switch_state "PLAY"; then
            echo "PLAY|$(get_app_color "Spotify" "com.spotify.client")|$STR_NOW_PLAYING · ${title} — ${artist}|🎵"; return
        fi
    fi
    play_state=$(osascript -e 'tell application "Music" to if it is running then player state as string else "stopped"' 2>/dev/null)
    if [ "$play_state" = "playing" ]; then
        title=$(osascript -e 'tell application "Music" to name of current track' 2>/dev/null)
        artist=$(osascript -e 'tell application "Music" to artist of current track' 2>/dev/null)
        if should_switch_state "PLAY"; then
            echo "PLAY|$(get_app_color "Music" "com.apple.Music")|$STR_NOW_PLAYING · ${title} — ${artist}|🎵"; return
        fi
    fi
    # 强力初始化：如果是初次运行或 update 触发，确保不卡 Loading
    if [[ "$SENDER" == "island_update" || "$SENDER" == "forced" ]]; then
        echo "IDLE|$RAINBOW_BREATH_COLOR||"
        return
    fi
    # ... 原有的通知检测逻辑 ...
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
            if should_switch_state "NOTIF"; then
                echo "NOTIF|0xffffffff:0xff888888|$NOTIF_MSG|🔔"; return
            fi
        fi
        rm "$NOTIF_CACHE"
    fi
# 3b. 增强保护：如果 System Events 没响应，直接返回 Finder 状态而不报错退出
    INFO_RAW=$(osascript -e 'set t to 0.4
    try
        with timeout of t seconds
            tell application "System Events"
                set frontApp to first process whose frontmost is true
                return {name of frontApp, bundle identifier of frontApp}
            end tell
        end timeout
    on error
        return "Finder,com.apple.finder"
    end try' 2>/dev/null)

   # 兜底：如果 INFO_RAW 还是空的
    if [ -z "$INFO_RAW" ]; then
        echo "IDLE|$RAINBOW_BREATH_COLOR||"; return
    fi

    # 正常解析
    FRONT=$(echo "$INFO_RAW" | awk -F', ' '{print $1}')
    BUNDLE=$(echo "$INFO_RAW" | awk -F', ' '{print $2}')

    # 3c. 播放器检测 (只查询当前前台进程，不再轮询列表)
    PLAYERS_BUNDLES="com.spotify.client|com.apple.Music|com.netease.163music|com.tencent.QQMusic"
    if [[ "$PLAYERS_BUNDLES" == *"$BUNDLE"* ]]; then
        STATE=$(osascript -e "tell application \"$FRONT\" to player state as string" 2>/dev/null)
        if [ "$STATE" = "playing" ]; then
            TITLE=$(osascript -e "tell application \"$FRONT\" to name of current track" 2>/dev/null)
            if should_switch_state "PLAY"; then
                echo "PLAY|$(get_app_color "$FRONT" "$BUNDLE")|$STR_NOW_PLAYING · $TITLE|🎵"; return
            fi
        fi
    fi

# --- B. 浏览器流光检测 (高性能修正版) ---
    if [[ "$FRONT" =~ ^(Google\ Chrome|Arc|Safari|Microsoft\ Edge|FireFox)$ ]]; then
        local browser_data=""
        if [[ "$FRONT" == "Safari" ]]; then
            browser_data=$(osascript -e 'tell application "Safari" to tell front window to get {name of current tab, URL of current tab}' 2>/dev/null)
        else
            # 适用于 Chromium 系浏览器 (Chrome, Edge, Arc)
            browser_data=$(osascript -e "tell application \"$FRONT\" to tell front window to get {title of active tab, URL of active tab}" 2>/dev/null)
        fi

        # 处理返回的数据
        TITLE=$(echo "$browser_data" | cut -d',' -f1 | sed 's/^ //')
        URL=$(echo "$browser_data" | cut -d',' -f2 | sed 's/^ //')

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
            if should_switch_state "FOCUS"; then
                echo "FOCUS|$(get_app_color "$FRONT" "$BUNDLE")|$TITLE|🌐"; return
            fi
        fi # 这一行是闭合上面的 if [[ "$FRONT" =~ ...

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

        if should_switch_state "FOCUS"; then
            echo "FOCUS|$(get_app_color "$FRONT" "$BUNDLE")|$FRONT|$app_emoji"; return
        fi
    fi

    # 3e. IDLE 状态
    if should_switch_state "IDLE"; then
        echo "IDLE|$RAINBOW_BREATH_COLOR|"
    fi
}


# --- 4. 交互处理 (已在上方统一处理) ---

# --- 5. 最终渲染 (全量属性强制推送版 - 暴力置顶修正) ---
STATE_FILE="/tmp/sketchybar_island_state"
[ ! -f "$STATE_FILE" ] && echo "INIT" > "$STATE_FILE"

LAST_STATE=$(cat "$STATE_FILE")
DATA=$(get_info)
IFS='|' read -r STATUS COLOR TITLE ICON <<< "$DATA"

# 提取主色
MAIN_COLOR=$(echo "$COLOR" | cut -d: -f1)

# 计算实时位移（已在矩阵中完成）

CURRENT_SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd)/$(basename "$0")"

# 统一定义参数数组 
# 放弃 display=all (防止消失)，改用 topmost=window (强制穿透全屏)
COMMON_ARGS=(
    width=dynamic
    drawing=on
    sticky=on
    z_index=999
    background.drawing=on
    background.height=$ISLAND_BG_HEIGHT
    background.border_width=4
    background.corner_radius=$CORNER_RADIUS
    background.color=0xff000000
    background.border_color="$COLOR" 
    background.y_offset=$ISLAND_Y_OFFSET
    icon.y_offset=$((ISLAND_Y_OFFSET + ICON_Y_FINAL))
    label.y_offset=$((ISLAND_Y_OFFSET + LABEL_Y_FINAL))
    icon.drawing=on
    icon.color="$MAIN_COLOR"
    icon.padding_left=15
    icon.width=dynamic
    label.width=dynamic
    label.drawing=on
    label.color="$MAIN_COLOR"
    label.padding_left=8
    label.padding_right=18
    click_script="$CURRENT_SCRIPT_PATH CLICK"
)

NEW_STATE="$STATUS"

if [[ $STATUS == "PLAY" || $STATUS == "GEMINI" || $STATUS == "WEB" || $STATUS == "FOCUS" || $STATUS == "NOTIF" || $STATUS == "CTRL" ]]; then
    CLEAN_TITLE=$(echo "$TITLE" | cut -c1-28)
    
    # 1. 先瞬间设定位置、高度等静态属性（不带动画，杜绝抖动）
    sketchybar --set island "${COMMON_ARGS[@]}" icon="$ICON" label="$CLEAN_TITLE"
    
    # 2. 仅对边框颜色执行动画（实现 A+B=C 的平滑流转）
    sketchybar --animate sin 20 --set island background.border_color="$COLOR"
else
    # IDLE 状态同理
    sketchybar --set island "${COMMON_ARGS[@]}" icon="" label="" \
               icon.padding_left=20 icon.padding_right=20
               
    sketchybar --animate sin 30 --set island background.border_color="$RAINBOW_BREATH_COLOR"
fi

# 更新状态缓存
echo "$NEW_STATE" > "$STATE_FILE"

# 强制同步绘图
sketchybar --set island drawing=on
