local tAPIsLoading = {}

function os.capture(cmd)
	local out
	local file = io.popen(cmd)
	if file then
		out = file:read("*a")
    file:close()
	else 
		return false
	end
    return out
end

function os.loadAPI( _sPath )
    if type( _sPath ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( _sPath ) .. ")", 2 ) 
    end
    local sName = fs.getName( _sPath )
    if sName:sub(-4) == ".lua" then
        sName = sName:sub(1,-5)
    end
    if tAPIsLoading[sName] == true then
        printError( "API "..sName.." is already being loaded" )
        return false
    end
    tAPIsLoading[sName] = true

    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )
    local fnAPI, err = loadfile( _sPath, "bt" , tEnv )
    if fnAPI then
        local ok, err = pcall( fnAPI )
        if not ok then
            tAPIsLoading[sName] = nil
            return error( "Failed to load API " .. sName .. " due to " .. err, 1 )
        end
    else
        tAPIsLoading[sName] = nil
        return error( "Failed to load API " .. sName .. " due to " .. err, 1 )
    end
    
    local tAPI = {}
    for k,v in pairs( tEnv ) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end

    _G[sName] = tAPI    
    tAPIsLoading[sName] = nil
    return true
end

function os.unloadAPI( _sName )
    if type( _sName ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( _sName ) .. ")", 2 ) 
    end
    if _sName ~= "_G" and type(_G[_sName]) == "table" then
        _G[_sName] = nil
    end
end