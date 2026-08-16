local filesystem = require("filesystem")
local shell = require("shell")
local internet = require("internet")

local repo = "https://raw.githubusercontent.com/USERNAME/MineGOOS/main/"

print("================================")
print("      MineGOOS Installer")
print("================================")
print("")
print("Installing MineGOOS...")

local function download(url, path)
  io.write("Downloading: " .. path .. "... ")

  local handle, reason = internet.request(url)

  if not handle then
    print("FAILED")
    print(reason or "Unknown error")
    return false
  end

  local file = io.open(path, "w")

  for chunk in handle do
    file:write(chunk)
  end

  file:close()
  print("OK")
  return true
end

filesystem.makeDirectory("/MineGOOS")
filesystem.makeDirectory("/MineGOOS/System")
filesystem.makeDirectory("/MineGOOS/Applications")
filesystem.makeDirectory("/MineGOOS/Libraries")

download(repo .. "init.lua", "/MineGOOS/init.lua")

print("")
print("MineGOOS installed!")
print("Start with:")
print("lua /MineGOOS/init.lua")
