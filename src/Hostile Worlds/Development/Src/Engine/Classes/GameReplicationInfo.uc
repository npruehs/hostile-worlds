//=============================================================================
// GameReplicationInfo.
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//
// Every GameInfo creates a GameReplicationInfo, which is always relevant, to replicate
// important game data to clients (as the GameInfo is not replicated).
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	config(Game)
	native(ReplicationInfo)
	nativereplication;

/** Class of the server's gameinfo, assigned by GameInfo. */
var repnotify class<GameInfo> GameClass;

/** The data store instance responsible for presenting state data for the current game session. */
var	protected		CurrentGameDataStore		CurrentGameData;

/** If true, stop RemainingTime countdown */
var bool bStopCountDown;

/** Match is in progress (replicated) */
var repnotify bool bMatchHasBegun;

/** Match is over (replicated) */
var repnotify bool bMatchIsOver;

/** Used for counting down time in time limited games */
var databinding int  RemainingTime, ElapsedTime, RemainingMinute;

/** Replicates scoring goal for this match */
var databinding int GoalScore;

/** Replicates time limit for this match */
var databinding int TimeLimit;

/** Replicated list of teams participating in this match */
var databinding array<TeamInfo > Teams;

/** Name of the server, i.e.: Bob's Server. */
var() databinding globalconfig string ServerName;		

/** Match winner.  Set by gameinfo when game ends */
var Actor Winner;			

/** Array of all PlayerReplicationInfos, maintained on both server and clients (PRIs are always relevant) */
var		array<PlayerReplicationInfo> PRIArray;

/** This list mirrors the GameInfo's list of inactive PRI objects */
var		array<PlayerReplicationInfo> InactivePRIArray;

cpptext
{
	// AActor interface.
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	
	/**
	 * Builds a list of components that are hidden for scene capture
	 *
	 * @param HiddenComponents the list to add to/remove from
	 */
	virtual void UpdateHiddenComponentsForSceneCapture(TSet<UPrimitiveComponent*>& HiddenComponents) {}
}

replication
{
	if ( bNetDirty )
		bStopCountDown, Winner, bMatchHasBegun, bMatchIsOver;

	if ( !bNetInitial && bNetDirty )
		RemainingMinute;

	if ( bNetInitial )
		GameClass, RemainingTime, ElapsedTime, GoalScore, TimeLimit, ServerName;
}


simulated event PostBeginPlay()
{
	local PlayerReplicationInfo PRI;
	local TeamInfo TI;

	if( WorldInfo.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank
		ServerName = "";
	}

	SetTimer(WorldInfo.TimeDilation, true);

	WorldInfo.GRI = self;

	// associate this GRI with the "CurrentGame" data store
	InitializeGameDataStore();

	ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
	{
		AddPRI(PRI);
	}
	foreach DynamicActors(class'TeamInfo', TI)
	{
		if (TI.TeamIndex >= 0)
		{
			SetTeam(TI.TeamIndex, TI);
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bMatchHasBegun' )
	{
		if (bMatchHasBegun)
		{
			WorldInfo.NotifyMatchStarted();
		}
	}
	else if ( VarName == 'bMatchIsOver' )
	{
		if ( bMatchIsOver )
		{
			EndGame();
		}
	}
	else if ( VarName == 'GameClass' )
	{
		ReceivedGameClass();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}


/** Called when the GameClass property is set (at startup for the server, after the variable has been replicated on clients) */
simulated function ReceivedGameClass();

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Winner = None;
}

/**
 * Called when this actor is destroyed
 */
simulated event Destroyed()
{
	Super.Destroyed();

	// de-associate this GRI with the "CurrentGame" data store
	CleanupGameDataStore();
}

simulated event Timer()
{
	if ( (WorldInfo.Game == None) || WorldInfo.Game.MatchIsInProgress() )
	{
		ElapsedTime++;
	}
	if ( WorldInfo.NetMode == NM_Client )
	{
		// sync remaining time with server once a minute
		if ( RemainingMinute != 0 )
		{
			RemainingTime = RemainingMinute;
			RemainingMinute = 0;
		}
	}
	if ( (RemainingTime > 0) && !bStopCountDown )
	{
		RemainingTime--;
		if ( WorldInfo.NetMode != NM_Client )
		{
			if ( RemainingTime % 60 == 0 )
			{
				RemainingMinute = RemainingTime;
			}
		}
	}

	if ( CurrentGameData != None )
	{
		// give the current game data store a chance to update its state
		CurrentGameData.Timer();
	}

	SetTimer(WorldInfo.TimeDilation, true);
}

/**
 * Checks to see if two actors are on the same team.
 *
 * @return	true if they are, false if they aren't
 */
simulated native function bool OnSameTeam(Actor A, Actor B);


simulated function AddPRI(PlayerReplicationInfo PRI)
{
	local int i;

	// Determine whether it should go in the active or inactive list
	if (!PRI.bIsInactive)
	{
		// make sure no duplicates
		for (i=0; i<PRIArray.Length; i++)
		{
			if (PRIArray[i] == PRI)
				return;
		}

		PRIArray[PRIArray.Length] = PRI;
	}
	else
	{
		// Add once only
		if (InactivePRIArray.Find(PRI) == INDEX_NONE)
		{
			InactivePRIArray[InactivePRIArray.Length] = PRI;
		}
	}

    if ( CurrentGameData == None )
    {
    	InitializeGameDataStore();
    }

	if ( CurrentGameData != None )
	{
		CurrentGameData.AddPlayerDataProvider(PRI);
	}
}

simulated function RemovePRI(PlayerReplicationInfo PRI)
{
    local int i;

    for (i=0; i<PRIArray.Length; i++)
    {
		if (PRIArray[i] == PRI)
		{
			if ( CurrentGameData != None )
			{
				CurrentGameData.RemovePlayerDataProvider(PRI);
			}

		    PRIArray.Remove(i,1);
			return;
		}
    }
}

/**
 * Assigns the specified TeamInfo to the location specified.
 *
 * @param	Index	location in the Teams array to place the new TeamInfo.
 * @param	TI		the TeamInfo to assign
 */
simulated function SetTeam( int Index, TeamInfo TI )
{
	//`log(GetFuncName()@`showvar(Index)@`showvar(TI));
	if ( Index >= 0 )
	{
		if ( CurrentGameData == None )
		{
    		InitializeGameDataStore();
		}

		if ( CurrentGameData != None )
		{
			if ( Index < Teams.Length && Teams[Index] != None )
			{
				// team is being replaced with another instance - see HandleSeamlessTravelPlayer
				CurrentGameData.RemoveTeamDataProvider( Teams[Index] );
			}

			if ( TI != None )
			{
				CurrentGameData.AddTeamDataProvider(TI);
			}
		}

		Teams[Index] = TI;
	}
}

/**
  * returns true if P1 should be sorted before P2
  */
simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	local LocalPlayer LP1, LP2;

	// spectators are sorted last
    if( P1.bOnlySpectator )
    {
		return P2.bOnlySpectator;
    }
    else if ( P2.bOnlySpectator )
	{
		return true;
	}

	// sort by Score
    if( P1.Score < P2.Score )
	{
		return false;
	}
    if( P1.Score == P2.Score )
    {
		// if score tied, use deaths to sort
		if ( P1.Deaths > P2.Deaths )
			return false;

		// keep local player highest on list
		if ( (P1.Deaths == P2.Deaths) && (PlayerController(P2.Owner) != None) )
		{
			LP2 = LocalPlayer(PlayerController(P2.Owner).Player);
			if ( LP2 != None )
			{
				if ( !class'Engine'.static.IsSplitScreen() || (LP2.ViewportClient.Outer.GamePlayers[0] == LP2) )
				{
					return false;
				}
				// make sure ordering is consistent for splitscreen players
				LP1 = LocalPlayer(PlayerController(P2.Owner).Player);
				return ( LP1 != None );
			}
		}
	}
    return true;
}

simulated function SortPRIArray()
{
    local int i, j;
    local PlayerReplicationInfo P1, P2;

    for (i=0; i<PRIArray.Length-1; i++)
    {
    	P1 = PRIArray[i];
		for (j=i+1; j<PRIArray.Length; j++)
		{
			P2 = PRIArray[j];
		    if( !InOrder( P1, P2 ) )
		    {
				PRIArray[i] = P2;
				PRIArray[j] = P1;
				P1 = P2;
		    }
		}
    }
}


/**
 * Called when a variable is replicated that has the 'databinding' keyword.
 *
 * @param	VarName		the name of the variable that was replicated.
 */
simulated event ReplicatedDataBinding( name VarName )
{
	Super.ReplicatedDataBinding(VarName);

	if ( CurrentGameData != None )
	{
		CurrentGameData.RefreshSubscribers(VarName, true, CurrentGameData);
	}
}

/**
 * Creates and registers a data store for the current game session.
 */
simulated function InitializeGameDataStore()
{
	local DataStoreClient DataStoreManager;

	DataStoreManager = class'UIInteraction'.static.GetDataStoreClient();
	if ( DataStoreManager != None )
	{
		CurrentGameData = CurrentGameDataStore(DataStoreManager.FindDataStore('CurrentGame'));
		if ( CurrentGameData != None )
		{
			CurrentGameData.CreateGameDataProvider(Self);
		}
		else
		{
			`log("Primary game data store not found!");
		}
	}
}

/**
 * Unregisters the data store for the current game session.
 */
simulated function CleanupGameDataStore()
{
	`log(`location,,'DataStore');
	if ( CurrentGameData != None )
	{
		CurrentGameData.ClearDataProviders();
	}

	CurrentGameData = None;
}

/**
 * Called on the server when the match has begin
 *
 * Network - Server and Client (Via ReplicatedEvent)
 */

simulated function StartMatch()
{
	bMatchHasBegun = true;
}

/**
 * Called on the server when the match is over
 *
 * Network - Server and Client (Via ReplicatedEvent)
 */

simulated function EndGame()
{
	bMatchIsOver = true;
}

/** Is the current gametype a multiplayer game? */
simulated function bool IsMultiplayerGame()
{
	return (WorldInfo.NetMode != NM_Standalone);
}

/** Is the current gametype a coop multiplayer game? */
simulated function bool IsCoopMultiplayerGame()
{
	return FALSE;
}

/** Should players show gore? */
simulated event bool ShouldShowGore()
{
	return TRUE;
}

defaultproperties
{
	TickGroup=TG_DuringAsyncWork

	bStopCountDown=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
