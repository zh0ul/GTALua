// =================================================================================
// Game Memory 
// =================================================================================
namespace GameMemory
{
	// Init
	void Init(int majorV, int minorV, int buildV, int revisionV );
	void FetchVersion(int majorV, int minorV, int buildV, int revisionV);

	// "Installers"
	void InstallInitHooks();
	void InstallHooks();

	// Module
	extern HMODULE GameModule;
	extern DWORD64 Base;
	extern DWORD64 Size;

	// Version
	extern char* Version;
	extern char* Version2;

	// Function Wrappers
	DWORD64 Find(BYTE* bMask, char* szMask);
	template <typename T>
	T Find(BYTE* bMask, char* szMask)
	{
		return (T) Find(bMask, szMask);
	}

	// Helper Functions
	DWORD64 FindAbsoluteAddress(BYTE* bMask, char* szMask, int iOffset);
	template <typename T>
	T FindAbsoluteAddress(BYTE* bMask, char* szMask, int iOffset)
	{
		return (T) FindAbsoluteAddress(bMask, szMask, iOffset);
	}

	DWORD64 At(DWORD64 dwOffset);
	template <typename T>
	T At(DWORD64 dwOffset)
	{
		return (T) At(dwOffset);
	}

	/*
	 * Content
	 */
	extern bool ScriptEngineInitialized;
}