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
    minimized = false,
    dragging = false,

    dragX = 0,
    dragY = 0,

    background = 0x171326,
    foreground = 0xFFFFFF,
    titleColor = 0x59328A
  }

  function win:draw()
    if not self.visible or self.minimized then return end

    local sw, sh = gpu.getResolution()

    self.width = math.min(self.width, sw)
    self.height = math.min(self.height, sh - 1)

    self.x = math.max(1, math.min(self.x, sw - self.width + 1))
    self.y = math.max(1, math.min(self.y, sh - self.height))

    gpu.setBackground(self.background)
    gpu.setForeground(self.foreground)

    gpu.fill(
      self.x,
      self.y,
      self.width,
      self.height,
      " "
    )

    gpu.setBackground(self.titleColor)
    gpu.fill(self.x, self.y, self.width, 1, " ")

    gpu.setForeground(0xFFFFFF)

    local title = " " .. self.title
    gpu.set(self.x, self.y, title:sub(1, self.width - 7))

    gpu.set(self.x + self.width - 5, self.y, "_")
    gpu.set(self.x + self.width - 2, self.y, "X")

    gpu.setBackground(self.background)
    gpu.setForeground(self.foreground)

    gpu.set(
      self.x,
      self.y + self.height - 1,
      string.rep("-", self.width)
    )
  end

  function win:contains(px, py)
    return self.visible
      and not self.minimized
      and px >= self.x
      and px < self.x + self.width
      and py >= self.y
      and py < self.y + self.height
  end

  function win:handleTouch(px, py)
    if not self:contains(px, py) then
      return false
    end

    if py == self.y then
      if px == self.x + self.width - 2 then
        self:close()
        return "close"
      end

      if px == self.x + self.width - 5 then
        self:minimize()
        return "minimize"
      end

      self.dragging = true
      self.dragX = px - self.x
      self.dragY = py - self.y

      return "drag"
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

  function win:minimize()
    self.minimized = true
    self.dragging = false
  end

  function win:restore()
    self.minimized = false
    self.visible = true
  end

  function win:close()
    self.visible = false
    self.minimized = false
    self.dragging = false
  end

  function win:show()
    self.visible = true
    self.minimized = false
    self:draw()
  end

  function win:move(newX, newY)
    self.x = newX
    self.y = newY
    self:draw()
  end

  return win
end

return Window
