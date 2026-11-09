-- MineGOOS startup

local post = dofile("/MineGOOS/BIOS/post.lua")

if post ~= true then
  return
end

local Core = dofile("/MineGOOS/System/Core.lua")
Core.boot()
