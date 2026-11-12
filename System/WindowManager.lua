local event = require("event")

local WindowManager = {
  windows = {},
  active = nil
}

function WindowManager.add(window)
  table.insert(WindowManager.windows, window)
end

function WindowManager.remove(window)
  for i = #WindowManager.windows, 1, -1 do
    if WindowManager.windows[i] == window then
      table.remove(WindowManager.windows, i)
    end
  end

  if WindowManager.active == window then
    WindowManager.active = nil
  end
end

function WindowManager.draw()
  for _, window in ipairs(WindowManager.windows) do
    if window.visible then
      window:draw()
    end
  end
end

local function topWindow(x, y)
  for i = #WindowManager.windows, 1, -1 do
    local window = WindowManager.windows[i]

    if window.visible and window:contains(x, y) then
      return i, window
    end
  end

  return nil
end

function WindowManager.run()
  while true do
    local name, _, x, y = event.pull()

    if name == "touch" then
      local index, window = topWindow(x, y)

      if window then
        table.remove(WindowManager.windows, index)
        table.insert(WindowManager.windows, window)

        WindowManager.active = window
        window:handleTouch(x, y)

        if not window.visible then
          WindowManager.active = nil
        end

        WindowManager.draw()
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
