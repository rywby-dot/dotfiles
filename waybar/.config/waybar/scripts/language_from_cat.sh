#!/bin/bash
STATE_FILE="$XDG_RUNTIME_DIR/driftwm/state"
STATE_DIR=$(dirname "$STATE_FILE")

while [ ! -f "$STATE_FILE" ]; do
  sleep 1
done

print_state() {
  # Достаем layout и сразу заменяем длинные названия на короткие
  sed -n 's/^layout=//p' "$STATE_FILE" | sed -e 's/Croatian (US)/qwerty/' -e 's/Russian/RU/' -e 's/English (Colemak-DH)/US/'
}

# Выводим один раз при запуске Waybar
print_state

# Мониторим изменения файла в реальном времени
inotifywait -q -m -e close_write,moved_to,modify "$STATE_DIR" | while read -r dir action file; do
  if [ "$file" = "state" ]; then
    print_state
  fi
done
