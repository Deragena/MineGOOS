local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")
local internet = require("internet")

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"
local ROOT = "/MineGOOS"

local gpu = component.gpu
local w, h = gpu.getResolution()

local files = {
    "init.lua",
    "Installer.lua",

    "Applications/Files.lua",
    "Applications/Settings.lua",
    "Applications/Terminal.lua",

    "Boot/boot.lua",

    "Installer/confirm.lua",
    "Installer/final.lua",
    "Installer/install.lua",
    "Installer/language.lua",
    "Installer/profile.lua",

    "Libraries/GUI.lua",
    "Libraries/Window.lua",

    "Store/catalog.lua",

    "System/Core.lua",
    "System/Desktop.lua",
    "System/FirstSetup.lua",
    "System/LanguageManager.lua",
    "System/WindowManager.lua",

    "Games/UploadLabs/launcher.lua"
}

local function clear()
    gpu.setBackground(0x101040)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
end

local function download(path)
    local url = BASE .. path
    local target = ROOT .. "/" .. path

    filesystem.makeDirectory(filesystem.path(target))

    local handle, reason = internet.request(url)

    if not handle then
        return false, reason
    end

    local file, err = io.open(target, "w")

    if not file then
        return false, err
    end

    for chunk in handle do
        file:write(chunk)
    end

    file:close()

    return true
end


clear()

gpu.set(3, 3, "MineGOOS Installer")
gpu.set(3, 5, "Preparing installation...")

filesystem.makeDirectory(ROOT)

for i, path in ipairs(files) do

    gpu.fill(1, 7, w, h - 6, " ")

    gpu.set(3, 7, "Downloading:")
    gpu.set(3, 8, path)

    local percent = math.floor((i - 1) / #files * 100)

    gpu.set(
        3,
        10,
        "[" ..
        string.rep("#", math.floor(percent / 5)) ..
        string.rep("-", 20 - math.floor(percent / 5)) ..
        "] " ..
        percent ..
        "%"
    )

    local ok, err = download(path)

    if not ok then
        gpu.set(3, 13, "ERROR!")
        gpu.set(3, 14, tostring(err))
        gpu.set(3, 16, "Press any key to reboot.")

        computer.pullSignal("key_down")
        computer.shutdown(true)
        return
    end
end

gpu.fill(1, 7, w, h - 6, " ")

gpu.set(3, 8, "Files downloaded successfully!")
gpu.set(3, 10, "Starting MineGOOS Setup...")

local file = io.open(ROOT .. "/.setup_stage", "w")

if file then
    file:write("1")
    file:close()
end

computer.pullSignal(2)

dofile(ROOT .. "/Installer.lua")
