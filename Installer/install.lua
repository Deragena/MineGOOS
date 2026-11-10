local component = require("component")
local filesystem = require("filesystem")
local internet = require("internet")

local gpu = component.gpu
local w, h = gpu.getResolution()

local Install = {}

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"

local files = {
  "init.lua",
  "BIOS/post.lua",
  "Applications/Games/UploadLabs/launcher.lua",
  "Installer.lua",
  "Boot/boot.lua",
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

local function downloadFile(path, destination)
  local target = destination .. "/" .. path

  filesystem.makeDirectory(filesystem.path(target))

  local request, reason = internet.request(BASE .. path)
  if not request then
    return false, "Request failed: " .. tostring(reason)
  end

  local output, err = io.open(target, "wb")
  if not output then
    return false, "Cannot write " .. target .. ": " .. tostring(err)
  end

  local ok, result = pcall(function()
    for chunk in request do
      output:write(chunk)
    end
  end)

  output:close()

  if not ok then
    return false, tostring(result)
  end

  return true
end

function Install.run(destination, callback)
  if not destination then
    return false, "No installation disk selected."
  end

  filesystem.makeDirectory(destination)

  for i, path in ipairs(files) do
    if callback then
      callback(i, #files, path)
    end

    local ok, reason = downloadFile(path, destination)

    if not ok then
      return false, reason
    end
  end

  if callback then
    callback(#files, #files, "Installation complete")
  end

  return true
end

return Install
