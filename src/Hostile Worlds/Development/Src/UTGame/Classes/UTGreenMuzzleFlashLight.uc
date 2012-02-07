/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTGreenMuzzleFlashLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=96
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=96,Brightness=8,LightColor=(R=232,G=255,B=184,A=255)),(StartTime=0.1,Radius=64,Brightness=8,LightColor=(R=116,G=255,B=92,A=255)),(StartTime=0.15,Radius=64,Brightness=0,LightColor=(R=0,G=128,B=0,A=255)))
}
