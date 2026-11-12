-- MineGOOS EEPROM Bootloader
local component = require("component")

local selected = nil

for address in component.list("filesystem") do
    local fs = component.proxy(address)

    if fs.exists("/BIOS/bios.lua") and fs.exists("/Boot/boot.lua") then
        selected = fs
        break
    end
end

if not selected then
    error("MineGOOS: BIOS or Bootloader not found")
end

local handle, err = selected.open("/BIOS/bios.lua", "r")
if not handle then
    error("Cannot open BIOS: " .. tostring(err))
end

local chunks = {}

while true do
    local data = selected.read(handle, 4096)
    if not data then break end
    chunks[#chunks + 1] = data
end

selected.close(handle)

local code = table.concat(chunks)
local bios, loadError = load(code, "=MineGOOS BIOS")

if not bios then
    error(loadError)
end

return bios()
