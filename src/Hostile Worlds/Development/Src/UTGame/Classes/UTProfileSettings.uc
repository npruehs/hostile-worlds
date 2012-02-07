/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * List of profile settings for UT
 */
class UTProfileSettings extends UDKProfileSettings
	config(game);

// Generic Yes/No Enum
enum EGenericYesNo
{
	UTPID_VALUE_NO,
	UTPID_VALUE_YES
};

// Gore Level Enum
enum EGoreLevel
{
	GORE_NORMAL,
	GORE_LOW
};

// Announcer Setting Enum
enum EAnnouncerSetting
{
	ANNOUNCE_OFF,
	ANNOUNCE_MINIMAL,
	ANNOUNCE_FULL
};

// Network Type Enum
enum ENetworkType
{
	NETWORKTYPE_Unknown,
	NETWORKTYPE_Modem,
	NETWORKTYPE_ISDN,
	NETWORKTYPE_Cable,
	NETWORKTYPE_LAN
};

/** Post Processing Preset */
enum EPostProcessPreset
{
	PPP_Default,
	PPP_Muted,
	PPP_Vivid,
	PPP_Intense
};

/** Vehicle controls. */
enum EUTVehicleControls
{
	UTVC_Simple,
	UTVC_Normal,
	UTVC_Advanced
};

/** Text to speech mode. */
enum EUTTextToSpeechMode
{
	TTSM_None,
	TTSM_TeamOnly,
	TTSM_All
};

// Possible Digital Button Actions - This order matters, data is saved in the order of this array.
enum EDigitalButtonActions
{
	DBA_None,
	DBA_Fire,
	DBA_AltFire,
	DBA_Jump,
	DBA_Use,
	DBA_ToggleMelee,
	DBA_ShowScores,
	DBA_ShowMap,
	DBA_FeignDeath,
	DBA_ToggleSpeaking,
	DBA_ToggleMinimap,
	DBA_WeaponPicker,
	DBA_NextWeapon,
	DBA_BestWeapon,
	DBA_PrevWeapon,

	// The following actions aren't exposed on consoles and are used for PC keybinding.
	DBA_Duck,
	DBA_MoveForward,
	DBA_MoveBackward,
	DBA_StrafeLeft,
	DBA_StrafeRight,
	DBA_TurnLeft,
	DBA_TurnRight,
	DBA_SwitchWeapon1,
	DBA_SwitchWeapon2,
	DBA_SwitchWeapon3,
	DBA_SwitchWeapon4,
	DBA_SwitchWeapon5,
	DBA_SwitchWeapon6,
	DBA_SwitchWeapon7,
	DBA_SwitchWeapon8,
	DBA_SwitchWeapon9,
	DBA_SwitchWeapon10,
	DBA_ShrinkHUD,
	DBA_GrowHUD,
	DBA_Talk,
	DBA_TeamTalk,
	DBA_ShowCommandMenu,
	DBA_ShowMenu,
	DBA_ToggleTranslocator,
	DBA_JumpPC,
	DBA_BestWeaponPC,
	DBA_Horn,
};

/** Mapping of action enum to actually exec commands. */
var array<string> DigitalButtonActionsToCommandMapping;

// Possible Analog Stick Configurations
enum EAnalogStickActions
{
	ESA_Normal,
	ESA_SouthPaw,
	ESA_Legacy,
	ESA_LegacySouthPaw
};

/** Poassible crosshair types.*/
enum ECrosshairType
{
	CHT_Normal,
	CHT_Simple,
	CHT_None
};

/** Enum of bindable keys */
enum EUTBindableKeys
{
	UTBND_Unbound,	// Must be 0!
	UTBND_MouseX,
	UTBND_MouseY,
	UTBND_MouseScrollUp,
	UTBND_MouseScrollDown,
	UTBND_LeftMouseButton,
	UTBND_RightMouseButton,
	UTBND_MiddleMouseButton,
	UTBND_ThumbMouseButton,
	UTBND_ThumbMouseButton2,
	UTBND_BackSpace,
	UTBND_Tab,
	UTBND_Enter,
	UTBND_Pause,
	UTBND_CapsLock,
	UTBND_Escape,
	UTBND_SpaceBar,
	UTBND_PageUp,
	UTBND_PageDown,
	UTBND_End,
	UTBND_Home,
	UTBND_Left,
	UTBND_Up,
	UTBND_Right,
	UTBND_Down,
	UTBND_Insert,
	UTBND_Delete,
	UTBND_Zero,
	UTBND_One,
	UTBND_Two,
	UTBND_Three,
	UTBND_Four,
	UTBND_Five,
	UTBND_Six,
	UTBND_Seven,
	UTBND_Eight,
	UTBND_Nine,
	UTBND_A,
	UTBND_B,
	UTBND_C,
	UTBND_D,
	UTBND_E,
	UTBND_F,
	UTBND_G,
	UTBND_H,
	UTBND_I,
	UTBND_J,
	UTBND_K,
	UTBND_L,
	UTBND_M,
	UTBND_N,
	UTBND_O,
	UTBND_P,
	UTBND_Q,
	UTBND_R,
	UTBND_S,
	UTBND_T,
	UTBND_U,
	UTBND_V,
	UTBND_W,
	UTBND_X,
	UTBND_Y,
	UTBND_Z,
	UTBND_NumPadZero,
	UTBND_NumPadOne,
	UTBND_NumPadTwo,
	UTBND_NumPadThree,
	UTBND_NumPadFour,
	UTBND_NumPadFive,
	UTBND_NumPadSix,
	UTBND_NumPadSeven,
	UTBND_NumPadEight,
	UTBND_NumPadNine,
	UTBND_Multiply,
	UTBND_Add,
	UTBND_Subtract,
	UTBND_Decimal,
	UTBND_Divide,
	UTBND_F1,
	UTBND_F2,
	UTBND_F3,
	UTBND_F4,
	UTBND_F5,
	UTBND_F6,
	UTBND_F7,
	UTBND_F8,
	UTBND_F9,
	UTBND_F10,
	UTBND_F11,
	UTBND_F12,
	UTBND_NumLock,
	UTBND_ScrollLock,
	UTBND_LeftShift,
	UTBND_RightShift,
	UTBND_LeftControl,
	UTBND_RightControl,
	UTBND_LeftAlt,
	UTBND_RightAlt,
	UTBND_Semicolon,
	UTBND_Equals,
	UTBND_Comma,
	UTBND_Underscore,
	UTBND_Period,
	UTBND_Slash,
	UTBND_Tilde,
	UTBND_LeftBracket,
	UTBND_Backslash,
	UTBND_RightBracket,
	UTBND_Quote,

	// Gamepad keys
	UTBND_LeftStickX,
	UTBND_LeftStickY,
	UTBND_LeftStick_Click,
	UTBND_RightStick_X,
	UTBND_RightStick_Y,
	UTBND_RightStick_Click,
	UTBND_ButtonA,			// accept button
	UTBND_ButtonB,			// cancel button
	UTBND_ButtonX,			// option button 1
	UTBND_ButtonY,			// option button 2
	UTBND_LeftShoulder,
	UTBND_RightShoulder,
	UTBND_LeftTrigger,
	UTBND_RightTrigger,
	UTBND_Start,
	UTBND_Select,
	UTBND_DPad_Up,
	UTBND_DPad_Down,
	UTBND_DPad_Left,
	UTBND_DPad_Right,

	UTBND_SpecialX,
	UTBND_SpecialY,
	UTBND_SpecialZ,
	UTBND_SpecialW
};
var transient array<name>	KeyMappingArray;	/** Mapping of enums to keynames. */

// Profile settings ids definitions
const UTPID_CustomCharString = 301;
const UTPID_UnlockedCharacters = 302;

// Audio
const UTPID_SFXVolume = 360;
const UTPID_MusicVolume = 361;
const UTPID_VoiceVolume = 362;
const UTPID_AnnouncerVolume = 363;
const UTPID_AnnounceSetting = 364;
const UTPID_AutoTaunt = 365;
const UTPID_MessageBeep = 366;
const UTPID_TextToSpeechMode = 367;
const UTPID_AmbianceVolume = 368;

// Video
const UTPID_Gamma = 380;
const UTPID_PostProcessPreset = 381;
const UTPID_ScreenResolutionX = 382;
const UTPID_ScreenResolutionY = 383;
const UTPID_DefaultFOV = 384;
const UTPID_Subtitles = 385;

// Game
const UTPID_ViewBob = 400;
const UTPID_GoreLevel = 401;
const UTPID_DodgingEnabled = 402;
const UTPID_WeaponSwitchOnPickup = 403;


// Network
const UTPID_Alias = 404;
const UTPID_ClanTag = 405;
const UTPID_NetworkConnection = 406;
const UTPID_DynamicNetspeed = 407;
const UTPID_SpeechRecognition = 408;
const UTPID_ServerDescription = 409;
const UTPID_AllowCustomCharacters = 410;
const UTPID_FirstTimeMultiplayer = 411;

// Input
const UTPID_MouseSmoothing = 420;
const UTPID_ReduceMouseLag = 421;
const UTPID_EnableJoystick = 422;
const UTPID_MouseSensitivityGame = 423;
const UTPID_MouseSensitivityMenus = 424;
const UTPID_MouseSmoothingStrength = 425;
const UTPID_MouseAccelTreshold = 426;
const UTPID_DodgeDoubleClickTime = 427;
const UTPID_TurningAccelerationFactor = 428;

const UTPID_GamepadBinding_ButtonA = 429;
const UTPID_GamepadBinding_ButtonB = 430;
const UTPID_GamepadBinding_ButtonX = 431;
const UTPID_GamepadBinding_ButtonY = 432;
const UTPID_GamepadBinding_Back = 433;
const UTPID_GamepadBinding_RightBumper = 434;
const UTPID_GamepadBinding_LeftBumper = 435;
const UTPID_GamepadBinding_RightTrigger = 436;
const UTPID_GamepadBinding_LeftTrigger = 437;
const UTPID_GamepadBinding_RightThumbstickPressed = 438;
const UTPID_GamepadBinding_LeftThumbstickPressed = 439;
const UTPID_GamepadBinding_DPadUp = 440;
const UTPID_GamepadBinding_DPadDown = 441;
const UTPID_GamepadBinding_DPadLeft = 442;
const UTPID_GamepadBinding_DPadRight = 443;

const UTPID_GamepadBinding_AnalogStickPreset = 444;

const UTPID_ControllerSensitivityMultiplier = 450;
const UTPID_AutoCenterPitch = 451;
const UTPID_AutoCenterVehiclePitch = 452;
const UTPID_TiltSensing = 453;
const UTPID_VehicleControls = 454;
const UTPID_EnableHardwarePhysics = 455;

// Weapons
const UTPID_WeaponHand = 460;
const UTPID_SmallWeapons = 461;
const UTPID_DisplayWeaponBar = 462;
const UTPID_ShowOnlyAvailableWeapons = 463;

const UTPID_RocketLauncherPriority = 464;
const UTPID_BioRiflePriority = 465;
const UTPID_FlakCannonPriority = 466;
const UTPID_SniperRiflePriority = 467;
const UTPID_LinkGunPriority = 468;
const UTPID_EnforcerPriority = 469;
const UTPID_ShockRiflePriority = 470;
const UTPID_StingerPriority = 471;
const UTPID_RedeemerPriority = 473;

const UTPID_CrosshairType = 474;

// HUD
const UTPID_ShowMap = 480;
const UTPID_ShowClock = 481;
const UTPID_ShowDoll = 482;
const UTPID_ShowAmmo = 483;
const UTPID_ShowPowerups = 484;
const UTPID_ShowScoring = 485;
const UTPID_ShowLeaderboard = 486;
const UTPID_RotateMap = 487;
const UTPID_ShowVehicleArmorCount = 488;

// PC Keybindings
const UTPID_KeyAction_1 = 	501;
const UTPID_KeyAction_2 = 	502;
const UTPID_KeyAction_3 = 	503;
const UTPID_KeyAction_4 = 	504;
const UTPID_KeyAction_5 = 	505;
const UTPID_KeyAction_6 = 	506;
const UTPID_KeyAction_7 = 	507;
const UTPID_KeyAction_8 = 	508;
const UTPID_KeyAction_9 = 	509;
const UTPID_KeyAction_10 = 	510;
const UTPID_KeyAction_11 = 	511;
const UTPID_KeyAction_12 = 	512;
const UTPID_KeyAction_13 = 	513;
const UTPID_KeyAction_14 = 	514;
const UTPID_KeyAction_15 = 	515;
const UTPID_KeyAction_16 = 	516;
const UTPID_KeyAction_17 = 	517;
const UTPID_KeyAction_18 = 	518;
const UTPID_KeyAction_19 = 	519;
const UTPID_KeyAction_20 = 	520;
const UTPID_KeyAction_21 = 	521;
const UTPID_KeyAction_22 = 	522;
const UTPID_KeyAction_23 = 	523;
const UTPID_KeyAction_24 = 	524;
const UTPID_KeyAction_25 = 	525;
const UTPID_KeyAction_26 = 	526;
const UTPID_KeyAction_27 = 	527;
const UTPID_KeyAction_28 = 	528;
const UTPID_KeyAction_29 = 	529;
const UTPID_KeyAction_30 = 	530;
const UTPID_KeyAction_31 = 	531;
const UTPID_KeyAction_32 = 	532;
const UTPID_KeyAction_33 = 	533;
const UTPID_KeyAction_34 = 	534;
const UTPID_KeyAction_35 = 	535;
const UTPID_KeyAction_36 = 	536;
const UTPID_KeyAction_37 = 	537;
const UTPID_KeyAction_38 = 	538;
const UTPID_KeyAction_39 = 	539;
const UTPID_KeyAction_40 = 	540;
const UTPID_KeyAction_41 = 	541;
const UTPID_KeyAction_42 = 	542;
const UTPID_KeyAction_43 = 	543;
const UTPID_KeyAction_44 = 	544;
const UTPID_KeyAction_45 = 	545;
const UTPID_KeyAction_46 = 	546;
const UTPID_KeyAction_47 = 	547;
const UTPID_KeyAction_48 = 	548;
const UTPID_KeyAction_49 = 	549;



//UT Achievements
enum EUTUnlockType
{
	EUnlockType_Count,
	EUnlockType_Bitmask
};

// ===================================================================
// Single Player Keys
// ===================================================================

/**
 * PersistentKeys are meant to be tied to in-game events and persist across
 * different missions.  The mission manager can use these keys to determine next
 * course of action and kismet can query for a key and act accordingly (TBD).
 * Current we have room for 20 persistent keys.
 *
 * To Add a persistent key, extend the enum below.
 */

enum ESinglePlayerPersistentKeys
{
	ESPKey_None,
	ESPKey_DarkWalkerUnlock,
	ESPKey_CanStealNecris,
	ESPKey_IronGuardUpgrade,
	ESPKey_LiandriUpgrade,
	ESPKey_MAX
};

const PSI_PersistentKeySlot0	= 200;
const PSI_PersistentKeySlot1	= 201;
const PSI_PersistentKeySlot2	= 202;
const PSI_PersistentKeySlot3	= 203;
const PSI_PersistentKeySlot4	= 204;
const PSI_PersistentKeySlot5	= 205;
const PSI_PersistentKeySlot6	= 206;
const PSI_PersistentKeySlot7	= 207;
const PSI_PersistentKeySlot8	= 208;
const PSI_PersistentKeySlot9	= 209;
const PSI_PersistentKeySlot10	= 210;
const PSI_PersistentKeySlot11	= 211;
const PSI_PersistentKeySlot12	= 212;
const PSI_PersistentKeySlot13	= 213;
const PSI_PersistentKeySlot14	= 214;
const PSI_PersistentKeySlot15	= 215;
const PSI_PersistentKeySlot16	= 216;
const PSI_PersistentKeySlot17	= 217;
const PSI_PersistentKeySlot18	= 218;
const PSI_PersistentKeySlot19	= 219;

const PSI_PersistentKeyMAX		= 220;	// When adding a persistent key slot, make sure you update the max
										// otherwise the new slot won't be processed

enum ESinglePlayerSkillLevels
{
	ESPSKILL_SkillLevel0,
	ESPSKILL_SkillLevel1,
	ESPSKILL_SkillLevel2,
	ESPSKILL_SkillLevel3,
	ESPSKILL_SkillLevelMAX
};

const PSI_SinglePlayerMapMaskA = 245;
const PSI_SinglePlayerMapMaskB = 246;

const PSI_SinglePlayerSkillLevel = 250;
const PSI_SinglePlayerCurrentMission=251;
const PSI_SinglePlayerCurrentMissionResult=252;

/** Holds which chapters have been unlocked */
const PSI_ChapterMask = 299;

// ===================================================================
// Single Player Keys Accessors
// ===================================================================

/**
 * Check to see if a Persistent Key has been set.
 *
 * @Param	SearchKey		The Persistent Key to look for
 * @Param	PSI_Index		<Optional Out> returns the PSI Index for the slot holding the key
 *
 * @Returns true if the key exists, false if it doesn't
 */
function bool HasPersistentKey(ESinglePlayerPersistentKeys SearchKey, optional out int PSI_Index)
{
	local int Value;

	if (SearchKey != ESPKey_None)
	{
		for (PSI_Index = PSI_PersistentKeySlot0; PSI_Index < PSI_PersistentKeyMAX; PSI_Index++)
		{
			GetProfileSettingValueInt( PSI_Index, Value );
			if ( Value == SearchKey )
			{
				return true;
			}
		}
	}
	return false;
}

/**
 * Add a PersistentKey
 *
 * @Param	AddKey		The Persistent Key to add
 * @Returns true if successful.
 *
 */
function bool AddPersistentKey(ESinglePlayerPersistentKeys AddKey)
{
	local int PSI_Index, Value;

	// Make sure the key does not exist first

	if ( HasPersistentKey(AddKey) )
	{
//		`log("[SinglePlayer] Persistent Key"@AddKey@"already exists.");
		return false;
	}

	// Find the first available slot

	for (PSI_Index = PSI_PersistentKeySlot0; PSI_Index < PSI_PersistentKeyMAX; PSI_Index++)
	{
		GetProfileSettingValueInt( PSI_Index, Value );
		if ( Value == ESPKey_None )
		{
//			`log("[SinglePlayer] Adding Persistent Key"@AddKey);
			SetProfileSettingValueInt( PSI_Index, AddKey );
			return true;
		}
	}

//	`log("[SinglePlayer] Persistent Key Slots Filled");
	return false;
}

/**
 * Remove a PersistentKey
 *
 * @Param	RemoveKey		The Persistent Key to remove
 * @returns true if successful
 */
function bool RemovePersistentKey(ESinglePlayerPersistentKeys RemoveKey)
{
	local iNT PSI_Index;


	if ( HasPersistentKey(RemoveKey, PSI_Index) )
	{
//		`log("[SinglePlayer] Removing Persistent Key"@RemoveKey);
		SetProfileSettingValueInt( PSI_Index, ESPKey_None );
		return true;
	}

	return false;
}

function int GetChapterMask()
{
	local int Value;
	GetProfileSettingValueInt( PSI_ChapterMask, value);
	return Value;
}

function SetChapterMask(int NewMask)
{
	SetProfileSettingValueInt( PSI_ChapterMask, NewMask );
}

function bool AreAnyChaptersUnlocked()
{
	local int Value;
	GetProfileSettingValueInt( PSI_ChapterMask, Value);
	return Value != 0;
}

function bool IsChapterUnlocked(int ChapterIndex)
{
	local int Mask,Value;

	Mask = 1 << ChapterIndex;
	GetProfileSettingValueInt( PSI_ChapterMask, Value );

	return ( (Value & Mask) != 0);
}

function UnlockChapter(int ChapterIndex)
{
	local int Mask,Value;

//	`log("[SinglePlayer] Unlocking Chapter"@ChapterIndex);

	Mask = 1 << (ChapterIndex-1);
	GetProfileSettingValueInt( PSI_ChapterMask, Value );
	Value = Value | Mask;


	SetProfileSettingValueInt( PSI_ChapterMAsk, Value );
}

/**
 * @Param MissionID		- Returns the Mission ID for the current mission
 * @Param MissionResult - Returns the results for the last mission.
 */
function GetCurrentMissionData(out int MissionID, out int MissionResult)
{
	GetProfileSettingValueInt(PSI_SinglePlayerCurrentMission,MissionID);
	GetProfileSettingValueInt(PSI_SinglePlayerCurrentMissionResult,MissionResult);
}

function SetCurrentMissionData(int NewMissionID, int bNewMissionResult)
{
	SetProfileSettingValueInt(PSI_SinglePlayerCurrentMission,NewMissionID);
	SetProfileSettingValueInt(PSI_SinglePlayerCurrentMissionResult,bNewMissionResult);
}

function int GetCampaignSkillLevel()
{
	local int CMIdx;
	GetProfileSettingValueInt(PSI_SinglePlayerSkillLevel, CMIdx);
	return CMIdx;
}

function SetCampaignSkillLevel(int NewSkillLevel)
{
	SetProfileSettingValueInt(PSI_SinglePlayerSkillLevel, NewSkillLevel);
}

/**
 * @Returns true if a game is in progress
 */

function bool bGameInProgress()
{
	local int IDX, R;
	GetCurrentMissionData(IDX,R);
	return (IDX >= 0);
}

/**
 * Resets the single player game profile settings for a new game
 */
function NewGame()
{
	local int i;

	for (i=PSI_PersistentKeySlot0;i< PSI_PersistentKeyMAX; i++)
	{
		SetProfileSettingValueInt(i,ESPKey_None);
	}

	// Reset the Map Mask
	SetProfileSettingValueInt(PSI_SinglePlayerMapMaskA,0);
	SetProfileSettingValueInt(PSI_SinglePlayerMapMaskB,0);

	SetProfileSettingValueInt(PSI_SinglePlayerSkillLevel,1);
	SetCurrentMissionData(0,0);
}
/**
 * Returns the integer value of a profile setting given its name.
 *
 * @return Whether or not the value was retrieved
 */
function bool GetProfileSettingValueIntByName(name SettingName, out int OutValue)
{
	local bool bResult;
	local int SettingId;

	bResult = FALSE;

	if(GetProfileSettingId(SettingName,SettingId))
	{
		bResult = GetProfileSettingValueInt(SettingId, OutValue);
	}

	return bResult;
}

/**
 * Returns the float value of a profile setting given its name.
 *
 * @return Whether or not the value was retrieved
 */
function bool GetProfileSettingValueFloatByName(name SettingName, out float OutValue)
{
	local bool bResult;
	local int SettingId;

	bResult = FALSE;

	if(GetProfileSettingId(SettingName,SettingId))
	{
		bResult = GetProfileSettingValueFloat(SettingId, OutValue);
	}

	return bResult;
}

/**
 * Returns the string value of a profile setting given its name.
 *
 * @return Whether or not the value was retrieved
 */
function bool GetProfileSettingValueStringByName(name SettingName, out string OutValue)
{
	local bool bResult;
	local int SettingId;

	bResult = FALSE;

	if(GetProfileSettingId(SettingName,SettingId))
	{
		bResult = GetProfileSettingValue(SettingId, OutValue);
	}

	return bResult;
}

/**
 * Returns the Id mapped value of a profile setting given its name.
 *
 * @return Whether or not the value was retrieved
 */
function bool GetProfileSettingValueIdByName(name SettingName, out int OutValue)
{
	local bool bResult;
	local int SettingId;

	bResult = FALSE;

	if(GetProfileSettingId(SettingName,SettingId))
	{
		bResult = GetProfileSettingValueId(SettingId, OutValue);
	}

	return bResult;
}

/**
 * Stores key settings in the profile using the player input object provided.
 *
 * @param PInput	Player input to get bindings from.
 */
function StoreKeysUsingPlayerInput(optional PlayerInput PInput=None)
{
	local int BindingIdx, CommandIdx, ToBindIdx;
	local int NumTotalBinds, NumCurrBinds;
	local name KeyBinds[2];
	local array<KeyBind> Bindings;

	if(PInput==None)
	{
		Bindings=class'PlayerInput'.default.Bindings;
	}
	else
	{
		Bindings=PInput.Bindings;
	}

	NumTotalBinds = 2;

	// Loop through all of the commands in the profile.
	for ( CommandIdx = 0; CommandIdx<DigitalButtonActionsToCommandMapping.length; CommandIdx++ )
	{
		// Init the local binding data.
		NumCurrBinds = 0;
		for ( ToBindIdx = 0; ToBindIdx < NumTotalBinds; ToBindIdx++ )
		{
			KeyBinds[ToBindIdx] = '';
		}

		// Loop through all of the binds and find the commands that match the one we are currently trying to set in the profile.
		for( BindingIdx = Bindings.length-1; BindingIdx >= 0; BindingIdx-- )
		{
			// Found one so mark the index in our local array.
			if (Bindings[BindingIdx].Command == DigitalButtonActionsToCommandMapping[CommandIdx])
			{
				KeyBinds[NumCurrBinds++] = Bindings[BindingIdx].Name;
			}

			// Make sure we only mark NumTotoalBinds worth of binds.
			if ( NumCurrBinds >= NumTotalBinds )
			{
				break;
			}
		}

		// Now set them in the profile.
		SetKeyBindingUsingCommand( DigitalButtonActionsToCommandMapping[CommandIdx], KeyBinds[0], KeyBinds[1] );
	}
}


/**
 * Sets all of the profile settings to their default values
 */
event SetToDefaults()
{
	local string DefaultStringValue;

	Super.SetToDefaults();

	DefaultStringValue = "";

	// Resets keys to default values.
	ResetKeysToDefault();
	StoreKeysUsingPlayerInput();

	SetProfileSettingValueFloat(UTPID_RocketLauncherPriority, class'UTWeap_RocketLauncher'.default.Priority);
	SetProfileSettingValueFloat(UTPID_ShockRiflePriority, class'UTWeap_ShockRifleBase'.default.Priority);
	SetProfileSettingValueFloat(UTPID_LinkGunPriority, class'UTWeap_LinkGun'.default.Priority);
	
	if ( !class'UIRoot'.static.IsConsole() )
	{
		SetProfileSettingValueId(UTPID_ShowVehicleArmorCount, UTPID_VALUE_YES);
	}

	SetProfileSettingValue(UTPID_ClanTag, DefaultStringValue);
	SetProfileSettingValue(UTPID_Alias, DefaultStringValue);
	SetProfileSettingValue(UTPID_ServerDescription, DefaultStringValue);

	SetProfileSettingValueId(UTPID_SmallWeapons, class'UTWeapon'.default.bSmallWeapons ? UTPID_VALUE_YES : UTPID_VALUE_NO);
}

/**
 * Looks up a keybinding name given an enum value
 *
 * @param KeyName	Key name to look up the enum for.
 *
 * @return Returns the name for the key if it exists, or '' otherwise.
 */
function name FindKeyName(EUTBindableKeys KeyEnum)
{
	local name Result;

	if(KeyEnum < KeyMappingArray.length)
	{
		Result = KeyMappingArray[KeyEnum];
	}
	else
	{
		Result = '';
	}

	return Result;
}

/**
 * Looks up a keybinding enum value given its name.
 *
 * @param KeyName	Key name to look up the enum for.
 *
 * @return Returns the enum value for the key or INDEX_NONE if none was found.
 */
function int FindKeyEnum(name KeyName)
{
	local int KeyIdx;
	local int Result;

	Result = INDEX_NONE;

	for(KeyIdx=0; KeyIdx<KeyMappingArray.length; KeyIdx++)
	{
		if(KeyMappingArray[KeyIdx]==KeyName)
		{
			Result = KeyIdx;
			break;
		}
	}

	return Result;
}

/**
 * Returns the profile ID for a digital button action.
 *
 * @param KeyAction		Action to return a profile ID for.
 *
 * @return	Returns the profile ID for the action.
 */
function int GetProfileIDForDBA(EDigitalButtonActions KeyAction)
{
	local int ProfileId;
	ProfileId = UTPID_KeyAction_1+KeyAction;
	`assert(ProfileId<=UTPID_KeyAction_49);
	return ProfileId;
}

/**
 * Attempts to find a digital button action enum using a string command
 *
 * @param Command	Command to find
 *
 * @return an EDigitalButtonAction enum value if one exists, INDEX_NONE otherwise.
 */
function int GetDBAFromCommand(string Command)
{
	local int Result;
	local int CommandIdx;

	Result = INDEX_NONE;

	for(CommandIdx=0; CommandIdx<DigitalButtonActionsToCommandMapping.length; CommandIdx++)
	{
		if(DigitalButtonActionsToCommandMapping[CommandIdx]==Command)
		{
			Result = CommandIdx;
			break;
		}
	}

	return Result;
}

/**
 * Sets a binding for a specified command.
 *
 * @param KeyAction		DBA to bind
 * @param KeyBinding1	Key to bind #1
 * @param KeyBinding2	Key to bind #2
 * @param KeyBinding3	Key to bind #3
 * @param KeyBinding4	Key to bind #4
 */
function SetKeyBindingUsingCommand(string KeyCommand, name KeyBinding, optional name KeyBinding2='', optional name KeyBinding3='', optional name KeyBinding4='')
{
	local int KeyAction;

	KeyAction = GetDBAFromCommand(KeyCommand);

	if(KeyAction != INDEX_NONE)
	{
		SetKeyBinding(EDigitalButtonActions(KeyAction), KeyBinding, KeyBinding2, KeyBinding3, KeyBinding4);
	}
}

/**
 * Sets a binding for a specified key action.
 *
 * @param KeyAction		DBA to bind
 * @param KeyBinding1	Key to bind #1
 * @param KeyBinding2	Key to bind #2
 * @param KeyBinding3	Key to bind #3
 * @param KeyBinding4	Key to bind #4
 */
function SetKeyBinding(EDigitalButtonActions KeyAction, name KeyBinding, optional name KeyBinding2='', optional name KeyBinding3='', optional name KeyBinding4='')
{
	local int KeyBindingValue[4];
	local int FinalProfileValue;
	local int KeyEnumValue;
	local int BindingIdx;

	KeyBindingValue[0]=0;
	KeyBindingValue[1]=0;
	KeyBindingValue[2]=0;
	KeyBindingValue[3]=0;

	// Key binding 1
	if(KeyBinding != '')
	{
		KeyEnumValue = FindKeyEnum(KeyBinding);

		if(KeyEnumValue != INDEX_NONE)
		{
			KeyBindingValue[3]=KeyEnumValue;
		}
	}

	// Key binding 2
	if(KeyBinding2 != '')
	{
		KeyEnumValue = FindKeyEnum(KeyBinding2);

		if(KeyEnumValue != INDEX_NONE)
		{
			KeyBindingValue[2]=KeyEnumValue;
		}
	}

	// Key binding 3
	if(KeyBinding3 != '')
	{
		KeyEnumValue = FindKeyEnum(KeyBinding3);

		if(KeyEnumValue != INDEX_NONE)
		{
			KeyBindingValue[1]=KeyEnumValue;
		}
	}

	// Key binding 4
	if(KeyBinding4 != '')
	{
		KeyEnumValue = FindKeyEnum(KeyBinding4);

		if(KeyEnumValue != INDEX_NONE)
		{
			KeyBindingValue[0]=KeyEnumValue;
		}
	}

	// Save the value to the profile
	FinalProfileValue=0;
	for(BindingIdx=0;BindingIdx<4;BindingIdx++)
	{
		FinalProfileValue = FinalProfileValue | (KeyBindingValue[BindingIdx]<<(BindingIdx*8));
	}
	SetProfileSettingValueInt(GetProfileIDForDBA(KeyAction), FinalProfileValue);
}

/**
 * Unbinds the specified key.
 *
 * @param PInput	Player input to operate on
 * @param BindName	Key to unbind
 */
function UnbindKey(PlayerInput PInput, name BindName)
{
	local int BindingIdx;

	for(BindingIdx = 0;BindingIdx < PInput.Bindings.Length;BindingIdx++)
	{
		if(PInput.Bindings[BindingIdx].Name == BindName)
		{
			PInput.Bindings.Remove(BindingIdx, 1);
			PInput.SaveConfig();
			break;
		}
	}
}

/**
 * Applies all possible bindings to the specified player input.
 *
 * @param InPlayerInput		PlayerInput to bind keys on
 */
function ApplyAllKeyBindings(PlayerInput PInput)
{
	local int BindingIdx;
	local name KeyName;
	local string KeyCommand;
	local int CurrentProfileValue;

	if ( !class'UIRoot'.static.IsConsole() )
	{
		RemoveDBABindings( PInput );

		//Key bindings
		for(BindingIdx=0; BindingIdx<DBA_MAX; BindingIdx++)
		{
			ApplyKeyBinding(PInput, EDigitalButtonActions(BindingIdx));
		}

		//Joystick bindings
		for( BindingIdx = class'UTConsolePlayerController'.default.ProfileSettingToUE3BindingMapping360.length-1; BindingIdx >= 0; BindingIdx-- )
		{
			if( GetProfileSettingValueIdByName( class'UTConsolePlayerController'.default.ProfileSettingToUE3BindingMapping360[BindingIdx].ProfileSettingName, CurrentProfileValue) )
			{
				//SettingName = class'UTConsolePlayerController'.default.ProfileSettingToUE3BindingMapping360[BindingIdx].ProfileSettingName;
				KeyName = class'UTConsolePlayerController'.default.ProfileSettingToUE3BindingMapping360[BindingIdx].UE3BindingName;
				KeyCommand = DigitalButtonActionsToCommandMapping[CurrentProfileValue];

				//`Log("### - Applying joy binding setting:"@SettingName@"Key:"@KeyName@"Command:"@KeyCommand);
				PInput.SetBind(KeyName, KeyCommand);
			}
		}

	}
}

/**
 * Applies a key binding to the given player input, rebinds keys that are already bound, doesn't unbind keys already assigned to the action.
 *
 * @param InPlayerInput		PlayerInput to bind keys on
 * @param KeyBinding		Action to bind keys for.
 */
function ApplyKeyBinding(PlayerInput PInput, EDigitalButtonActions KeyBinding)
{
	local int KeyBindingValue;
	local int CurrentProfileValue;
	local name KeyName;
	local string KeyCommand;
	local int BindingIdx;

	if(GetProfileSettingValueInt(GetProfileIDForDBA(KeyBinding), CurrentProfileValue))
	{
		// Unpack value
		for(BindingIdx=0;BindingIdx<4;BindingIdx++)
		{
			KeyBindingValue = 0xFF & (CurrentProfileValue>>(BindingIdx*8));
			KeyName = FindKeyName(EUTBindableKeys(KeyBindingValue));
			KeyCommand = DigitalButtonActionsToCommandMapping[KeyBinding];

			// Unbind the current value first
			if(KeyBindingValue != 0 && KeyName != '' && Len(KeyCommand)>0)
			{
				//`Log("### - Applying keybinding Key:"@KeyName@"Command:"@KeyCommand);
				PInput.SetBind(KeyName, KeyCommand);
			}
		}
	}
}

/** Removes any binds the profile manages. */
function RemoveDBABindings( PlayerInput PInput )
{
	local int BindingIdx, DBAIdx;

	for ( BindingIdx = 0; BindingIdx < PInput.Bindings.length; BindingIdx++ )
	{
		for ( DBAIdx = 0; DBAIdx < DigitalButtonActionsToCommandMapping.length; DBAIdx++ )
		{
			if ( PInput.Bindings[BindingIdx].Command == DigitalButtonActionsToCommandMapping[DBAIdx] )
			{
				//`Log("### - Removing keybinding Key:"@PInput.Bindings[BindingIdx].Name@"Command:"@DigitalButtonActionsToCommandMapping[DBAIdx]);
				PInput.Bindings.Remove(BindingIdx, 1);
				BindingIdx--;
				break;
			}
		}
	}
}

/** Whether an action has been bound or not. */
function bool ActionIsBound(EDigitalButtonActions ActionIdx)
{
	local int Idx, Value;

	for ( Idx = UTPID_GamepadBinding_ButtonA; Idx <= UTPID_GamepadBinding_DPadRight; Idx++ )
	{
		if ( GetProfileSettingValueId(Idx, Value) )
		{
			if ( Value == ActionIdx )
			{
				return true;
			}
		}
	}

	return false;
}

// Returns the string of an action name.
function string GetActionName(EDigitalButtonActions ActionIdx)
{
	local string ActionName;
	local int ProfileSettingIDIndex, Idx;

	ActionName = "";

	for ( ProfileSettingIDIndex = 0; ProfileSettingIDIndex < ProfileMappings.length; ProfileSettingIDIndex++ )
	{
		if ( ProfileMappings[ProfileSettingIDIndex].Id == UTPID_GamepadBinding_ButtonA )
		{
			for ( Idx = 0; Idx < ProfileMappings[ProfileSettingIDIndex].ValueMappings.Length; Idx++ )
			{
				if (ProfileMappings[ProfileSettingIDIndex].ValueMappings[Idx].Id == int(ActionIdx))
				{
					ActionName = string(ProfileMappings[ProfileSettingIDIndex].ValueMappings[Idx].Name);
					break;
				}
			}
		}
	}

	return ActionName;
}

defaultproperties
{
	// If you change any profile ids, increment this number!!!!
	VersionNumber=61

	/////////////////////////////////////////////////////////////
	// ProfileSettingIds - Array of profile setting IDs to use as lookups
	/////////////////////////////////////////////////////////////
	ProfileSettingIds.Empty

	// Online Service - Gamer profile settings that should be read to meet TCR
	ProfileSettingIds.Add(PSI_ControllerVibration)
	ProfileSettingIds.Add(PSI_YInversion)
	ProfileSettingIds.Add(PSI_VoiceMuted)
	ProfileSettingIds.Add(UTPID_ControllerSensitivityMultiplier)
	ProfileSettingIds.Add(PSI_AutoAim)


	// UT Specific Ids
	ProfileSettingIds.Add(UTPID_CustomCharString)
	ProfileSettingIds.Add(UTPID_UnlockedCharacters)

	// Audio
	ProfileSettingIds.Add(UTPID_SFXVolume)
	ProfileSettingIds.Add(UTPID_MusicVolume)
	ProfileSettingIds.Add(UTPID_VoiceVolume)
	ProfileSettingIds.Add(UTPID_AnnouncerVolume)
	ProfileSettingIds.Add(UTPID_AnnounceSetting)
	ProfileSettingIds.Add(UTPID_AutoTaunt)
	ProfileSettingIds.Add(UTPID_MessageBeep)
	ProfileSettingIds.Add(UTPID_TextToSpeechMode)
	ProfileSettingIds.Add(UTPID_AmbianceVolume)

	// Video
	ProfileSettingIds.Add(UTPID_Gamma)
	ProfileSettingIds.Add(UTPID_PostProcessPreset)
	ProfileSettingIds.Add(UTPID_ScreenResolutionX)
	ProfileSettingIds.Add(UTPID_ScreenResolutionY)
	ProfileSettingIds.Add(UTPID_DefaultFOV)
	ProfileSettingIds.Add(UTPID_Subtitles)

	// Game
	ProfileSettingIds.Add(UTPID_ViewBob)
	ProfileSettingIds.Add(UTPID_GoreLevel)
	ProfileSettingIds.Add(UTPID_DodgingEnabled)
	ProfileSettingIds.Add(UTPID_WeaponSwitchOnPickup)
	ProfileSettingIds.Add(UTPID_Alias)
	ProfileSettingIds.Add(UTPID_ClanTag)
	ProfileSettingIds.Add(UTPID_NetworkConnection)
	ProfileSettingIds.Add(UTPID_DynamicNetspeed)
	ProfileSettingIds.Add(UTPID_SpeechRecognition)
	ProfileSettingIds.Add(UTPID_ServerDescription)
	ProfileSettingIds.Add(UTPID_AllowCustomCharacters)
	ProfileSettingIds.Add(UTPID_FirstTimeMultiplayer)

	// Input
	ProfileSettingIds.Add(UTPID_MouseSmoothing)
	ProfileSettingIds.Add(UTPID_ReduceMouseLag)
	ProfileSettingIds.Add(UTPID_EnableJoystick)
	ProfileSettingIds.Add(UTPID_MouseSensitivityGame)
	ProfileSettingIds.Add(UTPID_MouseSensitivityMenus)
	ProfileSettingIds.Add(UTPID_MouseSmoothingStrength)
	ProfileSettingIds.Add(UTPID_MouseAccelTreshold)
	ProfileSettingIds.Add(UTPID_DodgeDoubleClickTime)
	ProfileSettingIds.Add(UTPID_TurningAccelerationFactor)

	ProfileSettingIds.Add(UTPID_GamepadBinding_ButtonA)
	ProfileSettingIds.Add(UTPID_GamepadBinding_ButtonB)
	ProfileSettingIds.Add(UTPID_GamepadBinding_ButtonX)
	ProfileSettingIds.Add(UTPID_GamepadBinding_ButtonY)
	ProfileSettingIds.Add(UTPID_GamepadBinding_Back)
	ProfileSettingIds.Add(UTPID_GamepadBinding_RightBumper)
	ProfileSettingIds.Add(UTPID_GamepadBinding_LeftBumper)
	ProfileSettingIds.Add(UTPID_GamepadBinding_RightTrigger)
	ProfileSettingIds.Add(UTPID_GamepadBinding_LeftTrigger)
	ProfileSettingIds.Add(UTPID_GamepadBinding_RightThumbstickPressed)
	ProfileSettingIds.Add(UTPID_GamepadBinding_LeftThumbstickPressed)
	ProfileSettingIds.Add(UTPID_GamepadBinding_DPadUp)
	ProfileSettingIds.Add(UTPID_GamepadBinding_DPadDown)
	ProfileSettingIds.Add(UTPID_GamepadBinding_DPadLeft)
	ProfileSettingIds.Add(UTPID_GamepadBinding_DPadRight)
	ProfileSettingIds.Add(UTPID_GamepadBinding_AnalogStickPreset)

	ProfileSettingIds.Add(UTPID_AutoCenterPitch)
	ProfileSettingIds.Add(UTPID_AutoCenterVehiclePitch)
	ProfileSettingIds.Add(UTPID_TiltSensing)
	ProfileSettingIds.Add(UTPID_EnableHardwarePhysics)
	ProfileSettingIds.Add(UTPID_VehicleControls)

	// Weapons
	ProfileSettingIds.Add(UTPID_WeaponHand)
	ProfileSettingIds.Add(UTPID_SmallWeapons)
	ProfileSettingIds.Add(UTPID_DisplayWeaponBar)
	ProfileSettingIds.Add(UTPID_ShowOnlyAvailableWeapons)

	ProfileSettingIds.Add(UTPID_RocketLauncherPriority)
	ProfileSettingIds.Add(UTPID_LinkGunPriority)
	ProfileSettingIds.Add(UTPID_ShockRiflePriority)
	ProfileSettingIds.Add(UTPID_CrosshairType)

	// HUD
	ProfileSettingIds.Add(UTPID_ShowMap)
	ProfileSettingIds.Add(UTPID_ShowClock)
	ProfileSettingIds.Add(UTPID_ShowDoll)
	ProfileSettingIds.Add(UTPID_ShowAmmo)
	ProfileSettingIds.Add(UTPID_ShowPowerups)
	ProfileSettingIds.Add(UTPID_ShowScoring)
	ProfileSettingIds.Add(UTPID_ShowLeaderboard)
	ProfileSettingIds.Add(UTPID_RotateMap)
	ProfileSettingIds.Add(UTPID_ShowVehicleArmorCount)

	ProfileSettingIDs.Add(PSI_SinglePlayerMapMaskA);
	ProfileSettingIDs.Add(PSI_SinglePlayerMapMaskB);

	// Single player Persistent Keys
	ProfileSettingIds.Add(PSI_PersistentKeySlot0);
	ProfileSettingIds.Add(PSI_PersistentKeySlot1);
	ProfileSettingIds.Add(PSI_PersistentKeySlot2);
	ProfileSettingIds.Add(PSI_PersistentKeySlot3);
	ProfileSettingIds.Add(PSI_PersistentKeySlot4);
	ProfileSettingIds.Add(PSI_PersistentKeySlot5);
	ProfileSettingIds.Add(PSI_PersistentKeySlot6);
	ProfileSettingIds.Add(PSI_PersistentKeySlot7);
	ProfileSettingIds.Add(PSI_PersistentKeySlot8);
	ProfileSettingIds.Add(PSI_PersistentKeySlot9);
	ProfileSettingIds.Add(PSI_PersistentKeySlot10);
	ProfileSettingIds.Add(PSI_PersistentKeySlot11);
	ProfileSettingIds.Add(PSI_PersistentKeySlot12);
	ProfileSettingIds.Add(PSI_PersistentKeySlot13);
	ProfileSettingIds.Add(PSI_PersistentKeySlot14);
	ProfileSettingIds.Add(PSI_PersistentKeySlot15);
	ProfileSettingIds.Add(PSI_PersistentKeySlot16);
	ProfileSettingIds.Add(PSI_PersistentKeySlot17);
	ProfileSettingIds.Add(PSI_PersistentKeySlot18);
	ProfileSettingIds.Add(PSI_PersistentKeySlot19);

	ProfileSettingIds.Add(PSI_ChapterMask);
	ProfileSettingIds.Add(PSI_SinglePlayerSkillLevel);
	ProfileSettingIds.Add(PSI_SinglePlayerCurrentMission);
	ProfileSettingIDs.Add(PSI_SinglePlayerCurrentMissionResult);

	// PC Keys
	ProfileSettingIDs.Add(UTPID_KeyAction_1);
	ProfileSettingIDs.Add(UTPID_KeyAction_2);
	ProfileSettingIDs.Add(UTPID_KeyAction_3);
	ProfileSettingIDs.Add(UTPID_KeyAction_4);
	ProfileSettingIDs.Add(UTPID_KeyAction_5);
	ProfileSettingIDs.Add(UTPID_KeyAction_6);
	ProfileSettingIDs.Add(UTPID_KeyAction_7);
	ProfileSettingIDs.Add(UTPID_KeyAction_8);
	ProfileSettingIDs.Add(UTPID_KeyAction_9);
	ProfileSettingIDs.Add(UTPID_KeyAction_10);
	ProfileSettingIDs.Add(UTPID_KeyAction_11);
	ProfileSettingIDs.Add(UTPID_KeyAction_12);
	ProfileSettingIDs.Add(UTPID_KeyAction_13);
	ProfileSettingIDs.Add(UTPID_KeyAction_14);
	ProfileSettingIDs.Add(UTPID_KeyAction_15);
	ProfileSettingIDs.Add(UTPID_KeyAction_16);
	ProfileSettingIDs.Add(UTPID_KeyAction_17);
	ProfileSettingIDs.Add(UTPID_KeyAction_18);
	ProfileSettingIDs.Add(UTPID_KeyAction_19);
	ProfileSettingIDs.Add(UTPID_KeyAction_20);
	ProfileSettingIDs.Add(UTPID_KeyAction_21);
	ProfileSettingIDs.Add(UTPID_KeyAction_22);
	ProfileSettingIDs.Add(UTPID_KeyAction_23);
	ProfileSettingIDs.Add(UTPID_KeyAction_24);
	ProfileSettingIDs.Add(UTPID_KeyAction_25);
	ProfileSettingIDs.Add(UTPID_KeyAction_26);
	ProfileSettingIDs.Add(UTPID_KeyAction_27);
	ProfileSettingIDs.Add(UTPID_KeyAction_28);
	ProfileSettingIDs.Add(UTPID_KeyAction_29);
	ProfileSettingIDs.Add(UTPID_KeyAction_30);
	ProfileSettingIDs.Add(UTPID_KeyAction_31);
	ProfileSettingIDs.Add(UTPID_KeyAction_32);
	ProfileSettingIDs.Add(UTPID_KeyAction_33);
	ProfileSettingIDs.Add(UTPID_KeyAction_34);
	ProfileSettingIDs.Add(UTPID_KeyAction_35);
	ProfileSettingIDs.Add(UTPID_KeyAction_36);
	ProfileSettingIDs.Add(UTPID_KeyAction_37);
	ProfileSettingIDs.Add(UTPID_KeyAction_38);
	ProfileSettingIDs.Add(UTPID_KeyAction_39);
	ProfileSettingIDs.Add(UTPID_KeyAction_40);
	ProfileSettingIDs.Add(UTPID_KeyAction_41);
	ProfileSettingIDs.Add(UTPID_KeyAction_42);
	ProfileSettingIDs.Add(UTPID_KeyAction_43);
	ProfileSettingIDs.Add(UTPID_KeyAction_44);
	ProfileSettingIDs.Add(UTPID_KeyAction_45);
	ProfileSettingIDs.Add(UTPID_KeyAction_46);
	ProfileSettingIDs.Add(UTPID_KeyAction_47);
	ProfileSettingIDs.Add(UTPID_KeyAction_48);
	ProfileSettingIDs.Add(UTPID_KeyAction_49);

	/////////////////////////////////////////////////////////////
	// ProfileMappings - Information on how the data is presented to the UI system
	/////////////////////////////////////////////////////////////
	ProfileMappings.Empty

	// Online Service Mappings
	ProfileMappings[0]=(Id=PSI_ControllerVibration,Name="ControllerVibration",MappingType=PVMT_IdMapped,ValueMappings=((Id=PCVTO_Off),(Id=PCVTO_On)))
	ProfileMappings[1]=(Id=PSI_YInversion,Name="InvertY",MappingType=PVMT_IdMapped,ValueMappings=((Id=PYIO_Off),(Id=PYIO_On)))
	ProfileMappings[2]=(Id=PSI_VoiceMuted,Name="MuteVoice",MappingType=PVMT_IdMapped,ValueMappings=((Id=0),(Id=1)))
	ProfileMappings[3]=(Id=UTPID_ControllerSensitivityMultiplier,Name="ControllerSensitivityMultiplier",MappingType=PVMT_RawValue)
	ProfileMappings[4]=(Id=PSI_AutoAim,Name="AutoAim",MappingType=PVMT_IdMapped,ValueMappings=((Id=PAAO_Off),(Id=PAAO_On)))

	// UT Specific Mappings
	ProfileMappings[5]=(Id=UTPID_CustomCharString,Name="CustomCharData",MappingType=PVMT_RawValue)

	// Audio
	ProfileMappings[6]=(Id=UTPID_SFXVolume,Name="SFXVolume",MappingType=PVMT_RawValue)
	ProfileMappings[7]=(Id=UTPID_MusicVolume,Name="MusicVolume",MappingType=PVMT_RawValue)
	ProfileMappings[8]=(Id=UTPID_VoiceVolume,Name="VoiceVolume",MappingType=PVMT_RawValue)
	ProfileMappings[9]=(Id=UTPID_AnnouncerVolume,Name="AnnouncerVolume",MappingType=PVMT_RawValue)
	ProfileMappings[10]=(Id=UTPID_AnnounceSetting,Name="AnnounceSetting",MappingType=PVMT_IdMapped,ValueMappings=((Id=ANNOUNCE_OFF),(Id=ANNOUNCE_MINIMAL),(Id=ANNOUNCE_FULL)))
	ProfileMappings[11]=(Id=UTPID_AutoTaunt,Name="AutoTaunt",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[12]=(Id=UTPID_MessageBeep,Name="MessageBeep",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[13]=(Id=UTPID_TextToSpeechMode,Name="TextToSpeechMode",MappingType=PVMT_IdMapped,ValueMappings=((Id=TTSM_None),(Id=TTSM_TeamOnly),(Id=TTSM_All)))
	ProfileMappings[14]=(Id=UTPID_AmbianceVolume,Name="AmbianceVolume",MappingType=PVMT_RawValue)

	// Video
	ProfileMappings[15]=(Id=UTPID_Gamma,Name="Gamma",MappingType=PVMT_RawValue)
	ProfileMappings[16]=(Id=UTPID_PostProcessPreset,Name="PostProcessPreset",MappingType=PVMT_IdMapped,ValueMappings=((Id=PPP_Muted),(Id=PPP_Default),(Id=PPP_Vivid),(Id=PPP_Intense)))
	ProfileMappings[17]=(Id=UTPID_ScreenResolutionX,Name="ScreenResolutionX",MappingType=PVMT_RawValue)
	ProfileMappings[18]=(Id=UTPID_ScreenResolutionY,Name="ScreenResolutionY",MappingType=PVMT_RawValue)
	ProfileMappings[19]=(Id=UTPID_DefaultFOV,Name="DefaultFOV",MappingType=PVMT_RawValue)

	// Game
	ProfileMappings[20]=(Id=UTPID_ViewBob,Name="ViewBob",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[21]=(Id=UTPID_GoreLevel,Name="GoreLevel",MappingType=PVMT_IdMapped,ValueMappings=((Id=GORE_NORMAL),(Id=GORE_LOW)))
	ProfileMappings[22]=(Id=UTPID_DodgingEnabled,Name="DodgingEnabled",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[23]=(Id=UTPID_WeaponSwitchOnPickup,Name="WeaponSwitchOnPickup",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[24]=(Id=UTPID_NetworkConnection,Name="NetworkConnection",MappingType=PVMT_IdMapped,ValueMappings=((Id=NETWORKTYPE_Unknown),(Id=NETWORKTYPE_Modem),(Id=NETWORKTYPE_ISDN),(Id=NETWORKTYPE_Cable),(Id=NETWORKTYPE_LAN)))
	ProfileMappings[25]=(Id=UTPID_DynamicNetspeed,Name="DynamicNetspeed",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[26]=(Id=UTPID_SpeechRecognition,Name="SpeechRecognition",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))

	// Input
	ProfileMappings[27]=(Id=UTPID_MouseSmoothing,Name="MouseSmoothing",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[28]=(Id=UTPID_ReduceMouseLag,Name="ReduceMouseLag",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[29]=(Id=UTPID_EnableJoystick,Name="EnableJoystick",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[30]=(Id=UTPID_MouseSensitivityGame,Name="MouseSensitivityGame",MappingType=PVMT_RawValue)
	ProfileMappings[31]=(Id=UTPID_MouseSensitivityMenus,Name="MouseSensitivityMenus",MappingType=PVMT_RawValue)
	ProfileMappings[32]=(Id=UTPID_MouseSmoothingStrength,Name="MouseSmoothingStrength",MappingType=PVMT_RawValue)
	ProfileMappings[33]=(Id=UTPID_MouseAccelTreshold,Name="MouseAccelTreshold",MappingType=PVMT_RawValue)
	ProfileMappings[34]=(Id=UTPID_DodgeDoubleClickTime,Name="DodgeDoubleClickTime",MappingType=PVMT_RawValue)
	ProfileMappings[35]=(Id=UTPID_TurningAccelerationFactor,Name="TurningAccelerationFactor",MappingType=PVMT_RawValue)

	ProfileMappings[36]=(Id=UTPID_MouseSmoothing)
	ProfileMappings[37]=(Id=UTPID_ReduceMouseLag)
	ProfileMappings[38]=(Id=UTPID_EnableJoystick)
	ProfileMappings[39]=(Id=UTPID_MouseSensitivityGame)
	ProfileMappings[40]=(Id=UTPID_MouseSensitivityMenus)
	ProfileMappings[41]=(Id=UTPID_MouseSmoothingStrength)
	ProfileMappings[42]=(Id=UTPID_MouseAccelTreshold)
	ProfileMappings[43]=(Id=UTPID_DodgeDoubleClickTime)
	ProfileMappings[44]=(Id=UTPID_TurningAccelerationFactor)

	ProfileMappings[45]=(Id=UTPID_GamepadBinding_ButtonA,Name="GamepadBinding_ButtonA",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[46]=(Id=UTPID_GamepadBinding_ButtonB,Name="GamepadBinding_ButtonB",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[47]=(Id=UTPID_GamepadBinding_ButtonX,Name="GamepadBinding_ButtonX",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[48]=(Id=UTPID_GamepadBinding_ButtonY,Name="GamepadBinding_ButtonY",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[49]=(Id=UTPID_GamepadBinding_Back,Name="GamepadBinding_Back",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[50]=(Id=UTPID_GamepadBinding_RightBumper,Name="GamepadBinding_RightBumper",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[51]=(Id=UTPID_GamepadBinding_LeftBumper,Name="GamepadBinding_LeftBumper",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[52]=(Id=UTPID_GamepadBinding_RightTrigger,Name="GamepadBinding_RightTrigger",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[53]=(Id=UTPID_GamepadBinding_LeftTrigger,Name="GamepadBinding_LeftTrigger",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[54]=(Id=UTPID_GamepadBinding_RightThumbstickPressed,Name="GamepadBinding_RightThumbstickPressed",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[55]=(Id=UTPID_GamepadBinding_LeftThumbstickPressed,Name="GamepadBinding_LeftThumbstickPressed",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[56]=(Id=UTPID_GamepadBinding_DPadUp,Name="GamepadBinding_DPadUp",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[57]=(Id=UTPID_GamepadBinding_DPadDown,Name="GamepadBinding_DPadDown",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[58]=(Id=UTPID_GamepadBinding_DPadLeft,Name="GamepadBinding_DPadLeft",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[59]=(Id=UTPID_GamepadBinding_DPadRight,Name="GamepadBinding_DPadRight",MappingType=PVMT_IdMapped,ValueMappings=((Id=DBA_None),(Id=DBA_Fire),(Id=DBA_AltFire),(Id=DBA_Jump),(Id=DBA_Use),(Id=DBA_ToggleMelee),(Id=DBA_ShowScores),(Id=DBA_ShowMap),(Id=DBA_FeignDeath),(Id=DBA_ToggleSpeaking),(Id=DBA_ShowCommandMenu),(Id=DBA_ToggleMinimap),(Id=DBA_WeaponPicker),(Id=DBA_NextWeapon),(Id=DBA_BestWeapon),(Id=DBA_PrevWeapon)))
	ProfileMappings[60]=(Id=UTPID_GamepadBinding_AnalogStickPreset,Name="GamepadBinding_AnalogStickPreset",MappingType=PVMT_IdMapped,ValueMappings=((Id=ESA_Normal),(Id=ESA_SouthPaw),(Id=ESA_Legacy),(Id=ESA_LegacySouthPaw)))

	ProfileMappings[61]=(Id=UTPID_AutoCenterPitch,Name="AutoCenterPitch",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[62]=(Id=UTPID_AutoCenterVehiclePitch,Name="AutoCenterVehiclePitch",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[63]=(Id=UTPID_TiltSensing,Name="TiltSensing",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))

	// Weapons
	ProfileMappings[64]=(Id=UTPID_WeaponHand,Name="WeaponHand",MappingType=PVMT_IdMapped,ValueMappings=((Id=HAND_Right),(Id=HAND_Left),(Id=HAND_Hidden)))
	ProfileMappings[65]=(Id=UTPID_SmallWeapons,Name="SmallWeapons",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[66]=(Id=UTPID_DisplayWeaponBar,Name="DisplayWeaponBar",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[67]=(Id=UTPID_ShowOnlyAvailableWeapons,Name="ShowOnlyAvailableWeapons",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))

	ProfileMappings[68]=(Id=UTPID_RocketLauncherPriority,Name="UTGame.UTWeap_RocketLauncher_Priority",MappingType=PVMT_RawValue)
	ProfileMappings[72]=(Id=UTPID_LinkGunPriority,Name="UTGame.UTWeap_LinkGun_Priority",MappingType=PVMT_RawValue)
	ProfileMappings[74]=(Id=UTPID_ShockRiflePriority,Name="UTGame.UTWeap_ShockRifle_Priority",MappingType=PVMT_RawValue)

	// HUD
	ProfileMappings[78]=(Id=UTPID_ShowMap,Name="ShowMap",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[79]=(Id=UTPID_ShowClock,Name="ShowClock",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[80]=(Id=UTPID_ShowDoll,Name="ShowDoll",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[81]=(Id=UTPID_ShowAmmo,Name="ShowAmmo",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[82]=(Id=UTPID_ShowPowerups,Name="ShowPowerups",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[83]=(Id=UTPID_ShowScoring,Name="ShowScoring",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[84]=(Id=UTPID_ShowLeaderboard,Name="ShowLeaderboard",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[85]=(Id=UTPID_RotateMap,Name="RotateMap",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[86]=(Id=UTPID_ShowVehicleArmorCount,Name="ShowVehicleArmorCount",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))

	// Physics
	ProfileMappings[87]=(Id=UTPID_EnableHardwarePhysics,Name="EnableHardwarePhysics",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[88]=(Id=UTPID_VehicleControls,Name="VehicleControls",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTVC_Simple),(Id=UTVC_Normal),(Id=UTVC_Advanced)))

	// Other
	ProfileMappings[89]=(Id=UTPID_AllowCustomCharacters,Name="AllowCustomCharacters",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))
	ProfileMappings[90]=(Id=UTPID_CrosshairType,Name="CrosshairType",MappingType=PVMT_IdMapped,ValueMappings=((Id=CHT_Normal),(Id=CHT_Simple),(Id=CHT_None)))
	ProfileMappings[91]=(Id=UTPID_Subtitles,Name="Subtitles",MappingType=PVMT_IdMapped,ValueMappings=((Id=UTPID_VALUE_NO),(Id=UTPID_VALUE_YES)))

	// Single Player
	ProfileMappings[92]=(Id=PSI_SinglePlayerSkillLevel,Name="SkillLevel",MappingType=PVMT_RawValue))


	// Chapter Mask
	ProfileMappings.Add((ID=PSI_ChapterMask,NAme="ChapterMask",MappingType=PVMT_RawValue))

	ProfileMappings.Add((Id=PSI_SinglePlayerMapMaskA, Name="MapMaskA",MappingType=PVMT_RawValue))
 	ProfileMappings.Add((Id=PSI_SinglePlayerMapMaskB, Name="MapMaskB",MappingType=PVMT_RawValue))

	ProfileMappings.Add((Id=PSI_PersistentKeySlot0, Name="PKey0",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot1, Name="PKey1",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot2, Name="PKey2",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot3, Name="PKey3",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot4, Name="PKey4",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot5, Name="PKey5",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot6, Name="PKey6",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot7, Name="PKey7",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot8, Name="PKey8",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot9, Name="PKey9",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot10, Name="PKey10",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot11, Name="PKey11",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot12, Name="PKey12",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot13, Name="PKey13",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot14, Name="PKey14",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot15, Name="PKey15",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot16, Name="PKey16",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot17, Name="PKey17",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot18, Name="PKey18",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_PersistentKeySlot19, Name="PKey19",MappingType=PVMT_RawValue))

	ProfileMappings.Add((Id=PSI_SinglePlayerCurrentMission, NAME="CurrentMission",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=PSI_SinglePlayerCurrentMissionResult, NAME="CurrentMissionResult",MappingType=PVMT_RawValue))

	// Other
	ProfileMappings.Add((Id=UTPID_UnlockedCharacters,Name="UnlockedCharacters",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_Alias,Name="Alias",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_ClanTag,Name="ClanTag",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_ServerDescription,Name="ServerDescription",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_FirstTimeMultiplayer,Name="FirstTimeMultiplayer",MappingType=PVMT_RawValue))

	// PC Keys
	ProfileMappings.Add((Id=UTPID_KeyAction_1,Name="KeyAction_1",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_2,Name="KeyAction_2",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_3,Name="KeyAction_3",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_4,Name="KeyAction_4",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_5,Name="KeyAction_5",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_6,Name="KeyAction_6",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_7,Name="KeyAction_7",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_8,Name="KeyAction_8",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_9,Name="KeyAction_9",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_10,Name="KeyAction_10",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_11,Name="KeyAction_11",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_12,Name="KeyAction_12",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_13,Name="KeyAction_13",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_14,Name="KeyAction_14",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_15,Name="KeyAction_15",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_16,Name="KeyAction_16",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_17,Name="KeyAction_17",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_18,Name="KeyAction_18",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_19,Name="KeyAction_19",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_20,Name="KeyAction_20",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_21,Name="KeyAction_21",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_22,Name="KeyAction_22",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_23,Name="KeyAction_23",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_24,Name="KeyAction_24",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_25,Name="KeyAction_25",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_26,Name="KeyAction_26",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_27,Name="KeyAction_27",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_28,Name="KeyAction_28",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_29,Name="KeyAction_29",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_30,Name="KeyAction_30",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_31,Name="KeyAction_31",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_32,Name="KeyAction_32",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_33,Name="KeyAction_33",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_34,Name="KeyAction_34",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_35,Name="KeyAction_35",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_36,Name="KeyAction_36",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_37,Name="KeyAction_37",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_38,Name="KeyAction_38",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_39,Name="KeyAction_39",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_40,Name="KeyAction_40",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_41,Name="KeyAction_41",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_42,Name="KeyAction_42",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_43,Name="KeyAction_43",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_44,Name="KeyAction_44",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_45,Name="KeyAction_45",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_46,Name="KeyAction_46",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_47,Name="KeyAction_47",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_48,Name="KeyAction_48",MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=UTPID_KeyAction_49,Name="KeyAction_49",MappingType=PVMT_RawValue))

	/////////////////////////////////////////////////////////////
	// DefaultSettings - Defaults for the profile
	/////////////////////////////////////////////////////////////
	DefaultSettings.Empty

	// Online Service - Defaults for the values if not specified by the online service
	DefaultSettings.Add((Owner=OPPO_OnlineService,ProfileSetting=(PropertyId=PSI_ControllerVibration,Data=(Type=SDT_Int32,Value1=PCVTO_On))))
	DefaultSettings.Add((Owner=OPPO_OnlineService,ProfileSetting=(PropertyId=PSI_YInversion,Data=(Type=SDT_Int32,Value1=PYIO_Off))))
	DefaultSettings.Add((Owner=OPPO_OnlineService,ProfileSetting=(PropertyId=PSI_VoiceMuted,Data=(Type=SDT_Int32,Value1=PYIO_Off))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ControllerSensitivityMultiplier,Data=(Type=SDT_Int32,Value1=10))))
	DefaultSettings.Add((Owner=OPPO_OnlineService,ProfileSetting=(PropertyId=PSI_AutoAim,Data=(Type=SDT_Int32,Value1=PAAO_Off))))

	// UT Specific Defaults
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_CustomCharString,Data=(Type=SDT_String))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_UnlockedCharacters,Data=(Type=SDT_Int32))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_FirstTimeMultiplayer,Data=(Type=SDT_Int32))))

	// Audio
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_SFXVolume,Data=(Type=SDT_Int32,Value1=5))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MusicVolume,Data=(Type=SDT_Int32,Value1=5))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_VoiceVolume,Data=(Type=SDT_Int32,Value1=6))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AmbianceVolume,Data=(Type=SDT_Int32,Value1=5))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AnnouncerVolume,Data=(Type=SDT_Int32,Value1=5))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AnnounceSetting,Data=(Type=SDT_Int32,Value1=ANNOUNCE_FULL))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AutoTaunt,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MessageBeep,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_TextToSpeechMode,Data=(Type=SDT_Int32,Value1=TTSM_None))))

	// Video
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_Gamma,Data=(Type=SDT_Int32,Value1=6))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_PostProcessPreset,Data=(Type=SDT_Int32,Value1=PPP_Default))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ScreenResolutionX,Data=(Type=SDT_Int32,Value1=1024))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ScreenResolutionY,Data=(Type=SDT_Int32,Value1=768))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_DefaultFOV,Data=(Type=SDT_Int32,Value1=90))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_Subtitles,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))

	// Game
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ViewBob,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GoreLevel,Data=(Type=SDT_Int32,Value1=GORE_NORMAL))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_DodgingEnabled,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_WeaponSwitchOnPickup,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_NetworkConnection,Data=(Type=SDT_Int32,Value1=NETWORKTYPE_Cable))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_DynamicNetspeed,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_SpeechRecognition,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_Alias,Data=(Type=SDT_String))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ClanTag,Data=(Type=SDT_String))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ServerDescription,Data=(Type=SDT_String))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AllowCustomCharacters,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))

	// Input
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MouseSmoothing,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ReduceMouseLag,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_EnableJoystick,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MouseSensitivityGame,Data=(Type=SDT_Int32,Value1=2500))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MouseSensitivityMenus,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MouseSmoothingStrength,Data=(Type=SDT_Int32,Value1=10))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_MouseAccelTreshold,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_DodgeDoubleClickTime,Data=(Type=SDT_Int32,Value1=25))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_TurningAccelerationFactor,Data=(Type=SDT_Int32,Value1=4))))

	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_ButtonA,Data=(Type=SDT_Int32,Value1=DBA_Jump))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_ButtonB,Data=(Type=SDT_Int32,Value1=DBA_ToggleMelee))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_ButtonX,Data=(Type=SDT_Int32,Value1=DBA_Use))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_ButtonY,Data=(Type=SDT_Int32,Value1=DBA_ShowMap))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_Back,Data=(Type=SDT_Int32,Value1=DBA_ShowScores))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_RightBumper,Data=(Type=SDT_Int32,Value1=DBA_Fire))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_LeftBumper,Data=(Type=SDT_Int32,Value1=DBA_AltFire))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_RightTrigger,Data=(Type=SDT_Int32,Value1=DBA_NextWeapon))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_LeftTrigger,Data=(Type=SDT_Int32,Value1=DBA_WeaponPicker))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_RightThumbstickPressed,Data=(Type=SDT_Int32,Value1=DBA_BestWeapon))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_LeftThumbstickPressed,Data=(Type=SDT_Int32,Value1=DBA_Jump))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_DPadUp,Data=(Type=SDT_Int32,Value1=DBA_ToggleMinimap))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_DPadDown,Data=(Type=SDT_Int32,Value1=DBA_FeignDeath))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_DPadLeft,Data=(Type=SDT_Int32,Value1=DBA_ShowCommandMenu))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_DPadRight,Data=(Type=SDT_Int32,Value1=DBA_ToggleSpeaking))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_GamepadBinding_AnalogStickPreset,Data=(Type=SDT_Int32,Value1=ESA_Normal))))

	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AutoCenterPitch,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_AutoCenterVehiclePitch,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_TiltSensing,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_EnableHardwarePhysics,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_VehicleControls, Data=(Type=SDT_Int32,Value1=UTVC_Simple))))


	// Weapons
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_WeaponHand,Data=(Type=SDT_Int32,Value1=HAND_Right))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_SmallWeapons,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_DisplayWeaponBar,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowOnlyAvailableWeapons,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_yES))))


	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_RocketLauncherPriority,Data=(Type=SDT_Float))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_LinkGunPriority,Data=(Type=SDT_Float))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShockRiflePriority,Data=(Type=SDT_Float))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_CrosshairType,Data=(Type=SDT_Int32,Value1=CHT_Normal))))

	// HUD
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowMap,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowClock,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowDoll,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowAmmo,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowPowerups,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowScoring,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_YES))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowLeaderboard,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_RotateMap,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_ShowVehicleArmorCount,Data=(Type=SDT_Int32,Value1=UTPID_VALUE_NO))))

	// PC Keys
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_1,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_2,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_3,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_4,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_5,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_6,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_7,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_8,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_9,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_10,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_11,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_12,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_13,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_14,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_15,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_16,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_17,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_18,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_19,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_20,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_21,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_22,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_23,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_24,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_25,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_26,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_27,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_28,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_29,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_30,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_31,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_32,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_33,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_34,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_35,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_36,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_37,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_38,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_39,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_40,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_41,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_42,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_43,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_44,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_45,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_46,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_47,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_48,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=UTPID_KeyAction_49,Data=(Type=SDT_Int32,Value1=0)))

	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_SinglePlayerMapMaskA,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_SinglePlayerMapMaskB,Data=(Type=SDT_Int32,Value1=0)))

	// Single Player
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot0,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot1,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot2,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot3,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot4,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot5,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot6,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot7,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot8,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot9,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot10,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot11,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot12,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot13,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot14,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot15,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot16,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot17,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot18,Data=(Type=SDT_Int32,Value1=0)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_PersistentKeySlot19,Data=(Type=SDT_Int32,Value1=0)))

	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_SinglePlayerSkillLevel,Data=(Type=SDT_Int32,Value1=1)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_SinglePlayerCurrentMission,Data=(Type=SDT_Int32,Value1=-1)))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_SinglePlayerCurrentMissionResult,Data=(Type=SDT_Int32,Value1=0)))

    DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=PSI_ChapterMask,Data=(Type=SDT_Int32,Value1=0)))

	// Keymapping array - Maps enum to unreal key names.
	KeyMappingArray[UTBND_MouseX]="MouseX";
	KeyMappingArray[UTBND_MouseY]="MouseY";
	KeyMappingArray[UTBND_MouseScrollUp]="MouseScrollUp";
	KeyMappingArray[UTBND_MouseScrollDown]="MouseScrollDown";
	KeyMappingArray[UTBND_LeftMouseButton]="LeftMouseButton";
	KeyMappingArray[UTBND_RightMouseButton]="RightMouseButton";
	KeyMappingArray[UTBND_MiddleMouseButton]="MiddleMouseButton";
	KeyMappingArray[UTBND_ThumbMouseButton]="ThumbMouseButton";
	KeyMappingArray[UTBND_ThumbMouseButton2]="ThumbMouseButton2";
	KeyMappingArray[UTBND_BackSpace]="BackSpace";
	KeyMappingArray[UTBND_Tab]="Tab";
	KeyMappingArray[UTBND_Enter]="Enter";
	KeyMappingArray[UTBND_Pause]="Pause";
	KeyMappingArray[UTBND_CapsLock]="CapsLock";
	KeyMappingArray[UTBND_Escape]="Escape";
	KeyMappingArray[UTBND_SpaceBar]="SpaceBar";
	KeyMappingArray[UTBND_PageUp]="PageUp";
	KeyMappingArray[UTBND_PageDown]="PageDown";
	KeyMappingArray[UTBND_End]="End";
	KeyMappingArray[UTBND_Home]="Home";
	KeyMappingArray[UTBND_Left]="Left";
	KeyMappingArray[UTBND_Up]="Up";
	KeyMappingArray[UTBND_Right]="Right";
	KeyMappingArray[UTBND_Down]="Down";
	KeyMappingArray[UTBND_Insert]="Insert";
	KeyMappingArray[UTBND_Delete]="Delete";
	KeyMappingArray[UTBND_Zero]="Zero";
	KeyMappingArray[UTBND_One]="One";
	KeyMappingArray[UTBND_Two]="Two";
	KeyMappingArray[UTBND_Three]="Three";
	KeyMappingArray[UTBND_Four]="Four";
	KeyMappingArray[UTBND_Five]="Five";
	KeyMappingArray[UTBND_Six]="Six";
	KeyMappingArray[UTBND_Seven]="Seven";
	KeyMappingArray[UTBND_Eight]="Eight";
	KeyMappingArray[UTBND_Nine]="Nine";
	KeyMappingArray[UTBND_A]="A";
	KeyMappingArray[UTBND_B]="B";
	KeyMappingArray[UTBND_C]="C";
	KeyMappingArray[UTBND_D]="D";
	KeyMappingArray[UTBND_E]="E";
	KeyMappingArray[UTBND_F]="F";
	KeyMappingArray[UTBND_G]="G";
	KeyMappingArray[UTBND_H]="H";
	KeyMappingArray[UTBND_I]="I";
	KeyMappingArray[UTBND_J]="J";
	KeyMappingArray[UTBND_K]="K";
	KeyMappingArray[UTBND_L]="L";
	KeyMappingArray[UTBND_M]="M";
	KeyMappingArray[UTBND_N]="N";
	KeyMappingArray[UTBND_O]="O";
	KeyMappingArray[UTBND_P]="P";
	KeyMappingArray[UTBND_Q]="Q";
	KeyMappingArray[UTBND_R]="R";
	KeyMappingArray[UTBND_S]="S";
	KeyMappingArray[UTBND_T]="T";
	KeyMappingArray[UTBND_U]="U";
	KeyMappingArray[UTBND_V]="V";
	KeyMappingArray[UTBND_W]="W";
	KeyMappingArray[UTBND_X]="X";
	KeyMappingArray[UTBND_Y]="Y";
	KeyMappingArray[UTBND_Z]="Z";
	KeyMappingArray[UTBND_NumPadZero]="NumPadZero";
	KeyMappingArray[UTBND_NumPadOne]="NumPadOne";
	KeyMappingArray[UTBND_NumPadTwo]="NumPadTwo";
	KeyMappingArray[UTBND_NumPadThree]="NumPadThree";
	KeyMappingArray[UTBND_NumPadFour]="NumPadFour";
	KeyMappingArray[UTBND_NumPadFive]="NumPadFive";
	KeyMappingArray[UTBND_NumPadSix]="NumPadSix";
	KeyMappingArray[UTBND_NumPadSeven]="NumPadSeven";
	KeyMappingArray[UTBND_NumPadEight]="NumPadEight";
	KeyMappingArray[UTBND_NumPadNine]="NumPadNine";
	KeyMappingArray[UTBND_Multiply]="Multiply";
	KeyMappingArray[UTBND_Add]="Add";
	KeyMappingArray[UTBND_Subtract]="Subtract";
	KeyMappingArray[UTBND_Decimal]="Decimal";
	KeyMappingArray[UTBND_Divide]="Divide";
	KeyMappingArray[UTBND_F1]="F1";
	KeyMappingArray[UTBND_F2]="F2";
	KeyMappingArray[UTBND_F3]="F3";
	KeyMappingArray[UTBND_F4]="F4";
	KeyMappingArray[UTBND_F5]="F5";
	KeyMappingArray[UTBND_F6]="F6";
	KeyMappingArray[UTBND_F7]="F7";
	KeyMappingArray[UTBND_F8]="F8";
	KeyMappingArray[UTBND_F9]="F9";
	KeyMappingArray[UTBND_F10]="F10";
	KeyMappingArray[UTBND_F11]="F11";
	KeyMappingArray[UTBND_F12]="F12";
	KeyMappingArray[UTBND_NumLock]="NumLock";
	KeyMappingArray[UTBND_ScrollLock]="ScrollLock";
	KeyMappingArray[UTBND_LeftShift]="LeftShift";
	KeyMappingArray[UTBND_RightShift]="RightShift";
	KeyMappingArray[UTBND_LeftControl]="LeftControl";
	KeyMappingArray[UTBND_RightControl]="RightControl";
	KeyMappingArray[UTBND_LeftAlt]="LeftAlt";
	KeyMappingArray[UTBND_RightAlt]="RightAlt";
	KeyMappingArray[UTBND_Semicolon]="Semicolon";
	KeyMappingArray[UTBND_Equals]="Equals";
	KeyMappingArray[UTBND_Comma]="Comma";
	KeyMappingArray[UTBND_Underscore]="Underscore";
	KeyMappingArray[UTBND_Period]="Period";
	KeyMappingArray[UTBND_Slash]="Slash";
	KeyMappingArray[UTBND_Tilde]="Tilde";
	KeyMappingArray[UTBND_LeftBracket]="LeftBracket";
	KeyMappingArray[UTBND_Backslash]="Backslash";
	KeyMappingArray[UTBND_RightBracket]="RightBracket";
	KeyMappingArray[UTBND_Quote]="Quote";

	KeyMappingArray[UTBND_LeftStickX]="XBoxTypeS_LeftX"
	KeyMappingArray[UTBND_LeftStickY]="XboxTypeS_LeftY"
	KeyMappingArray[UTBND_LeftStick_Click]="XboxTypeS_LeftThumbstick"
	KeyMappingArray[UTBND_RightStick_X]="XboxTypeS_RightX"
	KeyMappingArray[UTBND_RightStick_Y]="XboxTypeS_RightY"
	KeyMappingArray[UTBND_RightStick_Click]="XboxTypeS_RightThumbstick"
	KeyMappingArray[UTBND_ButtonA]="XboxTypeS_A"
	KeyMappingArray[UTBND_ButtonB]="XboxTypeS_B"
	KeyMappingArray[UTBND_ButtonX]="XboxTypeS_X"
	KeyMappingArray[UTBND_ButtonY]="XboxTypeS_Y"
	KeyMappingArray[UTBND_LeftShoulder]="XboxTypeS_LeftShoulder"
	KeyMappingArray[UTBND_RightShoulder]="XboxTypeS_RightShoulder"
	KeyMappingArray[UTBND_LeftTrigger]="XboxTypeS_LeftTrigger"
	KeyMappingArray[UTBND_RightTrigger]="XboxTypeS_RightTrigger"
	KeyMappingArray[UTBND_Start]="XboxTypeS_Start"
	KeyMappingArray[UTBND_Select]="XboxTypeS_Back"
	KeyMappingArray[UTBND_DPad_Up]="XboxTypeS_DPad_Up"
	KeyMappingArray[UTBND_DPad_Down]="XboxTypeS_DPad_Down"
	KeyMappingArray[UTBND_DPad_Left]="XboxTypeS_DPad_Right"
	KeyMappingArray[UTBND_DPad_Right]="XboxTypeS_DPad_Left"
	KeyMappingArray[UTBND_SpecialX]="SIXAXIS_AccelX"
	KeyMappingArray[UTBND_SpecialY]="SIXAXIS_AccelY"
	KeyMappingArray[UTBND_SpecialZ]="SIXAXIS_AccelZ"
	KeyMappingArray[UTBND_SpecialW]="SIXAXIS_Gyro"

	// Action mapping array
	DigitalButtonActionsToCommandMapping[DBA_None]="";
	DigitalButtonActionsToCommandMapping[DBA_Fire]="GBA_Fire";
	DigitalButtonActionsToCommandMapping[DBA_AltFire]="GBA_AltFire";
	DigitalButtonActionsToCommandMapping[DBA_Jump]="GBA_Jump_Gamepad";
	DigitalButtonActionsToCommandMapping[DBA_Use]="GBA_Use";
	DigitalButtonActionsToCommandMapping[DBA_ToggleMelee]="GBA_ToggleMelee";
	DigitalButtonActionsToCommandMapping[DBA_ShowScores]="GBA_ShowScores";
	DigitalButtonActionsToCommandMapping[DBA_ShowMap]="GBA_ShowMap";
	DigitalButtonActionsToCommandMapping[DBA_FeignDeath]="GBA_FeignDeath";
	DigitalButtonActionsToCommandMapping[DBA_ToggleSpeaking]="GBA_ToggleSpeaking";
	DigitalButtonActionsToCommandMapping[DBA_ToggleMinimap]="GBA_ToggleMinimap";
	DigitalButtonActionsToCommandMapping[DBA_WeaponPicker]="GBA_WeaponPicker";
	DigitalButtonActionsToCommandMapping[DBA_NextWeapon]="GBA_NextWeapon";
	DigitalButtonActionsToCommandMapping[DBA_PrevWeapon]="GBA_PrevWeapon";
	DigitalButtonActionsToCommandMapping[DBA_BestWeapon]="GBA_SwitchToBestWeapon_Gamepad";
	DigitalButtonActionsToCommandMapping[DBA_Duck]="GBA_Duck";
	DigitalButtonActionsToCommandMapping[DBA_MoveForward]="GBA_MoveForward";
	DigitalButtonActionsToCommandMapping[DBA_MoveBackward]="GBA_Backward";
	DigitalButtonActionsToCommandMapping[DBA_StrafeLeft]="GBA_StrafeLeft";
	DigitalButtonActionsToCommandMapping[DBA_StrafeRight]="GBA_StrafeRight";
	DigitalButtonActionsToCommandMapping[DBA_TurnLeft]="GBA_TurnLeft";
	DigitalButtonActionsToCommandMapping[DBA_TurnRight]="GBA_TurnRight";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon1]="GBA_SwitchWeapon1";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon2]="GBA_SwitchWeapon2";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon3]="GBA_SwitchWeapon3";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon4]="GBA_SwitchWeapon4";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon5]="GBA_SwitchWeapon5";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon6]="GBA_SwitchWeapon6";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon7]="GBA_SwitchWeapon7";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon8]="GBA_SwitchWeapon8";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon9]="GBA_SwitchWeapon9";
	DigitalButtonActionsToCommandMapping[DBA_SwitchWeapon10]="GBA_SwitchWeapon10";
	DigitalButtonActionsToCommandMapping[DBA_ShrinkHUD]="GBA_GrowHud";
	DigitalButtonActionsToCommandMapping[DBA_GrowHUD]="GBA_ShrinkHud";
	DigitalButtonActionsToCommandMapping[DBA_Horn]="GBA_Horn";
	DigitalButtonActionsToCommandMapping[DBA_Talk]="GBA_Talk";
	DigitalButtonActionsToCommandMapping[DBA_TeamTalk]="GBA_TeamTalk";
	DigitalButtonActionsToCommandMapping[DBA_ShowCommandMenu]="GBA_ShowCommandMenu";
	DigitalButtonActionsToCommandMapping[DBA_ShowMenu]="GBA_ShowMenu";
	DigitalButtonActionsToCommandMapping[DBA_ToggleTranslocator]="GBA_ToggleTranslocator";
	DigitalButtonActionsToCommandMapping[DBA_JumpPC]="GBA_Jump";
	DigitalButtonActionsToCommandMapping[DBA_BestWeaponPC]="GBA_SwitchToBestWeapon";
}
