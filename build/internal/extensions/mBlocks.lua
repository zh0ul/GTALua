--[[
figlet -w 120 -f blocks.flf C Memory Blocks
                                                       .----------------.
                                                      | .--------------. |
                                                      | |     ______   | |
                                                      | |   /' ___  |  | |
                                                      | |  / .'   \_|  | |
                                                      | | |  |         | |
                                                      | |  \ `.___.'\  | |
                                                      | |   `._____.'  | |
                                                      | |              | |
                                                      | '--------------' |
                                                       '----------------'
     .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.
    | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
    | | ____    ____ | || |  _________   | || | ____    ____ | || |     ____     | || |  _______     | || |  ____  ____  | |
    | ||_   \  /   _|| || | |_   ___  |  | || ||_   \  /   _|| || |   .'    `.   | || | |_   __ \    | || | |_  _||_  _| | |
    | |  |   \/   |  | || |   | |_  \_|  | || |  |   \/   |  | || |  /  .--.  \  | || |   | |__) |   | || |   \ \  / /   | |
    | |  | |\  /| |  | || |   |  _|  _   | || |  | |\  /| |  | || |  | |    | |  | || |   |  __ /    | || |    \ \/ /    | |
    | | _| |_\/_| |_ | || |  _| |___/ |  | || | _| |_\/_| |_ | || |  \  `--'  /  | || |  _| |  \ \_  | || |    _|  |_    | |
    | ||_____||_____|| || | |_________|  | || ||_____||_____|| || |   `.____.'   | || | |____| |___| | || |   |______|   | |
    | |              | || |              | || |              | || |              | || |              | || |              | |
    | '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
     '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'
     .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.
    | .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
    | |   ______     | || |   _____      | || |     ____     | || |     ______   | || |  ___  ____   | || |    _______   | |
    | |  |_   _ \    | || |  |_   _|     | || |   .'    `.   | || |   .' ___  |  | || | |_  ||_  _|  | || |   /  ___  |  | |
    | |    | |_) |   | || |    | |       | || |  /  .--.  \  | || |  / .'   \_|  | || |   | |_/ /    | || |  |  (__ \_|  | |
    | |    |  __'.   | || |    | |   _   | || |  | |    | |  | || |  | |         | || |   |  __'.    | || |   '.___`-.   | |
    | |   _| |__) |  | || |   _| |__/ |  | || |  \  `--'  /  | || |  \ `.___.'\  | || |  _| |  \ \_  | || |  |`\____) |  | |
    | |  |_______/   | || |  |________|  | || |   `.____.'   | || |   `._____.'  | || | |____||____| | || |  |_______.'  | |
    | |              | || |              | || |              | || |              | || |              | || |              | |
    | '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
     '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'

    - Pre-Defined CMemory Blocks.
    - Saves time each frame by not having to re-define shared vars.
    - Saves time during dev, due to less crashing from improper handling.
    - Console command added to display C memory block information:  mblocks
    - mBlocks can be used without registering them first.
    - In fact, there is no register function as registration is automated through the use of metatables.
    - They are also reusable, even by different functions across different mods.

    ==========
    Example 1:
    ==========

    local veh = natives.PED.GET_VEHICLE_PED_IS_IN( natives.PLAYER.PLAYER_PED_ID(), false )

    if ( veh ~= 0 )
    then
        natives.VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(   veh, mBlocks[1], mBlocks[2], mBlocks[3] )
        natives.VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR( veh, mBlocks[4], mBlocks[5], mBlocks[6] )

        local custom1R,custom1G,custom1B = mBlocks[1]:ReadDWORD32(0), mBlocks[2]:ReadDWORD32(0), mBlocks[3]:ReadDWORD32(0)
        local custom2R,custom2G,custom2B = mBlocks[4]:ReadDWORD32(0), mBlocks[5]:ReadDWORD32(0), mBlocks[6]:ReadDWORD32(0)
    end

    ==========
    Example 2:
    ==========

    local veh = natives.PED.GET_VEHICLE_PED_IS_IN( natives.PLAYER.PLAYER_PED_ID(), false )

    if ( veh ~= 0 )
    then
        natives.VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(   veh, mBlocks.r1, mBlocks.g1, mBlocks.b1 )
        natives.VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR( veh, mBlocks.r2, mBlocks.g2, mBlocks.b2 )

        local custom1R,custom1G,custom1B = mBlocks.r1:ReadDWORD32(0), mBlocks.g1:ReadDWORD32(0), mBlocks.b1:ReadDWORD32(0)
        local custom2R,custom2G,custom2B = mBlocks.r2:ReadDWORD32(0), mBlocks.g2:ReadDWORD32(0), mBlocks.b2:ReadDWORD32(0)
    end

--]]



-- For testing outside of GTA environment.
-- Does not affect anything if CMemoryBlock already exists.
if not CMemoryBlock then CMemoryBlock = function() return("CMemoryBlock")  ;end ;end


-- Cleanup old memory blocks if this script is reloaded somehow.
if  mBlocksTable
then
    for k,v in pairs(mBlocksTable) do if type(v) == "CMemoryBlock" or type(v) == "string" then print("# mBlocks : Releasing old memory: "..tostring(k)) ; if v.Release then v:Release() ; end ; end ; end
end


-- Set mBlocks meta table.
mBlocks  = setmetatable(
              {},
              {
                __index   =
                  function (t, k, ...)
                    local arg = {...}
                    if mBlocksTable[k] then
                        if #arg ~= 0 and type(mBlocksTable[k]) ~= "function" then
                            mBlocksTable[k] = unpack(arg)
                        end
                        return mBlocksTable[k];
                    else
                        if #arg ~= 0 then
                            mBlocksTable[k] = unpack(arg)       ; mBlocksTable.count = mBlocksTable.count + 1
                        else
                            mBlocksTable[k] = CMemoryBlock(64)  ; mBlocksTable.count = mBlocksTable.count + 1
                        end
                        return mBlocksTable[k];
                    end;
                  end;
              }
            )

-- Set mBlocks actual table.
mBlocksTable = { count = 0, Release = function(k) if k and mBlocksTable[k] then if mBlocksTable[k].Release then mBlocksTable[k].Release() ;end ; mBlocksTable[k] = nil ; mBlocksTable.count = mBlocksTable.count -1 ; end; end; }

if debugTesting and testFunc then  testFunc( 10000, function() for i = 1,200 do local var = mBlocks[i] ;end  ;end )  ;end
if debugTesting and testFunc then  testFunc( 10000, function() for i = 1,200 do local var = mBlocks[i] ;end  ;end )  ;end

if    mBlocks.count and mBlocks.count < 48
then  for i = 1,48 do local tmpVar = mBlocks[i] ; end
end

--------------------------------------------------------------------------------

function mBlocksTable.Release(k) if k and mBlocksTable[k] then if mBlocksTable[k].Release then mBlocksTable[k].Release() ;end ; mBlocksTable[k] = nil ; mBlocksTable.count = mBlocksTable.count -1 ; end; end;

function mBlocksTable.Print(blocksFrom,blocksTo,readType,doNotHideInvalidValues)
--  1 = auto , 2 = DWORD32 , 3 = Float
    blocksFrom = tonumber(blocksFrom or  1 ) or  1
    blocksTo   = tonumber(blocksTo   or -1 ) or -1
    readType   = tonumber(readType   or  1 ) or  1
    local printProvider = echo or print
    local readTypeOrig = readType
    for i = 1,#mBlocksTable do
    for j = 0,4 do
        if ( blocksFrom <= i ) and ( ( blocksTo == -1 ) or ( blocksTo >= i )   )
        then
            if      ( readTypeOrig == 1 ) then  if not tostring(mBlocksTable[i]:ReadFloat(j*4)):find("e[+-]") then readType = 3 ; else readType = 2 ; end ; end

            if      ( readType == 3 ) then  printProvider( string.format( "%-28s = %22s",  "mBlocks["..tostring(i).."]:ReadFloat("   .. tostring(j*4) .. ")", tostring(mBlocksTable[i]:ReadFloat(j*4))   ) )
                                      else  printProvider( string.format( "%-28s = %22s",  "mBlocks["..tostring(i).."]:ReadDWORD32(" .. tostring(j*4) .. ")", tostring(mBlocksTable[i]:ReadDWORD32(j*4)) ) )
            end
        end
    end
    end

end

--------------------------------------------------------------------------------

-----------------------------------
-- Setup console command  'mblocks'
-----------------------------------
if    console and console.Commands
then  console.Commands["mblocks"] = function(...) mBlocksTable.Print(...) ; end;
end

--------------------------------------------------------------------------------
