local component=require("component")
local gpu=component.gpu

local Window=dofile("/MineGOOS/Libraries/Window.lua")
local WM=dofile("/MineGOOS/System/WindowManager.lua")

local function drawDesktop()
  local w,h=gpu.getResolution()

  gpu.setBackground(0x17102B)
  gpu.setForeground(0xFFFFFF)
  gpu.set(3,1,"MINEGOOS")

  gpu.setForeground(0xC5B9E8)
  gpu.set(14,1,"Desktop")
  gpu.set(w-7,1,os.date("%H:%M"))

  gpu.setForeground(0xA77BFF)
  gpu.set(3,4,"YOUR UNIVERSE. YOUR SYSTEM.")

  gpu.setForeground(0xFFFFFF)
  gpu.set(3,7,"[ Files ]")
  gpu.set(3,9,"[ Terminal ]")
  gpu.set(3,11,"[ Settings ]")
  gpu.set(3,13,"[ Text Editor ]")

  gpu.setForeground(0xC5B9E8)
  if h>15 then
    gpu.set(3,h-2,"Select an application to open")
  end
end

local apps={
  Files={
    title="Files",
    path="/MineGOOS/Applications/FilesGUI.lua"
  },
  Terminal={
    title="Terminal",
    path="/MineGOOS/Applications/TerminalGUI.lua"
  },
  Settings={
    title="Settings",
    path="/MineGOOS/Applications/SettingsGUI.lua"
  },
  ["Text Editor"]={
    title="Text Editor",
    path="/MineGOOS/Applications/TextEditorGUI.lua"
  }
}

local function openApp(name)
  local info=apps[name]
  if not info then return end

  local ok,factory=pcall(dofile,info.path)
  if not ok then
    gpu.setForeground(0xFF6666)
    gpu.set(2,17,"App load error: "..tostring(factory):sub(1,30))
    return
  end

  local created,app=pcall(factory.create)
  if not created then
    gpu.setForeground(0xFF6666)
    gpu.set(2,17,"App start error: "..tostring(app):sub(1,30))
    return
  end

  local w,h=gpu.getResolution()
  local width=math.max(12,math.min(42,w-2))
  local height=math.max(5,math.min(17,h-2))
  local count=#WM.windows

  local win=Window.create(
    info.title,
    2+(count*2)%math.max(1,w-width-1),
    2+(count*2)%math.max(1,h-height-1),
    width,
    height
  )

  win.app=app

  win.content=function(self,x,y,cw,ch)
    if self.app and self.app.draw then
      self.app:draw(x,y,cw,ch)
    end
  end

  win.onTouch=function(self,tx,ty)
    if self.app and self.app.touch then
      self.app:touch(tx,ty,self.width-2,self.height-3)
    end
  end

  WM.add(win)
end

local function desktopTouch(x,y)
  if x>20 then return end

  if y==7 then
    openApp("Files")
  elseif y==9 then
    openApp("Terminal")
  elseif y==11 then
    openApp("Settings")
  elseif y==13 then
    openApp("Text Editor")
  end
end

WM.desktopDraw=drawDesktop
WM.run(desktopTouch)
