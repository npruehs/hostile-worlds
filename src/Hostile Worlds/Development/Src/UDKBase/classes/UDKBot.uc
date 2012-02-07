/**
 * AI Controller that simulates the  behavior of a human player
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKBot extends AIController
	native;

/** Squad this bot is in.  Squads share the same goal, and handle AI planning. */
var UDKSquadAI			Squad;

/** component that handles delayed calls ExecuteWhatToDoNext() to when triggered */
var UDKAIDecisionComponent DecisionComponent;

/** temporarily look at this actor (for e.g. looking at shock ball for combos) - only used when looking at enemy */
var Actor TemporaryFocus;

/** set when in ExecuteWhatToDoNext() so we can detect bugs where
 * it calls WhatToDoNext() again and causes decision-making to happen every tick
 */
var bool bExecutingWhatToDoNext;

/** script flags that cause various events to be called to override C++ functionality */
var bool bScriptSpecialJumpCost;

/** used with route reuse to force the next route finding attempt to do the full path search */
var bool bForceRefreshRoute;

/** if set pass bRequestAlternateLoc = TRUE to GetTargetLocation() when determining FocalPoint from Focus */
var bool bTargetAlternateLoc;

var		bool		bEnemyInfoValid;	// false when change enemy, true when LastSeenPos etc updated

var		bool		bEnemyIsVisible;		/** Result of last enemy LineOfSightTo() check */

var		bool		bLeadTarget;		// lead target with projectile attack

var		bool		bJumpOverWall;					// true when jumping to clear obstacle

var		bool		bPlannedJump;		// set when doing voluntary jump

/** bInDodgeMove is true if a bot is currently executing a dodge, and has not yet landed from it */
var		bool		bInDodgeMove;

/** bEnemyAcquired is true if the bot has been able to face the enemy directly.  The bot has improved tracking after acquiring an enemy (uses AcquisitionYawRate instead of RotationRate to track enemy before acquired). */
var		bool		bEnemyAcquired;

/** triggers the bot to call DelayedLeaveVehicle() during its next tick - used in the 'non-blocking' case of LeaveVehicle() */
var bool bNeedDelayedLeaveVehicle;

/** if true, when pathfinding to the same RouteGoal as the last time, use old RouteCache if it's still valid and all paths on it usable */
var bool bAllowRouteReuse;

/** if not 255, bot always uses this fire mode - for scripting bot actions */
var byte ScriptedFireMode;

// caching visibility of enemies
var		float		EnemyVisibilityTime;	/** When last enemy LineOfSightTo() check was done */
var		pawn		VisibleEnemy;			/** Who the enemy was for the last LineOfSightTo() check */

/** Last vehicle which blocked the path of this bot */
var		Vehicle		LastBlockingVehicle;

/** Normally the current enemy.  Reset SavedPositions if this changes. */
var		Pawn		CurrentlyTrackedEnemy;	

struct native EnemyPosition
{
	var vector	Position;
	var	vector	Velocity;
	var float	Time;
};

/** Position and velocity of enemy at previous ticks.  
Used for smooth bot aiming prediction - bots aim at where they think the target is based on his position and velocity a few 100 msec ago, like a player. */
var array<EnemyPosition> SavedPositions;	

/** velocity added while falling (bot tries to correct for it) */
var vector	ImpactVelocity;	 

/** The bot uses AcquisitionYawRate instead of RotationRate to track enemy before acquired. */
var		int		AcquisitionYawRate;

/** distance at which bot will notice noises. */
var float			HearingThreshold;	

/** How long ahead to predict inventory respawns */
var		float							RespawnPredictionTime;

/** delay before act on warning about being shot at by InstantWarnTarget() or ReceiveProjectileWarning() */
var float WarningDelay;	

/** Projectile bot has been warned about and will react to (should set in ReceiveProjectileWarning()) */
var Projectile WarningProjectile;

/** for monitoring the position of a pawn.  Will receive a MonitoredPawnAlert() event if the MonitoredPawn is killed or no longer possessed, 
or moves too far away from either MonitorStartLoc or the bot's position */
var		vector		MonitorStartLoc;	// Location checked versus current MonitoredPawn position to see if it has moved too far 
var		Pawn		MonitoredPawn;		// Pawn being monitored
var		float		MonitorMaxDistSq;	// Maximum distance the Monitored pawn can move before being considered too far away.

// enemy position information
var		vector		LastSeenPos; 	// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;	// position where I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		float		LastSeenTime;	// time at which last seen information was last updated.

/** Enemy tracking - bots use this for targeting their current enemy.  Bots actually aim at a position based that's predicted based on the 
target's position TrackingReactionTime ago, extrapolated using the target's velocity at that time.
This means, for example, that if a target suddenly changes directions, bots will miss because they'll fire at where they thought he was going 
(until their reactio delay catches up */
var		float		TrackingReactionTime;	/** How far back in time is bots model of enemy position based on */
var		float		BaseTrackingReactionTime;	/** Base value, modified by skill to set TrackingReactionTime */
var		vector		TrackedVelocity;		/** Current velocity estimate (lagged) of tracked enemy */

/** whether bot is currently using the squad alternate route - if false, FindPathToSquadRoute() just calls FindPathToward(Squad.RouteObjective) */
var bool bUsingSquadRoute;

/** if true, this bot uses the SquadAI's PreviousObjectiveRouteCache instead (used when the route changes while bot is following it) */
var bool bUsePreviousSquadRoute;

/** goal along squad's route, used when moving along alternate path via FindPathToSquadRoute() */
var NavigationPoint SquadRouteGoal;

/** Iterative aim correction in progress if set */
var pawn BlockedAimTarget;

/** pct lead for last targeting check */
var float LastIterativeCheck;

/* Aim update frequency.  How frequently bots check whether their tracking aim needs to be adjusted for obstacles, etc. */
var float AimUpdateFrequency;

/** Last time tracking aim was updated */
var float LastAimUpdateTime;

/** how often aim error is updated when bot has a visible enemy */
var float ErrorUpdateFrequency;

/** last time aim error was updated */
var float LastErrorUpdateTime;

/** aim error value currently being used */
var float CurrentAimError;

/** expected min landing height of dodge.  Hint used by bots to track whether they are about to miss their planned landing spot (if bInDodgeMove is true).
If so, the MissedDodge() event is triggered. */
var		float		DodgeLandZ;		

/** avoid these spots when moving - used for very short term stationary hazards like bio goo or sticky grenades. */
var		Actor	FearSpots[2];	

/** Likelihood that MayDodgeToMoveTarget() event is called when starting MoveToGoal(). */
var float			DodgeToGoalPct;

/** jump Z velocity bot can gain using multijumps (not counting first jump) */
var		float		MultiJumpZ;

cpptext
{
	DECLARE_FUNCTION(execPollWaitToSeeEnemy);
	DECLARE_FUNCTION(execPollLatentWhatToDoNext);
	UBOOL Tick( FLOAT DeltaSeconds, ELevelTick TickType );
	virtual void UpdateEnemyInfo(APawn* AcquiredEnemy);
	virtual void PrePollMove();
	virtual void PostPollMove();
	void CheckFears();
	virtual void PreAirSteering(FLOAT DeltaTime);
	virtual void PostAirSteering(FLOAT DeltaTime);
	virtual void PostPhysFalling(FLOAT DeltaTime);
	virtual UBOOL AirControlFromWall(FLOAT DeltaTime, FVector& RealAcceleration);
	virtual UReachSpec* PrepareForMove(ANavigationPoint *NavGoal, UReachSpec* CurrentPath);
	virtual void AdjustFromWall(FVector HitNormal, AActor* HitActor);
	virtual void JumpOverWall(FVector WallNormal);
	virtual void NotifyJumpApex();
	virtual FRotator SetRotationRate(FLOAT deltaTime);
	virtual DWORD LineOfSightTo(const AActor* Other, INT bUseLOSFlag = 0, const FVector* chkLocation = NULL, UBOOL bTryAlternateTargetLoc = FALSE);
	FLOAT SpecialJumpCost(FLOAT RequiredJumpZ);
	virtual UBOOL ForceReached(ANavigationPoint *Nav, const FVector& TestPosition);
	virtual void UpdatePawnRotation();
	virtual void MarkEndPoints(ANavigationPoint* EndAnchor, AActor* Goal, const FVector& GoalLocation);
	virtual UBOOL OverridePathTo(ANavigationPoint* EndAnchor, AActor* Goal, const FVector& GoalLocation, UBOOL bWeightDetours, FLOAT& BestWeight);
	virtual void FailMove();

	// Seeing and hearing checks
	virtual UBOOL ShouldCheckVisibilityOf(AController* C);
	virtual DWORD SeePawn(APawn* Other, UBOOL bMaySkipChecks = TRUE);
	virtual UBOOL CanHear(const FVector& NoiseLoc, FLOAT Loudness, AActor *Other);
	virtual void HearNoise(AActor* NoiseMaker, FLOAT Loudness, FName NoiseType);
}

/**
  * Used to determine which actor should be the focus of this bot (that he looks at while moving)
  */
function Actor FaceActor(float StrafingModifier);

/** entry point for AI decision making
 * this gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
 */
protected event ExecuteWhatToDoNext();

/** 
 * Warning from vehicle that bot is about to be run over.
*/
event ReceiveRunOverWarning(UDKVehicle V, float projSpeed, vector VehicleDir);

/** return when looking directly at visible enemy */
native final latent function WaitToSeeEnemy(); 

/** encapsulates calling WhatToDoNext() and waiting for the tick-delayed decision making process to occur using UDKAIDecisionComponent */
native final latent function LatentWhatToDoNext();

/** assumes valid CurrentPath, tries to see if CurrentPath can be combined with path to A */
native final function bool CanMakePathTo(Actor A); 

/**
* Searches the navigation network for a path that leads
* to nearby inventory pickups.
*/
native final function actor FindBestInventoryPath(out float MinWeight);

/**
* Returns shortest path to squad route (UTSquadAI.ObjectiveRouteCache), or next node along route
* if already on squad route
*/
native final function actor FindPathToSquadRoute(optional bool bWeightDetours);

/** 
* Called by squadleader.  Fills the squad's ObjectiveRouteCache.
* Builds upon previous attempts by adding cost to the routes
* in the SquadAI's SquadRoutes array, up to a maximum
* of MaxSquadRoutes iterations.
*/
native final function BuildSquadRoute();

/**
  * Sets all available "super pickups" as possible destinations, and determines best one
  * based on the value of and distance to the pickup (distance must be less than MaxDist).
  * A super pickup is a PickupFactory with bIsSuperItem==true
  * To be valid, it must be ready to pick up, or about to respawn (within this bot's RespawnPredictionTime)
  * not blocked by a vehicle, and desireable to this bot (based on the SuperDesireability() event).
  */
native function Actor FindBestSuperPickup(float MaxDist);

/** triggers ExecuteWhatToDoNext() to occur during the next tick
 * this is also where logic that is unsafe to do during the physics tick should be added
 * @note: in state code, you probably want LatentWhatToDoNext() so the state is paused while waiting for ExecuteWhatToDoNext() to be called
 */
event WhatToDoNext();

/**
 * Will receive a MonitoredPawnAlert() event if the MonitoredPawn is killed or no longer possessed, 
 * or moves too far away from either MonitorStartLoc or the bot's position 
 */
event MonitoredPawnAlert();

/** 
* If bot gets stuck trying to jump, then bCanDoubleJump is set false for the pawn
* Set a timer to reset the ability to double jump once the bot is clear.
*/
event TimeDJReset();

/* 
Called when starting MoveToGoal(), based on DodgeToGoalPct
Know have CurrentPath, with end lower than start
*/
event MayDodgeToMoveTarget();

/** Called when bScriptSpecialJumpCost is true and the bot is considering a path to DestinationActor
 *	that requires a jump with JumpZ greater than the bot's normal capability, but less than MaxSpecialJumpZ
 *	calculates any additional distance that should be applied to this path to take into account preparation, etc
 * @return true to override the cost with the value in the Cost out param, false to use the default natively-calculated cost
 */
event bool SpecialJumpCost(float RequiredJumpZ, out float Cost);

/*
 * Called from native FindBestSuperPickup() to determine how desireable a specific super pickup 
 * is to this bot.
 */
event float SuperDesireability(PickupFactory P);

/*
 * Aiming code requests an update to the aiming error periodically when tracking a target, based on ErrorUpdateFrequency.
 */
event float AdjustAimError(float TargetDist, bool bInstantProj );

/** 
 * If DodgeLandZ (expected min landing height of dodge) is missed when bInDodgeMove is true,
 * the MissedDodge() event is triggered.
 */
event MissedDodge();

/* If ReceiveWarning caused WarningDelay to be set, this will be called when it times out
*/
event DelayedWarning();

/** called just before the AI's next tick if bNeedDelayedLeaveVehicle is true */
event DelayedLeaveVehicle();

defaultproperties
{
	RotationRate=(Pitch=30000,Yaw=30000,Roll=2048)
	RemoteRole=ROLE_None

	Begin Object Class=UDKAIDecisionComponent Name=TheDecider
	End Object
	DecisionComponent=TheDecider
	Components.Add(TheDecider)

	AimUpdateFrequency=0.2
	LastIterativeCheck=1.0
	ErrorUpdateFrequency=0.45
	bLeadTarget=True

	AcquisitionYawRate=20000
	TrackingReactionTime=+0.25
	BaseTrackingReactionTime=+0.25
	bUsingSquadRoute=true
	bAllowRouteReuse=true
	HearingThreshold=2800.0
}

