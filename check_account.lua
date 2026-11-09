local ok, component = pcall(require, "component")
if not ok then
  print("component unavailable: this script must run inside OpenComputers")
  return
end

print("Data Cards:")
for address in component.list("data") do
  local card = component.proxy(address)
  print("SHA256:", type(card.sha256))
  print("Random:", type(card.random))
end
