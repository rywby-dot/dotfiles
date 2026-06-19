#!/bin/bash

wl-paste -t text --watch bash -c '
    # 1. Читаем первые 200 байт (с запасом)
    # 2. iconv -c тихо удаляет обрезанные наполовину UTF-8 символы на конце
    # 3. tr "\n" " " меняет переносы строк на пробелы
    raw_text=$(head -c 200 | iconv -f UTF-8 -t UTF-8 -c | tr "\n" " ")
    
    # Обрезаем строку ровно до 60 символов (bash считает именно символы, а не байты)
    text="${raw_text:0:150}"
    
    # Если исходный текст был длиннее 60 символов, добавляем многоточие
    if [ ${#raw_text} -gt 150 ]; then
        text="$text..."
    fi
    
    # Отправляем уведомление, если текст не пустой
    if [ -n "$text" ]; then
        notify-send "Copied" "$text" -t 2000 -h string:x-canonical-private-synchronous:clipboard
    fi
'
