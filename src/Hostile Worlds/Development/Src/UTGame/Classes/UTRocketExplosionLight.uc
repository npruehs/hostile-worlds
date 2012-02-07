/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTRocketExplosionLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=256
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=256,Brightness=16,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=0.3,Radius=128,Brightness=8,LightColor=(R=255,G=255,B=128,A=255)),(StartTime=0.4,Radius=128,Brightness=0,LightColor=(R=255,G=255,B=64,A=255)))
}
