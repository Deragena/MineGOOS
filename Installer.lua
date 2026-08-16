local component = require("component")
local filesystem = require("filesystem")
local internet = require("internet")

local BASE = "https://raw.githubusercontent.com/deragena/MineGOOS/main/"

local files = {
  "init.lua",
  "System/Core.lua",
  "System/LanguageManager.lua",
  "System/FirstSetup.lua",
  "System/WindowManager.lua",
  "System/Desktop.lua",
  "Libraries/GUI.lua",
  "Libraries/Window.lua",
  "Store/catalog.lua",
  "Games/UploadLabs/launcher.lua"
}

print("================================")
print("       MineGOOS Installer")
print("================================")
print("")
print("GitHub: deragena/MineGOOS")
print("")

local function downloadFile(path)
  local url = BASE .. path

  print("Downloading " .. path)

  local handle, reason = internet.request(url)

  if not handle then
    print("ERROR: " .. tostring(reason))
    return false
  end

  local directory = filesystem.path("/MineGOOS/" .. path)

  if directory then
    filesystem.makeDirectory(directory)
  end

  local file, err = io.open("/MineGOOS/" .. path, "w")

  if not file then
    print("ERROR: " .. tostring(err))
    return false
  end

  for chunk in handle do
    file:write(chunk)
  end

  file:close()

  print("OK")
  return true
end

filesystem.makeDirectory("/MineGOOS")

for _, path in ipairs(files) do
  if not downloadFile(path) then
    print("")
    print("Installation failed.")
    return
  end
end

print("")
print("================================")
print("     MineGOOS installed!")
print("================================")
print("")
print("Start with:")
print("lua /MineGOOS/init.lua")
