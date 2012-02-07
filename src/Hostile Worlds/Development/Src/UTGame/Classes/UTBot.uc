/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTBot extends UDKBot
	dependson(UTCharInfo);

// AI Magic numbers - distance based, so scale to bot speed/weapon range
const MAXSTAKEOUTDIST = 2000;
const ENEMYLOCATIONFUZZ = 1200;
const TACTICALHEIGHTADVANTAGE = 320;
const MINSTRAFEDIST = 200;
const MINVIEWDIST = 200;
const AngleConvert = 0.0000958738;	// 2*PI/65536

/** shooter of instant hit weapon we're trying to dodge (@see DelayedInstantWarning()) */
var Pawn InstantWarningShooter;

var float	LastWarningTime;	/** Last time a warning about a shot being fired at my pawn was accepted. */

//AI flags
var		bool		bHuntPlayer;		// hunting player
var		bool		bCanFire;			// used by TacticalMove and Charging states
var		bool		bStrafeDir;
var		bool		bChangeDir;			// tactical move boolean
var		bool		bFrustrated;
var		bool		bInitLifeMessage;
var		bool		bReachedGatherPoint;
var		bool		bTacticalDoubleJump;
var		bool		bWasNearObjective;
var		bool		bHasFired;
var		bool		bForcedDirection;
var		bool		bFireSuccess;
var		bool		bStoppedFiring;
var		bool		bMustCharge;
var		bool		bPursuingFlag;
var		bool		bJustLanded;
var		bool		bRecommendFastMove;
var		bool		bIgnoreEnemyChange;		// to prevent calling whattodonext() again on enemy change
var		bool		bHasSuperWeapon;
var		bool		bPendingDoubleJump;
var		bool		bAllowedToImpactJump;
var		bool		bScriptedFrozen;
var		bool		bSendFlagMessage;
var		bool		bForceNoDetours;
var		bool		bShortCamp;
var		bool		bBetrayTeam;


/** set to true for bots created by Kismet scripts; prevents them from checking for too many bots or unbalanced teams
	also causes them to be destroyed on death instead of respawning */
var bool bSpawnedByKismet;

/** impact hammer properties */
var		Actor		ImpactTarget;
var		float		ImpactJumpZ; // if > 0, we have an impact hammer and it will give us this much Z speed

/** maximum jump Z velocity bot can attain using special abilities (jump boots, impact jumping, etc) */
var		float		MaxSpecialJumpZ;

var name	OldMessageType;
var int		OldMessageID;
var int		LastTauntIndex;

/** Temp holder for sending killed vehicle messages */
var class<UTVehicle> KilledVehicleClass;

// Advanced AI attributes.
var	vector			HidingSpot;
var	float			Aggressiveness;		// 0.0 to 1.0 (typically)
var float			LastAttractCheck;
var NavigationPoint BlockedPath;
var	float			AcquireTime;		// time at which current enemy was acquired
var float			Aggression;
var float			LoseEnemyCheckTime;
var actor			StartleActor;
var	float			StartTacticalTime;
var float			LastUnderFire;
var float			RetreatStartTime;
var float			ForcedFlagDropTime;	// time when bot was forced to drop flag

// modifiable AI attributes
var float			BaseAlertness;
var float			Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var	float		    BaseAggressiveness; // 0 to 1 (0.3 default, higher is more aggressive)
var	float			StrafingAbility;	// -1 to 1 (higher uses strafing more)
var	float			CombatStyle;		// -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
var float			Tactics;
var float			ReactionTime;
var float			Jumpiness;			// 0 to 1
var class<Weapon>	FavoriteWeapon;
var float OldMessageTime;				// to limit frequency of voice messages

// Team AI attributes
var string			GoalString;			// for debugging - used to show what bot is thinking (with 'ShowDebug')
var string			SoakString;			// for debugging - shows problem when soaking

/** linked list of members of this squad */
var UTBot			NextSquadMember;

/** set when bot is done waiting at gather point for more attackers */
var bool bFinalStretch;

var float			ReTaskTime;			// time when squad will retask bot (delayed to avoid hitches)

var UTDefensePoint DefensePoint;	// DefensePoint to which bot is assigned (assigned by TeamAI)
var NavigationPoint DefensivePosition;

/** if RouteGoal == NoVehicleGoal, don't use a vehicle to get there */
var Actor NoVehicleGoal;

var		vector		DirectionHint;	// used to help pick which side of vehicle to get out of

var float		StopStartTime;
var float		LastRespawnTime;
var float		FailedHuntTime;
var Pawn		FailedHuntEnemy;
/** if set bot ignores Squad recommendation of spots to look for enemy while hunting */
var bool bDirectHunt;

// inventory searh
var float		LastSearchTime;
var float		LastSearchWeight;
var float		CampTime;
/** transient flag that indicates inventory search is for vehicle driver, not Pawn */
var transient bool bCheckDriverPickups;

var int		NumRandomJumps;			// attempts to free bot from being stuck

// weapon check
var float LastFireAttempt;
var float GatherTime;

var() name OrderNames[16];
var name OldOrders;
var Controller OldOrderGiver;

// 1vs1 Enemy location model
var vector LastKnownPosition;
var vector LastKillerPosition;

/** if set, bot always shoots at it (for Kismet scripts) */
var Actor ScriptedTarget;

/** Last time bot sent an action music event to a player */
var float LastActionMusicUpdate;

/** last time bot tried to use hoverboard, so we don't get stuck if it fails to spawn for whatever reason */
var float LastTryHoverboardTime;

/** last target bot fired at */
var Actor LastFireTarget;
/** transient flag for TimedFireWeaponAtEnemy() to indicate that the weapon firing code already reset the combat timer */
var transient bool bResetCombatTimer;

/** Last time weapon's CanAttack() was checked for firing again */
var float LastCanAttackCheckTime;

var float LastInjuredVoiceMessageTime;

/* epic ===============================================
* ::EnemyJustTeleported
*
* Notification that Enemy just went through a teleporter.
*
* =====================================================
*/
function EnemyJustTeleported()
{
	local EnemyPosition NewPosition;

	LineOfSightTo(Enemy);
	SavedPositions.Remove(0,SavedPositions.Length);
	NewPosition.Position = Enemy.GetTargetLocation();
	NewPosition.Velocity = Enemy.Velocity;
	NewPosition.Time = WorldInfo.TimeSeconds;
	SavedPositions[0] = NewPosition;
}

function WasKilledBy(Controller Other)
{
	if ( (Other != None) && (Other.Pawn != None) )
		LastKillerPosition = Other.Pawn.Location;
}

function StartMonitoring(Pawn P, float MaxDist)
{
	MonitoredPawn = P;
	MonitorStartLoc = P.Location;
	MonitorMaxDistSq = MaxDist * MaxDist;
}

function PawnDied(Pawn P)
{
	if ( Pawn != P )
		return;

	PendingMover = None;
	Super.PawnDied(P);
}

function Destroyed()
{
	if (Pawn != None)
	{
		Pawn.Suicide();
	}
	if ( Squad != None )
		UTSquadAI(Squad).RemoveBot(self);
	if ( DefensePoint != None )
		DefensePoint.FreePoint();
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCombatTimer();
	Aggressiveness = BaseAggressiveness;
	if ( UTGame(WorldInfo.Game).bSoaking )
		bSoaking = true;
}

event SpawnedByKismet()
{
	bSpawnedByKismet = true;
	if (Pawn != None)
	{
		Pawn.MaxDesiredSpeed = 1.0;
	}
}

/** LandingShake()
returns true if controller wants landing view shake
*/
simulated function bool LandingShake()
{
	return true;
}

/** @return whether bot has an inventory item with a timer on it */
function bool HasTimedPowerup()
{
	local Vehicle V;

	if (Pawn.FindInventoryType(class'UTTimedPowerup', true) != None)
	{
		return true;
	}
	else
	{
		V = Vehicle(Pawn);
		if (V != None && V.Driver != None)
		{
			return (V.Driver.FindInventoryType(class'UTTimedPowerup', true) != None);
		}
		else
		{
			return false;
		}
	}
}

function NotifyAddInventory(inventory NewItem)
{
	if ( bHasSuperWeapon )
		return;

	bHasSuperWeapon = (UTWeapon(NewItem) != None && UTWeapon(NewItem).bSuperWeapon);
}

/* called before start of navigation network traversal to allow setup of transient navigation flags
*/
event SetupSpecialPathAbilities()
{
	bAllowedToImpactJump = CanImpactJump();

	if ( Pawn.bCanJump )
	{
		// initial max jump height is the pawn's JumpZ, or impact jump height if we can impact jump
		MaxSpecialJumpZ = Pawn.JumpZ;
		if (bAllowedToImpactJump)
		{
			MaxSpecialJumpZ += ImpactJumpZ;
		}
		if ( (UTPawn(Pawn) != None) && UTPawn(Pawn).bCanDoubleJump )
		{
			// add in multijump height
			// FIXME: account for greater than double jump
			MultiJumpZ = (Pawn.JumpZ * 0.3) + UTPawn(Pawn).MultiJumpBoost;
			MaxSpecialJumpZ += MultiJumpZ;
		}
		else
		{
			MultiJumpZ = 0.f;
		}
	}
	else
	{
		MaxSpecialJumpZ = 0.f;
	}
}

event bool NotifyHitWall(vector HitNormal, actor Wall)
{
	local vector JumpDir;
	local UTCarriedObject Flag;

	if ( (UTPawn(Pawn) != None) && (Pawn.Physics == PHYS_Swimming) )
	{
		if ( InLatentExecution(LATENT_MOVETOWARD) && (Movetarget != None)
			&& !MoveTarget.PhysicsVolume.bWaterVolume && !Pawn.HeadVolume.bWaterVolume )
		{
			JumpDir = Movetarget.Location - Pawn.Location;
			JumpDir.Z = 0;
			ImpactVelocity = vect(0,0,0);
			Pawn.JumpOutOfWater(Normal(JumpDir));
			bNotifyApex = true;
			bPendingDoubleJump = true;
		}
	}

	LastBlockingVehicle = Vehicle(Wall);
	if (LastBlockingVehicle != None && Vehicle(Pawn) == None)
	{
		// if the flag is covered by the vehicle we rammed into, count that as touching it
		// yeah, that's technically cheating, but if we had more time we'd do this for players too
		// because parking a vehicle on the flag is lame
		if (UTCarriedObject(MoveTarget) != None && MoveTarget.Touching.Find(LastBlockingVehicle) != INDEX_NONE)
		{
			MoveTarget.Touch(Pawn, None, MoveTarget.Location, HitNormal);
		}
		else if (UTGameObjective(MoveTarget) != None)
		{
			Flag = UTGameObjective(MoveTarget).GetFlag();
			if (Flag != None && Flag.bHome && Flag.Touching.Find(LastBlockingVehicle) != INDEX_NONE)
			{
				Flag.Touch(Pawn, None, Flag.Location, HitNormal);
			}
		}

		if (Wall == RouteGoal || (Vehicle(RouteGoal) != None && Wall == Vehicle(RouteGoal).GetVehicleBase()))
		{
			if (LastBlockingVehicle != None)
			{
				LastBlockingVehicle.TryToDrive(Pawn);
				if (Vehicle(Pawn) != None)
				{
					LastBlockingVehicle = None;
					UTSquadAI(Squad).BotEnteredVehicle(self);
					WhatToDoNext();
				}
			}
			return true;
		}

		if (LastBlockingVehicle.Controller != None || FRand() < 0.9)
		{
			return false;
		}
		else
		{
			bNotifyApex = true;
			bPendingDoubleJump = true;
			Pawn.SetPhysics(PHYS_Falling);
			Pawn.Velocity = GetDestinationPosition() - Pawn.Location;
			Pawn.Velocity.Z = 0;
			Pawn.Velocity = Pawn.GroundSpeed * Normal(Pawn.Velocity);
			Pawn.Velocity.Z = Pawn.JumpZ;
		}
	}
	return false;
}

function FearThisSpot(UTAvoidMarker aSpot)
{
	local int i;

	if ( (Pawn == None) || (Skill < 1 + 4.5*FRand()) )
		return;
	if ( !LineOfSightTo(aSpot) )
		return;
	for ( i=0; i<2; i++ )
		if ( (FearSpots[i] == None) || FearSpots[i].bDeleteMe )
		{
			FearSpots[i] = aSpot;
			return;
		}
	for ( i=0; i<2; i++ )
		if ( VSize(Pawn.Location - FearSpots[i].Location) > VSize(Pawn.Location - aSpot.Location) )
		{
			FearSpots[i] = aSpot;
			return;
		}
}

function Startle(Actor Feared)
{
	if ( Vehicle(Pawn) != None )
		return;
	GoalString = "STARTLED!";
	StartleActor = Feared;
	GotoState('Startled');
}

function SetCombatTimer()
{
	SetTimer(1.2 - 0.09 * FMin(10,Skill+ReactionTime), True);
}

//===========================================================================
// Weapon management functions

function bool CanImpactJump()
{
	return (ImpactJumpZ > 0.f && Pawn.Health >= 80 && Skill >= 5.0 && UTSquadAI(Squad).AllowImpactJumpBy(self));
}

/** 
  * If bot gets stuck trying to jump, then bCanDoubleJump is set false for the pawn
  * Set a timer to reset the ability to double jump once the bot is clear.
  */
event TimeDJReset()
{
	SetTimer(12.0, false, 'ResetDoubleJump');
}

function ResetDoubleJump()
{
	local UTPawn P;

	P = UTPawn(Pawn);
	if ( (P == None) && (Vehicle(Pawn) != None) )
	{
		P = UTPawn(Vehicle(Pawn).Driver);
	}
	if ( P != None )
		P.bCanDoubleJump = true;
}

// WaitForMover()
//Wait for Mover M to tell me it has completed its move
function WaitForMover(InterpActor M)
{
	ReadyForLift();

	if ( (Enemy != None) && (WorldInfo.TimeSeconds - LastSeenTime < 3.0) )
		Focus = Enemy;
	StopStartTime = WorldInfo.TimeSeconds;
	Super.WaitForMover(M);
}

function ReadyForLift()
{
	local float Dist;

	// vehicles can't activate lifts
	if (Vehicle(Pawn) != None )
	{
		if ( UTVehicle_Hoverboard(Pawn) != None )
		{
			LeaveVehicle(false);
		}
		else
		{
			Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
			if ( LiftCenter(Pawn.Anchor) != None )
	{
		LeaveVehicle(false);
	}
		}
	}
}

/* WeaponFireAgain()
Notification from weapon when it is ready to fire (either just finished firing,
or just finished coming up/reloading).
Returns true if weapon should fire.
If it returns false, can optionally set up a weapon change
*/
function bool WeaponFireAgain(bool bFinishedFire)
{
	LastFireAttempt = WorldInfo.TimeSeconds;
	bFireSuccess = false;
	if (ScriptedTarget != None)
	{
		Focus = ScriptedTarget;
	}
	else if (Focus == None)
	{
		Focus = Enemy;
	}
	if (Focus != None)
	{
		if ( !Pawn.IsFiring() )
		{
			if ( (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) || (!Pawn.NeedToTurn(GetFocalPoint()) && CanAttack(Focus)) )
			{
				LastCanAttackCheckTime = WorldInfo.TimeSeconds;
				bCanFire = true;
				bStoppedFiring = false;
				bFireSuccess = Pawn.BotFire(bFinishedFire);
				LastFireTarget = Focus;
				return bFireSuccess;
			}
			else
			{
				bCanFire = false;
			}
		}
		else if ( bCanFire && ShouldFireAgain() )
		{
			if ( !Focus.bDeleteMe )
			{
				bStoppedFiring = false;
				bFireSuccess = Pawn.BotFire(bFinishedFire);
				LastFireTarget = Focus;
				return bFireSuccess;
			}
		}
	}
	StopFiring();
	return false;
}

function bool ShouldFireAgain()
{
	local UTWeapon UTWeap;
	local float LandTime, ProjTime, TargetGravityZ;
	local vector HitLocation, HitNormal, TargetLoc;

	if (ScriptedTarget != None)
	{
		return true;
	}
	// re-eval weapon if switching to non-Pawn target
	if (Focus != LastFireTarget && Pawn(Focus) == None)
	{
		return false;
	}
	UTWeap = UTWeapon(Pawn.Weapon);
	if (UTWeap != None)
	{
		if ( WorldInfo.TimeSeconds - LastCanAttackCheckTime > 1.0 )
		{
			LastCanAttackCheckTime = WorldInfo.TimeSeconds;
			if (!CanAttack(Focus))
			{
				return false;
			}
		}
		if (UTWeap.bFastRepeater)
		{
			return true;
		}
		else if (UTWeap.bLockedAimWhileFiring && !Focus.IsStationary())
		{
			return false;
		}
	}

	if (Pawn.Weapon == None || !Pawn.Weapon.bMeleeWeapon)
	{
		if (Pawn.FireOnRelease())
		{
			return (FRand() < 0.8 || (Skill > 1.0 + 3.0 * FRand() && UTWeap != None && UTWeap.IsFullyCharged() && LineOfSightTo(Focus)));
		}
		else if (UTWeap != None && Focus == Enemy)
		{
			if (UTWeap.bInstantHit)
			{
				// sometimes delay a little to throw opponent dodges off
				if (VSize(Enemy.Velocity) > Enemy.GroundSpeed && FRand() < 0.4 && Skill + Tactics + ReactionTime > 2.0 + 4.0 * FRand())
				{
					return false;
				}
			}
			// if target is falling, wait until it's close enough to ground that we can target at feet and hit
			else if (UTWeap.bRecommendSplashDamage && Focus.Physics == PHYS_Falling && Skill + Accuracy + Tactics > 2.0 + 2.0 * FRand())
			{
				if (UTWeap.CurrentFireMode < UTWeap.WeaponProjectiles.length && UTWeap.WeaponProjectiles[UTWeap.CurrentFireMode] != None)
				{
					// approximate landing Z by just tracing down with world trace
					if (Trace(HitLocation, HitNormal, Focus.Location - vect(0,0,10000), Focus.Location, false, Pawn(Focus).GetCollisionExtent()) != None)
					{
						TargetLoc = Focus.Location;
						TargetLoc.Z = HitLocation.Z;
						// get time for target to land
						TargetGravityZ = Focus.GetGravityZ();
						LandTime = (-Focus.Velocity.Z - Sqrt(Square(Focus.Velocity.Z) - (2.0 * TargetGravityZ * (Focus.Location.Z - TargetLoc.Z)))) / TargetGravityZ;
						ProjTime = UTWeap.WeaponProjectiles[UTWeap.CurrentFireMode].static.StaticGetTimeToLocation(TargetLoc, UTWeap.GetPhysicalFireStartLoc(), self);
						if (LandTime + 0.1 > ProjTime)
						{
							if (LandTime - UTWeap.GetFireInterval(UTWeap.CurrentFireMode) > ProjTime)
							{
								// target will take so long to land that we can fire a shot now
								// and still have time to shoot the ground later
								return true;
							}
							else
							{
								// delay until about to land
								SetTimer(LandTime - ProjTime, true);
								bResetCombatTimer = true;
								return false;
							}
						}
					}
				}
			}
		}

		if (FRand() < 0.8)
		{
			return true;
		}
	}

	if ( Pawn(Focus) != None )
		return ( (Pawn.bStationary || Pawn(Focus).bStationary) && (Pawn(Focus).Health > 0) );

	return IsShootingObjective();
}

function TimedFireWeaponAtEnemy()
{
	bResetCombatTimer = false;
	if (Enemy == None || FireWeaponAt(Enemy))
	{
		if (!bResetCombatTimer)
		{
			SetCombatTimer();
		}
	}
	else if (!bResetCombatTimer)
	{
		SetTimer(0.1, true);
	}
}

function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Focus = A;
	if ( Pawn.Weapon != None )
	{
		if ( Pawn.Weapon.HasAnyAmmo() )
			return WeaponFireAgain(false);
	}
	else
		return WeaponFireAgain(false);

	return false;
}

function bool CanAttack(Actor Other)
{
	local UTMapInfo WorldMapInfo;

	WorldMapInfo = UTMapInfo(WorldInfo.GetMapInfo());
	if ( (WorldMapInfo != None) && (WorldMapInfo.VisibilityModifier < 1.0)
		&& (WorldMapInfo.VisibilityModifier * Pawn.SightRadius < VSize(Other.Location - Pawn.Location)) )
	{
		return false;
	}
	// return true if in range of current weapon
	return Pawn.CanAttack(Other);
}

function OnAIStartFireAt(UTSeqAct_AIStartFireAt FireAction)
{
	local SeqVar_Object ObjVar;

	foreach FireAction.LinkedVariables(class'SeqVar_Object', ObjVar, "Fire At")
	{
		// use first valid Actor found
		ScriptedTarget = Actor(ObjVar.GetObjectValue());
		if (ScriptedTarget != None)
		{
			break;
		}
	}
	if (ScriptedTarget != None)
	{
		if (ScriptedTarget.IsA('Controller'))
		{
			ScriptedTarget = Controller(ScriptedTarget).Pawn;
		}
		Focus = ScriptedTarget;
		SwitchToBestWeapon();
		ScriptedFireMode = FireAction.ForcedFireMode;
		SetTimer(0.1, true, 'TimedFireWeaponAtScriptedTarget');
	}
	else
	{
		FireAction.ScriptLog("WARNING: Missing Actor to fire at");
	}
}

function TimedFireWeaponAtScriptedTarget()
{
	Focus = ScriptedTarget;
	FireWeaponAt(ScriptedTarget);
}

function StopFiring()
{
	bStoppedFiring =  ( (Pawn==None) || Pawn.StopFiring());
	bCanFire = false;
}

function OnAIStopFire(UTSeqAct_AIStopFire FireAction)
{
	ScriptedTarget = None;
	StopFiring();
	ClearTimer('TimedFireWeaponAtScriptedTarget');
}

simulated function float RateWeapon(Weapon w)
{
	local float Rating;

	Rating = UTWeapon(W).GetAIRating() + FRand() * 0.05 + WeaponPreference(W);

	return Rating;
}

function float WeaponPreference(Weapon W)
{
	local float WeaponStickiness;

	if ( (DefensePoint != None) && (DefensePoint.WeaponPreference != None)
		&& ClassIsChildOf(W.class, DefensePoint.WeaponPreference)
		&& Pawn.ReachedDestination(DefensePoint.GetMoveTarget()) )
		return 0.3;

	if ( (Focus != None) && (Pawn(Focus) == None) )
		return 0;

	if ( (FavoriteWeapon != None) && (ClassIsChildOf(W.class, FavoriteWeapon)) )
	{
		if ( W == Pawn.Weapon )
			return 0.3;
		return 0.15;
	}

	if ( W == Pawn.Weapon )
	{
		WeaponStickiness = 0.1; //@todo FIXMESTEVE - base on weapon switch time, including reload pct
		if ( (Pawn.Weapon.AIRating < 0.5) || (Enemy == None) )
			return WeaponStickiness + 0.1;
		else if ( skill < 5 )
			return WeaponStickiness + 0.6 - 0.1 * skill;
		else
			return WeaponStickiness + 0.1;
	}
	return 0;
}

function bool ProficientWithWeapon()
{
	local float proficiency;

	if ( (Pawn == None) || (Pawn.Weapon == None) )
		return false;
	proficiency = skill;
	if ( (FavoriteWeapon != None) && ClassIsChildOf(Pawn.Weapon.class, FavoriteWeapon) )
		proficiency += 2;

	return ( proficiency > 2 + FRand() * 4 );
}

function bool CanComboMoving()
{
	if ( (Skill >= 5) && ClassIsChildOf(Pawn.Weapon.class, FavoriteWeapon) )
		return true;
	if ( Skill >= 7 )
		return (FRand() < 0.9);
	return ( Skill - 3 > 4 * FRand() );
}

function bool CanCombo()
{
	if ( Stopped() )
		return true;

	if ( Pawn.Physics == PHYS_Falling )
		return false;

	if ( (Pawn.Acceleration == vect(0,0,0)) || (MoveTarget == Enemy) )
		return true;

	return CanComboMoving();
}

//===========================================================================

simulated function DisplayDebug(HUD HUD, out float YL, out float YPos)
{
	local UTWeapon best[5], moving, temp;
	local bool bFound;
	local int i;
	local UTWeapon W;
	local string S;
	local Canvas Canvas;

	Super.DisplayDebug(HUD,YL, YPos);

	Canvas = HUD.Canvas;
	Canvas.SetDrawColor(255,255,255);
	if (Squad != None)
	{
		Squad.DisplayDebug(HUD,YL,YPos);
	}
	else
	{
		Canvas.DrawText("NO SQUAD");
	}
	if ( DefensePoint != None )
		Canvas.DrawText("     "$GoalString$" DefensePoint "$GetItemName(string(DefensePoint))$" Sniping "$IsSniping()$" ReTaskTime "$ReTaskTime, false);
	else
		Canvas.DrawText("     "$GoalString$" ReTaskTime "$ReTaskTime, false);

	YPos += 2*YL;
	Canvas.SetPos(4,YPos);

	if ( Enemy != None )
	{
		Canvas.DrawText("Enemy Dist "$VSize(Enemy.Location - Pawn.Location)$" Strength "$RelativeStrength(Enemy)$" Acquired "$bEnemyAcquired$" LastSeenTime "$(WorldInfo.TimeSeconds - LastSeenTime)$ " AcquireTime "$(WorldInfo.TimeSeconds - AcquireTime));
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	ForEach Pawn.InvManager.InventoryActors(class'UTWeapon',W)
	{
		bFound = false;
		for ( i=0; i<5; i++ )
			if ( Best[i] == None )
			{
				bFound = true;
				Best[i] = W;
				break;
			}
		if ( !bFound )
		{
			Moving = W;
			for ( i=0; i<5; i++ )
				if ( Best[i].CurrentRating < Moving.CurrentRating )
				{
					Temp = Moving;
					Moving = Best[i];
					Best[i] = Temp;
				}
		}
	}

	Canvas.DrawText("Weapons Fire last attempt at "$LastFireAttempt$" success "$bFireSuccess$" stopped firing "$bStoppedFiring, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	for ( i=0; i<5; i++ )
		if ( Best[i] != None )
			S = S@Best[i].GetHumanReadableName()@Best[i].CurrentRating;

	Canvas.DrawText("Weapons: "$S, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("PERSONALITY: Alertness "$BaseAlertness$" Accuracy "$Accuracy$" Favorite Weap "$FavoriteWeapon);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("    Aggressiveness "$BaseAggressiveness$" CombatStyle "$CombatStyle$" Strafing "$StrafingAbility$" Tactics "$Tactics);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function name GetOrders()
{
	local UTSquadAI UTSquad;

	UTSquad = UTSquadAI(Squad);
	if ( UTHoldSpot(DefensePoint) != None )
	{
		return 'Hold';
	}
	else if (UTSquad == None)
	{
		return 'Attack';
	}
	else if (PlayerController(UTSquad.SquadLeader) != None)
	{
		return 'Follow';
	}
	else
	{
		return UTSquad.GetOrders();
	}
}

/* YellAt()
Tell idiot to stop shooting me
*/
function YellAt(PlayerReplicationInfo Moron)
{
	local float Threshold;

	if ( Enemy == None )
		Threshold = 0.2;
	else
		Threshold = 0.7;
	if ( FRand() < Threshold )
		return;

	SendMessage(Moron, 'FRIENDLYFIRE', 5);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, float Wait, optional class<DamageType> DamageType)
{
	// limit frequency of same message
	if ( (MessageType == OldMessageType)
		&& (WorldInfo.TimeSeconds - OldMessageTime < Wait) )
		return;

	if ( WorldInfo.Game.bGameEnded || WorldInfo.Game.bWaitingToStartMatch )
		return;

	OldMessageType = MessageType;
	OldMessageTime = WorldInfo.TimeSeconds;

	UTPlayerReplicationInfo(PlayerReplicationInfo).VoiceClass.static.SendVoiceMessage(self, Recipient, MessageType, DamageType);
}

/* SetOrders()
Called when player gives orders to bot
*/
function SetBotOrders(name NewOrders, Controller OrderGiver, bool bShouldAck)
{
	if ( PlayerReplicationInfo.Team != OrderGiver.PlayerReplicationInfo.Team )
		return;

	Aggressiveness = BaseAggressiveness;
	if ( (NewOrders == 'Hold') || (NewOrders == 'Follow') )
	{
		Aggressiveness = 1.0;
	}

	if ( bShouldAck )
	{
		SendMessage(OrderGiver.PlayerReplicationInfo, 'ACK', 5);
	}
	UTTeamInfo(PlayerReplicationInfo.Team).AI.SetOrders(self,NewOrders,OrderGiver);
	WhatToDoNext();
}

// Give bot orders but remember old orders, which are restored by calling ClearTemporaryOrders()
function SetTemporaryOrders(name NewOrders, Controller OrderGiver)
{
	if (OldOrders == 'None')
	{
		OldOrders = GetOrders();
		OldOrderGiver = UTSquadAI(Squad).SquadLeader;
		if (OldOrderGiver == None)
			OldOrderGiver = OrderGiver;
	}
	SetBotOrders(NewOrders, OrderGiver, false);
}

// Return bot to its previous orders
function ClearTemporaryOrders()
{
	if (OldOrders != 'None')
	{
		Aggressiveness = BaseAggressiveness;
		if ( (OldOrders == 'Hold') || (OldOrders == 'Follow') )
		{
			Aggressiveness = 1.0;
		}
		UTTeamInfo(PlayerReplicationInfo.Team).AI.SetOrders(self,OldOrders,OldOrderGiver);

		OldOrders = 'None';
		OldOrderGiver = None;
	}
}

event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
	if ( NoiseMaker.Instigator.IsInvisible() )
	{
		// only react to invisible player noise if its a pickup or a projectile explosion and can see the instigator
		if ( (Skill < 3)
			|| ((PickupFactory(NoiseMaker) != None) && (Projectile(Noisemaker) != None))
			|| ((vector(Rotation) dot Normal(NoiseMaker.Instigator.Location - Pawn.Location)) < 0.7)
			|| !LineOfSightTo(NoiseMaker.Instigator) )
		{
			return;
		}
	}

	if ( UTSquadAI(Squad).SetEnemy(self, NoiseMaker.Instigator))
	{
		WhatToDoNext();
	}
}

event SeePlayer(Pawn SeenPlayer)
{
	if (Squad == None && !WorldInfo.GRI.OnSameTeam(self, SeenPlayer))
	{
		// maybe scripted pawn; just notify Kismet
		Pawn.TriggerEventClass(class'SeqEvent_AISeeEnemy', SeenPlayer);
	}
	else if (UTSquadAI(Squad).SetEnemy(self, SeenPlayer))
	{
		// check for any Kismet scripts that might care
		Pawn.TriggerEventClass(class'SeqEvent_AISeeEnemy', SeenPlayer);

		WhatToDoNext();
	}
	if ( Enemy == SeenPlayer )
	{
		VisibleEnemy = Enemy;
		EnemyVisibilityTime = WorldInfo.TimeSeconds;
		bEnemyIsVisible = true;
	}
}

function SetAttractionState()
{
	if ( Enemy != None )
		GotoState('FallBack');
	else
		GotoState('Roaming');
}

function bool ClearShot(Vector TargetLoc, bool bImmediateFire)
{
	local bool bSeeTarget;

	if ( (Enemy == None) || (VSize(Enemy.Location - TargetLoc) > MAXSTAKEOUTDIST) )
	{
		return false;
	}

	bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.EyeHeight * vect(0,0,1),, true);
	// if pawn is crouched, check if standing would provide clear shot
	if ( !bImmediateFire && !bSeeTarget && Pawn.bIsCrouched )
		bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.GetCollisionHeight() * vect(0,0,1),, true);

	if (!bSeeTarget)
		return false;
	if ( VSize(Pawn.Location - TargetLoc) < Pawn.Weapon.GetDamageRadius()
		|| !FastTrace(TargetLoc + vect(0,0,0.9) * Enemy.GetCollisionHeight(), Pawn.Location,, true) )
	{
		StopFiring();
		return false;
	}
	return true;
}

function bool CanStakeOut()
{
	local float relstr;

	relstr = RelativeStrength(Enemy);

	if ( bFrustrated || !bEnemyInfoValid
		 || (VSize(Enemy.Location - Pawn.Location) > 0.5 * (MAXSTAKEOUTDIST + (FRand() * relstr - CombatStyle) * MAXSTAKEOUTDIST))
		 || (WorldInfo.TimeSeconds - FMax(LastSeenTime,AcquireTime) > 2.5 + FMax(-1, 3 * (FRand() + 2 * (relstr - CombatStyle))) )
		 || !ClearShot(LastSeenPos,false) )
		return false;
	return true;
}

/* CheckIfShouldCrouch()
returns true if target position still can be shot from crouched position,
and weapon is a sniping weapon
or if couldn't hit it from standing position either
*/
function CheckIfShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
{
	local actor HitActor;
	local vector HitNormal,HitLocation, projstart;

	if ( WorldInfo.bUseConsoleInput || !Pawn.bCanCrouch || (!Pawn.bIsCrouched && (FRand() > probability))
		|| !IsSniping()
		|| (Skill < 3 * FRand()) )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}

	projStart = Pawn.GetWeaponStartTraceLocation();
	projStart = projStart + StartPosition - Pawn.Location;
	projStart.Z = projStart.Z - 1.8 * (Pawn.GetCollisionHeight() - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = true;
		return;
	}

	projStart.Z = projStart.Z + 1.8 * (Pawn.CylinderComponent.Default.CollisionHeight - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}
	Pawn.bWantsToCrouch = true;
}

function bool IsSniping()
{
	// @TODO FIXMESTEVE - issniping if in non-defensepoint base defense mode also!
	return ( (DefensePoint != None) && DefensePoint.bSniping && UTWeapon(Pawn.Weapon) != None && UTWeapon(Pawn.Weapon).bSniping
			&& Pawn.ReachedDestination(DefensePoint.GetMoveTarget()) );
}

function FreePoint()
{
	if ( DefensePoint != None )
	{
		DefensePoint.FreePoint();
		DefensePoint = None;
	}
}

function bool AssignSquadResponsibility()
{
	if ( LastAttractCheck == WorldInfo.TimeSeconds )
		return false;
	LastAttractCheck = WorldInfo.TimeSeconds;

	return UTSquadAI(Squad).AssignSquadResponsibility(self);
}

/* RelativeStrength()
returns a value indicating the relative strength of other
> 0 means other is stronger than controlled pawn

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)
*/

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedOther;

	if ( Pawn == None )
	{
		`warn("Relative strength with no pawn in state "$GetStateName());
		return 0;
	}
	adjustedOther = 0.5 * (Other.Health + Other.HealthMax);
	compare = 0.01 * float(adjustedOther - Pawn.health);
	compare = compare - Pawn.AdjustedStrength() + Other.AdjustedStrength();

	if ( UTWeapon(Pawn.Weapon) != None )
	{
		compare -= 0.5 * Pawn.GetDamageScaling() * UTWeapon(Pawn.Weapon).CurrentRating;
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.3;
		}
	}
	if ( Other.Weapon != None )
		compare += 0.5 * Other.GetDamageScaling() * Other.Weapon.AIRating;

	if ( Other.Location.Z > Pawn.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare += 0.2;
	else if ( Pawn.Location.Z > Other.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare -= 0.15;

	return compare;
}

function SetEnemyInfo(bool bNewEnemyVisible)
{
	local UTBot b;
	local UTVehicle V;

	if ( bNewEnemyVisible )
	{
		AcquireTime = WorldInfo.TimeSeconds;
		LastSeenTime = WorldInfo.TimeSeconds;
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Pawn.Location;
		bEnemyInfoValid = true;

		if ( WorldInfo.Game.bTeamGame )
		{
			V = UTVehicle(Enemy);
			if ( (V != None) && V.bHasEnemyVehicleSound )
			{
				if ( Worldinfo.TimeSeconds - V.LastEnemyWarningTime > 15 )
				{
					SendMessage(None, 'INCOMINGVEHICLE', 10);
				}
			}
			else if ( (GetOrders() == 'Defend') && (UTGame(WorldInfo.Game) != None)
						&& (UTGame(WorldInfo.Game).VehicleList == None) )
			{
				SendMessage(None, 'INCOMING', 25);
			}
		}
		if ( UTPlayerController(Enemy.Controller) != None )
		{
			UTPlayerController(Enemy.Controller).ClientMusicEvent(0);
		}
	}
	else
	{
		LastSeenTime = -1000;
		bEnemyInfoValid = false;
		For ( B=UTSquadAI(Squad).SquadMembers; B!=None; B=B.NextSquadMember )
		{
			if ( B.Enemy == Enemy )
				AcquireTime = FMax(AcquireTime, B.AcquireTime);
		}
	}
}

// EnemyChanged() called by squad when current enemy changes
function EnemyChanged(bool bNewEnemyVisible)
{
	bEnemyAcquired = false;
	SetEnemyInfo(bNewEnemyVisible);
	//`log(GetHumanReadableName()$" chooseattackmode from enemychanged at "$WorldInfo.TimeSeconds);
}

function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest);

//**********************************************************************

event NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local vector jumpDir;

	if ( Vehicle(Pawn) != None )
		return;

	if ( newVolume.bWaterVolume )
	{
		bPlannedJump = false;
		if (!Pawn.bCanSwim)
			MoveTimer = -1.0;
		else if (Pawn.Physics != PHYS_Swimming && Pawn.Physics != PHYS_RigidBody)
			Pawn.setPhysics(PHYS_Swimming);
	}
	else if (Pawn.Physics == PHYS_Swimming)
	{
		if ( Pawn.bCanFly )
			 Pawn.SetPhysics(PHYS_Flying);
		else
		{
			Pawn.SetPhysics(PHYS_Falling);
			if ( Pawn.bCanWalk && (Abs(Pawn.Acceleration.X) + Abs(Pawn.Acceleration.Y) + Abs(Acceleration.Z) > 0)
				&& (GetDestinationPosition().Z >= Pawn.Location.Z)
				&& Pawn.CheckWaterJump(jumpDir) )
				{
					ImpactVelocity = vect(0,0,0);
					Pawn.JumpOutOfWater(jumpDir);
					bNotifyApex = true;
					bPendingDoubleJump = true;
				}
		}
	}
}

/* MayDodgeToMoveTarget()
called when starting MoveToGoal(), based on DodgeToGoalPct
Know have CurrentPath, with end lower than start
*/
event MayDodgeToMoveTarget()
{
	local vector Dir,X,Y,Z, DodgeV,NewDir;
	local float Dist,NewDist, RealJumpZ;
	local Actor OldMoveTarget;
	local float RealGroundSpeed;

	if ( Pawn.Physics != PHYS_Walking )
		return;

	if ( (Focus != MoveTarget) && (Skill+Jumpiness < 4.5 + 1.5 * FRand()) )
		return;

	// never in low grav
	if ( Pawn.GetGravityZ() > WorldInfo.DefaultGravityZ )
		return;

	Dir = MoveTarget.GetDestination(self) - Pawn.Location;
	Dist = VSize(Dir);
	OldMoveTarget = MoveTarget;

	// only dodge if far enough to destination
	if ( (Dist < 500.0) || (Dir.Z < 0.0) )
	{
		// maybe change movetarget
		if ( ((PathNode(MoveTarget) == None) && (PlayerStart(MoveTarget) == None)) || (RouteCache.Length == 0) || (MoveTarget != RouteCache[0]) )
		{
			if ( Dist < 500.0 )
				return;
		}
		else if ( (RouteCache.Length > 1) && (RouteCache[1] != None) )
		{
			if ( Pawn.Location.Z + Pawn.MaxStepHeight < RouteCache[1].Location.Z )
			{
				if ( Dist < 500.0 )
					return;
			}

			NewDir = RouteCache[1].Location - Pawn.Location;
			NewDist = VSize(NewDir);
			if ( (NewDist > 500.0) && CanMakePathTo(RouteCache[1]) )
			{
				Dist = NewDist;
				Dir = NewDir;
				MoveTarget = RouteCache[1];
			}
			else if ( Dist < 500.0 )
				return;
		}
	}
	if ( Focus == OldMoveTarget )
		Focus = MoveTarget;
	SetDestinationPosition(MoveTarget.Location);
	GetAxes(Pawn.Rotation,X,Y,Z);

	if ( Abs(X Dot Dir) > Abs(Y Dot Dir) )
	{
		if ( (X Dot Dir) > 0 )
			UTPawn(Pawn).CurrentDir = DCLICK_Forward;
		else
			UTPawn(Pawn).CurrentDir = DCLICK_Back;
	}
	else if ( (Y Dot Dir) < 0 )
		UTPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UTPawn(Pawn).CurrentDir = DCLICK_Right;

	bPlannedJump = true;
	UTPawn(Pawn).PerformDodge(UTPawn(Pawn).CurrentDir, Normal(Dir), vect(0,0,0));

	// if below, make sure really far
	if ( Dir.Z < -1 * Pawn.GetCollisionHeight() )
	{
		Pawn.Velocity.Z = 0.0;
		RealJumpZ = Pawn.JumpZ;
		DodgeV = UTPawn(Pawn).BotDodge(vect(1,0,0));
		Pawn.JumpZ = DodgeV.Z;
		DodgeV.Z = 0.0;
		RealGroundSpeed = Pawn.GroundSpeed;
		Pawn.GroundSpeed = VSize(DodgeV);
		Pawn.SuggestJumpVelocity(Pawn.Velocity, GetDestinationPosition(), Pawn.Location);
		Pawn.GroundSpeed = RealGroundSpeed;
		Pawn.JumpZ = RealJumpZ;
	}
	Pawn.Acceleration = vect(0,0,0);
}

event NotifyJumpApex()
{
	local vector HitLocation, HitNormal, HalfHeight, Start;
	local actor HitActor;

	// double jump
	if ( bPendingDoubleJump )
	{
		Pawn.bWantsToCrouch = false;
		if ( UTPawn(Pawn).CanDoubleJump() )
			UTPawn(Pawn).DoDoubleJump(false);
		bPendingDoubleJump = false;
	}
	else if ( bJumpOverWall )
	{
		// double jump if haven't cleared obstacle
		Pawn.Acceleration = GetDestinationPosition() - Pawn.Location;
		Pawn.Acceleration.Z = 0;
		HalfHeight = Pawn.GetCollisionRadius() * vect(1,1,0);
		HalfHeight.Z = 0.5 * Pawn.GetCollisionHeight();
		Start = Pawn.Location - Pawn.GetCollisionHeight() * vect(0,0,0.5);
		HitActor = Pawn.Trace(HitLocation, HitNormal, Start + 8 * Normal(Pawn.Acceleration), Start, true,HalfHeight);
		if ( HitActor != None )
		{
			Pawn.bWantsToCrouch = false;
			if ( UTPawn(Pawn).CanDoubleJump() )
				UTPawn(Pawn).DoDoubleJump(false);
		}
	}
}

event NotifyMissedJump()
{
	local NavigationPoint N;
	local actor OldMoveTarget;
	local vector Loc2D, NavLoc2D;
	local float BestDist, NewDist;

	OldMoveTarget = MoveTarget;
	MoveTarget = None;

	if ( MoveTarget == None )
	{
		// find an acceptable path
		Loc2D = Pawn.Location;
		Loc2D.Z = 0;
		foreach WorldInfo.AllNavigationPoints(class'NavigationPoint', N)
		{
			if ( N.Location.Z < Pawn.Location.Z )
			{
				NavLoc2D = N.Location;
				NavLoc2D.Z = 0;
				NewDist = VSize(NavLoc2D - Loc2D);
				if ( (NewDist <= Pawn.Location.Z - N.Location.Z)
					&& ((MoveTarget == None) || (BestDist > NewDist))  && LineOfSightTo(N) )
				{
					MoveTarget = N;
					BestDist = NewDist;
				}
			}
		}
		if ( MoveTarget == None )
		{
			MoveTarget = OldMoveTarget;
			return;
		}
	}

	MoveTimer = 1.0;
}

function Reset()
{
	Super.Reset();

	NextRoutePath = None;
	LastSeenTime = 0;
	MonitoredPawn = None;
	WarningProjectile = None;
	bHuntPlayer = false;
	bEnemyAcquired	= false;
	ResetSkill();
	bPlannedJump = false;
	bFrustrated = false;
	bInitLifeMessage = false;
	bReachedGatherPoint = false;
	bFinalStretch = false;
	bHasSuperWeapon = false;
	bJumpOverWall	= false;
	StartleActor = None;
	DefensePoint = None;
	ImpactVelocity = vect(0,0,0);
	PendingMover = None;
	Enemy = None;
	bFrustrated = false;
	BlockedPath = None;
	bInitLifeMessage = false;
	bInDodgeMove = false;
	bWasNearObjective = false;
	bPreparingMove = false;
	bPursuingFlag = false;
	ImpactJumpZ = 0.f;
	RouteGoal = None;
	NoVehicleGoal = None;
	SquadRouteGoal = None;
	bUsingSquadRoute = true;
	bUsePreviousSquadRoute = false;
	MoveTarget = None;
	bEnemyInfoValid = false;
	if ( Pawn == None )
		GotoState('Dead');
}

function Possess(Pawn aPawn, bool bVehicleTransition)
{
	if (aPawn.bDeleteMe)
	{
		`Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
		ScriptTrace();
		GotoState('Dead');
	}
	else
	{
		Super.Possess(aPawn, bVehicleTransition);
		bPlannedJump = false;
		ResetSkill();
		ImpactVelocity = vect(0,0,0);
		Pawn.SetMovementPhysics();
		if (Pawn.Physics == PHYS_Walking)
			Pawn.SetPhysics(PHYS_Falling);
		enable('NotifyBump');
	}
}

function Initialize(float InSkill, const out CharacterInfo BotInfo)
{
	local UTPlayerReplicationInfo PRI;

	Skill = FClamp(InSkill, 0, 7);

	// copy AI personality
	if (BotInfo.AIData.FavoriteWeapon != "")
	{
		if (WorldInfo.IsConsoleBuild())
		{
			FavoriteWeapon = class<Weapon>(FindObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
		else
		{
			FavoriteWeapon = class<Weapon>(DynamicLoadObject(BotInfo.AIData.FavoriteWeapon, class'Class'));
		}
	}
	Aggressiveness = FClamp(BotInfo.AIData.Aggressiveness, 0, 1);
	BaseAggressiveness = Aggressiveness;
	Accuracy = FClamp(BotInfo.AIData.Accuracy, -5, 5);
	StrafingAbility = FClamp(BotInfo.AIData.StrafingAbility, -5, 5);
	CombatStyle = FClamp(BotInfo.AIData.CombatStyle, -1, 1);
	Jumpiness = FClamp(BotInfo.AIData.Jumpiness, -1, 1);
	Tactics = FClamp(BotInfo.AIData.Tactics, -5, 5);
	ReactionTime = FClamp(BotInfo.AIData.ReactionTime, -5, 5);

	// copy visual properties
 	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
 	if (PRI != None)
 	{
	//Get the chosen character class for this character
		PRI.CharClassInfo = class'UTCharInfo'.static.FindFamilyInfo(BotInfo.FamilyID);
	}

	ResetSkill();
}

function ResetSkill()
{
	if (Skill >= 0 )
	{
		TrackingReactionTime = BaseTrackingReactionTime * 7/(Skill+2);
	}

	if ( Skill < 3 )
		DodgeToGoalPct = 0;
	else
		DodgeToGoalPct = (Jumpiness * 0.5) + Skill / 6;
	Aggressiveness = BaseAggressiveness;
	bLeadTarget = ( Skill >= 4 );
	SetCombatTimer();
	SetPeripheralVision();
	HearingThreshold = default.HearingThreshold * FClamp(Skill/6.0, 0.0, 1.0);

	if ( WorldInfo.IsConsoleBuild() )
	{
		RotationRate.Yaw = Min(30000 + 4000*(skill + ReactionTime), 60000);
	}
	else
	{
		if ( Skill + ReactionTime >= 7 )
		{
			SightCounterInterval = 0.2;
			RotationRate.Yaw = 110000;
		}
		else if ( Skill + ReactionTime >= 4 )
		{
			RotationRate.Yaw = 7000 + 10000 * (skill + ReactionTime);
			SightCounterInterval = 0.3;
		}
		else
		{
			RotationRate.Yaw = 35000 + 3000 * (skill + ReactionTime);
			SightCounterInterval = 0.4;
		}
	}
	RotationRate.Pitch = RotationRate.Yaw;
	AcquisitionYawRate = FMin(1.0,(0.75 + 0.05 * ReactionTime)) * RotationRate.Yaw;

	SetMaxDesiredSpeed();
}

function SetMaxDesiredSpeed()
{
	if (Pawn != None && !bSpawnedByKismet)
	{
		if ( (UTGame(WorldInfo.Game) != None) && UTGame(WorldInfo.Game).bDemoMode )
		{
			Pawn.bCanCrouch = false;
			Pawn.MaxDesiredSpeed = 0.75;
		}
		else if ( Skill >= 4 )
			Pawn.MaxDesiredSpeed = 1;
		else if ( (UTPlayerReplicationInfo(PlayerReplicationInfo) != None) && UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag )
		{
			Pawn.MaxDesiredSpeed = 0.8 + 0.05 * Skill;
		}
		else
		{
			Pawn.MaxDesiredSpeed = 0.6 + 0.1 * Skill;
	}
}
}

function SetPeripheralVision()
{
	if ( Pawn == None )
		return;
	if ( Pawn.bStationary || (Pawn.Physics == PHYS_Flying) )
	{
		bSlowerZAcquire = false;
		Pawn.PeripheralVision = -0.7;
		return;
	}

	bSlowerZAcquire = true;
	if ( Skill < 2 )
		Pawn.PeripheralVision = 0.7;
	else if ( Skill > 6 )
	{
		bSlowerZAcquire = false;
		Pawn.PeripheralVision = -0.2;
	}
	else
		Pawn.PeripheralVision = 1.0 - 0.2 * skill;

	Pawn.PeripheralVision = FMin(Pawn.PeripheralVision - BaseAlertness, 0.8);
	Pawn.SightRadius = Pawn.Default.SightRadius;
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
function SetAlertness(float NewAlertness)
{
	if ( Pawn.Alertness != NewAlertness )
	{
		Pawn.PeripheralVision += 0.707 * (Pawn.Alertness - NewAlertness); //Used by engine for SeePlayer()
		Pawn.Alertness = NewAlertness;
	}
}

/** triggers ExecuteWhatToDoNext() to occur during the next tick
 * this is also where logic that is unsafe to do during the physics tick should be added
 * @note: in state code, you probably want LatentWhatToDoNext() so the state is paused while waiting for ExecuteWhatToDoNext() to be called
 */
event WhatToDoNext()
{
	if (bExecutingWhatToDoNext)
	{
		`Log("WhatToDoNext loop:" @ GetHumanReadableName());
		// ScriptTrace();
	}
	if (Pawn == None)
	{
		`Warn(GetHumanReadableName() @ "WhatToDoNext with no pawn");
		return;
	}

	if (Enemy == None || Enemy.bDeleteMe || Enemy.Health <= 0)
	{
		if (!bSpawnedByKismet && UTGame(WorldInfo.Game).TooManyBots(self))
		{
			if ( Pawn != None )
			{
				if ( (Vehicle(Pawn) != None) && (Vehicle(Pawn).Driver != None) )
					Vehicle(Pawn).Driver.KilledBy(Vehicle(Pawn).Driver);
				else
				{
					Pawn.Health = 0;
					Pawn.Died( self, class'DmgType_Suicided', Pawn.Location );
				}
			}
			Destroy();
			return;
		}
		BlockedPath = None;
		bFrustrated = false;
		if (Focus == None || (Pawn(Focus) != None && Pawn(Focus).Health <= 0))
		{
			StopFiring();
			// if blew self up, return
			if ( (Pawn == None) || (Pawn.Health <= 0) )
				return;
		}
	}

	RetaskTime = 0.0;
	DecisionComponent.bTriggered = true;
}

/** entry point for AI decision making
 * this gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
 */
protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;

	if (Pawn == None)
	{
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
	}
	bHasFired = false;
	GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;
	// if we don't have a squad, try to find one
	//@fixme FIXME: doesn't work for FFA gametypes
	if (Squad == None && PlayerReplicationInfo != None && UTTeamInfo(PlayerReplicationInfo.Team) != None)
	{
		UTTeamInfo(PlayerReplicationInfo.Team).SetBotOrders(self);
	}
	SwitchToBestWeapon();

	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (StartleActor != None) && !StartleActor.bDeleteMe )
	{
		StartleActor.GetBoundingCylinder(StartleRadius, StartleHeight);
		if ( VSize(StartleActor.Location - Pawn.Location) < StartleRadius  )
		{
			Startle(StartleActor);
			return;
		}
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if ( Enemy == None )
		UTSquadAI(Squad).FindNewEnemyFor(self,false);
	else if ( !UTSquadAI(Squad).MustKeepEnemy(Enemy) && !LineOfSightTo(Enemy) )
	{
		// decide if should lose enemy
		if ( UTSquadAI(Squad).IsDefending(self) )
		{
			if ( LostContact(4) )
				LoseEnemy();
		}
		else if ( LostContact(7) )
			LoseEnemy();
	}

	bIgnoreEnemyChange = false;
	if ( AssignSquadResponsibility() )
	{
		return;
	}
	if ( ShouldDefendPosition() )
	{
		return;
	}
	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		if (Pawn.FindAnchorFailedTime == WorldInfo.TimeSeconds)
		{
			// we failed the above actions because we couldn't find an anchor.
			GoalString = "No anchor" @ WorldInfo.TimeSeconds;
			if (Pawn.LastValidAnchorTime > 5.0)
			{
				if (bSoaking)
				{
					SoakStop("NO PATH AVAILABLE!!!");
				}
				if ( (NumRandomJumps > 4) || PhysicsVolume.bWaterVolume )
				{
					// can't suicide during physics tick, delay it
					Pawn.SetTimer(0.01, false, 'Suicide');
					return;
				}
				else
				{
					// jump
					NumRandomJumps++;
					if (!Pawn.IsA('Vehicle') && Pawn.Physics != PHYS_Falling && Pawn.DoJump(false))
					{
						Pawn.SetPhysics(PHYS_Falling);
						Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
						Pawn.Velocity.Z = Pawn.JumpZ;
					}
				}
			}
		}

		GoalString @= "- Wander or Camp at" @ WorldInfo.TimeSeconds;
		bShortCamp = UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag;
		WanderOrCamp();
	}
}

/** tells the bot to enter the given vehicle
 * will abort if the vehicle can't be entered (too far away or whatever)
 * must be used during ExecuteWhatToDoNext() as entering vehicles during async work is not allowed
 */
function EnterVehicle(Vehicle V)
{
	GoalString = "Entering vehicle" @ V;
	RouteGoal = V;
	GotoState('EnteringVehicle');
}

/** tells the bot to leave the vehicle as soon as possible
 * must be used during ExecuteWhatToDoNext() as leaving vehicles during async work is not allowed
 * @param bBlocking - whether or not this action 'blocks' the AI decision logic
 *			(i.e. it needs to wait until the bot exits the vehicle to finish decisionmaking)
 */
function LeaveVehicle(bool bBlocking)
{
	if (bBlocking)
	{
		GoalString = "Leaving vehicle";
		GotoState('LeavingVehicle');
	}
	else
	{
		// just set flag and get out next tick while continuing to perform current action
		bNeedDelayedLeaveVehicle = true;
	}
}

/** called just before the AI's next tick if bNeedDelayedLeaveVehicle is true */
event DelayedLeaveVehicle()
{
	local Vehicle V;

	V = Vehicle(Pawn);
	if (V != None && !V.DriverLeave(false))
	{
		// something went wrong, so trigger blocking version instead as it has some error handling
		LeaveVehicle(true);
	}
}

function bool DoWaitForLanding()
{
	GotoState('WaitingForLanding');
	return true;
}

function VehicleFightEnemy(bool bCanCharge, float EnemyStrength)
{
	local UTVehicle V;

	V = UTVehicle(Pawn);
	if (V != None && V.bShouldLeaveForCombat)
	{
		LeaveVehicle(true);
		return;
	}
	if (Pawn.bStationary || (UTWeaponPawn(Pawn) != None) || V.bKeyVehicle )
	{
		if ( !LineOfSightTo(Enemy) )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else
		{
			DoRangedAttackOn(Enemy);
		}
		return;
	}

	if ( !bFrustrated && Pawn.HasRangedAttack() && Pawn.TooCloseToAttack(Enemy) )
	{
		GoalString = "Retreat";
		DoRetreat();
		return;
	}
	if ( (Enemy == FailedHuntEnemy && WorldInfo.TimeSeconds == FailedHuntTime) || V.bKeyVehicle )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( Pawn.HasRangedAttack() && LineOfSightTo(Enemy) )
			DoRangedAttackOn(Enemy);
		else
			WanderOrCamp();
		return;
	}
	if ( !LineOfSightTo(Enemy) )
	{
		if ( UTSquadAI(Squad).MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		if ( !bCanCharge || (UTSquadAI(Squad).IsDefending(self) && LostContact(4)) )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else if ( ((Aggression < 1) && !LostContact(3+2*FRand()) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	BlockedPath = None;
	Focus = Enemy;

	if ( V.RecommendCharge(self, Enemy) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}

	if ( Pawn.bCanFly && !Enemy.bCanFly && (Pawn.Weapon == None || VSize(Pawn.Location - Enemy.Location) < Pawn.Weapon.MaxRange()) &&
		(FRand() < 0.17 * (skill + Tactics - 1)) )
	{
		GoalString = "Do tactical move";
		DoTacticalMove();
		return;
	}

	if ( Pawn.RecommendLongRangedAttack() )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}
	GoalString = "Charge";
	DoCharge();
}


function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle;
	local bool bFarAway, bOldForcedCharge;

	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		`log("HERE 3 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);

	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(bCanCharge, EnemyStrength);
		return;
	}
	if ( Pawn.IsInPain() && FindInventoryGoal(0.0) )
	{
	        GoalString = "Fallback out of pain volume " $ RouteGoal $ " hidden " $ RouteGoal.bHidden;
	        GotoState('FallBack');
	        return;
	}

	if ( (Enemy == FailedHuntEnemy) && (WorldInfo.TimeSeconds == FailedHuntTime) )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( LineOfSightTo(Enemy) )
			bCanCharge = false;
		else if ( FindInventoryGoal(0) )
		{
			SetAttractionState();
			return;
		}
		else
		{
			WanderOrCamp();
			return;
		}
	}

	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle + UTWeapon(Pawn.Weapon).SuggestAttackStyle();
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle - 0.5 * EnemyStrength
				+ FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( UTWeapon(Enemy.Weapon) != None )
		Aggression += 2 * UTWeapon(Enemy.Weapon).SuggestDefenseStyle();
	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;
	if (Squad != None)
	{
		UTSquadAI(Squad).ModifyAggression(self, Aggression);
	}
	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
		{
			bFarAway = true;
			Aggression += 0.5;
		}
		else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.GetCollisionHeight()) // below enemy
			Aggression += CombatStyle;
	}

	if (!Pawn.CanAttack(Enemy))
	{
		if ( UTSquadAI(Squad).MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		if ( !bCanCharge )
		{
			GoalString = "Stake Out - no charge";
			DoStakeOut();
		}
		else if ( UTSquadAI(Squad).IsDefending(self) && LostContact(4) && ClearShot(LastSeenPos, false) )
		{
			GoalString = "Stake Out "$LastSeenPos;
			DoStakeOut();
		}
		else if ( (((Aggression < 1) && !LostContact(3+2*FRand())) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else if ( Skill + Tactics >= 3.5 + FRand() && !LostContact(1) && VSize(Enemy.Location - Pawn.Location) < MAXSTAKEOUTDIST &&
			Pawn.Weapon != None && Pawn.Weapon.AIRating > 0.5 && !Pawn.Weapon.bMeleeWeapon &&
			FRand() < 0.75 && !LineOfSightTo(Enemy) && !Enemy.LineOfSightTo(Pawn) &&
			(Squad == None || !UTSquadAI(Squad).HasOtherVisibleEnemy(self)) )
		{
			GoalString = "Stake Out 3";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	// see enemy - decide whether to charge it or strafe around/stand and fire
	BlockedPath = None;
	Focus = Enemy;

	if( Pawn.Weapon.bMeleeWeapon || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}
	if ( Pawn.RecommendLongRangedAttack() )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	if ( UTWeapon(Pawn.Weapon).RecommendRangedAttack() || IsSniping() || ((FRand() > 0.17 * (skill + Tactics - 1)) && !DefendMelee(enemyDist)) )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge )
	{
		if ( Aggression > 1 )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}
	GoalString = "Do tactical move";
	if ( !UTWeapon(Pawn.Weapon).bRecommendSplashDamage && (FRand() < 0.7) && (3*Jumpiness + FRand()*Skill > 3) )
	{
		GetAxes(Pawn.Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else
			TryToDuck(Y, false);
	}
	DoTacticalMove();
}

function DoRangedAttackOn(Actor A)
{
	local UTVehicle V;

	// leave vehicle if it's not useful for shooting things
	V = UTVehicle(Pawn);
	if (V != None && V.bShouldLeaveForCombat)
	{
		LeaveVehicle(false);
	}

	Focus = A;
	LastFireTarget = Focus;
	GotoState('RangedAttack');
}

/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ChooseAttackMode()
{
	local float EnemyStrength, WeaponRating, RetreatThreshold;

	GoalString = " ChooseAttackMode last seen "$(WorldInfo.TimeSeconds - LastSeenTime);
	// should I run away?
	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		`log("HERE 1 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);
	EnemyStrength = RelativeStrength(Enemy);
	if ( EnemyStrength > RetreatThreshold && (PlayerReplicationInfo.Team != None) && (FRand() < 0.25)
		&& (WorldInfo.TimeSeconds - LastInjuredVoiceMessageTime > 45.0) )
	{
		LastInjuredVoiceMessageTime = WorldInfo.TimeSeconds;
		SendMessage(None, 'INJURED', 35);
	}
	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(true, EnemyStrength);
		return;
	}
	if ( !bFrustrated && !UTSquadAI(Squad).MustKeepEnemy(Enemy) )
	{
		RetreatThreshold = Aggressiveness;
		if ( UTWeapon(Pawn.Weapon).CurrentRating > 0.5 )
			RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
		if ( EnemyStrength > RetreatThreshold )
		{
			GoalString = "Retreat";
			if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05)
				&& (WorldInfo.TimeSeconds - LastInjuredVoiceMessageTime > 45.0) )
			{
				LastInjuredVoiceMessageTime = WorldInfo.TimeSeconds;
				SendMessage(None, 'INJURED', 35);
			}
			DoRetreat();
			return;
		}
	}

	if ( (UTSquadAI(Squad).PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon.AIRating < 0.5)) )
	{
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			if ( EnemyStrength > 0.3 )
				WeaponRating = 0;
			else
				WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/2000;
		}
		else if ( EnemyStrength > 0.3 )
			WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/2000;
		else
			WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/1000;

		// fallback to better pickup?
		if ( FindInventoryGoal(WeaponRating) )
		{
			if ( PickupFactory(RouteGoal) == None )
				GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
			else
				GoalString = "Fallback to better pickup " $ RouteGoal $ " hidden " $ RouteGoal.bHidden;
			GotoState('FallBack');
			return;
		}
	}

	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true, EnemyStrength);
}

function bool FindSuperPickup(float MaxDist)
{
	local actor BestPath;
	local UTPickupFactory P;

	if ( (LastSearchTime == WorldInfo.TimeSeconds) || ((!Pawn.bCanPickupInventory || Vehicle(Pawn) != None) && !bCheckDriverPickups) )
		return false;

	if ( (UTDeathMatch(WorldInfo.Game) != None) && !UTDeathMatch(WorldInfo.Game).WantsPickups(self) )
		return false;

	LastSearchTime = WorldInfo.TimeSeconds;
	LastSearchWeight = -1;

	BestPath = FindBestSuperPickup(MaxDist);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		P = UTPickupFactory(RouteGoal);
		if ( (P != None) && (PlayerReplicationInfo.Team != None)
			&& (PlayerReplicationInfo.Team.TeamIndex < 4) )
		{
			P.TeamOwner[PlayerReplicationInfo.Team.TeamIndex] = self;
			if ( WorldInfo.TimeSeconds - P.LastSeekNotificationTime > 30.0 )
			{
				P.LastSeekNotificationTime = WorldInfo.TimeSeconds;
				SendMessage(None, 'LOCATION', 10, None);
			}
		}
		return true;
	}
	return false;
}


function bool FindInventoryGoal(float BestWeight)
{
	local actor BestPath;
	local UTPickupFactory P;

	if ( (LastSearchTime == WorldInfo.TimeSeconds) && (LastSearchWeight >= BestWeight) )
		return false;

	if ( (UTDeathMatch(WorldInfo.Game) != None) && !UTDeathMatch(WorldInfo.Game).WantsPickups(self) )
		return false;

	if ( (Vehicle(Pawn) != None) ? !bCheckDriverPickups : !Pawn.bCanPickupInventory )
		return false;

	LastSearchTime = WorldInfo.TimeSeconds;
	LastSearchWeight = BestWeight;

	 // look for inventory
	if ( (Skill > 3) && (Enemy == None) )
		RespawnPredictionTime = 4;
	else
		RespawnPredictionTime = 0;
	BestPath = FindBestInventoryPath(BestWeight);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		P = UTPickupFactory(RouteGoal);
		if ( (P!=None) && (P == Pawn.Anchor) && Pawn.IsOverlapping(P) )
		{
			P.Touch(Pawn, Pawn.Mesh, P.Location, vect(0,0,1));
		}
		if ( (P != None) && P.bIsSuperItem && (PlayerReplicationInfo.Team != None)
				&& (PlayerReplicationInfo.Team.TeamIndex < 4) )
		{
				if ( WorldInfo.TimeSeconds - P.LastSeekNotificationTime > 30.0 )
				{
					P.LastSeekNotificationTime = WorldInfo.TimeSeconds;
					SendMessage(None, 'LOCATION', 10, None);
				}
		}
		return true;
	}
	return false;
}

/**
 * TossFlagToPlayer()
 * If a player is nearby, transfer the flag / orb to the nearest player
 * Otherwise, just drop the flag / orb
 */
function TossFlagToPlayer(Controller OrderGiver)
{
	local UTPawn BotPawn;
	local UTPlayerReplicationInfo PRI;
	local UTCarriedObject Flag;
	local float FlagVelocityZ;

	if (UTPawn(Pawn) != None)
	{
		BotPawn = UTPawn(Pawn);
		PRI = UTPlayerReplicationInfo(BotPawn.PlayerReplicationInfo);
	}
	else if (UTPawn(UTVehicle(Pawn).Driver) != None)
	{
		BotPawn = UTPawn(UTVehicle(Pawn).Driver);
		PRI = UTPlayerReplicationInfo(UTVehicle(Pawn).PlayerReplicationInfo);
	}

	if (BotPawn == None || PRI == None)
		return;

	Flag = PRI.GetFlag();
	if (Flag == None)
		return;

	// Drop the flag, and don't pick it up for a while
	Flag.Drop();
	ForcedFlagDropTime = WorldInfo.TimeSeconds;

	// If near the player, throw it toward him
	if ( (OrderGiver != None) && (OrderGiver.Pawn != None) )
	{
		FlagVelocityZ = Flag.Velocity.Z;
		Flag.Velocity.Z = 0;
		Flag.Velocity = VSize(Flag.Velocity) * Normal(OrderGiver.Pawn.Location - Pawn.Location);
		Flag.Velocity.Z = FlagVelocityZ;
	}
}

function bool PickRetreatDestination()
{
	local actor BestPath;

	if ( FindInventoryGoal(0) )
		return true;

	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		RouteGoal = FindRandomDest();
		if ( RouteGoal == None )
			return false;
		BestPath = RouteCache[0];
	}

	if ( BestPath == None )
		BestPath = FindPathToward(RouteGoal,Pawn.bCanPickupInventory  && (Vehicle(Pawn) == None));
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	RouteGoal = None;
	return false;
}

event SoakStop(optional string problem)
{
	local UTPlayerController PC;

	`log(problem);
	SoakString = problem;
	GoalString = SoakString@GoalString;
	ForEach DynamicActors(class'UTPlayerController',PC)
	{
		PC.SoakPause(Pawn);
		break;
	}
}

function bool FindRoamDest()
{
	local actor BestPath;

	if ( Pawn.FindAnchorFailedTime == WorldInfo.TimeSeconds )
	{
		// if we have no anchor, there is no point in doing this because it will fail
		return false;
	}
	NumRandomJumps = 0;
	GoalString @= "- Find roam dest "$WorldInfo.TimeSeconds;
	if (RouteGoal != None && Pawn.Anchor != RouteGoal && !Pawn.ReachedDestination(RouteGoal))
	{
		BestPath = FindPathToward(RouteGoal, false);
	}
	// find random NavigationPoint to roam to
	if (BestPath == None)
	{
		RouteGoal = FindRandomDest();
		if ( RouteGoal == None )
		{
			GoalString = "Failed to find roam dest";
			if ( bSoaking && (Physics != PHYS_Falling) )
			{
				SoakStop("COULDN'T FIND ROAM DESTINATION");
			}
			FreePoint();
			return false;
		}
		BestPath = RouteCache[0];
	}
	MoveTarget = BestPath;
	SetAttractionState();
	return true;
}

function Restart(bool bVehicleTransition)
{
	if ( !bVehicleTransition )
	{
		Super.Restart(bVehicleTransition);
		ReSetSkill();
		GotoState('Roaming','DoneRoaming');
		ClearTemporaryOrders();
	}
	else if ( Pawn != None )
		Pawn.Restart();
}

function bool CheckPathToGoalAround(Pawn P)
{
	return false;
}

function ClearPathFor(Controller C)
{
	if ( Vehicle(Pawn) != None )
		return;
	if ( AdjustAround(C.Pawn) )
		return;
	if ( Enemy != None )
	{
		if ( LineOfSightTo(Enemy) && Pawn.bCanStrafe )
		{
			GotoState('TacticalMove');
			return;
		}
	}
	else if ( Stopped() && !Pawn.bStationary )
		MoveAwayFrom(C);
}

function bool AdjustAround(Pawn Other)
{
	local vector VelDir, OtherDir, SideDir, HitLocation, HitNormal, Adj;

	if ( !InLatentExecution(LATENT_MOVETOWARD) )
		return false;

	VelDir = Normal(MoveTarget.Location - Pawn.Location);
	VelDir.Z = 0;
	OtherDir = Other.Location - Pawn.Location;
	OtherDir.Z = 0;
	OtherDir = Normal(OtherDir);
	if ( (VelDir Dot OtherDir) > 0.8 )
	{
		SideDir.X = VelDir.Y;
		SideDir.Y = -1 * VelDir.X;
		if ( (SideDir Dot OtherDir) > 0 )
			SideDir *= -1;
		Adj = Pawn.Location + 3 * Other.GetCollisionRadius() * (0.5 * VelDir + SideDir);
		// make sure adjust location isn't through a wall
		if (Trace(HitLocation, HitNormal, Adj, Pawn.Location, false) != None)
		{
			Adj = HitLocation;
		}

		SetAdjustLocation( Adj, TRUE );

		return true;
	}
	else
	{
		return false;
	}
}

event bool NotifyBump(Actor Other, Vector HitNormal)
{
	local Pawn P;
	local UTVehicle V;

	if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
	{
		if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
		{
			V = UTVehicle(Other);
			if ( V != None )
			{
				V.TryToDrive(Pawn);
				if (Vehicle(Pawn) != None)
				{
					UTSquadAI(Squad).BotEnteredVehicle(self);
					WhatToDoNext();
				}
			}
			return true;
		}
	}

	// temporarily disable bump notifications to avoid getting overwhelmed by them
	Disable('NotifyBump');
	settimer(1.0, false, 'EnableBumps');

	P = Pawn(Other);
	if ( (P == None) || (P.Controller == None) || (Enemy == P) )
		return false;
	if ( (Squad != None) && UTSquadAI(Squad).SetEnemy(self,P) )
	{
		WhatToDoNext();
		return false;
	}

	if ( Enemy == P )
		return false;

	if ( CheckPathToGoalAround(P) )
		return false;

	ClearPathFor(P.Controller);
	return false;
}

function bool PriorityObjective()
{
	return (UTSquadAI(Squad).PriorityObjective(self) > 0);
}

function SetFall()
{
	local vector TestVelocity, AdjustedDest, Dir;
	local UTPawn P;
	local NavigationPoint Nav;

	if (Pawn.bCanFly)
	{
		Pawn.SetPhysics(PHYS_Flying);
		return;
	}
	P = UTPawn(Pawn);
	if (P != None && P.bNoJumpAdjust)
	{
		UTPawn(Pawn).bNoJumpAdjust = false;
		return;
	}
	else
	{
		bPlannedJump = true;
		AdjustedDest = (MoveTarget != None) ? MoveTarget.GetDestination(self) : GetDestinationPosition();
		Pawn.SuggestJumpVelocity(Pawn.Velocity, (MoveTarget != None) ? MoveTarget.GetDestination(self) : GetDestinationPosition(), Pawn.Location);
		if (P != None && P.bRequiresDoubleJump)
		{
			// if trying to avoid double jumps, see if really need to
			Nav = NavigationPoint(MoveTarget);
			if (HighJumpNodeCostModifier > 0 && Nav != None)
			{
				Dir = AdjustedDest - Location;
				Dir.Z = 0;
				AdjustedDest -= Normal(Dir) * Nav.CylinderComponent.CollisionRadius;
				if (!FastTrace(AdjustedDest, AdjustedDest - vect(0,0,1) * (Nav.CylinderComponent.CollisionHeight + 5.0)))
				{
					Pawn.SuggestJumpVelocity(TestVelocity, AdjustedDest, Pawn.Location);
					if (!P.bRequiresDoubleJump)
					{
						P.Velocity = TestVelocity;
					}
				}
			}
			if (P.bRequiresDoubleJump)
			{
				bNotifyApex = true;
				bPendingDoubleJump = true;
			}
		}
		Pawn.Acceleration = vect(0,0,0);
	}
}

event bool NotifyLanded(vector HitNormal, Actor FloorActor)
{
	local vector Vel2D;

	LastBlockingVehicle = Vehicle(FloorActor);

	bInDodgeMove = false;
	bPlannedJump = false;
	bNotifyFallingHitWall = false;
	if ( MoveTarget != None )
	{
		Vel2D = Pawn.Velocity;
		Vel2D.Z = 0;
		if ( (Vel2D Dot (MoveTarget.Location - Pawn.Location)) < 0 )
		{
			Pawn.Acceleration = vect(0,0,0);
			if ( NavigationPoint(MoveTarget) != None )
				Pawn.SetAnchor(NavigationPoint(MoveTarget));
			MoveTimer = -1;
		}
		else
		{
			if ( (NavigationPoint(MoveTarget) != None) && InLatentExecution(LATENT_MOVETOWARD) && (FRand() < 0.85)
				&& (FRand() < DodgeToGoalPct) && (Pawn.Location.Z + Pawn.MaxStepHeight >= MoveTarget.Location.Z)
				&& (VSize(MoveTarget.Location - Pawn.Location) > 800) )
				bNotifyPostLanded = true;
		}
	}
	return false;
}

event NotifyPostLanded()
{
	bNotifyPostLanded = false;
	SetTimer(0.25 + 0.15 * FRand(), false, 'TimedDodgeToMoveTarget');
}

/** used on a timer when bot may consider a second dodge towards its MoveTarget to emulate double click delay */
function TimedDodgeToMoveTarget()
{
	if ( (Pawn != None) && (Pawn.Physics == PHYS_Walking) && (CurrentPath != None)
			&& ((CurrentPath.reachFlags & 257) == CurrentPath.reachFlags) )
	{
		MayDodgeToMoveTarget();
	}
}

function bool StartMoveToward(Actor O)
{
	if ( MoveTarget == None )
	{
		if ( (O == Enemy) && (O != None) )
		{
			FailedHuntTime = WorldInfo.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Pawn.Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND ROUTE TO "$O.GetHumanReadableName());
		GoalString = "No path to "$O.GetHumanReadableName()@"("$O$")";
	}
	else
		SetAttractionState();
	return ( MoveTarget != None );
}

function bool SetRouteToGoal(Actor A)
{
	if (Pawn.bStationary)
		return false;

	RouteGoal = A;
	FindBestPathToward(A,false,true);
	return StartMoveToward(A);
}

event bool AllowDetourTo(NavigationPoint N)
{
	return UTSquadAI(Squad).AllowDetourTo(self,N);
}

/* FindBestPathToward()
Assumes the desired destination is not directly reachable.
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	if ( !bCheckedReach && ActorReachable(A) )
	{
		MoveTarget = A;
	}
	else
	{
		MoveTarget = FindPathToward(A, (bAllowDetour && Pawn.bCanPickupInventory && (Vehicle(Pawn) == None) && (NavigationPoint(A) != None) && !bForceNoDetours));
	}

	if ( MoveTarget != None )
	{
		return true;
	}
	else
	{
		if (A == Enemy && A != None)
		{
			if (Pawn.Physics == PHYS_Flying)
			{
				LoseEnemy();
			}
			else
			{
				FailedHuntTime = WorldInfo.TimeSeconds;
				FailedHuntEnemy = Enemy;
			}
		}
		if ( bSoaking && (Physics != PHYS_Falling) )
		{
			SoakStop("COULDN'T FIND BEST PATH TO "$A);
		}
	}
	return false;
}

function vector GetDirectionHint()
{
	local vector Result;

	Result =  DirectionHint;
	DirectionHint = vect(0,0,0);
	return Result;
}

// check for line of sight to target deltatime from now.
function bool CheckFutureSight(float deltatime)
{
	local vector FutureLoc;

	if ( Pawn.Acceleration == vect(0,0,0) )
		FutureLoc = Pawn.Location;
	else
		FutureLoc = Pawn.Location + Pawn.GroundSpeed * Normal(Pawn.Acceleration) * deltaTime;

	if ( Pawn.Base != None )
		FutureLoc += Pawn.Base.Velocity * deltaTime;
	//make sure won't run into something
	if ( !FastTrace(FutureLoc, Pawn.Location) && (Pawn.Physics != PHYS_Falling) )
		return false;

	//check if can still see target
	if ( FastTrace(GetFocalPoint() + TrackedVelocity * deltatime, FutureLoc) )
		return true;

	return false;
}

/*
 * Aiming code requests an update to the aiming error periodically when tracking a target, based on ErrorUpdateFrequency.
 */
event float AdjustAimError(float TargetDist, bool bInstantProj )
{
	local float aimdist, desireddist, NewAngle, aimerror, TargetRadius, TargetHeight, FullAcquisitionTime, LowVisibilityMult;
	local bool bDefendMelee;
	local UTMapInfo MapInfo;
	local Pawn PFocus;

	if (UTWeapon(Pawn.Weapon) == None)
	{
		return 0;
	}

	aimerror = UTWeapon(Pawn.Weapon).AimError;

	PFocus = Pawn(Focus);

	// if we can't really see the enemy due to fog or whatever, increase error
	MapInfo = UTMapInfo(WorldInfo.GetMapInfo());
	if ( (MapInfo != None) && (MapInfo.VisibilityModifier < 1.0) && (TargetDist > Pawn.SightRadius * 0.75 * MapInfo.VisibilityModifier) )
	{
		LowVisibilityMult = (TargetDist > Pawn.SightRadius * MapInfo.VisibilityModifier) ? 4.0 : 2.0;
		// not as much of a modifier against large targets
		if (PFocus != None && PFocus.GetCollisionRadius() + PFocus.GetCollisionHeight() > 200.0)
		{
			LowVisibilityMult *= 0.75;
		}
		aimerror *= LowVisibilityMult;
	}

	if (PFocus != None && PFocus.IsInvisible())
	{
		aimerror *= 4.0;
	}

	if (PFocus != None && PFocus.bStationary)
	{
		aimerror *= 0.15;
		return (Rand(2 * aimerror) - aimerror);
	}

	// if enemy is charging straight at bot with a melee weapon, improve aim
	bDefendMelee = ( (Focus == Enemy) && DefendMelee(TargetDist) );
	if ( bDefendMelee )
		aimerror *= 0.5;

	if ( VSizeSq(TrackedVelocity) < 2500.f )
		aimerror *= (0.2 + 0.06 * (7 - FMin(7,Skill)));

	// aiming improves over time if stopped
	if ( Stopped() && (WorldInfo.TimeSeconds > StopStartTime) )
	{
		if ( (Skill+Accuracy) > 4 )
			aimerror *= 0.75;

		if ( UTWeapon(Pawn.Weapon) != None && UTWeapon(Pawn.Weapon).bSniping )
			aimerror *= FClamp((1.5 - 0.08 * FMin(skill,7) - 0.8 * FRand())/(WorldInfo.TimeSeconds - StopStartTime + 0.4),0.3,1.0);
		else
			aimerror *= FClamp((2 - 0.08 * FMin(skill,7) - FRand())/(WorldInfo.TimeSeconds - StopStartTime + 0.4),0.7,1.0);
	}

	// adjust aim error based on skill
	if ( !bDefendMelee )
		aimerror *= (3.3 - 0.4 * (FClamp(skill+Accuracy,0,8) + 0.3 * FRand()));

	// Bots don't aim as well if recently hit, or if they or their target is flying through the air
	if ( (skill < 5 + 2*FRand()) && (WorldInfo.TimeSeconds - Pawn.LastPainTime < 0.2) )
		aimerror *= 1.3;
	if (Pawn.Physics == PHYS_Falling) // don't consider target physics here because native tracking covers it
		aimerror *= (1.6 - 0.04*(Skill+Accuracy));

	// Bots don't aim as well at recently acquired targets (because they haven't had a chance to lock in to the target)
	FullAcquisitionTime = 0.5 + 1.0 * (7.0 - FMin(7.0, Skill + ReactionTime));
	if ( AcquireTime > WorldInfo.TimeSeconds - FullAcquisitionTime )
	{
		if ( Skill < 6.0 )
		{
			aimerror *= 2.0;
			if ( bInstantProj )
				aimerror *= 1.2;
		}
		else
		{
			aimerror *= 1.5;
			if ( bInstantProj )
				aimerror *= 1.5;
		}
	}

	aimerror = 2.0 * aimerror * FRand() - aimerror;
	if (Abs(aimerror) > 900.0)
	{
		if ( bInstantProj )
			DesiredDist = 180;
		else
			DesiredDist = 500;
		GetBoundingCylinder(TargetRadius,TargetHeight);
		DesiredDist += TargetRadius;
		aimdist = tan(AngleConvert * aimerror) * targetdist;
		if ( abs(aimdist) > DesiredDist )
		{
			NewAngle = ATan2(DesiredDist,TargetDist)/AngleConvert;
			if ( aimerror > 0 )
				aimerror = NewAngle;
			else
				aimerror = -1 * NewAngle;
		}
	}
	return aimerror;
}

/*
GetAdjustedAimFor()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/
function Rotator GetAdjustedAimFor( Weapon InWeapon, vector projstart )
{
	local rotator FireRotation;
	local float TargetDist, ProjSpeed, TargetHeight;
	local actor HitActor;
	local vector FireSpot, FireDir, HitLocation, HitNormal;
	local bool bDefendMelee, bClean;
	local class<UTProjectile> ProjectileClass;
	local UTWeapon W;

	// make sure bot has a valid target
	if ( Focus == None )
		return Rotation;

	W = UTWeapon(InWeapon);
	if ( W == None )
		return Rotation;

	ProjectileClass = class<UTProjectile>(W.GetProjectileClass());
	if ( ProjectileClass != None )
		projspeed = ProjectileClass.default.speed;

	FireSpot = GetFocalPoint();
	TargetDist = VSize(GetFocalPoint() - Pawn.Location);

	// perfect aim at stationary objects
	if ( Focus.IsStationary() )
	{
		if ( (ProjectileClass == None) || (ProjectileClass.Default.Physics != PHYS_Falling) )
		{
			FireRotation = rotator(GetFocalPoint() - projstart);
		}
		else
		{
			SuggestTossVelocity(FireDir, GetFocalPoint(), ProjStart, projspeed, ProjectileClass.Default.TossZ, 0.2,, PhysicsVolume.bWaterVolume ? PhysicsVolume.TerminalVelocity : ProjectileClass.Default.TerminalVelocity);
			FireRotation = rotator(FireDir);
		}
		// make sure bot shoots in the direction it's facing
		// our vehicles do their own aim clamping stuff so we don't need this
		if (Vehicle(Pawn) == None)
		{
			FireRotation.Yaw = Pawn.Rotation.Yaw;
		}
		SetRotation(FireRotation);
		return Rotation;
	}

	if ( (WorldInfo.TimeSeconds - LastActionMusicUpdate > 6.0) && (Enemy != None) && (Focus == Enemy) && (UTPlayerController(Enemy.Controller) != None) )
	{
		LastActionMusicUpdate = WorldInfo.TimeSeconds;
		UTPlayerController(Enemy.Controller).ClientMusicEvent(0);
	}

	bDefendMelee = ( (Focus == Enemy) && DefendMelee(TargetDist) );

	bClean = false; //so will fail first check unless shooting at feet

	if ( Pawn(Focus) != None )
		TargetHeight = Pawn(Focus).GetCollisionHeight();

	// adjust for toss distance
	if ( (ProjectileClass != None) && (ProjectileClass.Default.Physics == PHYS_Falling) )
	{
		if ( W.bRecommendSplashDamage && (Pawn(Focus) != None) && ((Skill >=4) || bDefendMelee)
			&& (((Focus.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= GetFocalPoint().Z))
				|| ((Pawn.Location.Z + 19 >= GetFocalPoint().Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
		{
			FireSpot = FireSpot - vect(0,0,1) * TargetHeight;
		}
		// toss at target
		SuggestTossVelocity(FireDir, FireSpot, ProjStart, projspeed, ProjectileClass.Default.TossZ, 0.2,, PhysicsVolume.bWaterVolume ? PhysicsVolume.TerminalVelocity : ProjectileClass.Default.TerminalVelocity);
	}
	else
	{
		if ( W.bRecommendSplashDamage && (Pawn(Focus) != None) )
		{
			if ( W.bLockedAimWhileFiring )
			{
				// it's a levi - fire at ground
	 			HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1000), FireSpot, false);
 				bClean = (HitActor == None);
				if ( !bClean )
				{
					FireSpot = HitLocation + vect(0,0,20);
					bClean = FastTrace(FireSpot, ProjStart);
				}
				else
				{
					bClean = FastTrace(FireSpot, ProjStart);
				}
			}
			else if ( ((Skill >=4) || bDefendMelee)
			&& (((Focus.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= GetFocalPoint().Z))
				|| ((Pawn.Location.Z + 19 >= GetFocalPoint().Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
		{
	 		HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (TargetHeight + 6), FireSpot, false);
 			bClean = (HitActor == None);
			if ( !bClean )
			{
				FireSpot = HitLocation + vect(0,0,3);
				bClean = FastTrace(FireSpot, ProjStart);
			}
			else
				bClean = ( (Focus.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
		}
		}
		if ( W.bSniping && Stopped() && (Skill > 5 + 6 * FRand()) )
		{
			// try head
 			FireSpot.Z = GetFocalPoint().Z + 0.9 * TargetHeight;
 			bClean = FastTrace(FireSpot, ProjStart);
		}

		if ( !bClean )
		{
			//try middle
			FireSpot.Z = GetFocalPoint().Z;
 			bClean = FastTrace(FireSpot, ProjStart);
		}
		if ( (ProjectileClass != None) && (ProjectileClass.Default.Physics == PHYS_Falling) && !bClean && bEnemyInfoValid )
		{
			FireSpot = LastSeenPos;
	 		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
			if ( HitActor != None )
			{
				bCanFire = false;
				FireSpot += 2 * TargetHeight * HitNormal;
			}
			bClean = true;
		}

		if( !bClean )
		{
			// try head
 			FireSpot.Z = GetFocalPoint().Z + 0.9 * TargetHeight;
 			bClean = FastTrace(FireSpot, ProjStart);
		}
		if (!bClean && (Focus == Enemy) && bEnemyInfoValid)
		{
			FireSpot = LastSeenPos;
			if ( Pawn.Location.Z >= LastSeenPos.Z )
				FireSpot.Z -= 0.4 * TargetHeight;
	 		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
			if ( HitActor != None )
			{
				FireSpot = LastSeenPos + 2 * TargetHeight * HitNormal;
				if ( Pawn.Weapon != None && Pawn.Weapon.GetDamageRadius() > 0 && (Skill >= 4) )
				{
			 		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
					if ( HitActor != None )
						FireSpot += 2 * TargetHeight * HitNormal;
				}
				if ( UTWeapon(Pawn.Weapon) != None && !UTWeapon(Pawn.Weapon).bFastRepeater )
				{
					bCanFire = false;
			}
		}
		}

		FireDir = FireSpot - ProjStart;
	}

	FireRotation = Rotator(FireDir);
	// make sure bot shoots in the direction it's facing
	// our vehicles do their own aim clamping stuff so we don't need this
	if (Vehicle(Pawn) == None)
	{
		FireRotation.Yaw = Pawn.Rotation.Yaw;
	}

	if (ProjectileClass == None)
	{
		InstantWarnTarget(Focus, Pawn.Weapon, vector(FireRotation));
	}
	ShotTarget = Pawn(Focus);

	SetRotation(FireRotation);
	return FireRotation;
}

/** considers attempting to dodge an enemy shot by dodging in the closest dodge direction to our MoveTarget
 * @return whether the bot attempted a dodge
 */
function bool TryDuckTowardsMoveTarget(vector Dir, vector Y)
{
	local vector MoveDir;

	if (MoveTarget != None && InLatentExecution(LATENT_MOVETOWARD) && Skill + StrafingAbility > 4.0 + 2.0 * FRand())
	{
		// try to duck towards MoveTarget
		MoveDir = MoveTarget.Location - Pawn.Location;
		MoveDir.Z = 0.0;
		MoveDir = Normal(MoveDir);
		if (Abs(MoveDir dot Dir) < 0.5)
		{
			if ((MoveDir dot Y) < 0.0)
			{
				Y *= -1;
				TryToDuck(Y, true);
			}
			else
			{
				TryToDuck(Y, false);
			}
			return true;
		}
	}

	return false;
}

/* If ReceiveWarning caused WarningDelay to be set, this will be called when it times out
*/
event DelayedWarning()
{
	local vector X,Y,Z, Dir, LineDist, FuturePos, HitLocation, HitNormal;
	local actor HitActor;
	local float dist;

	if ( (Pawn == None) || (WarningProjectile == None) || (WarningProjectile.Velocity == vect(0,0,0)) )
		return;
	if ( Enemy == None )
	{
		if ( Squad != None )
			UTSquadAI(Squad).SetEnemy(self, WarningProjectile.Instigator);
		return;
	}

	if ( UTVehicle_Hoverboard(Pawn) != None )
	{
		if ( (FRand() < 0.5) && (Skill >= 1.0) )
		{
			LeaveVehicle(true);
		}
		return;
	}

	// check if still on target, else ignore
	Dir = Normal(WarningProjectile.Velocity);
	FuturePos = Pawn.Location + Pawn.Velocity * VSize(WarningProjectile.Location - Pawn.Location)/VSize(WarningProjectile.Velocity);
	LineDist = FuturePos - (WarningProjectile.Location + (Dir Dot (FuturePos - WarningProjectile.Location)) * Dir);
	dist = VSize(LineDist);
	if ( dist > 230 + Pawn.GetCollisionRadius() )
		return;
	if ( dist > 1.2 * Pawn.GetCollisionHeight() )
	{
		if ( WarningProjectile.Damage <= 40 && Pawn.Health > WarningProjectile.Damage )
			return;

		if ( (WarningProjectile.Physics == PHYS_Projectile) && (dist > Pawn.GetCollisionHeight() + 100) && !WarningProjectile.IsA('UTProj_Shockball') )
		{
			HitActor = Trace(HitLocation, HitNormal, WarningProjectile.Location + WarningProjectile.Velocity, WarningProjectile.Location, false);
			if ( HitActor == None )
				return;
		}
	}

	GetAxes(Pawn.Rotation,X,Y,Z);
	X.Z = 0;
	Dir = WarningProjectile.Location - Pawn.Location;
	Dir.Z = 0;
	Dir = Normal(Dir);

	// make sure still looking at projectile
	if ((Dir Dot Normal(X)) < 0.7)
		return;

	// decide which way to duck
	if (!TryDuckTowardsMoveTarget(Dir, Y))
	{
		if ( (WarningProjectile.Velocity Dot Y) > 0 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else
		{
			TryToDuck(Y, false);
		}
	}
}

/* epic ===============================================
* ::ReceiveProjectileWarning
*
* Notification that the pawn is about to be shot by a
* projectile.
*
* =====================================================
*/
function ReceiveProjectileWarning(Projectile Proj)
{
	local float ProjTime;
	local vector X,Y,Z, enemyDir;

	LastUnderFire = WorldInfo.TimeSeconds;
	if ( WorldInfo.TimeSeconds - LastWarningTime < 0.5 )
		return;
	LastWarningTime = WorldInfo.TimeSeconds;

	// bots may duck if not falling or swimming
	if ( (Pawn.health <= 0) || (Skill < 2) || (Enemy == None)
		|| (Pawn.Physics == PHYS_Swimming) )
		return;

	if ( proj.Speed > 0 )
	{
		ProjTime = Proj.GetTimeToLocation(Pawn.Location);
		// and projectile time is long enough
		if ( ProjTime < 0.35 - 0.03*(Skill+ReactionTime) )
			return;
		if ( ProjTime < 2 - (0.265 + FRand()*0.2) * (skill + ReactionTime) )
			return;

		if ( (WarningProjectile != None) && (VSize(WarningProjectile.Location - Pawn.Location)/WarningProjectile.Speed < ProjTime) )
			return;

		// check if tight FOV
		if ( (ProjTime < 1.2) || (WarningProjectile != None) )
		{
			GetAxes(Rotation,X,Y,Z);
			enemyDir = Proj.Location - Pawn.Location;
			enemyDir.Z = 0;
			X.Z = 0;
			if ((Normal(enemyDir) Dot Normal(X)) < 0.7)
				return;
		}

		if ( Skill + ReactionTime >= 7 )
			WarningDelay = WorldInfo.TimeSeconds + FMax(0.08,FMax(0.35 - 0.025*(Skill + ReactionTime)*(1 + FRand()), ProjTime - 0.65));
		else
			WarningDelay = WorldInfo.TimeSeconds + FMax(0.08,FMax(0.35 - 0.02*(Skill + ReactionTime)*(1 + FRand()), ProjTime - 0.65));
		WarningProjectile = Proj;
	}
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	LastUnderFire = WorldInfo.TimeSeconds;
	if ( (instigatedBy != None) && (instigatedBy != self) )
		damageAttitudeTo(instigatedBy, Damage);
}

/** called on a timer from ReceiveWarning() to dodge before the enemy's next instant hit shot */
function DelayedInstantWarning()
{
	local vector X,Y,Z, Dir;

	if ( Pawn == None || InstantWarningShooter == None || InstantWarningShooter.bDeleteMe ||
		InstantWarningShooter.Controller == None )
	{
		return;
	}
	if ( Enemy == None )
	{
		if ( Squad != None )
		{
			UTSquadAI(Squad).SetEnemy(self, InstantWarningShooter);
		}
		return;
	}

	GetAxes(Pawn.Rotation, X,Y,Z);
	X.Z = 0;
	Dir = InstantWarningShooter.Location - Pawn.Location;
	Dir.Z = 0;
	Dir = Normal(Dir);

	// make sure still looking at shooter
	if ((Dir Dot Normal(X)) < 0.7 || !LineOfSightTo(InstantWarningShooter))
	{
		return;
	}

	// decide which way to duck
	if (!TryDuckTowardsMoveTarget(Dir, Y))
	{
		if (FRand() < 0.5)
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else
		{
			TryToDuck(Y, false);
		}
	}
}

/* ReceiveWarning()
 AI controlled creatures may duck
 if not falling, and projectile time is long enough
 often pick opposite to current direction (relative to shooter axis)
*/
event ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist, projTime, DodgeTime;
	local vector X,Y,Z, enemyDir;

	LastUnderFire = WorldInfo.TimeSeconds;
	if ( WorldInfo.TimeSeconds - LastWarningTime < 0.5 )
		return;
	LastWarningTime = WorldInfo.TimeSeconds;

	// AI controlled creatures may duck if not falling
	if ( Pawn.bStationary || !Pawn.bCanStrafe || (Pawn.health <= 0) )
		return;
	if ( Enemy == None )
	{
		if ( Squad != None )
			UTSquadAI(Squad).SetEnemy(self, shooter);
		return;
	}

	if ( UTVehicle_Hoverboard(Pawn) != None )
	{
		if ( (FRand() < 0.5) && (Skill >= 1.0) )
		{
			LeaveVehicle(true);
		}
		return;
	}

	if ((Skill < 4.0) || (Pawn.Physics == PHYS_Swimming) || (FRand() > 0.2 * skill - 0.33))
		return;

	enemyDist = VSize(shooter.Location - Pawn.Location);

	if (enemyDist > 2000.0 * (Skill + StrafingAbility - 2.0) && Vehicle(shooter) == None && !Stopped() )
		return;

	// only if tight FOV
	GetAxes(Pawn.Rotation,X,Y,Z);
	enemyDir = shooter.Location - Pawn.Location;
	enemyDir.Z = 0;
	X.Z = 0;
	if ((Normal(enemyDir) Dot Normal(X)) < 0.7)
		return;

	if ( projSpeed > 0 && Vehicle(shooter) == None )
	{
		projTime = enemyDist/projSpeed;
		if ( projTime < 0.11 + 0.15 * FRand())
		{
			if ( Stopped() )
				GotoState('TacticalMove');
			return;
		}
	}

	if (Skill + StrafingAbility < 2.0 + 3.0 * FRand())
	{
		if (Stopped())
		{
			GotoState('TacticalMove');
		}
		return;
	}

	if (projSpeed < 0 && shooter.Weapon != None)
	{
		// instant hit attack
		// consider trying to dodge next shot instead of this one
		DodgeTime = shooter.Weapon.GetFireInterval(shooter.Weapon.CurrentFireMode) - 0.15 - 0.1 * FRand();
		if ( DodgeTime > 0.0 && DodgeTime >= 0.35 - 0.03 * (Skill + ReactionTime) &&
			DodgeTime >= 2.0 - (0.265 + FRand() * 0.2) * (Skill + ReactionTime) )
		{
			// check that we're not already going to dodge
			if ( InstantWarningShooter == None || InstantWarningShooter.bDeleteMe ||
				InstantWarningShooter.Controller == None ||  !IsTimerActive('DelayedInstantWarning') ||
				GetTimerRate('DelayedInstantWarning') - GetTimerCount('DelayedInstantWarning') > DodgeTime )
			{
				InstantWarningShooter = shooter;
				SetTimer(DodgeTime, false, 'DelayedInstantWarning');
			}
			return;
		}
	}

	if ( FRand() * (Skill + 4) < 4 )
	{
		if ( Stopped() )
			GotoState('TacticalMove');
		return;
	}

	if (Pawn.Physics == PHYS_Falling)
	{
		// no point in continuing, dodges below will fail
		return;
	}

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		if (TryToDuck(Y, true))
		{
			return;
		}
	}
	else
	{
		if (TryToDuck(Y, false))
		{
			return;
		}
	}

	// FIXME - if duck fails, try back jump if splashdamage landing

	if (Stopped())
	{
		GotoState('TacticalMove');
	}
}

/*
 Warning from vehicle that bot is about to be run over.
*/
event ReceiveRunOverWarning(UDKVehicle V, float projSpeed, vector VehicleDir)
{
	if ( !WorldInfo.GRI.OnSameTeam(V,self) )
	{
		// if enemy, just use normal ReceiveWarning()
		ReceiveWarning(V, projSpeed, VehicleDir);
		return;
	}

	if ( Pawn.bStationary || (Pawn.health <= 0)
		|| (Pawn.Physics == PHYS_Falling) || (Pawn.Physics == PHYS_Swimming) )
		return;

	// check that vehicle really is coming at me
	if ( PointDistToLine(Pawn.Location, VehicleDir, V.Location) > V.GetCollisionRadius() + V.GetCollisionHeight() + Pawn.GetCollisionRadius() + Pawn.GetCollisionHeight() )
		return;

	ReceiveWarning(V, projSpeed, VehicleDir);
}

event NotifyFallingHitWall( vector HitNormal, actor HitActor)
{
	bNotifyFallingHitWall = false;
	TryWallDodge(HitNormal, HitActor);
}

/** 
 * If DodgeLandZ (expected min landing height of dodge) is missed when bInDodgeMove is true,
 * the MissedDodge() event is triggered.
 */
event MissedDodge()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation, Extent, Vel2D;

	if ( UTPawn(Pawn).CanDoubleJump() && (Abs(Pawn.Velocity.Z) < 100) )
	{
		UTPawn(Pawn).DoDoubleJump(false);
		bPendingDoubleJump = false;
	}

	Extent = Pawn.GetCollisionRadius() * vect(1,1,0);
	Extent.Z = Pawn.GetCollisionHeight();
	HitActor = trace(HitLocation, HitNormal, Pawn.Location - (20 + 3*Pawn.MaxStepHeight) * vect(0,0,1), Pawn.Location, false, Extent);
	Vel2D = Pawn.Velocity;
	Vel2D.Z = 0;
	if ( HitActor != None )
	{
		Pawn.Acceleration = -1 * Pawn.AccelRate * Normal(Vel2D);
		Pawn.Velocity.X = 0;
		Pawn.Velocity.Z = 0;
		return;
	}
	Pawn.Acceleration = Pawn.AccelRate * Normal(Vel2D);
}


function bool TryWallDodge(vector HitNormal, actor HitActor)
{
	local vector X,Y,Z, Dir, TargetDir, NewHitNormal, HitLocation, Extent;
	local float DP;
	local Actor NewHitActor;

	if ( (Abs(HitNormal.Z) > 0.7) || !HitActor.bWorldGeometry )
		return false;

	if ( (Pawn.Velocity.Z < -150) && (FRand() < 0.4) )
		return false;

	if (UTPawn(Pawn).bDodging)
	{
		return false;
	}

	// check that it was a legit, visible wall
	Extent = Pawn.GetCollisionRadius() * vect(1,1,0);
	Extent.Z = 0.5 * Pawn.GetCollisionHeight();
	NewHitActor = Trace(HitLocation, NewHitNormal, Pawn.Location - 32*HitNormal, Pawn.Location, false, Extent);
	if ( NewHitActor == None )
		return false;

	GetAxes(Pawn.Rotation,X,Y,Z);

	Dir = HitNormal;
	Dir.Z = 0;
	Dir = Normal(Dir);

	if ( InLatentExecution(LATENT_MOVETOWARD) )
	{
		TargetDir = MoveTarget.Location - Pawn.Location;
		TargetDir.Z = 0;
		TargetDir = Normal(TargetDir);
		DP = HitNormal Dot TargetDir;
		if ( (DP >= 0)
			&& (VSize(MoveTarget.Location - Pawn.Location) > 200) )
		{
			if ( DP < 0.7 )
				Dir = Normal( TargetDir + HitNormal * (1 - DP) );
			else
				Dir = TargetDir;
		}
	}
	if ( Abs(X Dot Dir) > Abs(Y Dot Dir) )
	{
		if ( (X Dot Dir) > 0 )
			UTPawn(Pawn).CurrentDir = DCLICK_Forward;
		else
			UTPawn(Pawn).CurrentDir = DCLICK_Back;
	}
	else if ( (Y Dot Dir) < 0 )
		UTPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UTPawn(Pawn).CurrentDir = DCLICK_Right;

 	bPlannedJump = true;
	UTPawn(Pawn).PerformDodge(UTPawn(Pawn).CurrentDir, Dir,Normal(Dir Cross vect(0,0,1)));
	return true;
}

function ChangeStrafe();

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent, Start;
	local actor HitActor;
	local bool bSuccess, bDuckLeft, bWallHit, bChangeStrafe;
	local float MinDist,Dist;

	if ( UTVehicle(Pawn) != None )
		return UTVehicle(Pawn).Dodge(DCLICK_None);
	if ( Pawn.bStationary )
		return false;
	if ( Stopped() )
		GotoState('TacticalMove');
	else if ( FRand() < 0.6 )
		bChangeStrafe = IsStrafing();


	if ( (Skill < 3) || Pawn.PhysicsVolume.bWaterVolume || (Pawn.Physics == PHYS_Falling)
		|| (Pawn.GetGravityZ() > WorldInfo.DefaultGravityZ) )
		return false;
    if ( Pawn.bIsCrouched || Pawn.bWantsToCrouch || (Pawn.Physics != PHYS_Walking) )
	return false;

	duckDir.Z = 0;
	duckDir *= 335;
	bDuckLeft = bReversed;
	Extent = Pawn.GetCollisionRadius() * vect(1,1,0);
	Extent.Z = Pawn.GetCollisionHeight();
	Start = Pawn.Location + vect(0,0,25);
	HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);

	MinDist = 150;
	Dist = VSize(HitLocation - Pawn.Location);
	if ( (HitActor == None) || ( Dist > 150) )
	{
		if ( HitActor == None )
			HitLocation = Start + duckDir;

		HitActor = Trace(HitLocation, HitNormal, HitLocation - Pawn.MaxStepHeight * vect(0,0,2.5), HitLocation, false, Extent);
		bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
	}
	else
	{
		bWallHit = Skill + 2*Jumpiness > 5;
		MinDist = 30 + MinDist - Dist;
	}

	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > MinDist) );
		if ( bSuccess )
		{
			if ( HitActor == None )
				HitLocation = Start + duckDir;

			HitActor = Trace(HitLocation, HitNormal, HitLocation - Pawn.MaxStepHeight * vect(0,0,2.5), HitLocation, false, Extent);
			bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
		}
	}
	if ( !bSuccess )
	{
		if ( bChangeStrafe )
			ChangeStrafe();
		return false;
	}

	if ( Skill + 2*Jumpiness > 3 + 3*FRand() )
		bNotifyFallingHitWall = true;

	if ( bNotifyFallingHitWall && bWallHit )
		bDuckLeft = !bDuckLeft; // plan to wall dodge
	if ( bDuckLeft )
		UTPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UTPawn(Pawn).CurrentDir = DCLICK_Right;

	bInDodgeMove = true;
	DodgeLandZ = Pawn.Location.Z;
	UTPawn(Pawn).Dodge(UTPawn(Pawn).CurrentDir);
	return true;
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageType)
{
	if ( Squad != None )
	{
		UTSquadAI(Squad).NotifyKilled(Killer,Killed,KilledPawn,damageType);
	}
}

function Actor FaceMoveTarget()
{
	if ( (MoveTarget != Enemy) && (MoveTarget != Focus) )
		StopFiring();
	return MoveTarget;
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( (UTVehicle(Pawn) != None) && !UTVehicle(Pawn).bFollowLookDir )
		return true;

	if ( (Skill + StrafingAbility < 3) && !UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag )
		return false;

	if ( WayPoint == Enemy )
	{
		if ( Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon )
			return false;
		return ( Skill + StrafingAbility > 5 * FRand() - 1 );
	}
	else if ( PickupFactory(WayPoint) == None )
	{
		N = NavigationPoint(WayPoint);
		if ( (N == None) || N.bNeverUseStrafing )
			return false;

		if ( N.FearCost > 200 )
			return true;
		if ( N.bAlwaysUseStrafing && (FRand() < 0.8) )
			return true;
	}
	if ( (Pawn(WayPoint) != None) || ((UTSquadAI(Squad).SquadLeader != None) && (WayPoint == UTSquadAI(Squad).SquadLeader.MoveTarget)) )
		return ( Skill + StrafingAbility > 5 * FRand() - 1 );

	if ( Skill + StrafingAbility < 6 * FRand() - 1 )
		return false;

	if ( !bFinalStretch && Enemy == None )
		return ( FRand() < 0.4 );

	if ( (WorldInfo.TimeSeconds - LastUnderFire < 2) )
		return true;
	if ( (Enemy != None) && LineOfSightTo(Enemy) )
		return ( FRand() < 0.85 );
	return ( FRand() < 0.6 );
}

/**
  * Used to determine which actor should be the focus of this bot (that he looks at while moving)
  */
function Actor FaceActor(float StrafingModifier)
{
	local float RelativeDir;
	local actor SquadFace;

	if ( (UTGameObjective(Focus) != None) && (Focus == Squad.SquadObjective) && (UTSquadAI(Squad).GetOrders() == 'ATTACK') && Pawn.IsFiring() && UTGameObjective(Focus).Shootable() )
		return Focus;

	SquadFace = UTSquadAI(Squad).SetFacingActor(self);
	if ( SquadFace != None )
		return SquadFace;
	if ( FocusOnLeader(false) )
	{
		if ( Vehicle(Focus) != None )
			FireWeaponAt(Focus);
		return Focus;
	}

	bRecommendFastMove = false;
	if ( (!Pawn.bCanStrafe && (UTVehicle(Pawn) == None || !UTVehicle(Pawn).bSeparateTurretFocus))
	     || (Enemy == None) || (WorldInfo.TimeSeconds - LastSeenTime > 6 - StrafingModifier) )
		return FaceMoveTarget();

	if ( (MoveTarget == Enemy) || (Vehicle(Pawn) != None) || ((skill + StrafingAbility >= 6) && !Pawn.Weapon.bMeleeWeapon)
		|| ((MoveTarget != None) && (VSize(MoveTarget.Location - Pawn.Location) < 4 * Pawn.GetCollisionRadius())) )
		return Enemy;
	if ( WorldInfo.TimeSeconds - LastSeenTime > 4 - StrafingModifier)
		return FaceMoveTarget();
	if ( (MoveTarget == None) || ((Skill > 2.5) && (UTCarriedObject(MoveTarget) != None)) )
		return Enemy;
	RelativeDir = Normal(Enemy.Location - Pawn.Location - vect(0,0,1) * (Enemy.Location.Z - Pawn.Location.Z))
			Dot Normal(MoveTarget.Location - Pawn.Location - vect(0,0,1) * (MoveTarget.Location.Z - Pawn.Location.Z));

	if ( RelativeDir > 0.85 )
		return Enemy;
	if ( (RelativeDir > 0.3) && (UTBot(Enemy.Controller) != None) && (MoveTarget == Enemy.Controller.MoveTarget) )
		return Enemy;
	if ( skill + StrafingAbility < 2 + FRand() )
		return FaceMoveTarget();

	if ( (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon && (RelativeDir < 0.3))
		|| (Skill + StrafingAbility < (5 + StrafingModifier) * FRand())
		|| (0.4*RelativeDir + 0.8 < FRand()) )
		return FaceMoveTarget();

	return Enemy;
}

function bool NeedWeapon()
{
	local UTWeapon W;

	if ( Vehicle(Pawn) != None )
		return false;
	if ( Pawn.Weapon.AIRating > 0.5 )
		return ( !Pawn.Weapon.HasAmmo(0) );

	// see if have some other good weapon, currently not in use
	ForEach Pawn.InvManager.InventoryActors(class'UTWeapon',W)
		if ( (W.AIRating > 0.5) && W.HasAmmo(0) )
			return false;

	return true;
}

event float RatePickup(Actor PickupHolder, class<Inventory> InvClass)
{
	if (PickupHolder.IsA('UTWeaponLocker'))
	{
		return UTWeaponLocker(PickupHolder).BotDesireability(bCheckDriverPickups ? Vehicle(Pawn).Driver : Pawn, self);
	}
	return InvClass.static.BotDesireability(PickupHolder, bCheckDriverPickups ? Vehicle(Pawn).Driver : Pawn, self);
}

/*
 * Called from native FindBestSuperPickup() to determine how desireable a specific super pickup 
 * is to this bot.
 */
event float SuperDesireability(PickupFactory P)
{
	if ( !SuperPickupNotSpokenFor(UTPickupFactory(P)) )
		return 0;
	return P.InventoryType.static.BotDesireability(P, bCheckDriverPickups ? Vehicle(Pawn).Driver : Pawn, self);
}

function bool SuperPickupNotSpokenFor(UTPickupFactory P)
{
	local UTBot CurrentOwner;

	if ( P == None )
		return false;

	if ( PlayerReplicationInfo.Team == None )
		return true;

	CurrentOwner = UTBot(P.TeamOwner[PlayerReplicationInfo.Team.TeamIndex]);

	if ( (CurrentOwner == None ) || (CurrentOwner == self)
		|| (CurrentOwner.Pawn == None)
		|| ((CurrentOwner.RouteGoal != P) && (CurrentOwner.MoveTarget != P)) )
	{
		P.TeamOwner[PlayerReplicationInfo.Team.TeamIndex] = None;
		return true;
	}

	// decide if better than current owner
	if ( (UTSquadAI(Squad).GetOrders() == 'Defend')
		|| (CurrentOwner.MoveTarget == P) )
		return false;
	if ( UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag )
		return true;
	if ( CurrentOwner.RouteCache.length > 1 && CurrentOwner.RouteCache[1] == P )
		return false;
	if ( UTSquadAI(CurrentOwner.Squad).GetOrders() == 'Defend' )
		return true;
	return false;
}

function DamageAttitudeTo(Controller Other, float Damage)
{
	if ( (Pawn.health > 0) && (Damage > 0) && (Other.Pawn != None) && (Squad != None) && UTSquadAI(Squad).SetEnemy(self,Other.Pawn) )
		WhatToDoNext();
}

function bool IsRetreating()
{
	return false;
}

function OnAIFreeze(UTSeqAct_AIFreeze FreezeAction)
{
	if (FreezeAction.InputLinks[0].bHasImpulse)
	{
		// freeze
		PushState(FreezeAction.bAllowWeaponFiring ? 'FrozenMovement' : 'Frozen');
	}
	else
	{
		FreezeAction.ScriptLog(self @ "received unfreeze request while not frozen");
	}
}

//**********************************************************************************
// AI States

//=======================================================================================================
// No goal/no enemy states

function bool IsDefending()
{
	return false;
}

function bool ShouldDefendPosition()
{
	if ( (DefensePoint != None) && (Enemy == None) )
	{
		MoveToDefensePoint();
		return true;
	}
	return false;
}

function MoveToDefensePoint()
{
	GotoState('Defending', 'Begin');
}

function MoveAwayFrom(Controller C)
{
	GoalString = "MOVE AWAY FROM/ "$GoalString;
	GotoState('Defending');
	ClearPathFor(C);
}

function WanderOrCamp()
{
	GotoState('Defending', 'Begin');
}

/** EnableBumps()
Timer - implemented in states where bot wants to receive bump notifications again
*/
function EnableBumps();

//@todo FIXMESTEVE - separate defending and move to defending states?
/** Defending
In the Defending state, the bot will take a position near the squad's FormationCenter().
*/
state Defending
{
	ignores EnemyNotVisible;

	function Restart( bool bVehicleTransition ) {}

	function bool IsDefending()
	{
		return true;
	}

	function EnableBumps()
	{
		enable('NotifyBump');
	}

	/**
	 * Will receive a MonitoredPawnAlert() event if the MonitoredPawn is killed or no longer possessed, 
	 * or moves too far away from either MonitorStartLoc or the bot's position 
	 */
	event MonitoredPawnAlert()
	{
		WhatToDoNext();
	}

	function ClearPathFor(Controller C)
	{
		MoveAwayFrom(C);
	}

	function MoveAwayFrom(Controller C)
	{
		local int i;
		local NavigationPoint Best, CurrentPosition;
		local float BestDot, CurrentDot;
		local vector BlockedDir;

		Pawn.bWantsToCrouch = false;

		// if already moving, don't do anything
		if ( InLatentExecution(LATENT_MOVETOWARD) )
			return;

		if ( (Pawn.Anchor != None) && Pawn.ReachedDestination(Pawn.Anchor) )
			CurrentPosition = Pawn.Anchor;
		else if ( DefensePoint != None )
			CurrentPosition = DefensePoint;
		else
			CurrentPosition = DefensivePosition;
		if ( (CurrentPosition != None) && Pawn.ReachedDestination(CurrentPosition) )
		{
			BlockedDir = Normal(C.Pawn.Acceleration);
			if ( BlockedDir == vect(0,0,0) )
				return;

			// pick a spec off of current position as perpendicular as possible to BlockedDir
			for ( i=0; i<CurrentPosition.PathList.Length; i++ )
			{
				if ( !CurrentPosition.PathList[i].IsBlockedFor(Pawn) )
				{
					CurrentDot = Abs(Normal(CurrentPosition.Pathlist[i].GetEnd().Location - Pawn.Location) dot BlockedDir);
					if ( (Best == None) || (CurrentDot < BestDot) )
					{
						Best = CurrentPosition.Pathlist[i].GetEnd();
						BestDot = CurrentDot;
					}
				}
			}
			if ( Best == None )
			{
				return;
			}
			else
			{
				MoveTarget = Best;
			}
		}
		else
		{
			RouteGoal = None;
			SetRouteGoal();
		}
		GotoState('Defending','Moving');
	}

	function SuggestDefenseRotation()
	{
		local int i;
		local vector CenterDir;
		local Actor FormationCenter;
		local NavigationPoint DefenseAnchor;

		///@todo FIXMESTEVE - improve (move to SquadAI?), based on squadmates, maybe use player facing as cue if player in center?

		if (UTHoldSpot(DefensivePosition) != None && UTHoldSpot(DefensivePosition).LastAnchor != None)
		{
			DefenseAnchor = UTHoldSpot(DefensivePosition).LastAnchor;
		}
		else
		{
			DefenseAnchor = DefensivePosition;
		}

		if (DefenseAnchor.PathList.length > 0)
		{
			Focus = None;

			FormationCenter = UTSquadAI(Squad).FormationCenter(self);
			if (FormationCenter != None)
			{
				CenterDir = Normal(FormationCenter.Location - Pawn.Location);

				// temp pick randomly from among reachspecs not facing formation center
				for ( i=0; i<DefenseAnchor.PathList.Length; i++ )
				{
					if ( DefenseAnchor.PathList[i].GetEnd() != None &&
						(CenterDir Dot Normal(DefenseAnchor.PathList[i].GetEnd().Location - Pawn.Location)) <= 0.0 )
					{
						if ( ((Rand(DefenseAnchor.PathList.Length) == 0) && (DefenseAnchor.PathList[i].Distance > 200.0)) || (Focus == None) )
						{
							Focus = DefenseAnchor.PathList[i].GetEnd();
						}
					}
				}
			}
			if ( Focus == None )
			{
				Focus = DefenseAnchor.PathList[0].GetEnd();
			}
		}
	}

	function SetRouteGoal()
	{
		local Actor NextMoveTarget;
		local bool bCanDetour;
		local UTSquadAI UTSquad;

		UTSquad = UTSquadAI(Squad);

		if (DefensePoint == None || UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag )
		{
			// if in good position, tend to stay there
			if ( (WorldInfo.TimeSeconds - FMax(LastSeenTime, AcquireTime) < 5.0 || FRand() < 0.85)
				&& DefensivePosition != None && Pawn.ReachedDestination(DefensivePosition)
				&& UTSquad.AcceptableDefensivePosition(DefensivePosition, self) )
			{
				CampTime = 3;
				GotoState('Defending','Pausing');
			}
			DefensivePosition = UTSquad.FindDefensivePositionFor(self);
			if ( DefensivePosition == None )
			{
				RouteGoal = UTSquad.FormationCenter(self);
			}
			else
			{
				RouteGoal = DefensivePosition;
			}
		}
		else
			RouteGoal = DefensePoint;
		if ( RouteGoal != None )
		{
			bCanDetour = (Vehicle(Pawn) == None) || (UTVehicle_Hoverboard(Pawn) != None);
			if ( ActorReachable(RouteGoal) )
				NextMovetarget = RouteGoal;
			else
				NextMoveTarget = FindPathToward(RouteGoal, bCanDetour);
			if ( NextMoveTarget == None )
			{
				if ( (DefensePoint != None) && (UTHoldSpot(DefensePoint) == None) )
					FreePoint();
				DefensivePosition = UTSquad.FindDefensivePositionFor(self);
				if ( DefensivePosition == None )
				{
					RouteGoal = UTSquad.FormationCenter(self);
				}
				else
				{
					RouteGoal = DefensivePosition;
				}
				NextMoveTarget = FindPathToward(RouteGoal, bCanDetour);
			}
		}
		if ( NextMoveTarget == None )
		{
			CampTime = 3;
			GotoState('Defending','Pausing');
		}
		Focus = NextMoveTarget;
		MoveTarget = NextMoveTarget;
	}

	function EndState(Name NextStateName)
	{
		MonitoredPawn = None;
		SetCombatTimer();
		bShortCamp = false;
	}

	function BeginState(Name PreviousStateName)
	{
		local UTSquadAI UTSquad;

		UTSquad = UTSquadAI(Squad);
		Pawn.bWantsToCrouch = false;
		if ( (Vehicle(Pawn) != None) && (Pawn.GetVehicleBase() != None) )
		{
			if ( Pawn.GetVehicleBase().Controller != None )
			{
			StartMonitoring(Pawn.GetVehicleBase(),UTSquad.FormationSize);
			}
		}
		else if ( (UTSquad.SquadLeader != self) && (UTSquad.SquadLeader.Pawn != None) && (UTSquad.FormationCenter(self) == UTSquad.SquadLeader.Pawn) )
			StartMonitoring(UTSquad.SquadLeader.Pawn,UTSquad.FormationSize);
		else
			MonitoredPawn = None;
	}

Begin:
	WaitForLanding();
	CampTime = bShortCamp ? 0.3 : 3.0;
	bShortCamp = false;
	if ( Pawn.bStationary )
	{
		Goto('Pausing');
	}
	SetRouteGoal();
	if ( Pawn.ReachedDestination(RouteGoal) )
	{
		Goto('Pausing');
	}
	else
	{
Moving:
		Pawn.bWantsToCrouch = false;
		MoveToward(MoveTarget);
		if (Pawn.ReachedDestination(RouteGoal))
		{
			ShouldDefendPosition(); // will change state/label if true
		}
	}
	LatentWhatToDoNext();

Pausing:
	if (UTVehicle(Pawn) != None && UTVehicle(Pawn).bShouldLeaveForCombat)
	{
		UTVehicle(Pawn).DriverLeave(false);
	}

	StopMovement();
	Pawn.bWantsToCrouch = IsSniping() && !WorldInfo.bUseConsoleInput;
	if ( DefensePoint != None )
	{
		if ( Pawn.ReachedDestination(DefensePoint) )
		{
			Focus = None;
			SetFocalPoint( Pawn.Location + vector(DefensePoint.Rotation) * 1000.0 );
		}
	}
	else if ( (DefensivePosition != None) && Pawn.ReachedDestination(DefensivePosition) )
	{
		SuggestDefenseRotation();
	}
	SwitchToBestWeapon();
	Sleep(0.5);
	if (UTWeapon(Pawn.Weapon) != None && UTWeapon(Pawn.Weapon).ShouldFireWithoutTarget())
		Pawn.BotFire(false);
	Sleep(FMax(0.1,CampTime - 0.5));
	LatentWhatToDoNext();
}

function Celebrate()
{
	if (UTPawn(Pawn) != None)
	{
		UTPawn(Pawn).PlayVictoryAnimation();
	}
}

function ForceGiveWeapon()
{
    local Vector TossVel, LeaderVel;
	local Pawn LeaderPawn;

	LeaderPawn = UTSquadAI(Squad).SquadLeader.Pawn;
	if ( (Pawn == None) || (Pawn.Weapon == None) || (LeaderPawn == None) || !LineOfSightTo(LeaderPawn) )
	return;

    if ( Pawn.CanThrowWeapon() )
    {
		TossVel = Vector(Pawn.Rotation);
		TossVel.Z = 0;
		TossVel = Normal(TossVel);
		LeaderVel = Normal(LeaderPawn.Location - Pawn.Location);
		if ( (TossVel Dot LeaderVel) > 0.7 )
				TossVel = LeaderVel;
		TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
		Pawn.TossInventory(Pawn.Weapon, TossVel);
		SwitchToBestWeapon();
    }
}

//=======================================================================================================
// Move To Goal states

state Startled
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function Startle(Actor Feared)
	{
		GoalString = "STARTLED!";
		StartleActor = Feared;
		BeginState(GetStateName());
	}

	function BeginState(Name PreviousStateName)
	{
		// FIXME - need FindPathAwayFrom()
		Pawn.Acceleration = Pawn.Location - StartleActor.Location;
		Pawn.Acceleration.Z = 0;
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = false;
		if ( Pawn.Acceleration == vect(0,0,0) )
			Pawn.Acceleration = VRand();
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);
	}
Begin:
	Sleep(0.5);
	LatentWhatToDoNext();
	Goto('Begin');
}

state MoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P)
	{
		local UTBot PBot;
		local UTSquadAI PSquad;

		PBot = UTBot(P.Controller);
		if ( (MoveTarget == None) || (PBot == None) || !WorldInfo.GRI.OnSameTeam(self,P.Controller) )
			return false;

		PSquad = UTSquadAI(PBot.Squad);
		return ( (PSquad != None) && PSquad.ClearPathFor(self) );
	}

	function Timer()
	{
		SetCombatTimer();
	}

	function EnableBumps()
	{
		enable('NotifyBump');
	}

	function BeginState(Name PreviousStateName)
	{
		Pawn.bWantsToCrouch = false;
	}
}

state MoveToGoalNoEnemy extends MoveToGoal
{
}

state MoveToGoalWithEnemy extends MoveToGoal
{
	function Timer()
	{
		TimedFireWeaponAtEnemy();
	}
}

function float GetDesiredOffset()
{
	local UTSquadAI UTSquad;

	UTSquad = UTSquadAI(Squad);
	if ( (UTSquad.SquadLeader == None) || (MoveTarget != UTSquad.SquadLeader.Pawn) )
		return 0;

	return UTSquad.FormationSize*0.5;
}

state Roaming extends MoveToGoal
{
	ignores EnemyNotVisible;

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

Begin:
	SwitchToBestWeapon();
	WaitForLanding();
	if ( Pawn.bCanPickupInventory && (UTPickupFactory(MoveTarget) != None) && (UTSquadAI(Squad).PriorityObjective(self) == 0) && (Vehicle(Pawn) == None)
		&& UTPickupFactory(MoveTarget).ShouldCamp(self, 5) )
	{
		CampTime = MoveTarget.LatentFloat;
		GoalString = "Short wait for inventory "$MoveTarget;
		GotoState('Defending','Pausing');
	}
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	LatentWhatToDoNext();
	GoalString = "STUCK IN ROAMING";
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

state Fallback extends MoveToGoalWithEnemy
{
	function bool FireWeaponAt(Actor A)
	{
		if ( (A == Enemy) && (Pawn.Weapon != None) && (Pawn.Weapon.AIRating < 0.5)
			&& (WorldInfo.TimeSeconds - Pawn.SpawnTime < UTDeathMatch(WorldInfo.Game).SpawnProtectionTime)
			&& (UTSquadAI(Squad).PriorityObjective(self) == 0)
			&& (PickupFactory(Routegoal) != None) )
		{
			// don't fire if still spawn protected, and no good weapon
			return false;
		}
		return Global.FireWeaponAt(A);
	}

	function bool IsRetreating()
	{
		return ( (Pawn.Acceleration Dot (Pawn.Location - Enemy.Location)) > 0 );
	}

	event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		local Pawn P;
		local UTVehicle V;

		if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
		{
			if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = UTVehicle(RouteGoal);
				if ( V != None )
				{
					V.TryToDrive(Pawn);
					if (Vehicle(Pawn) != None)
					{
						UTSquadAI(Squad).BotEnteredVehicle(self);
						WhatToDoNext();
					}
				}
				return true;
			}
		}

		// temporarily disable bump notifications to avoid getting overwhelmed by them
		Disable('NotifyBump');
		settimer(1.0, false, 'EnableBumps');

		if ( MoveTarget == Other )
		{
			if ( MoveTarget == Enemy && Pawn.HasRangedAttack() )
			{
				TimedFireWeaponAtEnemy();
				DoRangedAttackOn(Enemy);
			}
			return false;
		}

		P = Pawn(Other);
		if ( (P == None) || (P.Controller == None) )
			return false;
		if ( (RouteCache.Length > 0) && !WorldInfo.GRI.OnSameTeam(self,P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache.Length > 1) && P.ReachedDestination(MoveTarget) )
		{
			MoveTimer = VSize(RouteCache[1].Location - Pawn.Location)/(Pawn.GroundSpeed * Pawn.DesiredSpeed) + 1;
			MoveTarget = RouteCache[1];
		}
		UTSquadAI(Squad).SetEnemy(self,P);
		if ( Enemy == Other )
		{
			Focus = Enemy;
			TimedFireWeaponAtEnemy();
		}
		if ( CheckPathToGoalAround(P) )
			return false;

		AdjustAround(P);
		return false;
	}

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

	function EnemyNotVisible()
	{
		if ( UTSquadAI(Squad).FindNewEnemyFor(self,false) || (Enemy == None) )
			WhatToDoNext();
		else
		{
			enable('SeePlayer');
			disable('EnemyNotVisible');
		}
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		bEnemyAcquired = false;
		SetEnemyInfo(bNewEnemyVisible);
		if ( bNewEnemyVisible )
		{
			disable('SeePlayer');
			enable('EnemyNotVisible');
		}
	}

Begin:
	WaitForLanding();

Moving:
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
}

//=======================================================================================================================
// Tactical Combat states

/* LostContact()
return true if lost contact with enemy
*/
function bool LostContact(float MaxTime)
{
	if ( Enemy == None )
		return true;

	if ( Enemy.IsInvisible() && MaxTime > 2.0 )
		MaxTime = FMax(2,MaxTime - 2);
	if ( WorldInfo.TimeSeconds - FMax(LastSeenTime,AcquireTime) > MaxTime )
		return true;

	return false;
}

/* LoseEnemy()
get rid of old enemy, if squad lets me
*/
function bool LoseEnemy()
{
	if ( Enemy == None )
		return true;
	if ( (Enemy.Health > 0) && (Enemy.Controller != None) && (LoseEnemyCheckTime > WorldInfo.TimeSeconds - 0.2) )
		return false;
	LoseEnemyCheckTime = WorldInfo.TimeSeconds;
	if ( UTSquadAI(Squad).LostEnemy(self) )
	{
		bFrustrated = false;
		return true;
	}
	// still have same enemy
	return false;
}

function DoStakeOut()
{
	GotoState('StakeOut');
}

function DoCharge()
{
	if ( Vehicle(Pawn) != None )
	{
		GotoState('VehicleCharging');
		return;
	}
	if ( Enemy.PhysicsVolume.bWaterVolume )
	{
		if ( !Pawn.bCanSwim )
		{
			DoTacticalMove();
			return;
		}
	}
	else if ( !Pawn.bCanFly && !Pawn.bCanWalk )
	{
		DoTacticalMove();
		return;
	}
	GotoState('Charging');
}

function DoTacticalMove()
{
	if ( !Pawn.bCanStrafe )
	{
		if (Pawn.HasRangedAttack())
			DoRangedAttackOn(Enemy);
		else
			WanderOrCamp();
	}
	else
		GotoState('TacticalMove');
}

function DoRetreat()
{
	if ( UTSquadAI(Squad).PickRetreatDestination(self) )
	{
		GotoState('Retreating');
		return;
	}

	// if nothing, then tactical move
	if ( LineOfSightTo(Enemy) )
	{
		GoalString= "No retreat because frustrated";
		bFrustrated = true;
		if ( Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon )
			GotoState('Charging');
		else if ( Vehicle(Pawn) != None )
			GotoState('VehicleCharging');
		else
			DoTacticalMove();
		return;
	}
	GoalString = "Stakeout because no retreat dest";
	DoStakeOut();
}

/* DefendMelee()
return true if defending against melee attack
*/
function bool DefendMelee(float Dist)
{
	return ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (Dist < 1000) );
}

state Retreating extends Fallback
{
	function bool IsRetreating()
	{
		return true;
	}

	function Actor FaceActor(float StrafingModifier)
	{
		return Global.FaceActor((Skill + StrafingAbility >= 5.0) ? FMin(WorldInfo.TimeSeconds - RetreatStartTime, 2.0) : 2.0);
	}

	function BeginState(Name PreviousStateName)
	{
		Pawn.bWantsToCrouch = false;
		RetreatStartTime = WorldInfo.TimeSeconds;
	}
}

state Charging extends MoveToGoalWithEnemy
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall(bool bFloor, vector FloorNormal)
	{
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{
		if ( !Pawn.bCanStrafe )
			return false;
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy )
			return TryStrafe(duckDir);
		return false;
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;

		if ( Enemy == None || FRand() * Damage < 0.15 * CombatStyle * Pawn.Health )
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
		if ( (Pawn.Velocity Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;

		Extent = Pawn.GetCollisionRadius() * vect(1,1,0);
		Extent.Z = Pawn.GetCollisionHeight();
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		}
		if (HitActor != None)
			return false;

		if ( Pawn.Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir - Pawn.MaxStepHeight * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		SetDestinationPosition( Pawn.Location + 2 * MINSTRAFEDIST * sideDir );
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;

		Global.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		LastUnderFire = WorldInfo.TimeSeconds;

		bWasOnGround = (Pawn.Physics == PHYS_Walking);
		if ( Pawn.health <= 0 )
			return;
		if ( StrafeFromDamage(damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) &&
					(Pawn.Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		if ( (Other == Enemy)
			&& (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() > 0.4 + 0.1 * skill) )
		{
			DoRangedAttackOn(Enemy);
			return false;
		}
		return Global.NotifyBump(Other,HitNormal);
	}

	function Timer()
	{
		Focus = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function EnemyNotVisible()
	{
		WhatToDoNext();
	}

	function EndState(Name NextStateName)
	{
		if ( (Pawn != None) && Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		SetDestinationPosition( Enemy.Location );
		WaitForLanding();
	}
	if ( Enemy == None )
		LatentWhatToDoNext();
	if ( !FindBestPathToward(Enemy, false,true) )
		DoTacticalMove();
Moving:
	if ( Pawn.Weapon.bMeleeWeapon ) // FIXME HACK
		FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

state VehicleCharging extends MoveToGoalWithEnemy
{
	ignores SeePlayer, HearNoise;

	function Timer()
	{
		Focus = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function FindDestination()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Cross;

		if ( MoveTarget == None )
		{
			SetDestinationPosition( Pawn.Location );
			return;
		}
		SetDestinationPosition( Pawn.Location + 5000 * Normal(Pawn.Location - MoveTarget.Location) );
		HitActor = Trace(HitLocation, HitNormal, GetDestinationPosition(), Pawn.Location, false);

		if ( HitActor == None )
			return;

		Cross = Normal((GetDestinationPosition() - Pawn.Location) cross vect(0,0,1));
		SetDestinationPosition( GetDestinationPosition() + 1000 * Cross );
		HitActor = Trace(HitLocation, HitNormal, GetDestinationPosition(), Pawn.Location, false);
		if ( HitActor == None )
			return;

		SetDestinationPosition( GetDestinationPosition() - 2000 * Cross );
		HitActor = Trace(HitLocation, HitNormal, GetDestinationPosition(), Pawn.Location, false);
		if ( HitActor == None )
			return;

		SetDestinationPosition( GetDestinationPosition() + 1000 * Cross - 3000 * Normal(Pawn.Location - MoveTarget.Location) );
	}

	function EnemyNotVisible()
	{
		WhatToDoNext();
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		SetDestinationPosition( Enemy.Location );
		WaitForLanding();
	}
	if ( Enemy == None )
		LatentWhatToDoNext();
	if ( Pawn.Physics == PHYS_Flying )
	{
		if ( VSize(Enemy.Location - Pawn.Location) < 1200 )
		{
			FindDestination();
			MoveTo(GetDestinationPosition(), None,, false);
			if ( Enemy == None )
				LatentWhatToDoNext();
		}
		MoveTarget = Enemy;
	}
	else if ( !FindBestPathToward(Enemy, false,true) )
	{
		if (Pawn.HasRangedAttack())
			GotoState('RangedAttack');
		else
			WanderOrCamp();
	}
Moving:
	FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN VEHICLECHARGING!");
}

function bool IsStrafing()
{
	return false;
}

function bool EngageDirection(vector StrafeDir, bool bForced)
{
	`warn("Bot called EngageDirection in state "$GetStateName()$" pawn "$Pawn$" health "$Pawn.health);
	// scripttrace();
	return false;
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function bool IsStrafing()
	{
		return true;
	}

	function SetFall()
	{
		Pawn.Acceleration = vect(0,0,0);
		SetDestinationPosition( Pawn.Location );
		Global.SetFall();
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		local UTVehicle V;

		if ( Vehicle(Wall) != None && Vehicle(Pawn) == None )
		{
			if ( Wall == RouteGoal || (Vehicle(RouteGoal) != None && Wall == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = UTVehicle(Wall);
				if ( V != None )
				{
					V.TryToDrive(Pawn);
					if (Vehicle(Pawn) != None)
					{
						UTSquadAI(Squad).BotEnteredVehicle(self);
						WhatToDoNext();
					}
				}
				return true;
			}
			return false;
		}
		if (Pawn.Physics == PHYS_Falling)
		{
			NotifyFallingHitWall(HitNormal, Wall);
			return false;
		}
		if ( Enemy == None )
		{
			WhatToDoNext();
			return false;
		}
		if ( bChangeDir || (FRand() < 0.5)
			|| (((Enemy.Location - Pawn.Location) Dot HitNormal) < 0) )
		{
			Focus = Enemy;
			WhatToDoNext();
		}
		else
		{
			bChangeDir = true;
			SetDestinationPosition( Pawn.Location - HitNormal * FRand() * 500 );
		}
		return true;
	}

	function Timer()
	{
		Focus = Enemy;
		if ( (Enemy != None) && !bNotifyApex )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnableBumps()
	{
		enable('NotifyBump');
	}

	function EnemyNotVisible()
	{
		StopFiring();
		// if blew self up, return
		if ( (Pawn == None) || (Pawn.Health <= 0) )
			return;
		if ( aggressiveness > relativestrength(enemy) )
		{
			if ( FastTrace(Enemy.Location, LastSeeingPos) )
				GotoState('TacticalMove','RecoverEnemy');
			else
				WhatToDoNext();
		}
		Disable('EnemyNotVisible');
	}

	function ChangeStrafe()
	{
		local vector Dir, Dest;

		Dir = Vector(Pawn.Rotation);
		Dest = GetDestinationPosition();
		SetDestinationPosition( Dest +  2 * (Pawn.Location - Dest + Dir * ((Dest - Pawn.Location) Dot Dir)) );
	}

	/* PickDestination()
	Choose a destination for the tactical move, based on aggressiveness and the tactical
	situation. Make sure destination is reachable
	*/
	function PickDestination()
	{
		local vector pickdir, enemydir, enemyPart, Y, LookDir;
		local float strafeSize;
		local bool bFollowingPlayer;
		local Controller SquadLeader;

		if ( Pawn == None )
		{
			`warn(self$" Tactical move pick destination with no pawn");
			return;
		}
		bChangeDir = false;
		if ( Pawn.PhysicsVolume.bWaterVolume && !Pawn.bCanSwim && Pawn.bCanFly)
		{
			SetDestinationPosition( (Pawn.Location + 75 * (VRand() + vect(0,0,1))) + vect(0,0,100) );
			return;
		}

		enemydir = Normal(Enemy.Location - Pawn.Location);
		Y = (enemydir Cross vect(0,0,1));
		if ( Pawn.Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else
			enemydir.Z = FMax(0,enemydir.Z);

		SquadLeader = UTSquadAI(Squad).SquadLeader;
		bFollowingPlayer = ( (PlayerController(SquadLeader) != None) && (SquadLeader.Pawn != None)
							&& (VSize(Pawn.Location - SquadLeader.Pawn.Location) < 1600) );

		strafeSize = FClamp(((2 * Aggression + 1) * FRand() - 0.65),-0.7,0.7);
		if ( UTSquadAI(Squad).MustKeepEnemy(Enemy) )
			strafeSize = FMax(0.4 * FRand() - 0.2,strafeSize);

		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		if ( bFollowingPlayer )
		{
			// try not to get in front of squad leader
			LookDir = vector(SquadLeader.Rotation);
			if ( (LookDir dot (Pawn.Location + (enemypart + pickdir)*MINSTRAFEDIST - SquadLeader.Pawn.Location))
				> FMax(0,(LookDir dot (Pawn.Location + (enemypart - pickdir)*MINSTRAFEDIST - SquadLeader.Pawn.Location))) )
			{
				bStrafeDir = !bStrafeDir;
				pickdir *= -1;
			}

		}

		bStrafeDir = !bStrafeDir;

		if ( EngageDirection(enemyPart + pickdir, false) )
			return;

		if ( EngageDirection(enemyPart - pickdir,false) )
			return;

		bForcedDirection = true;
		StartTacticalTime = WorldInfo.TimeSeconds;
		EngageDirection(EnemyPart + PickDir, true);
	}

	function bool EngageDirection(vector StrafeDir, bool bForced)
	{
		local actor HitActor;
		local vector HitLocation, collspec, MinDest, HitNormal;
		local bool bWantJump;

		// successfully engage direction if can trace out and down
		MinDest = Pawn.Location + MINSTRAFEDIST * StrafeDir;
		if ( !bForced )
		{
			collSpec = Pawn.GetCollisionRadius() * vect(1,1,0);
			collSpec.Z = FMax(6, Pawn.GetCollisionHeight() - Pawn.MaxStepHeight);

			bWantJump = (Vehicle(Pawn) == None) && (Pawn.Physics == PHYS_Walking) && ((FRand() < 0.05 * Skill + 0.6 * Jumpiness) || (UTWeapon(Pawn.Weapon).SplashJump() && ProficientWithWeapon()))
				&& (Enemy.Location.Z - Enemy.GetCollisionHeight() <= Pawn.Location.Z + Pawn.MaxStepHeight - Pawn.GetCollisionHeight())
				&& !Pawn.NeedToTurn((Enemy == Focus) ? GetFocalPoint() : Enemy.Location);

			HitActor = Trace(HitLocation, HitNormal, MinDest, Pawn.Location, false, collSpec);
			if ( (HitActor != None) && !bWantJump )
				return false;

			if ( Pawn.Physics == PHYS_Walking )
			{
				collSpec.X = FMin(14, 0.5 * Pawn.GetCollisionRadius());
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (3 * Pawn.MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				if ( HitActor == None )
				{
					HitNormal = -1 * StrafeDir;
					return false;
				}
			}

			if ( bWantJump )
			{
				if ( (UTWeapon(Pawn.Weapon) != None) && UTWeapon(Pawn.Weapon).SplashJump() )
				{
					StopFiring();

					// if blew self up, return
					if ( (Pawn == None) || (Pawn.Health <= 0) )
						return false;
				}
				bNotifyApex = true;
				bTacticalDoubleJump = true;

				// try jump move
				bPlannedJump = true;
				DodgeLandZ = Pawn.Location.Z;
				bInDodgeMove = true;
				Pawn.SetPhysics(PHYS_Falling);
				Pawn.SuggestJumpVelocity(Pawn.Velocity, MinDest, Pawn.Location);
				Pawn.Velocity.Z = Pawn.JumpZ;
				Pawn.Acceleration = vect(0,0,0);
				if ( Skill + 2*Jumpiness > 3 + 3*FRand() )
					bNotifyFallingHitWall = true;
				SetDestinationPosition( MinDest );
				return true;
			}
		}
		SetDestinationPosition( MinDest + StrafeDir * (0.5 * MINSTRAFEDIST
											+ FMin(VSize(Enemy.Location - Pawn.Location), MINSTRAFEDIST * (FRand() + FRand()))) );
		return true;
	}

	event NotifyJumpApex()
	{
		if ( bTacticalDoubleJump && !bPendingDoubleJump && (FRand() < 0.4) && (Skill > 2 + 5 * FRand()) )
		{
			bTacticalDoubleJump = false;
			bNotifyApex = true;
			bPendingDoubleJump = true;
		}
		else if ( Pawn.CanAttack(Enemy) )
		{
			LastCanAttackCheckTime = WorldInfo.TimeSeconds;
			TimedFireWeaponAtEnemy();
		}
		Global.NotifyJumpApex();
	}

	function BeginState(Name PreviousStateName)
	{
		bForcedDirection = false;
		if ( Skill < 4 )
			Pawn.MaxDesiredSpeed = 0.4 + 0.08 * skill;
		MinHitWall += 0.15;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.bCanJump = false;
		bAdjustFromWalls = false;
		Pawn.bWantsToCrouch = false;
	}

	function EndState(Name NextStateName)
	{
		if ( !bPendingDoubleJump )
			bNotifyApex = false;
		bAdjustFromWalls = true;
		if ( Pawn == None )
			return;
		SetMaxDesiredSpeed();
		Pawn.bAvoidLedges = false;
		Pawn.bStopAtLedges = false;
		MinHitWall -= 0.15;
		if (Pawn.JumpZ > 0)
			Pawn.bCanJump = true;
	}

TacticalTick:
	Sleep(0.02);
Begin:
	if ( Enemy == None )
	{
		sleep(0.01);
		Goto('FinishedStrafe');
	}
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		SetDestinationPosition( Enemy.Location );
		WaitForLanding();
	}
	if ( Enemy == None )
		Goto('FinishedStrafe');
	PickDestination();

DoMove:
	if ( FocusOnLeader(false) )
		MoveTo(GetDestinationPosition(), Focus);
	else if ( !Pawn.bCanStrafe )
	{
		StopFiring();
		MoveTo(GetDestinationPosition());
	}
	else
	{
DoStrafeMove:
		MoveTo(GetDestinationPosition(), Enemy);
	}
	if ( bForcedDirection && (WorldInfo.TimeSeconds - StartTacticalTime < 0.2) )
	{
		if ( !Pawn.HasRangedAttack() || Skill > 2 + 3 * FRand() )
		{
			bMustCharge = true;
			LatentWhatToDoNext();
		}
		GoalString = "RangedAttack from failed tactical";
		DoRangedAttackOn(Enemy);
	}
	if ( (Enemy == None) || LineOfSightTo(Enemy) || !FastTrace(Enemy.Location, LastSeeingPos) || (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) )
		Goto('FinishedStrafe');

RecoverEnemy:
	GoalString = "Recover Enemy";
	HidingSpot = Pawn.Location;
	StopFiring();
	Sleep(0.1 + 0.2 * FRand());
	SetDestinationPosition( LastSeeingPos + 4 * Pawn.GetCollisionRadius() * Normal(LastSeeingPos - Pawn.Location) );
	MoveTo(GetDestinationPosition(), Enemy);

	if (FireWeaponAt(Enemy))
	{
		Pawn.Acceleration = vect(0,0,0);
		if (Pawn.Weapon != None && Pawn.Weapon.GetDamageRadius() > 0)
		{
			StopFiring();
			Sleep(0.05);
		}
		else
			Sleep(0.1 + 0.3 * FRand() + 0.06 * (7 - FMin(7,Skill)));
		if ( (FRand() + 0.3 > Aggression) )
		{
			Enable('EnemyNotVisible');
			SetDestinationPosition( HidingSpot + 4 * Pawn.GetCollisionRadius() * Normal(HidingSpot - Pawn.Location) );
			Goto('DoMove');
		}
	}
FinishedStrafe:
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN TACTICAL MOVE!");
}

function bool IsHunting()
{
	return false;
}

function bool FindViewSpot()
{
	return false;
}

state Hunting extends MoveToGoalWithEnemy
{
ignores EnemyNotVisible;

	/* MayFall() called by] engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		return true;
	}

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup') );
	}

	function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		LastUnderFire = WorldInfo.TimeSeconds;
		Global.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
			bFrustrated = true;
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = WorldInfo.TimeSeconds;
			bEnemyIsVisible = true;
			BlockedPath = None;
			Focus = Enemy;
			WhatToDoNext();
		}
		else
			Global.SeePlayer(SeenPlayer);
	}

	function Timer()
	{
		SetCombatTimer();
		StopFiring();
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up
		if ( (Enemy == None) || (Enemy.Health <= 0) || (Enemy.IsInvisible() && (WorldInfo.TimeSeconds - LastSeenTime > Skill)) )
		{
			LoseEnemy();
			WhatToDoNext();
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (LostContact(5) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0))
				&& LoseEnemy() )
			{
				WhatToDoNext();
				return;
			}
			SetDestinationPosition( Enemy.Location );
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if (BlockedPath != None || UTSquadAI(Squad).BeDevious(Enemy))
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToward(Enemy,false) != None )
				{
					for ( i=0; i<RouteCache.Length; i++ )
					{
						if ( RouteCache[i] == None )
							break;
						else if ( Enemy.Controller.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = RouteCache[i];
							break;
						}
					}
					bForceRefreshRoute = true;
				}
				else if ( CanStakeOut() )
				{
					GoalString = "Stakeout from hunt";
					GotoState('StakeOut');
					return;
				}
				else if ( LoseEnemy() )
				{
					WhatToDoNext();
					return;
				}
				else
				{
					GoalString = "Retreat from hunt";
					DoRetreat();
					return;
				}
			}
			// control path weights
			if ( BlockedPath != None )
			{
				BlockedPath.TransientCost = 5000;
			}
		}
		if (!bDirectHunt)
		{
			UTSquadAI(Squad).MarkHuntingSpots(self);
		}
		if ( FindBestPathToward(Enemy, true, true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid && LoseEnemy() )
		{
			WhatToDoNext();
			return;
		}

		SetDestinationPosition( LastSeeingPos );
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot)
			&& VSize(Pawn.Location - GetDestinationPosition()) > Pawn.CylinderComponent.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

		posZ = LastSeenPos.Z + Pawn.GetCollisionHeight() - Enemy.GetCollisionHeight();
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CylinderComponent.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			SetDestinationPosition( nextSpot );
		else if ( bCanSeeLastSeen )
		{
			Dir = Pawn.Location - LastSeenPos;
			Dir.Z = 0;
			if ( VSize(Dir) < Pawn.GetCollisionRadius() )
			{
				GoalString = "Stakeout 3 from hunt";
				GotoState('StakeOut');
				return;
			}
			SetDestinationPosition( LastSeenPos );
		}
		else
		{
			SetDestinationPosition( LastSeenPos );
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( (Pawn.Physics == PHYS_Flying) && LoseEnemy() )
				{
					WhatToDoNext();
					return;
				}
				else
				{
					GoalString = "Stakeout 2 from hunt";
					GotoState('StakeOut');
					return;
				}
			}
		}
	}

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		if ( Enemy == None )
			return false;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;

		if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CylinderComponent.CollisionRadius) )
		{
			SetDestinationPosition( Pawn.Location + 2.5 * Y * Pawn.CylinderComponent.CollisionRadius );
			return true;
		}

		if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CylinderComponent.CollisionRadius) )
		{
			SetDestinationPosition( Pawn.Location - 2.5 * Y * Pawn.CylinderComponent.CollisionRadius );
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				SetDestinationPosition( Pawn.Location - 2.5 * Y * Pawn.CylinderComponent.CollisionRadius );
			else
				SetDestinationPosition( Pawn.Location - 2.5 * Y * Pawn.CylinderComponent.CollisionRadius );
			return true;
		}

		return false;
	}

	function BeginState(Name PreviousStateName)
	{
		Pawn.bWantsToCrouch = false;
		//SetAlertness(0.5);
	}

	function EndState(Name NextStateName)
	{
		bDirectHunt = false;
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

AdjustFromWall:
	MoveTo(GetDestinationPosition(), MoveTarget);

Begin:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SeePlayer(Enemy);
	PickDestination();
SpecialNavig:
	if (MoveTarget == None)
		MoveTo(GetDestinationPosition());
	else
		MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget));

	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}

state StakeOut
{
ignores EnemyNotVisible;

	function bool CanAttack(Actor Other)
	{
		return true;
	}

	function bool WeaponFireAgain(bool bFinishedFire)
	{
		LastFireAttempt = WorldInfo.TimeSeconds;
		bFireSuccess = false;
		if (!Pawn.NeedToTurn(GetFocalPoint()))
		{
			bCanFire = true;
			bStoppedFiring = false;
			bFireSuccess = Pawn.BotFire(bFinishedFire);
			LastFireTarget = Focus;
			return bFireSuccess;
		}
		else
		{
			bCanFire = false;
			StopFiring();
			return false;
		}
	}

	function bool Stopped()
	{
		return true;
	}

	event SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = WorldInfo.TimeSeconds;
			bEnemyIsVisible = true;
			if ( !FocusOnLeader(false) && (FRand() < 0.5) )
			{
				Focus = Enemy;
				FireWeaponAt(Focus);
			}
			WhatToDoNext();
		}
		else if ( UTSquadAI(Squad).SetEnemy(self,SeenPlayer) )
		{
			if ( Enemy == SeenPlayer )
			{
				VisibleEnemy = Enemy;
				EnemyVisibilityTime = WorldInfo.TimeSeconds;
				bEnemyIsVisible = true;
			}
			WhatToDoNext();
		}
	}
	/* DoStakeOut()
	called by ChooseAttackMode - if called in this state, means stake out twice in a row
	*/
	function DoStakeOut()
	{
		FocusOnLeader(false);
		if ( (FRand() < 0.3) || !FastTrace(GetFocalPoint() + vect(0,0,0.9) * Enemy.GetCollisionHeight(), Pawn.Location + vect(0,0,0.8) * Pawn.GetCollisionHeight()) )
			FindNewStakeOutDir();
		GotoState('StakeOut','Begin');
	}

	function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		Global.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
		{
			bFrustrated = true;
			if ( (InstigatedBy != None) && (InstigatedBy.Pawn != None) && (InstigatedBy.Pawn == Enemy) )
				AcquireTime = WorldInfo.TimeSeconds;
			WhatToDoNext();
		}
	}

	function Timer()
	{
		SetCombatTimer();
	}

	function EnableBumps()
	{
		enable('NotifyBump');
	}

	/*
	GetAdjustedAimFor()
	Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
	*/
	function Rotator GetAdjustedAimFor( Weapon InWeapon, vector ProjStart )
	{
		local vector FireSpot;
		local actor HitActor;
		local vector HitLocation, HitNormal;

		FireSpot = GetFocalPoint();

		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None )
		{
			if ( Enemy != None )
				FireSpot += 2 * Enemy.GetCollisionHeight() * HitNormal;
			if ( !FastTrace(FireSpot, ProjStart) )
			{
				FireSpot = GetFocalPoint();
			}
		}

		SetRotation(Rotator(FireSpot - ProjStart));
		return Rotation;
	}

	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Pawn.Location);
		foreach WorldInfo.AllNavigationPoints(class'NavigationPoint', N)
		{
			Dir = N.Location - Pawn.Location;
			Dist = VSize(Dir);
			if ( (Dist < MAXSTAKEOUTDIST) && (Dist > MINSTRAFEDIST) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( WorldInfo.Game.bTeamgame && PlayerReplicationInfo.Team != None && PlayerReplicationInfo.Team.Size > 1 )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}
		if ( Best != None )
			SetFocalPoint( Best.Location + 0.5 * Pawn.GetCollisionHeight() * vect(0,0,1) );
	}

	function BeginState(Name PreviousStateName)
	{
		StopStartTime = WorldInfo.TimeSeconds;
		StopMovement();
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		//SetAlertness(0.5);
		FocusOnLeader(false);
		if ( !bEnemyInfoValid || VSize(GetFocalPoint() - Pawn.Location) < MINSTRAFEDIST ||
			(WorldInfo.TimeSeconds - LastSeenTime > 6.0 && FRand() < 0.5) ||
			!ClearShot(GetFocalPoint(), false) )
		{
			FindNewStakeOutDir();
		}
	}

	function EndState(Name NextStateName)
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

Begin:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	if ( FocusOnLeader(false) )
		Focus = Focus;
	CheckIfShouldCrouch(Pawn.Location,GetFocalPoint(), 1);
	FinishRotation();
	if ( FocusOnLeader(false) )
		FireWeaponAt(Focus);
	else if ( (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && UTSquadAI(Squad).ShouldSuppressEnemy(self) && ClearShot(GetFocalPoint(),true) )
	{
		WeaponFireAgain(false);
	}
	else if ( Vehicle(Pawn) != None )
	{
		WeaponFireAgain(false);
	}
	else
	{
		StopFiring();
	}
	Sleep(1 + FRand());
	// check if uncrouching would help
	if ( Pawn.bIsCrouched
		&& !FastTrace(GetFocalPoint(), Pawn.Location + Pawn.EyeHeight * vect(0,0,1))
		&& FastTrace(GetFocalPoint(), Pawn.Location + Pawn.GetCollisionHeight() * vect(0,0,1)) )
	{
		Pawn.bWantsToCrouch = false;
		Sleep(0.15 + 0.05 * (1 + FRand()) * (10 - skill));
	}
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN STAKEOUT!");
}

function bool Stopped()
{
	return bPreparingMove;
}

function bool IsShootingObjective()
{
	return false;
}

function bool FocusOnLeader(bool bLeaderFiring)
{
	return ( (UTWeapon(Pawn.Weapon) != None) && UTWeapon(Pawn.Weapon).FocusOnLeader(bLeaderFiring) );
}

/** tells our pawn to stop moving */
function StopMovement()
{
	local Vehicle V;

	if (Pawn.Physics != PHYS_Flying)
	{
		Pawn.Acceleration = vect(0,0,0);
	}
	V = Vehicle(Pawn);
	if (V != None)
	{
		V.Steering = 0;
		V.Throttle = 0;
		V.Rise = 0;
	}
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function bool Stopped()
	{
		return (bPreparingMove || !InLatentExecution(LATENT_MOVETOWARD));
	}

	function bool IsShootingObjective()
	{
		return (Focus != None && Focus == Squad.SquadObjective);
	}

	function ClearPathFor(Controller C)
	{
		DoTacticalMove();
	}

	function StopFiring()
	{
		if ( (Pawn != None) && Pawn.RecommendLongRangedAttack() && Pawn.IsFiring() )
			return;
		Global.StopFiring();
		if ( bHasFired )
		{
			if ( IsSniping() && !WorldInfo.bUseConsoleInput )
			{
				Pawn.bWantsToCrouch = (Skill > 2);
			}
			else
			{
				bHasFired = false;
				WhatToDoNext();
			}
		}
	}

	function EnemyNotVisible()
	{
		//let attack animation complete
		if ( (Focus == Enemy) && !Pawn.RecommendLongRangedAttack() )
			WhatToDoNext();
	}

	// really not sure how this function manages to get into an infinite loop in rare cases...
	singular function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
	{
		if (Focus == KilledPawn && Killed != self)
		{
			WhatToDoNext();
		}
		Global.NotifyKilled(Killer, Killed, KilledPawn,damageType);
	}

	function Timer()
	{
		if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon )
		{
			SetCombatTimer();
			StopFiring();
					// if blew self up, return
					if ( (Pawn == None) || (Pawn.Health <= 0) )
						return;
			WhatToDoNext();
		}
		else if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
		else
			FireWeaponAt(Focus);
	}

	function DoRangedAttackOn(Actor A)
	{
		if ( !FocusOnLeader(false) )
			Focus = A;
		GotoState('RangedAttack', 'Begin');
	}

	/** if the bot is skilled enough, finds another navigation point that the bot can also shoot the target from
	 * and sets MoveTarget to it
	 * @return whether a valid MoveTarget was found
	 */
	function bool FindStrafeDest()
	{
		local float Dist, TargetDist, MaxRange;
		local int Start, i;
		local bool bAllowBackwards;
		local NavigationPoint Nav;
		local UTWeapon UTWeap;

		if (!Pawn.bCanStrafe || Pawn.Weapon == None || Skill + StrafingAbility < 1.5 + 3.5 * FRand())
		{
			// can't strafe, no weapon to check distance with or not skilled enough
			return false;
		}

		UTWeap = UTWeapon(Pawn.Weapon);
		MaxRange = (UTWeap != None ? UTWeap.GetOptimalRangeFor(Focus) : Pawn.Weapon.MaxRange());
		// get on path network if not already
		if (!Pawn.ValidAnchor())
		{
			Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
			if (Pawn.Anchor == None)
			{
				// can't get on path network
				return false;
			}
			else
			{
				if (Dist > Pawn.CylinderComponent.CollisionRadius)
				{
					if ( VSize(Pawn.Anchor.Location - Focus.Location) <= MaxRange &&
						FastTrace(Focus.Location, Pawn.Anchor.Location) )
					{
						MoveTarget = Pawn.Anchor;
						return true;
					}
					else
					{
						// can't shoot target from best anchor
						return false;
					}
				}
			}
		}
		else if (Pawn.Anchor.PathList.length > 0)
		{
			TargetDist = VSize(Focus.Location - Pawn.Location);
			// consider backstep opposed to always charging if enemy objective, depending on combat style and weapon
			if (!WorldInfo.GRI.OnSameTeam(Focus, self))
			{
				bAllowBackwards = (CombatStyle + (UTWeap != None ? UTWeap.SuggestAttackStyle() : 0.0) <= 0.0);
			}
			// pick a random point linked to anchor that we can shoot target from
			Start = Rand(Pawn.Anchor.PathList.length);
			i = Start;
			do
			{
				if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
				{
					Nav = Pawn.Anchor.PathList[i].GetEnd();
					if (Nav != Focus && !Nav.bSpecialMove && !Nav.IsA('Teleporter'))
					{
						// allow points within range, that aren't significantly backtracking unless allowed,
						// and that we can still hit target from
						Dist = VSize(Nav.Location - Focus.Location);
						if ( (Dist <= MaxRange || Dist < TargetDist) && (bAllowBackwards || Dist <= TargetDist + 100.0) &&
							FastTrace(Focus.Location, Nav.Location) )
						{
							MoveTarget = Nav;
							return true;
						}
					}
				}
				i++;
				if (i == Pawn.Anchor.PathList.length)
				{
					i = 0;
				}
			} until (i == Start);
		}

		return false;
	}

	function BeginState(Name PreviousStateName)
	{
		StopStartTime = WorldInfo.TimeSeconds;
		bHasFired = false;
		StopMovement();
		if ( !FocusOnLeader(false) && (Focus == None) )
			Focus = Enemy;
		if ( Focus == None )
			`log(GetHumanReadableName()$" no target in ranged attack");
	}

Begin:
	bHasFired = false;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon )
		SwitchToBestWeapon();
	GoalString = GoalString@"Ranged attack";
	Sleep(0.0);
	if ( (Focus == None) || Focus.bDeleteMe )
		LatentWhatToDoNext();
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( Pawn.NeedToTurn(GetFocalPoint()) )
	{
		FinishRotation();
	}
	bHasFired = true;
	if ( Focus == Enemy )
		TimedFireWeaponAtEnemy();
	else
		FireWeaponAt(Focus);
	Sleep(0.1);
	if ( ((Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon) || (Focus == None) || ((Focus != Enemy) && (UTGameObjective(Focus) == None) && (Enemy != None) && LineOfSightTo(Enemy)) )
		LatentWhatToDoNext();
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if (FindStrafeDest())
	{
		GoalString = GoalString $ ", strafe to" @ MoveTarget;
		MoveToward(MoveTarget, Focus,, true, false);
		StopMovement();
	}
	else
	{
		Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	}
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange, NotifyHitWall, NotifyBump, ExecuteWhatToDoNext;

	event DelayedWarning() {}

	function DoRangedAttackOn(Actor A)
	{
	}

	function WhatToDoNext()
	{
		//`log(self @ "WhatToDoNext while dead);
		//ScriptTrace();
	}

	function Celebrate()
	{
		`log(self$" Celebrate while dead");
	}

	function bool SetRouteToGoal(Actor A)
	{
		`log(self$" SetRouteToGoal while dead");
		return true;
	}

	function SetAttractionState()
	{
		`log(self$" SetAttractionState while dead");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		`log(self$" EnemyChanged while dead");
	}

	function WanderOrCamp()
	{
		`log(self$" WanderOrCamp while dead");
	}

	function Timer() {}

	function BeginState(Name PreviousStateName)
	{
		if (bSpawnedByKismet || UTGame(WorldInfo.Game).TooManyBots(self))
		{
			Destroy();
			return;
		}
		if ( (DefensePoint != None) && (UTHoldSpot(DefensePoint) == None) )
			FreePoint();
		if ( NavigationPoint(MoveTarget) != None )
		{
			NavigationPoint(MoveTarget).FearCost = 2 * NavigationPoint(MoveTarget).FearCost + 600;
			WorldInfo.Game.bDoFearCostFallOff = true;
		}
		NextRoutePath = None;
		MonitoredPawn = None;
		WarningProjectile = None;
		PendingMover = None;
		Enemy = None;
		StopFiring();
		bFrustrated = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		bPlannedJump = false;
		bInDodgeMove = false;
		bReachedGatherPoint = false;
		bFinalStretch = false;
		bWasNearObjective = false;
		bPreparingMove = false;
		bPursuingFlag = false;
		bHasSuperWeapon = false;
		ImpactJumpZ = 0.f;
		RouteGoal = None;
		NoVehicleGoal = None;
		SquadRouteGoal = None;
		bUsingSquadRoute = true;
		bUsePreviousSquadRoute = false;
		MoveTarget = None;
		ImpactVelocity = vect(0,0,0);
		LastSeenTime = -1000;
		bEnemyInfoValid = false;
		bHuntPlayer = false;
		bEnemyAcquired	= false;
		bJumpOverWall	= false;
		StartleActor = None;
		DefensePoint = None;
	}

Begin:
	if ( WorldInfo.Game.bGameEnded )
		GotoState('RoundEnded');
	Sleep(0.2);
TryAgain:
	if ( UTGame(WorldInfo.Game) == None )
		destroy();
	else
	{
		Sleep(0.75 + UTGame(WorldInfo.Game).SpawnWait(self));
		LastRespawnTime = WorldInfo.TimeSeconds;
		WorldInfo.Game.ReStartPlayer(self);
		Goto('TryAgain');
	}

MPStart:
	Sleep(0.75 + FRand());
	WorldInfo.Game.ReStartPlayer(self);
	Goto('TryAgain');
}

state FindAir
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyHeadVolumeChange(PhysicsVolume NewHeadVolume)
	{
		Global.NotifyHeadVolumeChange(newHeadVolume);
		if ( !newHeadVolume.bWaterVolume )
			WhatToDoNext();
		return false;
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		//change directions
		SetDestinationPosition( MINSTRAFEDIST * (Normal(GetDestinationPosition() - Pawn.Location) + HitNormal) );
		return true;
	}

	function Timer()
	{
		if ( (Enemy != None) && LineOfSightTo(Enemy) )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnemyNotVisible() {}

/* PickDestination()
*/
	function PickDestination(bool bNoCharge)
	{
		local Vector Dest;
		Dest = VRand();
		Dest.Z = 1;
		SetDestinationPosition( Pawn.Location + MINSTRAFEDIST * Dest );
	}

	function BeginState(Name PreviousStateName)
	{
		Pawn.bWantsToCrouch = false;
		bAdjustFromWalls = false;
	}

	function EndState(Name NextStateName)
	{
		bAdjustFromWalls = true;
	}

Begin:
	PickDestination(false);

DoMove:
	if ( Enemy == None )
		MoveTo(GetDestinationPosition());
	else
		MoveTo(GetDestinationPosition(), Enemy);
	LatentWhatToDoNext();
}

state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange,
	Falling, TakeDamage, ReceiveWarning, ExecuteWhatToDoNext;

	event DelayedWarning() {}

	function SwitchToBestWeapon(optional bool bForceNewWeapon) {}

	function WhatToDoNext()
	{
		`Log(self @ "WhatToDoNext while RoundEnded");
		// ScriptTrace();
	}

	function Celebrate()
	{
		`log(self$" Celebrate while RoundEnded");
	}

	function SetAttractionState()
	{
		`log(self$" SetAttractionState while RoundEnded");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		`log(self$" EnemyChanged while RoundEnded");
	}

	function WanderOrCamp()
	{
		`log(self$" WanderOrCamp while RoundEnded");
	}

	function CelebrateVictory()
	{
		if ( UTGame(WorldInfo.Game) != None )
		{
			if ( (UTGame(WorldInfo.Game).EndGameFocus == Pawn) && (Pawn != None) )
			{
				UTPawn(Pawn).PlayVictoryAnimation();
			}
		}
	}

	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if ( (UTGame(WorldInfo.Game) != None) && (UTGame(WorldInfo.Game).EndGameFocus == Pawn) && (Pawn != None) )
		{
			SetTimer(3.0, false, 'CelebrateVictory');
		}
	}
}

State WaitingForLanding
{
	function bool DoWaitForLanding()
	{
		if ( bJustLanded )
			return false;
		BeginState(GetStateName());
		return true;
	}

	event bool NotifyLanded(vector HitNormal, Actor FloorActor)
	{
		bJustLanded = true;
		Global.NotifyLanded(HitNormal, FloorActor);
		return false;
	}

	function Timer()
	{
		if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function BeginState(Name PreviousStateName)
	{
		bJustLanded = false;
		if ( (MoveTarget != None) && ((Enemy == None) ||(Focus != Enemy)) )
			FaceActor(1.5);
		if ( (Enemy == None) || (Focus != Enemy) )
			StopFiring();
	}

Begin:
	if ( (Pawn.PhysicsVolume.bWaterVolume) || (Pawn.Physics == PHYS_Swimming) )
		LatentWhatToDoNext();
	if ( Pawn.GetGravityZ() > 0.9 * WorldInfo.DefaultGravityZ )
	{
     	if ( (MoveTarget == None) || (MoveTarget.Location.Z > Pawn.Location.Z) )
	    {
		    NotifyMissedJump();
		    if ( MoveTarget != None )
			    MoveToward(MoveTarget,Focus,,true);
	    }
	    else if ( Pawn.Physics != PHYS_Falling )
	    	LatentWhatToDoNext();
	    else
	    {
		    Sleep(0.5);
		    Goto('Begin');
	    }
	}
	WaitForLanding();
	LatentWhatToDoNext();
	Sleep(0.5);
    Goto('Begin');
}

/** used when bot wants to enter a vehicle */
state EnteringVehicle
{
Begin:
	if (Vehicle(RouteGoal) != None && Vehicle(Pawn) == None && Vehicle(RouteGoal).Health > 0 && !RouteGoal.bDeleteMe)
	{
		if (Vehicle(RouteGoal).TryToDrive(Pawn))
		{
			UTSquadAI(Squad).BotEnteredVehicle(self);
		}
		else if (UTVehicle(RouteGoal) != None && UTVehicle(RouteGoal).bPlayingSpawnEffect)
		{
			GoalString = "Waiting for" @ RouteGoal @ "to finish spawning in";
			Sleep(0.25);
			Goto('Begin');
		}
		else if (ActorReachable(RouteGoal))
		{
			// if failed but reachable, try to get closer
			GoalString = "Getting closer to enter vehicle" @ RouteGoal;
			MoveTarget = RouteGoal;
			MoveToward(RouteGoal, FaceActor(1),, ShouldStrafeTo(RouteGoal));
			if (Vehicle(Pawn) == None && Vehicle(RouteGoal).TryToDrive(Pawn))
			{
				UTSquadAI(Squad).BotEnteredVehicle(self);
			}
		}
	}
	LatentWhatToDoNext();
	if (bSoaking)
	{
		SoakStop("STUCK IN ENTERINGVEHICLE");
	}
}

/** used when bot is trying to leave its current vehicle */
state LeavingVehicle
{
	/** tries to exit the current vehicle
	 * @return true if the bot is no longer in a vehicle, false otherwise
	 */
	function TryLeavingVehicle()
	{
		local Vehicle V;
		local UTAirVehicle AirVehicle;

		V = Vehicle(Pawn);
		if (V != None)
		{
			if (IsZero(DirectionHint) && RouteGoal != None)
			{
				DirectionHint = Normal(RouteGoal.Location - V.Location);
			}
			V.DriverLeave(false);
			if (Vehicle(Pawn) == None)
			{
				// push air vehicles away from objective a bit so they don't land directly on top of it
				AirVehicle = UTAirVehicle(V);
				if (AirVehicle != None)
				{
					AirVehicle.Mesh.AddImpulse(AirVehicle.PushForce * vector(AirVehicle.Rotation), AirVehicle.Location);
				}
				if (Pawn.Physics == PHYS_Falling && DoWaitForLanding())
				{
					Pawn.Velocity.Z = 0;
				}
			}
		}
	}

Begin:
	TryLeavingVehicle();
	if (Vehicle(Pawn) != None)
	{
		// failed to leave vehicle
		// possibly no room, so try moving around
		GoalString = "Failed to exit vehicle - try moving to more open area";
		FindRandomDest();
		if (RouteCache.length > 0)
		{
			MoveToward(RouteCache[0]);
		}
	}

	LatentWhatToDoNext();
	if (bSoaking)
	{
		SoakStop("STUCK IN LEAVINGVEHICLE");
	}
}

/** function called during CustomAction state
 * @param B the bot performing the action
 * @return whether the action is complete
 */
delegate bool CustomActionFunc(UTBot B)
{
	return true;
}

/** performs a custom action, calling the specified delegate each tick until it returns true, then triggers a new decision via WhatToDoNext() */
function PerformCustomAction(delegate<CustomActionFunc> ActionFunc)
{
	CustomActionFunc = ActionFunc;
	GotoState('CustomAction');
}

/** state that calls a set delegate until it says its done, then triggers WhatToDoNext() */
state CustomAction
{
	event EndState(name NextStateName)
	{
		CustomActionFunc = None;
	}

Begin:
	while (!CustomActionFunc(self))
	{
		Sleep(0.0);
	}

	LatentWhatToDoNext();
	if (bSoaking)
	{
		SoakStop("STUCK IN CUSTOMACTION");
	}
}

// UnderLift()
//called by mover when it hits a pawn with that mover as its pendingmover while moving to its destination
function UnderLift(LiftCenter M)
{
	local LiftExit Exit;

	bPreparingMove = false;
	PendingMover = None;

	// find nearest lift exit and go for that
	if ( (MoveTarget == None) || MoveTarget.IsA('LiftCenter') )
	{
		foreach WorldInfo.AllNavigationPoints(class'LiftExit', Exit)
		{
			if (Exit.MyLiftCenter == M && ActorReachable(Exit))
			{
				MoveTarget = Exit;
				return;
			}
		}
	}
}

event bool HandlePathObstruction(Actor BlockedBy)
{
	local UTVehicle V, MyVehicle;
	local Pawn P;
	local Weapon Weap;

	MyVehicle = UTVehicle(Pawn);
	if ( MyVehicle != None )
	{
		if ( MyVehicle.bShouldLeaveForCombat )
	{
		MyVehicle.DriverLeave(false);
	}
		else if ( MyVehicle.bKeyVehicle && (Vehicle(BlockedBy) != None) )
		{
			// Key vehicles ignore blocking vehicles (driver over/into them)
			return true;
		}
	}

	// if it's a vehicle, try to get in it
	if (!Pawn.IsA('Vehicle'))
	{
		V = UTVehicle(BlockedBy);
		if (V != None && Squad != None && UTSquadAI(Squad).VehicleDesireability(V, self) > 0.0)
		{
			GoalString = V @ "is blocking path to" @ MoveTarget @ "- enter it";
			if (Focus == MoveTarget)
			{
				Focus = V;
			}
			MoveTarget = V;
			RouteGoal = V;
			if (VSize(Pawn.Location - V.Location) < Pawn.GetCollisionRadius() + V.GetCollisionRadius() + Pawn.VehicleCheckRadius)
			{
				EnterVehicle(V);
			}
			return true;
		}
	}
	// if it's an enemy pawn, try to shoot it
	P = Pawn(BlockedBy);
	if (P != None && !WorldInfo.GRI.OnSameTeam(self, P))
	{
		GoalString = P @ "is blocking path to" @ MoveTarget @ " - kill it";
		Focus = P;
		Enemy = P;
		MoveTarget = P;
		SwitchToBestWeapon();
		Weap = (Pawn.InvManager != None && Pawn.InvManager.PendingWeapon != None) ? Pawn.InvManager.PendingWeapon : Pawn.Weapon;
		if (Weap != None && Weap.CanAttack(P))
		{
			LastCanAttackCheckTime = WorldInfo.TimeSeconds;
			FireWeaponAt(P);
			MoveTimer = 1.0;
			return true;
		}
	}

	// ask Squad
	return (Squad != None) ? UTSquadAI(Squad).HandlePathObstruction(self, BlockedBy) : false;
}

state InQueue extends RoundEnded
{
	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		PlayerReplicationInfo.bIsSpectator = true;
	}

	function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		PlayerReplicationInfo.bIsSpectator = false;
	}
}

state ScriptedMove
{
	ignores WhatToDoNext, SeePlayer, SeeMonster, HearNoise, ExecuteWhatToDoNext;

	event bool NotifyHitWall(vector HitNormal, Actor Wall)
	{
		// if we're moving to a UTVehicleFactory, we hit the vehicle it spawned and that vehicle is still on top of the factory,
		// then consider the factory as reached
		if ( Vehicle(Wall) != None && ScriptedMoveTarget.IsA('UTVehicleFactory') &&
			Wall == UTVehicleFactory(ScriptedMoveTarget).ChildVehicle && Wall.ContainsPoint(ScriptedMoveTarget.Location) )
		{
			PopState();
			return false;
		}
		else
		{
			return Global.NotifyHitWall(HitNormal, Wall);
		}
	}

	event PushedState()
	{
		Super(ScriptedMove).PushedState();
		// make sure pawn isn't crouched
		Pawn.UnCrouch();
	}

	event PoppedState()
	{
		Super(ScriptedMove).PoppedState();
		if (Pawn != None)
		{
			StopMovement();
		}
	}
}

/** state where bot ignores all stimulus and just stands there (mainly for Kismet scripts) */
state Frozen
{
	ignores WhatToDoNext, SeeMonster, HearNoise, ExecuteWhatToDoNext;

	event SeePlayer(Pawn SeenPlayer)
	{
		// check for any Kismet scripts that might care
		if (Pawn != None)
		{
			Pawn.TriggerEventClass(class'SeqEvent_AISeeEnemy', SeenPlayer);
		}
	}

	function OnAIFreeze(UTSeqAct_AIFreeze FreezeAction)
	{
		if (FreezeAction.InputLinks[1].bHasImpulse)
		{
			// unfreeze
			PopState();
		}
		else
		{
			FreezeAction.ScriptLog(self @ "received freeze request while already frozen");
		}
	}

	event PushedState()
	{
		StopMovement();
		bScriptedFrozen = true;
		StopFiring();
		Focus = None;
	}

	event PoppedState()
	{
		bScriptedFrozen = false;
	}
}

/** state that disables the bot's movement and objective selection, but allows them to target and fire upon any enemies in the area */
state FrozenMovement
{
	ignores ExecuteWhatToDoNext;

	function WhatToDoNext()
	{
		if (Enemy != None)
		{
			Focus = Enemy;
			TimedFireWeaponAtEnemy();
		}
		else
		{
			Enemy = None;
			StopFiring();
		}
	}

	function Timer()
	{
		if (Enemy != None)
		{
			TimedFireWeaponAtEnemy();
		}
	}

	function OnAIFreeze(UTSeqAct_AIFreeze FreezeAction)
	{
		if (FreezeAction.InputLinks[1].bHasImpulse)
		{
			// unfreeze
			PopState();
		}
		else
		{
			FreezeAction.ScriptLog(self @ "received freeze request while already frozen");
		}
	}

	event PushedState()
	{
		// make sure we have a squad (needed to recognize enemies)
		//@fixme FIXME: doesn't work for FFA gametypes
		if (Squad == None && PlayerReplicationInfo != None && UTTeamInfo(PlayerReplicationInfo.Team) != None)
		{
			UTTeamInfo(PlayerReplicationInfo.Team).SetBotOrders(self);
		}

		StopMovement();
		bScriptedFrozen = true;
	}

	event PoppedState()
	{
		bScriptedFrozen = false;
	}
}

defaultproperties
{
	LastTauntIndex=-1
	OldMessageTime=-100.0
	LastAttractCheck=-10000.0
	LastSearchTime=-10000.0
	bCanDoSpecial=true
	bIsPlayer=true
	Aggressiveness=+00000.40000
	BaseAggressiveness=+00000.40000
	CombatStyle=+00000.20000

	OrderNames(0)=Defend
	OrderNames(1)=Hold
	OrderNames(2)=Attack
	OrderNames(3)=Follow
	OrderNames(4)=FreeLance
	OrderNames(10)=Attack
	OrderNames(11)=Defend
	OrderNames(12)=Defend
	OrderNames(13)=Attack
	OrderNames(14)=Attack

	ScriptedFireMode=255

}
