// =================================================================================
// Includes
// =================================================================================
#include "Includes.h"
#include "Memory.h"
#include "GTALua.h"

// =================================================================================
// Member
// =================================================================================
char* GameMemory::Version  = NULL;
char* GameMemory::Version2 = NULL;

HMODULE GameMemory::GameModule = NULL;
DWORD64 GameMemory::Base = NULL;
DWORD64 GameMemory::Size = NULL;
bool GameMemory::ScriptEngineInitialized = false;

// =================================================================================
// Init
// =================================================================================
void GameMemory::Init(int majorV, int minorV, int buildV, int revisionV )
{
#ifndef GTA_LUA_TEST_EXE

	// FYI: Game version supported now comes from GTALua.ini

	// Module
	GameModule = GetModuleHandle("GTA5.exe");
	if (GameModule == NULL)
	{
		printf("GameMemory::Init GTA5.exe module not found!");
		return;
	}

	// Base
	Base = (DWORD64) GameModule;
	//printf("[GameMemory] Game Base: %p\n", Base);

	// Size
	Size = Memory::GetModuleSize(GameModule);
	//printf("[GameMemory] Game Size: %p\n", Size);

	// Content
	ScriptEngineInitialized = false;

	// Version
	FetchVersion( majorV, minorV, buildV, revisionV);

	// Version Check
	printf("===================================================================\n");
	printf("     Game Version: %s", Version);
	printf("Supported Version: %s", Version2);
	if (
	  //strcmp(Version, "1.0.350.1") == 0 ||
	  //strcmp(Version, "1.0.350.2") == 0 ||
	  //strcmp(Version, "1.0.372.1") == 0 ||
	  //strcmp(Version, "1.0.372.2") == 0 ||
	  //strcmp(Version, "1.0.393.2") == 0 ||
	  //strcmp(Version, "1.0.393.4") == 0 ||
	  //strcmp(Version, "1.0.440.2") == 0 ||
	  //strcmp(Version, "1.0.463.1") == 0 ||
	  //strcmp(Version, "1.0.505.2") == 0 ||
	  //strcmp(Version, "1.0.573.1") == 0 ||
	  //strcmp(Version, "1.0.617.1") == 0 ||
	  //strcmp(Version, "1.0.678.1") == 0 ||
	  //strcmp(Version, "1.0.944.2") == 0 ||
		strcmp(Version, Version2)    == 0
		)
	{
		printf("(Supported)\n");
	}
	else
	{
		printf("\nThis version may not be supported!\n");
	}
	printf("===================================================================\n");

	// Init Hook
	InstallInitHooks();
#else
	printf("[GameMemory] Disabled\n");
#endif
}

// =================================================================================
// Wrapper
// =================================================================================
DWORD64 GameMemory::Find(BYTE* bMask, char* szMask)
{
	return Memory::Find(Base, Size, bMask, szMask);
}

// =================================================================================
// Helper
// =================================================================================
DWORD64 GameMemory::At(DWORD64 dwOffset)
{
	return Base + dwOffset;
}
DWORD64 GameMemory::FindAbsoluteAddress(BYTE* bMask, char* szMask, int iOffset)
{
	DWORD64 dwInstruction = Find(bMask, szMask);
	if (dwInstruction == NULL) return NULL;

	dwInstruction += iOffset;
	return dwInstruction + *(uint32_t*)dwInstruction + 4;
}

// =================================================================================
// Version
// =================================================================================
void GameMemory::FetchVersion(int majorV, int minorV, int buildV, int revisionV)
{
	// One-Time-Only
	if (Version != NULL) return;

	// Game EXE
	char* sVersionFile = Memory::GetModulePath((HMODULE) Base);
	if (sVersionFile == NULL)
	{
		printf("GameMemory::FetchVersion failed [Memory::GetModulePath returned 0]\n");
		return;
	}

	// Version Info Size
	DWORD dwVersionInfoSize = GetFileVersionInfoSize(sVersionFile, NULL);
	if (dwVersionInfoSize == NULL)
	{
		printf("GameMemory::FetchVersion failed! [GetFileVersionInfoSize returned 0]\n");
		
		// Cleanup
		free(sVersionFile);

		return;
	}

	// Version Info
	VS_FIXEDFILEINFO* pFileInfo = (VS_FIXEDFILEINFO*) new BYTE[dwVersionInfoSize];
	DWORD dwVersionHandle = NULL;
	if (!GetFileVersionInfo(sVersionFile, dwVersionHandle, dwVersionInfoSize, pFileInfo))
	{
		printf("GameMemory::FetchVersion failed! [GetFileVersionInfo failed]\n");
		
		// Cleanup
		free(sVersionFile);
		delete[] pFileInfo;

		return;
	}

	// Query
	UINT uiFileInfoLength = 0;
	VS_FIXEDFILEINFO* pVersionInfo = NULL;
	if (!VerQueryValue(pFileInfo, "\\", (LPVOID*) &pVersionInfo, &uiFileInfoLength) || uiFileInfoLength == 0)
	{
		printf("GameMemory::FetchVersion failed! [VerQueryValue failed]\n");

		// Cleanup
		free(sVersionFile);
		delete[] pFileInfo;
		if (pVersionInfo != NULL)
			delete pVersionInfo;

		return;
	}

	// Signature
	if (pVersionInfo->dwSignature != 0xFEEF04BD)
	{
		printf("GameMemory::FetchVersion failed! [Signature mismatch, got %X]\n", pVersionInfo->dwSignature);

		// Cleanup
		free(sVersionFile);
		delete[] pFileInfo;
		if (pVersionInfo != NULL)
			delete pVersionInfo;

		return;
	}

	// Build Version String
	Version = new char[128];
	sprintf(Version, "%d.%d.%d.%d",
		(pVersionInfo->dwFileVersionMS >> 16) & 0xffff,
		(pVersionInfo->dwFileVersionMS >> 0) & 0xffff,
		(pVersionInfo->dwFileVersionLS >> 16) & 0xffff,
		(pVersionInfo->dwFileVersionLS >> 0) & 0xffff);

	// Build Version2 String
	Version2 = new char[128];
	sprintf(Version2, "%d.%d.%d.%d",
			majorV, 
			minorV,
			buildV,
			revisionV
	);


	// Cleanup
	free(sVersionFile);
	delete[] pFileInfo;
}