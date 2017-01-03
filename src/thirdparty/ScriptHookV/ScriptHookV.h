// =================================================================================
// ScriptHookV
// =================================================================================
// Forward Declarations
namespace ScriptBinds { namespace Memory { class MemoryBlock; }; };
typedef void(*ScriptHook_Callback)();

typedef void(*KeyboardHandler)(DWORD, WORD, BYTE, BOOL, BOOL, BOOL, BOOL);

// ScriptHook
namespace ScriptHook
{
	// Initialized
	extern bool CanRegisterThreads;

	// Imported
	UINT64 *GetGlobalPtr(int globalId);
	void ScriptWait(DWORD dwTime);
	void ScriptRegister(HMODULE hModule, ScriptHook_Callback ptr);
	void ScriptUnregister(HMODULE hModule);

	void NativeInit(UINT64 hash);
	void NativePush64(UINT64 val);
	PUINT64 NativeCall();

	int GetGlobal(int GlobalId, int Offset);
	void SetGlobal(int GlobalId, int Offset, int value);

	void KeyboardHandlerRegister(KeyboardHandler handler);
	void KeyboardHandlerUnregister(KeyboardHandler handler);

	// Helper
	int GetGameTime();
	int GetGameTimer();

	// Create Texture
	int createTexture(const char *texFileName);

	// Draw Texture
	void drawTexture(int id, int index, int level, int time, float sizeX, float sizeY, float centerX, float centerY, float posX, float posY, float rotation, float screenHeightScaleFactor, float r, float g, float b, float a);

	int worldGetAllVehicles(int *arr, int arrSize);
	int worldGetAllPeds(int *arr, int arrSize);
	int worldGetAllObjects(int *arr, int arrSize);
	int worldGetAllPickups(int *arr, int arrSize);

	static int worldGetAllVehiclesWrapper();
	static int worldGetAllPedsWrapper();
	static int worldGetAllObjectsWrapper();
	static int worldGetAllPickupsWrapper();

	// Push Value Wrapper
	template <typename T>
	static inline void PushValue(T val)
	{
		UINT64 val64 = NULL;
		*reinterpret_cast<T *>(&val64) = val;
		NativePush64(val64);
	}
	static inline void PushVector(rage::CVector vec)
	{
		PushValue(vec.x);
		PushValue(vec.y);
		PushValue(vec.z);
	}

	// Call Wrapper
	template <typename T>
	static inline T Call()
	{
		return *reinterpret_cast<T *>(NativeCall());
	}
	static inline void CallVoid()
	{
		NativeCall();
	}

	// Push: Memory Pointer
	void PushMemory(ScriptBinds::Memory::MemoryBlock* pMemBlock);
}