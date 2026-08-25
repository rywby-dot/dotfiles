#!/bin/sh

# Путь к нашему первому скрипту переключения
TOGGLE_SCRIPT="$HOME/.config/driftwm/colemak.sh"

# Проверяем, запущен ли уже один такой демон, чтобы не плодить дубликаты
if pidof -x "$(basename "$0")" -o $$ >/dev/null; then
  echo "Демон уже запущен."
  exit 1
fi

echo "Слушатель Caps Lock запущен. Нажми Ctrl+C для выхода."

# Читаем события libinput и ловим нажатие Caps Lock
libinput debug-events | while read -r line; do
  # Проверяем, что это событие клавиатуры, клавиша Caps Lock и она именно НАЖАТА (pressed)
  if echo "$line" | grep -q "KEY_CAPSLOCK" && echo "$line" | grep -q "pressed"; then
    sh "$TOGGLE_SCRIPT"
  fi
done
