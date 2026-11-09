-- MineGOOS BIOS preparation

local file = io.open("BIOS/bios.lua", "rb")
if not file then
  error("BIOS/bios.lua not found")
end

local code = file:read("*a")
file:close()

print("MineGOOS BIOS")
print("--------------------------")
print("BIOS size: " .. #code .. " bytes")
print("EEPROM limit: 4096 bytes")

if #code > 4096 then
  print("ERROR: BIOS is too large!")
else
  print("BIOS size: OK")
end
