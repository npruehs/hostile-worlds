/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_Telefrag extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_TRANSLOCATOR
	DeathStatsName=DEATHS_TRANSLOCATOR
	SuicideStatsName=SUICIDES_TRANSLOCATOR
	bAlwaysGibs=true
	GibPerterbation=1.0
	bLocationalHit=false
}

