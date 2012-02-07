/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTShockMuzzleFlashLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=128
	LightColor=(R=255,G=255,B=255,A=255)
	TimeShift=((StartTime=0.0,Radius=128,Brightness=8,LightColor=(R=176,G=165,B=239,A=255)),(StartTime=0.2,Radius=64,Brightness=8,LightColor=(R=176,G=92,B=239,A=255)),(StartTime=0.25,Radius=64,Brightness=0,LightColor=(R=176,G=0,B=239,A=255)))
}
