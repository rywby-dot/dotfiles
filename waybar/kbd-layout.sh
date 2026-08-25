#!/usr/bin/env bash
FILE="/tmp/kbd_layout"

# Вывести текущую раскладку сразу при старте
cat "$FILE" 2>/dev/null || echo "??"

# Слушать изменения и выводить новое значение при каждом обновлении
inotifywait -q -m -e close_write --include "kbd_layout" /tmp 2>/dev/null \
| while read -r; do
    cat "$FILE"
done
