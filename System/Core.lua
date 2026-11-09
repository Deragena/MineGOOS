local Core = {}

function Core.boot()
  local ok, err = xpcall(function()
    dofile("/MineGOOS/System/Desktop.lua")
  end, debug.traceback)

  if not ok then
    local component = require("component")
    local gpu = component.gpu
    local w, h = gpu.getResolution()

    gpu.setBackground(0x200000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
    gpu.set(2, 2, "MineGOOS startup error:")
    gpu.set(2, 4, tostring(err):sub(1, w - 4))
  end
end

return Core
