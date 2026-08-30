#!/bin/bash

# 1. Магия: переходим в папку, где лежит этот файл
cd "$(dirname "$0")"

echo "📂 Рабочая папка: $(pwd)"
echo "🚀 Запуск Aseprite..."

# 2. Запускаем Aseprite с твоим Lua-скриптом
# (Используем $HOME, чтобы путь был универсальным)
"$HOME/Library/Application Support/Steam/steamapps/common/Aseprite/Aseprite.app/Contents/MacOS/aseprite" -b -script full_export.lua

echo "✅ Готово! Можешь закрыть это окно."