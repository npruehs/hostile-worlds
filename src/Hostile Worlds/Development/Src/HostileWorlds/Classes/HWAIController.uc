// ============================================================================
// HWAIController
// Controls all pawns of Hostile Worlds, receiving and carrying out basic
// orders.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/10/12
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAIController extends AIController;

/** 
 *  The number of frames a pawn is considered stuck moving if the distance
 *  from this target does not change.
 */
const FRAMES_BEING_STUCK_THRESHOLD = 60;

/** The next point the attached actor has to move to on its path. */
var Vector NextMoveLocation;

/** The destination location of the attached actor's current order. */
var Vector OrderTargetDestination;

/** The target unit of the attached actor's current attack order. */
var HWPawn OrderTargetUnit;

/** The target HWSelectable of the attached actor's current ActorMove order. */
var HWSelectable OrderTargetSelectable;

/** The ability the attached actor has been ordered to use. */
var HWAbility OrderedAbility;

/** A type-casted reference to the ability targeting a unit the attached actor has been ordered to use. */
var HWAbilityTargetingUnit OrderedAbilityTargetingUnit;

/** A type-casted reference to the ability targeting a location the attached actor has been ordered to use. */
var HWAbilityTargetingLocation OrderedAbilityTargetingLocation;

/** Whether the ability the attached actor has been ordered to use has been used. */
var bool bAbilityTriggered;

/** The unit's location in the last frame. Used to verify if the unit is stuck on ReachedTarget() calls. */
var Vector LocationLastFrame;

/** The number of frames the attached actor is stuck moving. */
var int FramesBeingStuck;

/** A typecasted reference to the unit possessed by this controller. */
var repnotify HWPawn Unit;

/** The error message that is shown if a pawn tries to move to a unreachable location. */
var localized string ErrorCannotMoveThere;

/** The current order of the unit belonging to this controller. */
var enum EOrder
{
	O_None,
	O_Moving,
	O_Attacking,
	O_UsingAbilityTargetingUnit,
	O_UsingAbilityTargetingLocation
} CurrentOrder;

/** The previous location of the unit, e.g. before chasing an enemy. */
var vector PreviousLocation;

/** Flag to show if coming from an attack-move. Used in Auto-Attack state to determine if unit shall return to PreviousLocation or keep attack-moving to OrderTargetDestination. */
var bool bAttackMove;

/** Flag to show if the unit shall hold its position or not. */
var repnotify bool bIsHoldingPosition;

/** How long to wait before reducing Aggro on a new Aggro entry (in seconds). */
var float AggroFactorDecreaseGracePeriod;

/** How much to reduce aggro after grace period is over (in percent per second). */
var float AggroFactorDecreaseSpeed;

/** A struct to contain the "aggro" value towards a particular attacker. */
struct AggroEntry
{
	var HWPawn Attacker;
	var float AggroFactor;
	var float LastAggroHitTime;
};

/** Contains the AggroEntry instances of units that are attacking or have attacked this pawn. */
var array<AggroEntry> AggroEntries;

/** How many times already tried to unstuck. */
var int UnstuckTries;

/** Time to wait without moving on first unstuck tries, in order to let the path clear itself (in seconds). */
const UNSTUCK_WAIT_TIME = 0.1f;

/** Locations used by unstuck logic for rerouting on target location. */ 
var array<vector> UnstuckLocations;

/** The last valid location the pawn stood on (inside a polygon that isn't inescapable). */
var Vector LastValidLocation;

/** Original OrderTargetDestination buffered before unstuck logic rerouting. */
var vector OrderTargetDestinationOriginal;

/** The acceptable default distance from the destination used by movement orders on a location. */
var float DestinationOffsetDefault;

/** The current acceptable DestinationOffset used by movement orders to reach a target location or actor. */
var float DestinationOffset;

/** The radius to search for valid locations around issued non valid OrderTargetDestinations. */
const VALID_LOCATION_SEARCH_RADIUS = 300;

/**
 * Must be assigned by movement states in order to evaluate specific move conditions. 
 * Returns true if allowed to keep moving, false otherwise.
 */	
var delegate<CheckMoveConditions> OnCheckMoveConditions;

var float DistanceTemp;


/** Saves a type-casted reference to the pawn on possession. */
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	Unit = HWPawn(inPawn);
	DestinationOffsetDefault = FMax(Unit.GetCollisionHeight(), Unit.GetCollisionRadius());
}

/** Override the base implementation in order to additionally create a NavigationHandle on clients*/
event PostBeginPlay()
{
	Super.PostBeginPlay();

	// The base implementation doesn't call InitNavigationHandle() for clients
	if ( WorldInfo.NetMode == NM_Client )
	{
		InitNavigationHandle();
	}
}

/**
 * Clears all orders and makes the attached actor move in range for
 * using the specified ability, and use it.
 * 
 * @param Ability
 *      the ability the actor should use
 */
function IssueAbilityOrder(HWAbility Ability)
{	
	InterruptChanneling();

	OrderedAbility = Ability;	
	OrderedAbility.bBeingActivated = true;
	OrderTargetUnit = none;
	OrderTargetSelectable = none;

	// try casting to AbilityTargetingUnit
	OrderedAbilityTargetingUnit = HWAbilityTargetingUnit(OrderedAbility);

	bAttackMove = false;

	if (OrderedAbilityTargetingUnit != none)
	{
		`log(Unit$" has been issued the order to use ability "$Ability$" on "$OrderedAbilityTargetingUnit.TargetUnit);

		// An ability order breaks the hold position order if the targeted unit is outside the range
		// TODO MK Enable again for toggleable bIsHoldingPosition
		//if(bIsHoldingPosition && !ReachedTarget(OrderedAbilityTargetingUnit.TargetUnit.Location, Unit.Range))
		//{
		//	bIsHoldingPosition = false;
		//}

		CurrentOrder = O_UsingAbilityTargetingUnit;

		GotoState('UsingAbilityOnUnit');
	}
	else 
	{
		// try casting to AbilityTargetingLocation
		OrderedAbilityTargetingLocation = HWAbilityTargetingLocation(OrderedAbility);

		if (OrderedAbilityTargetingLocation != none)
		{
			`log(Unit$" has been issued the order to use ability "$Ability$" at location "$OrderedAbilityTargetingLocation.TargetLocation);

			// An ability order breaks the hold position order if the targeted location is outside the range
			// TODO MK Enable again for toggleable bIsHoldingPosition
			//if(bIsHoldingPosition && !ReachedTarget(OrderedAbilityTargetingLocation.TargetLocation, Unit.Range))
			//{
			//	bIsHoldingPosition = false;
			//}

			CurrentOrder = O_UsingAbilityTargetingLocation;

			GotoState('UsingAbilityOnLocation');
		}
	}
}

/**
 * Clears all orders of the attached actor.
 */
function IssueStopOrder()
{
	InterruptChanneling();

	GotoState('Idle');
}

/**
 * Clears all orders and makes the attached actor move to the specified location.
 * 
 * @param TargetLocation
 *      the location the actor should move to
 */
function IssueMoveOrder(Vector TargetLocation)
{
	InterruptChanneling();

	OrderTargetDestination = TargetLocation;
	OrderTargetUnit = none;
	OrderTargetSelectable = none;

	bAttackMove = false;

	// A move order breaks the hold position order
	// TODO MK Enable again for toggleable bIsHoldingPosition
	//if(bIsHoldingPosition)
	//{
	//	bIsHoldingPosition = false;
	//}
	
	CurrentOrder = O_Moving;

	GotoState('LocationMove');
}

/**
 * Clears all orders and makes the attached actor attack-move to the specified location.
 * 
 * @param TargetLocation
 *      the location the actor should attack-move to
 */
function IssueAttackMoveOrder(Vector TargetLocation)
{
	InterruptChanneling();

	OrderTargetDestination = TargetLocation;
	OrderTargetUnit = none;
	OrderTargetSelectable = none;
	
	bAttackMove = true;

	// An attack move order breaks the hold position order
	// TODO MK Enable again for toggleable bIsHoldingPosition
	//if(bIsHoldingPosition)
	//{
	//	bIsHoldingPosition = false; 
	//}

	CurrentOrder = O_Moving;

	GotoState('AttackMove');
}

/**
 * Clears all orders and makes the attached actor move in range for
 * attacking the specified target, and attack it.
 * 
 * @param EnemyUnit
 *      the enemy unit the actor should attack
 */
function IssueAttackOrder(HWPawn EnemyUnit)
{
	if(Unit.bBlinded)
	{
		return;
	}

	InterruptChanneling();

	OrderTargetUnit = EnemyUnit;
	OrderTargetSelectable = EnemyUnit;
	bAttackMove = false;

	// Squadmembers shall approach the target on AttackOrders
	// TODO MK Remove for toggleable bIsHoldingPosition
	bIsHoldingPosition = false;

	// An attack order breaks the hold position order if the EnemyUnit is outside the range
	// TODO MK Enable again for toggleable bIsHoldingPosition
	//if(bIsHoldingPosition && !ReachedTarget(EnemyUnit.Location, Unit.Range))
	//{
	//	bIsHoldingPosition = false;
	//}

	CurrentOrder = O_Attacking;

	GotoState('Attack');
}

/** 
 *  Sets the bIsHoldingPosition flag to true
 *  and issues a Stop order.
 */
function IssueHoldPositionOrder()
{	
	bIsHoldingPosition = true;
	IssueStopOrder();
}

/** Stops the attached pawn and ignores further orders. */
function IssueDismissOrder()
{
	InterruptChanneling();

	GotoState('Dismissing');
}

/** Causes the unit to auto attack the heard NoiseMaker. */
event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	local HWPawn NoiseMakingPawn;

	NoiseMakingPawn = HWPawn(NoiseMaker);

	// Return if NoiseMaker is not a pawn or already dead
	if(NoiseMakingPawn == none || NoiseMakingPawn.Health <= 0)
	{
		return;
	}

	// listen to calls for help
	if (NoiseType == 'CallForHelp')
	{
		//`log(Unit$" heard "$NoiseMaker$" calling for help.");

		// check if the unit calling for help is on the same team,
		// if it is attacking an existing unit
		// and if the unit to be attacked is on the other team of this unit
		if( Unit.TeamIndex == NoiseMakingPawn.TeamIndex
			&& HWAIController(NoiseMakingPawn.Controller).OrderTargetUnit != none
			&& Unit.TeamIndex != HWAIController(NoiseMakingPawn.Controller).OrderTargetUnit.TeamIndex)
		{
			// check distance
			if (VSize2D(NoiseMakingPawn.Location - Unit.Location) < class'HWPawn'.const.CALL_FOR_HELP_RADIUS)
			{
				//`log(`location@"Unit:"@Unit@"acquired enemy:"@HWAIController(NoiseMakingPawn.Controller).OrderTargetUnit@"by a help call from:"@NoiseMaker);

				AcquiredEnemyUnit(HWAIController(NoiseMakingPawn.Controller).OrderTargetUnit);
			}
		}

		return;
	}

	// Acquire enemy units in range
	if(Unit.TeamIndex != NoiseMakingPawn.TeamIndex)
	{
		//`log(`location@"Unit:"@Unit@"acquired enemy:"@NoiseMakingPawn@"in range!");

		AcquiredEnemyUnit(NoiseMakingPawn);
	}
	// Check AutoCast on friendly units in range
	else
	{
		// acquired own unit - check for auto cast
		CheckForAutoCast(NoiseMakingPawn);
	}
}

/**
 * Causes the HWAIController.Unit to either attack the enemy with the most aggro in acquisition range or the given EnemyUnit.
 */
function AcquiredEnemyUnit(HWPawn EnemyUnit)
{
	local AggroEntry AE;

	// Return if 
	// - the own unit is blinded
	// - the enemy unit is cloaked
	// - the enemy unit is already the target
	if(    Unit.bBlinded 
		|| EnemyUnit.bCloaked
		|| EnemyUnit == OrderTargetUnit)
	{
		return;
	}

	// Find the enemy with the most aggro in the units' acquisition radius
	if(GetFirstAggroEntryInRange(Unit.Location, Unit.AcquisitionRadiusUU, AE))
	{   
		// Return if already attacking the found enemy
		if(AE.Attacker == OrderTargetUnit)
		{
			return;
		}

		OrderTargetUnit = AE.Attacker;
		OrderTargetSelectable = AE.Attacker;

		GoToState('AutoAttack');	
	}
	// else attack the given EnemyUnit if not attacking another unit already
	else if(OrderTargetUnit == none)
	{
		OrderTargetUnit = EnemyUnit;
		OrderTargetSelectable = EnemyUnit;

		GoToState('AutoAttack');	
	}
}

/**
 * Checks whether the unit attached to this controller may target the
 * specified unit with its autocast ability, if any, and does so if
 * possible.
 * 
 * @param AutoCastTarget
 *      the target to check
 */
function CheckForAutoCast(HWPawn AutoCastTarget)
{
	local HWSquadMember SquadMember;
	local HWAbilityTargetingUnit AutoCastAbility;
	local string ErrorMessage;

	SquadMember = HWSquadMember(Unit);

	// check whether a squad member with auto cast ability is attached
	if (SquadMember != none && SquadMember.AutoCastAbility != none)
	{
		AutoCastAbility = SquadMember.AutoCastAbility;

		// check preconditions
		if (AutoCastAbility.bLearned 
			&& AutoCastAbility.CheckPreconditions(ErrorMessage) 
			&& AutoCastAbility.CheckTarget(AutoCastTarget, ErrorMessage)
			&& (!bIsHoldingPosition || (bIsHoldingPosition && ReachedTarget(AutoCastTarget.Location, AutoCastAbility.Range))))
		{
			// trigger auto cast
			AutoCastAbility.TargetUnit = AutoCastTarget;
			IssueAbilityOrder(AutoCastAbility);
		}
	}
}

/**
 * Starts charging the enemy, ignoring further orders.
 */
function StartCharging()
{
	// charging breaks the hold position order
	// TODO MK Enable again for toggleable bIsHoldingPosition
	//if(bIsHoldingPosition)
	//{
	//	bIsHoldingPosition = false; 
	//}

	GotoState('Charging');
}

/**
 * Tries to find a path to the specified location using the NavMesh. Returns true,
 * if the search was successful, storing the resulting path in the pathcache, and
 * false, otherwise.
 * 
 * @param TargetLocation
 *      the location to compute a path to
 * @param Distance
 *      the acceptable distance from that location
 */
function bool FindPathToLocation(Vector TargetLocation, float Distance)
{
	NavigationHandle.ClearConstraints();

	// reset path constraints and goal evaluators
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	// find path
	class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, TargetLocation);
	class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, TargetLocation, Distance);

	NavigationHandle.SetFinalDestination(TargetLocation);

	return NavigationHandle.FindPath();
}

/**
 * Tries to find a path to the specified target unit using the NavMesh. Returns true,
 * if the search was successful, storing the resulting path in the pathcache, and
 * false, otherwise.
 * 
  * @param Target
 *      the actor to compute a path to
 * @param Distance
 *      the acceptable distance from that location
 */
function bool FindPathToUnit(Actor Target, float Distance)
{
	NavigationHandle.ClearConstraints();

	// reset path constraints and goal evaluators
	NavigationHandle.PathConstraintList = none;
	NavigationHandle.PathGoalList = none;

	// find path
	class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, Target);
	class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Target, Distance);

	NavigationHandle.SetFinalDestination(Target.Location);

	return NavigationHandle.FindPath();
}

/**
 * Returns true, if the controlled unit is within the acceptable distance from
 * the specified destination, and false otherwise.
 * Only the 2D distance is considered (the Z component is assumed to be 0).
 * 
 * @param Destination
 *      the destination location to check
 * @param AcceptableDistance
 *      the distance that returns true
 * @param CurrentDistance
 *      the current distance from the unit's location to the given destination
 */
function bool ReachedTarget(Vector Destination, float AcceptableDistance, out optional float CurrentDistance)
{   
	return CheckDistance2D(Unit.Location, Destination, AcceptableDistance, CurrentDistance);
}

static function bool CheckDistance2D(Vector Origin, Vector Destination, float AcceptableDistance, out optional float CurrentDistance)
{   
	CurrentDistance = VSize2D(Destination - Origin);

	return (CurrentDistance <= AcceptableDistance);
}

/**
 * Returns true, if the attached actor is within the specified range from
 * the given target, and false otherwise.
 * 
 * @param Target
 *      the target to check
 * @param Range
 *      the range that returns true
 */
function bool TargetInRange(Actor Target, float Range)
{
	return ReachedTarget(Target.Location, DestinationOffsetDefault + Range);
}

/** Returns true if the controlled unit is stuck for more frames than the allowed threshold. */
function bool CheckIfStuck()
{
	local Vector2D DistanceVector;
	local float Progress;

	DistanceVector.X = LocationLastFrame.X - Unit.Location.X;
	DistanceVector.Y = LocationLastFrame.Y - Unit.Location.Y;

	Progress = (DistanceVector.X * DistanceVector.X) + (DistanceVector.Y * DistanceVector.Y);

	// if the distance does not change over time, count frames - maybe the pawn is stuck ...
	if (Progress < 0.01)
	{
		FramesBeingStuck++;
	}

	if (FramesBeingStuck > FRAMES_BEING_STUCK_THRESHOLD)
	{
		return true;
	}
	else
	{
		LocationLastFrame = Unit.Location;

		return false;
	}
}

/** 
 *  Returns true if UnstuckLocation was set, false otherwise.
 *  @param UnstuckLocation
 *      A random location near the units current location that can be reached directly on the nav mesh
 *  */
function bool GetUnstuckLocation(out Vector UnstuckLocation)
{
	local int maxRadius;

	maxRadius = UnstuckTries * DestinationOffsetDefault;

	UnstuckLocations.Length = 0;
	class'NavigationHandle'.static.GetValidPositionsForBox(Unit.Location, maxRadius, Unit.GetCollisionExtent(), true, UnstuckLocations, 10, DestinationOffsetDefault);

	if(UnstuckLocations.Length > 0)
	{
		UnstuckLocation = UnstuckLocations[Rand(UnstuckLocations.Length)];

		return true;
	}
	else
	{
		return false;
	}
}

/** Function stub that is overriden in the Channeling state. */
function StopChanneling();

/** Function stub that is overriden in the Channeling state. */
function InterruptChanneling();

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	UpdateAggro(DeltaTime);
}

/** 
 *  Called by the Pawn whenever it has taken damage.
 *  
 *  Causes the pawn to attack the DamageCauser if it's the first attacker
 *  or if it caused more aggro than the current attacked target.
 *  
 *  @param Damage
 *      the amount of damage that has been dealt to the pawn
 *  @param DamageCauser
 *      the actor that has dealt damage to the pawn
 *  @param DamageType
 *      the type of the damage dealt
 */
function NotifyTakeDamage(int Damage, Actor DamageCauser, class<DamageType> DamageType)
{
	local HWPawn Attacker;	
	local float AttackerAggroFactor;

	// damage from damage areas is not relevant for the aggro table
	if (DamageType == class'HWDT_DamageArea')
	{
		return;
	}

	// Assign the DamageCauser as Attacker (melee damage)
	Attacker = HWPawn(DamageCauser);

	// If the DamageCauser is no HWPawn, assign the DamageCauser.Instigator as Attacker (projectile damage)
	if(Attacker == none)
	{
		Attacker = HWPawn(DamageCauser.Instigator);
	}

	// It's an error if the Attacker is still none, return!
	if(Attacker == none)
	{
		`Log(self@"ERROR NotifyTakeDamage() Neither DamageCauser nor DamageCauser.Instigator are HWPawns! DamageCauser:"@DamageCauser@"DamageCauser.Instigator:"@DamageCauser.Instigator);
		
		return;
	}

	// damage from units on own team is not relevant for the aggro table
	if (Attacker.TeamIndex == Unit.TeamIndex)
	{
		return;
	}

	// Add aggro for whatever damaged us, relative to the percentage of our max structure points it took away
	AttackerAggroFactor = AddToAggro(Attacker, float(Damage) / float(Unit.StructureMax));

	// If this is the first attacker, attack him
	// TODO Refactor (only check for aggro)
	if(OrderTargetUnit == none)
	{
		HearNoise(1.0f, Attacker, 'TakeDamage');
	}
	// else attack a target from the aggro table
	else if(AggroEntries.Length > 0)
	{
		// Sort the AggroEntries array if the attacker caused more aggro than the first entry
		if(AttackerAggroFactor > AggroEntries[0].AggroFactor)
		{
			AggroEntries.Sort(SortByAggroFactor);
		}

		// Attack the target with the most aggro
		HearNoise(1.0f, AggroEntries[0].Attacker, 'TakeDamage');
	}
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageTyp)
{	
	if (OrderTargetUnit == KilledPawn)
	{
		OrderTargetUnit = None;
		OrderTargetSelectable = None;
	}

	// try to remove the killed pawn from the aggro table
	RemoveFromAggro(HWPawn(KilledPawn));
}

function bool CheckAttackConditions()
{
   // keep moving if 
	// - target unit still exists
	// - target unit is still alive
	// - target unit isn't cloaked
	// - controlled unit isn't blinded
	return  OrderTargetUnit != none
			&& OrderTargetUnit.Health > 0
			&& !OrderTargetUnit.bCloaked 
			&& !Unit.bBlinded; 
}

delegate bool CheckMoveConditions()
{
	return true;
}

function bool CheckMoveConditionsOnAutoAttack()
{
	// keep auto attack moving if 
	// - Attack conditions are true
	// - controlled unit is doing an AttackMove 
	//   or it isn't but it is still inside the chase radius
	//   (since aliens don't do attack moves the chase radius is always checked for them) 
	return  CheckAttackConditions()
			&& (bAttackMove || ReachedTarget(PreviousLocation, Unit.ChaseRadiusUU));
}

function bool CheckMoveConditionsOnAttack()
{
	// Just use the AttackConditions as MoveConditions for state Attack,
	// since they don't require a special check as AutoAttack does
	return CheckAttackConditions();
}

function bool CheckMoveConditionsOnUsingAbilityOnLocation()
{
	return !Unit.bSilenced; 
}

function bool CheckMoveConditionsOnUsingAbilityOnUnit()
{
	return  !Unit.bSilenced
			&& OrderedAbilityTargetingUnit.TargetUnit != none
			&& OrderedAbilityTargetingUnit.TargetUnit.Health > 0
			&& HWPawn(OrderedAbilityTargetingUnit.TargetUnit) == none
			|| !HWPawn(OrderedAbilityTargetingUnit.TargetUnit).bCloaked;
}

/** 
 *  Delegate function used to sort an array of AggroEntries by their AggroFactor. 
 *  Returns -1 if A's AggroFactor is less then B's, 0 otherwise.
 *  This causes a list to be sorted from the highest AggroFactor to the lowest.
 */
delegate int SortByAggroFactor(AggroEntry A, AggroEntry B)
{
	return A.AggroFactor < B.AggroFactor ? -1 : 0; 
}

/** Updates the AggroFactor of all entries in AggroEntries based on the passed DeltaTime. */
function UpdateAggro(float DeltaTime)
{
	local int Index;
	local bool bAttackNewTarget; // Flag to show if any updated entry has more aggro than the first entry and should be attacked

	for(Index = 0; Index < AggroEntries.Length && AggroEntries.Length > 0; Index++)
	{
		// Check whether any aggro entries have exceeded the grace period
		if(`Timesince(AggroEntries[Index].LastAggroHitTime) > AggroFactorDecreaseGracePeriod)
		{
			// and if so, decrease their magnitude
			if(AggroEntries[Index].AggroFactor > 0)
			{
				AggroEntries[Index].AggroFactor -= AggroFactorDecreaseSpeed * DeltaTime;

				// Remove the entry
				if(AggroEntries[Index].AggroFactor < 0)
				{
					AggroEntries.Remove(Index, 1);
					Index--;
				}
				// If the updated entry has more aggro than the first entry evaluate the aggro table again after the loop
				else if(AggroEntries[Index].AggroFactor > AggroEntries[0].AggroFactor)
				{
					bAttackNewTarget = true;
				}
			}
		}
	}

	// Sort the AggroEntries array and attack the first entry (which must be any of the entries which set bAttackNewTarget to true)
	if(bAttackNewTarget)
	{
		AggroEntries.Sort(SortByAggroFactor);

		HearNoise(1.0f, AggroEntries[0].Attacker);
	}
}

/** 
 *  Adds a new aggro entry for a potential target, or adds to the aggro of an existing entry if one is found. 
 *  Returns the AggroFactor of the Attacker.
 */
function float AddToAggro(HWPawn Attacker, float DamagePercent)
{
	local int Index;
	local AggroEntry NewAggroEntry;

	if(Attacker == none)		
	{
		`Log(self@"ERROR AddToAggro() The passed Attacker is none!");

		return 0;
	}

	// Check if the given Attacker already has a corresponding entry
	Index = AggroEntries.Find('Attacker', Attacker);

	// If the Attacker already exists just update it and return
	if(Index != -1)
	{
		AggroEntries[Index].AggroFactor+=DamagePercent;
		AggroEntries[Index].LastAggroHitTime=WorldInfo.TimeSeconds;

		return AggroEntries[Index].AggroFactor;
	}

	NewAggroEntry.Attacker=Attacker;
	NewAggroEntry.AggroFactor=DamagePercent;
	NewAggroEntry.LastAggroHitTime=WorldInfo.TimeSeconds;

	AggroEntries.AddItem(NewAggroEntry);

	return NewAggroEntry.AggroFactor;
}

/** Removes the given Attacker from the aggro table if it exists. */
function RemoveFromAggro(HWPawn Attacker)
{
	local int Index;

	Index = AggroEntries.Find('Attacker', Attacker);

	if(Index != -1)
	{
		AggroEntries.Remove(Index, 1);
	}
}

/**
 * Searches for the AggroEntry with the most aggro in the specified range from the location.
 * Only the 2D distance is considered (the Z component is assumed to be 0).
 * Returns true if an AggroEntry was found, false if not.
 * 
 * @param ReferenceLocation
 *      The reference location
 *      
 * @param Range
 *      The required range from the reference location (in UU)
 *
 * @param AggroEntryInRange
 *      The first AggroEntry in range
 *      
 * @param Sort
 *      If to sort the AggroEntries array (only required if not already presorted)
 */
function bool GetFirstAggroEntryInRange(Vector ReferenceLocation, float Range, out AggroEntry AggroEntryInRange, optional bool Sort = false)
{
	local AggroEntry currentAE;
	local float distance;

	if(Sort)
	{
		AggroEntries.Sort(SortByAggroFactor);
	}

	// Iterating from start to end implicitly finds the entry with the most aggro (if the aggro table is sorted)
	foreach AggroEntries(currentAE)
	{
		distance = VSize2D(ReferenceLocation - currentAE.Attacker.Location);
		if(distance <= Range)
		{
			AggroEntryInRange = currentAE;

			return true;
		}
	}

	return false;
}

/**
 * Does nothing, it's just implemented to prevent Kismet warnings (Warning: Obj HWAIController_52 has no handler for SeqAct_ToggleCinematicMode_0).
 * This is because a SeqAct_ToggleCinematicMode uses a SeqVar_Player in order to find all existing Controllers (PlayerController & AIController).
 * If the Controller doesn't have a pawn OnToggleCinematicMode is called on the Controller instead, which leads to the warning.
 */
function OnToggleCinematicMode(SeqAct_ToggleCinematicMode Action)
{
	// do nothing
}

auto state Idle
{
	/** Hides the old order target destination and stops the controlled unit. */
	event BeginState(name PreviousStateName)
	{
		if (Unit != none)
		{
			UnstuckTries = 0;

			OrderTargetUnit = none;
			OrderTargetSelectable = none;
			OrderedAbility = none;
			OrderedAbilityTargetingUnit = none;
			OrderedAbilityTargetingLocation = none;
			bAbilityTriggered = false;
			CurrentOrder = O_None;
			bAttackMove = false;
			PreviousLocation = vect(0,0,0);

			Unit.ZeroMovementVariables();
			Focus = none;

			// Stop weapon fired effects
			Unit.ClearFlashCount(none);
		}
	}
}

/** State that ignores all further orders while the attached squad member is being dismissed. */
state Dismissing extends Idle
{
	ignores HearNoise, IssueAbilityOrder, IssueAttackMoveOrder, IssueAttackOrder, IssueMoveOrder, IssueStopOrder, IssueHoldPositionOrder, IssueDismissOrder;
}

/** 
 *  State that wraps the latent MoveTo() function and reacts on HearNoise() calls. 
 *  MoveTo() is called without the DestinationOffset parameter.
 */
state AttackMoveTo
{
Begin:
	MoveTo(OrderTargetDestination);
	PopState();
}

/** State that wraps the latent MoveTo() function and ignores HearNoise() calls. */
state MoveToLocation extends AttackMoveTo
{
	ignores HearNoise;
}

/** 
 *  State that wraps the latent MoveTo() function and reacts on HearNoise() calls. 
 *  MoveTo() is called with the DestinationOffset parameter.
 */
state MoveToLocationWithOffset
{
	ignores HearNoise;

Begin:
	// DestinationOffset must be reduced by some offset (e.g. DestinationOffsetDefault, which is the units collision radius),
	// since MoveTo() returns before reaching the original offset from the location.
	// Not reducing it can cause the Pawn to never reach the location with the original offset and would trigger
	// the unstuck logic in AttackMove.
	MoveTo(OrderTargetDestination, none, DestinationOffset - DestinationOffsetDefault);
	PopState();
}

/** State that wraps the latent MoveToward() function and reacts on HearNoise() calls. */
state AttackMoveTowardActor
{
Begin:
	// DestinationOffset must be reduced by some offset (e.g. DestinationOffsetDefault, which is the units collision radius),
	// since MoveToward() returns before reaching the original offset from the unit.
	// Not reducing it can cause the Pawn to never reach the location with the original offset and would trigger
	// the unstuck logic in AttackMove.
	MoveToward(OrderTargetSelectable, OrderTargetSelectable, DestinationOffset - DestinationOffsetDefault);
	PopState();
}

/** State that wraps the latent MoveToward() function and ignores HearNoise() calls. */
state MoveTowardActor extends AttackMoveTowardActor
{
	ignores HearNoise;
}

/** 
 *  State that tries to solve stuck situations by either waiting some time
 *  or trying to move onto an intermediate location.
 */
state SolveStuck
{
	ignores HearNoise;

Begin:
	FramesBeingStuck = 0;								

	UnstuckTries++;

	`log(`location@"WARNING Unit stuck at"@Unit.Location@"IsAnchorInescapable:"@NavigationHandle.IsAnchorInescapable()@"UnstuckTries:"@UnstuckTries@"OrderTargetDestination:"@OrderTargetDestination);

	switch(UnstuckTries)
	{
		case 1:
			// Often the path becomes clear after waiting some time
			Sleep(UNSTUCK_WAIT_TIME);
			goto('Begin');
			break;

		case 2:
			Sleep(2 * UNSTUCK_WAIT_TIME);
			goto('Begin');
			break;

		case 3:			
		case 4:
		case 5:
			// Move to a random location in order to unstuck
			PushState('UnstuckMove');

			// Return to previous move state
			PopState();
			break;

		default:
			// Stop trying
			IssueStopOrder();
			break;
	}
}

/**
 * The base movement state all other movement states shall derive from.
 * The base implementation moves the unit onto OrderTargetDestination
 * and reacts on HearNoise() calls (auto attacking enemies on the way).
 */
state AttackMove
{
	event BeginState(name PreviousStateName)
	{
		InitState();
	}

	event PushedState()
	{
		InitState();
	}
	/** 
	 *  Init any state specific variables here. 
	 *  Caution: any substate should overwrite this and set it's own DestinationOffset.
	 *  Failing to do so can cause reachability problems (e.g. Units never reaching their target),
	 *  since the default logic expects to get as close as the DestinationOffsetDefault.
	 */
	function InitState()
	{
		FramesBeingStuck = 0;

		// Use the default implementation of CheckMoveConditions if none
		if(OnCheckMoveConditions == none)
		{
			OnCheckMoveConditions = CheckMoveConditions;
		}

		DestinationOffset = DestinationOffsetDefault;	
	}

	/**
	 * Must be overriden by substates in order to find specific paths (e.g. to unit).
	 * The base implementation calls FindPathToLocation().
	 */
	function bool FindPath()
	{
		local bool result;

		// If no path could be found to OrderTargetDestination,
		// try to find a path to a nearby location
		if(!FindPathToLocation(OrderTargetDestination, DestinationOffset))
		{
			`log(`location@"Couldn't find path to orginal location! Unit.Location:"@Unit.Location@"OrderTargetDestination:"@OrderTargetDestination);

			// Find a valid nearby location
			UnstuckLocations.Length = 0; // Reset the array before usage
			class'NavigationHandle'.static.GetValidPositionsForBox(OrderTargetDestination, VALID_LOCATION_SEARCH_RADIUS, Unit.GetCollisionExtent(), false, UnstuckLocations, 1);

			if(UnstuckLocations.Length > 0)
			{
				OrderTargetDestination = UnstuckLocations[0];

				`log(`location@"Found alternative location! Unit.Location:"@Unit.Location@"OrderTargetDestination:"@OrderTargetDestination);

				// Try to reach the new position and return the result
				result = FindPathToLocation(OrderTargetDestination, DestinationOffset);

				if(!result)
				{
					`log(`location@"Couldn't find path to alternative location! Unit.Location:"@Unit.Location@"OrderTargetDestination:"@OrderTargetDestination);
				}

				return result;
			}
			else
			{
				`log(`location@"No alternative location found!");

				return false;
			}
		}

		return true;
	}

	/**
	 * Must be overriden by substates in order to check if the Target (e.g. unit) was reached
	 * with an acceptable offset.
	 * The base implementation checks if OrderTargetDestination was reached.
	 */
	function bool TargetReached()
	{
		return ReachedTarget(OrderTargetDestination, DestinationOffset);
	}
	
	/**
	 * Must be overriden by substates in order to check if the Target (e.g. unit) is directly reachable.
	 * The base implementation checks if OrderTargetDestination is directly reachable.
	 */
	function bool TargetDirectlyReachable()
	{
		return NavigationHandle.PointReachable(OrderTargetDestination, Unit.Location);
	}

	/**
	 * Must be overriden by substates in order to push the correct intermediate movement state on the stack.
	 * The base implementation pushes AttackMoveTo on OrderTargetDestination on the stack.
	 */
	function MoveToTarget()
	{
		PushState('AttackMoveTo');
	}

	/**
	 * Must be overriden by substates in order to provide handling of stuck situations.
	 * The base implementation pushes SolveStuck on the stack.
	 */
	function OnStuck()
	{
		//PushState('SolveStuck');
	}

	/**
	 * Must be overriden by substates in order to provide functionality on how to proceed if the state was ended.
	 * The base implementation goes to state Idle.
	 */
	function OnEnd()
	{
		GotoState('Idle');
	}

Begin:
	if (FindPath())
	{
		//NavigationHandle.DrawPathCache(,true);
		//NavigationHandle.bUltraVerbosePathDebugging = true;

		// keep moving until we reached destination
		while (Unit != None && !TargetReached())
		{
			//if(CheckIfStuck())
			//{
			//	OnStuck();

			//	`log(`location@"STUCK! Finding new path!");

			//	// Call FindPath() after the stuck handling to intitialize the NavigationHandle correctly again
			//	// (since an UnstuckMove could have changed it)
			//	FindPath();
			//}

			// Check if any move conditions prevent further movement
			if(!OnCheckMoveConditions())
			{
				OnEnd();
			}

			if (TargetDirectlyReachable())
			{	
				LastValidLocation = Unit.Location;					

				MoveToTarget();
			}
			else
			{
				// move to the next node on the path
				if (NavigationHandle.GetNextMoveLocation(NextMoveLocation, DestinationOffset))
				{
					//DrawDebugLine(Unit.Location, OrderTargetDestination,0,255,0,true);
					//DrawDebugSphere(OrderTargetDestination,16,20,0,255,0,true);

					// SuggestMovePreparation returns true when the edge's logic will move the actor, and
					// false if we should run there ourselves
					if(!NavigationHandle.SuggestMovePreparation(NextMoveLocation, self))
					{
						LastValidLocation = Unit.Location;

						MoveTo(NextMoveLocation);
					}
				}
				else
				{
					`log(`location@"GetNextMoveLocation() returned false! Location"@Unit.Location
						@"OrderTargetDestination:"@OrderTargetDestination@"IsAnchorInescapable:"@NavigationHandle.IsAnchorInescapable()@"LastValidLocation:"@LastValidLocation);

					if(NavigationHandle.IsAnchorInescapable())
					{
						// Warp to the last valid location and stop
						Unit.SetLocation(LastValidLocation);

						`log(`location@"Warping to LastValidLocation! Location:"@
							Unit.Location@"OrderTargetDestination:"@OrderTargetDestination@"LastValidLocation:"@LastValidLocation);

						GotoState('Idle');
					}
					else
					{
						// Try to find a new path once, stop if no path could be found
						if(!FindPath())
						{
							`warn(`location@"Failed to find a path from"@Unit.Location@"to"@OrderTargetDestination@"IsAnchorInescapable:"@NavigationHandle.IsAnchorInescapable());

							GotoState('Idle');
						}
					}
				}
			}
		}
	}
	else
	{
		// no path could be found!
		if(Unit.OwningPlayer != none)
		{
			Unit.OwningPlayer.ShowErrorMessage(ErrorCannotMoveThere);
		}

		`warn(`location@"Failed to find a path from"@Unit.Location@"to"@OrderTargetDestination@"IsAnchorInescapable:"@NavigationHandle.IsAnchorInescapable());
	}

	// order complete		
	OnEnd();
}

/** 
 * State that moves the unit onto the set OrderTargetDestination
 * and ignores on HearNoise() calls.
 */
state LocationMove extends AttackMove
{
	ignores HearNoise;

	function MoveToTarget()
	{
		PushState('MoveToLocation');
	}
}

/** 
 *  Intermediate state which can be pushed on the stack
 *  in order to move toward OrderTargetSelectable. 
 */
state ActorMove extends AttackMove
{
	ignores HearNoise;

	function InitState()
	{
		FramesBeingStuck = 0;

		// It's necessary to overwrite AttackMove.InitState in order to prevent overwriting of DestinationOffset.
		// Since ActorMove is only used as intermediate state,
		// it's ok to use the configuration (DestinationOffset etc.) set by the originating state.
	}

	function bool FindPath()
	{
		local bool foundNearbyLocation;
		local int i;
		local Vector offsetVector;

		// If no path could be found to OrderTargetDestination,
		// try to find a path to a position nearby
		if(!FindPathToUnit(OrderTargetSelectable, DestinationOffset))
		{
			// If OrderTargetSelectable stands on the obstacle mesh, 
			// try to find a nearby valid location that lies on the line from OrderTargetSelectable to the Unit
			// (necessary to enclose on HWArtifacts)
			// (NavigationHandle.ObstacleLineCheck() can't be used as it seems to be buggy and doesn't return the first valid location)
			offsetVector = Normal(Unit.Location - OrderTargetSelectable.Location);
			offsetVector *= Unit.GetCollisionExtent();
			OrderTargetDestination = OrderTargetSelectable.Location;

			// advance from OrderTargetSelectable.Location in 10 steps of collision extend size
			for(i = 0; i < 10; i++)
			{
				OrderTargetDestination += offsetVector;

				// Stop if location isn't on the obstacle mesh
				if(NavigationHandle.ObstaclePointCheck(OrderTargetDestination, Unit.GetCollisionExtent()))	
				{
					//DrawDebugBox(OrderTargetDestination, Unit.GetCollisionExtent(), 255, 0, 0, true);
					foundNearbyLocation = true;
					break;
				}
				else
				{
					//DrawDebugBox(OrderTargetDestination, Unit.GetCollisionExtent(), 0, 255, 0, true);
				}
			}
		
			if(foundNearbyLocation)
			{
				return FindPathToLocation(OrderTargetDestination, DestinationOffset);
			}
			else
			{
				return false;
			}
		}

		return true;
	}

	function bool TargetReached()
	{
		if(OrderTargetSelectable == none)
		{
			return true;
		}

		return ReachedTarget(OrderTargetSelectable.Location, DestinationOffset);
	}
	
	function bool TargetDirectlyReachable()
	{
		return NavigationHandle.ActorReachable(OrderTargetSelectable);
	}

	function MoveToTarget()
	{
		PushState('MoveTowardActor');
	}

	function OnEnd()
	{
		PopState();
	}
}

/**
 * State used to move onto a target ability location with a specific offset.
 */
state AbilityMove extends AttackMove
{
	ignores HearNoise;	

	function InitState()
	{
		super.InitState();

		DestinationOffset = OrderedAbility.Range;
	}

	function MoveToTarget()
	{
		PushState('MoveToLocationWithOffset');
	}

	function OnEnd()
	{
		PopState();
	}
}

/**
 * State used to move the unit onto an intermediate location if stuck.
 * This state shall only assumed by pushing it on the stack.
 */
state UnstuckMove extends AttackMove
{
	ignores HearNoise;

	event PushedState()
	{
		// Backup the original OrderTargetDestination
		OrderTargetDestinationOriginal = OrderTargetDestination;

		// Find a temporary location to move on in order to unstuck
		if(!GetUnstuckLocation(OrderTargetDestination))
		{
			`log(`location@"WARNING GetUnstuckLocation() didn't find a valid location at"@Unit.Location);

			PopState();
		}
	}

	event PoppedState()
	{
		// Restore the original OrderTargetDestination 
		// (only necessary for location moves, unit moves ignore this)
		OrderTargetDestination = OrderTargetDestinationOriginal;
	}

	function OnStuck()
	{
		PopState();
	}

	function OnEnd()
	{
		PopState();
	}
}

/**
 * Base Attack state other attack states must derive from.
 * Go to this state if the unit shall automatically attack an enemy unit.
 */
state AutoAttack
{
	ignores CheckForAutoCast;
	
	event BeginState(name PreviousStateName)
	{
		InitState();
	}

	event EndState(name NextStateName)
	{
		LeaveState();
	}

	event PushedState()
	{
		InitState();
	}

	event PoppedState()
	{
		LeaveState();
	}

	function InitState()
	{
		// set PreviousLocation if not doing an AttackMove
		if(!bAttackMove)
		{
			PreviousLocation = Unit.Location;
		}

		FramesBeingStuck = 0;
		Unit.ZeroMovementVariables();		
		Unit.NotifyEnemyEngaged();
		OrderTargetSelectable = OrderTargetUnit;

		DestinationOffset = Unit.Range;

		// Use specific MoveConditions
		OnCheckMoveConditions = CheckMoveConditionsOnAutoAttack;
	}

	function LeaveState()
	{	
		Unit.StopAttack();

		// Reset OnCheckMoveConditions to the default implementation
		OnCheckMoveConditions = CheckMoveConditions;

		// TODO MK Remove for toggleable bIsHoldingPosition
		if(HWSquadMember(Unit) != none)
		{
			bIsHoldingPosition = true;
		}
	}

	function OnEnd()
	{	
		if(bAttackMove)
		{
			IssueAttackMoveOrder(OrderTargetDestination);
		}
		// Only issue a move order onto the PreviousLocation if not already close by
		else if(!ReachedTarget(PreviousLocation, DestinationOffset))
		{
			IssueMoveOrder(PreviousLocation);
		}
		else
		{
			GoToState('Idle');
		}
	}

Begin:
	if (Unit.bShouldFocusTarget)
	{
		Focus = OrderTargetUnit;
	}

	// keep attacking while the attack conditions are true
	while (CheckAttackConditions())
	{
		// Leave if the MoveConditions aren't valid
		if(!OnCheckMoveConditions())
		{
			OnEnd();
		}

		// check if we are in range
		if (ReachedTarget(OrderTargetUnit.Location, DestinationOffset))
		{
			if (!Unit.bAttackOnCooldown)
			{
				// attack is ready, attack and wait
				Unit.Attack(OrderTargetUnit);
				Sleep(Unit.Cooldown);
			}
			else
			{
				// wait for the attack to be cooled down
				Sleep(Unit.GetRemainingAttackCooldown());
			}
		}
		else
		{
			// don't chase if the unit is holding its position
			if(bIsHoldingPosition)
			{
				OnEnd();
			}

			// Stop attacking if trying to find a path
			if(Unit.bIsAttacking)
			{
				Unit.StopAttack();
			}

			// Move to the actor
			PushState('ActorMove');

			// Leave state if OrderTargetUnit exists and ActorMove failed to reach the target
			if (OrderTargetUnit == none || !ReachedTarget(OrderTargetUnit.Location, DestinationOffset))
			{
				OnEnd();
			}
			else
			{
				Unit.ZeroMovementVariables();
			}
		}
	}

	// target is dead, order complete
	OnEnd();
}

/** 
 *  Attack state which ignores HearNoise() calls.
 *  Go to this state if the unit shall explicitly attack an enemy unit due to an attack order.
 *  */
state Attack extends AutoAttack
{
	// Don't switch targets if attacking an enemy
	ignores HearNoise;

	function InitState()
	{		
		FramesBeingStuck = 0;
		Unit.ZeroMovementVariables();		

		DestinationOffset = Unit.Range;

		// Use specific MoveConditions 
		OnCheckMoveConditions = CheckMoveConditionsOnAttack;
	}

	function OnEnd()
	{	
		GoToState('Idle');
	}
}

/** 
 *  Base "UseAbility" state which provides functionality to trigger an OrderedAbilityTargetingLocation.
 */
state UsingAbilityOnLocation
{
	ignores HearNoise;

	event BeginState(name PreviousStateName)
	{
		InitState();
	}

	event EndState(name NextStateName)
	{	
		// Reset OnCheckMoveConditions to the default implementation
		OnCheckMoveConditions = CheckMoveConditions;
	}

	function InitState()
	{
		FramesBeingStuck = 0;
		Unit.ZeroMovementVariables();		
		OrderTargetDestination = OrderedAbilityTargetingLocation.TargetLocation;

		DestinationOffset = OrderedAbility.Range + DestinationOffsetDefault;

		// Use specific MoveConditions
		OnCheckMoveConditions = CheckMoveConditionsOnUsingAbilityOnLocation;
	}

	function LeaveState()
	{
		OrderedAbility.bBeingActivated = false;
		GotoState('Idle');
	}

	function bool CheckAbilityConditions()
	{
		// keep trying to apply the ability as long it isn't triggered and the unit isn't silenced
		return !bAbilityTriggered && !Unit.bSilenced; 
	}

	function bool TargetReached()
	{
		return ReachedTarget(OrderTargetDestination, DestinationOffset);
	}

	function TriggerAbility()
	{
		OrderedAbility.TriggerAbility();
		bAbilityTriggered = true;
	}

	function MoveToTarget()
	{
		PushState('AbilityMove');
	}

	Begin:
		// keep trying to use the ability
		while (CheckAbilityConditions())
		{
			// check if we are in range
			if (TargetReached())
			{
				TriggerAbility();
			}
			else
			{
				MoveToTarget();

				// Leave state if move failed to reach the target
				if (TargetReached())
				{
					Unit.ZeroMovementVariables();
				}
				else
				{	
					LeaveState();
				}
			}
		}

		LeaveState();
}

/** State which provides functionality to use a OrderedAbilityTargetingUnit. */
state UsingAbilityOnUnit extends UsingAbilityOnLocation
{
	ignores HearNoise;

	function InitState()
	{
		FramesBeingStuck = 0;
		Unit.ZeroMovementVariables();

		if (Unit.bShouldFocusTarget)
		{
			Focus = OrderedAbilityTargetingUnit.TargetUnit;
		}

		OrderTargetUnit = HWPawn(OrderedAbilityTargetingUnit.TargetUnit);
		OrderTargetSelectable = OrderedAbilityTargetingUnit.TargetUnit;

		DestinationOffset = OrderedAbility.Range;

		// Use specific MoveConditions
		OnCheckMoveConditions = CheckMoveConditionsOnUsingAbilityOnUnit;
	}

	function bool CheckAbilityConditions()
	{
		return  !bAbilityTriggered 
				&& !Unit.bSilenced
				&& OrderedAbilityTargetingUnit.TargetStillValid();
	}

	function bool TargetReached()
	{
		return ReachedTarget(OrderedAbilityTargetingUnit.TargetUnit.Location, OrderedAbility.Range);
	}

	function TriggerAbility()
	{
		OrderedAbility.TriggerAbility();
		
		if (OrderedAbility.IsA('HWChanneledAbility'))
		{
			GotoState('Channeling');
		}
		else
		{
			bAbilityTriggered = true;
		}
	}

	function MoveToTarget()
	{
		PushState('ActorMove');
	}
}

state Charging
{
	// assure that state is left properly - nothing can stop us now!
	ignores HearNoise, IssueAbilityOrder, IssueAttackMoveOrder, IssueAttackOrder, IssueMoveOrder, IssueStopOrder;

	event BeginState(name PreviousStateName)
	{
		FramesBeingStuck = 0;
	}
	
	Begin:
		`log(Unit$" starts charging "$OrderedAbilityTargetingUnit.TargetUnit);

		// Start the StartUp animation
		Unit.PlayCustomAnimation(HWAb_Charge(OrderedAbilityTargetingUnit).AnimNameStartUp, , , 2.0);

		// Wait for the StartUp animation to finish
		FinishAnim(Unit.FullBodyAnimSlot.GetCustomAnimNodeSeq());

		// Loop the Sprint animation
		Unit.PlayCustomAnimation(HWAb_Charge(OrderedAbilityTargetingUnit).AnimNameSprint, , , 1.5 , , , true);

		// keep charging until we collide with the target
		while (OrderedAbilityTargetingUnit.TargetStillValid() && !TargetInRange(OrderedAbilityTargetingUnit.TargetUnit, Unit.GetCollisionRadius() + OrderedAbilityTargetingUnit.TargetUnit.GetCollisionRadius()))
		{
			// stop charging if silenced
			if(Unit.bSilenced)
			{
				break;
			}

			// try to find a path to the target unit
			if (FindPathToUnit(OrderedAbilityTargetingUnit.TargetUnit, Unit.GetCollisionRadius() + OrderedAbilityTargetingUnit.TargetUnit.GetCollisionRadius()))
			{
				// Pathcache contains a list of NavMesh edges only;
				// the actor needs to know where to go after it has passed the last edge
				NavigationHandle.SetFinalDestination(OrderedAbilityTargetingUnit.TargetUnit.Location);

				// show debug information
				//NavigationHandle.DrawPathCache(,true);

				// keep charging until we collide with the target
				while (Unit != None && !TargetInRange(OrderedAbilityTargetingUnit.TargetUnit, Unit.GetCollisionRadius() + OrderedAbilityTargetingUnit.TargetUnit.GetCollisionRadius()))
				{
					// stop charging if silenced
					if(Unit.bSilenced)
					{
						break;
					}

					if (NavigationHandle.ActorReachable(OrderedAbilityTargetingUnit.TargetUnit))
					{
						// then move directly to the destination
						MoveToward(OrderedAbilityTargetingUnit.TargetUnit, OrderedAbilityTargetingUnit.TargetUnit, DestinationOffsetDefault);
					}
					else
					{
						// move to the next node on the path
						if (NavigationHandle.GetNextMoveLocation(NextMoveLocation, Unit.GetCollisionRadius() + OrderedAbilityTargetingUnit.TargetUnit.GetCollisionRadius()))
						{
							// SuggestMovePreparation returns true when the edge's logic will move the actor, and
							// false if we should run there ourselves
							if (!NavigationHandle.SuggestMovePreparation(NextMoveLocation, self))
							{
								MoveTo(NextMoveLocation, none, Unit.GetCollisionRadius() + OrderedAbilityTargetingUnit.TargetUnit.GetCollisionRadius());
							}
						}
					}
				}
			}
			else
			{
				// no path could be found!
				`log("WARNING: Failed to find a path from "$Location$" to "$GetDestinationPosition());
				GotoState('Idle');
			}
		}

		// Only apply the effects if target still valid (not cloaked) and if own unit isn't silenced
		if(OrderedAbilityTargetingUnit.TargetStillValid() && !Unit.bSilenced)
		{
			// Start the Kick animation
			Unit.PlayCustomAnimation(HWAb_Charge(OrderedAbilityTargetingUnit).AnimNameKick, , , 1.5);

			// play sound
			HWPawn(OrderedAbilityTargetingUnit.TargetUnit).PlaySound(class'HWAb_Charge'.default.SoundKnockback);

			// Hack: approx. 1 second (original animation speed) until the kick animation is at its peek (kicknomove)
			Sleep(0.5f);		

			// knock target back (at peek of Kick animation)
			HWPawn(OrderedAbilityTargetingUnit.TargetUnit).KnockedBackBy
				(Unit,
				 HWAb_Charge(OrderedAbilityTargetingUnit).KnockbackMomentum,
				 HWAb_Charge(OrderedAbilityTargetingUnit).KnockbackDamage);

			// Wait for the Kick animation to finish
			FinishAnim(Unit.FullBodyAnimSlot.GetCustomAnimNodeSeq());

			// Stop the Kick animation (otherwise somehow the mesh pose is stuck on the last frame of the animation)
			Unit.PlayCustomAnimation(HWAb_Charge(OrderedAbilityTargetingUnit).AnimNameKick, , true);
		}
		// else stop the sprint animation (otherwise it loops endlessly)
		else
		{
			Unit.PlayCustomAnimation(HWAb_Charge(OrderedAbilityTargetingUnit).AnimNameSprint, , true);
		}

		// restore movement speed
		Unit.RemoveBuffByClass(class'HWBu_Charge');

		bAbilityTriggered = false;
		GotoState('Idle');
}

state Channeling
{
	// prohibit auto-attacks while channeling
	ignores HearNoise;

	/** 
	 *  Called whenever a channeling unit receives a new order.
	 *  Notifies the channeled ability that it has been interrupted.
	 */
	function InterruptChanneling()
	{
		local HWChanneledAbility a;

		a = HWChanneledAbility(OrderedAbility);

		if (a != none && a.bChanneling)
		{
			a.Interrupt();
		}
	}

	/** 
	 *  Called by abilities that finished or interrupted channeling.
	 *  Returns to the idle state.
	 */
	function StopChanneling()
	{
		bAbilityTriggered = false;
		GotoState('Idle');
	}

	Begin:
		if (HWChanneledAbility(OrderedAbility).TargetStillValid() 
			&& !Unit.bSilenced)
		{
			// wait for the channeling ability to complete
			Sleep(0.1);
			goto('Begin');
		}
		else
		{
			InterruptChanneling();
		}
}

State Dead
{
	// Prevent unnecessary overhead until controller instance is removed completely
	ignores UpdateAggro;
}

state RoundEnded
{
	ignores HearNoise, IssueAbilityOrder, IssueAttackMoveOrder, IssueAttackOrder, IssueMoveOrder, IssueStopOrder;
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == 'Unit' )	
	{
		if(Role < ROLE_Authority)
		{
			// On all clients set the Units controller to this HWAIController instance if the replicated Unit was changed (likely by the initial replication).
			// This is how replicated HWPawns on clients have their Controllers set (the default Unreal logic only replicates Pawn.Controller to the owning client).
			// If ReplicatedEvent() was called for Unit == None, it was destroyed on server.
			if(Unit != none)
			{
				Unit.Controller = self;
			}
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		Unit,
		
		// XXX quick fix for showing order target destinations; if running into performance issues, may want to have a look at this again
		CurrentOrder, OrderTargetDestination, OrderTargetUnit, OrderedAbilityTargetingUnit, OrderedAbilityTargetingLocation,

		bIsHoldingPosition;
}

DefaultProperties
{
	RemoteRole = ROLE_AutonomousProxy; // This is necessary because otherwise using SimulatedProxy issuing MoveOrders doesn't work anymore if a 2nd client joins the game (on all client!)
	bAlwaysRelevant = true; // this is necessary in order to replicate HWAIController and its Unit variable to all clients	

	AggroFactorDecreaseGracePeriod=10;
	AggroFactorDecreaseSpeed=0.1;

	OnCheckMoveConditions = CheckMoveConditions;
}
