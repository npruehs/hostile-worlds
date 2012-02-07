/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_Pancake extends UTDmgType_RanOver
	abstract;


static function SmallReward(UTPlayerController Killer, int KillCount)
{
	Killer.ReceiveLocalizedMessage(class'UTVehicleKillMessage', 4);
}

defaultproperties
{
	bAlwaysGibs=true
	GibPerterbation=1.0
	bLocationalHit=false
	bArmorStops=false
}
