#!/bin/bash

# NotchKit Notification Monitor
# 监听 macOS 通知中心数据库

DB="$HOME/Library/Application Support/NotificationCenter/db2/db"

last_id=""

while true; do

    notif=$(sqlite3 "$DB" "
    SELECT app_id, title
    FROM record
    ORDER BY delivered_date DESC
    LIMIT 1;
    ")

    id=$(echo "$notif" | cut -d'|' -f1)
    title=$(echo "$notif" | cut -d'|' -f2)

    if [[ "$id" != "$last_id" && "$title" != "" ]]; then

        sketchybar --trigger notification_occurrence INFO="$title"

        last_id="$id"

    fi

    sleep 2

done