// =================================================================================
// Includes 
// =================================================================================
#include "Includes.h"
#include "GTALua.h"
#include "lua/Lua.h"
#include "ScriptEngine/ScriptEngine.h"
#include "Memory/Memory.h"
#include "UTIL/UTIL.h"
#include "ScriptBinds/ScriptBinds.h"
#include "thirdparty/ScriptHookV/ScriptHookV.h"
#include "thirdparty/ScriptHookV/inc/main.h"

// =================================================================================
// ScriptHook Member 
// =================================================================================
bool ScriptHook::CanRegisterThreads = true;

// =================================================================================
// Push Memory 
// =================================================================================
void ScriptHook::PushMemory(ScriptBinds::Memory::MemoryBlock* pMemBlock)
{
	if (pMemBlock == NULL || !pMemBlock->IsValid())
	{
		lua->PushString("ScriptHook::PushMemory failed! Invalid CMemoryBlock passed!");
		throw luabind::error(lua->State());
	}
	PushValue(pMemBlock->GetMemoryPointer()); 
}

int ScriptHook::GetGameTime()
{
#ifndef GTA_LUA_TEST_EXE
	NativeInit(0x9CD27B0045628463);
	return Call<int>();
#else
	return (int)GetTickCount();
#endif
}

int ScriptHook::GetGameTimer()
{
#ifndef GTA_LUA_TEST_EXE
	NativeInit(0x9CD27B0045628463);
	return Call<int>();
#else
	return (int)GetTickCount();
#endif
}


int ScriptHook::createTexture(const char *texFileName)
{
	return (int)createTexture(texFileName);
}

void ScriptHook::drawTexture(int id, int index, int level, int time, float sizeX, float sizeY, float centerX, float centerY, float posX, float posY, float rotation, float screenHeightScaleFactor, float r, float g, float b, float a)
{
	drawTexture(id, index, level, time, sizeX, sizeY, centerX, centerY, posX, posY, rotation, screenHeightScaleFactor, r, g, b, a);
}

int ScriptHook::worldGetAllVehicles(int * arr, int arrSize)
{
	return (int)worldGetAllVehicles(arr, arrSize);
}

int ScriptHook::worldGetAllPeds(int * arr, int arrSize)
{
	return (int)worldGetAllPeds(arr, arrSize);
}

int ScriptHook::worldGetAllObjects(int * arr, int arrSize)
{
	return (int)worldGetAllObjects(arr, arrSize);
}

int ScriptHook::worldGetAllPickups(int * arr, int arrSize)
{
	return (int)worldGetAllPickups(arr, arrSize);
}

static int ScriptHook::worldGetAllVehiclesWrapper()
{
	int arrSize;
	int *arr = new int[32];

	arrSize = worldGetAllVehicles(arr, 32);

	lua_State *L = lua_open();
	//	luaopen_base(L);
	//	luaopen_io(L);
	//	luaopen_string(L);
	//	luaopen_math(L);

	lua_newtable(L);

	int i;
	for (i = 1; i < arrSize; i++)
		lua_pushinteger(L, arr[i]);
	    lua_rawseti(L, -2, i + 1);

	lua_close(L);

	return 1;

}

static int ScriptHook::worldGetAllPedsWrapper()
{
	int arrSize;
	int *arr = new int[32];

	arrSize = worldGetAllPeds(arr, 32);

	lua_State *L = lua_open();
	//	luaopen_base(L);
	//	luaopen_io(L);
	//	luaopen_string(L);
	//	luaopen_math(L);

	lua_newtable(L);

	int i;
	for (i = 1; i < arrSize; i++)
		lua_pushinteger(L, arr[i]);
	    lua_rawseti(L, -2, i + 1);

	lua_close(L);

	return 1;
}


static int ScriptHook::worldGetAllObjectsWrapper()
{
	int arrSize;
	int *arr = new int[32];

	arrSize = worldGetAllObjects(arr, 32);

	lua_State *L = lua_open();
	//	luaopen_base(L);
	//	luaopen_io(L);
	//	luaopen_string(L);
	//	luaopen_math(L);

	lua_newtable(L);

	int i;
	for (i = 1; i < arrSize; i++)
		lua_pushinteger(L, arr[i]);
	    lua_rawseti(L, -2, i + 1);

	lua_close(L);

	return 1;

}


static int ScriptHook::worldGetAllPickupsWrapper()
{
	int arrSize;
	int *arr = new int[32];

	arrSize = worldGetAllPickups(arr, 32);

	lua_State *L = lua_open();
//	luaopen_base(L);
//	luaopen_io(L);
//	luaopen_string(L);
//	luaopen_math(L);

	lua_newtable(L);

	int i;
	for (i = 1; i < arrSize; i++)
		lua_pushinteger(L, arr[i]);
		lua_rawseti(L, -2, i + 1);

  	lua_close(L);

		return 1;
}



// =================================================================================
// Wrapper
// I don't want the imported functions to be global
// =================================================================================
UINT64 *ScriptHook::GetGlobalPtr(int globalId)
{
	return getGlobalPtr(globalId);
}
void ScriptHook::ScriptWait(DWORD dwTime)
{
#ifndef GTA_LUA_TEST_EXE
	scriptWait(dwTime);
#else
	Sleep(dwTime);
#endif
}
void ScriptHook::ScriptRegister(HMODULE hModule, ScriptHook_Callback ptr)
{
#ifndef GTA_LUA_TEST_EXE
	scriptRegister(hModule, ptr);
#endif
}
void ScriptHook::ScriptUnregister(HMODULE hModule)
{
#ifndef GTA_LUA_TEST_EXE
	scriptUnregister(hModule);
#endif
}

void ScriptHook::NativeInit(UINT64 hash)
{
#ifndef GTA_LUA_TEST_EXE
	nativeInit(hash);
#endif
}
void ScriptHook::NativePush64(UINT64 val)
{
#ifndef GTA_LUA_TEST_EXE
	nativePush64(val);
#endif
}
PUINT64 ScriptHook::NativeCall()
{
#ifndef GTA_LUA_TEST_EXE
	return nativeCall();
#else
	UINT64 p = 0;
	return &p;
#endif
}

int ScriptHook::GetGlobal(int GlobalId, int Offset)
{
	UINT64 *result = ScriptHook::GetGlobalPtr(GlobalId);
	if (result != nullptr)
	{
		result += Offset;
		if (result != nullptr)
		{
			return *result;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

void ScriptHook::SetGlobal(int GlobalId, int Offset, int Value)
{
	UINT64 *result = ScriptHook::GetGlobalPtr(GlobalId);
	if (result != nullptr)
	{
		result += Offset;
		DWORD dwOldProtection;
		VirtualProtect((void*)result, 8, PAGE_EXECUTE_READWRITE, &dwOldProtection);
		*result = Value;
		if (PAGE_EXECUTE_READWRITE != dwOldProtection)
		{
			VirtualProtect((void*)result, 8, dwOldProtection, &dwOldProtection);
		}
	}
}

void ScriptHook::KeyboardHandlerRegister(KeyboardHandler handler)
{
	keyboardHandlerRegister(handler);
}

void ScriptHook::KeyboardHandlerUnregister(KeyboardHandler handler)
{
	keyboardHandlerUnregister(handler);
}
