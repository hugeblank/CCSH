local function ls(dir, args)
  if not dir then dir = "" end
  if args then args = " -"..args.." " end
  local f = io.popen("ls"..args..dir..">&1 2>/dev/null")
  local ls
  if f then
    ls = f:read("*a")
  end
  f:close()
  if not ls then 
    return "" 
  else
    return ls
  end
end

fs = {
  list = function(dir)
    local out = {}
    for l in ls(dir, "A"):gmatch("[^\n]+") do
      out[#out+1] = l
    end
    return out
  end,

  exists = function(dir)
    local ls0 = ls(dir, "A")
    if ls0 ~= "" then 
      return true 
    else
      return false
    end
  end,

  isDir = function(dir)
    local ls0 = ls(dir, "ld")
    if ls0 and ls0:sub(1, 1) == "d" then
      return true
    else
      return false
    end
  end,

  isReadOnly = function(dir)
    local ls0 = ls(dir, "ld")
    if ls0:find(username) and (ls0:sub(2, 2) == "r" and (ls0:sub(3, 3) ~= "w" or ls0:sub(4, 4) ~= "x")) then
      return true
    elseif (not ls0:find(username)) and ls0:sub(5, 5) == "r" and (ls0:sub(6, 6) ~= "w" or ls0:sub(7, 7) ~= "x") then
      return true
    else
      return false
    end
  end,
  
  getName = function(dir)
    if dir == "/" then return "root" end
    dir = dir.."/"
    local out = ""
    for l in dir:gmatch("[^/]+") do out = l end
    return out
  end,
  
  getDrive = function(dir)
    return io.popen("df -P "..dir.." | tail -1 | cut -d' ' -f 1"):read()
  end,
  
  getSize = function(dir)
    if dir == "/" then
      return io.popen("du -s"):read()
    else
      return io.popen("du -s "..dir.." | tail -1 | cut -f 1"):read()
    end
  end,
  
  getFreeSpace = function(dir)
      local out = {}
      local str = io.popen("df | grep -n "..fs.getDrive(dir).." | cut -d: -f2"):read("*a")
      for l in x:gmatch("%S+") do
        out[#out+1] = l
      end
      return out[4]
  end,
  
  makeDir = function(dir)
    os.execute("mkdir "..dir.." 2>/dev/null")
  end,
  
  move = function(dir, newdir)
    os.execute("mv -r "..dir.." "..newdir.." 2>/dev/null")
  end,
  
  copy = function(dir)
    os.execute("cp -r "..dir.." "..newdir.." 2>/dev/null")
  end,
  
  delete = function(dir)
    os.execute("rm -r "..dir.." 2>/dev/null")
  end,
  
  combine = function(dir, dir0)
    if dir == "" then
      return dir0
    elseif dir0 == "" then
      return dir
    else
      return dir.."/"..dir0
    end
  end,
  
  open = function(name, mode)
    data = {
      index = 1,
      isClosed = false, 
      tempfile = "",
      check = function()
        if data.isClosed then
          error("attempt to use a closed file", 2)
        end
      end,
      save = function()
        handle = io.open(name, "w")
        handle:write(data.tempfile)
        handle:close()
      end
    }
    writefuncs = {
      write = function(info)
        data.check()
        data.tempfile = data.tempfile..info
      end,
      
      writeLine = function(info)
        data.check()
        data.tempfile = writefuncs.write(info.."\n")
      end,
      
      flush = function()
        data.check()
        data.save()
      end, 
      
      close = function()
        writefuncs.flush()
        data.isClosed = true
      end
    }
    readfuncs = {
      read = function()
        data.check()
        data.tempfile = data.tempfile:sub(2, -1)
        local out = data.tempfile:sub(data.index, data.index)
        data.index = data.index+1
        return out
      end,
      
      readLine = function()
        data.check()
        local _, n = data.tempfile:find("\n")
        local out = data.tempfile:sub(1, n)
        data.tempfile = data.tempfile:sub(n+1, -1)
        data.index = n+1
        return out
      end,
      
      readAll = function()
        data.check()
        data.index = data.tempfile:len()
        local out = data.tempfile
        data.tempfile = ""
        return out
      end,
      
      close = function()
        data.check()
        data.isClosed = true
      end
    }
    if mode == "w" or mode == "wb" then
      return writefuncs
    elseif mode == "a" or mode == "ab" then
      local f = io.open(name, "r")
      data.tempfile = f:read("*a")
      f:close()
      return writefuncs
    elseif mode == "r" or mode == "rb" then
      if fs.exists(name) then
        local f = io.open(name, "r")
        data.tempfile = f:read("*a")
        f:close()
        return readfuncs
      end
    else
      error("Unsupported mode", 2)
    end
  end,
  
  find = list,
  
  getDir = function(dir)
    if fs.exists(dir) then
      local out = ""
      local pre = {}
      for l in dir:gmatch("[^/]+") do
        pre[#pre+1] = l
      end
      for i = 1, #pre-1 do
        out = out..pre[i].."/"
      end
      out = out:sub(1, -2)
      if out == "" then out = "/" end
      return out
    end
  end,
  
  complete = function(str, dir, incf, incs)
    if incf == nil then incf = true end
    if incs == nil then incs = true end
    local out = {}
    local list = fs.list(dir)
    if list then
      for i = 1, #list do
        local a, _ = list[i]:find(str)
        if a == 1 then
          if (not fs.isDir(dir.."/"..list[i])) or incf == true then
            out[#out+1] = list[i]:sub(1+str:len(), -1)
            if incs then
              out[#out+1] = out[#out].."/"
            end
          end
        end
      end
      return out
    else
      error("not a directory", 2)
    end
  end
}