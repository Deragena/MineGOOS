local component = require("component")
local filesystem = require("filesystem")

local Downloads = {}

local BASE = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"
local CATALOG = BASE .. "Store/catalog.txt"

local function request(url)
    if not component.isAvailable("internet") then
        return nil, "Internet card not found"
    end

    local ok, handle = pcall(component.internet.request, url)
    if not ok or not handle then
        return nil, "Connection failed"
    end

    local result = {}

    local success, err = pcall(function()
        for chunk in handle do
            result[#result + 1] = chunk
        end
    end)

    if handle.close then
        pcall(handle.close)
    end

    if not success then
        return nil, tostring(err)
    end

    return table.concat(result)
end

local function save(path, data)
    local file, err = io.open(path, "wb")
    if not file then
        return false, err
    end

    local ok, result = pcall(function()
        file:write(data)
        file:close()
    end)

    if not ok then
        pcall(file.close, file)
        return false, tostring(result)
    end

    return true
end

function Downloads.install(targetRoot, progress)
    local folder = targetRoot .. "/System/downloads"

    filesystem.makeDirectory(folder)

    local catalog, err = request(CATALOG)
    if not catalog then
        return false, err
    end

    local count = 0

    for line in catalog:gmatch("[^\r\n]+") do
        local id, filename, remote =
            line:match("^([%w%-]+)|([%w%-]+%.mgapp)|([%w%-%_/%..]+)$")

        if not id or not remote then
            return false, "Invalid catalog entry"
        end

        if remote:find("..", 1, true) then
            return false, "Invalid package path"
        end

        local url = BASE .. remote
        local destination = folder .. "/" .. filename
        local temporary = destination .. ".part"

        local data
        data, err = request(url)

        if not data then
            return false, id .. ": " .. tostring(err)
        end

        local ok
        ok, err = save(temporary, data)

        if not ok then
            return false, tostring(err)
        end

        if filesystem.exists(destination) then
            filesystem.remove(destination)
        end

        local renamed, renameError =
            filesystem.rename(temporary, destination)

        if not renamed then
            filesystem.remove(temporary)
            return false, tostring(renameError)
        end

        count = count + 1

        if progress then
            progress(count, id, filename)
        end
    end

    return true, count
end

return Downloads
