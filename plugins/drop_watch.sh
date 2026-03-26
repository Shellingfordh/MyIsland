#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

CONTROL_CACHE="/tmp/sketchybar_island_ctrl"
TARGET_FILE="/tmp/sketchybar_drop_target"
DROP_DIR_DEFAULT="$HOME/Downloads/MyIslandDrop"
DROP_DIR="${USER_DROP_DIR:-$DROP_DIR_DEFAULT}"
STATE_FILE="/tmp/sketchybar_drop_state"

mkdir -p "$DROP_DIR"

# read target
TARGET=$(cat "$TARGET_FILE" 2>/dev/null)
[ -z "$TARGET" ] && TARGET="downloads"

set_control_cache() {
  local msg="$1"
  local icon="$2"
  echo "$(date +%s)|$msg|$icon" > "$CONTROL_CACHE"
}

# find newest file
latest=$(find "$DROP_DIR" -maxdepth 1 -type f -print0 2>/dev/null | xargs -0 stat -f "%m %N" 2>/dev/null | sort -nr | head -n1)
[ -z "$latest" ] && exit 0

mtime=$(echo "$latest" | awk '{print $1}')
file=$(echo "$latest" | cut -d' ' -f2-)

last_mtime=$(cat "$STATE_FILE" 2>/dev/null || echo "")
if [ "$mtime" = "$last_mtime" ]; then
  exit 0
fi

echo "$mtime" > "$STATE_FILE"

case "$TARGET" in
  downloads)
    dest="$HOME/Downloads"
    mv "$file" "$dest/" 2>/dev/null
    set_control_cache "Drop → Downloads" "📥"
    ;;
  desktop)
    dest="$HOME/Desktop"
    mv "$file" "$dest/" 2>/dev/null
    set_control_cache "Drop → Desktop" "🖥️"
    ;;
  clipboard)
    echo "$file" | pbcopy
    set_control_cache "Drop → Clipboard" "📋"
    ;;
  airdrop)
    open "x-apple.systempreferences:com.apple.AirDrop" >/dev/null 2>&1
    open -R "$file" >/dev/null 2>&1
    set_control_cache "Drop → AirDrop" "📡"
    ;;
  *)
    set_control_cache "Drop detected" "📦"
    ;;
esac

sketchybar --trigger island_update
