/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*
*  Manages adding appropriate crowd population around player
*  Agents will be spawned/recycled at any available active GameCrowdDestination
*
*/
class GameCrowdPopulationManager extends CrowdPopulationManagerBase
	implements(Interface_NavigationHandle)
	implements(GameCrowdSpawnerInterface)
	dependson(SeqAct_GameCrowdSpawner)
	native;

/** Controls whether we are actively spawning agents. */
var	bool	bSpawningActive;

/** How many agents per second will be spawned at the target actor(s).  */
var	float	SpawnRate;

/** The maximum number of agents alive at one time. If agents are destroyed, more will spawn to meet this number. */
var	int		SpawnNum;

/** How much to reduce number by in splitscreen */
var	float	SplitScreenNumReduction;

/** Used by spawning code to accumulate partial spawning */
var	float	Remainder;

/** Sum of agent types + frequency modifiers */
var float AgentFrequencySum;

/** Archetypes of agents spawned by this crowd spawner */
var array<AgentArchetypeInfo>	AgentArchetypes;

/** Pool of agents available for re-use:  these are agents close to being removed */
var array<GameCrowdAgent> AgentPool;

/** Maximum size of agent pool */
var int MaxAgentPoolSize;

/** Number of currently spawned crowd members. */
var int AgentCount;

/** Lighting channels to put the agents in. */
var LightingChannelContainer	AgentLightingChannel;

/** Whether to enable the light environment on crowd members. */
var bool	bEnableCrowdLightEnvironment;

/** Whether agents from this spawner should cast shadows */
var   bool    bCastShadows;

/** If true, force obstacle checking for all agents from this spawner */
var bool bForceObstacleChecking;

/** If true, force nav mesh navigation for all agents from this spawner */
var bool bForceNavMeshPathing;

/** Average time to "warm up" spawned agents before letting them sleep if not rendered */
var float AgentWarmupTime;

/** How frequently to reprioritize GameCrowdDestinations as potential spawn points */
var float SpawnPrioritizationInterval;

/** Index into prioritization array for picking spawn points, incremented as agents are spawned at each point */
var int PrioritizationIndex;

/** Index into prioritization array for updating prioritization*/
var int PrioritizationUpdateIndex;

/** Ordered array of prioritized spawn GameCrowdDestinations */
var array<GameCrowdDestination>  PrioritizedSpawnPoints;

/** How far ahead to compute predicted player position for spawn prioritization */
var float PlayerPositionPredictionTime;

/** List of all GameCrowdDestinations that are PotentialSpawnPoints */
var array<GameCrowdDestination> PotentialSpawnPoints;

/** Max distance allowed for spawns */
var float MaxSpawnDist;

/** Square of max distance allowed for spawns */
var float MaxSpawnDistSq;

/** Square of min distance allowed for in line of sight but out of view frustrum agent spawns */
var float MinBehindSpawnDistSq;

/** Agent spawning stats */
var int SpawnedCount, PoolCount, KilledCount;

/** Offset used to validate spawn by checking above spawn location to see if head/torso would be visible */
var float HeadVisibilityOffset;

/** flag set when first adding agents.  Extra fill on first tick */
var bool bHaveInitialPopulation;

/** How much population to add first tick */
var float InitialPopulationPct;

/** If true, and initial spawn positiong is not in player's line of sight, and agent is not part of a group,
  * agent will try to find an starting position at a random spot between the initial spawn positing and its initial destination
  * that isn't in the player's line of sight.
  */
var() bool bWarmupPosition;

/** Navigation Handle used by agents requesting pathing */
var     class<NavigationHandle>         NavigationHandleClass;
var     NavigationHandle                NavigationHandle;

/** Agent requesting navigation handle use */
var GameCrowdAgent QueryingAgent;

cpptext
{
	virtual UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );

	/** Interface_NavigationHandle implementation to grab search params */
	virtual void SetupPathfindingParams( FNavMeshPathParams& out_ParamCache );
	virtual FVector GetEdgeZAdjust(FNavMeshEdgeBase* Edge);
}

function PostBeginPlay()
{
	local GameCrowdDestination GCD;

	Super.PostBeginPlay();

	if( class'Engine'.static.IsSplitScreen() )
	{
		SpawnNum = SplitScreenNumReduction * float(SpawnNum);
	}

	if ( !bDeleteMe )
	{
		WorldInfo.PopulationManager = self;
	}

	if( NavigationHandleClass != None )
	{
		NavigationHandle = new(self) NavigationHandleClass;
	}

	MaxSpawnDistSq = MaxSpawnDist * MaxSpawnDist;

	// add spawn points that have already begun play
	ForEach AllActors(class'GameCrowdDestination', GCD)
	{
		AddSpawnPoint(GCD);
	}
}

// Interface_navigationhandle stub - called when path edge is deleted that this controller is using
event NotifyPathChanged();

/** 
  * GameCrowdSpawnerInterface
  */
function float GetMaxSpawnDist()
{
	return MaxSpawnDist;
}

function AddSpawnPoint(GameCrowdDestination GCD)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;
	local int j;
	local bool bInsertedSpawnPoint;
	local vector ViewLocation, PredictionLocation;
	local rotator ViewRotation;
	local PlayerController PC;

	if ( GCD.MyPopMgr != None )
	{
		return;
	}
	GCD.MyPopMgr = self;

	if ( GCD.bAllowsSpawning )
	{
		PotentialSpawnPoints[PotentialSpawnPoints.Length] = GCD;

		ForEach LocalPlayerControllers(class'PlayerController', PC )
		{
			PC.GetPlayerViewPoint(ViewLocation, ViewRotation);
			PredictionLocation = ViewLocation + PlayerPositionPredictionTime * PC.ViewTarget.Velocity;
			break;
		}

		// Initial population (before first frame is rendered) fills in at visible spots
		GCD.bIsBeyondSpawnDistance = (FMin(VSizeSq(ViewLocation - GCD.Location), VSizeSq(PredictionLocation - GCD.Location)) > MaxSpawnDistSq);
		GCD.bCanSpawnHereNow = GCD.bIsEnabled && GCD.bAllowsSpawning && !GCD.bIsBeyondSpawnDistance;
		GCD.bIsVisible = true;
		if (GCD.bCanSpawnHereNow )
		{
			HitActor = Trace(HitLocation, HitNormal, GCD.Location, ViewLocation, false);
			if ( HitActor == None )
			{
				// Priority based on inverse of distance
				GCD.Priority = 1.0/VSizeSq(GCD.Location - ViewLocation);

				// insert GCD into prioritized list
				bInsertedSpawnPoint = false;
				for ( j=0; j<PrioritizedSpawnPoints.Length; j++ )
				{
					if ( PrioritizedSpawnPoints[j].Priority < GCD.Priority )
					{
						PrioritizedSpawnPoints.Insert(j, 1);
						PrioritizedSpawnPoints[j] = GCD;
						bInsertedSpawnPoint = true;
						break;
					}
				}

				if ( !bInsertedSpawnPoint )
				{
					PrioritizedSpawnPoints[PrioritizedSpawnPoints.Length] = GCD;
				}
			}
		}
	}

	// what about fixing up links from previously loaded spawn points?

}

function RemoveSpawnPoint(GameCrowdDestination GCD)
{
	GCD.MyPopMgr = None;

	// remove from potential spawnpoints and prioritized spawn points list
	// also remove agents moving toward unloaded spawn point
}

function OnGameCrowdPopulationManagerToggle( SeqAct_GameCrowdPopulationManagerToggle inAction)
{
	local int i;

	if( inAction.InputLinks[0].bHasImpulse )
	{
		bSpawningActive = TRUE;
		if ( inAction.WarmupPct > 0.0 )
		{
			InitialPopulationPct = FMax(0.0, inAction.WarmupPct - AgentCount/SpawnNum);
			bHaveInitialPopulation = false;
		}

		// if wanted, clear out current list of agent archetypes
		if ( inAction.bClearOldArchetypes )
		{
			AgentArchetypes.Length = 0;
		}

		if ( inAction.CrowdAgentList != None )
		{
			// get new agent archetypes to use from kismet action
			for (i=0; i<inAction.CrowdAgentList.ListOfAgents.Length; i++ )
			{
				AgentArchetypes[AgentArchetypes.Length] = inAction.CrowdAgentList.ListOfAgents[i];
			}
		}
		MaxSpawnDist = inAction.MaxSimulationDistance;
		MaxSpawnDistSq = MaxSpawnDist * MaxSpawnDist;
		MinBehindSpawnDistSq = MaxSpawnDistSq * 0.0625;
		bCastShadows = inAction.bCastShadows;
		bEnableCrowdLightEnvironment = inAction.bEnableCrowdLightEnvironment;
		SpawnRate = inAction.SpawnRate;
		SpawnNum = inAction.MaxAgents;
	}
	else if( inAction.InputLinks[1].bHasImpulse )
	{
		bSpawningActive = FALSE;
		if ( inAction.bKillAgentsInstantly )
		{
			FlushAgents();
		}
	}
}

/** Instantly destroy all active agents controlled by this manager. Useful for debugging.  */
function FlushAgents()
{
	local GameCrowdAgent Agent;
	
	ForEach DynamicActors(class'GameCrowdAgent', Agent)
	{
		if ( Agent.MySpawner == GameCrowdSpawnerInterface(self) )
		{
			Agent.Destroy();
		}
	}
}

function AgentDestroyed(GameCrowdAgent Agent)
{
	local int i;

	// now modify the CurrSpawned amount for this archetype since we just destroyed one
	for ( i=0; i<AgentArchetypes.length; i++ )
	{
		if ( GameCrowdAgent(AgentArchetypes[i].AgentArchetype) == Agent.MyArchetype )
		{
			AgentArchetypes[i].CurrSpawned--;
			//`log( GetFuncName() @ `showvar(AgentArchetypes[i].AgentArchetype) @ `showvar(AgentArchetypes[i].CurrSpawned) );
		}
	}

	AgentCount--;
}

function bool AddToAgentPool(GameCrowdAgent Agent)
{
	if ( AgentPool.Length >= MaxAgentPoolSize )
	{
		if ( MaxAgentPoolSize == 0 )
		{
			return false;
		}

		//remove oldest agent
		KilledCount++;
		AgentPool[0].LifeSpan = -0.1;
		AgentPool[0].TimeSinceLastTick = 1000.0;
		AgentPool.Remove(0, 1);
	}

	AgentPool[AgentPool.Length] = Agent;
	return true;
}

/**
  *  Use 'GameDebug' console command to show this debug info
  *  Useful to show general debug info not tied to a particular concrete actor.
  */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local Canvas	Canvas;
	local int RenderedNum, LOSNum, SimNum, ActualCount, WTFNum, DistanceBucket[10], i;
	local Actor HitActor;
	local vector HitNormal, HitLocation, ViewLocation;
	local rotator ViewRotation;
	local PlayerController PC;
	local GameCrowdAgent GCD;
	local float Dist;

	Canvas = HUD.Canvas;
	Canvas.SetDrawColor(255,255,255);

	Canvas.SetPos(4,out_YPos);
	Canvas.DrawText("---- GameCrowdPopulationManager ---");
	out_YPos += out_YL;

	Canvas.DrawText("SpawnedList "$AgentCount$" out of "$SpawnNum );
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);

	ForEach LocalPlayerControllers(class'PlayerController', PC )
	{
		// FIXME - doesn't handle predicting position for two local players (splitscreen)
		PC.GetPlayerViewPoint(ViewLocation, ViewRotation);
		break;
	}

	// calculate number of agents being rendered, simulated, and in player's LOS
	ForEach DynamicActors(class'GameCrowdAgent', GCD)
	{
		if( (GCD.MySpawner == self) )
		{
			ActualCount++;
			if ( GCD.Health > 0 )
			{
				if ( GCD.bSimulateThisTick )
				{
					SimNum++;
				}
				if ( (WorldInfo.TimeSeconds - GCD.LastRenderTime < 1.0) && (GCD.LastRenderTime != GCD.InitialLastRenderTime) )
				{
					RenderedNum++;
					LOSNum++;
				}
				else
				{
					HitActor = PC.Trace(HitLocation, HitNormal, GCD.Location, ViewLocation, false);
					if ( HitActor == None )
					{
						LOSNum++;
					}
					else if ( (GCD.CurrentDestination == None) || (!GCD.CurrentDestination.bIsVisible && !GCD.CurrentDestination.bWillBeVisible) )
					{
						WTFNum++;
					}
				}
			}
			Dist = VSize(ViewLocation - GCD.Location);
			DistanceBucket[Min(9, int(5.0*Dist/MaxSpawnDist))]++;
		}
	}

	if ( ActualCount != AgentCount )
	{
		Canvas.DrawText("WARNING:  ActualCount "$ActualCount$" does not match AgentCount "$AgentCount);
		out_YPos += out_YL;
		Canvas.SetPos(4,out_YPos);
	}
	Canvas.DrawText("Spawned "$SpawnedCount$" recycled "$PoolCount$" Killed from pool "$KilledCount );
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);

	Canvas.DrawText("Agents Rendered "$RenderedNum$" in LOS "$LOSNum$" Simulated this tick "$SimNum$" Not useful "$WTFNum );
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);

	Canvas.DrawText("Distance Buckets");
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);
	for ( i=0; i<9; i++ )
	{
		Canvas.DrawText(" (<"$(0.2*MaxSpawnDist * (i+1))$")"$DistanceBucket[i]);
		out_YPos += out_YL;
		Canvas.SetPos(4,out_YPos);
	}

}

/**
  * FIXMESTEVE - Nativize?
  */
function Tick(float DeltaSeconds)
{
	local GameCrowdDestination PickedSpawnPoint;
	local float CurrentSpawnRate;
	local bool bSpawnedAgent;

	// If crowds disabled - keep active but don't spawn any crowd members
	// also if active but too many agents out - keep active
	if( !bSpawningActive || (AgentCount >= SpawnNum) )
	{
		return;
	}

	// spawnrate depends on number of agents missing
	CurrentSpawnRate = SpawnRate;

	Remainder += (FMin(DeltaSeconds, 0.05) * CurrentSpawnRate);
	if ( !bHaveInitialPopulation )
	{
		// on first tick, fill population faster
		Remainder = FMax(Remainder, InitialPopulationPct*SpawnNum);
	}
	// Prioritize based on potential visibility and recently spawned agents 
	PrioritizeSpawnPoints(DeltaSeconds);

	if ( Remainder > 1.f )
	{
		// Spawn new agents for this tick
		while(Remainder > 1.f && AgentCount < SpawnNum)
		{
			PickedSpawnPoint = PickSpawnPoint();
			if ( PickedSpawnPoint != None )
			{
				PickedSpawnPoint.LastSpawnTime = WorldInfo.TimeSeconds;
				SpawnAgent(PickedSpawnPoint);
				Remainder -= 1.f;
				bSpawnedAgent = true;
			}
			else
			{
				Remainder = 0.0;
			}
		}
		bHaveInitialPopulation = bHaveInitialPopulation || bSpawnedAgent;
	}
}

/**
  * @RETURN best spawn point to spawn next crowd agent
  */
function GameCrowdDestination PickSpawnPoint()
{
	local int StartingIndex;
	local GameCrowdDestination Candidate;

	// Go down prioritized list, make sure currently valid (still not visible if not prioritize frame)
	StartingIndex = Min(PrioritizationIndex, PrioritizedSpawnPoints.Length);
	while ( PrioritizationIndex < PrioritizedSpawnPoints.Length )
	{
		Candidate = PrioritizedSpawnPoints[PrioritizationIndex];
		PrioritizationIndex++;
		if ( ValidateSpawnAt(Candidate) )
		{
			return Candidate;
		}
	}

	// failed to find suitable candidate at end of list.  Wrap around and check at start
	PrioritizationIndex = 0;
	while ( PrioritizationIndex < StartingIndex )
	{
		Candidate = PrioritizedSpawnPoints[PrioritizationIndex];
		PrioritizationIndex++;
		if ( ValidateSpawnAt(Candidate) )
		{
			return Candidate;
		}
	}
	return None;
}

/**
  *  Prioritize GameCrowdDestinations as potential spawn points
  */
function PrioritizeSpawnPoints(float DeltaSeconds)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, ViewLocation, PredictionLocation;
	local PlayerController PC;
	local int UpdateNum;
	local rotator ViewRotation;


	// look for spawn points which are either one link away from a visible GameCrowdDestination, or which will be visible in PlayerPositionPredictionTime
	ForEach LocalPlayerControllers(class'PlayerController', PC )
	{
		// FIXME - doesn't handle predicting position for two local players (splitscreen)
		PC.GetPlayerViewPoint(ViewLocation, ViewRotation);
		PredictionLocation = ViewLocation + PlayerPositionPredictionTime * PC.ViewTarget.Velocity;
		break;
	}

	// FIXME - Bail if we have no local player controllers (i.e. on a dedicated server)
	if( (PC == None) || (PotentialSpawnPoints.Length == 0) )
	{
		return;
	}
	
	// clamp predicted camera position inside world geometry
	HitActor = PC.Trace(HitLocation, HitNormal, PredictionLocation, ViewLocation, false);
	if ( HitActor != None )
	{
		PredictionLocation = (7.0*HitLocation + 3.0*ViewLocation)/10.0;
	}

	// calculate number of potential spawn points to prioritize this tick
	UpdateNum = Max(1, DeltaSeconds * float(PotentialSpawnPoints.Length)/SpawnPrioritizationInterval);

	// FIXMESTEVE - use physics asynch line checks for this?

	// analyze and prioritize a number of spawn points
	if ( PrioritizationUpdateIndex + UpdateNum >= PotentialSpawnPoints.Length )
	{
		// analyze end of list and wrap around
		AnalyzeSpawnPoints(PrioritizationUpdateIndex, PotentialSpawnPoints.Length, ViewLocation, PredictionLocation);
		UpdateNum = Max(0, UpdateNum - (PotentialSpawnPoints.Length - PrioritizationUpdateIndex));
		PrioritizationUpdateIndex = 0;
		
	}
	AnalyzeSpawnPoints(PrioritizationUpdateIndex, Min(PotentialSpawnPoints.Length, PrioritizationUpdateIndex + UpdateNum), ViewLocation, PredictionLocation); 
	PrioritizationUpdateIndex += UpdateNum;
}

function AnalyzeSpawnPoints(int StartIndex, int StopIndex, vector ViewLocation, vector PredictionLocation)
{
	local Actor HitActor;
	local int i, j;
	local GameCrowdDestination GCD, NextGCD;
	local vector HitLocation, HitNormal;

	if ( StartIndex >= PotentialSpawnPoints.Length )
	{
		return;
	}

	// determine potential visibility of all GameCrowdDestinations
	for ( i=StartIndex; i<Min(StopIndex,PotentialSpawnPoints.Length); i++ )
	{
		GCD = PotentialSpawnPoints[i];
		if (GCD == None)
		{
			PotentialSpawnPoints.Remove(i--,1);
			continue;
		}
		GCD.bIsVisible = true;
		GCD.bAdjacentToVisibleNode = false;
		GCD.bWillBeVisible = false;
		GCD.Priority = 0.0;
		GCD.bIsBeyondSpawnDistance = (FMin(VSizeSq(ViewLocation - GCD.Location), VSizeSq(PredictionLocation - GCD.Location)) > MaxSpawnDistSq);
		GCD.bCanSpawnHereNow = false;
		GCD.bHasNavigationMesh = true;
		if ( GCD.bIsEnabled && GCD.bAllowsSpawning )
		{
			if ( bForceNavMeshPathing && NavigationHandle.LineCheck(GCD.Location, GCD.Location - vect(0,0,3)*GCD.CylinderComponent.CollisionHeight, vect(0,0,0)) )
			{
				// no nav mesh streamed in, so can't use for spawning
				GCD.bHasNavigationMesh = false;
			}
			else if ( !GCD.bIsBeyondSpawnDistance )
			{
				GCD.bCanSpawnHereNow = true;
				HitActor = Trace(HitLocation, HitNormal, GCD.Location, ViewLocation, false);
				if ( HitActor != None )
				{
					GCD.bIsVisible = false;
					HitActor = Trace(HitLocation, HitNormal, GCD.Location, PredictionLocation, false);
					if ( HitActor == None )
					{
						GCD.bWillBeVisible = true;
					}
				}
			}
			else
			{
				// Allow spawning at destinations beyond the max spawn dist if connected to visible destinations inside the spawn dist
				for ( j=0; j<GCD.NextDestinations.Length; j++ )
				{
					NextGCD = GCD.NextDestinations[j];
					if ( (NextGCD != None) && NextGCD.bIsVisible && NextGCD.bCanSpawnHereNow && !NextGCD.bIsBeyondSpawnDistance )
					{
						GCD.bAdjacentToVisibleNode = true;
						GCD.bCanSpawnHereNow = true;
						GCD.bIsVisible = false; // pretend, so that we can spawn guys at long range
					}
				}
			}
		}
	}

	// Prioritize potential spawn points - remove from current position, add at new
	for ( i=StartIndex; i<StopIndex; i++ )
	{
		GCD = PotentialSpawnPoints[i];
		PrioritizedSpawnPoints.RemoveItem(GCD);

		// add GCD back to list if is potential spawn point
		if ( !GCD.bIsVisible && GCD.bCanSpawnHereNow )
		{
			if ( GCD.bWillBeVisible || GCD.bAdjacentToVisibleNode )
			{
				AddPrioritizedSpawnPoint(GCD, ViewLocation);
			}
			else
			{
				// check if neighbor visible
				for ( j=0; j<GCD.NextDestinations.Length; j++ )
				{
					if ( (GCD.NextDestinations[j] != None) && GCD.NextDestinations[j].bCanSpawnHereNow && GCD.NextDestinations[j].bIsVisible )
					{
						AddPrioritizedSpawnPoint(GCD, ViewLocation);
						break;
					}
				}
			}
		}
	}
}

/**
  * Prioritize passed in GameCrowdDestination and insert it into ordered PrioritizedSpawnPoints list, offset from current starting point
  */
function AddPrioritizedSpawnPoint(GameCrowdDestination GCD, vector ViewLocation)
{
	local int i;
	
	// Priority based on inverse of distance
	GCD.Priority = 1.0/VSize(GCD.Location - ViewLocation);

	// prefer destinations that are about to become visible
	if ( GCD.bWillBeVisible )
	{
		GCD.Priority *= 10.0;
	}

	// prefer destinations that haven't been used recently
	GCD.Priority *= FMin(WorldInfo.TimeSeconds - GCD.LastSpawnTime, 10.0);
	PrioritizationIndex = Min(PrioritizationIndex, PrioritizedSpawnPoints.Length);

	// insert GCD into prioritized list
	for ( i=PrioritizationIndex; i<PrioritizedSpawnPoints.Length; i++ )
	{
		if ( PrioritizedSpawnPoints[i].Priority < GCD.Priority )
		{
			PrioritizedSpawnPoints.Insert(i, 1);
			PrioritizedSpawnPoints[i] = GCD;
			return;
		}
	}

	for ( i=0; i<PrioritizationIndex; i++ )
	{
		if ( PrioritizedSpawnPoints[i].Priority < GCD.Priority )
		{
			PrioritizedSpawnPoints.Insert(i, 1);
			PrioritizedSpawnPoints[i] = GCD;
			return;
		}
	}

	// add right at current index (and increment index since this one should be last
	PrioritizedSpawnPoints.Insert(PrioritizationIndex, 1);
	PrioritizedSpawnPoints[PrioritizationIndex] = GCD;
	PrioritizationIndex++;
	if ( PrioritizationIndex >= PrioritizedSpawnPoints.Length )
	{
		PrioritizationIndex = 0;
	}
}

/**
  *  Determine whether candidate spawn point is currently valid
  */
function bool ValidateSpawnAt(GameCrowdDestination Candidate)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, ViewLocation;
	local rotator ViewRotation;
	local PlayerController PC;
	local float DistSq;

	// make sure candidate not at capacity
	if ( Candidate.AtCapacity() || !Candidate.bIsEnabled || !Candidate.bAllowsSpawning )
	{
		return false;
	}

	// check that spawn point is not visible to player
	if ( bHaveInitialPopulation )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC )
		{
			PC.GetPlayerViewPoint(ViewLocation, ViewRotation);

			// if candidate is beyond max (normal) spawn dist, it's a special case and we don't mind if it is visible
			// also don't mind if far away and not in view frustrum
			DistSq = VSizeSq(Candidate.Location - ViewLocation);
			if ( (DistSq < MaxSpawnDistSq) 
				&& ((DistSq <MinBehindSpawnDistSq) || ((Normal(Candidate.Location - ViewLocation) dot vector(ViewRotation)) > 0.7)) )
			{
				HitActor = PC.Trace(HitLocation, HitNormal, Candidate.Location + HeadVisibilityOffset*vect(0,0,1), ViewLocation, false,,, TRACEFLAG_Bullet);  
				if ( HitActor == None )
				{
					// FIXMESTEVE - remove from list???
					//`log("FAILED VALIDATE SPAWN AT "$Candidate$" Time "$WorldInfo.TimeSeconds);
					return false;
				}
			}
		}
	}
	return true;
}

/** 
  *  Actually create a new CrowdAgent actor, and initialise it 
  */
event GameCrowdAgent SpawnAgent(GameCrowdDestination SpawnLoc)
{
	local GameCrowdAgent	Agent;
	local float AgentPickValue, PickSum;
	local int i, PickedInfo;
	local GameCrowdAgent AgentTemplate;
	local GameCrowdGroup NewGroup;

	// pick agent class
	if ( AgentFrequencySum == 0.0 )
	{
		// make sure initialized
		for ( i=0; i<AgentArchetypes.length; i++ )
		{
			if ( GameCrowdAgent(AgentArchetypes[i].AgentArchetype) != None )
			{
				AgentFrequencySum = AgentFrequencySum + FMax(0.0,AgentArchetypes[i].FrequencyModifier);
			}
		}
	}

	AgentPickValue = AgentFrequencySum * FRand();
	PickedInfo = -1;
	for ( i=0; i<AgentArchetypes.Length; i++ )
	{
		AgentTemplate = GameCrowdAgent(AgentArchetypes[i].AgentArchetype);
		if ( AgentTemplate != None )
		{
			// here we can check this here and have a max allowed
			//`log( GetFuncName() @ `showvar(AgentArchetypes[i].CurrSpawned) @ `showvar(AgentArchetypes[i].GroupMembers.Length) );
			// native struct properties don't get properly propagated so we need to hack this in.
			if( ( AgentArchetypes[i].CurrSpawned < AgentArchetypes[i].MaxAllowed ) || ( AgentArchetypes[i].MaxAllowed == 0 ) )
			{
				PickSum = PickSum + FMax(0.0,AgentArchetypes[i].FrequencyModifier);

				if ( PickSum > AgentPickValue )
				{
					PickedInfo = i;
					break;
				}
			}
		} 
	}	

	if ( PickedInfo == -1 )
	{
		// failed to find valid archetype
		return None;
	}

	if ( AgentArchetypes[PickedInfo].GroupMembers.Length > 0 )
	{
		NewGroup = New(None) class'GameCrowdGroup';
	}

	Agent = CreateNewAgent(SpawnLoc, AgentTemplate, NewGroup);

	// spawn other agents in group
	for ( i=0; i<AgentArchetypes[PickedInfo].GroupMembers.Length; i++ )
	{
		if ( GameCrowdAgent(AgentArchetypes[PickedInfo].GroupMembers[i]) != None )
		{
			CreateNewAgent(SpawnLoc, GameCrowdAgent(AgentArchetypes[PickedInfo].GroupMembers[i]), NewGroup);
		}
	}
	return Agent;
}

	
/**
  * Create new GameCrowdAgent and initialize it
  */
function GameCrowdAgent CreateNewAgent(GameCrowdDestination SpawnLoc, GameCrowdAgent AgentTemplate, GameCrowdGroup NewGroup)
{
	local GameCrowdAgent	Agent;
	local GameCrowdAgentSkeletal SkAgent;
	local rotator	SpawnRot;
	local vector	SpawnPos;
	local int i;
	
	// GameCrowdSpawnInterface provides spawn location (can be line/circle/volume/etc. based)
	GameCrowdSpawnInterface(SpawnLoc).GetSpawnPosition(none, SpawnPos, SpawnRot);
	
	// try to find useable agent in the Agent Pool
	if ( AgentPool.Length > 0 )
	{
		// check for useable agent with same archetype in pool
		for ( i=0; i<AgentPool.Length; i++ )
		{
			if( ( AgentPool[i] != None ) && ( AgentPool[i].MyArchetype == AgentTemplate ) )
			{
				Agent = AgentPool[i];
				PoolCount++;
				AgentPool.Remove(i,1);
				break;
			}
		}
		if ( Agent != None )
		{
			Agent.SetLocation(SpawnPos);
			Agent.SetRotation(SpawnRot);
			Agent.ResetPooledAgent();
			Agent.InitializeAgent(SpawnLoc, AgentTemplate, NewGroup, AgentWarmUpTime*2.0*FRand(), bWarmupPosition, true);

			// limit max distance to keep agents around based on max simulation distance (with some leeway)
			Agent.MaxLOSLifeDistanceSq = 2.25 * MaxSpawnDistSq;
			Agent.VisibleProximityLODDist = FMin(Agent.VisibleProximityLODDist, MaxSpawnDist);
			Agent.ProximityLODDist = FMin(Agent.ProximityLODDist, Agent.VisibleProximityLODDist);

			// limit max animation distance to max spawn distance
			SKAgent = GameCrowdAgentSkeletal(Agent);
			if ( SKAgent != None )
			{
				SKAgent.MaxAnimationDistanceSq = FMin(SKAgent.MaxAnimationDistanceSq, MaxSpawnDistSq);
			}
			return Agent;
		}
	}

	Agent = Spawn( AgentTemplate.Class,,,SpawnPos,SpawnRot,AgentTemplate);
	SpawnedCount++;
	Agent.SetLighting(bEnableCrowdLightEnvironment, AgentLightingChannel, bCastShadows);

	if ( bForceObstacleChecking )
	{
		Agent.bCheckForObstacles = true;
	}
	
	if ( bForceNavMeshPathing )
	{
		Agent.bUseNavMeshPathing = true;
	}

	// don't prefer visible paths on spawn if on soon to be visible start
	if ( SpawnLoc.bWillBeVisible )
	{
		Agent.bPreferVisibleDestinationOnSpawn = Agent.bPreferVisibleDestination;
	}
	
	Agent.MySpawner = GameCrowdSpawnerInterface(self);
	Agent.InitializeAgent(SpawnLoc, AgentTemplate, NewGroup, AgentWarmUpTime*2.0*FRand(), bWarmupPosition, bHaveInitialPopulation);
	AgentCount++;

	// now find the archetype and update the CurrSpawned
	for ( i=0; i<AgentArchetypes.length; i++ )
	{
		if ( GameCrowdAgent(AgentArchetypes[i].AgentArchetype) == Agent.MyArchetype )
		{
			AgentArchetypes[i].CurrSpawned++;
		}
	}


	return Agent;
}

defaultproperties
{
	AgentLightingChannel=(Crowd=TRUE,bInitialized=TRUE)

	NavigationHandleClass=class'NavigationHandle'

	SpawnRate=50
	SpawnNum=700
	bSpawningActive=true

	SplitScreenNumReduction=0.5
	
	AgentWarmupTime=2.0

	SpawnPrioritizationInterval=0.4
	PlayerPositionPredictionTime=5.0

	MaxSpawnDist=20000.0
	MinBehindSpawnDistSq=25000000.0

	MaxAgentPoolSize=20

	HeadVisibilityOffset=40.0
	InitialPopulationPct=0.5
	bWarmupPosition=true

	RemoteRole=ROLE_None
	NetUpdateFrequency=10
	bHidden=TRUE
	bOnlyDirtyReplication=TRUE
	bSkipActorPropertyReplication=TRUE

	bForceNavMeshPathing=TRUE
}
