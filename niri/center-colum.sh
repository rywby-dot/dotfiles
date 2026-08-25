#!/usr/bin/env bash

# Слушаем поток событий niri, ловим событие закрытия окна
# и сразу дергаем команду выравнивания видимых колонок
niri msg event-stream | grep --line-buffered "WindowClosed" | while read -r line; do
  niri msg action center-visible-columns
done
