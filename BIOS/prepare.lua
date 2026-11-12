-- MineGOOS BIOS preparation checker

local function read(path)
    local file, err = io.open(path, "rb")
    if not file then
        return nil, err
    end

    local data = file:read("*a")
    file:close()
    return data
end

local eepromCode, eepromError = read("BIOS/eeprom.lua")
local biosCode, biosError = read("BIOS/bios.lua")

print("================================")
print("       MineGOOS BIOS CHECK")
print("================================")

if not eepromCode then
    print("ERROR: " .. tostring(eepromError))
    return
end

if not biosCode then
    print("ERROR: " .. tostring(biosError))
    return
end

local limit = 4096

print("EEPROM loader: " .. #eepromCode .. " bytes")
print("Main BIOS:     " .. #biosCode .. " bytes")
print("EEPROM limit:  " .. limit .. " bytes")
print("--------------------------------")

if #eepromCode > limit then
    print("ERROR: EEPROM loader is too large!")
else
    print("EEPROM loader size: OK")
end

local compiled, err = load(eepromCode, "@BIOS/eeprom.lua")
if not compiled then
    print("EEPROM syntax error: " .. tostring(err))
else
    print("EEPROM syntax: OK")
end

local compiledBios, biosSyntaxError = load(biosCode, "@BIOS/bios.lua")
if not compiledBios then
    print("BIOS syntax error: " .. tostring(biosSyntaxError))
else
    print("BIOS syntax: OK")
end

print("--------------------------------")
print("Preparation check finished.")
