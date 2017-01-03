// =================================================================================
// Game Events
// =================================================================================
class Mutex;
namespace GameEvents
{
	enum eGameEvents
	{
		GAME_EVENT_PED_CREATED,
	    GAME_EVENT_VEHICLE_CREATED
	};
	struct GameEventCallback
	{
		GameEventCallback(eGameEvents typ, int param1 = 0, int param2 = 0)
		{
			eType = typ;
			param_1 = param1;
			param_2 = param2;
		}
		eGameEvents eType;
		int param_1;
		int param_2;
	};


	extern vector<GameEventCallback> vEventQueue;
	extern Mutex QueueMutex;
	void DispatchEvents();
	int GetEntityID(__int64* pEntity);


	//std::vector<Ped> peds;

	//const int ARR_SIZE = 1024; //max size of array to hold all the peds
	//Ped worldPeds[ARR_SIZE]; //array to hold all the peds
	//int numPedsInWorld = worldGetAllPeds(worldPeds, ARR_SIZE); //fills up worldPeds with peds, and returns the number of peds found as an int in numPedsInWorld
	//for (int i = 0; i < numPedsInWorld; i++) {
	//	if (canAddPed(worldPeds[i])) //just like in the vector example above...
	//		peds.push_back(worldPeds[i]); //move the peds you want from the array to the vector, because the vector is far more versatile
	//}


	namespace Install
	{
		void Entity();
		void OnPedCreated();
	  //void OnVehicleCreated();
	}

}