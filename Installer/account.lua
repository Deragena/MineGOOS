local component = require("component")
local event = require("event")
local gpu = component.gpu

local Account = {}

local w,h = gpu.getResolution()
local purple = 0xA77BFF
local white = 0xFFFFFF
local bg = 0x171326

local function draw(title, subtitle)
  gpu.setBackground(bg)
  gpu.setForeground(white)
  gpu.fill(1,1,w,h," ")

  gpu.setForeground(purple)
  gpu.set(math.floor(w/2)-7,3,"MINEGOOS SETUP")

  gpu.setForeground(white)
  gpu.set(math.floor(w/2)-10,6,title)

  gpu.setForeground(0xAAA5BD)
  gpu.set(math.floor(w/2)-15,8,subtitle)
end

local function input(label, secret)
  gpu.setForeground(white)
  gpu.set(4,11,label)

  gpu.setBackground(0x292238)
  gpu.fill(4,13,w-7,3," ")

  local value = ""

  while true do
    local e = {event.pull()}

    if e[1] == "key_down" then
      local char, code = e[3], e[4]

      if code == 28 then
        return value
      elseif code == 14 then
        value = value:sub(1,-2)
      elseif char and char >= 32 and char <= 126 then
        value = value .. string.char(char)
      end

      gpu.setBackground(0x292238)
      gpu.fill(4,13,w-7,3," ")
      gpu.setForeground(white)

      local shown = secret and string.rep("*",#value) or value
      gpu.set(5,14,shown:sub(1,w-9))
    end
  end
end

function Account.create()
  draw("Create your account","Enter your new system credentials")

  local username = input("Username:",false)

  if not username or not username:match("^[%w_-]+$") or #username < 3 then
    return nil,"Username must be at least 3 characters and use letters, numbers, _ or -."
  end

  draw("Create your account","Choose a password")
  local password = input("Password:",true)

  if #password < 8 then
    return nil,"Password must contain at least 8 characters."
  end

  draw("Confirm password","Enter the password again")
  local confirm = input("Confirm password:",true)

  if password ~= confirm then
    return nil,"Passwords do not match."
  end

  return {
    username = username,
    password = password
  }
end

return Account
