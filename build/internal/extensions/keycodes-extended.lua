-- keycodes-extended.lua

--[[    To load:

    LUA_KEYS, NATIVE_KEYS, NATIVE_KEYS_2, NATIVE_CONTROL_GROUPS = dofile("GTALua/internal/extensions/keycodes-extended.lua")

--]]


----------------------------
-- All Controllers Support
----------------------------
--[[
    If you use keys from NATIVE_KEYS then it works for both keyboard/controller.

    They also work with the native controller calls.

    Natives to use:
    --------------                                                                                 ________________________
    --                                                                                           \/                        \____ This is always 2 _____
    local is_control_just_pressed           = natives.CONTROLS.IS_CONTROL_JUST_PRESSED(           2, NATIVE_KEYS["JUMP"]  ) --  0 means keyboard-only
    local is_control_pressed                = natives.CONTROLS.IS_CONTROL_PRESSED(                2, NATIVE_KEYS["JUMP"]  ) --  1 means gamepad-only
    local is_control_just_released          = natives.CONTROLS.IS_CONTROL_JUST_RELEASED(          2, NATIVE_KEYS["JUMP"]  ) --  2 means 'on all inputs'
    local is_disabled_control_pressed       = natives.CONTROLS.IS_DISABLED_CONTROL_PRESSED(       2, NATIVE_KEYS["JUMP"]  )
    local is_disabled_control_just_pressed  = natives.CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED(  2, NATIVE_KEYS["JUMP"]  )
    local is_disabled_control_just_released = natives.CONTROLS.IS_DISABLED_CONTROL_JUST_RELEASED( 2, NATIVE_KEYS["JUMP"]  )

    natives.CONTROLS.DISABLE_CONTROL_ACTION( groupNum, NATIVE_KEYS[keyName] or NATIVE_KEYS_2[keyName], false )
    natives.CONTROLS.ENABLE_CONTROL_ACTION(  groupNum, NATIVE_KEYS[keyName] or NATIVE_KEYS_2[keyName], true  )

    natives.CONTROLS.DISABLE_ALL_CONTROL_ACTIONS(groupNum)
    natives.CONTROLS.ENABLE_ALL_CONTROL_ACTIONS(groupNum)

    Examples:

    -- Find out if the Shift/Sprint key was just released/let go.

    local sprintJustUp   = natives.CONTROLS.IS_CONTROL_JUST_RELEASED( 2, NATIVE_KEYS["SPRINT"] )

    -- Find out if the LCTRL/Sneak/Duck key is currently being held down.

    local sneakDown      = natives.CONTROLS.IS_CONTROL_PRESSED(       2, NATIVE_KEYS["DUCK"]   )

    -- Find out if the Jump key was just pushed down.
    -- If in a vehicle, JUMP is disabled, so we can fail over to VEH_HANDBRAKE using  or ...

    local spaceJustDown  = natives.CONTROLS.IS_CONTROL_JUST_PRESSED(  2, NATIVE_KEYS["JUMP"]   ) or  natives.CONTROLS.IS_CONTROL_JUST_PRESSED( 2, NATIVE_KEYS["VEH_HANDBRAKE"] )

    -- Disable a control 'in game', but still detect if its pressed.
    -- Like if you want to disable the horn in game, but still do something if horn is pressed.

    local keyName  = "PHONE"
    local keyGroup = 2
    natives.CONTROLS.DISABLE_CONTROL_ACTION( keyGroup, NATIVE_KEYS[keyName] or NATIVE_KEYS_2[keyName], false )
    local is_disabled_control_just_pressed  = natives.CONTROLS.IS_DISABLED_CONTROL_JUST_PRESSED( keyGroup, NATIVE_KEYS[keyName]  )
    if    is_disabled_control_just_pressed
    then  -- Do cool stuff instead of "PHONE"
    end

--]]

local NATIVE_KEYS = {
  ["NEXT_CAMERA"]                               = 0,
  ["LOOK_LR"]                                   = 1,
  ["LOOK_UD"]                                   = 2,
  ["LOOK_UP_ONLY"]                              = 3,
  ["LOOK_DOWN_ONLY"]                            = 4,
  ["LOOK_LEFT_ONLY"]                            = 5,
  ["LOOK_RIGHT_ONLY"]                           = 6,
  ["CINEMATIC_SLOWMO"]                          = 7,
  ["SCRIPTED_FLY_UD"]                           = 8,
  ["SCRIPTED_FLY_LR"]                           = 9,
  ["SCRIPTED_FLY_ZUP"]                          = 10,
  ["SCRIPTED_FLY_ZDOWN"]                        = 11,
  ["WEAPON_WHEEL_UD"]                           = 12,
  ["WEAPON_WHEEL_LR"]                           = 13,
  ["WEAPON_WHEEL_NEXT"]                         = 14,
  ["WEAPON_WHEEL_PREV"]                         = 15,
  ["SELECT_NEXT_WEAPON"]                        = 16,
  ["SELECT_PREV_WEAPON"]                        = 17,
  ["SKIP_CUTSCENE"]                             = 18,
  ["CHARACTER_WHEEL"]                           = 19,
  ["MULTIPLAYER_INFO"]                          = 20,
  ["SPRINT"]                                    = 21,
  ["JUMP"]                                      = 22,
  ["ENTER"]                                     = 23,
  ["ATTACK"]                                    = 24,
  ["AIM"]                                       = 25,
  ["LOOK_BEHIND"]                               = 26,
  ["PHONE"]                                     = 27,
  ["SPECIAL_ABILITY"]                           = 28,
  ["SPECIAL_ABILITY_SECONDARY"]                 = 29,
  ["MOVE_LR"]                                   = 30,
  ["MOVE_UD"]                                   = 31,
  ["MOVE_UP_ONLY"]                              = 32,
  ["MOVE_DOWN_ONLY"]                            = 33,
  ["MOVE_LEFT_ONLY"]                            = 34,
  ["MOVE_RIGHT_ONLY"]                           = 35,
  ["DUCK"]                                      = 36,
  ["SELECT_WEAPON"]                             = 37,
  ["PICKUP"]                                    = 38,
  ["SNIPER_ZOOM"]                               = 39,
  ["SNIPER_ZOOM_IN_ONLY"]                       = 40,
  ["SNIPER_ZOOM_OUT_ONLY"]                      = 41,
  ["SNIPER_ZOOM_IN_SECONDARY"]                  = 42,
  ["SNIPER_ZOOM_OUT_SECONDARY"]                 = 43,
  ["COVER"]                                     = 44,
  ["RELOAD"]                                    = 45,
  ["TALK"]                                      = 46,
  ["DETONATE"]                                  = 47,
  ["HUD_SPECIAL"]                               = 48,
  ["ARREST"]                                    = 49,
  ["ACCURATE_AIM"]                              = 50,
  ["CONTEXT"]                                   = 51,
  ["CONTEXT_SECONDARY"]                         = 52,
  ["WEAPON_SPECIAL"]                            = 53,
  ["WEAPON_SPECIAL_TWO"]                        = 54,
  ["DIVE"]                                      = 55,
  ["DROP_WEAPON"]                               = 56,
  ["DROP_AMMO"]                                 = 57,
  ["THROW_GRENADE"]                             = 58,
  ["VEH_MOVE_LR"]                               = 59,
  ["VEH_MOVE_UD"]                               = 60,
  ["VEH_MOVE_UP_ONLY"]                          = 61,
  ["VEH_MOVE_DOWN_ONLY"]                        = 62,
  ["VEH_MOVE_LEFT_ONLY"]                        = 63,
  ["VEH_MOVE_RIGHT_ONLY"]                       = 64,
  ["VEH_SPECIAL"]                               = 65,
  ["VEH_GUN_LR"]                                = 66,
  ["VEH_GUN_UD"]                                = 67,
  ["VEH_AIM"]                                   = 68,
  ["VEH_ATTACK"]                                = 69,
  ["VEH_ATTACK2"]                               = 70,
  ["VEH_ACCELERATE"]                            = 71,
  ["VEH_BRAKE"]                                 = 72,
  ["VEH_DUCK"]                                  = 73,
  ["VEH_HEADLIGHT"]                             = 74,
  ["VEH_EXIT"]                                  = 75,
  ["VEH_HANDBRAKE"]                             = 76,
  ["VEH_HOTWIRE_LEFT"]                          = 77,
  ["VEH_HOTWIRE_RIGHT"]                         = 78,
  ["VEH_LOOK_BEHIND"]                           = 79,
  ["VEH_CIN_CAM"]                               = 80,
  ["VEH_NEXT_RADIO"]                            = 81,
  ["VEH_PREV_RADIO"]                            = 82,
  ["VEH_NEXT_RADIO_TRACK"]                      = 83,
  ["VEH_PREV_RADIO_TRACK"]                      = 84,
  ["VEH_RADIO_WHEEL"]                           = 85,
  ["VEH_HORN"]                                  = 86,
  ["VEH_FLY_THROTTLE_UP"]                       = 87,
  ["VEH_FLY_THROTTLE_DOWN"]                     = 88,
  ["VEH_FLY_YAW_LEFT"]                          = 89,
  ["VEH_FLY_YAW_RIGHT"]                         = 90,
  ["VEH_PASSENGER_AIM"]                         = 91,
  ["VEH_PASSENGER_ATTACK"]                      = 92,
  ["VEH_SPECIAL_ABILITY_FRANKLIN"]              = 93,
  ["VEH_STUNT_UD"]                              = 94,
  ["VEH_CINEMATIC_UD"]                          = 95,
  ["VEH_CINEMATIC_UP_ONLY"]                     = 96,
  ["VEH_CINEMATIC_DOWN_ONLY"]                   = 97,
  ["VEH_CINEMATIC_LR"]                          = 98,
  ["VEH_SELECT_NEXT_WEAPON"]                    = 99,
  ["VEH_SELECT_PREV_WEAPON"]                    = 100,
  ["VEH_ROOF"]                                  = 101,
  ["VEH_JUMP"]                                  = 102,
  ["VEH_GRAPPLING_HOOK"]                        = 103,
  ["VEH_SHUFFLE"]                               = 104,
  ["VEH_DROP_PROJECTILE"]                       = 105,
  ["VEH_MOUSE_CONTROL_OVERRIDE"]                = 106,
  ["VEH_FLY_ROLL_LR"]                           = 107,
  ["VEH_FLY_ROLL_LEFT_ONLY"]                    = 108,
  ["VEH_FLY_ROLL_RIGHT_ONLY"]                   = 109,
  ["VEH_FLY_PITCH_UD"]                          = 110,
  ["VEH_FLY_PITCH_UP_ONLY"]                     = 111,
  ["VEH_FLY_PITCH_DOWN_ONLY"]                   = 112,
  ["VEH_FLY_UNDERCARRIAGE"]                     = 113,
  ["VEH_FLY_ATTACK"]                            = 114,
  ["VEH_FLY_SELECT_NEXT_WEAPON"]                = 115,
  ["VEH_FLY_SELECT_PREV_WEAPON"]                = 116,
  ["VEH_FLY_SELECT_TARGET_LEFT"]                = 117,
  ["VEH_FLY_SELECT_TARGET_RIGHT"]               = 118,
  ["VEH_FLY_VERTICAL_FLIGHT_MODE"]              = 119,
  ["VEH_FLY_DUCK"]                              = 120,
  ["VEH_FLY_ATTACK_CAMERA"]                     = 121,
  ["VEH_FLY_MOUSE_CONTROL_OVERRIDE"]            = 122,
  ["VEH_SUB_TURN_LR"]                           = 123,
  ["VEH_SUB_TURN_LEFT_ONLY"]                    = 124,
  ["VEH_SUB_TURN_RIGHT_ONLY"]                   = 125,
  ["VEH_SUB_PITCH_UD"]                          = 126,
  ["VEH_SUB_PITCH_UP_ONLY"]                     = 127,
  ["VEH_SUB_PITCH_DOWN_ONLY"]                   = 128,
  ["VEH_SUB_THROTTLE_UP"]                       = 129,
  ["VEH_SUB_THROTTLE_DOWN"]                     = 130,
  ["VEH_SUB_ASCEND"]                            = 131,
  ["VEH_SUB_DESCEND"]                           = 132,
  ["VEH_SUB_TURN_HARD_LEFT"]                    = 133,
  ["VEH_SUB_TURN_HARD_RIGHT"]                   = 134,
  ["VEH_SUB_MOUSE_CONTROL_OVERRIDE"]            = 135,
  ["VEH_PUSHBIKE_PEDAL"]                        = 136,
  ["VEH_PUSHBIKE_SPRINT"]                       = 137,
  ["VEH_PUSHBIKE_FRONT_BRAKE"]                  = 138,
  ["VEH_PUSHBIKE_REAR_BRAKE"]                   = 139,
  ["MELEE_ATTACK_LIGHT"]                        = 140,
  ["MELEE_ATTACK_HEAVY"]                        = 141,
  ["MELEE_ATTACK_ALTERNATE"]                    = 142,
  ["MELEE_BLOCK"]                               = 143,
  ["PARACHUTE_DEPLOY"]                          = 144,
  ["PARACHUTE_DETACH"]                          = 145,
  ["PARACHUTE_TURN_LR"]                         = 146,
  ["PARACHUTE_TURN_LEFT_ONLY"]                  = 147,
  ["PARACHUTE_TURN_RIGHT_ONLY"]                 = 148,
  ["PARACHUTE_PITCH_UD"]                        = 149,
  ["PARACHUTE_PITCH_UP_ONLY"]                   = 150,
  ["PARACHUTE_PITCH_DOWN_ONLY"]                 = 151,
  ["PARACHUTE_BRAKE_LEFT"]                      = 152,
  ["PARACHUTE_BRAKE_RIGHT"]                     = 153,
  ["PARACHUTE_SMOKE"]                           = 154,
  ["PARACHUTE_PRECISION_LANDING"]               = 155,
  ["MAP"]                                       = 156,
  ["SELECT_WEAPON_UNARMED"]                     = 157, -- 1
  ["SELECT_WEAPON_MELEE"]                       = 158, -- 2
  ["SELECT_WEAPON_HANDGUN"]                     = 159, -- 6
  ["SELECT_WEAPON_SHOTGUN"]                     = 160, -- 3
  ["SELECT_WEAPON_SMG"]                         = 161, -- 7
  ["SELECT_WEAPON_AUTO_RIFLE"]                  = 162, -- 8
  ["SELECT_WEAPON_SNIPER"]                      = 163, -- 9
  ["SELECT_WEAPON_HEAVY"]                       = 164, -- 4
  ["SELECT_WEAPON_SPECIAL"]                     = 165, -- 5
  ["SELECT_CHARACTER_MICHAEL"]                  = 166,
  ["SELECT_CHARACTER_FRANKLIN"]                 = 167,
  ["SELECT_CHARACTER_TREVOR"]                   = 168,
  ["SELECT_CHARACTER_MULTIPLAYER"]              = 169,
  ["SAVE_REPLAY_CLIP"]                          = 170,
  ["SPECIAL_ABILITY_PC"]                        = 171,
  ["CELLPHONE_UP"]                              = 172,
  ["CELLPHONE_DOWN"]                            = 173,
  ["CELLPHONE_LEFT"]                            = 174,
  ["CELLPHONE_RIGHT"]                           = 175,
  ["CELLPHONE_SELECT"]                          = 176,
  ["CELLPHONE_CANCEL"]                          = 177,
  ["CELLPHONE_OPTION"]                          = 178,
  ["CELLPHONE_EXTRA_OPTION"]                    = 179,
  ["CELLPHONE_SCROLL_FORWARD"]                  = 180,
  ["CELLPHONE_SCROLL_BACKWARD"]                 = 181,
  ["CELLPHONE_CAMERA_FOCUS_LOCK"]               = 182,
  ["CELLPHONE_CAMERA_GRID"]                     = 183,
  ["CELLPHONE_CAMERA_SELFIE"]                   = 184,
  ["CELLPHONE_CAMERA_DOF"]                      = 185,
  ["CELLPHONE_CAMERA_EXPRESSION"]               = 186,
  ["FRONTEND_DOWN"]                             = 187,
  ["FRONTEND_UP"]                               = 188,
  ["FRONTEND_LEFT"]                             = 189,
  ["FRONTEND_RIGHT"]                            = 190,
  ["FRONTEND_RDOWN"]                            = 191,
  ["FRONTEND_RUP"]                              = 192,
  ["FRONTEND_RLEFT"]                            = 193,
  ["FRONTEND_RRIGHT"]                           = 194,
  ["FRONTEND_AXIS_X"]                           = 195,
  ["FRONTEND_AXIS_Y"]                           = 196,
  ["FRONTEND_RIGHT_AXIS_X"]                     = 197,
  ["FRONTEND_RIGHT_AXIS_Y"]                     = 198,
  ["FRONTEND_PAUSE"]                            = 199,
  ["FRONTEND_PAUSE_ALTERNATE"]                  = 200,
  ["FRONTEND_ACCEPT"]                           = 201,
  ["FRONTEND_CANCEL"]                           = 202,
  ["FRONTEND_X"]                                = 203,
  ["FRONTEND_Y"]                                = 204,
  ["FRONTEND_LB"]                               = 205,
  ["FRONTEND_RB"]                               = 206,
  ["FRONTEND_LT"]                               = 207,
  ["FRONTEND_RT"]                               = 208,
  ["FRONTEND_LS"]                               = 209,
  ["FRONTEND_RS"]                               = 210,
  ["FRONTEND_LEADERBOARD"]                      = 211,
  ["FRONTEND_SOCIAL_CLUB"]                      = 212,
  ["FRONTEND_SOCIAL_CLUB_SECONDARY"]            = 213,
  ["FRONTEND_DELETE"]                           = 214,
  ["FRONTEND_ENDSCREEN_ACCEPT"]                 = 215,
  ["FRONTEND_ENDSCREEN_EXPAND"]                 = 216,
  ["FRONTEND_SELECT"]                           = 217,
  ["SCRIPT_LEFT_AXIS_X"]                        = 218,
  ["SCRIPT_LEFT_AXIS_Y"]                        = 219,
  ["SCRIPT_RIGHT_AXIS_X"]                       = 220,
  ["SCRIPT_RIGHT_AXIS_Y"]                       = 221,
  ["SCRIPT_RUP"]                                = 222,
  ["SCRIPT_RDOWN"]                              = 223,
  ["SCRIPT_RLEFT"]                              = 224,
  ["SCRIPT_RRIGHT"]                             = 225,
  ["SCRIPT_LB"]                                 = 226,
  ["SCRIPT_RB"]                                 = 227,
  ["SCRIPT_LT"]                                 = 228,
  ["SCRIPT_RT"]                                 = 229,
  ["SCRIPT_LS"]                                 = 230,
  ["SCRIPT_RS"]                                 = 231,
  ["SCRIPT_PAD_UP"]                             = 232,
  ["SCRIPT_PAD_DOWN"]                           = 233,
  ["SCRIPT_PAD_LEFT"]                           = 234,
  ["SCRIPT_PAD_RIGHT"]                          = 235,
  ["SCRIPT_SELECT"]                             = 236,
  ["CURSOR_ACCEPT"]                             = 237,
  ["CURSOR_CANCEL"]                             = 238,
  ["CURSOR_X"]                                  = 239,
  ["CURSOR_Y"]                                  = 240,
  ["CURSOR_SCROLL_UP"]                          = 241,
  ["CURSOR_SCROLL_DOWN"]                        = 242,
  ["ENTER_CHEAT_CODE"]                          = 243,
  ["INTERACTION_MENU"]                          = 244,
  ["MP_TEXT_CHAT_ALL"]                          = 245,
  ["MP_TEXT_CHAT_TEAM"]                         = 246,
  ["MP_TEXT_CHAT_FRIENDS"]                      = 247,
  ["MP_TEXT_CHAT_CREW"]                         = 248,
  ["PUSH_TO_TALK"]                              = 249,
  ["CREATOR_LS"]                                = 250,
  ["CREATOR_RS"]                                = 251,
  ["CREATOR_LT"]                                = 252,
  ["CREATOR_RT"]                                = 253,
  ["CREATOR_MENU_TOGGLE"]                       = 254,
  ["CREATOR_ACCEPT"]                            = 255,
  ["CREATOR_DELETE"]                            = 256,
  ["ATTACK2"]                                   = 257,
  ["RAPPEL_JUMP"]                               = 258,
  ["RAPPEL_LONG_JUMP"]                          = 259,
  ["RAPPEL_SMASH_WINDOW"]                       = 260,
  ["PREV_WEAPON"]                               = 261,
  ["NEXT_WEAPON"]                               = 262,
  ["MELEE_ATTACK1"]                             = 263,
  ["MELEE_ATTACK2"]                             = 264,
  ["WHISTLE"]                                   = 265,
  ["MOVE_LEFT"]                                 = 266,
  ["MOVE_RIGHT"]                                = 267,
  ["MOVE_UP"]                                   = 268,
  ["MOVE_DOWN"]                                 = 269,
  ["LOOK_LEFT"]                                 = 270,
  ["LOOK_RIGHT"]                                = 271,
  ["LOOK_UP"]                                   = 272,
  ["LOOK_DOWN"]                                 = 273,
  ["SNIPER_ZOOM_IN"]                            = 274,
  ["SNIPER_ZOOM_OUT"]                           = 275,
  ["SNIPER_ZOOM_IN_ALTERNATE"]                  = 276,
  ["SNIPER_ZOOM_OUT_ALTERNATE"]                 = 277,
  ["VEH_MOVE_LEFT"]                             = 278,
  ["VEH_MOVE_RIGHT"]                            = 279,
  ["VEH_MOVE_UP"]                               = 280,
  ["VEH_MOVE_DOWN"]                             = 281,
  ["VEH_GUN_LEFT"]                              = 282,
  ["VEH_GUN_RIGHT"]                             = 283,
  ["VEH_GUN_UP"]                                = 284,
  ["VEH_GUN_DOWN"]                              = 285,
  ["VEH_LOOK_LEFT"]                             = 286,
  ["VEH_LOOK_RIGHT"]                            = 287,
  ["REPLAY_START_STOP_RECORDING"]               = 288,
  ["REPLAY_START_STOP_RECORDING_SECONDARY"]     = 289,
  ["SCALED_LOOK_LR"]                            = 290,
  ["SCALED_LOOK_UD"]                            = 291,
  ["SCALED_LOOK_UP_ONLY"]                       = 292,
  ["SCALED_LOOK_DOWN_ONLY"]                     = 293,
  ["SCALED_LOOK_LEFT_ONLY"]                     = 294,
  ["SCALED_LOOK_RIGHT_ONLY"]                    = 295,
  ["REPLAY_MARKER_DELETE"]                      = 296,
  ["REPLAY_CLIP_DELETE"]                        = 297,
  ["REPLAY_PAUSE"]                              = 298,
  ["REPLAY_REWIND"]                             = 299,
  ["REPLAY_FFWD"]                               = 300,
  ["REPLAY_NEWMARKER"]                          = 301,
  ["REPLAY_RECORD"]                             = 302,
  ["REPLAY_SCREENSHOT"]                         = 303,
  ["REPLAY_HIDEHUD"]                            = 304,
  ["REPLAY_STARTPOINT"]                         = 305,
  ["REPLAY_ENDPOINT"]                           = 306,
  ["REPLAY_ADVANCE"]                            = 307,
  ["REPLAY_BACK"]                               = 308,
  ["REPLAY_TOOLS"]                              = 309,
  ["REPLAY_RESTART"]                            = 310,
  ["REPLAY_SHOWHOTKEY"]                         = 311,
  ["REPLAY_CYCLEMARKERLEFT"]                    = 312,
  ["REPLAY_CYCLEMARKERRIGHT"]                   = 313,
  ["REPLAY_FOVINCREASE"]                        = 314,
  ["REPLAY_FOVDECREASE"]                        = 315,
  ["REPLAY_CAMERAUP"]                           = 316,
  ["REPLAY_CAMERADOWN"]                         = 317,
  ["REPLAY_SAVE"]                               = 318,
  ["REPLAY_TOGGLETIME"]                         = 319,
  ["REPLAY_TOGGLETIPS"]                         = 320,
  ["REPLAY_PREVIEW"]                            = 321,
  ["REPLAY_TOGGLE_TIMELINE"]                    = 322,
  ["REPLAY_TIMELINE_PICKUP_CLIP"]               = 323,
  ["REPLAY_TIMELINE_DUPLICATE_CLIP"]            = 324,
  ["REPLAY_TIMELINE_PLACE_CLIP"]                = 325,
  ["REPLAY_CTRL"]                               = 326,
  ["REPLAY_TIMELINE_SAVE"]                      = 327,
  ["REPLAY_PREVIEW_AUDIO"]                      = 328,
  ["VEH_DRIVE_LOOK"]                            = 329,
  ["VEH_DRIVE_LOOK2"]                           = 330,
  ["VEH_FLY_ATTACK2"]                           = 331,
  ["RADIO_WHEEL_UD"]                            = 332,
  ["RADIO_WHEEL_LR"]                            = 333,
  ["VEH_SLOWMO_UD"]                             = 334,
  ["VEH_SLOWMO_UP_ONLY"]                        = 335,
  ["VEH_SLOWMO_DOWN_ONLY"]                      = 336,
  ["MAP_POI"]                                   = 337,

  -----------------------------------
  --    XBOX Controller Support    --
  -----------------------------------
  ["XBOX_A"]            = 18, -- 0x12
  ["XBOX_B"]            = 45, -- 0x2d
  ["XBOX_X"]            = 22, -- 0x16
  ["XBOX_Y"]            = 23, -- 0x17
  ["XBOX_LB"]           = 37, -- 0x25
  ["XBOX_RB"]           = 44, -- 0x2c
  ["XBOX_L2"]           = 10, -- 0x0a
  ["XBOX_R2"]           = 11, -- 0x0b
  ["XBOX_L3"]           = 28, -- 0x1c
  ["XBOX_R3"]           = 29, -- 0x1d
  ["XBOX_SELECT"]       = 0,  -- 0x00
  ["XBOX_START"]        = 1,  -- 0x01

  -- D-PAD:
  ["XBOX_LEFT"]         = 15, -- 0x0f
  ["XBOX_RIGHT"]        = 74, -- 0x4a
  ["XBOX_UP"]           = 27, -- 0x1b
  ["XBOX_DOWN"]         = 19, -- 0x13

  -- LEFT-STICK:
  ["XBOX_LSTICK_LEFT"]  = 34, -- 0x22
  ["XBOX_LSTICK_RIGHT"] = 9,  -- 0x09
  ["XBOX_LSTICK_UP"]    = 32, -- 0x20
  ["XBOX_LSTICK_DOWN"]  = 8,  -- 0x08

  -- RIGHT-STICK:
  ["XBOX_RSTICK_LEFT"]  = 5,  -- 0x05
  ["XBOX_RSTICK_RIGHT"] = 1,  -- 0x01
  ["XBOX_RSTICK_UP"]    = 3,  -- 0x03
  ["XBOX_RSTICK_DOWN"]  = 2,  -- 0x02

  ------------------------------------
  --     PSX Controller Support     --
  ------------------------------------
  ["PSX_X"]             = 0xBE, -- 190
  ["PSX_CIRCLE"]        = 0xC0, -- 192
  ["PSX_SQUARE"]        = 0xBF, -- 191
  ["PSX_TRIANGLE"]      = 0xBD, -- 189
  ["PSX_SELECT"]        = 0xCB, -- 203
  ["PSX_L1"]            = 0xC1, -- 193
  ["PSX_L2"]            = 0xC3, -- 195
  ["PSX_L3"]            = 0xC5, -- 197
  ["PSX_R1"]            = 0xC2, -- 194
  ["PSX_R2"]            = 0xC4, -- 196
  ["PSX_R3"]            = 0xC6, -- 198
  ["PSX_DPADUP"]        = 0xC7, -- 199
  ["PSX_DPADDOWN"]      = 0xC8, -- 200
  ["PSX_DPADLEFT"]      = 0xC9, -- 201
  ["PSX_DPADRIGHT"]     = 0xCA, -- 202
}


local NATIVE_KEYS_2 = {
    [8] = "S",
    [9] = "D",
   [10] = "PAGE_UP",
   [11] = "PAGE_DOWN",
   [12] = "MOUSE_MOVE_DOWN",
   [13] = "MOUSE_MOVE_RIGHT",
   [18] = "SPACE_OR_ENTER",
   [19] = "L_ALT",
   [20] = "Z",
   [21] = "L_SHIFT",
   [23] = "F",
   [32] = "W",
   [34] = "A",
   [36] = "L_CTRL",
   [39] = "[",
   [40] = "]",
   [44] = "Q",
   [45] = "R",
   [51] = "E",
   [56] = "F9",
   [57] = "F10",
   [58] = "G",
   [60] = "NUM_PAD_5",
   [61] = "NUM_PAD_8",
  [197] = "]",
  [199] = "P",
  [202] = "BACKSPACE",
  [205] = "Q",
  [206] = "E",
  [209] = "L_SHIFT",
  [211] = "TAB",
  [213] = "HOME",
  [214] = "DEL",
  [215] = "ENTER",
  [216] = "SPACEBAR",
  [217] = "CAPS_LOCK",
  [224] = "L_CTRL",
  [232] = "W",
  [233] = "S",
  [234] = "A",
  [235] = "D",
  [236] = "V",
  [239] = "CAM_+",
  [240] = "CAM_-",
  [243] = "~",
  [244] = "M",
  [245] = "T",
  [246] = "Y",
  [249] = "N",
}


local NATIVE_CONTROL_GROUPS = {

  --[[--
        Use like:

        natives.CONTROLS.DISABLE_CONTROL_ACTION( 0, NATIVE_CONTROL_GROUPS["INPUTGROUP_WEAPON_WHEEL_CYCLE"], true  ) -- Disable weapon wheel cycle
        natives.CONTROLS.DISABLE_CONTROL_ACTION( 0, NATIVE_CONTROL_GROUPS["INPUTGROUP_WEAPON_WHEEL_CYCLE"], false ) -- Enable  weapon wheel cycle

        Or:

        natives.CONTROLS.DISABLE_ALL_CONTROL_ACTIONS( NATIVE_CONTROL_GROUPS["INPUTGROUP_WEAPON_WHEEL_CYCLE"] )

  --]]--
        ["INPUTGROUP_MOVE"] = 0,
        ["INPUTGROUP_LOOK"] = 1,
        ["INPUTGROUP_WHEEL"] = 2,
        ["INPUTGROUP_CELLPHONE_NAVIGATE"] = 3,
        ["INPUTGROUP_CELLPHONE_NAVIGATE_UD"] = 4,
        ["INPUTGROUP_CELLPHONE_NAVIGATE_LR"] = 5,
        ["INPUTGROUP_FRONTEND_DPAD_ALL"] = 6,
        ["INPUTGROUP_FRONTEND_DPAD_UD"] = 7,
        ["INPUTGROUP_FRONTEND_DPAD_LR"] = 8,
        ["INPUTGROUP_FRONTEND_LSTICK_ALL"] = 9,
        ["INPUTGROUP_FRONTEND_RSTICK_ALL"] = 10,
        ["INPUTGROUP_FRONTEND_GENERIC_UD"] = 11,
        ["INPUTGROUP_FRONTEND_GENERIC_LR"] = 12,
        ["INPUTGROUP_FRONTEND_GENERIC_ALL"]= 13,
        ["INPUTGROUP_FRONTEND_BUMPERS"] = 14,
        ["INPUTGROUP_FRONTEND_TRIGGERS"] = 15,
        ["INPUTGROUP_FRONTEND_STICKS"] = 16,
        ["INPUTGROUP_SCRIPT_DPAD_ALL"]= 17,
        ["INPUTGROUP_SCRIPT_DPAD_UD"] = 18,
        ["INPUTGROUP_SCRIPT_DPAD_LR"] = 19,
        ["INPUTGROUP_SCRIPT_LSTICK_ALL"] = 20,
        ["INPUTGROUP_SCRIPT_RSTICK_ALL"] = 21,
        ["INPUTGROUP_SCRIPT_BUMPERS"] = 22,
        ["INPUTGROUP_SCRIPT_TRIGGERS"] = 23,
        ["INPUTGROUP_WEAPON_WHEEL_CYCLE"] = 24,
        ["INPUTGROUP_FLY"] = 25,
        ["INPUTGROUP_SUB"] = 26,
        ["INPUTGROUP_VEH_MOVE_ALL"] = 27,
        ["INPUTGROUP_CURSOR"] = 28,
        ["INPUTGROUP_CURSOR_SCROLL"] = 29,
        ["INPUTGROUP_SNIPER_ZOOM_SECONDARY"] = 30,
        ["INPUTGROUP_VEH_HYDRAULICS_CONTROL"] = 31,
        ["MAX_INPUTGROUPS"] = 32,
        ["INPUTGROUP_INVALID"] = 33,
 }


local LUA_KEYS    = {
  ["KEY_LBUTTON"] = 1,
  ["KEY_RBUTTON"] = 2,
   ["KEY_CANCEL"] = 3,
  ["KEY_MBUTTON"] = 4,
     ["KEY_BACK"] = 8,
      ["KEY_TAB"] = 9,
    ["KEY_CLEAR"] = 12,
   ["KEY_RETURN"] = 13,
    ["KEY_SHIFT"] = 16,
  ["KEY_CONTROL"] = 17,
     ["KEY_MENU"] = 18,
    ["KEY_PAUSE"] = 19,
  ["KEY_CAPITAL"] = 20,
   ["KEY_ESCAPE"] = 27,
    ["KEY_SPACE"] = 32,
    ["KEY_PRIOR"] = 33,
     ["KEY_NEXT"] = 34,
      ["KEY_END"] = 35,
     ["KEY_HOME"] = 36,
     ["KEY_LEFT"] = 37,
       ["KEY_UP"] = 38,
    ["KEY_RIGHT"] = 39,
     ["KEY_DOWN"] = 40,
   ["KEY_SELECT"] = 41,
    ["KEY_PRINT"] = 42,
  ["KEY_EXECUTE"] = 43,
 ["KEY_SNAPSHOT"] = 44,
   ["KEY_INSERT"] = 45,
   ["KEY_DELETE"] = 46,
     ["KEY_HELP"] = 47,
        ["KEY_0"] = 48,
        ["KEY_1"] = 49,
        ["KEY_2"] = 50,
        ["KEY_3"] = 51,
        ["KEY_4"] = 52,
        ["KEY_5"] = 53,
        ["KEY_6"] = 54,
        ["KEY_7"] = 55,
        ["KEY_8"] = 56,
        ["KEY_9"] = 57,
        ["KEY_A"] = 65,
        ["KEY_B"] = 66,
        ["KEY_C"] = 67,
        ["KEY_D"] = 68,
        ["KEY_E"] = 69,
        ["KEY_F"] = 70,
        ["KEY_G"] = 71,
        ["KEY_H"] = 72,
        ["KEY_I"] = 73,
        ["KEY_J"] = 74,
        ["KEY_K"] = 75,
        ["KEY_L"] = 76,
        ["KEY_M"] = 77,
        ["KEY_N"] = 78,
        ["KEY_O"] = 79,
        ["KEY_P"] = 80,
        ["KEY_Q"] = 81,
        ["KEY_R"] = 82,
        ["KEY_S"] = 83,
        ["KEY_T"] = 84,
        ["KEY_U"] = 85,
        ["KEY_V"] = 86,
        ["KEY_W"] = 87,
        ["KEY_X"] = 88,
        ["KEY_Y"] = 89,
        ["KEY_Z"] = 90,
     ["KEY_LWIN"] = 91,
     ["KEY_RWIN"] = 92,
     ["KEY_APPS"] = 93,
  ["KEY_NUMPAD0"] = 96,
  ["KEY_NUMPAD1"] = 97,
  ["KEY_NUMPAD2"] = 98,
  ["KEY_NUMPAD3"] = 99,
  ["KEY_NUMPAD4"] = 100,
  ["KEY_NUMPAD5"] = 101,
  ["KEY_NUMPAD6"] = 102,
  ["KEY_NUMPAD7"] = 103,
  ["KEY_NUMPAD8"] = 104,
  ["KEY_NUMPAD9"] = 105,
 ["KEY_MULTIPLY"] = 106,
      ["KEY_ADD"] = 107,
["KEY_SEPARATOR"] = 108,
 ["KEY_SUBTRACT"] = 109,
  ["KEY_DECIMAL"] = 110,
   ["KEY_DIVIDE"] = 111,
       ["KEY_F1"] = 112,
       ["KEY_F2"] = 113,
       ["KEY_F3"] = 114,
       ["KEY_F4"] = 115,
       ["KEY_F5"] = 116,
       ["KEY_F6"] = 117,
       ["KEY_F7"] = 118,
       ["KEY_F8"] = 119,
       ["KEY_F9"] = 120,
      ["KEY_F10"] = 121,
      ["KEY_F11"] = 122,
      ["KEY_F12"] = 123,
      ["KEY_F13"] = 124,
      ["KEY_F14"] = 125,
      ["KEY_F15"] = 126,
      ["KEY_F16"] = 127,
      ["KEY_F17"] = 128,
      ["KEY_F18"] = 129,
      ["KEY_F19"] = 130,
      ["KEY_F20"] = 131,
      ["KEY_F21"] = 132,
      ["KEY_F22"] = 133,
      ["KEY_F23"] = 134,
      ["KEY_F24"] = 135,
     ["VK_OEM_1"] = 186,   -- OEM_1 (: ;)
     ["VK_OEM_2"] = 191,   -- OEM_2 (? /)
     ["VK_OEM_3"] = 192,   -- OEM_3 (~ `)
     ["VK_OEM_4"] = 219,   -- OEM_4 ({ [)
     ["VK_OEM_5"] = 220,   -- OEM_5 (   )
     ["VK_OEM_6"] = 221,   -- OEM_6 (} ])
     ["VK_OEM_7"] = 222,   -- OEM_7 (" ')
["VK_OEM_PERIOD"] = 190,   -- OEM_PERIOD (> .)
  ["VK_OEM_PLUS"] = 187,   -- OEM_PLUS (+ =)
 ["VK_OEM_MINUS"] = 189,   -- OEM_MINUS (_ -)
  ["KEY_NUMLOCK"] = 144,
   ["KEY_SCROLL"] = 145,
   ["KEY_LSHIFT"] = 160,
 ["KEY_LCONTROL"] = 162,
    ["KEY_LMENU"] = 164,
   ["KEY_RSHIFT"] = 161,
 ["KEY_RCONTROL"] = 163,
    ["KEY_RMENU"] = 165,
}

for k,v in pairs(LUA_KEYS)      do  if ( LUA_KEYS[v]      == nil )  then  LUA_KEYS[v]      = v ;end ;end
for k,v in pairs(NATIVE_KEYS)   do  if ( NATIVE_KEYS[v]   == nil )  then  NATIVE_KEYS[v]   = k ;end ;end
for k,v in pairs(NATIVE_KEYS_2) do  if ( NATIVE_KEYS_2[v] == nil )  then  NATIVE_KEYS_2[v] = k ;end ;end

return LUA_KEYS, NATIVE_KEYS, NATIVE_KEYS_2, NATIVE_CONTROL_GROUPS
