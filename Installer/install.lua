local component = require("component")
local filesystem = require("filesystem")
local internet = require("internet")

local gpu = component.gpu
local w, h = gpu.getResolution()

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"

local Storage = dofile("/MineGOOS/Installer/storage.lua")

local files = {
  "init.lua",
  "BIOS/post.lua",
  "Applications/Games/UploadLabs/launcher.lua",
  "Installer.lua",
  "Boot/boot.lua",
  "Installer/confirm.lua",
  "Installer/final.lua",
  "Installer/install.lua",
  "Installer/language.lua",
  "Installer/profile.lua",
  "Installer/interface.lua",
  "Installer/theme.lua",
  "Installer/storage.lua",
  "Applications/Files.lua",
  "Applications/Settings.lua",
  "Applications/Terminal.lua",
  "Applications/TextEditor.lua",
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

local function draw(title, message, progress)
  gpu.setBackground(0x100D1C)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")

  gpu.setForeground(0x985CFF)
  gpu.set(2, 2, "MINEGOOS INSTALLER")

  gpu.setForeground(0xFFFFFF)
  gpu.set(2, 5, title)

  gpu.setForeground(0xAAA4BD)
  gpu.set(2, 7, message)

  if progress then
    local width = math.max(1, w - 4)
    local filled = math.floor(width * progress)
    gpu.setBackground(0x302744)
    gpu.fill(2, 10, width, 1, " ")
    gpu.setBackground(0x985CFF)
    if filled > 0 then
      gpu.fill(2, 10, filled, 1, " ")
    end
    gpu.setBackground(0x100D1C)
  end
end

local function downloadFile(path, destination)
  local url = BASE .. path
  local target = destination .. "/" .. path

  local parent = filesystem.path(target)
  filesystem.makeDirectory(parent)

  local request, reason = internet.request(url)
  if not request then
    return false, "Request failed: " .. tostring(reason)
  end

  local output, openError = io.open(target, "wb")
  if not output then
    return false, "Cannot write " .. target .. ": " .. tostring(openError)
  end

  local ok, err = pcall(function()
    for chunk in request do
      output:write(chunk)
    end
  end)

  output:close()

  if not ok then
    return false, tostring(err)
  end

  return true
end

local function main()
  draw("SELECT INSTALLATION DISK", "Choose the destination drive.")

  local destination = Storage.choose()
  if not destination then
    return false, "Disk selection cancelled or failed."
  end

  filesystem.makeDirectory(destination)

  for i, path in ipairs(files) do
    local percent = (i - 1) / #files
    draw(
      "INSTALLING MINEGOOS",
      "Downloading: " .. path,
      percent
    )

    local ok, reason = downloadFile(path, destination)
    if not ok then
      return false, reason
    end
  end

  draw("INSTALLATION COMPLETE", "System files downloaded.", 1)
  return true
end

local ok, result = pcall(main)

if not ok then
  draw("INSTALLATION ERROR", tostring(result))
  return false
end

if result == false then
  return false
end

return true
