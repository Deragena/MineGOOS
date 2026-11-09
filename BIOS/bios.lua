-- MineGOOS BIOS
-- Data Center Edition

local component = require("component")
local computer = require("computer")

local gpu = component.gpu

gpu.setBackground(0x080812)
gpu.setForeground(0xA970FF)
gpu.fill(1, 1, 80, 25, " ")

gpu.set(3, 2, "MineGOOS BIOS v1.0")
gpu.setForeground(0xFFFFFF)
gpu.set(3, 4, "Data Center Edition")
gpu.set(3, 7, "[POST] Checking hardware...")

local checks = {
    {"GPU", component.isAvailable("gpu")},
    {"Screen", component.isAvailable("screen")},
    {"Filesystem", component.isAvailable("filesystem")},
    {"EEPROM", component.isAvailable("eeprom")}
}

local y = 9

for _, item in ipairs(checks) do
    gpu.setForeground(item[2] and 0x55FF55 or 0xFF5555)
    gpu.set(3, y, item[1] .. ": " .. (item[2] and "OK" or "NOT FOUND"))
    y = y + 1
end

gpu.setForeground(0xA970FF)
gpu.set(3, 16, "Starting MineGOOS Bootloader...")

os.sleep(2)

local boot = "/Boot/boot.lua"

if not component.isAvailable("filesystem") then
    error("No filesystem available")
end

local fs = component.proxy(component.list("filesystem")())

if not fs.exists(boot) then
    error("MineGOOS bootloader not found")
end

local handle = fs.open(boot, "r")
local code = ""

while true do
    local data = fs.read(handle, math.huge)
    if not data then break end
    code = code .. data
end

fs.close(handle)

local fn, err = load(code, "=MineGOOS Bootloader")

if not fn then
    error(err)
end

fn()
