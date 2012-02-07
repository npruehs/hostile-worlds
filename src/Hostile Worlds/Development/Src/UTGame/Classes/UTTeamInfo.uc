/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// UTTeamInfo.
// includes list of bots on team for multiplayer games
//
//=============================================================================

class UTTeamInfo extends TeamInfo;

var int DesiredTeamSize;
var UTTeamAI AI;

var UTGameObjective HomeBase;			// key objective associated with this team
var UTCarriedObject TeamFlag;
/** only bot characters in this faction will be used */
var string Faction;

var color BaseTeamColor[4];
var localized string TeamColorNames[4];

replication
{
	if (bNetDirty)
		HomeBase, TeamFlag;
}

simulated function string GetHumanReadableName()
{
	if ( TeamName == Default.TeamName )
	{
		if ( TeamIndex < 4 )
			return TeamColorNames[TeamIndex];
		return TeamName@TeamIndex;
	}
	return TeamName;
}

simulated function color GetHUDColor()
{
	return BaseTeamColor[TeamIndex];
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	if ( !UTGame(WorldInfo.Game).bTeamScoreRounds )
		Score = 0;
}

function bool AllBotsSpawned()
{
	return false;
}

/**
 * Initializes the team index and grabs any associated BotTeamRosters
 */
function Initialize(int NewTeamIndex)
{
	TeamIndex = NewTeamIndex;
}

function bool NeedsBotMoreThan(UTTeamInfo T)
{
	return ( (DesiredTeamSize - Size) > (T.DesiredTeamSize - T.Size) );
}

function SetBotOrders(UTBot NewBot)
{
	if (AI != None)
	{
		AI.SetBotOrders(NewBot);
	}
}

function RemoveFromTeam(Controller Other)
{
	Super.RemoveFromTeam(Other);
	if (AI != None)
	{
		AI.RemoveFromTeam(Other);
	}
}

function bool BotNameTaken(string BotName)
{
	local int i;
	local UTPlayerReplicationInfo PRI;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	for (i=0;i<GRI.PRIArray.Length;i++)
	{
		PRI = UTPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]);
		if (PRI.PlayerName == BotName)
		{
			return true;
		}
	}
	return false;
}

function GetAvailableBotList(out array<int> AvailableBots, optional string FactionFilter, optional bool bMalesOnly)
{
	local int i;

	AvailableBots.length = 0;
	for (i=0;i<class'UTCharInfo'.default.Characters.length;i++)
	{
		if(	(FactionFilter == "" || class'UTCharInfo'.default.Characters[i].Faction ~= FactionFilter) &&
			!bMalesOnly &&
			!BotNameTaken(class'UTCharInfo'.default.Characters[i].CharName) )
		{
			AvailableBots[AvailableBots.Length] = i;
		}
	}
}

/** retrieves bot info, for the named bot if a valid name is specified, otherwise from a random bot */
function CharacterInfo GetBotInfo(string BotName)
{
	local int Index;
	local array<int> AvailableBots;
	local bool bMalesOnly;

	// Only allow male chars once game is in progress..
	bMalesOnly = WorldInfo.Game.IsInState('MatchInProgress');

	Index = class'UTCharInfo'.default.Characters.Find('CharName', BotName);
	if (Index == INDEX_NONE)
	{
		// First attempt to add a bot from the Faction
		if (Faction != "")
		{
			GetAvailableBotList(AvailableBots,Faction,bMalesOnly);
			if (AvailableBots.Length > 0)
			{
				Index = AvailableBots[0];
			}
		}

		// If we still haven't found a good match, take a bot from any faction
		if (Index == INDEX_None)
		{
			GetAvailableBotList(AvailableBots,,bMalesOnly);
			if (AvailableBots.Length > 0)
			{
				Index = AvailableBots[Rand(AvailableBots.Length)];
			}
		}

		// If we still haven't found a good match looking for men, take a female
		if (bMalesOnly && Index == INDEX_None)
		{
			GetAvailableBotList(AvailableBots);
			if (AvailableBots.Length > 0)
			{
				Index = AvailableBots[Rand(AvailableBots.Length)];
			}
		}

		// At this point, if we haven't found a bot, just take any bot
		if ( Index == INDEX_None )
		{
			Index = Rand(class'UTCharInfo'.default.Characters.length);
		}
	}

	return class'UTCharInfo'.default.Characters[Index];
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (AI != None)
	{
		AI.Destroy();
	}
}

defaultproperties
{
	DesiredTeamSize=8
	BaseTeamColor(0)=(r=255,g=64,b=64,a=255)
	BaseTeamColor(1)=(r=64,g=64,b=255,a=255)
	BaseTeamColor(2)=(r=65,g=255,b=64,a=255)
	BaseTeamColor(3)=(r=255,g=255,b=0,a=255)
}

