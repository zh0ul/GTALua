-- Ped
class 'Ped'(Entity)

if not c_array_peds then c_array_peds = CMemoryBlock(512) end
if not c_array_vehs then c_array_vehs = CMemoryBlock(512) end
if not nearby_peds  then nearby_peds  = {}              ; end
if not nearby_vehs  then nearby_vehs  = {}              ; end

-- CTor
function Ped:__init(id)
	Entity.__init(self, id)
	
	self._type = "Ped"
end

-- Delete
function Ped:Delete()
	self:_CheckExists()
	local c_handle = CMemoryBlock(4)
	c_handle:WriteDWORD32(0, self.ID)
	natives.PED.DELETE_PED(c_handle)
	c_handle:Release()
end

--Set not needed
function Ped:SetNotNeeded()
	self:_CheckExists()
	local c_ped_handle = CMemoryBlock(4)
	c_ped_handle:WriteDWORD32(0, self.ID)
	natives.ENTITY.SET_PED_AS_NO_LONGER_NEEDED(c_ped_handle)
	c_ped_handle:Release()
end

-- Weapon Switching
function Ped:AllowWeaponSwitching(b)
	self:_CheckExists()
	if b == nil then b = true end
	
	natives.PED.SET_PED_CAN_SWITCH_WEAPON(self.ID, b)
end

-- Weapon
function Ped:DelayedGiveWeapon(wep, ammo)
	self:_CheckExists()
	if type(wep) == "string" then
		wep = natives.GAMEPLAY.GET_HASH_KEY(wep)
	end
	natives.WEAPON.GIVE_DELAYED_WEAPON_TO_PED(self.ID, wep, ammo, false)
end

function Ped:RemoveWeapon(wep)
	self:_CheckExists()
	if type(wep) == "string" then
		wep = natives.GAMEPLAY.GET_HASH_KEY(wep)
	end
	natives.WEAPON.REMOVE_WEAPON_FROM_PED(self.ID, wep)
end

function Ped:RemoveAllWeapons()
	natives.WEAPON.REMOVE_ALL_PED_WEAPONS(self.ID, true)
end

-- Group Member
function Ped:AddGroupMember(other_ped)
	self:_CheckExists()
	local group_id = other_ped
	if type(other_ped) == "Ped" or type(other_ped) == "Player" then
		group_id = other_ped:GetGroupIndex()
	end
	natives.PED.SET_PED_AS_GROUP_MEMBER(self.ID, group_id)
end
function Ped:GetGroupIndex()
	self:_CheckExists()
	return natives.PED.GET_PED_GROUP_INDEX(self.ID)
end

-- Vehicle
function Ped:IsInVehicle()
	self:_CheckExists()
	return natives.PED.IS_PED_IN_ANY_VEHICLE(self.ID, false)
end
function Ped:GetVehicle()
	self:_CheckExists()
	if self:IsInVehicle() then
		local veh = natives.PED.GET_VEHICLE_PED_IS_IN(self.ID, false)
		return Vehicle(veh)
	end
end

-- Armour
function Ped:SetArmour(i)
	self:_CheckExists()
	natives.PED.SET_PED_ARMOUR(self.ID, i)
end
Ped.SetArmor = Ped.SetArmour
function Ped:GetArmour()
	self:_CheckExists()
	return natives.PED.GET_PED_ARMOUR(self.ID)
end
Ped.GetArmor = Ped.GetArmour

-- Money
function Ped:SetMoney(i)
	self:_CheckExists()
	natives.PED.SET_PED_MONEY(self.ID, i)
end
function Ped:GetMoney()
	self:_CheckExists()
	return natives.PED.GET_PED_MONEY(self.ID)
end

-- Type
function Ped:GetType()
	self:_CheckExists()
	return natives.PED.GET_PED_TYPE(self.ID)
end

-- Nearby Peds
function Ped:GetNearbyPeds(max_peds)
	self:_CheckExists()
	
	-- default value
	max_peds = max_peds or 62
	
	-- c array
	local array_pad  = 8
	local array_size = array_pad * max_peds + array_pad
--local c_array_peds = CMemoryBlock(array_size * array_pad + array_pad ) -- Defined as a global so we dont have to keep defining it every call.
	
	-- index 0 defines the length of the array
	c_array_peds:WriteInt32(0, max_peds)

	-- call native
	local found=natives.PED.GET_PED_NEARBY_PEDS(self.ID, c_array_peds, -1)
	
	-- check returned peds
	local new_nearby_peds = {}
	local i=0
	while i<found do
		local offset = i*array_pad+array_pad
	  local ped = c_array_peds:ReadDWORD32(offset)
		if type(ped) == "number" and ped > 0 then  table.insert(new_nearby_peds, ped)  ; end
		i=i+1
	end
	-- release
	nearby_peds = new_nearby_peds
	return nearby_peds
end


--[[
-- All Peds
function Ped:GetAllPeds(max_peds)

	-- default value
	max_peds = max_peds or 62
	
	-- c array
	local array_pad  = 8
	local array_size = array_pad * max_peds + array_pad
--local c_array_peds = CMemoryBlock(array_size * array_pad + array_pad )
	
	-- index 0 defines the length of the array
	c_array_peds:WriteInt32(0, max_peds)

	-- call native
	local found = scripthookv.worldGetAllObjects(c_array_peds,max_peds)
	
	-- check returned peds
	local new_nearby_peds = {}
	local i=0
	while i<found do
		local offset = i*array_pad+array_pad
	  local ped = c_array_peds:ReadDWORD32(offset)
		if type(ped) == "number" and ped > 0 then  table.insert(new_nearby_peds, ped)  ; end
		i=i+1
	end
	-- release
	nearby_peds = new_nearby_peds
	return nearby_peds
end
--]]

--------------------
-- Nearby Vehicles
function Ped:GetNearbyVehicles(max_vehs)
	self:_CheckExists()
	
	-- default value
	max_vehs = math.min( 62, max_vehs or 10 )
	
	-- c array
	local array_pad  = 8
	local array_size = array_pad * max_vehs + array_pad
--local c_array_vehs = CMemoryBlock(array_size * 4 + array_pad)
	c_array_vehs:WriteInt32(0, max_vehs)
	
	-- call native
	local found=natives.PED.GET_PED_NEARBY_VEHICLES(self.ID, c_array_vehs)

	-- check
	local new_nearby_vehs = {}
	local i=0
  while i<found do
		local offset = i*array_pad+array_pad
	  local veh = c_array_vehs:ReadDWORD32(offset)
		if type(veh) == "number" and veh > 0 then  table.insert(new_nearby_vehs, veh)  ; end
		i=i+1
	end

	-- release
	nearby_vehs = new_nearby_vehs
	return nearby_vehs
end

-----------------------------------------
-- Set Ped into specified vehicle's seat
function Ped:SetIntoVehicle(vehicle, seat)
	self:_CheckExists()
	natives.PED.SET_PED_INTO_VEHICLE(self.ID, vehicle, seat);
end

-------------------------------------------
-- Explode Ped's head
function Ped:ExplodeHead(weapon)
	self:_CheckExists()
	natives.PED.EXPLODE_PED_HEAD(self.ID, weapon)
end

