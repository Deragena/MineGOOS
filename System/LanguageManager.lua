local filesystem = require("filesystem")

local LanguageManager = {}

local basePath = "/MineGOOS"
local configPath = basePath .. "/Config/language.cfg"

function LanguageManager.loadLanguage(code)
  local path = basePath .. "/Languages/" .. code .. ".lua"

  if not filesystem.exists(path) then
    return nil
  end

  return dofile(path)
end

function LanguageManager.getLanguage()
  if not filesystem.exists(configPath) then
    return nil
  end

  local file = io.open(configPath, "r")
  local language = file:read("*l")
  file:close()

  return language
end

function LanguageManager.setLanguage(code)
  filesystem.makeDirectory(basePath .. "/Config")

  local file = io.open(configPath, "w")
  file:write(code)
  file:close()
end

return LanguageManager
