local component = require("component")
local event = require("event")
local internet = require("internet")

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"
local files = {"bios.lua", "eeprom.lua", "prepare.lua"}
local gpu = component.gpu

local disks = {}

for address in component.list("filesystem") do
  local fs = component.proxy(address)
  local ok, readonly = pcall(fs.isReadOnly)

  if ok and readonly == false then
    local label = "Disk " .. address:sub(1, 8)
    if fs.getLabel then
      local good, value = pcall(fs.getLabel)
      if good and value and value ~= "" then label = value end
    end
    disks[#disks + 1] = {fs = fs, label = label}
  end
end

if #disks == 0 then error("No writable disk found") end

local selected = 1

while true do
  local w, h = gpu.getResolution()
  gpu.setBackground(0x100D1C)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")
  gpu.set(2, 2, "MINEGOOS - DOWNLOAD BIOS")
  gpu.set(2, 4, "UP/DOWN: select  ENTER: continue  ESC: cancel")

  for i, disk in ipairs(disks) do
    gpu.setBackground(i == selected and 0x49316F or 0x211B35)
    gpu.fill(2, 6 + i * 2, w - 4, 1, " ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(4, 6 + i * 2, (i == selected and "> " or "  ") .. disk.label)
  end

  local _, _, char, key = event.pull("key_down")

  if key == 200 then
    selected = math.max(1, selected - 1)
  elseif key == 208 then
    selected = math.min(#disks, selected + 1)
  elseif key == 28 then
    break
  elseif char == 27 then
    return false
  end
end

local fs = disks[selected].fs
fs.makeDirectory("/BIOS")

for i, name in ipairs(files) do
  gpu.setBackground(0x100D1C)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, 80, 25, " ")
  gpu.set(2, 2, "Downloading BIOS: " .. name)

  local response, reason = internet.request(BASE .. "BIOS/" .. name)
  if not response then error("Download failed: " .. tostring(reason)) end

  local handle, err = fs.open("/BIOS/" .. name, "w")
  if not handle then error("Cannot write file: " .. tostring(err)) end

  local ok, problem = pcall(function()
    for chunk in response do
      fs.write(handle, chunk)
    end
  end)

  fs.close(handle)
  if not ok then error(tostring(problem)) end
end

gpu.setForeground(0x55DD99)
gpu.set(2, 6, "BIOS files downloaded successfully!")
gpu.setForeground(0xFFFFFF)
gpu.set(2, 8, "EEPROM was NOT changed.")
event.pull("key_down")

return true
