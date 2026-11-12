-- MineGOOS BIOS v1.1

local component = require("component")
local computer = require("computer")

local fs = nil

-- Find the filesystem containing the actual system bootloader
for address in component.list("filesystem") do
    local drive = component.proxy(address)

    if drive.exists("/Boot/boot.lua") then
        fs = drive
        break
    end
end

if not fs then
    error("MineGOOS: System disk not found")
end

-- Optional graphical POST
local gpuAddress = component.list("gpu")()
local screenAddress = component.list("screen")()

if gpuAddress and screenAddress then
    local gpu = component.proxy(gpuAddress)

    pcall(gpu.bind, screenAddress)

    local w, h = gpu.getResolution()
    gpu.setBackground(0x080812)
    gpu.setForeground(0xA970FF)
    gpu.fill(1, 1, w, h, " ")

    gpu.set(3, 2, "MineGOOS BIOS v1.1")
    gpu.setForeground(0xFFFFFF)
    gpu.set(3, 4, "Hardware POST")

    local checks = {
        {"GPU", component.list("gpu")() ~= nil},
        {"Screen", component.list("screen")() ~= nil},
        {"Filesystem", component.list("filesystem")() ~= nil},
        {"Bootloader", fs.exists("/Boot/boot.lua")}
    }

    local y = 7

    for _, item in ipairs(checks) do
        gpu.setForeground(item[2] and 0x55FF55 or 0xFF5555)
        gpu.set(3, y, item[1] .. ": " .. (item[2] and "OK" or "NOT FOUND"))
        y = y + 1
    end

    gpu.setForeground(0xA970FF)
    gpu.set(3, y + 1, "Starting MineGOOS...")
end

if os.sleep then os.sleep(2) end

-- Load the system bootloader
local handle, err = fs.open("/Boot/boot.lua", "r")

if not handle then
    error("Cannot open bootloader: " .. tostring(err))
end

local chunks = {}

while true do
    local data = fs.read(handle, 4096)
    if not data then break end
    chunks[#chunks + 1] = data
end

fs.close(handle)

local code = table.concat(chunks)
local boot, loadError = load(code, "=MineGOOS Bootloader")

if not boot then
    error("Bootloader error: " .. tostring(loadError))
end

return boot()
