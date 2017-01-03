-- List of threads
scripthookv.ThreadList = scripthookv.ThreadList or {}
scripthookv.ActiveThread = nil

-- Types
scripthookv.TypeTable = {
	a = "number",
	b = "boolean",
	f = "number",
	i = "number",
	m = "CMemoryBlock",
	s = "string",
	u = "number",
	v = "void",
	V = "Vector",
}

-- Find Thread
function scripthookv.FindThread(name)
	return scripthookv.ThreadList[name]
end

-- Kill Thread
function scripthookv.KillThread(name)
	-- Find
	local thread = scripthookv.FindThread(name)
	if thread then
		if not thread.m_bRunsOnMainThread then
			thread:internal_Kill()
		else
			scripthookv.FindThread("main_thread"):KillThread(thread)
		end
		scripthookv.ThreadList[name] = nil
	end
end