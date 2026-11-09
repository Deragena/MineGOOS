local term = require("term")
local io = require("io")
local LanguageManager = dofile("/MineGOOS/System/LanguageManager.lua")

term.clear()

print("================================")
print("         MineGOOS Setup")
print("================================")
print("")
print("Выберите язык / Choose language")
print("")
print("1. Русский")
print("2. English")
print("")

io.write("> ")

local choice = io.read()

if choice == "1" then
  LanguageManager.setLanguage("ru")
  print("Выбран русский язык!")

elseif choice == "2" then
  LanguageManager.setLanguage("en")
  print("English selected!")

else
  print("Неверный выбор / Invalid choice")
end
