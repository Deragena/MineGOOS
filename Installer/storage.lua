local component = require("component")
local filesystem = require("filesystem")
local event = require("event")

local gpu = component.gpu
local Storage = {}

local function safeCall(obj, method, ...)
  if not obj[method] then return nil end
  local ok, result = pcall(obj[method], ...)
  if ok then return result end
  return nil
end

function Storage.choose()
  local root = filesystem.get("/")
  local rootAddress = root and root.address

  local disks = {}

  for address in component.list("filesystem") do
    local fs = component.proxy(address)

    if address ~= rootAddress then
      local readonly = safeCall(fs, "isReadOnly", "/")
      local total = safeCall(fs, "spaceTotal")
      local used = safeCall(fs, "spaceUsed")
      local label = safeCall(fs, "getLabel")

      if readonly == false and total and used and total - used >= 2 * 1024 * 1024 then
        table.insert(disks, {
          address = address,
          proxy = fs,
          label = label or ("Disk " .. address:sub(1, 8)),
          free = total - used
        })
      end
    end
  end

  if #disks == 0 then
    gpu.setBackground(0x100D1C)
    gpu.setForeground(0xFF6666)
    gpu.fill(1, 1, select(1, gpu.getResolution()), select(2, gpu.getResolution()), " ")
    gpu.set(2, 2, "No suitable installation disk found.")
    event.pull("key_down")
    return nil
  end

  local selected = 1

  while true do
    local w, h = gpu.getResolution()
    gpu.setBackground(0x100D1C)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")

    gpu.setForeground(0x985CFF)
    gpu.set(2, 2, "MINEGOOS - SELECT DISK")

    gpu.setForeground(0xAAA4BD)
    gpu.set(2, 4, "UP/DOWN: select   ENTER: continue   ESC: cancel")

    for i, disk in ipairs(disks) do
      local y = 7 + (i - 1) * 3
      gpu.setBackground(i == selected and 0x49316F or 0x211B35)
      gpu.setForeground(0xFFFFFF)
      gpu.fill(2, y, w - 4, 2, " ")

      local freeMB = math.floor(disk.free / 1048576)
      gpu.set(4, y, (i == selected and "> " or "  ") ..
        disk.label .. "  |  Free: " .. freeMB .. " MB")
    end

    local e = {event.pull()}

    if e[1] == "key_down" then
      local key = e[4]

      if key == 200 then
        selected = math.max(1, selected - 1)
      elseif key == 208 then
        selected = math.min(#disks, selected + 1)
      elseif key == 28 then
        break
      elseif key == 1 then
        return nil
      end
    elseif e[1] == "touch" then
      local y = e[4]
      local index = math.floor((y - 7) / 3) + 1

      if index >= 1 and index <= #disks then
        selected = index
        break
      end
    end
  end

  local mountPath = "/mnt/minegoos_target"

  filesystem.makeDirectory("/mnt")
  filesystem.makeDirectory(mountPath)

  local ok, reason = filesystem.mount(disks[selected].proxy, mountPath)

  if not ok then
    error("Cannot mount disk: " .. tostring(reason))
  end

  return mountPath
end

return Storage
