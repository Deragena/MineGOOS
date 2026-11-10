local component = require("component")
local event = require("event")

local gpu = component.gpu
local selected = 1

local function draw()
  local w, h = gpu.getResolution()

  gpu.setBackground(0x080812)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")

  gpu.setForeground(0x985CFF)
  gpu.set(3, 2, "================================")
  gpu.set(3, 4, "          UPLOADLABS")
  gpu.set(3, 5, "================================")

  gpu.setForeground(0xAAA4BD)
  gpu.set(3, 8, "MineGOOS Games")

  local options = {
    "START GAME",
    "EXIT"
  }

  for i, option in ipairs(options) do
    local y = 11 + (i - 1) * 3

    gpu.setBackground(i == selected and 0x49316F or 0x211B35)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(3, y, w - 6, 2, " ")
    gpu.set(5, y, (i == selected and "> " or "  ") .. option)
  end

  gpu.setBackground(0x080812)
  gpu.setForeground(0x77718A)
  gpu.set(3, h - 2, "UP/DOWN: Select   ENTER: Confirm   ESC: Exit")
end

local function message(title, description)
  local w, h = gpu.getResolution()

  gpu.setBackground(0x080812)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")

  gpu.setForeground(0x985CFF)
  gpu.set(3, 4, title)

  gpu.setForeground(0xFFFFFF)
  gpu.set(3, 7, description)
  gpu.set(3, 10, "Press any key to return...")

  event.pull("key_down")
end

while true do
  draw()

  local e = {event.pull()}

  if e[1] == "key_down" then
    local key = e[4]

    if key == 200 then
      selected = selected - 1
      if selected < 1 then selected = 2 end

    elseif key == 208 then
      selected = selected + 1
      if selected > 2 then selected = 1 end

    elseif key == 28 then
      if selected == 1 then
        message("UPLOADLABS", "Game module is under development.")
      else
        break
      end

    elseif key == 1 then
      break
    end

  elseif e[1] == "touch" then
    local y = e[4]

    if y >= 11 and y <= 12 then
      message("UPLOADLABS", "Game module is under development.")
    elseif y >= 14 and y <= 15 then
      break
    end
  end
end

gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)

return true
