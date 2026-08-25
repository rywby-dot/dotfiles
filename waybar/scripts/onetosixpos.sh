#!/bin/bash

MONITOR=$1
if [ -z "$MONITOR" ]; then
  echo "Error: Output name required"
  exit 1
fi

print_position() {
  driftwm msg state 2>/dev/null | awk -v monitor="$MONITOR" '
        {
            offset = ($1 == "*" ? 1 : 0)
        }
        $(1 + offset) == monitor && $(2 + offset) == "camera" {
            x=$(3 + offset)
            y=$(4 + offset)
        }
        END {
            if (x != "" && y != "") {
                # Принудительно приводим к числу (убираем плавающую точку, если есть)
                x = x + 0
                y = y + 0

                # Положение 1
                if (x >= -9000 && x <= 0 && y >= 0 && y <= 8000) {
                    print "1"
                }
                # Положение 2
                else if (x >= 0 && x <= 9000 && y >= 0 && y <= 8000) {
                    print "2"
                }
                # Положение 3
                else if (x >= -9000 && x <= 0 && y <= 0 && y >= -8000) {
                    print "3"
                }
                # Положение 4
                else if (x >= 0 && x <= 9000 && y <= 0 && y >= -8000) {
                    print "4"
                }
                # Положение 5
                else if (x >= -4500 && x <= 4500 && y <= 16000 && y >= 8000) {
                    print "5"
                }
                # Всё остальное
                else {
                    print "-"
                }
            }
        }
    '
}

# В выводе команды нет файлового события, поэтому периодически опрашиваем driftwm.
# Печатаем результат только при изменении, чтобы не засорять вывод Waybar.
last_position=
while true; do
  position=$(print_position)

  if [ -n "$position" ] && [ "$position" != "$last_position" ]; then
    printf '%s\n' "$position"
    last_position=$position
  fi

  sleep 0.2
done
