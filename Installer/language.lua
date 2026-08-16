local component = require("component")
local event = require("event")

local gpu = component.gpu
local w, h = gpu.getResolution()

gpu.setBackground(0x101040)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")

gpu.set(3, 3, "MineGOOS Setup")
gpu.set(3, 5, "Select language / Выберите язык")

gpu.set(5, 8, "[ Русский ]")
gpu.set(5, 10, "[ English ]")

while true do
  local _, _, x, y = event.pull("touch")

  if y == 8 and x >= 5 and x <= 17 then
    return "ru"

  elseif y == 10 and x >= 5 and x <= 17 then
    return "en"
  end
end

