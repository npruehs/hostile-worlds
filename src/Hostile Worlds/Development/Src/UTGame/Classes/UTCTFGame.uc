/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFGame extends UTTeamGame
	abstract;

var UTCTFFlag Flags[2];

var class<UTLocalMessage> AnnouncerMessageClass;

function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	for ( i=0; i<2; i++ )
	{
		Flags[i].Team = Teams[i];
		Teams[i].HomeBase = UTGameObjective(Flags[i].HomeBase);
		Teams[i].TeamFlag = Flags[i];
		UTCTFTeamAI(Teams[i].AI).FriendlyFlag = Flags[i];
		UTCTFTeamAI(Teams[i].AI).EnemyFlag = Flags[1-i];
	}
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;

	if ( Winner != None )
	{
		if (Winner.Team.TeamIndex == 0)
		{
			EndGameFocus = Flags[0].HomeBase;
		}
		else
		{
			EndGameFocus = Flags[1].HomeBase;
		}
	}

	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded( EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	if ( (Other.PlayerReplicationInfo == None) || (Other.PlayerReplicationInfo.Team == None) )
	{
		return 0;
	}

	// base handicap on how far team is behind in powercore health
	return Teams[1 - Other.PlayerReplicationInfo.Team.TeamIndex].Score - Other.PlayerReplicationInfo.Team.Score;
}

/**
 * Returns through outparameters what location message to play
 * Returns true if it returned message information
 */
function bool GetLocationFor(Pawn StatusPawn, out Actor LocationObject, out int MessageIndex, int LocationSpeechOffset)
{
	local UTPickupFactory F;
	local UDKGameObjective Best;
	local UTBot B;

	// see if it's a bot heading for an objective or a power up
	B = UTBot(StatusPawn.Controller);
	if ( B != None )
	{
		F = UTPickupFactory(StatusPawn.Controller.RouteGoal);
		if ( (F != None) && F.bHasLocationSpeech )
		{
			MessageIndex = 0;
			LocationObject = F;
			return true;
		}
	}

	if ( (Flags[0].HomeBase != None) && (Flags[1].HomeBase != None) )
	{
		Best = (VSizeSq(StatusPawn.Location - Flags[0].HomeBase.Location) < VSizeSq(StatusPawn.Location - Flags[1].HomeBase.Location))
				? Flags[0].HomeBase
				: Flags[1].HomeBase;

		MessageIndex = UTGameObjective(Best).GetLocationMessageIndex(B, StatusPawn);
		LocationObject = Best;
		return true;
	}

	MessageIndex = 10;
	return true;
}

function RegisterFlag(UTCTFFlag F, int TeamIndex)
{
	Flags[TeamIndex] = F;
}

function bool NearGoal(Controller C)
{
	local UTGameObjective B;

	B = UTTeamInfo(C.PlayerReplicationInfo.Team).HomeBase;
	return ( UTCTFBase(B).myFlag.bHome && (VSize(C.Pawn.Location - B.Location) < 1000) );
}

function bool WantFastSpawnFor(AIController B)
{
	if ( NumBots < 6 )
		return true;
	if ( NumBots > 16 )
		return false;

	return !UTCTFSquadAI(UTBot(B).Squad).FriendlyFlag.bHome;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local UTCTFFlag BestFlag;
	local Controller P;
    local bool bLastMan;

	if ( bOverTime )
	{
		if ( Numbots + NumPlayers == 0 )
			return true;
		bLastMan = true;
		foreach WorldInfo.AllControllers(class'Controller', P)
		{
			if ( (P.PlayerReplicationInfo != None) && !P.PlayerReplicationInfo.bOutOfLives )
			{
				bLastMan = false;
				break;
			}
		}
		if ( bLastMan )
			return true;
	}

    bLastMan = ( Reason ~= "LastMan" );

	if ( CheckModifiedEndGame(Winner, Reason) )
		return false;

	if ( bLastMan )
	{
		GameReplicationInfo.Winner = Winner.Team;
	}
	else
	{
		if ( Teams[1].Score == Teams[0].Score )
		{
			// Don't allow overtime with automated perf testing.
			if( IsAutomatedPerfTesting() )
			{
				GameReplicationInfo.Winner = Teams[0];
			}
			else
			{
				if ( !bOverTimeBroadcast )
				{
					StartupStage = 7;
					PlayStartupMessage();
					bOverTimeBroadcast = true;
				}
				return false;
			}
		}
		else if ( Teams[1].Score > Teams[0].Score )
		{
			GameReplicationInfo.Winner = Teams[1];
		}
		else
		{
			GameReplicationInfo.Winner = Teams[0];
		}
	}

	BestFlag = UTCTFTeamAI(UTTeamInfo(GameReplicationInfo.Winner).AI).FriendlyFlag;

	if ( Winner != None )
	{
		EndGameFocus = Controller(Winner.Owner).Pawn;
	}

	if ( EndGameFocus == None )
	{
		EndGameFocus = BestFlag.HomeBase;
	}

	EndTime = WorldInfo.RealTimeSeconds + EndTimeDelay;
	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded( EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
	BestFlag.HomeBase.SetHidden(False);
	return true;
}

function ScoreFlag(Controller Scorer, UTCTFFlag theFlag)
{
	local float Dist,oppDist;
	local int i, GoalsScored;
	local float ppp,numtouch;
	local vector FlagLoc;
	local UTPlayerReplicationInfo ScorerPRI;
	local UTPlayerController PC;

	ScorerPRI = UTPlayerReplicationInfo(Scorer.PlayerReplicationInfo);
	if ( ScorerPRI.Team == theFlag.Team )
	{
		FlagLoc = TheFlag.Position().Location;
		Dist = vsize(FlagLoc - TheFlag.HomeBase.Location);
		oppDist = vsize(FlagLoc - Teams[1-TheFlag.Team.TeamIndex].HomeBase.Location);

		BroadcastLocalizedMessage( AnnouncerMessageClass, 1+7*TheFlag.Team.TeamIndex, ScorerPRI, None, TheFlag.Team );
		ScorerPRI.IncrementEventStat('EVENT_RETURNEDFLAG');
		if (Dist>1024)
		{
			// figure out who's closer
			if (Dist<=oppDist)	// In your team's zone
			{
				ScorerPRI.Score += 3;
			}
			else
			{
				ScorerPRI.Score += 5;

				if (oppDist<=1024)	// Denial
				{
  					ScorerPRI.Score += 7;
				}

			}
		}
		return;
	}

	// Figure out Team based scoring.
	if (TheFlag.FirstTouch!=None)	// Original Player to Touch it gets 5
	{
		TheFlag.FirstTouch.PlayerReplicationInfo.Score += 5;
		TheFlag.FirstTouch.PlayerReplicationInfo.bForceNetUpdate = TRUE;
	}

	// Guy who caps gets 5
	ScorerPRI.bForceNetUpdate = TRUE;
	ScorerPRI.Score += 5;
	GoalsScored = ScorerPRI.IncrementEventStat('EVENT_SCOREDFLAG');
	PC = UTPlayerController(Scorer);
	if ( GoalsScored == 3 )
	{
		ScorerPRI.IncrementEventStat('EVENT_HATTRICK');
		if ( PC != None )
		{
			PC.ReceiveLocalizedMessage(TeamScoreMessageClass, 6, ScorerPRI);
		}
	}
	else
	{
		if ( PC != None )
		{
			PC.ReceiveLocalizedMessage(TeamScoreMessageClass, 7, ScorerPRI);
		}
	}

	// Each player gets 20/x but it's guaranteed to be at least 1 point but no more than 5 points
	if ( TheFlag.Assists.Length > 0 )
	{
		numtouch=0;
		for (i=0;i<TheFlag.Assists.length;i++)
		{
			if (TheFlag.Assists[i]!=None)
				numtouch = numtouch + 1.0;
		}

		if ( numtouch > 0 )
		{
			ppp = FClamp(20/numtouch,1,5);

			for (i=0;i<TheFlag.Assists.length;i++)
			{
				if (TheFlag.Assists[i]!=None)
				{
					TheFlag.Assists[i].PlayerReplicationInfo.Score += int(ppp);
				}
			}
		}
	}

	// Apply the team score
	ScorerPRI.Team.Score += 1.0;
	ScorerPRI.Team.bForceNetUpdate = TRUE;

	CheckScore(ScorerPRI);

    if ( bOverTime )
    {
		EndGame(ScorerPRI,"timelimit");
    }
	else if ( UTGameReplicationInfo(GameReplicationInfo).bStoryMode )
	{
		if ( ScorerPRI.Team.TeamIndex == 0 )
		{
			// player team scored - increase bot skill
			AdjustedDifficulty = FMin(7.0,AdjustedDifficulty + 0.5);
		}
		else
		{
			 // bot team scored - decrease bot skill
			AdjustedDifficulty = FMax(0, AdjustedDifficulty - 0.5);
		}
		AdjustedDifficulty = FClamp(AdjustedDifficulty, GameDifficulty - 1.25, GameDifficulty + 1.25);
	}
	AnnounceScore(ScorerPRI.Team.TeamIndex);

}

State MatchOver
{
	function AnnounceScore(int ScoringTeam)
	{
	}

	function ScoreFlag(Controller Scorer, UTCTFFlag theFlag)
	{
	}
}

function ViewObjective(PlayerController PC)
{
	local actor a;
	if (PC.ViewTarget != none &&
	      (PC.ViewTarget == Flags[0] || (PC.ViewTarget == Flags[0].Holder) || PC.VIewTarget == Flags[0].HomeBase) )
	{
		a = Flags[1].HomeBase.GetBestViewTarget();
		PC.SetViewTarget( a );
		if ( UTPlayerController(PC) != None )
		{
			UTPlayerController(PC).ClientSetBehindView(true);
		}
	}
	else
	{
		a = Flags[0].HomeBase.GetBestViewTarget();
		PC.SetViewTarget( a );
		if ( UTPlayerController(PC) != None )
		{
			UTPlayerController(PC).ClientSetBehindView(true);
		}
	}
}

function Actor GetAutoObjectiveFor(UTPlayerController PC)
{
	if (UTTeamInfo(PC.PlayerReplicationInfo.Team) != None)
	{
		if ( UTPlayerReplicationInfo(PC.PlayerReplicationInfo).bHasFlag )
		{
			return UTTeamInfo(PC.PlayerReplicationInfo.Team).HomeBase;
		}
		else
		{
			return Teams[1 - PC.PlayerReplicationInfo.Team.TeamIndex].HomeBase;
		}
	}
	else
	{
		return None;
	}
}

defaultproperties
{
	bUndrivenVehicleDamage=true
	bSpawnInTeamArea=true
	bScoreTeamKills=False
	MapPrefixes[0]="CTF"
	Acronym="CTF"
	TeamAIType(0)=class'UTGame.UTCTFTeamAI'
	TeamAIType(1)=class'UTGame.UTCTFTeamAI'
	bScoreVictimsTarget=true
	DeathMessageClass=class'UTTeamDeathMessage'
	FlagKillMessageName=FLAGKILL

	OnlineGameSettingsClass=class'UTGameSettingsCTF'

	bScoreDeaths=false
	MidgameScorePanelTag=CTFPanel

}

