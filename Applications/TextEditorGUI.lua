local gpu = require("component").gpu
local unicode = require("unicode")
local App = {}

function App.create()
  local a = {
    path="/MineGOOS/notes.txt",
    content="",
    message="",
    cursor=0
  }

  local f = io.open(a.path,"r")
  if f then
    a.content = f:read("*a") or ""
    f:close()
  end
  a.cursor = unicode.len(a.content)

  function a:save()
    local file = io.open(self.path,"w")
    if not file then
      self.message = "Save failed"
      return
    end
    file:write(self.content)
    file:close()
    self.message = "Saved: "..self.path
  end

  function a:draw(x,y,w,h)
    gpu.setForeground(0xA77BFF)
    gpu.set(x,y,("File: "..self.path):sub(1,w))

    gpu.setForeground(0xC5B9E8)
    gpu.set(x,y+1,string.rep("-",w))

    local lines = {}
    for line in (self.content.."\n"):gmatch("(.-)\n") do
      table.insert(lines,line)
    end

    for i=1,math.min(#lines,h-4) do
      gpu.setForeground(0xFFFFFF)
      gpu.set(x,y+1+i,lines[i]:sub(1,w))
    end

    gpu.setBackground(0x29213D)
    gpu.fill(x,y+h-1,w,1," ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(x,y+h-1,"CTRL+S: Save | ESC: Close")

    if self.message ~= "" and h>3 then
      gpu.setBackground(0x171326)
      gpu.setForeground(0xA8FFAA)
      gpu.set(x,y+h-2,self.message:sub(1,w))
    end
    gpu.setBackground(0x171326)
  end

  function a:touch() end

  function a:key(char,code)
    if char == 19 then
      self:save()
    elseif code == 14 then
      local n = unicode.len(self.content)
      if n>0 then
        self.content = unicode.sub(self.content,1,n-1)
      end
      self.message = ""
    elseif char == 13 then
      self.content = self.content.."\n"
      self.message = ""
    elseif char and char>0 then
      local ok, symbol = pcall(unicode.char,char)
      if ok then
        self.content = self.content..symbol
        self.message = ""
      end
    end
  end

  return a
end

return App
