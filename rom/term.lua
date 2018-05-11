local tputcols = { 255, 214, 207, 75, 226, 118, 219, 237, 241, 38, 135, 21, 94, 34, 196, 232, 256 }
local vals = {} --x, y, bg, fg
local screen = {}

local function totput(color)
  return tputcols[math.log(color, 2)+1]
end

local function addobj(x, y, bg, fg, char)
  screen[#screen+1] = {x=x, y=y, bg=bg, fg=fg, obj=char}
end

local function onScreen(x, y)
  local fx, fy = io.popen("tput cols"), io.popen("tput lines")
  local x0, y0 = tonumber(fx:read("*a")), tonumber(fy:read("*a"))
  fx:close() fy:close()
  if y >= 1 and y <= y0 and x >= 1 and x <= x0 then
    return true
  else
    return false
  end
end

local function redraw() --make efficient-er !!!
  for i = 1, #screen do --re-render screen buffer. term.write()-esque
    if onScreen(screen[i].x, screen[i].y) then
      os.execute("tput cup "..(screen[i].y-1).." "..(screen[i].x-1).."; tput setab "..totput(screen[i].bg).."; tput setaf "..totput(screen[i].fg).."; printf \""..screen[i].obj.."\"")
    end
  end
end

getSize = function()
  local fx, fy = io.popen("tput cols"), io.popen("tput lines")
  local x, y = fx:read("*a"), fy:read("*a")
  fx:close() fy:close()
  return tonumber(x), tonumber(y)
end

setCursorPos = function(x, y)
  local x0, y0 = getSize()
  repeat until x0
  if onScreen(x, y) then
    os.execute("tput cup "..(y-1).." "..(x-1))
  end
  vals.x, vals.y = x, y
end

getCursorPos = function()
  return vals.x, vals.y
end

getTextColor = function()
  return vals.fg
end

setTextColor = function(color)
  if math.log(color, 2) == math.floor(math.log(color, 2)) and totput(color) then
    vals.fg = color
    os.execute("tput setaf "..totput(color))
  else
    error("Invalid color, (got "..color..")", 2)
  end
end

getBackgroundColor = function()
  return vals.bg
end

setBackgroundColor = function(color)
  if math.log(color, 2) == math.floor(math.log(color, 2)) and totput(color) then
    vals.bg = color
    os.execute("tput setab "..totput(color))
  else
    error("Invalid color, (got "..color..")", 2)
  end
end

write = function(str) --holy slow as balls!
  local x, y = getCursorPos()
  local x0, y0 = getSize()
  if onScreen(x, y) then
    local lin
    if str:len() > x-x0 then
      lin = x-x0
    else
      lin = -1
    end
    os.execute("tput setab "..totput(vals.bg).."; tput setaf "..totput(vals.fg).."; printf \""..str:sub(1, lin).."\"")
    vals.x = vals.x+lin
  end
  addobj(x, y, getBackgroundColor(), getTextColor(), str)
end

blit = function(text, fg, bg)
  local obg, ofg = getBackgroundColor(), getTextColor()
  for i = 1, text:len() do
    local fgs
    local bgs
    if fg then
      fgs = fg:sub(i, i)
    end
    if bg then
      bgs = bg:sub(i, i)
    end
    if fgs ~= "" then
      if tonumber(fgs, 16) then
        vals.fg = tonumber(fgs, 16)
      end
    end
    if bgs ~= "" then
      if tonumber(bgs, 16) then
        vals.bg = tonumber(bgs, 16)
      end
    end
    write(text:sub(i, i))
  end
  setTextColor(ofg)
  setBackgroundColor(obg)
end

clearLine = function()
  local x, y = getCursorPos()
  local row, _ = getSize()
  for k, obj in pairs(screen) do
    if obj.y == y then
      table.remove(screen, k)
    end
  end
  write(string.rep(" ", row))
  setCursorPos(x, y)
end

clear = function()
  screen = {}
  local x, y = getSize()
  setCursorPos(1, 1)
  write(string.rep("\n"..string.rep(" ", x), y))
  setCursorPos(1, 1)
end

isColor = function()
  local fc = io.popen("tput colors")
  local isc fc:read("*a")
  fc:close()
  if tonumber(isc) > 4 then
    return true
  else
    return false
  end
end

scroll = function(scr)
  if not scr then
    error("bad argument #1 (expected number, got nil)", 2)
  end
  for i = 1, #screen do 
    --print(screen[i].y, (screen[i].y)+scr)
    screen[i].y = (screen[i].y)+scr
  end
  redraw()
  setCursorPos(getCursorPos())
end

redirect = function(term)
  error("NYI, but soon.(tm) :^)", 2)
end

current = function()
  error("NYI, but soon.(tm) :^)", 2)
end

native = function()
  error("NYI, but soon.(tm) :^)", 2)
end

setBackgroundColor(2^16) --set vals.bg
setTextColor(2^0) --set vals.fg
setCursorPos(1, 1) --set vals.x and vals.y