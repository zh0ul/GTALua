-- Console
console = {}
console.Commands = {}

-- Register
function console.RegisterCommand(name, callback)
	console.Commands[name] = callback
end

-- Event Listener
--[[
event.AddListener("OnConsoleInput", "internal_consoleModule", function(command, args)
	local callback = console.Commands[command]
	if callback ~= nil then
		callback(unpack(args))
		return true
	end
end)
--]]

event.AddListener(
    "OnConsoleInput",
    "internal_consoleModule_custom",
    function(command,args)

          local function unpack2(t,mode)  local  modeNumber,modeString = false,false ; if not mode  then  modeNumber,modeString = true,true ;  elseif  mode:sub(1,2) == "nu"  then  modeNumber,modeString = true,  false ;  elseif  mode:sub(1,1) == "s"   then  modeNumber,modeString = false, true ;  elseif  mode:sub(1,2) == "na"  then  modeNumber,modeString = false, true ;  elseif  mode:sub(1,1) == "b"  then  modeNumber,modeString = true,  true ;  end ;  if ( type(t) ~= "table" ) then return t ; end ; local retVals,retKeysNumeric,retKeysString = {},{},{} ; for k,v in pairs(t) do  if type(k) == "number" and modeNumber  then  retKeysNumeric[#retKeysNumeric+1] = k  ;  elseif type(k) == "string" and modeString  then  retKeysString[#retKeysString+1]   = k ; end ; end ; table.sort(retKeysNumeric) ; table.sort(retKeysString) ; for _,k in pairs(retKeysNumeric) do retVals[#retVals+1] = t[k] ; end ; for _,k in pairs(retKeysString)  do retVals[#retVals+1] = t[k] ; end ; return unpack(retVals) ; end

          local command_all = command

          for k,v in pairs(args) do command_all = command_all .. " "..tostring(v) ; end

          -- Look for exact match first

          if ( command ~= "if" ) and ( command ~= "for" ) and ( command ~= "while" ) and ( command ~= "function" ) and ( command ~= "print" ) and ( command ~= "echo" ) and ( command ~= "local" )
          then
              for k,v in pairs(console.Commands) do
                  if  ( k:lower() == command:lower() )
                  then
                      local   callback = console.Commands[k]
                      if      callback ~= nil and args ~= nil
                      then    local ret = callback(unpack2(args)) ; return true
                      elseif  callback ~= nil
                      then    local ret = callback()              ; return true
                      end
                  end
              end

              -- Look for loose match next

              for k,v in pairs(console.Commands) do
                  if  string.find(k:lower(),command:lower())
                  then
                      local   callback = console.Commands[k]
                      if      callback ~= nil and args ~= nil
                      then    local ret = callback(unpack2(args)) ; return true
                      elseif  callback ~= nil
                      then    local ret = callback()              ; return true
                      end
                  end
              end
          end

          -- If no callback found, send command directly to lua_do
          --lua_do(command_all)
          local func = loadstring(command_all)
          if func then pcall(func) ; else print("LUA_DO: Could not load string:  "..tostring(command_all)) end

          return true
    end
)

-- Default Commands
include("default_commands.lua")