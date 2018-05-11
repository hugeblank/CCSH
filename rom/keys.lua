-- X11 key code bindings
-- See `xmodmap -pke` for more information.

local tKeys = {
	nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil,
  "one", "two", "three", "four", "five", 
  "six", "seven", "eight", "nine", "zero", 
  "minus", "equals", "backspace", "tab", "q", 
  "w", "e", "r", "t", "y", 
  "u", "i", "o", "p", "leftBracket", 
  "rightBracket", "enter", "leftCtrl", "a",	"s", "d", 
  "f", "g", "h", "j", "k", 
  "l", "semiColon", "apostrophe", "grave", "leftShift", 
  "backslash", "z", "x", "c", "v", 
  "b", "n", "m", "comma", "period", 
  "slash", "rightShift", "multiply", "leftAlt", "space",
  "capsLock", "f1", "f2", "f3", "f4",
  "f5", "f6", "f7", "f8", "f9", 
  "f10", "numLock", "scollLock", "numPad7", "numPad8", 
  "numPad9", "numPadSubtract", "numPad4", "numPad5", "numPad6", 
  "numPadAdd", "numPad1", "numPad2", "numPad3", "numPad0", 
  "numPadDecimal", nil, nil, nil, "f11", 
  "f12", nil, "kana", nil, nil, 
  nil, nil, nil, "numPadEnter", "rightCtrl",
  "numPadDivide", nil, "rightAlt", nil, "home",
  "up", "pageUp", "left", "right", "end",
  "down", "pageDown", "insert", "delete", nil,
  nil, nil, nil, nil, nil,
  nil, "pause"
}

local keys = _ENV
for nKey, sKey in pairs( tKeys ) do
	keys[sKey] = nKey
end
keys["return"] = keys.enter
--backwards compatibility to earlier, typo prone, versions
keys.scollLock = keys.scrollLock
keys.cimcumflex = keys.circumflex

function getName( _nKey )
    if type( _nKey ) ~= "number" then
        error( "bad argument #1 (expected number, got " .. type( _nKey ) .. ")", 2 ) 
    end
	return tKeys[ _nKey ]
end
