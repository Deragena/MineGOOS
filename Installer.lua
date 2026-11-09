local component = require("component")
local event = require("event")
local computer = require("computer")

local gpu = component.gpu
local w, h = gpu.getResolution()

local C = {
  bg = 0x100D1C,
  purple = 0x985CFF,
  blue = 0x526BFF,
  white = 0xFFFFFF,
  gray = 0xAAA4BD,
  green = 0x55DD99,
  red = 0xFF6666
}

local function clear()
  gpu.setBackground(C.bg)
  gpu.setForeground(C.white)
  gpu.fill(1, 1, w, h, " ")
end

local function center(y, value, color)
  gpu.setForeground(color or C.white)
  gpu.set(value and math.max(1, math.floor((w - #value) / 2)) or 1, y, value or "")
end

local function button(x, y, width, label)
  gpu.setBackground(C.purple)
  gpu.setForeground(C.white)
  gpu.fill(x, y, width, 3, " ")
  gpu.set(x + 2, y + 1, label)
end

local function screen(title, subtitle)
  clear()
  gpu.setForeground(C.purple)
  gpu.set(2, 2, "MINEGOOS SETUP")
  gpu.setForeground(C.white)
  center(5, title)
  gpu.setForeground(C.gray)
  center(7, subtitle)
  gpu.setForeground(C.blue)
  gpu.fill(2, 9, w - 4, 1, " ")
end

local function waitForChoice()
  while true do
    local e = {event.pull()}
    if e[1] == "key_down" then
      if e[4] == 28 then return true end
      if e[4] == 1 then return false end
    elseif e[1] == "touch" then
      return true
    end
  end
end

screen("Welcome to MineGOOS", "Data-center operating system installer")
center(12, "This installer will download system files.")
center(14, "Make sure the computer has an Internet connection.", C.gray)
button(math.floor((w - 18) / 2), h - 5, 18, "START INSTALL")

if not waitForChoice() then return end

screen("Installing MineGOOS", "Downloading system files...")
center(12, "Please wait. Do not turn off the computer.", C.gray)

local ok, result = pcall(dofile, "/MineGOOS/Installer/install.lua")

clear()

if ok and result ~= false then
  center(5, "INSTALLATION FINISHED", C.green)
  center(8, "Installer engine completed.")
  center(10, "Restart the computer to continue.", C.gray)
else
  center(5, "INSTALLATION ERROR", C.red)
  center(8, tostring(result), C.white)
  center(10, "Check the Internet connection and installer files.", C.gray)
end

center(h - 3, "Press ENTER to exit", C.purple)

while true do
  local e = {event.pull("key_down")}
  if e[4] == 28 then break end
end
