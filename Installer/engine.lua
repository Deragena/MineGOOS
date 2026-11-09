local component = require("component")

local Engine = {}

local function copyFile(source, target, fs)
    local input = io.open(source, "rb")
    if not input then
        return false, "Cannot open: " .. source
    end

    local output = fs.open(target, "wb")
    if not output then
        input:close()
        return false, "Cannot write: " .. target
    end

    while true do
        local data = input:read(4096)
        if not data then break end
        fs.write(output, data)
    end

    input:close()
    fs.close(output)
    return true
end

function Engine.install(driveAddress, sourcePath, progress)
    local fs = component.proxy(driveAddress)

    if not fs or not fs.spaceTotal then
        return false, "Invalid filesystem"
    end

    local folders = {
        "MineGOOS",
        "MineGOOS/System",
        "MineGOOS/Applications",
        "MineGOOS/Libraries",
        "MineGOOS/Boot",
        "MineGOOS/Store",
        "MineGOOS/Installer"
    }

    for _, folder in ipairs(folders) do
        if not fs.exists(folder) then
            local ok = fs.makeDirectory(folder)
            if not ok then
                return false, "Cannot create " .. folder
            end
        end
    end

    local files = {
        "init.lua",
        "System/Core.lua",
        "System/Desktop.lua",
        "System/WindowManager.lua",
        "System/LanguageManager.lua",
        "System/FirstSetup.lua",
        "Applications/Files.lua",
        "Applications/Terminal.lua",
        "Applications/Settings.lua",
        "Libraries/GUI.lua",
        "Libraries/Window.lua",
        "Boot/boot.lua",
        "Store/catalog.lua"
    }

    for i, name in ipairs(files) do
        local source = sourcePath .. "/" .. name
        local target = "MineGOOS/" .. name

        local ok, err = copyFile(source, target, fs)
        if not ok then return false, err end

        if progress then
            progress(i, #files, name)
        end
    end

    return true, "MineGOOS installed successfully!"
end

return Engine
