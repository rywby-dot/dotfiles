#!/bin/bash
STATE_FILE="$XDG_RUNTIME_DIR/driftwm/state"

# Быстрая проверка на существование файла
if [ ! -f "$STATE_FILE" ]; then
  echo "Error: State file not found"
  exit 1
fi

MONITOR=$1
if [ -z "$MONITOR" ]; then
  echo "Error: Output name required (e.g. ./script.sh HDMI-A-1)"
  exit 1
fi

# 1. Считываем координаты и определяем зону (твоя логика awk)
ZONE=$(awk -F'=' -v m="outputs.$MONITOR." '
    $1 == m"camera_x" { x=$2 }
    $1 == m"camera_y" { y=$2 }
    END {
        if (x != "" && y != "") {
            x = x + 0
            y = y + 0

            # Положение 1
            if (x >= -3500 && x <= 3500 && y >= -2250 && y <= 2250) {
                print "1"
            }
            # Положение 2
            else if (x >= 3500 && x <= 10500 && y >= -2250 && y <= 2250) {
                print "2"
            }
            # Положение 3
            else if (x >= -3500 && x <= 3500 && y <= 6750 && y >= 2250) {
                print "3"
            }
            # Положение 4
            else if (x >= 3500 && x <= 10500 && y <= 6750 && y >= 2250) {
                print "4"
            }
            # Положение 5
            else if (x >= 0 && x <= 7000 && y <= -3250 && y >= -7750) {
                print "5"
            }
            # Всё остальное
            else {
                print "-"
            }
        }
    }
' "$STATE_FILE")

# 2. Выполняем команду в зависимости от пойманной зоны и выходим
case "$ZONE" in
1)
  driftwm msg action go-to 1100 -600
  ;;
2)
  driftwm msg action go-to 8100 -600
  ;;
3)
  driftwm msg action go-to 900 -5100
  ;;
4)
  driftwm msg action go-to 8100 -5100
  ;;
5)
  driftwm msg action go-to 4600 4900
  ;;
"-")
  driftwm msg action zoom-to-fit
  ;;
*)
  echo "Error: Failed to parse coordinates."
  exit 1
  ;;
esac
