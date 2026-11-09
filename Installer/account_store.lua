local component = require("component")
local fs = require("filesystem")

local Store = {}
local PATH = "/MineGOOS/System/account.dat"

local function getDataCard()
  for address in component.list("data") do
    local card = component.proxy(address)
    if card.sha256 and card.random then
      return card
    end
  end
end

local function hex(data)
  return (data:gsub(".", function(c)
    return string.format("%02x", string.byte(c))
  end))
end

local function hash(card, salt, password)
  local result = card.sha256(salt .. password)

  for i = 1, 999 do
    result = card.sha256(salt .. result)
  end

  return result
end

function Store.save(username, password)
  if not username or not username:match("^[%w_-]+$") then
    return false, "Invalid username"
  end

  local card = getDataCard()
  if not card then
    return false, "A compatible Data Card is required"
  end

  local ok, salt = pcall(card.random, 16)
  if not ok or type(salt) ~= "string" or #salt < 16 then
    return false, "Cannot generate secure salt"
  end

  local success, digest = pcall(hash, card, salt, password)
  if not success or type(digest) ~= "string" then
    return false, "Password hashing failed"
  end

  local dir = fs.path(PATH)
  if not fs.exists(dir) then
    fs.makeDirectory(dir)
  end

  local file, err = io.open(PATH, "w")
  if not file then
    return false, tostring(err)
  end

  file:write("MINEGOOS_ACCOUNT_1\n")
  file:write(username .. "\n")
  file:write(hex(salt) .. "\n")
  file:write(digest .. "\n")
  file:close()

  return true
end

return Store
