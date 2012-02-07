/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTLeviathanMuzzleFlashLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=512
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=256,Brightness=8,LightColor=(R=255,G=192,B=128,A=255)),(StartTime=2.8,Radius=256,Brightness=24,LightColor=(R=255,G=192,B=128,A=255)),(StartTime=2.9,Radius=512,Brightness=16,LightColor=(R=255,G=228,B=192,A=255)),(StartTime=3.3,Radius=256,Brightness=4,LightColor=(R=255,G=192,B=128,A=255)))
}
