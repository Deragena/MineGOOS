local computer = require("computer")
local component = require("component")
local event = require("event")

local gpu = component.gpu
local Theme = dofile("/MineGOOS/Installer/theme.lua")
local Storage = dofile("/MineGOOS/Installer/storage.lua")
local Install = dofile("/MineGOOS/Installer/install.lua")

local UI = {}

local w, h = gpu.getResolution()
local step = 1
local destination = nil
local errorMessage = nil

local pages = {
  {
    "Welcome to MineGOOS",
    "Install your own data-center operating system.",
    "Press NEXT to begin."
  },
  {
    "Language",
    "Installer interface language: English.",
    "More language options can be added later."
  },
  {
    "Storage",
    "Choose the destination storage device.",
    "NEXT opens the disk selection screen."
  },
  {
    "Ready to install",
    "MineGOOS will download its system files.",
    "Check the selected disk before continuing."
  },
  {
    "Installing MineGOOS",
    "Downloading system files...",
    "Please wait."
  },
  {
    "Installation result",
    "",
    ""
  }
}

local function center(y, value, color)
  value = tostring(value or "")
  gpu.setForeground(color or Theme.white)
  gpu.setBackground(Theme.panelBg)

  local x = math.max(1, math.floor((w - #value) / 2))
  gpu.set(x, y, value:sub(1, math.max(1, w - 2)))
end

local function draw()
  Theme.clear()
  Theme.header("MineGOOS Setup", "Installation wizard")
  Theme.progress(math.min(step, #pages), #pages)

  Theme.panel(3, 10, w - 4, math.max(2, h - 15))

  local page = pages[step]
  local titleY = math.max(10, math.floor(h / 2) - 3)

  center(titleY, page[1], Theme.purple)
  center(titleY + 2, page[2], Theme.white)

  if titleY + 4 < h - 4 then
    center(titleY + 4, page[3], Theme.muted)
  end

  if step == 3 and destination then
    center(titleY + 4, "Selected: " .. destination, Theme.green)
  end

  if step == 6 then
    if errorMessage then
      center(titleY + 4, "ERROR: " .. errorMessage, Theme.red)
    else
      center(titleY + 4, "System files downloaded successfully.", Theme.green)
    end
  end

  center(h - 5, "STEP " .. step .. " / " .. #pages, Theme.muted)

  if step > 1 and step < 5 then
    Theme.button(3, h - 3, 13, "BACK", false)
  end

  local label = step == 6 and "RESTART"
      or step == 5 and "WAIT"
      or step == 4 and "INSTALL"
      or "NEXT"

  Theme.button(w - 15, h - 3, 13, label, true)
end

local function selectDisk()
  destination = Storage.choose()

  if not destination then
    errorMessage = "No disk selected."
    return false
  end

  errorMessage = nil
  return true
end

local function runInstallation()
  step = 5
  draw()

  local ok, result, reason = pcall(
    Install.run,
    destination,
    function(current, total, path)
      local percent = current / total
      Theme.clear()
      Theme.header("Installing MineGOOS", path)
      Theme.progress(percent * 100, 100)
      center(math.floor(h / 2), "Downloading " .. current .. " / " .. total, Theme.white)
    end
  )

  if not ok then
    errorMessage = tostring(result)
  elseif result == false then
    errorMessage = tostring(reason or "Installation failed.")
  else
    errorMessage = nil
  end

  step = 6
end

local function nextStep()
  if step == 3 then
    if selectDisk() then
      step = 4
    end
  elseif step == 4 then
    runInstallation()
  elseif step == 6 then
    computer.shutdown(true)
    return
  elseif step < 4 then
    step = step + 1
  end
end

function UI.run()
  while true do
    draw()

    local e = {event.pull()}

    if e[1] == "touch" then
      local x, y = e[3], e[4]

      if y >= h - 3 then
        if x <= 16 and step > 1 and step < 5 then
          step = step - 1
        elseif x >= w - 15 then
          nextStep()
        end
      end

    elseif e[1] == "key_down" then
      local code = e[4]

      if code == 203 and step > 1 and step < 5 then
        step = step - 1
      elseif code == 205 or code == 28 then
        nextStep()
      elseif code == 1 then
        return
      end
    end
  end
end

return UI
