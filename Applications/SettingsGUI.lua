local fs = require("filesystem")
local gpu = require("component").gpu
local App = {}

function App.create()
  local a = {language="en",message="Choose interface language"}

  local config = "/MineGOOS/Config/language.cfg"
  local f = io.open(config,"r")
  if f then
    a.language = f:read("*l") or "en"
    f:close()
  end

  function a:setLanguage(code)
    fs.makeDirectory("/MineGOOS/Config")
    local file = io.open(config,"w")
    if file then
      file:write(code)
      file:close()
      self.language = code
      self.message = "Language saved"
    else
      self.message = "Cannot save settings"
    end
  end

  function a:draw(x,y,w,h)
    gpu.setForeground(0xA77BFF)
    gpu.set(x,y,"MINEGOOS SETTINGS")

    gpu.setForeground(0xFFFFFF)
    gpu.set(x,y+2,"Interface language:")

    gpu.setBackground(self.language=="ru" and 0x59328A or 0x29213D)
    gpu.fill(x,y+4,math.min(w,18),1," ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(x+1,y+4,"[1] Русский")

    gpu.setBackground(self.language=="en" and 0x59328A or 0x29213D)
    gpu.fill(x,y+6,math.min(w,18),1," ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(x+1,y+6,"[2] English")

    gpu.setBackground(0x171326)
    gpu.setForeground(0xC5B9E8)
    gpu.set(x,y+8,"Current: "..self.language)
    gpu.setForeground(0xA8FFAA)
    gpu.set(x,y+10,self.message:sub(1,w))
    gpu.setForeground(0xFFFFFF)
    gpu.set(x,y+h-1,"Press 1 or 2 to change")
  end

  function a:touch(tx,ty)
    if ty==4 then self:setLanguage("ru")
    elseif ty==6 then self:setLanguage("en") end
  end

  function a:key(char)
    if char==49 then self:setLanguage("ru")
    elseif char==50 then self:setLanguage("en") end
  end

  return a
end

return App
