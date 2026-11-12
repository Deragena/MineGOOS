-- MineGOOS EEPROM Installer
local component = require("component")
local event = require("event")

local eepromAddress = component.list("eeprom")()
if not eepromAddress then
    error("EEPROM not found")
end

local eeprom = component.proxy(eepromAddress)
local selectedFS = nil

-- Find the disk containing the complete system
for address in component.list("filesystem") do
    local fs = component.proxy(address)

    if fs.exists("/BIOS/eeprom.lua")
        and fs.exists("/BIOS/bios.lua")
        and fs.exists("/Boot/boot.lua") then
        selectedFS = fs
        break
    end
end

if not selectedFS then
    error("Complete MineGOOS installation not found")
end

local function readFile(fs, path)
    local handle, err = fs.open(path, "r")
    if not handle then return nil, err end

    local chunks = {}

    while true do
        local data = fs.read(handle, 4096)
        if not data then break end
        chunks[#chunks + 1] = data
    end

    fs.close(handle)
    return table.concat(chunks)
end

local newCode, err = readFile(selectedFS, "/BIOS/eeprom.lua")
if not newCode then
    error("Cannot read EEPROM loader: " .. tostring(err))
end

local limit = eeprom.getSize()

if #newCode > limit then
    error("EEPROM limit exceeded: " .. #newCode .. "/" .. limit)
end

local oldCode = eeprom.get()

if type(oldCode) ~= "string" then
    error("Cannot read existing EEPROM firmware")
end

-- Create a backup before changing EEPROM
local backupPath = "/BIOS/eeprom-backup.lua"
local n = 1

while selectedFS.exists(backupPath) do
    backupPath = "/BIOS/eeprom-backup-" .. n .. ".lua"
    n = n + 1
end

local backup, backupError = selectedFS.open(backupPath, "w")
if not backup then
    error("Cannot create backup: " .. tostring(backupError))
end

local written, writeError = selectedFS.write(backup, oldCode)
selectedFS.close(backup)

if written == false then
    error("Backup write failed: " .. tostring(writeError))
end

-- Confirmation screen
local gpuAddress = component.list("gpu")()
if not gpuAddress then error("GPU not found") end

local gpu = component.proxy(gpuAddress)
local w, h = gpu.getResolution()

gpu.setBackground(0x100D1C)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")

gpu.setForeground(0xA970FF)
gpu.set(2, 2, "MINEGOOS EEPROM INSTALL")

gpu.setForeground(0xFFFFFF)
gpu.set(2, 4, "Loader: " .. #newCode .. "/" .. limit)
gpu.set(2, 5, "Backup: " .. backupPath)
gpu.set(2, 7, "Press Y to install.")
gpu.set(2, 8, "Any other key cancels.")

local _, _, char = event.pull("key_down")

if char ~= 89 and char ~= 121 then
    gpu.set(2, 10, "Cancelled. EEPROM unchanged.")
    event.pull("key_down")
    return false
end

local ok, problem = pcall(eeprom.set, newCode)

if not ok then
    error("EEPROM write failed: " .. tostring(problem))
end

if eeprom.get() ~= newCode then
    pcall(eeprom.set, oldCode)
    error("Verification failed. Restore was attempted.")
end

gpu.setForeground(0x55DD99)
gpu.set(2, 10, "EEPROM loader installed!")
gpu.setForeground(0xFFFFFF)
gpu.set(2, 12, "Backup: " .. backupPath)
gpu.set(2, 14, "Press any key.")
event.pull("key_down")

return true
