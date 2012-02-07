/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the search items common to all game types.
 */
class UTGameSearchCommon extends OnlineGameSearch
	abstract;

`include(UTOnlineConstants.uci)

defaultproperties
{
	// Which server side query to execute
	Query=(ValueIndex=QUERY_DM)

	MaxSearchResults=1000

	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_DM,AdvertisementType=ODAT_OnlineService)

	LocalizedSettings(1)=(Id=CONTEXT_PURESERVER,ValueIndex=CONTEXT_PURESERVER_ANY,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(1)=(Id=CONTEXT_PURESERVER,Name="PureServer",ValueMappings=((Id=CONTEXT_PURESERVER_NO),(Id=CONTEXT_PURESERVER_YES),(Id=CONTEXT_PURESERVER_ANY,bIsWildcard=true)))

	LocalizedSettings(2)=(Id=CONTEXT_LOCKEDSERVER,ValueIndex=CONTEXT_LOCKEDSERVER_YES,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(2)=(Id=CONTEXT_LOCKEDSERVER,Name="LockedServer",ValueMappings=((Id=CONTEXT_LOCKEDSERVER_NO),(Id=CONTEXT_LOCKEDSERVER_YES,bIsWildcard=true)))

	LocalizedSettings(3)=(Id=CONTEXT_CAMPAIGN,ValueIndex=CONTEXT_CAMPAIGN_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(3)=(Id=CONTEXT_CAMPAIGN,Name="Campaign",ValueMappings=((Id=CONTEXT_CAMPAIGN_NO),(Id=CONTEXT_CAMPAIGN_YES)))

	LocalizedSettings(4)=(Id=CONTEXT_ALLOWKEYBOARD,ValueIndex=CONTEXT_ALLOWKEYBOARD_ANY,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(4)=(Id=CONTEXT_ALLOWKEYBOARD,Name="AllowKeyboard",ValueMappings=((Id=CONTEXT_ALLOWKEYBOARD_NO),(Id=CONTEXT_ALLOWKEYBOARD_YES),(Id=CONTEXT_ALLOWKEYBOARD_ANY,bIsWildcard=true)))

	LocalizedSettings(5)=(Id=CONTEXT_FULLSERVER,ValueIndex=CONTEXT_FULLSERVER_YES,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(5)=(Id=CONTEXT_FULLSERVER,Name="ShowFullServers",ValueMappings=((Id=CONTEXT_FULLSERVER_NO),(Id=CONTEXT_FULLSERVER_YES,bIsWildcard=true)))

	LocalizedSettings(6)=(Id=CONTEXT_EMPTYSERVER,ValueIndex=CONTEXT_EMPTYSERVER_YES,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(6)=(Id=CONTEXT_EMPTYSERVER,Name="ShowEmptyServers",ValueMappings=((Id=CONTEXT_EMPTYSERVER_NO),(Id=CONTEXT_EMPTYSERVER_YES,bIsWildcard=true)))

	LocalizedSettings(7)=(Id=CONTEXT_DEDICATEDSERVER,ValueIndex=CONTEXT_DEDICATEDSERVER_NO,AdvertisementType=ODAT_OnlineService)
	LocalizedSettingsMappings(7)=(Id=CONTEXT_DEDICATEDSERVER,Name="IsDedicated",ValueMappings=((Id=CONTEXT_DEDICATEDSERVER_NO,bIsWildcard=true),(Id=CONTEXT_DEDICATEDSERVER_YES)))

	// Specifies the filter to use for online services that don't have predefined queries
	FilterQuery={
	(OrClauses=((OrParams=((EntryId=CONTEXT_GAME_MODE,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_PURESERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_LOCKEDSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_ALLOWKEYBOARD,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_FULLSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_EMPTYSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_DEDICATEDSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals)))
	))}
}
