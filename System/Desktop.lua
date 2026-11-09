local component = require("component")
local event = require("event")
local computer = require("computer")

local gpu = component.gpu
local w, h = gpu.getResolution()

local running = true
local menu = false

local white = 0xFFFFFF
local muted = 0xC5B9E8
local purple = 0xA77BFF

local function rgb(r,g,b)
  return math.floor(r)*65536 + math.floor(g)*256 + math.floor(b)
end

local function mix(a,b,t)
  local ar = math.floor(a/65536)
  local ag = math.floor(a/256)%256
  local ab = a%256

  local br = math.floor(b/65536)
  local bg = math.floor(b/256)%256
  local bb = b%256

  return rgb(
    ar+(br-ar)*t,
    ag+(bg-ag)*t,
    ab+(bb-ab)*t
  )
end

local function gradient()
  local left = 0x241044
  local center = 0x6545B8
  local right = 0x103D65

  for x=1,w,2 do
    local t=x/w
    local color

    if t<0.5 then
      color=mix(left,center,t*2)
    else
      color=mix(center,right,(t-0.5)*2)
    end

    local dark=0.55+(0.45*(1-math.abs(t-0.5)*1.5))
    color=mix(0x080817,color,dark)

    gpu.setBackground(color)
    gpu.fill(x,1,math.min(2,w-x+1),h," ")
  end
end

local function text(x,y,str,color)
  gpu.setForeground(color or white)
  gpu.set(x,y,tostring(str))
end

local function panel(x,y,width,height,color)
  gpu.setBackground(color)
  gpu.fill(x,y,width,height," ")
end

local function app(name)
  local files = {
    ["Files"]="/MineGOOS/Applications/Files.lua",
    ["Terminal"]="/MineGOOS/Applications/Terminal.lua",
    ["Settings"]="/MineGOOS/Applications/Settings.lua",
    ["Text Editor"]="/MineGOOS/Applications/TextEditor.lua"
  }

  local path=files[name]
  if not path then return end

  local ok,err=pcall(dofile,path)

  if not ok then
    gpu.setBackground(0x241020)
    gpu.setForeground(white)
    gpu.fill(1,1,w,h," ")
    gpu.set(2,2,"Application error:")
    gpu.set(2,4,tostring(err):sub(1,w-4))
    event.pull(2)
  end
end

local function draw()
  gradient()

  -- Верхняя панель
  panel(1,1,w,2,0x171326)
  text(3,1,"✦ MineGOOS",purple)
  text(17,1,"Desktop",muted)
  text(w-12,1,os.date("%H:%M"),white)

  -- Центральная надпись
  text(math.max(2,math.floor(w/2)-8),math.floor(h*0.30),
       "WELCOME TO",muted)
  text(math.max(2,math.floor(w/2)-8),math.floor(h*0.30)+2,
       "MineGOOS",white)
  text(math.max(2,math.floor(w/2)-10),math.floor(h*0.30)+4,
       "Your universe. Your system.",muted)

  -- Ярлыки
  text(3,7,"[ Files ]",white)
  text(3,9,"[ Terminal ]",white)
  text(3,11,"[ Settings ]",white)
  text(3,13,"[ Text Editor ]",white)

  -- Нижний док
  panel(1,h-2,w,3,0x171326)
  panel(2,h-1,10,1,0x7044B8)
  text(4,h-1,"✦ ПУСК",white)
  text(math.floor(w/2)-5,h-1,"MINEGOOS",muted)
  text(w-12,h-1,"POWER",0xFFAAAA)
end

local function drawMenu()
  local y=math.max(3,h-12)

  panel(2,y,26,11,0x211A38)
  text(4,y+1,"MINEGOOS",purple)
  text(4,y+3,"Files",white)
  text(4,y+4,"Terminal",white)
  text(4,y+5,"Settings",white)
  text(4,y+6,"Text Editor",white)
  text(4,y+8,"Выключить ПК",0xFF8888)
  text(4,y+10,"ESC - закрыть",muted)
end

draw()

while running do
  local e={event.pull(0.5)}

  if e[1]=="key_down" then
    if e[4]==1 and menu then
      menu=false
      draw()
    end

  elseif e[1]=="touch" then
    local x,y=e[3],e[4]

    if menu then
      local top=math.max(3,h-12)

      if y==top+3 then
        menu=false
        draw()
        app("Files")
        draw()
      elseif y==top+4 then
        menu=false
        draw()
        app("Terminal")
        draw()
      elseif y==top+5 then
        menu=false
        draw()
        app("Settings")
        draw()
      elseif y==top+6 then
        menu=false
        draw()
        app("Text Editor")
        draw()
      elseif y==top+8 then
        computer.shutdown(false)
      elseif y==top+10 then
        menu=false
        draw()
      end

    elseif y>=h-2 and x<=12 then
      menu=true
      drawMenu()

    elseif y==7 and x<=18 then
      app("Files")
      draw()
    elseif y==9 and x<=18 then
      app("Terminal")
      draw()
    elseif y==11 and x<=18 then
      app("Settings")
      draw()
    elseif y==13 and x<=22 then
      app("Text Editor")
      draw()
    end
  end
end
