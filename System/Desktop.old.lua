local component = require("component")
local event = require("event")
local term = require("term")
local computer = require("computer")

local gpu = component.gpu
local w, h = gpu.getResolution()

local bg = 0x171525
local panel = 0x242238
local purple = 0x7547B8
local white = 0xFFFFFF
local muted = 0xAAA5BD

local running = true
local menu = false

local function fill(x,y,width,height,color)
  gpu.setBackground(color)
  gpu.fill(x,y,width,height," ")
end

local function text(x,y,value,color)
  gpu.setForeground(color or white)
  gpu.set(x,y,tostring(value))
end

local function desktop()
  gpu.setBackground(bg)
  gpu.setForeground(white)
  gpu.fill(1,1,w,h," ")

  text(3,3,"MineGOOS",0xB78AFF)
  text(3,5,"Your universe. Your system.",muted)

  text(3,8,"Applications",white)
  text(5,10,"[ Files ]",white)
  text(5,12,"[ Terminal ]",white)
  text(5,14,"[ Settings ]",white)
  text(5,16,"[ Text Editor ]",white)

  fill(1,h-1,w,2,panel)
  fill(1,h-1,9,2,purple)
  text(3,h,"[ ПУСК ]",white)

  text(w-16,h,os.date("%H:%M"),white)
end

local function startMenu()
  fill(2,h-12,27,11,panel)
  text(4,h-11,"MINEGOOS",0xB78AFF)
  text(4,h-9,"Files",white)
  text(4,h-8,"Terminal",white)
  text(4,h-7,"Text Editor",white)
  text(4,h-6,"Settings",white)
  text(4,h-4,"Выключить ПК",0xFF7777)
  text(4,h-2,"ESC - Закрыть",muted)
end

desktop()

while running do
  local e = {event.pull(0.5)}

  if e[1] == "key_down" then
    local key = e[4]

    if key == 1 then
      if menu then
        menu = false
        desktop()
      else
        running = false
      end
    end

  elseif e[1] == "touch" then
    local x,y = e[3],e[4]

    if menu then
      if y == h-4 and x >= 3 and x <= 25 then
        running = false
        computer.shutdown()
      elseif y == h-2 then
        menu = false
        desktop()
      end
    elseif y == h-1 and x <= 10 then
      menu = true
      startMenu()
    end
  end
end

gpu.setBackground(0x000000)
gpu.setForeground(white)
gpu.fill(1,1,w,h," ")
