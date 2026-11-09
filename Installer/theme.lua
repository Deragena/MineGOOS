local component = require("component")
local gpu = component.gpu

local Theme = {
  background = 0x11101C,
  panel = 0x211B35,
  purple = 0x9B6DFF,
  blue = 0x536DFF,
  white = 0xFFFFFF,
  muted = 0xAAA4BD,
  green = 0x65D6A0
}

function Theme.clear()
  local w, h = gpu.getResolution()
  gpu.setBackground(Theme.background)
  gpu.setForeground(Theme.white)
  gpu.fill(1, 1, w, h, " ")
end

function Theme.header(title, subtitle)
  local w = gpu.getResolution()
  gpu.setBackground(Theme.background)
  gpu.setForeground(Theme.purple)
  gpu.set(2, 2, "MINEGOOS INSTALLER")
  gpu.setForeground(Theme.white)
  gpu.set(2, 4, title)
  gpu.setForeground(Theme.muted)
  gpu.set(2, 5, subtitle)
  gpu.setForeground(Theme.blue)
  gpu.fill(2, 7, w - 2, 1, "━")
end

function Theme.panel(x, y, width, height)
  gpu.setBackground(Theme.panel)
  gpu.fill(x, y, width, height, " ")
end

function Theme.button(x, y, width, label, active)
  gpu.setBackground(active and Theme.purple or Theme.panel)
  gpu.setForeground(Theme.white)
  gpu.fill(x, y, width, 3, " ")
  gpu.set(x + 2, y + 1, label)
end

function Theme.progress(step, total)
  local w = gpu.getResolution()
  local width = math.min(w - 4, 40)
  local filled = math.floor(width * step / total)

  gpu.setBackground(Theme.panel)
  gpu.fill(2, 8, width, 1, " ")
  gpu.setBackground(Theme.purple)
  if filled > 0 then
    gpu.fill(2, 8, filled, 1, " ")
  end
end

return Theme
