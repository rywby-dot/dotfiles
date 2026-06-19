#!/bin/bash
STATE_FILE="$XDG_RUNTIME_DIR/driftwm/state"
STATE_DIR=$(dirname "$STATE_FILE")

# Ждем появления файла состояния, если его еще нет
while [ ! -f "$STATE_FILE" ]; do
  sleep 1
done

MONITOR=$1
if [ -z "$MONITOR" ]; then
  echo "Error: Output name required"
  exit 1
fi

print_position() {
  awk -F'=' -v m="outputs.$MONITOR." '
        $1 == m"camera_x" { x=$2 }
        $1 == m"camera_y" { y=$2 }
        END {
            if (x != "" && y != "") {
                # Принудительно приводим к числу (убираем плавающую точку, если есть)
                x = x + 0
                y = y + 0

                # Положение 1: Центр (0, 0)
                if (x >= -3500 && x <= 3500 && y >= -2250 && y <= 2250) {
                    print "1"
                }
                # Положение 2: Центр (7000, 0)
                else if (x >= 3500 && x <= 10500 && y >= -2250 && y <= 2250) {
                    print "2"
                }
                # Положение 3: Центр (0, -4500)
                else if (x >= -3500 && x <= 3500 && y <= 6750 && y >= 2250) {
                    print "3"
                }
                # Положение 4: Центр (7000, -4500)
                else if (x >= 3500 && x <= 10500 && y <= 6750 && y >= 2250) {
                    print "4"
                }
                # Положение 5: Центр (3500, 5500)
                else if (x >= 0 && x <= 7000 && y <= -3250 && y >= -7750) {
                    print "5"
                }
                # Всё остальное
                else {
                    print "-"
                }
            }
        }
    ' "$STATE_FILE"
}

# Выводим начальное состояние при запуске
print_position

# Отслеживаем изменения в реальном времени
inotifywait -q -m -e close_write,moved_to,modify "$STATE_DIR" | while read -r dir action file; do
  if [ "$file" = "state" ]; then
    print_position
  fi
done
