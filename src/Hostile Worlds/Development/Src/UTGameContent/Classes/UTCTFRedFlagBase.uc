/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFRedFlagBase extends UTCTFBase_Content
	placeable;

defaultproperties
{
	FlagType=class'UTGameContent.UTCTFRedFlag'
    DefenderTeamIndex=0

	Begin Object Class=ParticleSystemComponent Name=EmptyParticles
		Template=ParticleSystem'Pickups.flag.effects.P_Flagbase_Empty_Idle_Red'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	End Object
	FlagEmptyParticles=EmptyParticles
	Components.Add(EmptyParticles)

	FlagBaseMaterial=MaterialInstanceConstant'Pickups.Base_Flag.Materials.M_Pickups_Base_Flag_Red'

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_InTheRedBase'
	NearLocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_NearTheRedBase'
	MidfieldHighSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_MidfieldHigh'
	MidfieldLowSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_MidfieldLow'
}
