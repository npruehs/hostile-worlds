// ============================================================================
// HWGame
// Implements Hostile Worlds main game logic.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/08/13
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HWGame extends GameInfo
	config(HostileWorlds); // UDKHostileWorlds.ini is accessed here in order to set GameInfo.GoalScore

/** The version number of the current build. */
const VERSION = "0.4.6";

/** The number of seconds between two updates of one of the visibility masks of the server. */
const VISIBILITY_UPDATE_INTERVAL = 0.25f;

/** The name of the frontend map responsible of loading the main menu. */
const FRONTEND_MAP_NAME = "HW-FrontEnd";


/** Whether to log gameplay events to the Stats folder of the game's main directory, or not. */
var bool bLogGameplayEvents;

/** The writer used for logging the gameplay events. */
var transient GameplayEventsWriter GameplayEventsWriter;

/** The message each user receives after they have succesfully logged in, followed by their name and an !. */
var localized string WelcomeMessage;

/** The array of available TeamInfo's. */
var	HWTeamInfo Teams[2];

/** The HWArtifactManager controlling all artifacts. */
var HWArtifactManager ArtifactManager;

/** A dynamic array of all existing HWAlienCamps. */
var array<HWAlienCamp> AlienCamps;

/** A reference to the HWMapInfoActor that allows tranformations between world space and tile space. */
var HWMapInfoActor Map;

/** The index of the team the visibility is updated for the next time. */
var int TeamToUpdateVisibilityFor;

/** The list of hints one of which is shown on the loading screen. */
var localized string GameHints[11];

/** The error message to show whenever a player tries to join a game that is already running. */
var localized string ErrorGameAlreadyRunning;


event InitGame(string Options, out string ErrorMessage)
{
	`Log(">>> 1. InitGame");

	super.InitGame(Options, ErrorMessage);

	`log("This is Hostile Worlds version "$VERSION);

	// parse passed game options
	GoalScore = Max(0, GetIntOption(Options, "ScoreLimit", GoalScore));

	`log("Score limit is now "$GoalScore);
	`log("Time limit is now "$TimeLimit);
}

event PreBeginPlay()
{
	local HWMapInfoActor TheMap;

	`Log(">>> 2. PreBeginPlay");

	super.PreBeginPlay();

	// clear previous references
	Map = none;

	// find new map info actor
	foreach AllActors(class'HWMapInfoActor', TheMap)
	{
		Map = TheMap;
		Map.Initialize();
		break;
	}

	// create teams and set up their server-side visibility masks
	CreateTeam(0);
	CreateTeam(1);
}

function InitGameReplicationInfo()
{
	super.InitGameReplicationInfo();

	`Log(">>> 2b. InitGameReplicationInfo");

	// Unreal, why don't you do that in your default engine implementation??!
	GameReplicationInfo.GoalScore = GoalScore;
	GameReplicationInfo.TimeLimit = TimeLimit;
	GameReplicationInfo.RemainingTime = 60 * TimeLimit;
}

event PostBeginPlay()
{
	`Log(">>> 3. PostBeginPlay");

	super.PostBeginPlay();

	// initialize gameplay events writer
	if (bLogGameplayEvents)
	{
		GameplayEventsWriter = new(self) class'GameplayEventsWriter';

		if (GameplayEventsWriter != none)
		{
			`Log("GamePlayEventsWriter up and running.");
		}
	}
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	`Log(">>> 4. Login");

	return super.Login(Portal, Options, UniqueID, ErrorMessage);
}

event PostLogin(PlayerController NewPlayer)
{
	local HWPlayerController NewHWPlayer;
	local HWPlayerController PC;
	local PlayerReplicationInfo PRI;

	`Log(">>> 5. PostLogin");

	super.PostLogin(NewPlayer);

	NewHWPlayer = HWPlayerController(NewPlayer);
	NewHWPlayer.ClientSetSoundVolume();

	if (Map != none)
	{
		// initialize player HUD and set up his or her client-side visibility mask
		NewHWPlayer.Map = Map; // server
		NewHWPlayer.ClientInitializeLobby(Map, GoalScore, TimeLimit); // client
	}
	else
	{
		// hide HUD in menu levels
		NewHWPlayer.HideHUD();
	}

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		// tell all other players about the player that has joined
		if (PC != NewPlayer)
		{
			PRI = NewPlayer.PlayerReplicationInfo;

			PC.ClientOtherPlayerJoined
				(PRI.PlayerName,
				 PRI.Team.TeamIndex,
				 HWTeamInfo(PRI.Team).GetPlayerSlot(NewHWPlayer));
		}

		// tell the new player about all others players already in the game
		PRI = PC.PlayerReplicationInfo;

		NewHWPlayer.ClientOtherPlayerJoined
			(PRI.PlayerName,
			 PRI.Team.TeamIndex,
			 HWTeamInfo(PRI.Team).GetPlayerSlot(PC));
	}

	// if PIE, start match immediately
	if (WorldInfo.NetMode == NM_Standalone && Map != none)
	{
		StartMatch();
	}
}

function StartMatch()
{
	local HWPlayerController PC;

	`Log(">>> 6. StartMatch");

	super.StartMatch();

	// start logging
	if (GameplayEventsWriter != none)
	{
		GameplayEventsWriter.StartLogging(0.5f);
		`Log("GamePlayEventsWriter started logging.");
	}

	// spawn the ArtifactManager
	ArtifactManager = Spawn(class'HWArtifactManager');	
	ArtifactManager.Game = self;
	ArtifactManager.ArtifactCycleRoundsTotal = Map.ArtifactCycleRoundsTotal;
	
	// Activate all artifacts for the first round
	ArtifactManager.NextArtifactRound();

	// update visibility masks at a rate less frequent than the frame rate
	SetTimer(VISIBILITY_UPDATE_INTERVAL, true, 'UpdateVisiblity');

	// write log output for analyzing tool
	`log("SERVER: New match started.");
	`log("SERVER: Map "$WorldInfo.GetMapName(true));
	`log("SERVER: Format "$Teams[0].Size$"v"$Teams[1].Size);

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		PC.ClientInitializeMatch(PC.PlayerReplicationInfo.Team.TeamIndex);

		`log("SERVER: Player "$PC.PlayerReplicationInfo.PlayerName);
	}
	
	GotoState('MatchInProgress');
}

function StartHumans()
{
	`Log(">>> 7. StartHumans");

	super.StartHumans();
}

function StartBots()
{
	local HWGameObject go;
	local HWAlienCamp c;

	`Log(">>> 8. StartBots");

	// initialize all game objects
	foreach AllActors(class'HWGameObject', go)
	{
		go.Initialize(Map);

		c = HWAlienCamp(go);

		if (c != none)
		{
			AlienCamps.AddItem(c);
		}
	}
}

function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string IncomingName)
{
	local PlayerStart P;
	local byte Team;
	local float NewRating;
	local float BestRating;
	local PlayerStart BestStart;

	// ignore player start rating on logins
	if (Player == none)
	{
		foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P)
		{
			return P;
		}
	}

	// use InTeam if player doesn't have a team yet
	Team = ((Player != None) && (Player.PlayerReplicationInfo != None) && (Player.PlayerReplicationInfo.Team != None))
			? byte(Player.PlayerReplicationInfo.Team.TeamIndex)
			: InTeam;

	// find best PlayerStart
	foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P)
	{
		NewRating = RatePlayerStart(P, Team, Player);

		if (NewRating > BestRating)
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}

	// don't use PlayerStarts twice
	Player.StartSpot = BestStart;
	BestStart.bEnabled = false;

	return BestStart;
}

function ChangeName(Controller Other, coerce string S, bool bNameChange)
{
	local HWPlayerSettings PlayerSettings;

	super.ChangeName(Other, S, bNameChange);

	PlayerSettings = HWPlayerController(Other).GetPlayerSettings();
	PlayerSettings.PlayerName = S;
	PlayerSettings.SaveConfig();
}

function byte PickTeam(byte Current, Controller C)
{
	local byte TeamSizes[2];
	local TeamInfo CurrentTeam;

	// get the current team sized
	TeamSizes[0] = Teams[0].Size;
	TeamSizes[1] = Teams[1].Size;

	// if a player has been passed...
	if (C != none)
	{
		// ... and he or she is already in a team ...
		CurrentTeam = C.PlayerReplicationInfo.Team;

		if (CurrentTeam.TeamIndex == 0 || CurrentTeam.TeamIndex == 1)
		{
			// adjust that team's size
			TeamSizes[CurrentTeam.TeamIndex]--;
		}
	}

	// return index of smaller team
	return (TeamSizes[0] <= TeamSizes[1]) ? 0 : 1;
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	local bool bNewPlayer;
	local HWPlayerController PC;
	local PlayerReplicationInfo PRI;
	local int OldTeamIndex;
	local int OldSlot;

	// check if a valid team index has been specified
	if (N == 0 || N == 1)
	{
		PRI = Other.PlayerReplicationInfo;
		bNewPlayer = (PRI.Team == none);

		// if the player is already in a team, remove him or her
		if (!bNewPlayer)
		{
			
			OldTeamIndex =  PRI.Team.TeamIndex;
			OldSlot = HWTeamInfo(PRI.Team).GetPlayerSlot(HWPlayerController(Other));

			Teams[PRI.Team.TeamIndex].RemoveFromTeam(Other);
		}

		// add player to the new team
		Teams[N].AddToTeam(Other);

		// if the player has already been in a team, notify all players of the team change
		if (!bNewPlayer)
		{
			foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
			{
				PC.ClientPlayerChangedTeam
					(PRI.PlayerName,
					 OldTeamIndex,
					 OldSlot,
					 PRI.Team.TeamIndex,
					 HWTeamInfo(PRI.Team).GetPlayerSlot(HWPlayerController(Other)));
			}
		}

		return true;
	}

	return false;
}

/** Tells all other players that we're shutting down the server. */
function NotifyServerShuttingDown()
{
	local HWPlayerController PC;

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		if (LocalPlayer(PC.Player) == none)
		{
			`log("Telling "$PC$" that we're shutting down...");
			PC.ClientNotifyServerShutDown();
		}	
	}
}

function Logout(Controller Exiting)
{
	local HWPlayerController ExitingPlayer;
	local PlayerReplicationInfo ExitingPlayerPRI;
	local HWPlayerController PC;

	ExitingPlayer = HWPlayerController(Exiting);
	ExitingPlayerPRI = ExitingPlayer.PlayerReplicationInfo;

	if (LocalPlayer(ExitingPlayer.Player) == none)
	{
		// tell all others players about the leaver
		foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
		{
			PC.ClientOtherPlayerLeft
				(ExitingPlayerPRI.PlayerName,
				 ExitingPlayerPRI.Team.TeamIndex,
				 HWTeamInfo(ExitingPlayerPRI.Team).GetPlayerSlot(ExitingPlayer));
		}
	}

	super.Logout(Exiting);

	`log(Exiting$" logged out.");
}

function Kick(string S)
{
	super.Kick(S);

	`log("Kicked player "$S);
}

/** 
 * Updates one of the visibility masks of the server, stopping all orders
 * that target units that just turned hidden for their respective enemies.
 */
function UpdateVisiblity()
{
	local HWPlayerController PC;

	UpdateVisibilityForTeam(TeamToUpdateVisibilityFor);

	// alternate between mask updates
	TeamToUpdateVisibilityFor = 1 - TeamToUpdateVisibilityFor;

	// cut down vision for score screen before variable has overflow
	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		PC.TotalVisionK += PC.TotalVision / 1000;
		PC.TotalVision = PC.TotalVision % 1000;
	}
}

/**
 * Updates the visibility masks for the specified team, stopping all orders
 * that target enemy units that just turned hidden.
 * 
 * @param Team
 *      the index of the team to update the visibility mask of
 */
function UpdateVisibilityForTeam(int Team)
{
	local HWPawn p;
	local IntPoint Tile;

	// compute new visibility mask
	Teams[Team].VisibilityMask.Update();
	
	// apply fog of war logic
	foreach DynamicActors(class'HWPawn', p)
	{
		// iterate all enemy pawns...
		if (!(p.TeamIndex == Team))
		{
			// ...and check whether they're visible or not
			Tile = Map.GetMapTileFromLocation(p.Location);

			if (Teams[Team].VisibilityMask.IsMapTileHidden(Tile))
			{
				// if it just turned invisible, stop orders targeting it
				if (p.bHiddenForTeam[Team] == 0)
				{
					StopOrders(p, Team);
					p.bHiddenForTeam[Team] = 1;
				}
			}
			else
			{
				p.bHiddenForTeam[Team] = 0;
			}
		}
	}
}

/**
 * Stops all orders of units belonging to the team with the passed index
 * on the given Target.
 * 
 * @param Target
 *      the target unit to stop orders for
 * @param TeamToHideUnitFrom
 *      the index of the team to check the units of
 */
function StopOrders(HWPawn Target, int TeamToHideUnitFrom)
{
	local HWPawn p;
	local HWAIController c;

	foreach DynamicActors(class'HWPawn', p)
	{
		// iterate all units belonging to the passed team
		if (p.TeamIndex == TeamToHideUnitFrom)
		{
			// a pawn's controller can destroyed already, while the pawn still exists
			if(p.Controller == none)
			{
				break;
			}

			c = HWAIController(p.Controller);

			// check whether the current unit's order is targeting the hiding unit
			if ((c != none) &&
				(c.CurrentOrder == O_Attacking                  && c.OrderTargetUnit == Target) ||
				(c.CurrentOrder == O_UsingAbilityTargetingUnit  && c.OrderedAbilityTargetingUnit.TargetUnit == Target))
			{
				`log(p$" stopped targeting "$Target$" because the latter just turned hidden.");
				c.IssueStopOrder();
			}
		}
	}
}

/**
 * Creates a player team with the given index and replicates it through the GameReplicationInfo
 */
function CreateTeam(int TeamIndex)
{
	Teams[TeamIndex] = spawn(class'HWTeamInfo');
	Teams[TeamIndex].TeamIndex = TeamIndex;
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);

	if (Map != none)
	{
		Teams[TeamIndex].VisibilityMask = new class'HWVisibilityMask';
		Teams[TeamIndex].VisibilityMask.Initialize(Map, TeamIndex);
	}

	`Log("CreateTeam() TeamIndex:"@TeamIndex@"Teams[TeamIndex]:"@Teams[TeamIndex]);
}

/**
 * Returns a pawn of the default pawn class and triggers the
 * PlayerSpawned event of the HWPlayerController.
 *
 * @param NewPlayer
 *      Controller for whom this pawn is spawned
 * @param StartSpot
 *      PlayerStart at which to spawn pawn
 */
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local Rotator StartRotation;
    local Pawn PlayerPawn;

	// spawn player pawn
    PlayerPawn = super.SpawnDefaultPawnFor(NewPlayer, StartSpot);

	// don't allow pawns to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	// spawn commander
	HWPlayerController(NewPlayer).SpawnCommander(Map, StartSpot.Location, StartRotation);

	// set players initial camera location
	HWPlayerController(NewPlayer).SetViewTarget(StartSpot);

    return PlayerPawn;
}

/** 
 *  Overrides GameInfo.Killed() in order to implement custom Hostile Worlds logic.
 */
function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType)
{
    // Don't call the base function, as Hostile Worlds doesn't need it and it might cause "KilledPlayer.PlayerReplicationInfo == none" access errors
    // (since the Controller is a HWAIController)

	NotifyKilled(Killer, KilledPlayer, KilledPawn, damageType);
}

/** Returns a random Hostile Worlds hint. */
function string GetRandomHint()
{
	return GameHints[rand(11)];
}

/**
 * This function must be called if a player scored victory points in order to decide if he wins.
 * 
 * @param Scorer
 *      the PlayerReplicationInfo of the player whose score shall be checked.
 */ 
function bool CheckScore(PlayerReplicationInfo Scorer)
{
	local HWPlayerController PC;

	// CheckScore() can also be called due to a Pawn.Died() call. 
	// The Controller passed on the following GameInfo.ScoreKilled() call is an HWAIController, which has no PlayerReplicationInfo, and therefor the given Scorer is none.
	if(Scorer == none)
		return false;
	
	// notify all clients of the new scores
	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		PC.ClientUpdateScores(Teams[0].Score, Teams[1].Score, GoalScore);
	}

	if (Scorer.Team != None && Scorer.Team.Score >= GoalScore)
	{
		EndGame(Scorer,"TeamScoreLimit");
		return true;
	}
	else if (bOverTime)
	{
		// if teams are tied at over time, scorer immediately wins
		EndGame(Scorer, "timelimit");
		return true;
	}

	return false;
}

/** 
 *  Modified implementation of UTGame.EndGame().
 *  Goes to the MatchOver state.
 */
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local HWPlayerController PC;

	if ((Reason ~= "TeamScoreLimit") ||
		(Reason ~= "TimeLimit") ||
		(Reason ~= "PlayerLeft"))
	{
		// Super function call results in a CheckEndGame() call and sets bGameEnded
		Super.EndGame(Winner,Reason);

		if (bGameEnded)
		{
			// write log output for analyzing tool
			foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
			{
				`log("SERVER: Actions "$PC.PlayerReplicationInfo.PlayerName@PC.TotalActions);
			}

			`log("SERVER: Match time "$GameReplicationInfo.ElapsedTime);
			`log("SERVER: Winner "$Winner.PlayerName);
			`log("SERVER: Match ended.");
			
			GotoState('MatchOver');
		}
	}
}

/**
 * Modified implementation of UTGame.CheckEndGame().
 * This function is call by GameInfo.EndGame() in order to let a sub class decide if to end the game.
 * This functions sets GameReplicationInfo.Winner to the given Winner,
 * chooses the EndGameFocus actor
 * and calls GameHasEnded() on all PlayerControllers.
 */
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local HWTeamInfo WinningTeam;
	local PlayerController PC;
	local Actor EndGameFocus;

	// find winning team
	if ((Reason ~= "TeamScoreLimit") ||
		(Reason ~= "TimeLimit"))
	{
		if (Teams[0].Score > Teams[1].Score)
		{
			WinningTeam = Teams[0];
		}
		else if (Teams[1].Score > Teams[0].Score)
		{
			WinningTeam = Teams[1];
		}
		else
		{
			// tied!
			return false;
		}

		if (Winner == None)
		{
			// find winner
			foreach WorldInfo.AllControllers(class'PlayerController', PC)
			{
				if (PC.PlayerReplicationInfo.Team == WinningTeam)
				{
					Winner = PC.PlayerReplicationInfo;
					break;
				}
			}
		}
	}
	else if (Reason ~= "PlayerLeft")
	{
		WinningTeam = HWTeamInfo(Winner.Team);
	}

	GameReplicationInfo.Winner = WinningTeam;

	// pass game results to all players
	ReplicateGameResults();

	// all player cameras focus on winner's commander
	EndGameFocus = HWPlayerController(Winner.Owner).Commander;	

	foreach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		PC.GameHasEnded(EndGameFocus, (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team == WinningTeam));
	}

	return true;
}

/** Creates a package containing all scores of all players and sends it to all players. */
function ReplicateGameResults()
{
	local HWGameResults Results;
	local HWPlayerController PC;

	local int NextTeamIndex[2];
	local int ResultArrayIndex;
	
	// prepare new result set
	Results = Spawn(class'HWGameResults');

	// set map name and time
	Results.MapName = WorldInfo.GetMapName(true);
	Results.MapTime = GameReplicationInfo.ElapsedTime;

	// fill player stats
	NextTeamIndex[0] = 0;
	NextTeamIndex[1] = 0;

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		`log("Preparing game results for player "$PC.PlayerReplicationInfo.Name$"...");

		// compute index for result arrays
		ResultArrayIndex = NextTeamIndex[PC.PlayerReplicationInfo.Team.TeamIndex];

		if (PC.PlayerReplicationInfo.Team.TeamIndex != 0)
		{
			ResultArrayIndex += 4;
		}

		// set player name
		Results.PlayerNames[ResultArrayIndex] = PC.PlayerReplicationInfo.PlayerName;

		// set resource scores
		Results.TotalShardsFarmed[ResultArrayIndex] = PC.TotalShardsFarmed;
		Results.TotalArtifactsAcquired[ResultArrayIndex] = PC.TotalArtifactsAcquired;
		Results.TotalVision[ResultArrayIndex] = PC.TotalVisionK;
		Results.TotalActions[ResultArrayIndex] = PC.TotalActions;

		// set ability scores
		Results.TotalAbilitiesTriggered[ResultArrayIndex] = PC.TotalAbilitiesTriggered;
		Results.TotalTacticalAbilitiesTriggered[ResultArrayIndex] = PC.TotalTacticalAbilitiesTriggered;
		Results.TotalKnockbacksCaused[ResultArrayIndex] = PC.TotalKnockbacksCaused;
		Results.TotalKnockbacksTaken[ResultArrayIndex] = PC.TotalKnockbacksTaken;

		// set unit scores
		Results.TotalAliensKilled[ResultArrayIndex] = PC.TotalAliensKilled;
		Results.TotalSquadMembersKilled[ResultArrayIndex] = PC.TotalSquadMembersKilled;
		Results.TotalSquadMembersLost[ResultArrayIndex] = PC.TotalSquadMembersLost;
		Results.TotalSquadMembersDismissed[ResultArrayIndex] = PC.TotalSquadMembersDismissed;
		Results.TotalReinforcementsCalled[ResultArrayIndex] = PC.TotalReinforcementsCalled;

		// set damage & healing scores
		Results.TotalDamageDealt[ResultArrayIndex] = PC.TotalDamageDealt;
		Results.TotalDamageTaken[ResultArrayIndex] = PC.TotalDamageTaken;
		Results.TotalDamageHealed[ResultArrayIndex] = PC.TotalDamageHealed;

		// set terrain scores
		Results.TotalTimeSpentInDamageArea[ResultArrayIndex] = PC.TotalTimeSpentInDamageArea;
		Results.TotalTimeSpentInSlowArea[ResultArrayIndex] = PC.TotalTimeSpentInSlowArea;
		Results.TotalTowersCaptured[ResultArrayIndex] = PC.TotalTowersCaptured;

		// increase team player count
		NextTeamIndex[PC.PlayerReplicationInfo.Team.TeamIndex]++;
	}

	// compute meta scores
	Results.ComputeScores();

	// replicate game results
	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		`log("Sending game results to player "$PC.PlayerReplicationInfo.Name$"...");
		PC.Results = Results;
	}
}

function EndLogging(string Reason)
{
	if (GameplayEventsWriter != none)
	{
		GameplayEventsWriter.EndLogging();
		`Log("GamePlayEventsWriter finished logging.");
	}

	Super.EndLogging(Reason);
}

/** Returns true if called for the PlayerController of the first player (TeamIndex == 0), false otherwise. */
function bool PlayerCanRestartGame(PlayerController aPlayer)
{
	return aPlayer.PlayerReplicationInfo.Team.TeamIndex == 0;
}

function ResetLevel()
{
	local HWAlienCamp AlienCamp;

	super.ResetLevel();

	// Initialization of the AlienCamps must be done after all Pawns are destroyed by the super.ResetLevel() call.
	// This shouldn't be done in the HWAlienCamp.Reset() call since several HWPawns still might exist, likely causing more "Destroyed because it was encroaching another Actor" errors.
	foreach AlienCamps(AlienCamp)
	{
		AlienCamp.Initialize(Map);
	}
}

function Reset()
{
	super.Reset();
	
	// The ArtifactManager should already have been reset in GameInfo.ResetLevel(),
	// do it again to be sure though :)
	ArtifactManager.Reset();

	// Activate all artifacts for the first round
	ArtifactManager.NextArtifactRound();

	Teams[0].Score = 0;
	Teams[1].Score = 0;
}

function bool MatchIsInProgress()
{
	return false;
}

/**
 * Returns a location with a random offset from the center inside the given radius
 * 
 *  @param center
 *      The center from which to find a random location.
 *      
 *  @param radius
 *      The radius from the center the random location lies in.
 *      
 *  @param disregardX
 *      If to disregard a random offset for the X component.
 *      
 *  @param disregardY
 *      If to disregard a random offset for the Y component.
 *      
 *  @param disregardZ
 *      If to disregard a random offset for the Z component.
 */
static function Vector GetRandomLocationInRadius(Vector center, float radius, optional bool disregardX, optional bool disregardY, optional bool disregardZ)
{
	local Vector NewLocation;
	local float Random;

	// find a random value from -radius to radius
	NewLocation.X = disregardX ? 0.0f : RandRange(-radius, radius);
	NewLocation.Y = disregardY ? 0.0f : RandRange(-radius, radius);
	NewLocation.Z = disregardZ ? 0.0f : RandRange(-radius, radius);

	// normalize the vector
	NewLocation = Normal(NewLocation);

	// scale it by random value inside the radius
	Random = Rand(radius + 1);
	NewLocation *= Random;

	// add the center offset
	NewLocation += center;

	return NewLocation;
}

/** 
 *  Returns the HotKey as string, 
 *  which must be pressed in order call the squadmember of the given index
 *  (index corresponding to the HWRace.SquadMemberClasses array).
 */
static function string GetHotkeyCallSquadmember(int index)
{
	switch(index)
	{
		case 0:
			return "I";

		case 1:
			return "O";

		case 2:
			return "P";
	}
}

/** 
 *  Returns the HotKey as string, 
 *  which must be pressed in order trigger the tactical ability of the given index
 *  (index corresponding to the HWRace.TacticalAbilities array).
 */
simulated static function string GetHotkeyTacticalAbility(int index)
{
	switch(index)
	{
		case 0:
			return "Q";

		case 1:
			return "W";

		case 2:
			return "E";
	}
}

/**
 * Notifies all allies of the passed player that his or her forces are under
 * attack.
 * 
 * @param inPlayer
 *      the player that is under attack
 */
function NotifyTakeDamage(HWPlayerController inPlayer)
{
	local HWPlayerController PC;

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		if (PC != inPlayer && PC.PlayerReplicationInfo.Team.TeamIndex == inPlayer.PlayerReplicationInfo.Team.TeamIndex)
		{
			PC.ClientNotifyAllyUnderAttack();
		}
	}
}

/**
 * Notifies all allies of the passed player that his or her commander has
 * fallen.
 * 
 * @param inPlayer
 *      the player whose commander has fallen
 */
function NotifyCommanderDied(HWPlayerController inPlayer)
{
	local HWPlayerController PC;

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		if (PC != inPlayer && PC.PlayerReplicationInfo.Team.TeamIndex == inPlayer.PlayerReplicationInfo.Team.TeamIndex)
		{
			PC.ClientNotifyAlliedCommanderDied();
		}
	}
}


// ----------------------------------------------------------------------------
// Cheats.

/** Adds the specified number of shards for all players. */
exec function Shards(int Value)
{
	local HWPlayerController PC;

	foreach WorldInfo.AllControllers(class'HWPlayerController', PC)
	{
		PC.Shards += Value;
	}
}

// ----------------------------------------------------------------------------

state MatchInProgress
{
	function BeginState(Name PreviousStateName)
	{
		local PlayerReplicationInfo PRI;

		// reset elapsed time
		foreach DynamicActors(class'PlayerReplicationInfo', PRI)
		{
			PRI.StartTime = 0;
		}
		
		GameReplicationInfo.ElapsedTime = 0;
		GameReplicationInfo.bStopCountDown = false;
	}

	function bool MatchIsInProgress()
	{
		return true;
	}

	function Timer()
	{
		global.Timer();

		// enforce time limit
		if (TimeLimit > 0 && GameReplicationInfo.RemainingTime <= 0)
		{
			EndGame(None,"TimeLimit");
		}
	}

	event PreLogin(string Options, string Address, out string ErrorMessage)
	{
		ErrorMessage = "HostileWorlds.HWGame.ErrorGameAlreadyRunning";
		return;
	}

	function Logout(Controller Exiting)
	{
		local HWPlayerController ExitingPlayer;
		local PlayerReplicationInfo ExitingPlayerPRI;
		local HWSquadMember SquadMember;
		local int ShardsPerPlayer;
		local HWTeamInfo Team;
		local HWPlayerController PC;
		local int Slot;

		ExitingPlayer = HWPlayerController(Exiting);
		ExitingPlayerPRI = ExitingPlayer.PlayerReplicationInfo;

		`log("Player "$ExitingPlayerPRI.Name$" is about to surrender and leave the game.");

		// dismiss all of the leaving player's squad members
		foreach DynamicActors(class'HWSquadMember', SquadMember)
		{
			if (SquadMember.OwningPlayer == ExitingPlayer)
			{
				ExitingPlayer.ServerDismissSquadMember(SquadMember);
			}
		}

		// check if in his or her team are any remaining players
		Team = Teams[ExitingPlayerPRI.Team.TeamIndex];

		if (Team.Size > 1)
		{
			// distribute his or her shards to the remaining team mates
			`log("Size of team "$Team.TeamIndex$" is "$Team.Size$", distributing shards among remaining players...");

			ShardsPerPlayer = ExitingPlayer.Shards / (Team.Size - 1);

			for (Slot = 0; Slot < 4; Slot++)
			{
				PC = Team.Players[Slot];

				if (PC != none && PC != ExitingPlayer)
				{
					PC.Shards += ShardsPerPlayer;
					`log(PC$" has received "$ShardsPerPlayer$" because his or her team mate left.");
				}
			}
		}
		else
		{
			// the other team wins
			`log("Size of team "$Team.TeamIndex$" is "$Team.Size$", the other team wins!");

			Team = Teams[1 - ExitingPlayerPRI.Team.TeamIndex];

			// find any player in the other team and return
			for (Slot = 0; Slot < 4; Slot++)
			{
				PC = Team.Players[Slot];

				if (PC != none)
				{
					EndGame(PC.PlayerReplicationInfo, "PlayerLeft");
					break;
				}
			}
		}

		super.Logout(Exiting);

		`log(Exiting$" has surrendered and left the game.");
	}
}

State MatchOver
{
	function BeginState(Name PreviousStateName)
	{
		local Pawn P;
		local HWAlienCamp C;

		// Call TurnOff() on all pawns here, in order to freeze them on the server
		foreach WorldInfo.AllPawns(class'Pawn', P)
		{
			P.TurnOff();
		}

		// Set all AlienCamps to RoundEnded state
		foreach AlienCamps(C)
		{
			C.GoToState('RoundEnded');
		}

		ArtifactManager.GoToState('RoundEnded');
	}
}

DefaultProperties
{
	PlayerControllerClass=class'HWPlayerController'
	DefaultPawnClass=class'HWPlayerPawn'	 
	HUDType=class'HWHud'

	bTeamGame=true

	bDelayedStart=true
	bWaitingToStartMatch=false
	bRestartLevel=false

	bLogGameplayEvents=false
}
