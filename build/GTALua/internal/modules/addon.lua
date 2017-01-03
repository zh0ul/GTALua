-- Addons
addon = {}
addon.AddonTable = {}

function addon.FileExists(file)
		  local f = io.open(file,"r")
		  if    f ~= nil  then  io.close(f)  ;  return true  ;  else  return false  ;  end
end

-- Load Addon
function addon.Load(name)

		if not name or name == "" then print("[addon.Load] Empty mod name given???") ; return ; end

	  if  addon.FileExists("GTALua/addons/"..name.."/main.lua")
	  then
		    include("../../addons/"..name.."/main.lua")
				-- Game Pause
				if IsScriptEngineInitialized() and game.IsPaused() then
					print("[addon.Load] Game is paused. Script Thread will reset after you unpaused it!")
				end
	  else
	  	  print("[addon.Load] Can't find file ".."GTALua/addons/"..name.."/main.lua")
		end
end

-- Unload Addon
function addon.Unload(name)
	local thread = scripthookv.FindThread(name)
	if  thread  then
		thread:Kill()
	else
		print("[addon.Unload] Can't find thread ", name)
	end
end