-- НАСТРОЙКИ
local config = {
    inputFile = "human.aseprite",
    outputDir = "Human",
    
    -- ОДИНОЧНЫЕ СЛОИ
    singleLayers = {
        ["base"] = "base",
        ["Cloth1"] = "cloth1",
        ["Boots1"] = "boots1",
        ["tools"] = "tools"
    },

    -- ВОЛОСЫ
    hairLayers = {
        "long hair",
        "curly hair",
        "spikey hair",
        "mop hair",
        "short hair",
        "bowl hair"
    }
}

-- КОД
local sprite = app.open(config.inputFile)
if not sprite then return print("❌ Ошибка: Не могу открыть файл " .. config.inputFile) end

local fs = app.fs
fs.makeDirectory(config.outputDir)

local function hideAllLayers()
    for _, layer in ipairs(sprite.layers) do
        layer.isVisible = false
    end
end

local function findLayer(name)
    for _, layer in ipairs(sprite.layers) do
        if layer.name == name then return layer end
    end
    return nil 
end

print("🚀 Начало экспорта (СТРОГАЯ СЕТКА)...")

for _, tag in ipairs(sprite.tags) do
    local tagName = tag.name
    local folderName = string.upper(tagName)
    local tagDir = fs.joinPath(config.outputDir, folderName)
    fs.makeDirectory(tagDir)
    
    -- Считаем кадры
    local framesCount = tag.toFrame.frameNumber - tag.fromFrame.frameNumber + 1
    print("📂 Анимация: " .. tagName .. " (" .. framesCount .. " кадров)")

    -- 1. ЭКСПОРТ ОДИНОЧНЫХ СЛОЕВ
    for layerName, filePrefix in pairs(config.singleLayers) do
        hideAllLayers()
        local layer = findLayer(layerName)
        
        if layer then
            layer.isVisible = true
            
            local filename = string.format("%s_%s_strip%d.png", filePrefix, tagName, framesCount)
            local path = fs.joinPath(tagDir, filename)

            app.command.ExportSpriteSheet {
                ui = false,
                type = "horizontal", 
                textureFilename = path,
                tag = tagName,
                trim = false,             -- ВАЖНО: Не обрезать пустоту!
                mergeDuplicates = false,  -- ВАЖНО: Не склеивать кадры!
                ignoreEmpty = false       -- ВАЖНО: Экспортировать даже пустые кадры
            }
        else
            print("⚠️ Слой не найден: " .. layerName)
        end
    end

    -- 2. ЭКСПОРТ ВОЛОС (Атлас)
    hideAllLayers()
    local foundAnyHair = false
    
    for _, hairName in ipairs(config.hairLayers) do
        local layer = findLayer(hairName)
        if layer then
            layer.isVisible = true
            foundAnyHair = true
        else
            print("⚠️ Слой волос не найден: " .. hairName)
        end
    end

    if foundAnyHair then
        local hairFilename = string.format("hair_merged_%s_strip%d.png", tagName, framesCount)
        local hairPath = fs.joinPath(tagDir, hairFilename)

        app.command.ExportSpriteSheet {
            ui = false,
            type = "rows", 
            textureFilename = hairPath,
            tag = tagName,
            splitLayers = true, 
            trim = false,             -- ВАЖНО: Сохраняем полный размер холста
            mergeDuplicates = false,  -- ВАЖНО: Строгая сетка
            ignoreEmpty = false,
            columns = framesCount     -- Форсируем ширину, чтобы ряды не ломались
        }
    end

end

print("✅ Готово! Сетка сохранена.")