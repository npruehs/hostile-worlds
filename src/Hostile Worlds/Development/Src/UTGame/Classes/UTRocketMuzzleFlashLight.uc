/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTRocketMuzzleFlashLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=192
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=160,Brightness=8,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=0.2,Radius=96,Brightness=5,LightColor=(R=255,G=255,B=128,A=255)),(StartTime=0.25,Radius=96,Brightness=0,LightColor=(R=255,G=255,B=64,A=255)))
}
