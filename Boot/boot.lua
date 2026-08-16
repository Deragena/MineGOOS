local component = require("component")
local computer = require("computer")

local gpu = component.gpu

local w, h = gpu.getResolution()

gpu.setBackground(0x080820)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")

gpu.set(3, 3, "MineGOOS Bootloader")
gpu.set(3, 5, "Checking system...")

if component.isAvailable("filesystem") then
  gpu.set(3, 7, "System disk found.")
  gpu.set(3, 9, "Starting MineGOOS...")
else
  gpu.set(3, 7, "No system disk found.")
  gpu.set(3, 9, "Insert MineGOOS disk.")
  while true do
    computer.pullSignal()
  end
end

computer.pullSignal(1)

local ok, err = pcall(function()
  dofile("/MineGOOS/init.lua")
end)

if not ok then
  gpu.set(3, 11, "Boot error:")
  gpu.set(3, 12, tostring(err))
  while true do
    computer.pullSignal()
  end
end
