/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
// DMRoster
// Holds list of pawns to use in this DM battle

class UTDMRoster extends UTTeamInfo;

var int Position;
var class<UTSquadAI> DMSquadClass;    // squad class to use for bots in DM games (no team)

function bool AddToTeam(Controller Other)
{
	local UTSquadAI DMSquad;

	if ( UTBot(Other) != None )
	{
		DMSquad = spawn(DMSquadClass);
		DMSquad.AddBot(UTBot(Other));
	}
	Other.PlayerReplicationInfo.Team = None;
	return true;
}

defaultproperties
{
    DMSquadClass=class'UTGame.UTDMSquad'
	TeamIndex=255
}
