local fs = require("filesystem")
local gpu = require("component").gpu

local App = {}

function App.create()
  local a = {path="/", entries={}, scroll=0, selected=1, message=""}

  function a:refresh()
    self.entries = {}
    if self.path ~= "/" then
      table.insert(self.entries, {name="..", dir=true, parent=true})
    end

    local ok, iter = pcall(fs.list, self.path)
    if ok and iter then
      for name in iter do
        local full = fs.concat(self.path, name)
        table.insert(self.entries, {
          name=name:gsub("/$", ""),
          dir=fs.isDirectory(full),
          full=full
        })
      end
    else
      self.message = "Cannot read directory"
    end

    table.sort(self.entries, function(x,y)
      if x.dir ~= y.dir then return x.dir end
      return x.name:lower() < y.name:lower()
    end)

    self.scroll = 0
    self.selected = 1
  end

  function a:open(index)
    local e = self.entries[index]
    if not e then return end

    if e.parent then
      self.path = fs.path(self.path)
      if self.path == "" then self.path = "/" end
    elseif e.dir then
      self.path = fs.concat(self.path, e.name)
    else
      self.message = "Selected: " .. e.name
      return
    end

    self.message = ""
    self:refresh()
  end

  function a:draw(x,y,w,h)
    gpu.setForeground(0xA77BFF)
    gpu.set(x,y,("PATH: "..self.path):sub(1,w))

    gpu.setForeground(0xC5B9E8)
    gpu.set(x,y+1,string.rep("-",w))

    local count = math.max(0,h-4)
    for n=1,count do
      local index = n+self.scroll
      local e = self.entries[index]
      if e then
        gpu.setBackground(index==self.selected and 0x49316B or 0x171326)
        gpu.fill(x,y+1+n,w,1," ")
        gpu.setForeground(e.dir and 0xC59AFF or 0xFFFFFF)
        local prefix = e.dir and "[DIR] " or "      "
        gpu.set(x,y+1+n,(prefix..e.name):sub(1,w))
      end
    end

    gpu.setBackground(0x29213D)
    gpu.fill(x,y+h-1,w,1," ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(x,y+h-1,"ENTER: Open  BACKSPACE: Up")

    if self.message ~= "" and h>3 then
      gpu.setBackground(0x171326)
      gpu.setForeground(0xFFAAAA)
      gpu.set(x,y+h-2,self.message:sub(1,w))
    end
    gpu.setBackground(0x171326)
  end

  function a:touch(tx,ty,w,h)
    local row = ty-1
    if row >= 1 and row <= h-4 then
      local index = row+self.scroll
      if self.entries[index] then
        self.selected = index
        self:open(index)
      end
    end
  end

  function a:key(char,code)
    if code == 200 then
      self.selected = math.max(1,self.selected-1)
    elseif code == 208 then
      self.selected = math.min(#self.entries,self.selected+1)
    elseif char == 13 then
      self:open(self.selected)
    elseif code == 14 then
      if self.path ~= "/" then
        self.path = fs.path(self.path)
        if self.path == "" then self.path = "/" end
        self:refresh()
      end
    elseif char == 117 then
      self.scroll = math.max(0,self.scroll-1)
    elseif char == 100 then
      self.scroll = math.min(math.max(0,#self.entries-1),self.scroll+1)
    end
  end

  a:refresh()
  return a
end

return App
