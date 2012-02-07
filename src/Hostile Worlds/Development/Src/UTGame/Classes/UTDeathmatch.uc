/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDeathmatch extends UTGame
	config(game);

function bool WantsPickups(UTBot B)
{
	return true;
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	local float ScoreDiff;

	if ( Other.PlayerReplicationInfo == None )
	{
		return 0;
	}

	// base handicap on how far pawn is behind top scorer
	GameReplicationInfo.SortPRIArray();
	ScoreDiff = GameReplicationInfo.PriArray[0].Score - Other.PlayerReplicationInfo.Score;

	if ( ScoreDiff < 3 )
	{
		// ahead or close
		return 0;
	}
	return ScoreDiff/3;
}

defaultproperties
{
	Acronym="DM"
	MapPrefixes[0]="DM"

	// Default set of options to publish to the online service
	OnlineGameSettingsClass=class'UTGame.UTGameSettingsDM'

	bScoreDeaths=true

	// Deathmatch games don't care about teams for voice chat
	bIgnoreTeamForVoiceChat=true
	
	bGivePhysicsGun=false
}
