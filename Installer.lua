local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")

local SETUP_STAGE = "/MineGOOS/.setup_stage"

local function getStage()
    local file = io.open(SETUP_STAGE, "r")

    if not file then
        return 1
    end

    local data = file:read("*a")
    file:close()

    return tonumber(data) or 1
end

local function setStage(stage)
    filesystem.makeDirectory("/MineGOOS")

    local file = io.open(SETUP_STAGE, "w")

    if file then
        file:write(tostring(stage))
        file:close()
    end
end

local function reboot()
    computer.shutdown(true)
end

local stage = getStage()

-- 1 → Выбор языка
if stage == 1 then

    local language = dofile("/MineGOOS/Installer/language.lua")

    local file = io.open("/MineGOOS/.language", "w")

    if file then
        file:write(language)
        file:close()
    end

    setStage(2)

    reboot()

-- 2 → Установка системы
elseif stage == 2 then

    local ok = dofile("/MineGOOS/Installer/install.lua")

    if ok then
        setStage(3)
        reboot()
    end

-- 3 → Финал установки
elseif stage == 3 then

    dofile("/MineGOOS/Installer/final.lua")

    setStage(4)

-- 4 → Имя пользователя и пароль
elseif stage == 4 then

    dofile("/MineGOOS/Installer/profile.lua")

    setStage(5)

-- 5 → Подтверждение
elseif stage == 5 then

    local ok = dofile("/MineGOOS/Installer/confirm.lua")

    if ok then
        setStage(6)
        reboot()
    end

-- 6 → Финальная перезагрузка
elseif stage == 6 then

    setStage(7)

    reboot()

-- 7 → Запуск MineGOOS
elseif stage == 7 then

    filesystem.remove(SETUP_STAGE)

    dofile("/MineGOOS/init.lua")

end
