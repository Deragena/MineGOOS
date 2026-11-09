local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")

local gpu = component.gpu
local w, h = gpu.getResolution()

local function screen(title, message, color)
  gpu.setBackground(0x080820)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")

  gpu.setForeground(0x985CFF)
  gpu.set(3, 3, "MineGOOS Bootloader")

  gpu.setForeground(color or 0xFFFFFF)
  gpu.set(3, 6, title)

  gpu.setForeground(0xAAA4BD)
  gpu.set(3, 8, message)
end

local function halt()
  while true do
    computer.pullSignal()
  end
end

screen("Searching for MineGOOS...", "Checking connected disks.")

local root = filesystem.get("/")
local rootAddress = root and root.address
local found = false

filesystem.makeDirectory("/mnt")

local index = 0

for address in component.list("filesystem") do
  if address ~= rootAddress then
    index = index + 1

    local proxy = component.proxy(address)
    local temp = "/mnt/minegoos_scan_" .. index

    filesystem.makeDirectory(temp)

    local mounted = filesystem.mount(proxy, temp)

    if mounted then
      if filesystem.exists(temp .. "/init.lua") then
        filesystem.umount(temp)

        filesystem.makeDirectory("/MineGOOS")
        local ok, reason = filesystem.mount(proxy, "/MineGOOS")

        if ok then
          found = true
          break
        else
          screen("Mount error", tostring(reason), 0xFF6666)
          halt()
        end
      else
        filesystem.umount(temp)
      end
    end
  end
end

if not found then
  screen("System not found", "Connect the disk with MineGOOS installed.", 0xFF6666)
  halt()
end

screen("System disk found", "Starting MineGOOS...", 0x55DD99)
computer.pullSignal(1)

local ok, err = pcall(function()
  dofile("/MineGOOS/init.lua")
end)

if not ok then
  screen("Boot error", tostring(err), 0xFF6666)
  halt()
end
