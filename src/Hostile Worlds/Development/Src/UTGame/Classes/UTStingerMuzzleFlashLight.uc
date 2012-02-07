/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTStingerMuzzleFlashLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=96
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=128,Brightness=8,LightColor=(R=128,G=200,B=255,A=255)),(StartTime=0.1,Radius=64,Brightness=8,LightColor=(R=64,G=150,B=200,A=255)),(StartTime=0.15,Radius=64,Brightness=0,LightColor=(R=32,G=100,B=128,A=255)))
}
