/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** Holds the settings that are advertised for a match */
class UTGameSettingsTDM extends UTGameSettingsCommon;

defaultproperties
{
	// Set the specific game mode
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_TDM,AdvertisementType=ODAT_OnlineService)

	Properties(2)=(PropertyId=PROPERTY_GOALSCORE,Data=(Type=SDT_Int32,Value1=50),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(2)=(Id=PROPERTY_GOALSCORE,Name="GoalScore",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0), (Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=20),(Type=SDT_Int32, Value1=30),(Type=SDT_Int32, Value1=40),(Type=SDT_Int32, Value1=50),(Type=SDT_Int32, Value1=60),(Type=SDT_Int32, Value1=70),(Type=SDT_Int32, Value1=80),(Type=SDT_Int32, Value1=90),(Type=SDT_Int32, Value1=100)))
	Properties(3)=(PropertyId=PROPERTY_TIMELIMIT,Data=(Type=SDT_Int32,Value1=20),AdvertisementType=ODAT_OnlineService)
}
