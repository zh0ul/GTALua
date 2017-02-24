// =================================================================================
// Includes 
// =================================================================================
#include "Includes.h"
#include "UTIL.h"

// =======================
// Externs
// ======================

bool consoleAutomatic = true;
int consoleX = 1;
int consoleY = 1;
int consoleSizeX = 1440;
int consoleSizeY = 800;


// =================================================================================
// Console 
// _ needed
// =================================================================================
void UTIL::Attach_Console(bool bAutomatic, int x, int y, int xSize, int ySize)
{
	// Vars
	consoleAutomatic = bAutomatic;
	consoleX = x;
	consoleY = y;
	consoleSizeX = xSize;
	consoleSizeY = ySize;

	// Console
	AllocConsole();
	AttachConsole(GetCurrentProcessId());

	// Console Window
	HWND hConsole = GetConsoleWindow();
	RECT rect;
	GetWindowRect(hConsole, &rect);

	Show_Console();

	// Input/Output
	freopen("CON", "w", stdout);
	freopen("CONIN$", "r", stdin);
}

void UTIL::Show_Console()
{
	// Console Window
	HWND hConsole = GetConsoleWindow();
	RECT rect;
	GetWindowRect(hConsole, &rect);

	if (consoleAutomatic)
	{
		// Automatic Window Position
		//SetWindowPos(hConsole, HWND_NOTOPMOST, x, y, 1440, 900, SWP_SHOWWINDOW);
		SetWindowPos(hConsole, HWND_TOP, consoleX, consoleY, 1440, 800, SWP_SHOWWINDOW);
		ShowWindow(hConsole, SW_SHOW);
	}
	else
	{
		// Manual Window Position
		//SetWindowPos(hConsole, HWND_NOTOPMOST, x, y, xSize, ySize, SWP_SHOWWINDOW);
		SetWindowPos(hConsole, HWND_TOP, consoleX, consoleX, consoleSizeX, consoleSizeY, SWP_SHOWWINDOW);
		ShowWindow(hConsole, SW_SHOW);
	}

	printf("# Show_Console() Requested.\n");
}

// =================================================================================
// String 
// =================================================================================
void UTIL::ReplaceString(std::string& str, const std::string& from, const std::string& to)
{
	if (from.empty())
		return;
	size_t start_pos = 0;
	while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
		str.replace(start_pos, from.length(), to);
		start_pos += to.length();
	}
}
void UTIL::Lowercase(char* sText)
{
	for (char* it = sText; *it != '\0'; ++it)
	{
		*it = tolower(*it);
		++it;
	}
}
void UTIL::Uppercase(char* sText)
{
	for (char* it = sText; *it != '\0'; ++it)
	{
		*it = toupper(*it);
		++it;
	}
}

// =================================================================================
// File Names 
// =================================================================================
string UTIL::SplitFilename(string& str)
{
	size_t found;
	found = str.find_last_of("/");
	return str.substr(0, found);
}
void UTIL::ParseFilePath(std::string& path)
{
	ReplaceString(path, "\\", "/");
	ReplaceString(path, "/\\", "/");
	ReplaceString(path, "\\/", "/");
	ReplaceString(path, "//", "/");
}
vector<string> UTIL::SplitString(string str, string del)
{
	string temp;
	vector<string> res;
	while (temp != str)
	{
		temp = str.substr(0, str.find_first_of(del));
		str = str.substr(str.find_first_of(del) + 1);
		res.push_back(temp);
	}
	return res;
}