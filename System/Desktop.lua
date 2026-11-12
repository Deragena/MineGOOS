local component = require("component")
local gpu = component.gpu

local Window = dofile("/MineGOOS/Libraries/Window.lua")
local WM = dofile("/MineGOOS/System/WindowManager.lua")

local w, h = gpu.getResolution()

local white = 0xFFFFFF
local muted = 0xC5B9E8
local purple = 0xA77BFF

local function drawDesktop()
  local sw, sh = gpu.getResolution()

  gpu.setBackground(0x17102B)
  gpu.setForeground(white)

  gpu.set(3, 1, "MINEGOOS")
  gpu.setForeground(muted)
  gpu.set(14, 1, "Desktop")
  gpu.set(w - 11, 1, os.date("%H:%M"))

  gpu.setForeground(purple)
  gpu.set(3, 4, "YOUR UNIVERSE. YOUR SYSTEM.")

  gpu.setForeground(white)
  gpu.set(3, 7, "[ Files ]")
  gpu.set(3, 9, "[ Terminal ]")
  gpu.set(3, 11, "[ Settings ]")
  gpu.set(3, 13, "[ Text Editor ]")

  gpu.setForeground(muted)
  gpu.set(3, sh - 3, "Click an icon to open an application")
end

local function openApp(name)
  local count = #WM.windows
  local width = math.min(42, w - 4)
  local height = math.min(16, h - 3)

  local win = Window.create(
    name,
    3 + (count * 2) % math.max(1, w - width - 2),
    3 + (count * 2) % math.max(1, h - height - 1),
    width,
    height
  )

  win.content = function(self, x, y, cw, ch)
    gpu.setForeground(purple)
    gpu.set(x, y, "MineGOOS Application")

    gpu.setForeground(white)
    gpu.set(x, y + 2, name .. " is running in a window.")

    gpu.setForeground(muted)
    gpu.set(x, y + 4, "Window system: ACTIVE")
    gpu.set(x, y + 5, "Application API: PREVIEW")

    gpu.set(x, y + 7, "Full application integration")
    gpu.set(x, y + 8, "will be added in the next stage.")
  end

  WM.add(win)
end

local function desktopTouch(x, y)
  if x > 20 then
    return
  end

  if y == 7 then
    openApp("Files")
  elseif y == 9 then
    openApp("Terminal")
  elseif y == 11 then
    openApp("Settings")
  elseif y == 13 then
    openApp("Text Editor")
  end
end

WM.desktopDraw = drawDesktop
WM.run(desktopTouch)
