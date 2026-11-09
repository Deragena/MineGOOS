local component = require("component")
local computer = require("computer")

local eeprom = component.proxy(component.list("eeprom")())
local fs = component.proxy(component.list("filesystem")())

local bootAddress = nil

for address in component.list("filesystem") do
    local drive = component.proxy(address)
    if drive.exists("/BIOS/bios.lua") then
        bootAddress = address
        break
    end
end

if not bootAddress then
    error("MineGOOS BIOS not found")
end

local drive = component.proxy(bootAddress)
local file = drive.open("/BIOS/bios.lua", "r")
local code = ""

while true do
    local chunk = drive.read(file, math.huge)
    if not chunk then break end
    code = code .. chunk
end

drive.close(file)

return assert(load(code, "=MineGOOS BIOS"))()
