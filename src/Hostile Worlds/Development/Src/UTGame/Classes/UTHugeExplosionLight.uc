/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTHugeExplosionLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=1024
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=512,Brightness=16,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=0.8,Radius=1024,Brightness=16,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=0.9,Radius=2048,Brightness=32,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=1.3,Radius=2048,Brightness=32,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=1.8,Radius=1024,Brightness=16,LightColor=(R=255,G=255,B=220,A=255)),(StartTime=2.0,Radius=1024,Brightness=8,LightColor=(R=255,G=255,B=255,A=255))),(StartTime=4.5,Radius=768,Brightness=8,LightColor=(R=255,G=255,B=128,A=255))))
}
