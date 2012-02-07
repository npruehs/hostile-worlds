/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTDmgType_VehicleExplosion extends UTDmgType_Burning
	abstract;

defaultproperties
{
    KillStatsName=KILLS_VEHICLEEXPLOSION
	DeathStatsName=DEATHS_VEHICLEEXPLOSION
	SuicideStatsName=SUICIDES_VEHICLEEXPLOSION
	GibPerterbation=0.15
	bThrowRagdoll=true
	KDamageImpulse=1000.0
}
