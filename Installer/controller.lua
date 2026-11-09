local component = require("component")
local filesystem = require("filesystem")

local M = {}

M.language = "ru"
M.selectedDrive = nil

function M.getDrives()
    local drives = {}

    for address in component.list("filesystem") do
        local fs = component.proxy(address)

        if fs and fs.spaceTotal then
            table.insert(drives, {
                address = address,
                total = fs.spaceTotal(),
                used = fs.spaceUsed()
            })
        end
    end

    return drives
end

function M.setLanguage(language)
    M.language = language
end

function M.selectDrive(address)
    for _, drive in ipairs(M.getDrives()) do
        if drive.address == address then
            M.selectedDrive = address
            return true
        end
    end

    return false
end

function M.getSelectedDrive()
    return M.selectedDrive
end

function M.getLanguage()
    return M.language
end

return M
