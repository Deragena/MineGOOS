local fs = require("filesystem")
local gpu = require("component").gpu
local App = {}

function App.create()
  local a = {
    cwd="/",
    input="",
    history={"MineGOOS Terminal"},
    message="Type help for commands"
  }

  local function add(self,text)
    table.insert(self.history,tostring(text))
    while #self.history>100 do table.remove(self.history,1) end
  end

  function a:execute(command)
    local args = {}
    for word in command:gmatch("%S+") do
      table.insert(args,word)
    end
    local cmd = args[1]

    if not cmd then return end

    if cmd=="help" then
      add(self,"help pwd ls cd cat mkdir touch echo date clear")
    elseif cmd=="pwd" then
      add(self,self.cwd)
    elseif cmd=="clear" then
      self.history={}
    elseif cmd=="date" then
      add(self,os.date("%Y-%m-%d %H:%M:%S"))
    elseif cmd=="echo" then
      add(self,command:sub(6))
    elseif cmd=="ls" then
      local path = args[2] and fs.concat(self.cwd,args[2]) or self.cwd
      local ok,iter = pcall(fs.list,path)
      if ok and iter then
        for name in iter do add(self,name) end
      else add(self,"Cannot list directory") end
    elseif cmd=="cd" then
      local target = args[2] or "/"
      local path = fs.canonical(fs.concat(self.cwd,target))
      if fs.isDirectory(path) then self.cwd=path
      else add(self,"Directory not found") end
    elseif cmd=="cat" then
      if not args[2] then add(self,"Usage: cat FILE")
      else
        local path=fs.concat(self.cwd,args[2])
        local f=io.open(path,"r")
        if f then
          local data=f:read("*a") or ""
          f:close()
          for line in (data.."\n"):gmatch("(.-)\n") do add(self,line) end
        else add(self,"File not found") end
      end
    elseif cmd=="mkdir" then
      if args[2] then
        local ok=pcall(fs.makeDirectory,fs.concat(self.cwd,args[2]))
        add(self,ok and "Directory created" or "Failed")
      else add(self,"Usage: mkdir NAME") end
    elseif cmd=="touch" then
      if args[2] then
        local f=io.open(fs.concat(self.cwd,args[2]),"a")
        if f then f:close(); add(self,"File created")
        else add(self,"Cannot create file") end
      else add(self,"Usage: touch NAME") end
    else
      add(self,"Unknown command: "..cmd)
      add(self,"Type help")
    end
  end

  function a:draw(x,y,w,h)
    local count=math.max(1,h-2)
    local first=math.max(1,#self.history-count+1)
    for i=first,#self.history do
      gpu.setForeground(0xC5B9E8)
      gpu.set(x,y+i-first,self.history[i]:sub(1,w))
    end

    gpu.setBackground(0x29213D)
    gpu.fill(x,y+h-1,w,1," ")
    gpu.setForeground(0xA8FFAA)
    gpu.set(x,y+h-1,("> "..self.cwd.." $ "..self.input):sub(1,w))
    gpu.setBackground(0x171326)
  end

  function a:touch() end

  function a:key(char,code)
    if char==13 then
      local command=self.input
      add(self,"> "..self.cwd.." $ "..command)
      self.input=""
      self:execute(command)
    elseif code==14 then
      self.input=self.input:sub(1,-2)
    elseif char and char>0 then
      local ok,symbol=pcall(require("unicode").char,char)
      if ok then self.input=self.input..symbol end
    end
  end

  return a
end

return App
