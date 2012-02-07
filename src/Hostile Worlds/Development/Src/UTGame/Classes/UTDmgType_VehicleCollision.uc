/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTDmgType_VehicleCollision extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=EVENT_RANOVERKILLS
	DeathStatsName=EVENT_RANOVERDEATHS
	SuicideStatsName=SUICIDES_ENVIRONMENT
	KDamageImpulse=0
	DamageOverlayTime=0.0
	bLocationalHit=false
	bArmorStops=false
}
