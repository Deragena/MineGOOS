local GUI = {}

function GUI.clear(gpu)
  local w, h = gpu.getResolution()
  gpu.fill(1, 1, w, h, " ")
end

function GUI.desktop(gpu)
  local w, h = gpu.getResolution()

  gpu.setBackground(0x1E1E1E)
  gpu.fill(1, 1, w, h, " ")

  gpu.setBackground(0x333333)
  gpu.fill(1, 1, w, 1, " ")

  gpu.setForeground(0xFFFFFF)
  gpu.set(2, 1, "MineGOOS 0.1")
end

return GUI
