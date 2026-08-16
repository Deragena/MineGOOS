local component = require("component")
local Window = dofile("/MineGOOS/Libraries/Window.lua")
local WindowManager = dofile("/MineGOOS/System/WindowManager.lua")

local gpu = component.gpu
local w, h = gpu.getResolution()

gpu.setBackground(0x1E1E1E)
gpu.fill(1, 1, w, h, " ")

-- Верхняя панель
gpu.setBackground(0x333333)
gpu.fill(1, 1, w, 1, " ")

gpu.setForeground(0xFFFFFF)
gpu.set(2, 1, "MineGOOS")

-- Окна
local files = Window.create("Files", 5, 4, 35, 15)
local terminal = Window.create("Terminal", 15, 8, 40, 12)

WindowManager.add(files)
WindowManager.add(terminal)

WindowManager.draw()
WindowManager.run()
