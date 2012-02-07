/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTLavaVolume extends WaterVolume
	placeable;

defaultproperties
{
	bPainCausing=True
	DamagePerSec=20.0
	FluidFriction=8.0
	DamageType=class'UTDmgType_Lava'
	TerminalVelocity=+01500.000000
	EntrySound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue'
	ExitSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue'
}
