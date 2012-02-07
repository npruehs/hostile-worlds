// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_Slomo extends UTMutator;

/** Game speed modifier. */
var()	float	GameSpeed;

function InitMutator(string Options, out string ErrorMessage)
{
	WorldInfo.Game.SetGameSpeed(GameSpeed);
	Super.InitMutator(Options, ErrorMessage);
}

defaultproperties
{
	GroupNames[0]="GAMESPEED"
	GameSpeed=0.8
}
