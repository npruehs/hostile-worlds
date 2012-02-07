/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTRocketLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=2
	Radius=192
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=192,Brightness=2,LightColor=(R=255,G=255,B=192,A=255)),(StartTime=2.0,Radius=128,Brightness=2,LightColor=(R=255,G=255,B=192,A=255)),(StartTime=2.5,Radius=128,Brightness=0,LightColor=(R=255,G=255,B=192,A=255)))
}
