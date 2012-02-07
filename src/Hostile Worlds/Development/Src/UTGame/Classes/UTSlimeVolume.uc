/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTSlimeVolume extends WaterVolume
	placeable;

defaultproperties
{
	bPainCausing=True
	DamagePerSec=7.0
	FluidFriction=5.0
	DamageType=class'UTDmgType_Lava'
	TerminalVelocity=+01500.000000
	EntrySound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue'
	ExitSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue'
}
