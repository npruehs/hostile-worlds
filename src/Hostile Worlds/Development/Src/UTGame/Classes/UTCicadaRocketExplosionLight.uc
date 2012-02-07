/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTCicadaRocketExplosionLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.01
	Brightness=8
	Radius=192
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=192,Brightness=8,LightColor=(R=255,G=255,B=255,A=255)),(StartTime=0.3,Radius=128,Brightness=8,LightColor=(R=255,G=255,B=128,A=255)))
}
