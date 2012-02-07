/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTShockImpactLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=200
	Radius=128
	LightColor=(R=255,G=192,B=64,A=255)

	TimeShift=((StartTime=0.0,Radius=64,Brightness=150,LightColor=(R=255,G=192,B=255,A=255)),(StartTime=0.15,Radius=48,Brightness=50,LightColor=(R=192,G=64,B=255,A=255)),(StartTime=0.2,Radius=48,Brightness=0,LightColor=(R=192,G=64,B=255,A=255)))
}
