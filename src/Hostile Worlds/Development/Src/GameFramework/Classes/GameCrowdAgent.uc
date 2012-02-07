/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GameCrowdAgent extends CrowdAgentBase
	native
	abstract
	hidecategories(Advanced)
	hidecategories(Attachment)
	hidecategories(Collision)
	hidecategories(Object)
	placeable; // placeable only so LDs can create archetypes

/** Agent group this agent is part of */
var GameCrowdGroup MyGroup;

/** Velocity in the absence of other agent interactions */
var vector PreferredVelocity;

/** Share of avoidance by this agent type */
var float AvoidanceShare;

/** Current destination */
var GameCrowdDestination CurrentDestination;

/** Last destination where performed Kismet/Behavior.  Cleared when have new destination.  Used to keep from looping kismet/behavior at destination. */
var GameCrowdDestination BehaviorDestination;

/** where agent is coming from */
var GameCrowdDestination PreviousDestination;

/** Additional force applied to this crowd agent externally - zeroed each frame. */
var		vector	ExternalForce;

/** If conforming to ground, this is how much to move the agent each frame between line-trace updates. */
var		float	InterpZTranslation;

/** Current health of agent */
var()		int								Health;

/** How long dead body stays around */
var(Behavior)	float DeadBodyDuration;

/** Pointer to LightEnvironment */
var const editconst DynamicLightEnvironmentComponent LightEnvironment;

/** Used to count how many frames since the last conform trace. */
var		transient int	ConformTraceFrameCount;

/** Used to count how many frames since the last conform trace. */
var		transient int	AwareUpdateFrameCount;

/** Nearby pawns and agents.  Updated periodically (AwareUpdateInterval) using main Octree
FIXMESTEVE - do we need more than one array, and should we put other dynamic actors in it? */
var		transient array<Actor>	NearbyDynamics;

/** Updated by touch using main Octree */
var		transient array<GameCrowdForcePoint> RelevantAttractors;

/** Whether to use same scale variation in all axes */
var bool bUniformScale;

enum EConformType
{
	CFM_NavMesh,
	CFM_BSP,
	CFM_World,
	CFM_None,
};

/** How agent conforms to surfaces */
var(Movement)	EConformType	ConformType;

/** Whether to have obstacle mesh block agents */
var(Pathing) bool bCheckForObstacles;

/** How far to trace to conform agent to the bsp/world. */
var(Movement)	float	ConformTraceDist;

/** Every how many frames the ground conforming line check is done. */
var(Movement)	int		ConformTraceInterval;

/** Current conform interval */
var int CurrentConformTraceInterval;

/** TEMP for debugging - last ground conform hit normal Z*/
var float LastGroundZ;

// Agent force stuff
/** Controls how far around an agent the system looks when finding the average speed. */
var(Pathing)	float	AwareRadius;

/** Every how many frames the agents 'awareness' is updated (attractors and other agents */
var(Pathing)	int		AwareUpdateInterval;

/** How hard agents are pushed apart when they overlap. */
var(Pathing)	float	AvoidOtherStrength;

/** How hard agents are pushed away from player. */
var(Pathing)	float	AvoidPlayerStrength;

/** The radius used to check overlap between agents (basically how big an agent is). */
var(Pathing)	float	AvoidOtherRadius;

/** How hard group members pull together */
var(Pathing)	float	GroupAttractionStrength;

/** How aggressively an agent matches the speed of its neighbours. */
var(Pathing)	float	MatchVelStrength;

/** Agent acceleration along the path direction (towards  their target). */
var(Pathing)	float	FollowPathStrength;

/** If TRUE, use navmesh for pathing */
var(Pathing)	bool	bUseNavMeshPathing;

/** Agent velocity damping (friction). */
var(Movement)	float	VelocityDamping;

/** When a 'target' action occurs, agent will rotate to face the CrowdAttractor. This controls how fast that turn happens */
var(Movement)	float	RotateToTargetSpeed;

/** Crowd agents rotate to face the direction they are travelling. This value limits how quickly they turn to do this, to avoid them spinning too quickly */
var(Movement)	float	MaxYawRate;

/** Min 3D drawscale to apply to the agent mesh */
var(Rendering)	vector			MeshMinScale3D;

/** Max 3D drawscale to apply to the agent mesh */
var(Rendering)	vector			MeshMaxScale3D;

/** Note currently only checks if see player when being rendered */
var bool bWantsSeePlayerNotification;

/** Eye Z offset from location */
var float EyeZOffset;

/** Distance to LOD out proximity checks for non-visible agents */
var(LOD) float ProximityLODDist;

/** Distance to LOD out proximity checks for visible agents */
var(LOD) float VisibleProximityLODDist;

/** Last position validated by collision trace */
var vector LastKnownGoodPosition;

/** Distance from ground to agent center (used to adjust foot positioning) */
var(Rendering) float GroundOffset;

/** Current movement destination intermediate to reaching CurrentDestination */
var vector IntermediatePoint;

/** bounding box to use for pathing queries */
var vector SearchExtent;

// Whether agent is allowed to pitch as he rotates toward his current velocity
var(Movement) bool bAllowPitching;

/** Navigation Handle used by agents requesting pathing */
var     class<NavigationHandle>         NavigationHandleClass;
var     NavigationHandle                NavigationHandle;

/** flags set for debugging (set each tick) */
var bool bHitObstacle, bBadHitNormal;
var int ObstacleCheckCount;

/** Used for accessing potential obstacles - not an obstacle if hitnormal.Z > WalkableFloorZ */
var float WalkableFloorZ;

/** Last time pathing was attempted for this agent */
var float LastPathingAttempt;

/** Used to limit update frequency of agents that are not visible */
var float LastUpdateTime;

/** Whether to perform crowd simulation this tick on this agent ( updated using ShouldPerformCrowdSimulation() )*/
var bool bSimulateThisTick;

/** how long to wait before killing this agent when it isn't visible */
var(LOD) float NotVisibleLifeSpan;

/** Scaling factor for agent ticking when not visible */
var(LOD) float NotVisibleTickScalingFactor;

/** Archetype used to spawn this agent */
var GameCrowdAgent MyArchetype;

/** Whether to clamp movement speed */
var(Movement) bool bClampMovementSpeed;

/** Max walking speed (if not using root motion velocity)*/
var(Movement) float MaxWalkingSpeed;

/** Max running speed (if not using root motion velocity)*/
var(Movement) float MaxRunningSpeed;

/** Current max speed */
var float MaxSpeed;

struct native RecentInteraction
{
	var Name	InteractionTag;
	var float	InteractionDelay;
};
var array<RecentInteraction> RecentInteractions;

/** Max distance to draw debug beacon */
var float BeaconMaxDist;

/** Debug beacon offset from Location */
var vector BeaconOffset;

/** Background texture for debug beacon */
var const Texture2D BeaconTexture;

/** Beacon background color */
var const LinearColor BeaconColor;

/** Ambient Sound cue played by this agent */
var() soundcue AmbientSoundCue;

/** Ambient sound being played */
var AudioComponent AmbientSoundComponent;

/** Current applied behavior instance */
var GameCrowdAgentBehavior CurrentBehavior;

/** Describes a behavior type and its frequency */
struct native BehaviorEntry
{
	/** Archetype based on a GameCrowdAgentBehavior class */
	var() GameCrowdAgentBehavior BehaviorArchetype;
	
	/** How often this behavior is picked = BehaviorFrequency/(sum of BehaviorFrequencies) */
	var() float BehaviorFrequency;
	
	/** If true, agent will never repeat this behavior */
	var() bool bNeverRepeat;

	/** Whether this behavior has been used by this agent */
	var bool bHasBeenUsed;
	
	/** Temp Cache whether this behavior can be used */
	var bool bCanBeUsed;
	
	structdefaultproperties
	{
		BehaviorFrequency=1.0
	}
};

/** Behaviors to choose from when encounter another agent (only if no current behavior) */
var(Behavior) array<BehaviorEntry>  EncounterAgentBehaviors;

/** Set when updating dynamics if agent is potential encounter for updating agent - only valid in HandlePotentialAgentEncounter() event.*/
var bool bPotentialEncounter;

/** Behaviors to choose from when see player (only if no current behavior) */
var(Behavior) array<BehaviorEntry>  SeePlayerBehaviors;

/** Calculated from behaviors in SeePlayerList */
var float MaxSeePlayerDistSq;

/** How often see player event can be triggered.  If 0, never retriggers */
var(Behavior) float	SeePlayerInterval;

/** Behaviors to choose from when agent spawns. */
var(Behavior) array<BehaviorEntry> SpawnBehaviors;

/** Behaviors to choose from when agent panicks. */
var(Behavior) array<BehaviorEntry>  PanicBehaviors;

/** Behaviors to choose from randomly at RandomBehaviorInterval. */
var(Behavior) array<BehaviorEntry>  RandomBehaviors;

/** Average time between random behavior attempt (only if visible to player and no current behavior) */
var(Behavior) float RandomBehaviorInterval;

/** FIXMESTEVE - only used for animation now.  Need to replace with more appropriately named property */
var bool bIsPanicked;

/** World time when agent was spawned or last rendered */
var float ForceUpdateTime;

/** Random variation in how closely agent must reach destination (0.5 to 1.0)*/
var float ReachThreshold;

/** Whether should idle and wait for other group members */
var bool bWantsGroupIdle;

/** Behaviors to choose from when waiting for other group members. */
var(Behavior) array<BehaviorEntry>  GroupWaitingBehaviors;

/** Try to keep Members this close together - probably will be obsolete when have formations */
var(Behavior) float DesiredGroupRadius;

/** Keep square of DesiredGroupRadius for faster testing */
var float DesiredGroupRadiusSq;

/** If true, agent will prefer destinations with line of sight to player if starting from non-L.O.S. destination */
var() bool bPreferVisibleDestination;

/** If true, prefer visible destination only for first destination chosen after spawn */
var() bool bPreferVisibleDestinationOnSpawn;

/** Max distance to keep agents around if they haven't been rendered in NotVisibleLifeSpan, but are still in player's potential line of sight */
var float MaxLOSLifeDistanceSq;

/** Actor with GameCrowdSpawnerInterface which spawned this agent */
var GameCrowdSpawnerInterface MySpawner;

/** True if already notified spawner about destruction */
var bool bHasNotifiedSpawner;

/** true if agent is currently sitting in pop mgr's agent pool */
var bool bIsInSpawnPool;

/** Used for keeping groups spawned together */
var vector SpawnOffset;

/** Initial setting of LastRenderTime (used to see if agent was ever actually rendered) */
var float InitialLastRenderTime;

cpptext
{
	virtual void PreBeginPlay();
	virtual void PostScriptDestroyed();
	virtual void GetActorReferences(TArray<FActorReference*>& ActorRefs, UBOOL bIsRemovingLevel);

	virtual UBOOL Tick( FLOAT DeltaSeconds, ELevelTick TickType );

	virtual void performPhysics(FLOAT DeltaTime);
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive, AActor *SourceActor, DWORD TraceFlags);

	/** Update force based on closest path - will push towards path if too far away, or push along path if close enough */
	virtual FVector CalcPathForce();

	virtual void TickSpecial( FLOAT DeltaSeconds );

	/** Calculate forces acting between crowd members, that is repulsion between crowd members, and force to match flock velocity */
	FVector CalcIntraCrowdForce();

	/**
	 *	Check relevant attractors, find nearest 'target', and 'best' ECAM_MoveTarget attractor locations.
	 *	Returns repulsive force due to ECAM_Repulsor attractors.
	 */
	virtual FVector CheckRelevantAttractors();

	/**
	 *	If desired, take the current location, and using a line check, update its Z to match the ground better.
	 *	Returns FALSE if could not be conformed, and agent was killed.
	 */
	UBOOL UpdateInterpZTranslation(const FVector& NewLocation);

	/**
	 *	Update NearbyDynamics, RelevantAttractors
	 *	Also checks ReportOverlapsWithClass and calls OverlappedActorEvent if necessary
	 */
	void UpdateProximityInfo();

	virtual UBOOL WantsOverlapCheckWith(AActor* TestActor);

	/**
	 * This will allow subclasses to implement specialized behavior for whether or not to actually simulate.
	 * Example: You have hundreds of crowd agents and not all can be seen.  So doing a distance check before simulating them
	 *          could save CPU.  (distance check in stead of LastRender as you might want them moving before the viewer sees them).
	 **/
	virtual UBOOL ShouldPerformCrowdSimulation(FLOAT DeltaTime);

	/** Whether agent should end idling now */
	virtual UBOOL ShouldEndIdle();

	/** Check if reached intermediate point in route to destination */
	UBOOL ReachedIntermediatePoint();

	/** Clamp max velocity based on maxspeed or root motion*/
	virtual void ClampVelocity(FLOAT DeltaTime, const FVector& OldVelocity, const FVector& ObstacleForce, const FVector& TotalForce);

	/** Clamp velocity to reach destination exactly */
	virtual void ExactVelocity(FLOAT DeltaTime);

	/** Interface_NavigationHandle implementation to grab search params */
	virtual void SetupPathfindingParams( FNavMeshPathParams& out_ParamCache );
	virtual FVector GetEdgeZAdjust(FNavMeshEdgeBase* Edge);

    /** 
     * This function actually does the work for the GetDetailInfo and is virtual.  
     * It should only be called from GetDetailedInfo as GetDetailedInfo is safe to call on NULL object pointers
     **/
	virtual FString GetDetailedInfoInternal() const;
}

/** called when the actor falls out of the world 'safely' (below KillZ and such) */
simulated event FellOutOfWorld(class<DamageType> dmgType)
{
	Health = -1;
	Lifespan = -0.1;
}

/**
  * @RETURNS whether this agent is panicked (true if agent has a CurrentBehavior and CurrentBehavior.bIsPanicked==true
  */
native function bool IsPanicked();

event SetPanic(actor PanicActor, bool bNewPanic)
{
	if ( bNewPanic )
	{
		if ( !IsPanicked() )
		{
			PickBehaviorFrom(PanicBehaviors);
		}
		if( CurrentBehavior != none )
		{
			CurrentBehavior.ActivatedBy(PanicActor);
		}
	}
	else if ( IsPanicked() )
	{
		// stop panicking now
		StopBehavior();
	}
}

/**
  * Pick a behavior from the BehaviorList, for a camera at BestCameraLoc,
  * and activate this behavior
  * Caller is responsible for setting bHasBeenUsed on picked behavior entry.
  *
  * @RETURNS true if new behavior was activated
  */
function bool PickBehaviorFrom(array<BehaviorEntry> BehaviorList, optional vector BestCameraLoc=vect(0,0,0) )
{
	local vector CameraLoc;
	local rotator CameraRot;
	local PlayerController PC;
	local float BestDistSq, NewDistSq;
	local int i;
	local float FreqSum, RandPick;
		
	if ( BestCameraLoc == vect(0,0,0) )
	{
		// if camera location not passed in, find closest camera
		BestDistSq = 90000000.0;
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			PC.GetPlayerViewPoint(CameraLoc, CameraRot);
			NewDistSq = VSizeSq(CameraLoc - Location);
			if ( NewDistSq < BestDistSq )
			{
				BestDistSq = NewDistSq;
				BestCameraLoc = CameraLoc;
			}
		}
	}
		
	// Pick a behavior to activate
	for ( i=0; i<BehaviorList.length; i++ )
	{
		if ( BehaviorList[i].BehaviorArchetype == None )
		{
			`warn(self@MyArchetype$" No behavior archetype for behaviorentry "$i);
		}
		else
		{
			BehaviorList[i].bCanBeUsed = (!BehaviorList[i].bHasBeenUsed || !BehaviorList[i].bNeverRepeat) && BehaviorList[i].BehaviorArchetype.CanBeUsedBy(self, BestCameraLoc);
			if ( BehaviorList[i].bCanBeUsed )
			{
				FreqSum += BehaviorList[i].BehaviorFrequency;
			}
		}
	}
	
	// If frequency sum < 1.0, chance no behavior will be picked
	RandPick = FMax(1.0,FreqSum) * FRand();
	if ( RandPick >= FreqSum )
	{
		return false;
	}
	
	// Activate the selected behavior
	for ( i=0; i<BehaviorList.length; i++ )
	{
		if ( BehaviorList[i].bCanBeUsed )
		{
			RandPick -= BehaviorList[i].BehaviorFrequency;
			if ( RandPick < 0.0 )
			{
				ActivateBehavior(BehaviorList[i].BehaviorArchetype);
				BehaviorList[i].bHasBeenUsed = true;
				return true;
			}
		}
	}
	
	return false;
}

/** 
  *  Too far ahead of group, pick waiting behavior
  */
event WaitForGroupMembers()
{
	local int i;
	
	PickBehaviorFrom(GroupWaitingBehaviors);
	if ( CurrentBehavior != None )
	{
		CurrentBehavior.ActionTarget = MyGroup.Members[0]; 
		
		// look at agent being waited for
		for ( i=0; i<MyGroup.Members.Length; i++ )
		{
			if (MyGroup.Members[i] != None && !MyGroup.Members[i].bDeleteMe && (VSizeSq(MyGroup.Members[i].Location - Location) > DesiredGroupRadiusSq) 
				&& ((MyGroup.Members[i].Velocity dot (Location - MyGroup.Members[i].Location)) > 0.0))
			{
				CurrentBehavior.ActionTarget = MyGroup.Members[i]; 
				break;
			}
		}
	}
}

event SetCurrentDestination(GameCrowdDestination NewDest)
{
	if ( NewDest != CurrentDestination )
	{
		if ( CurrentBehavior != None )
		{
			CurrentBehavior.ChangingDestination(NewDest);
		}
		CurrentDestination = NewDest;
		CurrentDestination.IncrementCustomerCount(self);
		
		ReachThreshold = CurrentDestination.bSoftPerimeter ? 0.5 + 0.5*FRand() : 1.0;
	}
	if ( CurrentDestination.bFleeDestination && !IsPanicked() )
	{
		SetPanic(None, TRUE);
	}
}

/** Set maximum movement speed */
function SetMaxSpeed()
{
	MaxSpeed = IsPanicked()? MaxRunningSpeed : MaxWalkingSpeed;
}

simulated function PostBeginPlay()
{
	local vector AgentScale3D;
	local int i;
	local float MaxSeePlayerDist;

	super.PostBeginPlay();

	if ( bDeleteMe )
	{
		return;
	}

	// Randomize scale
	if( bUniformScale )
	{
		AgentScale3D = MeshMinScale3D + (FRand() * (MeshMaxScale3D - MeshMinScale3D));
	}
	else
	{
		AgentScale3D.X = RandRange(MeshMinScale3D.X, MeshMaxScale3D.X);
		AgentScale3D.Y = RandRange(MeshMinScale3D.Y, MeshMaxScale3D.Y);
		AgentScale3D.Z = RandRange(MeshMinScale3D.Z, MeshMaxScale3D.Z);
	}
	SetDrawScale3D(AgentScale3D);

	// assume starting point is valid
	LastKnownGoodPosition = Location;
	LastKnownGoodPosition.Z += EyeZOffset;

	ForceUpdateTime = WorldInfo.TimeSeconds;

	// init max speed
	SetMaxSpeed();
	
	// init ambient sound
	if ( AmbientSoundCue != None )
	{
		AmbientSoundComponent = new(self) class'AudioComponent';
		if( AmbientSoundComponent != none )
		{
			AttachComponent(AmbientSoundComponent);
			AmbientSoundComponent.SoundCue = AmbientSoundCue;
			AmbientSoundComponent.Play();
		}
	}
	
	// init see player notification
	bWantsSeePlayerNotification = (SeePlayerBehaviors.Length > 0);
	for ( i=0; i<SeePlayerBehaviors.Length; i++ )
	{
		MaxSeePlayerDist = FMax(MaxSeePlayerDist, SeePlayerBehaviors[i].BehaviorArchetype.MaxPlayerDistance);
	} 

	// init convenient/perf squares of agent properties
	MaxSeePlayerDistSq = MaxSeePlayerDist*MaxSeePlayerDist;
	DesiredGroupRadiusSq = DesiredGroupRadius * DesiredGroupRadius;
	
	if ( RandomBehaviors.Length > 0 )
	{
		settimer((0.8+0.4*FRand())*RandomBehaviorInterval, true, 'TryRandomBehavior');
	}
}

/**
  *  Kill this agent or add it to population manager's spawn pool
  */
event KillAgent()
{
	if ( bIsInSpawnPool )
	{
		return;
	}
	if ( (MySpawner != None) && MySpawner.AddToAgentPool(self) )
	{
		// added to pool, so turn agent off
		SetHidden(true);
		if ( CurrentDestination != None )
		{
			CurrentDestination.DecrementCustomerCount(self);
			CurrentDestination = None;
		}
		if ( MyGroup != None )
		{
			MyGroup.RemoveMember(self);
		}
		Health = -1; // to prevent ticking
		TimeSinceLastTick = -1000.0;
		ClearAllTimers();
		BehaviorDestination = None;
		PreviousDestination = None;
		LifeSpan = 0.0;
		StopBehavior();
	}
	else
	{
		LifeSpan = -0.1;

		// make sure to tick right away to destroy
		TimeSinceLastTick = 1000.0;
	}
}

/**
  *  Agent is coming out of pool, so rev him up
  */
function ResetPooledAgent()
{
	bIsInSpawnPool = false;
	SetHidden(false);
	BehaviorDestination = None;
	PreviousDestination = None;
	LifeSpan = 0.0;
	Health = default.Health;
	TimeSinceLastTick = 0.0;
	LastKnownGoodPosition = Location;
	LastKnownGoodPosition.Z += EyeZOffset;
	ForceUpdateTime = WorldInfo.TimeSeconds;
	SetMaxSpeed();
	if ( RandomBehaviors.Length > 0 )
	{
		settimer((0.8+0.4*FRand())*RandomBehaviorInterval, true, 'TryRandomBehavior');
	}
}

simulated function Destroyed()
{
	super.Destroyed();

	if ( (MySpawner != None) && !bHasNotifiedSpawner )
	{
		bHasNotifiedSpawner = true;
		MySpawner.AgentDestroyed(self);
	}
	if ( CurrentDestination != None )
	{
		CurrentDestination.DecrementCustomerCount(self);
		CurrentDestination = None;
	}
	
	if ( MyGroup != None )
	{
		MyGroup.RemoveMember(self);
	}
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local string	T;
	local Canvas Canvas;

	super.DisplayDebug(HUD, out_YL, out_YPos);
	Canvas = HUD.Canvas;

	Canvas.SetPos(4, out_YPos);
	Canvas.SetDrawColor(255,0,0);

	T = GetDebugName();
	if( bDeleteMe )
	{
		T = T$" DELETED (bDeleteMe == true)";
	}

	if( T != "" )
	{
		Canvas.DrawText(T, FALSE);
		out_YPos += out_YL;
		Canvas.SetPos(4, out_YPos);
	}

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("Location:"@Location@"Rotation:"@Rotation@" Speed: "$VSize(Velocity)@"ZVel"@Velocity.Z, FALSE);
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);

	Canvas.DrawText("Hit obestacle:"@bHitObstacle@"BadHitNormal:"@bBadHitNormal@"count"@ObstacleCheckCount, FALSE);
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);

	Canvas.DrawText("Current conform interval:"@CurrentConformTraceInterval@"Base Conform Interval:"@ConformTraceInterval@" Last Ground Z "@LastGroundZ, FALSE);
	out_YPos += out_YL;
	Canvas.SetPos(4,out_YPos);

	if ( CurrentDestination == None )
	{
		Canvas.DrawText("NO DESTINATION", FALSE);
		out_YPos += out_YL;
		Canvas.SetPos(4,out_YPos);
	}
	else
	{
		if ( NavigationHandle != None )
		{
			NavigationHandle.DrawPathCache();
		}
		T = "DESTINATION "$CurrentDestination;
		if ( MyGroup != None )
		{
			T = T$" Group "$MyGroup;
			DrawDebugLine(MyGroup.Members[0].Location, Location, 255, 128, 0, FALSE);
		}
		
		Canvas.DrawText(T, FALSE);
		out_YPos += out_YL;
		Canvas.SetPos(4,out_YPos);
		if ( IntermediatePoint == CurrentDestination.Location )
		{
			DrawDebugLine(IntermediatePoint, Location, 0, 128, 255, FALSE);
		}
		else
		{
			DrawDebugLine(IntermediatePoint, Location, 0, 255, 0, FALSE);
			DrawDebugLine(CurrentDestination.Location, Location, 255, 255, 0, FALSE);
		}
	}
}

/**
  *  Set agent lighting
  *  @PARAM bEnableLightEnvironment controls whether light environment is enabled
  *  @PARAM AgentLightingChannel is the lighting channel to use (GameCrowdAgentSkeletal only)
  *  @PARAM bCastShadows controls whether agent casts shadows (GameCrowdAgentSkeletal only)
  */
simulated function SetLighting(bool bEnableLightEnvironment, LightingChannelContainer AgentLightingChannel, bool bCastShadows)
{
	// If desired, enable light env
	if(bEnableLightEnvironment)
	{
		LightEnvironment.SetEnabled(TRUE);
	}
	// If not, detach to stop it even getting updated
	else
	{
		DetachComponent(LightEnvironment);
	}
}

/**
  *  Initialize agent archetype, group, destination, and behavior
  */
simulated function InitializeAgent(Actor SpawnLoc, GameCrowdAgent AgentTemplate, GameCrowdGroup NewGroup, float AgentWarmUpTime, bool bWarmupPosition, bool bCheckWarmupVisibility)
{
	local bool bGroupDestination, bRealPreferVisible;
	local GameCrowdDestination SpawnDest;
	local float TryPct, MaxSpawnDist, DestDist, StartDist;
	local vector TryLoc;
	local Actor HitActor;
	local vector HitLocation, HitNormal, ViewLocation, YAdjust;
	local rotator ViewRotation;
	local PlayerController PC;
	local bool bVisibleTryLoc;

	MyArchetype = AgentTemplate;

	// let agent "warm up" and simulate a little before going to sleep
	LastRenderTime = WorldInfo.TimeSeconds + AgentWarmUpTime * (0.5 + FRand());
	InitialLastRenderTime = LastRenderTime;

	// set group - maybe get destination from there
	if ( NewGroup != None )
	{
		NewGroup.AddMember(self);
		if ( NewGroup.Members.Length > 1 )
		{
			//already have leader, get destination from him
			bGroupDestination = true;
			SetCurrentDestination(NewGroup.Members[0].CurrentDestination);
		}
	} 
	
	if ( !bGroupDestination )
	{
		SpawnDest = GameCrowdDestination(SpawnLoc);
		if ( SpawnDest != None )
		{
			// already at destination - pick a next destination from it
			SetCurrentDestination(SpawnDest);

			// ask for a new destination - with spawn preference for visible destination
			bRealPreferVisible = bPreferVisibleDestination;
			bPreferVisibleDestination = bPreferVisibleDestinationOnSpawn || !SpawnDest.bWillBeVisible;
			LastRenderTime = WorldInfo.TimeSeconds;     // Update the agent's render time, so it doesn't get killed on initialization for having not been rendered in a while
			CurrentDestination.ReachedDestination(self);
			bPreferVisibleDestination = bRealPreferVisible;
			if ( CurrentDestination == None )
			{
				`warn("INITIALIZING - NO CURRENTDESTINATION AFTER REACHING "$SpawnDest);
			}
			if ( bWarmupPosition )
			{
				ForEach LocalPlayerControllers(class'PlayerController', PC )
				{
					PC.GetPlayerViewPoint(ViewLocation, ViewRotation);
					break;
				}
				if ( (NewGroup == None) || (NewGroup.Members.Length == 0) )
				{
					// group leader or individual agent determines spawn offset
					// try randomizing position somewhere between spawn position and destination
					TryPct = FRand();
					MaxSpawnDist = (MySpawner != None) ? MySpawner.GetMaxSpawnDist() : 0.0;
					if ( SpawnDest.bIsBeyondSpawnDistance && (MySpawner != None) )
					{
						DestDist = VSize(CurrentDestination.Location - ViewLocation);
						if ( CurrentDestination.bIsBeyondSpawnDistance || (DestDist > MaxSpawnDist) )
						{
							TryPct = (DestDist < VSizeSq(SpawnDest.Location - ViewLocation)) ? 1.0 : 0.0;
						}
						else
						{
							// get close to max spawn dist
							StartDist = VSize(SpawnDest.Location - ViewLocation);
							if ( StartDist > DestDist )
							{
								TryPct = 1.0 - (MaxSpawnDist - DestDist)/(StartDist - DestDist);
								TryPct *= 0.9;
							}
							else
							{
								TryPct = 0.0;
							}
						}
					}
					else if ( !SpawnDest.bWillBeVisible )
					{
						// bias spawning closer to point that will soon be visible, unless player is about to view this area
						TryPct = 0.5*TryPct + 0.5;
					}
					else
					{
						TryPct *= 0.9;
					}
					TryLoc = TryPct * CurrentDestination.Location + (1-TryPct)*SpawnDest.Location;

					// make sure no player can see this intermediate spawn position
					bVisibleTryLoc = false;
					if ( bCheckWarmupVisibility && !SpawnDest.bIsBeyondSpawnDistance )
					{
						HitActor = PC.Trace(HitLocation, HitNormal, TryLoc, ViewLocation, false);
						if ( HitActor == None )
						{
							// try again closer to starting point
							TryPct *= 0.5;
							TryLoc = TryPct * CurrentDestination.Location + (1-TryPct)*SpawnDest.Location;
							HitActor = PC.Trace(HitLocation, HitNormal, TryLoc, ViewLocation, false);
							if ( HitActor == None )
							{
								bVisibleTryLoc = true;
							}
						}
					}
					if ( !bVisibleTryLoc )
					{
						SpawnOffset = TryLoc;

						// is candidate spawn position traceable from known good spawn position?
						HitActor = Trace(HitLocation, HitNormal, TryLoc, CurrentDestination.Location, false);
						if ( HitActor == None )
						{
							// try offsetting the agent so they aren't all in a line
							TryPct = 2.0 * FRand() - 1.0;
							YAdjust = TryLoc + TryPct * AvoidOtherRadius * Normal((CurrentDestination.Location - SpawnDest.Location) cross Vect(0,0,1));
							HitActor = Trace(HitLocation, HitNormal, YAdjust, CurrentDestination.Location, false);
							if ( HitActor == None )
							{
								TryLoc = YAdjust;
							}

							// find floor below candidate position, and adjust agent there
							HitActor = Trace(HitLocation, HitNormal, TryLoc - vect(0.0,0.0,250.0), TryLoc, false);
							if ( HitActor != None )
							{
								TryLoc.Z = HitLocation.Z + GroundOffset + 5.0;
							}

							// most of the time, agent is fine any way, otherwise will just fall quickly out of the world
							SetLocation(TryLoc);

							// randomly turn some agents around if their spawn loc is about to become visible, and their current destination is visible
							if ( SpawnDest.bWillBeVisible && CurrentDestination.bIsVisible && (FRand()<0.5) )
							{
								PreviousDestination = CurrentDestination;
								CurrentDestination.DecrementCustomerCount(self);
								CurrentDestination = None;
								BehaviorDestination = None;
								SetCurrentDestination(SpawnDest);
							}
						}
					}
				}
				else
				{
					// group leader already determined offset, other group members will use same offset
					TryLoc = SpawnOffset;

					// try offsetting the agent so they aren't all in a line
					TryPct = 2.0 * FRand() - 1.0;
					YAdjust = TryLoc + TryPct * AvoidOtherRadius * Normal((CurrentDestination.Location - SpawnDest.Location) cross Vect(0,0,1));
					HitActor = Trace(HitLocation, HitNormal, YAdjust, CurrentDestination.Location, false);
					if ( HitActor == None )
					{
						TryLoc = YAdjust;
					}

					// find floor below candidate position, and adjust agent there
					HitActor = Trace(HitLocation, HitNormal, TryLoc - vect(0.0,0.0,250.0), TryLoc, false);
					if ( HitActor != None )
					{
						TryLoc.Z = HitLocation.Z + GroundOffset + 5.0;
					}

					// most of the time, agent is fine any way, otherwise will just fall quickly out of the world
					SetLocation(TryLoc);
				}
			}
		}
	}
	LastKnownGoodPosition = Location;
	LastKnownGoodPosition.Z += EyeZOffset;

	// apply spawn behavior to agent
	if ( SpawnBehaviors.Length > 0 )
	{
		PlaySpawnBehavior();
	}
	UpdateIntermediatePoint();
}

simulated function OnPlayAgentAnimation(SeqAct_PlayAgentAnimation Action)
{
	// non-skeletal agent can't play animation, so get next destination
	CurrentDestination.ReachedDestination(self);
}

/**
  * Play a looping idle animation
  */
simulated event PlayIdleAnimation();

simulated event StopIdleAnimation();

/** 
  *  Called when agent encounters another agent
  *  NearbyDynamics list has been updated with agents, and potential encounters have their bPotentialEncounter set to true
  */
event HandlePotentialAgentEncounter()
{
	if ( CurrentBehavior == None )
	{
	 	PickBehaviorFrom(EncounterAgentBehaviors);
	}
}

/**
  *  Called when agent spawns and has SpawnBehaviors set
  */
function PlaySpawnBehavior()
{
	if ( CurrentBehavior == None )
	{	
	 	PickBehaviorFrom(SpawnBehaviors);
	}
}

/**
  * Called when see PC's pawn where PC is a local playercontroller,
  * Notification only occurs if bHasSeePlayerKismet=true
  */
event NotifySeePlayer(PlayerController PC)
{
	local bool bFoundBehavior;
	local int i;
	
	bWantsSeePlayerNotification = false; 
	
	// FIXMESTEVE - should check if current behavior can be overwritten and/or paused, and if so just pause it (keep it in current state)
	if ( CurrentBehavior == None )
	{	
	 	if ( !PickBehaviorFrom(SeePlayerBehaviors, PC.Pawn.Location) )
		{
			// maybe all behaviors have been used and can't be re-used
			for ( i=0; i<SeePlayerBehaviors.Length; i++ )
			{
				if ( !SeePlayerBehaviors[i].bNeverRepeat || !SeePlayerBehaviors[i].bHasBeenUsed )
				{
					bFoundBehavior = true;
					break;
				}
			}
			if ( !bFoundBehavior )
			{
			  	// no available behaviors, so kill the see player timer
				SeePlayerInterval = 0.0;
			 }
		}
	}
		
	// set timer to begin requesting see player notification again
	if ( SeePlayerInterval > 0.0 )
	{
		SetTimer( (0.8+0.4*FRand())*SeePlayerInterval, false, 'ResetSeePlayer');
	}
}

/**
  *  Called when random behavior timer expires
  *  If not currently in behavior AND player can see me, do a random behavior.
  */
function TryRandomBehavior()
{
	local bool bFoundBehavior;
	local int i;

	// FIXMESTEVE - should check if current behavior can be overwritten and/or paused, and if so just pause it (keep it in current state)
	if ( (CurrentBehavior == None) && (WorldInfo.TimeSeconds - LastRenderTime < 0.1) )
	{
		if ( !PickBehaviorFrom(RandomBehaviors) )
		{
			// maybe all behaviors have been used and can't be re-used
			for ( i=0; i<RandomBehaviors.Length; i++ )
			{
				if ( !RandomBehaviors[i].bNeverRepeat || !RandomBehaviors[i].bHasBeenUsed )
				{
					bFoundBehavior = true;
					break;
				}
			}
			if ( !bFoundBehavior )
			{
				// no available behaviors, so kill the see player timer
				ClearTimer('TryRandomBehavior');
			}
		}
	}
}

function ResetSeePlayer()
{
	bWantsSeePlayerNotification = true;
}

/** 
  * Activate the passed in NewBehaviorArchetype as the new current behavior for this agent
  * FIXMESTEVE - currently kills old behavior - instead, should have stack of behaviors
  */
event ActivateBehavior(GameCrowdAgentBehavior NewBehaviorArchetype)
{
	StopBehavior();
	if ( NewBehaviorArchetype == None )
	{
		`warn("Illegal behavior "$NewBehaviorArchetype$" for "$self);
		return;
	}
	
	SetCurrentBehavior(NewBehaviorArchetype);
	
	// start up behavior
	CurrentBehavior.InitBehavior(self);
}

/** 
  * Activate a new behavior that has already been instantiated
  */
function ActivateInstancedBehavior(GameCrowdAgentBehavior NewBehaviorObject)
{
	StopBehavior();
	CurrentBehavior = NewBehaviorObject;
	
	// start up behavior
	CurrentBehavior.InitBehavior(self);
}

event StopBehavior()
{
	if ( CurrentBehavior != None )
	{
		CurrentBehavior.StopBehavior();
		CurrentBehavior = None;
	}
}  

/** 
  * Instantiate a new behavior using BehaviorArchetype, and set it to be the current behavior. 
  */
final native function SetCurrentBehavior(GameCrowdAgentBehavior BehaviorArchetype);

/**
  * @RETURNS true if CurrentBehavior and CurrentBehavior.bIdleBehavior is true
  */
native function bool IsIdle();

/**
 *	Calculate camera view point, when viewing this actor.
 *
 * @param	fDeltaTime	delta time seconds since last update
 * @param	out_CamLoc	Camera Location
 * @param	out_CamRot	Camera Rotation
 * @param	out_FOV		Field of View
 *
 * @return	true if Actor should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector HitNormal;
	local float Radius;

	Radius = 20.0;

	if (Trace(out_CamLoc, HitNormal, Location - vector(out_CamRot) * Radius * 20, Location, false) == None)
	{
		out_CamLoc = Location - vector(out_CamRot) * Radius * 20;
	}

	return false;
}

/**
  *  Update current intermediate destination point for agent in route to DestinationActor
  */
event UpdateIntermediatePoint(optional Actor DestinationActor)
{
	if ( DestinationActor == None )
	{
		if ( CurrentBehavior != None )
		{
			DestinationActor = CurrentBehavior.GetDestinationActor();
		}
		else
		{
			DestinationActor = CurrentDestination;
		}
		if ( DestinationActor == None )
		{
			return;
		}
	}

	if ( !bUseNavMeshPathing )
	{
		IntermediatePoint = DestinationActor.Location;
		//DrawDebugLine(Location, IntermediatePoint,255,0,0,true);
	}
	else
	{
		IntermediatePoint = GeneratePathToActor(DestinationActor);
		if ( IntermediatePoint == vect(0,0,0) )
		{
			IntermediatePoint = DestinationActor.Location;
		}
	}
}

/** Stop agent moving and pay death anim */
native function PlayDeath(vector KillMomentum);

/** Death event is script class, so need to call from script */
simulated event FireDeathEvent()
{
	TriggerEventClass( class'SeqEvent_Death', self );
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if ( Health > 0 )
	{
		Health -= DamageAmount;

		if(Health <= 0)
		{
			Health = -1;
			SetCollision(FALSE, FALSE, FALSE); // Turn off all collision when dead.
			PlayDeath(normal(Momentum) * DamageType.default.KDamageImpulse + Vect(0,0,1)*DamageType.default.KDeathUpKick);
		}
	}
}

/** Called when crowd agent overlaps something in the ReportOverlapsWithClass list */
event OverlappedActorEvent(Actor A);

/** spawn and init Navigation Handle */
event InitNavigationHandle()
{
	if( NavigationHandleClass != None )
	{
		NavigationHandle = new(self) NavigationHandleClass;
	}
}

/**
  * Generate a path to Goal on behalf of the QueryingAgent
  */
event vector GeneratePathToActor( Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	local vector NextDest;
//	local byte R,G;

	LastPathingAttempt = WorldInfo.TimeSeconds;
	NextDest = Goal.Location;

//	R = 255;

	// make sure we have a valid navigation handle
	if ( NavigationHandle == None )
	{
		InitNavigationHandle();
	}
	if( (NavigationHandle != None) && !NavigationHandle.ActorReachable(Goal) )
	{
		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Goal );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Goal, WithinDistance, bAllowPartialPath );
		if ( NavigationHandle.FindPath() )
		{
			NavigationHandle.GetNextMoveLocation(NextDest, SearchExtent.X);
//			R = 0;
//			G = 255;
		}
		NavigationHandle.ClearConstraints();
	}
//	else G = 255;

//	DrawDebugLine(Location, NextDest,R,G,0,true);

	return NextDest;
}


simulated native function NativePostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);

/**
PostRenderFor()
Hook to allow agents to render HUD overlays for themselves.
Called only if the agent was rendered this tick.
Assumes that appropriate font has already been set
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local float NameXL, TextXL, BehavXL, TextYL, YL, XL;
	local vector ScreenLoc;
	local string ScreenName, DestString, BehaviorString;
	local FontRenderInfo FontInfo;

	// make sure not clipped out
	screenLoc = Canvas.Project(Location + BeaconOffset);
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		return;
	}

	ScreenName = "Agent"@self;
	if ( MyGroup != None )
	{
		ScreenName = ScreenName$" Group "$MyGroup;
		DrawDebugLine(MyGroup.Members[0].Location, Location, 255, 0, 255, FALSE);
	}
	ScreenName = ScreenName@"Last Rendered"@(WorldInfo.TimeSeconds - LastRenderTime);
	Canvas.StrLen(ScreenName, NameXL, TextYL);
	XL = FMax(XL, NameXL);
	YL += TextYL;

	DestString = GetDestString();
	Canvas.StrLen(DestString, TextXL, TextYL);
	XL = FMax(XL, TextXL);
	YL += TextYL;
	
	BehaviorString = GetBehaviorString();
	Canvas.StrLen(BehaviorString, BehavXL, TextYL);
	XL = FMax(XL, BehavXL);
	YL += TextYL;
	
	Canvas.SetPos(ScreenLoc.X-0.7*XL, ScreenLoc.Y-1.8*YL);
	Canvas.DrawTile(BeaconTexture, 1.4*XL, 1.2*YL, 0,0,31,31, BeaconColor);

	Canvas.DrawColor = class'HUD'.default.GreenColor;

	Canvas.SetPos(ScreenLoc.X-0.5*NameXL,ScreenLoc.Y-1.7*YL);
	FontInfo.bClipText = true;
	Canvas.DrawText(ScreenName, true,,, FontInfo);

	Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.7*YL + 1.1*TextYL);
	FontInfo.bClipText = true;
	Canvas.DrawText(DestString, true,,, FontInfo);

	Canvas.SetPos(ScreenLoc.X-0.5*BehavXL,ScreenLoc.Y-1.7*YL + 2.2*TextYL);
	FontInfo.bClipText = true;
	Canvas.DrawText(BehaviorString, true,,, FontInfo);
	
	// draw line to current destination
	if ( CurrentDestination != None )
	{
		DrawDebugLine(Location, CurrentDestination.Location, 255, 255, 0 , false);
	}
}

/**
  * Get debug string about agent destination and movement status
  */
function string GetDestString()
{
	local string DestString;
	
	DestString = (CurrentDestination == None) ? "NO DESTINATION" : ""$CurrentDestination;
	if ( IsIdle() )
	{
		DestString = ((CurrentDestination != None) && CurrentDestination.ReachedByAgent(self, Location, true)) ? "Idle at "$DestString : "Idle en route to "$DestString;
	}
	else
	{
		DestString = "Moving to "$DestString;
	}
	return DestString;
}

/** 
  * Get debug string about agent behavior
  */
function string GetBehaviorString()
{
	local string BehaviorString;
	
	if ( CurrentBehavior != None )
	{
		BehaviorString = CurrentBehavior.GetBehaviorString();
	}
	else
	{
		BehaviorString = "Moving between Destinations";
	}
	
	return BehaviorString;
}

defaultproperties
{
	NavigationHandleClass=class'NavigationHandle'

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=FALSE
		InvisibleUpdateTime=5.0
		MinTimeBetweenFullUpdates=2.0
		TickGroup=TG_DuringAsyncWork
		bCastShadows=true
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	MeshMinScale3D=(X=1.0,Y=1.0,Z=1.0)
	MeshMaxScale3D=(X=1.0,Y=1.0,Z=1.0)
	bUniformScale=TRUE

	Health=100

	ConformTraceDist=35.0
	ConformTraceInterval=10
	CurrentConformTraceInterval=10

	AvoidOtherStrength=1000.0
	AvoidPlayerStrength=10000.0
	AvoidOtherRadius=100.0
	AvoidanceShare=0.5
	GroupAttractionStrength=50.0

	MatchVelStrength=0.6

	AwareRadius=200.0
	EyeZOffset=40.0
	AwareUpdateInterval=30

	FollowPathStrength=300.0

	VelocityDamping=0.001

	RotateToTargetSpeed=30000.0

	MaxYawRate=40000.0

	TickGroup=TG_DuringAsyncWork

	Physics=PHYS_Interpolating
	bStatic=false
	bCollideActors=true
	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=false
	bProjTarget=TRUE
	bUpdateSimulatedPosition=false
	bNoEncroachCheck=true
	bPreferVisibleDestinationOnSpawn=true

	RemoteRole=ROLE_None
	bNoDelete=false

	ProximityLODDist=2000.0
	VisibleProximityLODDist=5000.0

	ConformType=CFM_NavMesh
	GroundOffset=40.0
	bCheckForObstacles=false
	bUseNavMeshPathing=true
	SearchExtent=(X=15.0,Y=15.0,Z=40.0)

	WalkableFloorZ=0.7

	NotVisibleLifeSpan=5.5
	NotVisibleTickScalingFactor=0.02
	MaxLOSLifeDistanceSq=400000000.0

	bClampMovementSpeed=true
	MaxWalkingSpeed=100.0
	MaxRunningSpeed=300.0

	SupportedEvents.Add(class'SeqEvent_TakeDamage')
	SupportedEvents.Add(class'SeqEvent_Death')

	BeaconMaxDist=1500.0
	BeaconOffset=(x=0.0,y=0.0,z=140.0)
	BeaconTexture=Texture2D'EngineResources.WhiteSquareTexture'
	BeaconColor=(R=0.5f, G=0.5f, B=0.5f, A=0.5f)

	DeadBodyDuration=10.0
	SeePlayerInterval=0.0
	RandomBehaviorInterval=30.0
	
	ReachThreshold=1.0
	DesiredGroupRadius=200.0
}



