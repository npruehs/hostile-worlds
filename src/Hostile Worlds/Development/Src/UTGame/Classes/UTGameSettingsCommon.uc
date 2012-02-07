/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** Holds the settings that are common to all match types */
class UTGameSettingsCommon extends UDKGameSettingsCommon;

`include(UTOnlineConstants.uci)

/** The maximum number of players allowed on this server. */
var databinding int MaxPlayers;

/** The minumum number of players that must be present before the match starts. */
var databinding int MinNetPlayers;

/**
 * Sets the property that advertises the custom map name
 *
 * @param MapName the string to use
 */
function SetCustomMapName(string MapName)
{
	local SettingsData CustomMap;

	if (Properties[4].PropertyId == PROPERTY_CUSTOMMAPNAME)
	{
		SetSettingsDataString(CustomMap,MapName);
		Properties[4].Data = CustomMap;
	}
	else
	{
		`Log("Failed to set custom map name because property order changed!");
	}
}

/**
 * Sets the property that advertises the official mutators being used in the game.
 *
 * @param	MutatorBitmask	bitmask of epic mutators that are active for this game session (bits are derived
 *							by left-shifting by the mutator's index into the UTUIDataStore_MenuItems' list of
 *							UTUIDataProvider_Mutators
 */
function SetOfficialMutatorBitmask( int MutatorBitmask )
{
	SetIntProperty(PROPERTY_EPICMUTATORS, MutatorBitmask);
}

/**
 * Builds a URL string out of the properties/contexts and databindings of this object.
 */
function BuildURL(out string OutURL)
{
	local int SettingIdx;
	local int OutValue;
	local float Ratio;
	local name SettingName;
	local name PropertyName;
	local string Description;

	OutURL = "";

	// Append properties marked with the databinding keyword to the URL
	AppendDataBindingsToURL(OutURL);

	// Iterate through localized settings and append them
	for (SettingIdx = 0; SettingIdx < LocalizedSettings.length; SettingIdx++)
	{
		SettingName = GetStringSettingName(LocalizedSettings[SettingIdx].Id);
		if (SettingName != '')
		{
			// For certain context's, output their string value name instead of their value index.
			switch(LocalizedSettings[SettingIdx].Id)
			{
			case CONTEXT_BOTSKILL:
				OutURL $= "?Difficulty=" $ LocalizedSettings[SettingIdx].ValueIndex;
				break;

			case CONTEXT_VSBOTS:
				if(GetStringSettingValue(CONTEXT_VSBOTS, OutValue))
				{
					Ratio = -1.0f;

					// Convert the vs bot context value to a floating point ratio of bots to players.
					switch(OutValue)
					{
					case CONTEXT_VSBOTS_1_TO_2:
						Ratio = 0.5f;
						break;
					case CONTEXT_VSBOTS_1_TO_1:
						Ratio = 1.0f;
						break;
					case CONTEXT_VSBOTS_3_TO_2:
						Ratio = 1.5f;
						break;
					case CONTEXT_VSBOTS_2_TO_1:
						Ratio = 2.0f;
						break;
					case CONTEXT_VSBOTS_3_TO_1:
						Ratio = 3.0f;
						break;
					case CONTEXT_VSBOTS_4_TO_1:
						Ratio = 4.0f;
						break;
					default:
						break;
					}

					if(Ratio > 0)
					{
						OutURL $= "?VsBots=" $ Ratio;
					}
				}
				break;

			// these are the values that are handled in other ways (don't append the values here)
			case CONTEXT_MAPNAME:		// index of map - but we go by mapname
			case CONTEXT_FULLSERVER:	// calculated on the server as players login
			case CONTEXT_EMPTYSERVER:	// calculated on the server as players login
			case CONTEXT_DEDICATEDSERVER:	// calculated on server based on the databinding property bIsDedicated
				break;

				// GameInfo.UpdateGameSettingsCounts() won't be called until a player logs in, so pass IsEmptyServer=1
				// on the URL so that dedicated servers will start off with this set
			case CONTEXT_ALLOWKEYBOARD:
				if ( class'UIRoot'.static.IsConsole(CONSOLE_PS3) )	// Only set allow keyboard option on ps3.
				{
					OutURL $= "?" $ SettingName $ "=" $ LocalizedSettings[SettingIdx].ValueIndex;
				}
				break;
			default:
				OutURL $= "?" $ SettingName $ "=" $ LocalizedSettings[SettingIdx].ValueIndex;
				break;
			}
		}
	}

	// Now add all properties the same way
	for (SettingIdx = 0; SettingIdx < Properties.length; SettingIdx++)
	{
		PropertyName = GetPropertyName(Properties[SettingIdx].PropertyId);
		if (PropertyName != '')
		{
			switch(Properties[SettingIdx].PropertyId)
			{
			case PROPERTY_NUMBOTS:
				// Will be handled by game launching code.
				break;

			case PROPERTY_SERVERDESCRIPTION:
				Description=GetPropertyAsString(PROPERTY_SERVERDESCRIPTION);
				// encode the string so that we don't have to worry about parsing errors
				OutURL $= "?ServerDescription=" $ BlobToString(Description);
				break;

			// skip this property because we assemble the mask on the server side based on the mutator class names
			case PROPERTY_EPICMUTATORS:
			// skip this property because we assemble the list of friendly names based on the active mutators
			case PROPERTY_CUSTOMMUTATORS:
				break;

			default:
				OutURL $= "?" $ PropertyName $ "=" $ GetPropertyAsString(Properties[SettingIdx].PropertyId);
				break;
			}
		}
	}
}

/**
 * Updates the game settings object from parameters passed on the URL
 *
 * @param URL the URL to parse for settings
 */
function UpdateFromURL(const out string URL, GameInfo Game)
{
	local string Description;
	local string RealDescription;
	local string BotSkillString, BotCountString;

	Super.UpdateFromURL(URL, Game);

	// Put back the question marks in the server description
	Description = GetPropertyAsString(PROPERTY_SERVERDESCRIPTION);

	// Make sure that we don't exceed our max allowing player counts for this game type!  Usually this is 32.
	NumPublicConnections = Clamp( NumPublicConnections, 0, Game.MaxPlayers );
	NumPrivateConnections = Clamp( NumPrivateConnections, 0, Game.MaxPlayers - NumPublicConnections );

	// Unblob the string
	if(StringToBlob(Description, RealDescription))
	{
		SetStringProperty(PROPERTY_SERVERDESCRIPTION, RealDescription);
	}

	SetMutators(URL);

	BotSkillString = class'GameInfo'.static.ParseOption(URL, "Difficulty");
	if ( BotSkillString != "" )
	{
		SetStringSettingValueByName('BotSkill', int(BotSkillString), true);
	}

	BotCountString = class'GameInfo'.static.ParseOption(URL, "NumPlay");
	if ( BotCountString != "" )
	{
		SetIntProperty(PROPERTY_NUMBOTS, int(BotCountString) - 1);
	}

	if (Game.WorldInfo.NetMode == NM_DedicatedServer || class'GameInfo'.static.HasOption(URL, "Dedicated"))
	{
		bIsDedicated = true;
	}

	if ( bIsDedicated )
	{
		SetStringSettingValue(CONTEXT_DEDICATEDSERVER,CONTEXT_DEDICATEDSERVER_YES,true);
	}
}


function SetMutators( const out string URL )
{
	local DataStoreClient DSClient;
	local UTUIDataStore_MenuItems MenuDataStore;
	local string MutatorURLValue;
	local array<string> MutatorClassNames;

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		MenuDataStore = UTUIDataStore_MenuItems(DSClient.FindDataStore('UTMenuItems'));
		if ( MenuDataStore != None )
		{
			// get the comma-delimited string of mutator class names from the URL
			MutatorURLValue = class'GameInfo'.static.ParseOption(URL, "Mutator");
			if ( MutatorURLValue != "" )
			{
				// separate into an array of strings
				ParseStringIntoArray(MutatorURLValue, MutatorClassNames, ",", true);
			}
		}
	}

	SetOfficialMutatorBitmask(GenerateMutatorBitmaskFromURL(MenuDataStore, MutatorClassNames));

	// now do the custom mutators
	SetCustomMutators(MenuDataStore, MutatorClassNames);
}

/**
 * Generates a bitmask of active mutators which were created by epic.  The bits are derived by left-shifting by
 * the mutator's index into the UTUIDataStore_MenuItems' list of UTUIDataProvider_Mutators.
 *
 * @return	a bitmask which has bits on for any enabled official mutators.
 */
function int GenerateMutatorBitmaskFromURL( UTUIDataStore_MenuItems MenuDataStore, out array<string> MutatorClassNames )
{
	local int Idx, MutatorIdx, EnabledMutatorBitmask;
	local string GameModeString;

	// Some mutators are filtered out based on the currently selected gametype, so in order to guarantee
	// that our bitmasks always match up (i.e. between a client and server), clear the setting that mutators
	// use for filtering so that we always get the complete list.  We'll restore it once we're done.
	class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedGameMode>", GameModeString);
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", "");

	for ( Idx = 0; Idx < MutatorClassNames.Length; Idx++ )
	{
		MutatorIdx = MenuDataStore.FindValueInProviderSet('OfficialMutators', 'ClassName', MutatorClassNames[Idx]);
		if ( MutatorIdx != INDEX_NONE )
		{
			EnabledMutatorBitmask = EnabledMutatorBitmask | (1 << MutatorIdx);
			MutatorClassNames.Remove(Idx--, 1);
		}
	}

	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", GameModeString);

	return EnabledMutatorBitmask;
}

/**
 * Sets the custom mutators property with a delimited string containing the friendly names for all active custom (non-epic) mutators.
 *
 * @param	MenuDataStore		the data store which contains the UI data for all game resources (mutators, maps, gametypes, etc.)
 * @param	MutatorClassNames	the array of pathnames for all mutators currently active in the game
 */
function SetCustomMutators( UTUIDataStore_MenuItems MenuDataStore, const out array<string> MutatorClassNames )
{
	local int Idx, MutatorIdx;
	local string MutatorName, CustomMutators, CustomMutatorDelimiter;

	// just cache the delimiter so we don't have to evaluate each time
	CustomMutatorDelimiter = Chr(28);
	for ( Idx = 0; Idx < MutatorClassNames.Length; Idx++ )
	{
		// find the index of the UTUIDataProvider_Mutator with the specified classname
		MutatorIdx = MenuDataStore.FindValueInProviderSet('Mutators', 'ClassName', MutatorClassNames[Idx]);
		if ( MutatorIdx != INDEX_NONE )
		{
			// get the value of the FriendlyName property for this UTUIDataProvider_Mutator
			if ( MenuDataStore.GetValueFromProviderSet('Mutators', 'FriendlyName', MutatorIdx, MutatorName) )
			{
				// append it to the string that will be set as the value for CustomMutators
				if ( CustomMutators != "" )
				{
					CustomMutators $= CustomMutatorDelimiter;
				}

				CustomMutators $= MutatorName;
			}
		}
	}

	//@note - CustomMutators might be blank
	SetStringProperty(PROPERTY_CUSTOMMUTATORS, CustomMutators);
}

defaultproperties
{
	// Default to 32 public and no private (user sets)
	// NOTE: UI will have to enforce proper numbers on consoles
	MaxPlayers=16
	NumPublicConnections=16
	NumPrivateConnections=0

	// Contexts and their mappings
	//@note: due to the way that UTUICollectionCheckbox works, for any settings which have on/off values, the "no/off/disabled/etc." value
	// must be at index 0 [in the ValueMappings array], and the "yes/on/enabled" value must be at index 1
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_DM,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(0)=(Id=CONTEXT_GAME_MODE,Name="GameMode",ValueMappings=((Id=CONTEXT_GAME_MODE_DM),(Id=CONTEXT_GAME_MODE_TDM),(Id=CONTEXT_GAME_MODE_CTF),(Id=CONTEXT_GAME_MODE_VCTF),(Id=CONTEXT_GAME_MODE_WAR),(Id=CONTEXT_GAME_MODE_DUEL),(Id=CONTEXT_GAME_MODE_CAMPAIGN),(Id=CONTEXT_GAME_MODE_CUSTOM)))

	LocalizedSettings(1)=(Id=CONTEXT_BOTSKILL,ValueIndex=CONTEXT_BOTSKILL_EXPERIENCED,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(1)=(Id=CONTEXT_BOTSKILL,Name="BotSkill",ValueMappings=((Id=CONTEXT_BOTSKILL_NOVICE),(Id=CONTEXT_BOTSKILL_AVERAGE),(Id=CONTEXT_BOTSKILL_EXPERIENCED),(Id=CONTEXT_BOTSKILL_SKILLED),(Id=CONTEXT_BOTSKILL_ADEPT),(Id=CONTEXT_BOTSKILL_MASTERFUL),(Id=CONTEXT_BOTSKILL_INHUMAN),(Id=CONTEXT_BOTSKILL_GODLIKE)))

	LocalizedSettings(2)=(Id=CONTEXT_MAPNAME,ValueIndex=CONTEXT_MAPNAME_CUSTOM,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(2)=(Id=CONTEXT_MAPNAME,Name="MapName",ValueMappings=((Id=CONTEXT_MAPNAME_CUSTOM)))

	LocalizedSettings(3)=(Id=CONTEXT_PURESERVER,ValueIndex=CONTEXT_PURESERVER_YES,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(3)=(Id=CONTEXT_PURESERVER,Name="PureServer",ValueMappings=((Id=CONTEXT_PURESERVER_NO),(Id=CONTEXT_PURESERVER_YES)))

	LocalizedSettings(4)=(Id=CONTEXT_LOCKEDSERVER,ValueIndex=CONTEXT_LOCKEDSERVER_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(4)=(Id=CONTEXT_LOCKEDSERVER,Name="LockedServer",ValueMappings=((Id=CONTEXT_LOCKEDSERVER_NO),(Id=CONTEXT_LOCKEDSERVER_YES)))

	LocalizedSettings(5)=(Id=CONTEXT_VSBOTS,ValueIndex=CONTEXT_VSBOTS_NONE,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(5)=(Id=CONTEXT_VSBOTS,Name="VsBots",ValueMappings=((Id=CONTEXT_VSBOTS_NONE),(Id=CONTEXT_VSBOTS_1_TO_1),(Id=CONTEXT_VSBOTS_3_TO_2),(Id=CONTEXT_VSBOTS_2_TO_1)))

	LocalizedSettings(6)=(Id=CONTEXT_CAMPAIGN,ValueIndex=CONTEXT_CAMPAIGN_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(6)=(Id=CONTEXT_CAMPAIGN,Name="Campaign",ValueMappings=((Id=CONTEXT_CAMPAIGN_NO),(Id=CONTEXT_CAMPAIGN_YES)))

	LocalizedSettings(7)=(Id=CONTEXT_FORCERESPAWN,ValueIndex=CONTEXT_FORCERESPAWN_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(7)=(Id=CONTEXT_FORCERESPAWN,Name="ForceRespawn",ValueMappings=((Id=CONTEXT_FORCERESPAWN_NO),(Id=CONTEXT_FORCERESPAWN_YES)))

	LocalizedSettings(8)=(Id=CONTEXT_ALLOWKEYBOARD,ValueIndex=CONTEXT_ALLOWKEYBOARD_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(8)=(Id=CONTEXT_ALLOWKEYBOARD,Name="AllowKeyboard",ValueMappings=((Id=CONTEXT_ALLOWKEYBOARD_NO),(Id=CONTEXT_ALLOWKEYBOARD_YES)))

	LocalizedSettings(9)=(Id=CONTEXT_FULLSERVER,ValueIndex=CONTEXT_FULLSERVER_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(9)=(Id=CONTEXT_FULLSERVER,Name="IsFullServer",ValueMappings=((Id=CONTEXT_FULLSERVER_NO),(Id=CONTEXT_FULLSERVER_YES)))

	LocalizedSettings(10)=(Id=CONTEXT_EMPTYSERVER,ValueIndex=CONTEXT_EMPTYSERVER_YES,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(10)=(Id=CONTEXT_EMPTYSERVER,Name="IsEmptyServer",ValueMappings=((Id=CONTEXT_EMPTYSERVER_NO),(Id=CONTEXT_EMPTYSERVER_YES)))

	LocalizedSettings(11)=(Id=CONTEXT_DEDICATEDSERVER,ValueIndex=CONTEXT_DEDICATEDSERVER_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(11)=(Id=CONTEXT_DEDICATEDSERVER,Name="IsDedicated",ValueMappings=((Id=CONTEXT_DEDICATEDSERVER_NO),(Id=CONTEXT_DEDICATEDSERVER_YES)))

	// Properties and their mappings
	Properties(0)=(PropertyId=PROPERTY_CUSTOMMAPNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(0)=(Id=PROPERTY_CUSTOMMAPNAME,Name="CustomMapName")

	Properties(1)=(PropertyId=PROPERTY_CUSTOMGAMEMODE,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(1)=(Id=PROPERTY_CUSTOMGAMEMODE,Name="CustomGameMode")

	Properties(2)=(PropertyId=PROPERTY_GOALSCORE,Data=(Type=SDT_Int32,Value1=20),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(2)=(Id=PROPERTY_GOALSCORE,Name="GoalScore",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0), (Type=SDT_Int32, Value1=5),(Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=15),(Type=SDT_Int32, Value1=20),(Type=SDT_Int32, Value1=25),(Type=SDT_Int32, Value1=30),(Type=SDT_Int32, Value1=35),(Type=SDT_Int32, Value1=40),(Type=SDT_Int32, Value1=45),(Type=SDT_Int32, Value1=50),(Type=SDT_Int32, Value1=55),(Type=SDT_Int32, Value1=60)))

	Properties(3)=(PropertyId=PROPERTY_TIMELIMIT,Data=(Type=SDT_Int32,Value1=20),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(3)=(Id=PROPERTY_TIMELIMIT,Name="TimeLimit",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0), (Type=SDT_Int32, Value1=5),(Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=15),(Type=SDT_Int32, Value1=20),(Type=SDT_Int32, Value1=30),(Type=SDT_Int32, Value1=45),(Type=SDT_Int32, Value1=60)))

	Properties(4)=(PropertyId=PROPERTY_NUMBOTS,Data=(Type=SDT_Int32,Value1=5),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(4)=(Id=PROPERTY_NUMBOTS,Name="NumBots",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0),(Type=SDT_Int32, Value1=1),(Type=SDT_Int32, Value1=2),(Type=SDT_Int32, Value1=3),(Type=SDT_Int32, Value1=4),(Type=SDT_Int32, Value1=5),(Type=SDT_Int32, Value1=6),(Type=SDT_Int32, Value1=7),(Type=SDT_Int32, Value1=8),(Type=SDT_Int32, Value1=9),(Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=11),(Type=SDT_Int32, Value1=12),(Type=SDT_Int32, Value1=13),(Type=SDT_Int32, Value1=14),(Type=SDT_Int32, Value1=15),(Type=SDT_Int32, Value1=16)))

	Properties(5)=(PropertyId=PROPERTY_SERVERDESCRIPTION,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(5)=(Id=PROPERTY_SERVERDESCRIPTION,Name="ServerDescription",MappingType=PVMT_RawValue)

	Properties(6)=(PropertyId=PROPERTY_EPICMUTATORS,Data=(Type=SDT_Int32),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(6)=(Id=PROPERTY_EPICMUTATORS,Name="OfficialMutators",MappingType=PVMT_RawValue)

	Properties(7)=(PropertyId=PROPERTY_CUSTOMMUTATORS,Data=(Type=SDT_String),AdvertisementType=ODAT_QoS)
	PropertyMappings(7)=(Id=PROPERTY_CUSTOMMUTATORS,Name="CustomMutators")
}
