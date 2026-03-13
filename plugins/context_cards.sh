#!/bin/bash
set -euo pipefail

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

CONTEXT_CARDS=${CONTEXT_CARDS:-"app,media,focus,system"}

has_card() {
  echo ",${CONTEXT_CARDS}," | grep -qi ",$1,"
}

front_app() {
  osascript -e "tell application \"System Events\" to get name of first process whose frontmost is true" 2>/dev/null || true
}

front_window() {
  osascript -e "tell application \"System Events\" to tell (first process whose frontmost is true) to get name of front window" 2>/dev/null || true
}

browser_tab() {
  local app="$1"
  case "$app" in
    "Google Chrome"|"Chromium"|"Microsoft Edge")
      osascript -e "tell application \"$app\" to if it is running then return title of active tab of front window" 2>/dev/null || true
      ;;
    "Arc")
      osascript -e "tell application \"Arc\" to if it is running then return title of active tab of front window" 2>/dev/null || true
      ;;
    "Safari")
      osascript -e "tell application \"Safari\" to if it is running then return name of current tab of front window" 2>/dev/null || true
      ;;
    *)
      ;;
  esac
}

media_now_playing() {
  local s m
  s=$(osascript -e "tell application \"Spotify\" to if it is running and player state is playing then return artist of current track & \" — \" & name of current track" 2>/dev/null || true)
  if [ -n "$s" ]; then
    echo "Spotify: $s"
    return
  fi
  m=$(osascript -e "tell application \"Music\" to if it is running and player state is playing then return artist of current track & \" — \" & name of current track" 2>/dev/null || true)
  if [ -n "$m" ]; then
    echo "Music: $m"
    return
  fi
  echo "(none)"
}

focus_status() {
  local dnd
  dnd=$(defaults -currentHost read com.apple.notificationcenterui doNotDisturb 2>/dev/null || true)
  if [ "$dnd" = "1" ] || [ "$dnd" = "true" ]; then
    echo "On"
    return
  fi
  if [ -z "$dnd" ]; then
    echo "(unknown)"
    return
  fi
  echo "Off"
}

system_status() {
  local batt vol bri
  batt=$(pmset -g batt 2>/dev/null | awk -F';' 'NR==2{gsub(/^[ \t]+/,"",$2); print $2}' | head -n1)
  vol=$(osascript -e "output volume of (get volume settings)" 2>/dev/null || echo "?")
  if command -v brightness >/dev/null 2>&1; then
    bri=$(brightness -l | awk '/brightness/ {print $4}' | head -n1)
    bri=${bri:-0}
    bri=$(python3 - <<'PY'
import sys
try:
    v=float(sys.argv[1])
    print(int(v*100))
except Exception:
    print("?")
PY
"$bri")
  else
    bri="?"
  fi
  echo "Battery ${batt:-?} | Vol ${vol}% | Bri ${bri}%"
}

show_dialog() {
  local app win tab media focus sys text

  if has_card "app"; then
    app=$(front_app)
    win=$(front_window)
    tab=$(browser_tab "$app")
  fi

  if has_card "media"; then
    media=$(media_now_playing)
  fi

  if has_card "focus"; then
    focus=$(focus_status)
  fi

  if has_card "system"; then
    sys=$(system_status)
  fi

  text=""
  if has_card "app"; then
    text+="App: ${app:-?}"
    if [ -n "$tab" ]; then
      text+="\nTab: $tab"
    elif [ -n "$win" ]; then
      text+="\nWindow: $win"
    fi
  fi

  if has_card "media"; then
    [ -n "$text" ] && text+="\n"
    text+="Media: $media"
  fi

  if has_card "focus"; then
    [ -n "$text" ] && text+="\n"
    text+="Focus: $focus"
  fi

  if has_card "system"; then
    [ -n "$text" ] && text+="\n"
    text+="System: $sys"
  fi

  osascript -e "display dialog \"$text\" with title \"MyIsland Context\" buttons {\"OK\"} default button 1" >/dev/null 2>&1
}

show_dialog
