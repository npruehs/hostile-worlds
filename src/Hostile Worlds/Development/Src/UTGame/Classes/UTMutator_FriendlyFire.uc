// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_FriendlyFire extends UTMutator;

var float FriendlyFireScale;

function bool MutatorIsAllowed()
{
	return UTTeamGame(WorldInfo.Game) != None && Super.MutatorIsAllowed();
}

function InitMutator(string Options, out string ErrorMessage)
{
	UTTeamGame(WorldInfo.Game).FriendlyFireScale = FriendlyFireScale;
	super.InitMutator(Options, ErrorMessage);
}

defaultproperties
{
	FriendlyFireScale=0.5
	GroupNames[0]="FRIENDLYFIRE"
}
