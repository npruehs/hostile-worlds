/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponLocker extends UTPickupFactory
	abstract;

struct native WeaponEntry
{
	var() class<UTWeapon> WeaponClass;
	var PrimitiveComponent PickupMesh;
};
var() array<WeaponEntry> Weapons;

/** when received on the client, replaces Weapons array classes with this array instead */
struct native ReplacementWeaponEntry
{
	/** indicates whether this entry in the Weapons array was actually replaced
	 * (so we can distinguish between WeaponClass == None because it wasn't touched vs. because it was removed
	 */
	var bool bReplaced;
	/** the class of weapon to replace with */
	var class<UTWeapon> WeaponClass;
};
var repnotify ReplacementWeaponEntry ReplacementWeapons[6];

/** offsets from locker location where we can place weapon meshes */
var array<vector> LockerPositions;

var localized string LockerString;

struct native PawnToucher
{
	var Pawn P;
	var float NextTouchTime;
};
var array<PawnToucher> Customers;

/** clientside flag - whether the locker should be displayed as active and having weapons available */
var bool bIsActive;

/** clientside flag - whether or not a local player is near this locker */
var bool bPlayerNearby;

/** whether weapons are currently scaling up */
var bool bScalingUp;

/** current scaling up weapon scale */
var float CurrentWeaponScaleX;

/** how close a player needs to be to be considered nearby */
var float ProximityDistanceSquared;

/** component for the active/inactive effect, depending on state */
var ParticleSystemComponent AmbientEffect;
/** effect that's visible when active and the player gets nearby */
var ParticleSystemComponent ProximityEffect;
/** effect for when the weapon locker cannot be used by the player right now */
var ParticleSystem InactiveEffectTemplate;
/** effect for when the weapon locker is usable by the player right now */
var ParticleSystem ActiveEffectTemplate;
/** effect played over weapons being scaled in when the player is nearby */
var ParticleSystem WeaponSpawnEffectTemplate;

/** the rate to scale the weapons's Scale3D.X when spawning them in (set to 0.0 to disable the scaling) */
var float ScaleRate;

/** Next proximity check time */
var float NextProximityCheckTime;

replication
{
	if (bNetInitial)
		ReplacementWeapons;
}

// Called after PostBeginPlay.
simulated event SetInitialState()
{
	if ( bIsDisabled )
	{
		GotoState('Disabled');
	}
	else
	{
		Super(Actor).SetInitialState();
	}
}

/* ShouldCamp()
Returns true if Bot should wait for me
*/
function bool ShouldCamp(UTBot B, float MaxWait)
{
	return false;
}

function bool AddCustomer(Pawn P)
{
	local int			i;
	local PawnToucher	PT;

	if ( UTInventoryManager(P.InvManager) == None )
		return false;

	if ( Customers.Length > 0 )
		for ( i=0; i<Customers.Length; i++ )
		{
			if ( Customers[i].NextTouchTime < WorldInfo.TimeSeconds )
			{
				if ( Customers[i].P == P )
				{
					Customers[i].NextTouchTime = WorldInfo.TimeSeconds + 30;
					return true;
				}
				Customers.Remove(i,1);
				i--;
			}
			else if ( Customers[i].P == P )
				return false;
		}

	PT.P = P;
	PT.NextTouchTime = WorldInfo.TimeSeconds + 30;
	Customers[Customers.Length] = PT;
	return true;
}

function bool HasCustomer(Pawn P)
{
	local int i;

	if ( Customers.Length > 0 )
		for ( i=0; i<Customers.Length; i++ )
		{
			if ( Customers[i].NextTouchTime < WorldInfo.TimeSeconds )
			{
				if ( Customers[i].P == P )
					return false;
				Customers.Remove(i,1);
				i--;
			}
			else if ( Customers[i].P == P )
				return true;
		}

	return false;
}

simulated function PostBeginPlay()
{
	if ( bIsDisabled )
	{
		return;
	}
	Super.PostBeginPlay();

	InitializeWeapons();
}

/** initialize properties/display for the weapons that are listed in the array */
simulated function InitializeWeapons()
{
	local int i;

	// clear out null entries
	for (i = 0; i < Weapons.length && i < LockerPositions.length; i++)
	{
		if (Weapons[i].WeaponClass == None)
		{
			Weapons.Remove(i, 1);
			i--;
		}
	}

	// initialize weapons
	MaxDesireability = 0;
	for (i = 0; i < Weapons.Length; i++)
	{
		MaxDesireability += Weapons[i].WeaponClass.Default.AIRating;
	}
}

simulated event ReplicatedEvent(name VarName)
{
	local int i;

	if (VarName == 'ReplacementWeapons')
	{
		for (i = 0; i < ArrayCount(ReplacementWeapons); i++)
		{
			if ( ReplacementWeapons[i].bReplaced )
			{
				if (i >= Weapons.length)
				{
					Weapons.length = i + 1;
				}
				Weapons[i].WeaponClass = ReplacementWeapons[i].WeaponClass;
				if (Weapons[i].PickupMesh != None)
				{
					DetachComponent(Weapons[i].PickupMesh);
					Weapons[i].PickupMesh = None;
				}
			}
		}
		InitializeWeapons();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** replaces an entry in the Weapons array (generally used by mutators) */
function ReplaceWeapon(int Index, class<UTWeapon> NewWeaponClass)
{
	if (Index >= 0)
	{
		if (Index >= Weapons.length)
		{
			Weapons.length = Index + 1;
		}
		Weapons[Index].WeaponClass = NewWeaponClass;
		if (Index < ArrayCount(ReplacementWeapons))
		{
			ReplacementWeapons[Index].bReplaced = true;
			ReplacementWeapons[Index].WeaponClass = NewWeaponClass;
		}
	}
}

function Reset()
{
	Super(NavigationPoint).Reset();
}

simulated function String GetHumanReadableName()
{
	return LockerString;
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot, Controller C)
{
	local UTWeapon AlreadyHas;
	local float desire;
	local int i;

	if ( bHidden || HasCustomer(Bot) )
		return 0;

	// see if bot already has a weapon of this type
	for ( i=0; i<Weapons.Length; i++ )
		if ( Weapons[i].WeaponClass != None )
		{
			AlreadyHas = UTWeapon(Bot.FindInventoryType(Weapons[i].WeaponClass));
			if ( AlreadyHas == None )
				desire += Weapons[i].WeaponClass.Default.AIRating;
			else if ( AlreadyHas.NeedAmmo() )
				desire += 0.15;
		}
	if ( UTBot(C).bHuntPlayer && (desire * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local UTWeapon AlreadyHas;
	local float desire;
	local int i;

	if ( bHidden || HasCustomer(Other) )
		return 0;

	// see if bot already has a weapon of this type
	for ( i=0; i<Weapons.Length; i++ )
	{
		AlreadyHas = UTWeapon(Other.FindInventoryType(Weapons[i].WeaponClass));
		if ( AlreadyHas == None )
			desire += Weapons[i].WeaponClass.Default.AIRating;
		else if ( AlreadyHas.NeedAmmo() )
			desire += 0.15;
	}
	if ( UTBot(Other.Controller).PriorityObjective()
		&& ((Other.Weapon.AIRating > 0.5) || (PathWeight > 400)) )
		return 0.2/PathWeight;
	return desire/PathWeight;
}

simulated function InitializePickup() {}
simulated function ShowActive();
simulated function NotifyLocalPlayerDead(PlayerController PC);

simulated event SetPlayerNearby(PlayerController PC, bool bNewPlayerNearby, bool bPlayEffects)
{
	local int i;
	local vector NewScale;
	local PrimitiveComponent DefaultMesh;
	local UTInventoryManager InvManager;

	if (bNewPlayerNearby != bPlayerNearby)
	{
		bPlayerNearby = bNewPlayerNearby;
		if ( WorldInfo.NetMode == NM_DedicatedServer )
		{
			return;
		}
		if (bPlayerNearby)
		{
			LightEnvironment.bDynamic = true;
			bScalingUp = true;
			CurrentWeaponScaleX = 0.1;
			if ( (PC != None) && (PC.Pawn != None) )
			{
				if ( UTPawn(PC.Pawn) != None )
				{
					InvManager = UTInventoryManager(PC.Pawn.InvManager);
				}
				else if (UTVehicle(PC.Pawn) != None )
				{
					InvManager = UTInventoryManager(UTVehicle(PC.Pawn).Driver.InvManager);
				}
			}

			if ( InvManager != None )
			{
				for (i = 0; i < Weapons.length; i++)
				{
					if ( (Weapons[i].WeaponClass.default.PickupFactoryMesh != None)
						 && (InvManager.HasInventoryOfClass(Weapons[i].WeaponClass) == None) )
					{
						if ( Weapons[i].PickupMesh == None )
						{
							DefaultMesh = Weapons[i].WeaponClass.default.PickupFactoryMesh;
							Weapons[i].PickupMesh = new(self) DefaultMesh.Class(DefaultMesh);
							Weapons[i].PickupMesh.SetTranslation(LockerPositions[i] + Weapons[i].WeaponClass.default.LockerOffset);
							Weapons[i].PickupMesh.SetRotation(Weapons[i].WeaponClass.default.LockerRotation);
							Weapons[i].PickupMesh.SetLightEnvironment(LightEnvironment);
							// Force skeletal mesh weapons to be in reference pose.
							if( SkeletalMeshComponent(Weapons[i].PickupMesh) != None )
							{
								SkeletalMeshComponent(Weapons[i].PickupMesh).bForceRefPose = 1;
							}
							NewScale = Weapons[i].PickupMesh.Scale3D;
							NewScale.X = 0.1;
							Weapons[i].PickupMesh.SetScale3D(NewScale);
						}
						if (Weapons[i].PickupMesh != None)
						{
							Weapons[i].PickupMesh.SetHidden(false);
							AttachComponent(Weapons[i].PickupMesh);

							if (bPlayEffects)
							{
								WorldInfo.MyEmitterPool.SpawnEmitter(WeaponSpawnEffectTemplate, Weapons[i].PickupMesh.GetPosition());
							}
						}
					}
				}
			}
			ProximityEffect.SetActive(true);
			ClearTimer('DestroyWeapons');
		}
		else
		{
			LightEnvironment.bDynamic = false;
			bPlayEffects = bPlayEffects && EffectIsRelevant(Location, false);
			bScalingUp = false;
			for (i = 0; i < Weapons.length; i++)
			{
				if (Weapons[i].PickupMesh != None)
				{
					Weapons[i].PickupMesh.SetHidden(true);
					if (bPlayEffects)
					{
						WorldInfo.MyEmitterPool.SpawnEmitter(WeaponSpawnEffectTemplate, Weapons[i].PickupMesh.GetPosition());
					}
				}
			}
			ProximityEffect.DeactivateSystem();
			SetTimer(5.0, false, 'DestroyWeapons');
		}
	}
}

simulated function DestroyWeapons()
{
	local int i;

	for (i = 0; i < Weapons.length; i++)
	{
		if (Weapons[i].PickupMesh != None)
		{
			DetachComponent(Weapons[i].PickupMesh);
			Weapons[i].PickupMesh = None;
		}
	}
}

simulated function ShowHidden()
{
	bIsActive = false;
	AmbientEffect.SetTemplate(InactiveEffectTemplate);
	SetPlayerNearby(None, false, false);
}

auto state LockerPickup
{
	simulated event Tick(FLOAT DeltaTime)
	{
		local bool bNewPlayerNearby;
		local PlayerController NearbyPC, PC;

		if ( WorldInfo.NetMode == NM_DedicatedServer )
		{
			Disable('Tick');
		}
		else if ( bIsActive )
		{
			if ( WorldInfo.TimeSeconds > NextProximityCheckTime )
			{
				NextProximityCheckTime = WorldInfo.TimeSeconds + 0.2 + 0.1 * FRand();
				ForEach LocalPlayerControllers(class'PlayerController', PC)
				{
					if ( PC.Pawn != None && (VSizeSq(Location - PC.Pawn.Location) < ProximityDistanceSquared) )
					{
						bNewPlayerNearby = TRUE;
						NearbyPC = PC;
						break;
					}
				}
				if ( bNewPlayerNearby != bPlayerNearby )
				{
					SetPlayerNearby(NearbyPC, bNewPlayerNearby, true);
				}
			}
		}
	}

	function bool ReadyToPickup(float MaxWait)
	{
		return true;
	}

	/*
	 * Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	simulated function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if (Pawn(Other) == None || !Pawn(Other).bCanPickupInventory)
		{
			return false;
		}
		else if (Pawn(Other).Controller == None)
		{
			// re-check later in case this Pawn is in the middle of spawning, exiting a vehicle, etc
			// and will have a Controller shortly
			SetTimer(0.2, false, 'RecheckValidTouch');
			return false;
		}
		// make sure not touching through wall
		else if ( !FastTrace(Other.Location, Location) )
		{
			SetTimer(0.5, false, 'RecheckValidTouch');
			return false;
		}

		return true;
	}

	/**
	Pickup was touched through a wall.  Check to see if touching pawn is no longer obstructed
	*/
	function RecheckValidTouch()
	{
		CheckTouching();
	}

	/**
	 * Make sure no pawn already touching (while touch was disabled in sleep).
	*/
	function CheckTouching()
	{
		local Pawn P;

		ForEach TouchingActors(class'Pawn', P)
			Touch(P, None, Location, Normal(Location-P.Location) );
	}

	simulated function ShowActive()
	{
		bIsActive = true;
		AmbientEffect.SetTemplate(ActiveEffectTemplate);
		NextProximityCheckTime = 0;
	}

	simulated function NotifyLocalPlayerDead(PlayerController PC)
	{
		ShowActive();
	}

	// When touched by an actor.
	simulated event Touch( actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local int		i;
		local UTWeapon Copy;
		local Pawn Recipient;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			Recipient = Pawn(Other);
			if ( (Recipient.Controller != None && Recipient.Controller.IsLocalPlayerController()) ||
				(Recipient.DrivenVehicle != None && Recipient.DrivenVehicle.Controller != None && Recipient.DrivenVehicle.Controller.IsLocalPlayerController()) )
			{
				if ( bIsActive )
				{
					ShowHidden();
					SetTimer(30,false,'ShowActive');
				}
			}
			if ( Role < ROLE_Authority )
				return;
			if ( !AddCustomer(Recipient) )
				return;

			for ( i=0; i<Weapons.Length; i++ )
			{
				InventoryType = Weapons[i].WeaponClass;
				Copy = UTWeapon(UTInventoryManager(Recipient.InvManager).HasInventoryOfClass(InventoryType));
				if ( Copy != None )
				{
					if ( Copy.LockerAmmoCount - Copy.AmmoCount > 0 )
						Copy.AddAmmo(Copy.LockerAmmoCount - Copy.AmmoCount);
					Copy.AnnouncePickup(Recipient);
				}
				else if (WorldInfo.Game.PickupQuery(Recipient, InventoryType, self))
				{
					Copy = UTWeapon(spawn(InventoryType));
					if ( Copy != None )
					{
						Copy.GiveTo(Recipient);
						Copy.AnnouncePickup(Recipient);
						if ( Copy.LockerAmmoCount - Copy.Default.AmmoCount > 0 )
							Copy.AddAmmo(Copy.LockerAmmoCount - Copy.Default.AmmoCount);
					}
					else
						`log(self$" failed to spawn "$inventorytype);
				}
			}
		}
	}

	simulated event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		ShowActive();
	}
}

State Disabled
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		ShowHidden();
	}
}

defaultproperties
{
	//PickupSound=Sound'NewWeaponSounds.WeaponsLocker_01'
	NetUpdateFrequency=1

	//MessageClass=class'UTPickupMessage'
	bRotatingPickup=false
	bMovable=FALSE
	bStatic=FALSE

	LockerPositions[0]=(X=18.0,Y=-30.0)
	LockerPositions[1]=(X=-15.0,Y=25.0)
	LockerPositions[2]=(X=34.0,Y=-2.0)
	LockerPositions[3]=(X=-30.0,Y=0.0)
	LockerPositions[4]=(X=16.0,Y=22.0)
	LockerPositions[5]=(X=-19.0,Y=-32.0)

	ProximityDistanceSquared=600000.0
	ScaleRate=2.0

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00080.000000
		CollisionHeight=+00050.000000
		CollideActors=true
	End Object
}

