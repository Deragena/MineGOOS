local computer = require("computer")
local component = require("component")
local event = require("event")
local gpu = component.gpu
local Theme = dofile("/MineGOOS/Installer/theme.lua")

local UI = {}
local w, h = gpu.getResolution()
local step = 1

local pages = {
  {
    "Welcome to MineGOOS",
    "Install your own data-center operating system.",
    "Press NEXT to begin."
  },
  {
    "Language",
    "Choose the language for your system.",
    "English / Russian"
  },
  {
    "Storage",
    "Choose the destination storage device.",
    "Disk selection will be connected to the installer engine."
  },
  {
    "Installation",
    "Everything is ready for installation.",
    "Press NEXT to start the installation."
  },
  {
    "Finished",
    "MineGOOS setup is complete.",
    "Restart the computer to launch your system."
  }
}

local function center(y, value, color)
  gpu.setForeground(color or Theme.white)
  gpu.setBackground(Theme.panel)
  gpu.set(math.max(2, math.floor((w - #value) / 2)), y, value)
end

function UI.draw()
  Theme.clear()
  Theme.header("MineGOOS Setup", "Installation wizard")
  Theme.progress(step, #pages)

  Theme.panel(3, 10, w - 4, h - 15)

  local page = pages[step]
  center(12, page[1], Theme.purple)
  center(15, page[2], Theme.white)
  center(18, page[3], Theme.muted)

  center(h - 5, "STEP " .. step .. " / " .. #pages, Theme.muted)

  if step > 1 then
    Theme.button(3, h - 3, 13, "BACK", false)
  end

  Theme.button(w - 15, h - 3, 13,
    step == #pages and "RESTART" or "NEXT", true)
end

function UI.run()
  while true do
    UI.draw()
    local e = {event.pull()}

    if e[1] == "touch" then
      local x, y = e[3], e[4]

      if y >= h - 3 then
        if x <= 16 and step > 1 then
          step = step - 1
        elseif x >= w - 15 then
          if step < #pages then
            step = step + 1
          else
            computer.shutdown(true)
            return
          end
        end
      end

    elseif e[1] == "key_down" then
      local code = e[4]

      if code == 203 and step > 1 then
        step = step - 1
      elseif code == 205 and step < #pages then
        step = step + 1
      elseif code == 28 and step < #pages then
        step = step + 1
      elseif code == 1 then
        return
      end
    end
  end
end

return UI
