local component = require("component")
local event = require("event")

local gpu = component.gpu
local w, h = gpu.getResolution()

local bg = 0x171525
local panel = 0x29243D
local purple = 0x8755D9
local white = 0xFFFFFF

local path = "/MineGOOS/notes.txt"
local content = ""
local cursor = 1

local function draw()
  gpu.setBackground(bg)
  gpu.setForeground(white)
  gpu.fill(1, 1, w, h, " ")

  gpu.setBackground(panel)
  gpu.fill(1, 1, w, 2, " ")
  gpu.setForeground(purple)
  gpu.set(2, 1, "MineGOOS Text Editor")

  gpu.setForeground(white)
  gpu.set(2, 3, "File: " .. path)
  gpu.set(2, 5, "Text:")

  local lines = {}
  for line in (content .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = line
  end

  for i = 1, math.min(#lines, h - 9) do
    gpu.set(3, 5 + i, lines[i]:sub(1, w - 5))
  end

  gpu.setBackground(purple)
  gpu.fill(1, h - 1, w, 2, " ")
  gpu.setForeground(white)
  gpu.set(2, h, "CTRL+S Save | ESC Exit")
end

local function save()
  local file = io.open(path, "w")
  if not file then return false end
  file:write(content)
  file:close()
  return true
end

local file = io.open(path, "r")
if file then
  content = file:read("*a") or ""
  file:close()
end

draw()

while true do
  local e = {event.pull()}
  if e[1] == "key_down" then
    local char, code = e[3], e[4]

    if code == 1 then
      break
    elseif char == 19 then
      save()
      draw()
    elseif char and char > 0 then
      content = content .. unicode.char(char)
      draw()
    end
  end
end

gpu.setBackground(bg)
gpu.fill(1, 1, w, h, " ")
