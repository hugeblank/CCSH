dofile("./rom/fs.lua")
dofile("./rom/os.lua")

local file = fs.open("/tmp/render.sh", "w")
file:close()

local files = fs.list("./rom")
for i = 1, #files do
  if not fs.isDir("./rom/"..files[i]) and (files[i] ~= "fs.lua" and files[i] ~= "os.lua") then
      print(files[i], fs.isDir)
      os.loadAPI("./rom/"..files[i])
  end
end


os.execute("./rom/bin/term_update.sh & lua")

