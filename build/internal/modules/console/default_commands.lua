-- help
function console.cmd_help()
  local tKeys = {}
	print("List of available commands:")
	print("----------------------------------------")
  for k,v in pairs(console.Commands) do	tKeys[#tKeys+1] = k ; end
	table.sort(tKeys)
	for k,v in pairs(tKeys) do
		if not utils.IsInArray(_deprecated_ConsoleCommands, v) then
			print(v)
		end
	end
	print("----------------------------------------")
end

-- Load Addon
function console.cmd_load_addon(name)
	-- Syntax
	if not name then
		print("[GTALua] Syntax: load/reload [addon name]")
		return
	end

	-- Unload if loaded
	if scripthookv.ThreadList[name] then print("[GTALua] Unloading "..name) ; addon.Unload(name) end

  -- Now load
	print("[GTALua] Loading ", name, "...")
	addon.Load(name)
	print("")
end

-- Unload Addon
function console.cmd_unload_addon(name)
	-- Syntax
	if not name then
		print("[GTALua] Syntax: unload [addon name]")
		return
	end

	-- Unload
	print("[GTALua] Unloading ", name, "...")
	addon.Unload(name)
	print("")
end

-- Reload All Addons
function console.cmd_reload_all_addons()
	print("[GTALua] Reloading all addons...")
	for  _,thread in pairs(scripthookv.ThreadList) do
		local name = thread:GetName()
		if name ~= "main_thread" then addon.Unload(name) ; addon.Load(name) end
	end
	print("")
end

-- Show the running threads
function console.cmd_show_all_addons()
	print("[GTALua] List of all loaded addons...")
	for  _,thread in pairs(scripthookv.ThreadList) do
		local name = thread:GetName()
		print(string.format( "%5s %-20s %8s %-5s %8s %-5s", "Name:", name,"Active:", tostring(thread:IsActive()), "Running:", tostring(thread:IsRunning()) ) )
	end
	print("")
end

-- Execute a Lua command
function console.cmd_lua(...)
	local cmd=table.concat(arg," ")
	local f=loadstring(cmd)
	if type(f) == "function" then
		local r=f()
		if r ~= nil then
			print(r)
		end
	else
		error("Input didn't evaluate to a function.")
	end
end


-- Register default console commands.

console.RegisterCommand("help", console.cmd_help)
console.RegisterCommand("unload", console.cmd_unload_addon)
console.RegisterCommand("reload", console.cmd_load_addon)
console.RegisterCommand("load", console.cmd_load_addon)
console.RegisterCommand("reloadall", console.cmd_reload_all_addons)
console.RegisterCommand("lua", console.cmd_lua)
