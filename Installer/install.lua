local component = require("component")
local event = require("event")
local filesystem = require("filesystem")

local gpu = component.gpu
local w, h = gpu.getResolution()

local function screen()
  gpu.setBackground(0x101040)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")
end

screen()

gpu.set(3, 3, "MineGOOS Setup")
gpu.set(3, 5, "Installing MineGOOS...")
gpu.set(3, 7, "Checking disk...")

local disk
local freeSpace = 0

for address in component.list("filesystem") do
  local fs = component.proxy(address)

  if fs.getCapacity() - fs.getUsedSpace() >= 2 * 1024 * 1024 then
    disk = fs
    freeSpace = fs.getCapacity() - fs.getUsedSpace()
    break
  end
end

if not disk then
  gpu.set(3, 9, "ERROR: Not enough disk space!")
  gpu.set(3, 10, "Required: 2 MB free")
  gpu.set(3, 12, "[ Retry ]")

  while true do
    local _, _, _, y = event.pull("touch")

    if y == 12 then
      return false
    end
  end
end

gpu.set(3, 9, "Disk OK")
gpu.set(3, 11, "Free space: " .. math.floor(freeSpace / 1024) .. " KB")

filesystem.makeDirectory("/MineGOOS")

gpu.set(3, 13, "Installing files...")
gpu.set(3, 15, "[####################] 100%")

event.pull("key_down")

return true
