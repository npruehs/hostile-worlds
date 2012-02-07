/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSayMsg extends UTLocalMessage;

var color RedTeamColor,BlueTeamColor;

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
	if ( (RelatedPRI_1 == None) || (RelatedPRI_1.Team == None) )
		return Default.DrawColor;

	if ( RelatedPRI_1.Team.TeamIndex == 0 )
		return Default.RedTeamColor;
	else
		return Default.BlueTeamColor;
}

defaultproperties
{
	bBeep=true
	DrawColor=(R=255,G=255,B=0,A=255)
	RedTeamColor=(R=255,G=64,B=64,A=255)
	BlueTeamColor=(R=64,G=192,B=255,A=255)
	LifeTime=6
}
