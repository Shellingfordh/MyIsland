#!/bin/bash
set -euo pipefail

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

CACHE_FILE="/tmp/myisland_hotness_cache.json"
DEFAULT_CACHE_MINUTES=30

HOTNESS_ENABLED=${HOTNESS_ENABLED:-off}
HOTNESS_CACHE_MINUTES=${HOTNESS_CACHE_MINUTES:-$DEFAULT_CACHE_MINUTES}
HOTNESS_SOURCES=${HOTNESS_SOURCES:-"google,github"}
HOTNESS_GEO=${HOTNESS_GEO:-"US"}
HOTNESS_LIMIT=${HOTNESS_LIMIT:-5}

now_epoch() { date +%s; }

is_enabled() {
  [ "$HOTNESS_ENABLED" = "on" ]
}

cache_age_minutes() {
  if [ ! -f "$CACHE_FILE" ]; then
    echo 99999
    return
  fi
  local ts
  ts=$(python3 - <<'PY'
import json
try:
    data=json.load(open("/tmp/myisland_hotness_cache.json"))
    print(int(data.get("timestamp", 0)))
except Exception:
    print(0)
PY
  )
  if [ -z "$ts" ] || [ "$ts" -le 0 ]; then
    echo 99999
    return
  fi
  local now
  now=$(now_epoch)
  echo $(( (now - ts) / 60 ))
}

fetch_github() {
  curl -sL --max-time 8 "https://github.com/trending?since=daily" | \
    grep -Eo '/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | \
    sed 's#^/##' | \
    grep -vE '^(topics|collections|sponsors|login|site|trending)\b' | \
    awk '!seen[$0]++' | \
    head -n "$HOTNESS_LIMIT"
}

fetch_google() {
  curl -sL --max-time 8 "https://trends.google.com/trends/trendingsearches/daily/rss?geo=${HOTNESS_GEO}" | \
    python3 - <<'PY'
import sys, xml.etree.ElementTree as ET
xml = sys.stdin.read()
if not xml.strip():
    sys.exit(0)
root = ET.fromstring(xml)
items = root.findall('.//item')
limit = int(sys.argv[1])
for item in items[:limit]:
    title = item.findtext('title', default='').strip()
    if title:
        print(title)
PY
"$HOTNESS_LIMIT"
}

write_cache() {
  local ts
  ts=$(now_epoch)
  python3 - <<'PY' "$ts"
import json, sys
path = "/tmp/myisland_hotness_cache.json"
lines = sys.stdin.read().splitlines()
section = "google"
store = {
    "timestamp": int(sys.argv[1]),
    "google": [],
    "github": []
}
for line in lines:
    if line.strip() == "--":
        section = "github"
        continue
    if not line.strip():
        continue
    store[section].append(line.strip())
with open(path, "w") as f:
    json.dump(store, f, ensure_ascii=True, indent=2)
PY
}

fetch_all() {
  local google github
  google=""
  github=""

  if echo ",${HOTNESS_SOURCES}," | grep -qi ",google,"; then
    google=$(fetch_google || true)
  fi
  if echo ",${HOTNESS_SOURCES}," | grep -qi ",github,"; then
    github=$(fetch_github || true)
  fi

  if [ -z "$google" ] && [ -z "$github" ] && [ -f "$CACHE_FILE" ]; then
    # Keep old cache if fetch failed
    return
  fi

  { echo "$google"; echo "--"; echo "$github"; } | write_cache
}

summary_text() {
  if [ ! -f "$CACHE_FILE" ]; then
    echo "(No cache yet)"
    return
  fi
  python3 - <<'PY'
import json, time
path = "/tmp/myisland_hotness_cache.json"
try:
    data=json.load(open(path))
except Exception:
    print("(Cache corrupted)")
    raise SystemExit(0)

limit = 5

ts=int(data.get("timestamp", 0))
if ts:
    ts_str=time.strftime("%Y-%m-%d %H:%M", time.localtime(ts))
else:
    ts_str="unknown"

google=data.get("google", [])[:limit]
github=data.get("github", [])[:limit]

print(f"Hotness (cached @ {ts_str})")
print("-------------------------")

if google:
    print("Google Trends:")
    for i, t in enumerate(google, 1):
        print(f"  {i}. {t}")
else:
    print("Google Trends: (empty)")

print("")

if github:
    print("GitHub Trending:")
    for i, t in enumerate(github, 1):
        print(f"  {i}. {t}")
else:
    print("GitHub Trending: (empty)")
PY
}

show_dialog() {
  local text
  text=$(summary_text)
  osascript -e "display dialog \"$text\" with title \"MyIsland Hotness\" buttons {\"OK\"} default button 1" >/dev/null 2>&1
}

main() {
  local cmd=${1:-"summary"}
  if ! is_enabled; then
    echo "Hotness is off"
    exit 0
  fi

  case "$cmd" in
    fetch)
      fetch_all
      ;;
    show)
      local age
      age=$(cache_age_minutes)
      if [ "$age" -ge "$HOTNESS_CACHE_MINUTES" ]; then
        fetch_all
      fi
      show_dialog
      ;;
    summary)
      local age
      age=$(cache_age_minutes)
      if [ "$age" -ge "$HOTNESS_CACHE_MINUTES" ]; then
        fetch_all
      fi
      summary_text
      ;;
    *)
      echo "Usage: hotness.sh [fetch|show|summary]"
      exit 1
      ;;
  esac
}

main "$@"
