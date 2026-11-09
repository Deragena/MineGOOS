local filesystem = require("filesystem")
local term = require("term")

term.clear()
print("=== MineGOOS Files ===")
print("")

for file in filesystem.list("/") do
  print(file)
end

print("")
print("Press any key to exit")

require("event").pull("key_down")
