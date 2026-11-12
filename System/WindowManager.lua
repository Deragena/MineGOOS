local event = require("event")
local component = require("component")
local gpu = component.gpu

local WindowManager = {
  windows = {},
  active = nil
}

function WindowManager.add(window)
  table.insert(WindowManager.windows, window)
  WindowManager.draw()
end

function WindowManager.remove(window)
  for i = #WindowManager.windows, 1, -1 do
    if WindowManager.windows[i] == window then
      table.remove(WindowManager.windows, i)
      break
    end
  end

  if WindowManager.active == window then
    WindowManager.active = nil
  end

  WindowManager.draw()
end

local function drawTaskbar()
  local w, h = gpu.getResolution()

  gpu.setBackground(0x100B1D)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, h, w, 1, " ")

  gpu.setForeground(0xA66BFF)
  gpu.set(1, h, "MINEGOOS")

  local x = 11

  for _, window in ipairs(WindowManager.windows) do
    if window.visible then
      local name = window.title:sub(1, 10)
      local label = "[" .. name .. "]"

      if window.minimized then
        gpu.setForeground(0xAAAAAA)
      else
        gpu.setForeground(0xFFFFFF)
      end

      if x + #label <= w then
        gpu.set(x, h, label)
      end

      x = x + #label + 1
    end
  end
end

function WindowManager.draw()
  local w, h = gpu.getResolution()

  gpu.setBackground(0x080612)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")

  for _, window in ipairs(WindowManager.windows) do
    if window.visible and not window.minimized then
      window:draw()
    end
  end

  drawTaskbar()
end

local function topWindow(x, y)
  for i = #WindowManager.windows, 1, -1 do
    local window = WindowManager.windows[i]

    if window:contains(x, y) then
      return i, window
    end
  end

  return nil
end

local function taskbarClick(x, y)
  local w, h = gpu.getResolution()

  if y ~= h or x < 11 then
    return false
  end

  local pos = 11

  for _, window in ipairs(WindowManager.windows) do
    if window.visible then
      local label = "[" .. window.title:sub(1, 10) .. "]"

      if x >= pos and x < pos + #label then
        if window.minimized then
          window:restore()
        end

        WindowManager.active = window

        return true
      end

      pos = pos + #label + 1
    end
  end

  return false
end

function WindowManager.run()
  WindowManager.draw()

  while true do
    local name, _, x, y = event.pull()

    if name == "touch" then
      if taskbarClick(x, y) then
        WindowManager.draw()
      else
        local index, window = topWindow(x, y)

        if window then
          table.remove(WindowManager.windows, index)
          table.insert(WindowManager.windows, window)

          WindowManager.active = window

          local action = window:handleTouch(x, y)

          if action == "close" then
            WindowManager.remove(window)
          elseif action == "minimize" then
            WindowManager.active = nil
          end

          WindowManager.draw()
        end
      end

    elseif name == "drag" then
      if WindowManager.active then
        WindowManager.active:handleDrag(x, y)
        WindowManager.draw()
      end

    elseif name == "drop" then
      if WindowManager.active then
        WindowManager.active:stopDrag()
        WindowManager.active = nil
      end
    end
  end
end

return WindowManager
