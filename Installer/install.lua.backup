local component = require("component")
local event = require("event")
local filesystem = require("filesystem")
local internet = require("internet")

local gpu = component.gpu
local w, h = gpu.getResolution()

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"

local files = {
  "init.lua",
  "Installer.lua",

  "Boot/boot.lua",

  "Installer/confirm.lua",
  "Installer/final.lua",
  "Installer/install.lua",
  "Installer/language.lua",
  "Installer/profile.lua",

  "Applications/Files.lua",
  "Applications/Settings.lua",
  "Applications/Terminal.lua",

  "Games/UploadLabs/launcher.lua",

  "Libraries/GUI.lua",
  "Libraries/Window.lua",

  "Store/catalog.lua",

  "System/Core.lua",
  "System/Desktop.lua",
  "System/FirstSetup.lua",
  "System/LanguageManager.lua",
  "System/WindowManager.lua"
}

local function clear()
  gpu.setBackground(0x101040)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")
end

local function downloadFile(path)
  local url = BASE .. path
  local target = "/MineGOOS/" .. path

  filesystem.makeDirectory(filesystem.path(target))

  local handle, reason = internet.request(url)

  if not handle then
    return false, tostring(reason)
  end

  local file, err = io.open(target, "w")

  if not file then
    return false, tostring(err)
  end

  for chunk in handle do
    file:write(chunk)
  end

  file:close()

  return true
end

clear()

gpu.set(3, 3, "MineGOOS Setup")
gpu.set(3, 5, "Checking disk...")

local disk

for address in component.list("filesystem") do
  local fs = component.proxy(address)

  local free = fs.getCapacity() - fs.getUsedSpace()

  if free >= 2 * 1024 * 1024 then
    disk = fs
    break
  end
end

if not disk then
  gpu.set(3, 8, "ERROR: Not enough disk space!")
  gpu.set(3, 10, "Required: 2 MB free")
  gpu.set(3, 12, "[ Retry ]")

  while true do
    local _, _, _, y = event.pull("touch")

    if y == 12 then
      return false
    end
  end
end

filesystem.makeDirectory("/MineGOOS")

gpu.set(3, 7, "Disk OK")
gpu.set(3, 9, "Downloading MineGOOS...")

for i, path in ipairs(files) do
  local ok, err = downloadFile(path)

  if not ok then
    clear()
    gpu.set(3, 5, "Installation error!")
    gpu.set(3, 7, path)
    gpu.set(3, 9, tostring(err))
    return false
  end

  local percent = math.floor((i / #files) * 100)

  gpu.set(3, 11, "Installing: " .. path)
  gpu.set(3, 13, "[" .. string.rep("#", math.floor(percent / 5))
    .. string.rep("-", 20 - math.floor(percent / 5))
    .. "] " .. percent .. "%")
end

gpu.set(3, 15, "Installation complete!")

return true
