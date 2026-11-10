local component = require("component")
local gpu = component.gpu

local Window = {}

function Window.create(title, x, y, width, height)
  local win = {
    title = title or "Window",
    x = x or 2,
    y = y or 2,
    width = width or 30,
    height = height or 12,
    visible = true,
    dragging = false,
    dragX = 0,
    dragY = 0,
    background = 0x171326,
    foreground = 0xFFFFFF,
    titleColor = 0x985CFF
  }

  function win:draw()
    if not self.visible then return end

    local w, h = gpu.getResolution()

    local x1 = math.max(1, self.x)
    local y1 = math.max(1, self.y)
    local x2 = math.min(w, self.x + self.width - 1)
    local y2 = math.min(h, self.y + self.height - 1)

    if x1 > x2 or y1 > y2 then return end

    gpu.setBackground(self.background)
    gpu.setForeground(self.foreground)
    gpu.fill(x1, y1, x2 - x1 + 1, y2 - y1 + 1, " ")

    gpu.setBackground(self.titleColor)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(x1, y1, x2 - x1 + 1, 1, " ")

    local title = " " .. self.title
    gpu.set(x1, y1, title:sub(1, math.max(1, x2 - x1 - 3)))

    if x2 - x1 >= 2 then
      gpu.set(x2 - 1, y1, "X")
    end

    gpu.setBackground(self.background)
    gpu.setForeground(self.foreground)

    if y2 - y1 >= 2 then
      gpu.set(x1, y2, string.rep("-", x2 - x1 + 1))
    end
  end

  function win:close()
    self.visible = false
  end

  function win:show()
    self.visible = true
    self:draw()
  end

  function win:move(newX, newY)
    self.x = newX
    self.y = newY
    self:draw()
  end

  function win:contains(px, py)
    return px >= self.x
      and px < self.x + self.width
      and py >= self.y
      and py < self.y + self.height
  end

  function win:handleTouch(px, py)
    if not self.visible or not self:contains(px, py) then
      return false
    end

    if py == self.y and px == self.x + self.width - 2 then
      self:close()
      return true
    end

    if py == self.y then
      self.dragging = true
      self.dragX = px - self.x
      self.dragY = py - self.y
    end

    return true
  end

  function win:handleDrag(px, py)
    if not self.dragging then return false end

    self.x = px - self.dragX
    self.y = py - self.dragY
    self:draw()

    return true
  end

  function win:stopDrag()
    self.dragging = false
  end

  return win
end

return Window
