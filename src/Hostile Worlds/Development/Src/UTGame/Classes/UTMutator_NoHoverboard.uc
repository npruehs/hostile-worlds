// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_NoHoverboard extends UTMutator;

function InitMutator(string Options, out string ErrorMessage)
{
	if ( UTGame(WorldInfo.Game) != None )
	{
		UTGame(WorldInfo.Game).bAllowHoverboard = false;
	}
	Super.InitMutator(Options, ErrorMessage);
}

defaultproperties
{
	GroupNames[0]="HOVERBOARD"
}
