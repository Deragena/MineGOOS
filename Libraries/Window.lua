local component = require("component")
local gpu = component.gpu

local Window = {}

function Window.create(title, x, y, width, height)
  local win = {
    title = title or "Window",
    x = x or 2,
    y = y or 2,
    width = width or 34,
    height = height or 14,

    visible = true,
    minimized = false,
    dragging = false,

    dragX = 0,
    dragY = 0,

    background = 0x171326,
    foreground = 0xFFFFFF,
    titleColor = 0x59328A,

    content = nil,
    onTouch = nil
  }

  function win:draw()
    if not self.visible or self.minimized then
      return
    end

    local sw, sh = gpu.getResolution()

    self.width = math.max(12, math.min(self.width, sw))
    self.height = math.max(5, math.min(self.height, sh - 1))

    self.x = math.max(1, math.min(self.x, sw - self.width + 1))
    self.y = math.max(1, math.min(self.y, sh - self.height))

    gpu.setBackground(self.background)
    gpu.setForeground(self.foreground)
    gpu.fill(self.x, self.y, self.width, self.height, " ")

    gpu.setBackground(self.titleColor)
    gpu.fill(self.x, self.y, self.width, 1, " ")

    gpu.setForeground(0xFFFFFF)
    gpu.set(self.x + 1, self.y, self.title:sub(1, self.width - 9))
    gpu.set(self.x + self.width - 5, self.y, "_")
    gpu.set(self.x + self.width - 2, self.y, "X")

    if self.content then
      gpu.setBackground(self.background)
      gpu.setForeground(self.foreground)

      local ok, err = pcall(
        self.content,
        self,
        self.x + 1,
        self.y + 2,
        self.width - 2,
        self.height - 3
      )

      if not ok then
        gpu.setForeground(0xFF6666)
        gpu.set(self.x + 1, self.y + 2, "App error:")
        gpu.set(self.x + 1, self.y + 3, tostring(err):sub(1, self.width - 3))
      end
    end
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

    if self.onTouch then
      local ok, result = pcall(
        self.onTouch,
        self,
        px - self.x - 1,
        py - self.y - 2
      )

      if ok then
        return result
      end
    end

    return true
  end

  function win:handleDrag(px, py)
    if not self.dragging then
      return false
    end

    self.x = px - self.dragX
    self.y = py - self.dragY
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
  end

  function win:move(newX, newY)
    self.x = newX
    self.y = newY
  end

  return win
end

return Window
