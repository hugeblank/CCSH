dofile("./rom/fs.lua")
dofile("./rom/os.lua")
local files = fs.list("./rom")
for i = 1, #files do
  if not fs.isDir("./rom/"..files[i]) and (files[i] ~= "fs.lua" and files[i] ~= "os.lua") then
      print(files[i], fs.isDir)
      os.loadAPI("./rom/"..files[i])
  end
end
--os.execute("lua")-- ./rom/bios.lua")