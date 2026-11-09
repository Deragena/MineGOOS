local component = require("component")
local computer = require("computer")
local event = require("event")

local gpu = component.gpu
local w, h = gpu.getResolution()

local colors = {
  bg = 0x080820,
  purple = 0x985CFF,
  white = 0xFFFFFF,
  green = 0x55DD99,
  red = 0xFF6666,
  gray = 0xAAA4BD
}

local function clear()
  gpu.setBackground(colors.bg)
  gpu.setForeground(colors.white)
  gpu.fill(1, 1, w, h, " ")
end

local function line(y, name, status, ok)
  gpu.setForeground(colors.white)
  gpu.set(3, y, name)

  gpu.setForeground(ok and colors.green or colors.red)
  gpu.set(math.max(25, w - 12), y, status)
end

local function run()
  clear()

  gpu.setForeground(colors.purple)
  gpu.set(3, 2, "MINEGOOS BIOS")
  gpu.setForeground(colors.white)
  gpu.set(3, 4, "POWER-ON SELF TEST")
  gpu.setForeground(colors.gray)
  gpu.set(3, 5, "Hardware diagnostics")

  gpu.setForeground(colors.purple)
  gpu.fill(3, 7, w - 6, 1, "=")

  local gpuOK = component.isAvailable("gpu")
  line(9, "Graphics adapter", gpuOK and "PASS" or "FAIL", gpuOK)

  local total = computer.totalMemory()
  local free = computer.freeMemory()
  local memoryOK = total > 0

  line(11, "Memory", memoryOK and "PASS" or "FAIL", memoryOK)

  gpu.setForeground(colors.gray)
  gpu.set(5, 12, "Total: " .. math.floor(total / 1024) .. " KB")
  gpu.set(5, 13, "Free:  " .. math.floor(free / 1024) .. " KB")

  local disks = 0
  for _ in component.list("filesystem") do
    disks = disks + 1
  end

  line(15, "Storage devices", disks > 0 and "PASS" or "FAIL", disks > 0)

  gpu.setForeground(colors.gray)
  gpu.set(5, 16, "Detected: " .. disks)

  local internetOK = component.isAvailable("internet")
  line(18, "Internet adapter", internetOK and "FOUND" or "NOT FOUND", internetOK)

  local passed = gpuOK and memoryOK and disks > 0

  gpu.setForeground(colors.purple)
  gpu.fill(3, 20, w - 6, 1, "=")

  if passed then
    gpu.setForeground(colors.green)
    gpu.set(3, 22, "POST PASSED")
    gpu.setForeground(colors.white)
    gpu.set(3, 24, "Starting bootloader...")
  else
    gpu.setForeground(colors.red)
    gpu.set(3, 22, "POST FAILED")
    gpu.setForeground(colors.white)
    gpu.set(3, 24, "Check the hardware above.")
    gpu.set(3, 26, "Press any key to stop.")
    event.pull("key_down")
    return false
  end

  event.pull(2)
  return true
end

return run()
