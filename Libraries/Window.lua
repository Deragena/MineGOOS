local component = require("component")

local gpu = component.gpu

local Window = {}

function Window.create(title, x, y, width, height)
  local win = {
    title = title,
    x = x,
    y = y,
    width = width,
    height = height,
    visible = true,
    dragging = false,
    dragX = 0,
    dragY = 0
  }

  function win:draw()
    if not self.visible then
      return
    end

