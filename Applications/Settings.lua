local term = require("term")
local event = require("event")

term.clear()

print("=== MineGOOS Settings ===")
print("")
print("1. Русский / Russian")
print("2. English")
print("")
print("Press any key to exit")

event.pull("key_down")
