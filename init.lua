local filesystem = require("filesystem")
local LanguageManager = dofile("/MineGOOS/System/LanguageManager.lua")

local languageCode = LanguageManager.getLanguage()

if not languageCode then
  dofile("/MineGOOS/System/FirstSetup.lua")
  languageCode = LanguageManager.getLanguage()
end

local L = LanguageManager.loadLanguage(languageCode)local component = require("component")

local event = require("event")

local gpu = component.gpu

local w, h = gpu.getResolution()

gpu.setBackground(0x1E1E1E)
gpu.fill(1, 1, w, h, " ")

gpu.setBackground(0x333333)
gpu.fill(1, 1, w, 1, " ")

gpu.setForeground(0xFFFFFF)
gpu.set(2, 1, "MineGOOS 0.1")

gpu.set(3, 4, "[ Files ]")
gpu.set(3, 6, "[ Terminal ]")
gpu.set(3, 8, "[ Settings ]")

while true do
  local _, _, x, y = event.pull("touch")

  if y == 4 then
    gpu.set(20, 4, "Files")

  elseif y == 6 then
    gpu.set(20, 6, "Terminal")

  elseif y == 8 then
    gpu.set(20, 8, "Settings")
  end
end
