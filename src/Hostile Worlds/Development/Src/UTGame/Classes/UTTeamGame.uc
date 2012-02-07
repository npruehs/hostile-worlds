/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTTeamGame extends UTDeathmatch;

var globalconfig	bool		bPlayersBalanceTeams;	// players balance teams
var config			bool		bAllowNonTeamChat;
var 				bool		bScoreTeamKills;
var 				bool		bSpawnInTeamArea;		// players spawn in marked team playerstarts
var					bool		bScoreVictimsTarget;	// Should we check a victims target for bonuses
var					bool		bForceAllRed;			// for AI testing

var					float		FriendlyFireScale;		//scale friendly fire damage by this value
var					float		TeammateBoost;
var					UTTeamInfo	Teams[2];
var					class<UTTeamAI> TeamAIType[2];
var					string		TeamFactions[2];

var class<LocalMessage>	TeamScoreMessageClass;

/** If a player requests a team change, but team balancing prevents it, we allow a swap within a few seconds */
var	PlayerController	PendingTeamSwap;
var	float				SwapRequestTime;

var name FlagKillMessageName;


function PreBeginPlay()
{
	Super.PreBeginPlay();

	CreateTeam(0);
	CreateTeam(1);
	Teams[0].AI.EnemyTeam = Teams[1];
	Teams[1].AI.EnemyTeam = Teams[0];
}

event PostLogin ( playerController NewPlayer )
{
	local Actor A;

	Super.PostLogin(NewPlayer);

	if ( LocalPlayer(NewPlayer.Player) == None )
		return;

	// if local player, notify level actors
	ForEach AllActors(class'Actor', A)
		A.NotifyLocalPlayerTeamReceived();
}

function FindNewObjectives( UTGameObjective DisabledObjective )
{
	// have team AI retask bots
	Teams[0].AI.FindNewObjectives(DisabledObjective);
	Teams[1].AI.FindNewObjectives(DisabledObjective);
}

/* create a player team, and fill from the team roster
*/
function CreateTeam(int TeamIndex)
{
	Teams[TeamIndex] = spawn(class'UTGame.UTTeamInfo');
	Teams[TeamIndex].Faction = TeamFactions[TeamIndex];
	Teams[TeamIndex].Initialize(TeamIndex);
	Teams[TeamIndex].AI = Spawn(TeamAIType[TeamIndex]);
	Teams[TeamIndex].AI.Team = Teams[TeamIndex];
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
	Teams[TeamIndex].AI.SetObjectiveLists();
}

exec function AddRedBots(int Num)
{
	// Disable auto balancing of bot teams.
	bCustomBots=true;

	DesiredPlayerCount = Clamp(DesiredPlayerCount+Num, 1, 32);
	while ( (NumPlayers + NumBots < DesiredPlayerCount) && AddBot(,true,0) != none )
	{
		`log("added red bot");
	}
}

exec function AddBlueBots(int Num)
{
	// Disable auto balancing of bot teams.
	bCustomBots=true;

	DesiredPlayerCount = Clamp(DesiredPlayerCount+Num, 1, 32);
	while ( (NumPlayers + NumBots < DesiredPlayerCount) && AddBot(,true,1) != none )
	{
		`log("added blue bot");
	}
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	local int ScoreDiff;

	if ( (Other.PlayerReplicationInfo == None) || (Other.PlayerReplicationInfo.Team == None) )
	{
		return 0;
	}

	// base handicap on how far team is behind
	ScoreDiff = Teams[1 - Other.PlayerReplicationInfo.Team.TeamIndex].Score - Other.PlayerReplicationInfo.Team.Score;
	if ( ScoreDiff < 5 )
	{
		// team is ahead or close
		return 0;
	}
	return ScoreDiff/5;
}

function UTTeamInfo GetBotTeam(optional int TeamBots,optional bool bUseTeamIndex, optional int TeamIndex)
{
	local int first, second;
	local PlayerController PC;

	if( bUseTeamIndex )
	{
		return Teams[TeamIndex];
	}

	if ( bForceAllRed )
	{
		return Teams[0];
	}

	if ( bPlayersVsBots && (WorldInfo.NetMode != NM_Standalone) )
	{
		return Teams[1];
	}

	if ( WorldInfo.NetMode == NM_Standalone )
	{
		if ( Teams[0].AllBotsSpawned() )
	    {
		    if ( !Teams[1].AllBotsSpawned() )
			{
			    return Teams[1];
			}
	    }
	    else if ( Teams[1].AllBotsSpawned() )
	    {
		    return Teams[0];
		}
	}

	second = 1;
	// always imbalance teams in favor of bot team in single player
	if (  WorldInfo.NetMode == NM_Standalone )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( (PC.PlayerReplicationInfo.Team != None) && (PC.PlayerReplicationInfo.Team.TeamIndex == 1) )
			{
				first = 1;
				second = 0;
			}
			break;
		}
	}
	if ( Teams[first].Size < Teams[second].Size )
	{
		return Teams[first];
	}
	else
	{
		return Teams[second];
	}
}

function int LevelRecommendedPlayers()
{
	local UTMapInfo MapInfo;
	local int Num;

	MapInfo = UTMapInfo(WorldInfo.GetMapInfo());
	if (MapInfo != None)
	{
		Num = Min(16, (MapInfo.RecommendedPlayersMax + MapInfo.RecommendedPlayersMin) / 2);
		if (Num % 2 != 0)
		{
			Num++;
		}
	}
	else
	{
		Num = 1;
	}
	return Num;
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if ( MaxLives > 0 )
    {
		if ( (Scorer != None) && !Scorer.bOutOfLives )
			Living = Scorer;
	bNoneLeft = true;
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
	    if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer
		&& !C.PlayerReplicationInfo.bOutOfLives
		&& !C.PlayerReplicationInfo.bOnlySpectator )
	    {
		if ( Living == None )
		{
			Living = C.PlayerReplicationInfo;
		}
		else if ( (C.PlayerReplicationInfo != Living) && (C.PlayerReplicationInfo.Team != Living.Team) )
		{
    	        	bNoneLeft = false;
	            	break;
		}
	    }
	}
	if ( bNoneLeft )
	{
			if ( Living != None )
				EndGame(Living,"LastMan");
			else
				EndGame(Scorer,"LastMan");
			return true;
		}
    }
    return false;
}

// Parse options for this game...
event InitGame( string Options, out string ErrorMessage )
{
	local string InOpt;
	local class<UTTeamAI> InType;
	//local string RedSymbolName,BlueSymbolName;
	//local texture NewSymbol;

	Super.InitGame(Options, ErrorMessage);
	InOpt = ParseOption( Options, "RedAI");
	if ( InOpt != "" )
	{
		InType = class<UTTeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[0] = InType;
	}

	InOpt = ParseOption( Options, "BlueAI");
	if ( InOpt != "" )
	{
		InType = class<UTTeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[1] = InType;
	}

	InOpt = ParseOption( Options, "AllRed");
	if ( InOpt != "" )
	{
		bForceAllRed = true;
	}

	InOpt = ParseOption(Options, "BalanceTeams");
	if ( InOpt != "" )
	{
		bPlayersBalanceTeams = bool(InOpt);
	}

	TeamFactions[0] = ParseOption(Options, "RedFaction");
	TeamFactions[1] = ParseOption(Options, "BlueFaction");
}

function bool TooManyBots(Controller botToRemove)
{
	local TeamInfo BotTeam, OtherTeam;

	if ( bForceAllRed )
		return false;
	if ( (!bPlayersVsBots || (WorldInfo.NetMode == NM_Standalone)) && (UTBot(botToRemove) != None) &&
		(!bCustomBots || (WorldInfo.NetMode != NM_Standalone)) && botToRemove.PlayerReplicationInfo.Team != None )
	{
		BotTeam = botToRemove.PlayerReplicationInfo.Team;
		OtherTeam = Teams[1-BotTeam.TeamIndex];
		if ( OtherTeam.Size < BotTeam.Size - 1 )
		{
			return true;
		}
		else if ( OtherTeam.Size > BotTeam.Size )
		{
			return false;
		}
	}
	if ( (WorldInfo.NetMode != NM_Standalone) && bPlayersVsBots )
		return ( NumBots > Min(16,BotRatio*NumPlayers) );
	if ( bPlayerBecameActive )
	{
		bPlayerBecameActive = false;
		return true;
	}
	return ( NumBots + NumPlayers > DesiredPlayerCount );
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType)
{
	Teams[0].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn,damageType);
	Teams[1].AI.NotifyKilled(Killer,KilledPlayer,KilledPawn,damageType);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
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
	if ( !bLastMan && CheckModifiedEndGame(Winner, Reason) )
		return false;

	if ( bTeamScoreRounds )
	{
		if ( Winner != None )
		{
			Winner.Team.Score += 1;
			Winner.Team.bForceNetUpdate = TRUE;
		}
	}
	else if ( !bLastMan && (Teams[1].Score == Teams[0].Score) )
	{
		// tie
		if ( !bOverTimeBroadcast )
		{
			StartupStage = 7;
			PlayStartupMessage();
			bOverTimeBroadcast = true;
		}
		return false;
	}
	if ( bLastMan )
		GameReplicationInfo.Winner = Winner.Team;
	else if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else
		GameReplicationInfo.Winner = Teams[0];

	if ( Winner == None )
	{
		foreach WorldInfo.AllControllers(class'Controller', P)
		{
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
		}
	}

	EndTime = WorldInfo.RealTimeSeconds + EndTimeDelay;

	SetEndGameFocus(Winner);
	return true;
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;

	if ( Winner != None )
		EndGameFocus = Controller(Winner.Owner).Pawn;
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded( EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
}

/**
 * returns true if Viewer is allowed to spectate ViewTarget
 **/
function bool CanSpectate( PlayerController Viewer, PlayerReplicationInfo ViewTarget )
{
	if ( (ViewTarget == None) || ViewTarget.bOnlySpectator )
		return false;
	return ( Viewer.PlayerReplicationInfo.bOnlySpectator || (ViewTarget.Team == Viewer.PlayerReplicationInfo.Team) );
}

/**
  * Balance teams before restarting game
  */
function RestartGame()
{
	local PlayerController PC;
	local int RedCount, BlueCount, MoveCount, i;
	local array<PlayerController> RedPlayers, BluePlayers;

	if ( !bPlayersVsBots && bPlayersBalanceTeams
			&& (WorldInfo.NetMode != NM_Standalone) )
	{
		// re-balance teams
		// first - count humans on each team
		foreach WorldInfo.AllControllers(class'PlayerController', PC)
		{
			if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
			{
				if ( PC.PlayerReplicationInfo.Team.TeamIndex == 0 )
				{
					RedCount++;
					RedPlayers[RedPlayers.Length] = PC;
				}
				else if ( PC.PlayerReplicationInfo.Team.TeamIndex == 1 )
				{
					BlueCount++;
					BluePlayers[BluePlayers.Length] = PC;
				}
			}
		}

		if ( Abs(RedCount - BlueCount) > 1 )
		{
			// need to move some players
			if ( RedCount > BlueCount )
			{
				MoveCount = (RedCount - BlueCount)/2;

				for ( i=0; i<MoveCount; i++ )
				{
					SetTeam( RedPlayers[RedPlayers.Length - i - 1], Teams[1], false);
				}
			}
			else
			{
				MoveCount = (BlueCount - RedCount)/2;
				for ( i=0; i<MoveCount; i++ )
				{
					SetTeam( BluePlayers[BluePlayers.Length - i - 1], Teams[0], false);
				}
			}
		}
	}

	super.RestartGame();
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num, Controller C)
{
	local UTTeamInfo SmallTeam, BigTeam, NewTeam;
	local Controller B;
	local int BigTeamBots, SmallTeamBots;

	if (bForceAllRed)
	{
		return 0;
	}

	if ( bPlayersVsBots && (WorldInfo.NetMode != NM_Standalone) )
	{
		if ( PlayerController(C) != None )
			return 0;
		return 1;
	}

	SmallTeam = Teams[0];
	BigTeam = Teams[1];

	if ( SmallTeam.Size > BigTeam.Size )
	{
		SmallTeam = Teams[1];
		BigTeam = Teams[0];
	}

	if ( num < 2 )
	{
		NewTeam = Teams[num];
	}

	if ( NewTeam == None )
		NewTeam = SmallTeam;
	else if ( bPlayersBalanceTeams && (WorldInfo.NetMode != NM_Standalone) && (PlayerController(C) != None) )
	{
		if ( SmallTeam.Size < BigTeam.Size )
			NewTeam = SmallTeam;
		else
		{
			// count number of bots on each team
			foreach WorldInfo.AllControllers(class'Controller', B)
			{
				if ( (B.PlayerReplicationInfo != None) && B.PlayerReplicationInfo.bBot )
				{
					if ( B.PlayerReplicationInfo.Team == BigTeam )
					{
						BigTeamBots++;
					}
					else if ( B.PlayerReplicationInfo.Team == SmallTeam )
					{
						SmallTeamBots++;
					}
				}
			}

			if ( BigTeamBots > 0 )
			{
				// balance the number of players on each team
				if ( SmallTeam.Size - SmallTeamBots < BigTeam.Size - BigTeamBots )
					NewTeam = SmallTeam;
				else if ( BigTeam.Size - BigTeamBots < SmallTeam.Size - SmallTeamBots )
					NewTeam = BigTeam;
				else if ( SmallTeamBots == 0 )
					NewTeam = BigTeam;
			}
			else if ( SmallTeamBots > 0 )
				NewTeam = SmallTeam;
			else if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.Team != None) )
			{
				// don't allow team changes if teams are even, and player is already on a team
				NewTeam = UTTeamInfo(C.PlayerReplicationInfo.Team);
			}
		}
	}

	return NewTeam.TeamIndex;
}

/** ChangeTeam()
* verify whether controller Other is allowed to change team, and if so change his team by calling SetTeam().
* @param Other:  the controller which wants to change teams
* @param num:  the teamindex of the desired team.  If 255, pick the smallest team.
* @param bNewTeam:  if true, broadcast team change notification
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local UTTeamInfo NewTeam, PendingTeam;

	// check if only allow team changes before match starts
	if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
		return false;

	// don't add spectators to teams
	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
		return true;
	}

	NewTeam = (num < 255) ? Teams[PickTeam(num,Other)] : None;

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
	{
		// may have returned current team if not allowed to switch
		// if not allowed to switch, set up or complete proposed swap
		if ( (num < 2) && (num != NewTeam.TeamIndex) && !bPlayersVsBots && (PlayerController(Other) != None)
			&& (UTTeamInfo(Other.PlayerReplicationInfo.Team) != None) )
		{
			// check if swap request is pending
			if ( PendingTeamSwap != None )
			{
				if ( PendingTeamSwap.bDeleteMe || (WorldInfo.TimeSeconds - SwapRequestTime > 8.0) )
				{
					PendingTeamSwap = None;
				}
				else if ( PendingTeamSwap.PlayerReplicationInfo.Team.TeamIndex == num )
				{
					// do the swap!
					PendingTeam = UTTeamInfo(PendingTeamSwap.PlayerReplicationInfo.Team);
					if (PendingTeam != None )
					{
						SetTeam(PendingTeamSwap, UTTeamInfo(Other.PlayerReplicationInfo.Team), true);
						if ( PendingTeamSwap.Pawn != None )
							PendingTeamSwap.Pawn.PlayerChangedTeam();
						PendingTeamSwap = None;
						SetTeam(Other, PendingTeam, bNewTeam);
						return true;
					}
				}
			}

			// set pending swap request
			PendingTeamSwap = PlayerController(Other);
			SwapRequestTime = WorldInfo.TimeSeconds;

			// broadcast swap request
			BroadcastLocalizedMessage(class'UTTeamGameMessage', 0, PendingTeamSwap.PlayerReplicationInfo);
		}
		return false;
	}

	// set the new team for Other
	SetTeam(Other, NewTeam, bNewTeam);
	return true;
}

/** SetTeam()
* Change Other's team to NewTeam.
* @param Other:  the controller which wants to change teams
* @param NewTeam:  the desired team.
* @param bNewTeam:  if true, broadcast team change notification
*/
function SetTeam(Controller Other, UTTeamInfo NewTeam, bool bNewTeam)
{
	local Actor A;

	if ( Other.PlayerReplicationInfo == None )
	{
		return;
	}
	if (Other.PlayerReplicationInfo.Team != None || !ShouldSpawnAtStartSpot(Other))
	{
		// clear the StartSpot, which was a valid start for his old team
		Other.StartSpot = None;
	}

	// remove the controller from his old team
	if ( Other.PlayerReplicationInfo.Team != None )
	{
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = none;
	}

	if ( NewTeam==None || (NewTeam!= none && NewTeam.AddToTeam(Other)) )
	{
		if ( (NewTeam!=None) && ((WorldInfo.NetMode != NM_Standalone) || (PlayerController(Other) == None) || (PlayerController(Other).Player != None)) )
			BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
	}

	if ( (PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None) )
	{
		// if local player, notify level actors
		ForEach AllActors(class'Actor', A)
		{
			A.NotifyLocalPlayerTeamReceived();
		}
	}
}

/** RatePlayerStart()
* Return a score representing how desireable a playerstart is.
* @param P is the playerstart being rated
* @param Team is the team of the player choosing the playerstart
* @param Player is the controller choosing the playerstart
* @returns playerstart score
*/
function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	if ( bSpawnInTeamArea )
	{
		// never use playerstarts not belonging to this team
		if ( UTTeamPlayerStart(P) == None )
		{
			`warn(P$" is not a team playerstart!");
			return -9;
		}
		if ( Team != UTTeamPlayerStart(P).TeamNumber )
			return -9;
	}
	return Super.RatePlayerStart(P,Team,Player);
}


/* CheckScore()
see if this score means the game ends
*/
function bool CheckScore(PlayerReplicationInfo Scorer)
{
	if (CheckMaxLives(Scorer))
	{
		return false;
	}
	else if ( (!bOverTime && GoalScore == 0) || (Scorer == None) )
	{
		return false;
	}
	else if (Scorer.Team != None && Scorer.Team.Score >= GoalScore)
	{
		EndGame(Scorer,"teamscorelimit");
		return true;
	}
	else if ( bOverTime )
	{
		EndGame(Scorer,"timelimit");
		return true;
	}
	else
	{
		if ( bScoreDeaths && (GoalScore > 0) )
		{
			if ( Scorer.Team.Score == GoalScore - 10 )
			{
				if ( !bPlayedTenKills && (GoalScore > 19) )
				{
					if ( Scorer.Team.Score > Teams[1-Scorer.Team.TeamIndex].Score )
					{
						bPlayedTenKills = true;
						BroadcastLocalized(self,class'UTKillsRemainingMessage', 0);
					}
				}
			}
			else if ( Scorer.Team.Score == GoalScore - 5 )
			{
				if ( !bPlayedFiveKills && (GoalScore > 9) )
				{
					if ( Scorer.Team.Score > Teams[1-Scorer.Team.TeamIndex].Score )
					{
						bPlayedFiveKills = true;
						BroadcastLocalized(self,class'UTKillsRemainingMessage', 1);
					}
				}
			}
			else if ( (Scorer.Team.Score == GoalScore - 1) && !bPlayedOneKill )
			{
				if ( Scorer.Team.Score > Teams[1-Scorer.Team.TeamIndex].Score )
				{
					bPlayedOneKill = true;
					BroadcastLocalized(self,class'UTKillsRemainingMessage', 2);
				}
			}
		}
		return false;
	}
}

// ==========================================================================
// FindVictimsTarget - Tries to determine who the victim was aiming at
// ==========================================================================
function Pawn FindVictimsTarget(Controller Other)
{
	local Vector Start,X,Y,Z;
	local float Dist,Aim;
	local Actor Target;

	if (Other==None || Other.Pawn==None || Other.Pawn.Weapon==None)	// If they have no weapon, they can't be targetting someone
		return None;

	GetAxes(Other.Pawn.GetViewRotation(),X,Y,Z);
	Start = Other.Pawn.Location + vect(0,0,1)*Other.Pawn.BaseEyeHeight;
	Aim = 0.97;
	Target = Other.PickTarget(class'Pawn', aim,dist,X,Start,4000.f);

	return Pawn(Target);

}

/** returns whether the given game object-holding player was near an objective the game object can be scored at */
function bool NearGoal(Controller C)
{
	return false;
}

function ScoreKill(Controller Killer, Controller Other)
{
	local Pawn Target;
	local UTPlayerReplicationInfo KillerPRI, OtherPRI, TargetPRI;
	local UTBot B;

	if ( !Other.bIsPlayer || ((Killer != None) && (!Killer.bIsPlayer || (Killer.PlayerReplicationInfo == None))) )
	{
		Super.ScoreKill(Killer, Other);
		if ( !bScoreTeamKills && (Killer != None) && Killer.bIsPlayer && (MaxLives > 0) )
			CheckScore(Killer.PlayerReplicationInfo);
		return;
	}

	if ( (Killer == None) || (Killer == Other)
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
	{
		if ( Killer != None )
		{
			KillerPRI = UTPlayerReplicationInfo(Killer.PlayerReplicationInfo);
			OtherPRI = UTPlayerReplicationInfo(Other.PlayerReplicationInfo);
			if ( KillerPRI.Team != OtherPRI.Team )
			{
				if ( OtherPRI.bHasFlag )
				{
					OtherPRI.GetFlag().bLastSecondSave = NearGoal(Other);
				}
				
				if ( OtherPRI.bHasFlag )
				{
					if ( NearGoal(Other) )
					{
						OtherPRI.GetFlag().bLastSecondSave = true;
					}

					// Kill Bonuses work as follows (in additional to the default 1 point
					//	+1 Point for killing an enemy targetting an important player on your team
					//	+2 Points for killing an enemy important player

					if ( (OtherPRI != None) )
				{
					KillerPRI.Score+= 2;
					KillerPRI.bForceNetUpdate = TRUE;
					KillerPRI.IncrementEventStat('EVENT_KILLEDFLAGCARRIER');
					if ( UTPlayerController(Killer) != None )
					{
						UTPlayerController(Killer).ClientMusicEvent(6);
						if ( (WorldInfo.TimeSeconds - LastEncouragementTime > 10) )
						{
							// maybe get encouragement from teammate
							ForEach WorldInfo.AllControllers(class'UTBot', B)
							{
								if ( (B.PlayerReplicationInfo != None) && (B.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) && (FRand() < 0.4) )
								{
									B.SendMessage(Killer.PlayerReplicationInfo, 'ENCOURAGEMENT', 0, None);
									break;
								}
							}
						}
					}
					SendFlagKillMessage(Killer, KillerPRI);
				}
				}

				if ( bScoreVictimsTarget )
				{
					Target = FindVictimsTarget(Other);
					TargetPRI = (Target != None) ? UTPlayerReplicationInfo(Target.PlayerReplicationInfo) : None;
					if ( (TargetPRI!=None) && TargetPRI.bHasFlag &&
						(TargetPRI.Team == Killer.PlayerReplicationInfo.Team) )
					{
						Killer.PlayerReplicationInfo.Score+=1;
						Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
					}
				}
			}
		}
		Super.ScoreKill(Killer, Other);
	}
	else
	{
		ModifyScoreKill(Killer, Other);
	}

	if ( !bScoreTeamKills )
	{
		if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Other) && (Killer.PlayerReplicationInfo != None)
			&& (Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
		}
		if ( (MaxLives > 0) && (Killer != None) )
			CheckScore(Killer.PlayerReplicationInfo);
		return;
	}
	if ( Other.bIsPlayer )
	{
		if ( (Killer == None) || (Killer == Other) )
		{
			Other.PlayerReplicationInfo.Team.Score -= 1;
			Other.PlayerReplicationInfo.Team.bForceNetUpdate = TRUE;
		}
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
		{
			Killer.PlayerReplicationInfo.Team.Score += 1;
			Killer.PlayerReplicationInfo.Team.bForceNetUpdate = TRUE;
		}
		else if ( FriendlyFireScale > 0 )
		{
			Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.Team.Score -= 1;
			Killer.PlayerReplicationInfo.Team.bForceNetUpdate = TRUE;
		}
		if ( UTGameReplicationInfo(GameReplicationInfo).bStoryMode && ((PlayerController(Killer) != None) || (PlayerController(Other) != None)) )
		{
			if ( AIController(Killer) != None )
				AdjustSkill(AIController(killer), PlayerController(Other), false);
			if ( AIController(Other) != None )
				AdjustSkill(AIController(Other), PlayerController(Killer), true);
		}
	}

	// check score again to see if team won
    if ( (Killer != None) && bScoreTeamKills )
		CheckScore(Killer.PlayerReplicationInfo);
}

/**
  * Called to adjust skill when bot respawns
  */
function CampaignSkillAdjust(UTBot aBot)
{
	if ( (aBot.PlayerReplicationInfo.Team.TeamIndex == 1) || (AdjustedDifficulty < GameDifficulty) )
	{
		aBot.Skill = AdjustedDifficulty;

		if ( aBot.PlayerReplicationInfo.Team.TeamIndex == 1 )
		{
			// reduced enemy skill slightly if their team is bigger
			if ( Teams[1].Size > Teams[0].size )
			{
				aBot.Skill -= 0.5;
			}
			else if ( (Teams[1].Size < Teams[0].Size) && (NumPlayers > 1) )
			{
				aBot.Skill += 0.75;
			}
			// increase skill for the big bosses.
			if ( aBot.PlayerReplicationInfo.PlayerName ~= "Akasha" )
			{
				aBot.Skill += 1.5;
			}
			else if ( aBot.PlayerReplicationInfo.PlayerName ~= "Loque" )
			{
				aBot.Skill += 0.75;
			}
		}
	}
	else
	{
		aBot.Skill = 0.5 * (AdjustedDifficulty + GameDifficulty);
	}
}

function AdjustSkill(AIController B, PlayerController P, bool bWinner)
{
	local float AdjustmentFactor;

	AdjustmentFactor = 0.15;
    if ( bWinner )
    {
		PlayerKills += 1;
		if ( (Teams[1-P.PlayerReplicationInfo.Team.TeamIndex].Score > Teams[P.PlayerReplicationInfo.Team.TeamIndex].Score + 1)
			&& (Teams[1-P.PlayerReplicationInfo.Team.TeamIndex].Size > 1) )
		{
			// don't adjust up if AI team already winning
			return;
		}
 		AdjustedDifficulty = FMin(7.0,AdjustedDifficulty + AdjustmentFactor);
   }
   else
   {
		PlayerDeaths += 1;
		if ( Teams[1-P.PlayerReplicationInfo.Team.TeamIndex].Score <= Teams[P.PlayerReplicationInfo.Team.TeamIndex].Score )
		{
			// don't adjust down if AI team already losing
			return;
		}
 		AdjustedDifficulty = FMax(0, AdjustedDifficulty - AdjustmentFactor);
   }
	AdjustedDifficulty = FClamp(AdjustedDifficulty, GameDifficulty - 1.25, GameDifficulty + 1.25);
	if ( bWinner == (B.Skill < AdjustedDifficulty) )
	{
		CampaignSkillAdjust(UTBot(B));
		UTBot(B).ResetSkill();
	}
}

function SendFlagKillMessage(Controller Killer, UTPlayerReplicationInfo KillerPRI)
{
	if ( (UTPlayerController(Killer) != None) && !UTPlayerController(Killer).bAutoTaunt )
	{
		return;
	}
	Killer.SendMessage(None, FlagKillMessageName, 10, None);
}

function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
	local int InjuredTeam, InstigatorTeam;
	local class<UTDamageType> UTDamageType;
	local UTPlayerController PC;

	if ( instigatedBy == None )
	{
		Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
		return;
	}

	InjuredTeam = Injured.GetTeamNum();
	InstigatorTeam = instigatedBy.GetTeamNum();
	if (instigatedBy != injured.Controller && (Injured.DrivenVehicle == None || InstigatedBy.Pawn != Injured.DrivenVehicle))
	{
		if ( (InjuredTeam != 255) && (InstigatorTeam != 255) )
		{
			if ( InjuredTeam == InstigatorTeam )
			{
				Momentum *= TeammateBoost;

				if ( InstigatedBy.PlayerReplicationInfo != None )
				{
					PC = UTPlayerController(InstigatedBy);
					if ( (PC != None) && (PC.Pawn != None) && (WorldInfo.TimeSeconds - PC.LastFriendlyFireTime > 5) )
					{
						// make sure PC is looking at injured guy, and no enemies around
						if ( (vector(PC.Rotation) dot Normal(Injured.Location - PC.Pawn.Location)) > 0.9 )
						{
							if ( (PC.ShotTarget == Injured) || (PC.ShotTarget == None) || WorldInfo.GRI.OnSameTeam(PC.ShotTarget, PC) )
					{
						UTDamageType = class<UTDamageType>(DamageType);
						if ( (UTDamageType != None) && UTDamageType.default.bComplainFriendlyFire )
						{
							if ( UTBot(injured.Controller) != None )
							{
								UTBot(Injured.Controller).YellAt(instigatedBy.PlayerReplicationInfo);
							}
							else if ( (UTPlayerController(Injured.Controller) != None) && UTPlayerController(Injured.Controller).bAutoTaunt )
							{
								Injured.Controller.SendMessage(instigatedBy.PlayerReplicationInfo, 'FRIENDLYFIRE', 12);
							}
						}
					}
				}
					}
				}
				if ( FriendlyFireScale==0.0 )
				{
					Damage = 0;
					Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
					return;
				}
				Damage *= FriendlyFireScale;
			}
			else if ( !injured.IsHumanControlled() && (injured.Controller != None)
					&& (UTPlayerReplicationInfo(injured.PlayerReplicationInfo) != None) && UTPlayerReplicationInfo(injured.PlayerReplicationInfo).bHasFlag )
				injured.Controller.SendMessage(None, 'INJURED', 15);
		}
	}
	Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
}

function bool DominatingVictory()
{
	return ( ((Teams[0].Score == 0) || (Teams[1].Score == 0))
		&& (Teams[0].Score + Teams[1].Score >= 3) );
}

function bool IsAWinner( PlayerController C )
{
	if ( C.PlayerReplicationInfo == None )
	{
		return false;
	}
	return ( C.PlayerReplicationInfo.bOnlySpectator || IsWinningTeam(C.PlayerReplicationInfo.Team) );
}

function bool IsWinningTeam( TeamInfo T )
{
	if ( Teams[0].Score > Teams[1].Score )
		return (T == Teams[0]);
	else
		return (T == Teams[1]);
}

function PlayRegularEndOfMatchMessage()
{
	local UTPlayerController PC;
	local int Index;

	if ( Teams[0].Score > Teams[1].Score )
		Index = 4;
	else
		Index = 5;
	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		PC.ClientPlayAnnouncement(VictoryMessageClass, Index);
	}
}

function AnnounceScore(int ScoringTeam)
{
	local UTPlayerController PC;
	local int OtherTeam, MessageIndex;

	if ( TeamScoreMessageClass == None )
	{
		return;
	}

	OtherTeam = 1 - ScoringTeam;

	if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 1 )
	{
		MessageIndex = 4 + ScoringTeam;
	}
	else if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 2 )
	{
		MessageIndex = 2 + ScoringTeam;
	}
	else
	{
		MessageIndex = ScoringTeam;
	}

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		PC.ReceiveLocalizedMessage(TeamScoreMessageClass, MessageIndex);
	}
}

/** OverridePRI()
* override as needed properties of NewPRI with properties from OldPRI which were assigned during the login process
*/
function OverridePRI(PlayerController PC, PlayerReplicationInfo OldPRI)
{
	local UTTeamInfo DesiredTeam;
	local int ActualTeamIndex;

	DesiredTeam = UTTeamInfo(PC.PlayerReplicationInfo.Team);
	PC.PlayerReplicationInfo.OverrideWith(OldPRI);

	// try to use old team
	if (DesiredTeam != PC.PlayerReplicationInfo.Team && DesiredTeam != None)
	{
		ActualTeamIndex = PickTeam(DesiredTeam.TeamIndex, PC);
		if ( PC.PlayerReplicationInfo.Team != Teams[ActualTeamIndex] )
		{
			SetTeam(PC, Teams[ActualTeamIndex], true);
		}
	}
}

/**
 * This function allows the server to override any requested teleport attempts from a client
 *
 * @returns 	returns true if the teleport is allowed
 */
function bool AllowClientToTeleport(UTPlayerReplicationInfo ClientPRI, Actor DestinationActor)
{
	return GameReplicationInfo.OnSameTeam(ClientPRI, DestinationActor);
}

function ShowPathTo(PlayerController P, int TeamNum)
{
	local UTGameObjective G, Best;

	Best = None;
	for (G = Teams[0].AI.Objectives; G != None; G = G.NextObjective)
	{
		if (G.BetterObjectiveThan(Best, TeamNum, P.PlayerReplicationInfo.Team.TeamIndex))
		{
			Best = G;
		}
	}

	if (Best != None && P.FindPathToward(Best, false) != None)
	{
		Spawn(class'UTWillowWhisp', P,, P.Pawn.Location);
	}
}

event GetSeamlessTravelActorList(bool bToEntry, out array<Actor> ActorList)
{
	local int i;

	Super.GetSeamlessTravelActorList(bToEntry, ActorList);

	// keep TeamInfos around so we can keep players' team
	for (i = 0; i < WorldInfo.GRI.Teams.length; i++)
	{
		if (WorldInfo.GRI.Teams[i] != None && (bToEntry || WorldInfo.GRI.Teams[i].Size > 0))
		{
			ActorList[ActorList.length] = WorldInfo.GRI.Teams[i];
		}
	}
}

function Logout(Controller Exiting)
{
	local TeamInfo OldTeam;
	local int i;
	local bool bFound;

	if (!WorldInfo.IsInSeamlessTravel() && Exiting.PlayerReplicationInfo.bFromPreviousLevel)
	{
		OldTeam = Exiting.PlayerReplicationInfo.Team;
	}
	Super.Logout(Exiting);
	// clean up team from old level if necessary
	//@warning: assumes RemoveFromTeam() call is *after* Logout() in Controller::Destroyed()
	if (OldTeam != None && OldTeam.Size <= 1)
	{
		for (i = 0; i < ArrayCount(Teams); i++)
		{
			if (Teams[i] == OldTeam)
			{
				bFound = true;
				break;
			}
		}
		if (!bFound)
		{
			OldTeam.Destroy();
		}
	}
}

event HandleSeamlessTravelPlayer(out Controller C)
{
	local TeamInfo NewTeam;

	if (C.PlayerReplicationInfo != None)
	{
		if (C.PlayerReplicationInfo.Team != None && C.PlayerReplicationInfo.Team.TeamIndex < ArrayCount(Teams))
		{
			if (Teams[C.PlayerReplicationInfo.Team.TeamIndex] != C.PlayerReplicationInfo.Team)
			{
				// move this player to the new team object with the same team index
				NewTeam = Teams[C.PlayerReplicationInfo.Team.TeamIndex];
				// if the old team would now be empty, we don't need it anymore, so destroy it
				if (C.PlayerReplicationInfo.Team.Size <= 1)
				{
					C.PlayerReplicationInfo.Team.Destroy();
				}
				else
				{
					C.PlayerReplicationInfo.Team.RemoveFromTeam(C);
				}
				NewTeam.AddToTeam(C);

				if (C.IsA('UTBot') && NewTeam.IsA('UTTeamInfo'))
				{
					// init bot orders
					UTTeamInfo(NewTeam).SetBotOrders(UTBot(C));
				}
			}
		}
		else if (!C.PlayerReplicationInfo.bOnlySpectator && AIController(C) == none)
		{
			//@FIXME: get team preference from somewhere?
			ChangeTeam(C, 0, false);
		}
	}

	Super.HandleSeamlessTravelPlayer(C);
}

/** parses the given speech for the bots that should receive it */
function ParseSpeechRecipients(UTPlayerController Speaker, const out array<SpeechRecognizedWord> Words, out array<UTBot> Recipients)
{
	local int i;
	local UTBot B;
	local bool bEntireTeam;
	local UTPlayerReplicationInfo PRI;

	bEntireTeam = (Words[0].WordText ~= "Team") || (Words[0].WordText ~= "everyone") || (Words[0].WordText ~= "all");
	for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
	{
		PRI = UTPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]);
		if ( PRI != None && PRI.Team != None && PRI.Team == Speaker.PlayerReplicationInfo.Team &&
			(bEntireTeam || PRI.GetCallSign() ~= Words[0].WordText) )
		{
			B = UTBot(GameReplicationInfo.PRIArray[i].Owner);
			if (B != None)
			{
				Recipients[Recipients.length] = B;
			}
		}
	}
}

/** parses and sends the orders in the given speech to the Recipients */
function ProcessSpeechOrders(UTPlayerController Speaker, const out array<SpeechRecognizedWord> Words, const out array<UTBot> Recipients)
{
	local name Orders;
	local int i;
	local Vehicle V;
	local bool bShouldAck;

	switch (Caps(Words[1].WordText))
	{
		case "ATTACK":
		case "DEFEND":
		case "FREELANCE":
		case "HOLD":
		//@todo: maybe support "Follow/Cover Alpha", etc to force bots to group with other bots?
		case "FOLLOW":
			Orders = name(Words[1].WordText);
			break;
		case "COVER":
			Orders = 'Follow';
			break;
		case "TAUNT":
			for (i = 0; i < Recipients.length; i++)
			{
				Recipients[i].SendMessage(None, 'TAUNT', 0);
			}
			break;
		case "SUICIDE":
			for (i = 0; i < Recipients.length; i++)
			{
				if (Recipients[i].Pawn != None)
				{
					Recipients[i].Pawn.Suicide();
				}
			}
			break;
		case "STATUS":
			for (i = 0; i < Recipients.length; i++)
			{
				Recipients[i].SendMessage(Speaker.PlayerReplicationInfo, 'STATUS', 0);
			}
			break;
		case "JUMP":
			for (i = 0; i < Recipients.length; i++)
			{
				if (Recipients[i].Pawn != None)
				{
					Recipients[i].Pawn.bWantsToCrouch = false;
					Recipients[i].Pawn.DoJump(false);
				}
			}
			break;
		case "GIMME":
			for (i = 0; i < Recipients.length; i++)
			{
				Recipients[i].ForceGiveWeapon();
			}
			break;
		case "GET OUT":
			for (i = 0; i < Recipients.length; i++)
			{
				V = Vehicle(Recipients[i].Pawn);
				if (V != None)
				{
					V.DriverLeave(false);
				}
			}
			break;
		default:
			break;
	}

	if (Orders != 'None')
	{
		bShouldAck = true;
		for (i = 0; i < Recipients.length; i++)
		{
			Recipients[i].SetBotOrders(Orders, Speaker, bShouldAck);
			bShouldAck = false;
		}
	}
}

function ProcessSpeechRecognition(UTPlayerController Speaker, const out array<SpeechRecognizedWord> Words)
{
	local array<UTBot> Recipients;

	Super.ProcessSpeechRecognition(Speaker, Words);

	ParseSpeechRecipients(Speaker, Words, Recipients);
	ProcessSpeechOrders(Speaker, Words, Recipients);
}

defaultproperties
{
	bScoreTeamKills=true
	bMustJoinBeforeStart=false
	bTeamGame=True
	TeamAIType(0)=class'UTGame.UTTeamAI'
	TeamAIType(1)=class'UTGame.UTTeamAI'
	EndMessageWait=1
	TeammateBoost=+0.3
	FriendlyFireScale=+0.0
	bMustHaveMultiplePlayers=true
	FlagKillMessageName=TAUNT

	Acronym="TDM"
	MapPrefixes[0]="DM"
 	HUDType=class'UTGame.UTTeamHUD'

	OnlineGameSettingsClass=class'UTGameSettingsTDM'
	MidgameScorePanelTag=TDMPanel

	// We don't want players on opposing teams to be able to hear each other
	bIgnoreTeamForVoiceChat=false
}



