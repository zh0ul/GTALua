-- event module
-- You can add/remove event listener, add your own events (and call them)
-- Each event listener has it's own name so it can be identified
event = {}
event.Listener = {}

-- Add Listener
function event.AddListener(event_name, listener_name, callback)
	if event.Listener[event_name] == nil then
		event.Listener[event_name] = {}
	end
	
	event.Listener[event_name][listener_name] = callback
end

-- Call Event Listener
-- This function calls ALL event listeners UNTIL a value is returned != nil
function event.Call(event_name, ...)
	if not event.Listener[event_name] then return end
	
	for k,v in pairs(event.Listener[event_name]) do
		local rv = v(...)
		if rv ~= nil then
			return rv
		end
	end
end

-- Remove Listener
function event.RemoveListener(event_name, listener_name)
	if event.Listener[event_name] == nil then return end
	event.Listener[event_name][listener_name] = nil
end

RestartRequest = {}

function RestartRequest:add(threadName)
    threadName = tostring(threadName) or ""
    if not threadName or threadName == "" then print("# Syntax: RestartRequest:add(\"threadName\")") ; return false ; end
    if not scripthookv.ThreadList[threadName] then print("# RestartRequest:add() could not find thread: "..threadName) ; return false ; end
    --local curThread = scripthookv.ThreadList[threadName]
    --if curThread.Kill then curThread:Kill() end
    self[#self+1] = { threadName = threadName, markedForRemoval = false, }
    --self:dorestart()
    print("# Restart request "..tostring(#self).." submitted for "..threadName)
    return true
end


function RestartRequest:remove(threadName)
    threadName = tostring(threadName) or ""
    for i,v in ipairs(self) do if  v and v.threadName and v.threadName == threadName then table.remove(self,i) ; print("# Removed "..threadName.." from RestartRequest successfully.") ; end ; end
end


function RestartRequest:dorestart()
    for i,v in ipairs(self)
    do
        if    v.markedForRemoval
        then  table.remove(self,i)
        else
            local curName = ""
            if   v and v.threadName and scripthookv.ThreadList[v.threadName] then curName = v.threadName end
            if   curName ~= ""
            and  scripthookv.ThreadList
            and  scripthookv.ThreadList[curName]
            then
                print("# Processing restart request for "..tostring(curName))
                if    console and console.cmd_load_addon and console.cmd_unload_addon
                then  scripthookv.ThreadList[curName]:Kill() ; console.cmd_load_addon(curName)
                end
            else
                print("# RestartRequest:dorestart() Unable to find thread "..tostring(v))
            end
        end
    end
    for i = #self,1,-1
    do
        self[i].markedForRemoval = true
    end
end

event.AddListener("RestartRequest",  "customRestartRequest",   function(...) RestartRequest:add(...)    ; end  )
event.AddListener("RestartRequestDo","customRestartRequestDo", function()    RestartRequest:dorestart() ; end  )
