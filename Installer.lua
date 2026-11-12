
local component = require("component")
local filesystem = require("filesystem")
local internet = require("internet")

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"
local ROOT = "/MineGOOS/"

local files = {
  "init.lua",
  "check_account.lua",

  "BIOS/bios.lua",
  "BIOS/eeprom.lua",
  "BIOS/post.lua",
  "BIOS/prepare.lua",

  "Boot/boot.lua",

  "Applications/Files.lua",
  "Applications/FilesGUI.lua",
  "Applications/Settings.lua",
  "Applications/SettingsGUI.lua",
  "Applications/Terminal.lua",
  "Applications/TerminalGUI.lua",
  "Applications/TextEditor.lua",
  "Applications/TextEditorGUI.lua",
  "Applications/Games/UploadLabs/launcher.lua",

  "Games/UploadLabs/launcher.lua",

  "Installer/account.lua",
  "Installer/account_store.lua",
  "Installer/confirm.lua",
  "Installer/controller.lua",
  "Installer/downloads.lua",
  "Installer/engine.lua",
  "Installer/final.lua",
  "Installer/install.lua",
  "Installer/interface.lua",
  "Installer/language.lua",
  "Installer/profile.lua",
  "Installer/storage.lua",
  "Installer/theme.lua",

  "Libraries/GUI.lua",
  "Libraries/Window.lua",

  "Store/API.lua",
  "Store/catalog.json",
  "Store/catalog.lua",
  "Store/catalog.txt",

  "System/Core.lua",
  "System/Desktop.lua",
  "System/FirstSetup.lua",
  "System/LanguageManager.lua",
  "System/WindowManager.lua"
}

local function download(path)
  local target = ROOT .. path

  if filesystem.exists(target) then
    return true, "EXISTS"
  end

  filesystem.makeDirectory(filesystem.path(target))

  local response, reason = internet.request(BASE .. path)

  if not response then
    return false, tostring(reason)
  end

  local temp = target .. ".download"
  local file, err = io.open(temp, "wb")

  if not file then
    return false, tostring(err)
  end

  local ok, problem = pcall(function()
    for chunk in response do
      file:write(chunk)
    end
  end)

  file:close()

  if not ok then
    filesystem.remove(temp)
    return false, tostring(problem)
  end

  local moved, moveError = filesystem.rename(temp, target)

  if not moved then
    filesystem.remove(temp)
    return false, tostring(moveError)
  end

  return true, "DOWNLOADED"
end

local gpu = component.gpu
local w, h = gpu.getResolution()

gpu.setBackground(0x100020)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")

local function status(line, message)
  gpu.set(2, line, tostring(message):sub(1, w - 3))
end

local function main()
  if not component.isAvailable("internet") then
    error("Internet Card not found!")
  end

  status(2, "MineGOOS Installer")
  status(4, "Checking system files...")

  local downloaded = 0
  local skipped = 0

  for i, path in ipairs(files) do
    status(6, "Downloading " .. i .. "/" .. #files)
    status(8, path)

    local ok, result = download(path)

    if not ok then
      error("Failed: " .. path .. "\n" .. result)
    end

    if result == "DOWNLOADED" then
      downloaded = downloaded + 1
    else
      skipped = skipped + 1
    end
  end

  status(10, "Downloaded: " .. downloaded)
  status(11, "Already existed: " .. skipped)
  status(13, "Starting graphical installer...")

  os.sleep(1)

  dofile(ROOT .. "Installer/interface.lua").run()
end

local ok, err = xpcall(main, debug.traceback)

if not ok then
  gpu.setBackground(0x400000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")
  status(2, "MINEGOOS INSTALLER ERROR")
  status(4, tostring(err))
end
