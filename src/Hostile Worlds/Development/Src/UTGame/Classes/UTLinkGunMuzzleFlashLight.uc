/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTLinkGunMuzzleFlashLight extends UDKExplosionLight;

var array<LightValues> RedTeamTimeShift, BlueTeamTimeShift;

function SetTeam(byte NewTeam)
{
	switch (NewTeam)
	{
		case 0:
			TimeShift = RedTeamTimeShift;
			break;
		case 1:
			TimeShift = BlueTeamTimeShift;
			break;
		default:
			TimeShift = default.TimeShift;
			break;
	}
}

defaultproperties
{
	HighDetailFrameTime=+0.02
	Brightness=8
	Radius=96
	LightColor=(R=255,G=255,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=96,Brightness=5,LightColor=(R=184,G=255,B=232,A=255)),(StartTime=0.1,Radius=64,Brightness=5,LightColor=(R=0,G=128,B=0,A=255)),(StartTime=0.15,Radius=64,Brightness=0,LightColor=(R=0,G=64,B=0,A=255)))
	RedTeamTimeShift=((StartTime=0.0,Radius=96,Brightness=5,LightColor=(R=255,G=192,B=192,A=255)),(StartTime=0.1,Radius=64,Brightness=5,LightColor=(R=128,G=0,B=0,A=255)),(StartTime=0.15,Radius=64,Brightness=0,LightColor=(R=64,G=0,B=0,A=255)))
	BlueTeamTimeShift=((StartTime=0.0,Radius=96,Brightness=5,LightColor=(R=192,G=192,B=255,A=255)),(StartTime=0.1,Radius=64,Brightness=5,LightColor=(R=0,G=0,B=128,A=255)),(StartTime=0.15,Radius=64,Brightness=0,LightColor=(R=0,G=0,B=64,A=255)))
}
