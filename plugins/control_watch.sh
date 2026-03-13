#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

CONTROL_CACHE="/tmp/sketchybar_island_ctrl"
VOLUME_CACHE="/tmp/sketchybar_island_volume"
BRIGHTNESS_CACHE="/tmp/sketchybar_island_brightness"

APPLE_LANG=$(plutil -extract AppleLanguages.0 raw -o - "$HOME/Library/Preferences/.GlobalPreferences.plist" 2>/dev/null)
APPLE_LOCALE=$(plutil -extract AppleLocale raw -o - "$HOME/Library/Preferences/.GlobalPreferences.plist" 2>/dev/null)
if [ -z "$APPLE_LANG" ]; then
  APPLE_LANG=$(defaults read -g AppleLanguages 2>/dev/null | tr -d '\",()' | awk 'NF{print $1; exit}')
fi
if [ -z "$APPLE_LOCALE" ]; then
  APPLE_LOCALE=$(defaults read -g AppleLocale 2>/dev/null | tr -d '\",()')
fi
LANG_IS_ZH=0
case "${APPLE_LANG:-${LANG:-}}" in
  zh* ) LANG_IS_ZH=1 ;;
  * )
    case "${APPLE_LOCALE:-}" in
      zh* ) LANG_IS_ZH=1 ;;
    esac
  ;;
esac

loc() {
  if [ "$LANG_IS_ZH" -eq 1 ]; then
    echo "$2"
  else
    echo "$1"
  fi
}

STR_VOLUME=$(loc "Volume" "音量")
STR_BRIGHTNESS=$(loc "Brightness" "亮度")

set_control_cache() {
  local msg="$1"
  local icon="$2"
  echo "$(date +%s)|$msg|$icon" > "$CONTROL_CACHE"
}

changed=0

cur_vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
cur_vol=${cur_vol:-0}
last_vol=$(cat "$VOLUME_CACHE" 2>/dev/null || echo "")
if [ -n "$last_vol" ]; then
  if [ "$cur_vol" != "$last_vol" ]; then
    set_control_cache "$STR_VOLUME ${cur_vol}%" "🔊"
    changed=1
  fi
fi
echo "$cur_vol" > "$VOLUME_CACHE"

if command -v brightness >/dev/null 2>&1; then
  cur_bri=$(brightness -l | awk '/brightness/ {print $4}' | head -n1)
  cur_bri=${cur_bri:-0.7}
  cur_bri=$(perl -e 'printf "%d", (shift*100)' "$cur_bri")
  last_bri=$(cat "$BRIGHTNESS_CACHE" 2>/dev/null || echo "")
  if [ -n "$last_bri" ]; then
    if [ "$cur_bri" != "$last_bri" ]; then
      set_control_cache "$STR_BRIGHTNESS ${cur_bri}%" "🔆"
      changed=1
    fi
  fi
  echo "$cur_bri" > "$BRIGHTNESS_CACHE"
fi

if [ "$changed" -eq 1 ]; then
  sketchybar --trigger island_update
fi
