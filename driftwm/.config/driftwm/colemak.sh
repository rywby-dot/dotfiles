#!/bin/sh

# Получаем текущее имя раскладки от driftwm
CURRENT=$(driftwm msg layout)

# Проверяем регистронезависимо, есть ли слово "english" в выводе
if echo "$CURRENT" | grep -qi "english"; then
  # Если сейчас us (0), то включаем ru (2)
  driftwm msg action switch-layout 2
else
  # Если сейчас ru (2) или hr (1), то возвращаем на us (0)
  driftwm msg action switch-layout 0
fi
