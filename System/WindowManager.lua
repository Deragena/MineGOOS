local event = require("event")
local component = require("component")
local gpu = component.gpu

local WM = {
  windows={},
  active=nil,
  desktopDraw=nil
}

function WM.add(window)
  table.insert(WM.windows,window)
  WM.active=window
  WM.draw()
end

function WM.remove(window)
  for i=#WM.windows,1,-1 do
    if WM.windows[i]==window then
      table.remove(WM.windows,i)
      break
    end
  end

  if WM.active==window then
    WM.active=WM.windows[#WM.windows]
  end
  WM.draw()
end

local function drawTaskbar()
  local w,h=gpu.getResolution()
  gpu.setBackground(0x100B1D)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1,h,w,1," ")
  gpu.setForeground(0xA66BFF)
  gpu.set(1,h,"MINEGOOS")

  local x=11
  for _,win in ipairs(WM.windows) do
    if win.visible then
      local label="["..win.title:sub(1,10).."]"
      gpu.setForeground(win.minimized and 0x888888 or 0xFFFFFF)
      if x+#label<=w then gpu.set(x,h,label) end
      x=x+#label+1
    end
  end
end

function WM.draw()
  local w,h=gpu.getResolution()
  gpu.setBackground(0x080612)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1,1,w,h," ")

  if WM.desktopDraw then pcall(WM.desktopDraw) end

  for _,win in ipairs(WM.windows) do
    if win.visible and not win.minimized then
      win:draw()
    end
  end

  drawTaskbar()
end

local function topWindow(x,y)
  for i=#WM.windows,1,-1 do
    local win=WM.windows[i]
    if win:contains(x,y) then return i,win end
  end
end

local function taskbarClick(x,y)
  local w,h=gpu.getResolution()
  if y~=h or x<11 then return false end

  local pos=11
  for i,win in ipairs(WM.windows) do
    if win.visible then
      local label="["..win.title:sub(1,10).."]"
      if x>=pos and x<pos+#label then
        win:restore()
        table.remove(WM.windows,i)
        table.insert(WM.windows,win)
        WM.active=win
        return true
      end
      pos=pos+#label+1
    end
  end
  return false
end

function WM.run(onDesktopTouch)
  WM.draw()

  while true do
    local e={event.pull()}
    local name=e[1]

    if name=="touch" then
      local x,y=e[3],e[4]

      if taskbarClick(x,y) then
        WM.draw()
      else
        local index,win=topWindow(x,y)

        if win then
          table.remove(WM.windows,index)
          table.insert(WM.windows,win)
          WM.active=win

          local action=win:handleTouch(x,y)

          if action=="close" then
            WM.remove(win)
          elseif action=="minimize" then
            WM.active=WM.windows[#WM.windows]
          end
          WM.draw()
        elseif onDesktopTouch then
          WM.active=nil
          pcall(onDesktopTouch,x,y)
          WM.draw()
        end
      end

    elseif name=="drag" then
      if WM.active then
        WM.active:handleDrag(e[3],e[4])
        WM.draw()
      end

    elseif name=="drop" then
      if WM.active then WM.active:stopDrag() end

    elseif name=="key_down" then
      local win=WM.active
      if win and win.visible and not win.minimized and win.app then
        if win.app.key then
          local ok,err=pcall(win.app.key,win.app,e[3],e[4])
          if not ok then win.app.message="Input error: "..tostring(err) end
        end
        WM.draw()
      end
    end
  end
end

return WM
