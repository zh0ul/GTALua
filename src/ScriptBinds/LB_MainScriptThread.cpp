// =================================================================================
// Includes 
// =================================================================================
#include "Includes.h"
#include "GTALua.h"
#include "lua/Lua.h"
#include "ScriptBinds.h"
#include "ScriptEngine/ScriptEngine.h"
#include "thirdparty/ScriptHookV/ScriptHookV.h"
#include "UTIL/UTIL.h"
#include "GameEvents/GameEvents.h"
using namespace ScriptBinds::ScriptThread;

// =================================================================================
// Main Thread 
// =================================================================================
void LuaScriptThread::Run_MainThread()
{
	// Dispatch Game Events
	GameEvents::DispatchEvents();

	// Mutex
	lua->GetMutex()->Lock();

	// Time
	int game_time = ScriptHook::GetGameTime();

	// Threads
	for (luabind::iterator i(m_lThreadList), end; i != end; i++)
	{
		luabind::object l_thread = *i;
		LuaScriptThread* pThread = luabind::object_cast<LuaScriptThread*>(l_thread);
		pThread->m_bActive = true;

		// Next Run
		if (pThread->m_iNextRun == 0)
			pThread->m_iNextRun = game_time - 1;

		// Reset
		if (pThread->m_bResetting)
		{
			printf("[LuaScriptThread] Thread %s reset\n", pThread->m_sName.c_str());
			pThread->m_bResetting = false;

			// Lua
			if (!pThread->Call_LuaCallback("SetupCoroutine"))
			{
				printf("[LuaScriptThread] Failed to reset Thread %s! Entering Idle State!\n", pThread->m_sName.c_str());
				pThread->m_bIdleState = true;
			}
			else {
				pThread->m_iNextRun = 0;
				pThread->m_bIdleState = false;
			}
		}

		// Tick
		if (!pThread->m_bIdleState)
		{
			if (!pThread->Call_LuaCallback("internal_OnTick"))
			{
				printf("[LuaScriptThread] Failed to call Thread %s:OnTick!\n", pThread->m_sName.c_str());
			}
		}

		// Run
		if (!pThread->m_bIdleState && game_time >= pThread->m_iNextRun)
		{
			// Callback
			if (!pThread->Run())
				pThread->m_bIdleState = !pThread->m_bResetting;

			// Wait
			pThread->m_iNextRun = game_time + pThread->m_iWaitTime;
			pThread->m_iWaitTime = 1;
		}
	}

	//MessageBox(0, 0, 0, 0);
	// Cleanup
	lua->GetMutex()->Unlock();

	// Yield
#ifdef GTA_LUA_TEST_EXE
	Sleep(10);
#else
	ScriptHook::ScriptWait(0);
#endif
}