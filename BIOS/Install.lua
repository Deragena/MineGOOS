local component = require("component")
local event = require("event")

local eepromAddress = component.list("eeprom")()
if not eepromAddress then error("EEPROM not found") end

local eeprom = component.proxy(eepromAddress)
local selectedFS, selectedAddress

for address in component.list("filesystem") do
  local fs = component.proxy(address)

  if fs.exists("/BIOS/eeprom.lua") and fs.exists("/BIOS/bios.lua") then
    selectedFS = fs
    selectedAddress = address
    break
  end
end

if not selectedFS then
  error("BIOS not found. Download it first.")
end

local function readFile(fs, path)
  local handle, err = fs.open(path, "r")
  if not handle then return nil, err end

  local chunks = {}
  while true do
    local chunk = fs.read(handle, 4096)
    if not chunk then break end
    chunks[#chunks + 1] = chunk
  end

  fs.close(handle)
  return table.concat(chunks)
end

local newCode, err = readFile(selectedFS, "/BIOS/eeprom.lua")
if not newCode then error(tostring(err)) end

local limit = eeprom.getSize()
if #newCode > limit then
  error("EEPROM limit exceeded: " .. #newCode .. "/" .. limit)
end

local oldCode = eeprom.get()
if type(oldCode) ~= "string" then
  error("Cannot read old EEPROM firmware")
end

local backupPath = "/BIOS/eeprom-backup.lua"
local n = 1

while selectedFS.exists(backupPath) do
  backupPath = "/BIOS/eeprom-backup-" .. n .. ".lua"
  n = n + 1
end

local backup, backupError = selectedFS.open(backupPath, "w")
if not backup then error("Backup failed: " .. tostring(backupError)) end

selectedFS.write(backup, oldCode)
selectedFS.close(backup)

local gpu = component.gpu
local w, h = gpu.getResolution()

gpu.setBackground(0x100D1C)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")

gpu.setForeground(0xA970FF)
gpu.set(2, 2, "MINEGOOS EEPROM INSTALL")

gpu.setForeground(0xFFFFFF)
gpu.set(2, 4, "Code size: " .. #newCode .. "/" .. limit)
gpu.set(2, 5, "Backup: " .. backupPath)
gpu.set(2, 7, "Press Y to flash EEPROM.")
gpu.set(2, 8, "Press any other key to cancel.")

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
gpu.set(2, 10, "EEPROM installed and verified!")
gpu.setForeground(0xFFFFFF)
gpu.set(2, 12, "Backup: " .. backupPath)
event.pull("key_down")

return true
