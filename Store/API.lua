local component = require("component")
local internet = component.internet
local filesystem = require("filesystem")

local API = {}

API.base = "https://raw.githubusercontent.com/Deragena/MineGOOS/main/"

local function download(url)
    if not internet then
        return nil, "Internet card not found"
    end

    local ok, result = pcall(function()
        local response = internet.request(url)
        if not response then
            error("Request failed")
        end

        local data = ""
        for chunk in response do
            data = data .. chunk
        end

        return data
    end)

    if not ok then
        return nil, tostring(result)
    end

    return result
end

function API.getCatalog()
    local data, err = download(API.base .. "Store/catalog.json")
    if not data then return nil, err end

    local ok, catalog = pcall(
        require("serialization").unserialize,
        data
    )

    if not ok or type(catalog) ~= "table" then
        return nil, "Invalid catalog"
    end

    return catalog
end

function API.getApp(id)
    local catalog, err = API.getCatalog()
    if not catalog then return nil, err end

    for _, app in ipairs(catalog.apps or {}) do
        if app.id == id then
            return app
        end
    end

    return nil, "Application not found"
end

function API.install(id)
    local app, err = API.getApp(id)
    if not app then return false, err end

    local url = API.base .. app.package
    local data
    data, err = download(url)

    if not data then return false, err end

    local directory = "/MineGOOS/Applications"
    filesystem.makeDirectory(directory)

    local path = directory .. "/" .. id .. ".lua"
    local file = io.open(path, "wb")

    if not file then
        return false, "Cannot create application file"
    end

    file:write(data)
    file:close()

    return true, app.name .. " installed!"
end

return API
