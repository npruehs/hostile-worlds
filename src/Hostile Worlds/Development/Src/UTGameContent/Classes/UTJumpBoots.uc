/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
/** jump boots drastically increase a player's double jump velocity */
class UTJumpBoots extends UTInventory;

/** the Z velocity boost to give the owner's double jumps */
var float MultiJumpBoost;
/** the number of jumps that the owner can do before the boots run out */
var repnotify byte Charges;
/** sound to play when the boots are used */
var SoundCue ActivateSound;
/** message to send to the owner when the boots run out */
var databinding	localized string RanOutText;

replication
{
	if (bNetOwner && bNetDirty && Role==ROLE_Authority)
		Charges;
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	Super.GivenTo(NewOwner, bDoNotActivate);
	AdjustPawn(UTPawn(NewOwner), false);
}

function ItemRemovedFromInvManager()
{
	AdjustPawn(UTPawn(Owner), true);
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'Charges')
	{
		UTPawn(Owner).JumpBootCharge = Charges;
	}

	Super.ReplicatedEvent(VarName);
}


reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super.ClientGivenTo(NewOwner, bDoNotActivate);
	if (Role < ROLE_Authority)
	{
		AdjustPawn(UTPawn(NewOwner), false);
	}
}

reliable client function ClientLostItem()
{
	local UTPawn P;

	P = UTPawn(Owner);
	if (P != None)
	{
		if (Role < ROLE_Authority)
		{
			AdjustPawn(P, true);
		}
		P.JumpBootCharge = 0;
	}

	Super.ClientLostItem();
}

/** adds or removes our bonus from the given pawn */
simulated function AdjustPawn(UTPawn P, bool bRemoveBonus)
{
	if (P != None)
	{
		if (bRemoveBonus)
		{
			P.MultiJumpBoost -= MultiJumpBoost;
			P.MaxFallSpeed -= MultiJumpBoost;
			P.JumpBootCharge = 0;
			// increase cost of high jump nodes so bots don't waste the boots for small shortcuts
			if (P.Controller != None)
			{
				P.Controller.HighJumpNodeCostModifier -= 1000;
			}
		}
		else
		{
			P.MultiJumpBoost += MultiJumpBoost;
			P.MaxFallSpeed += MultiJumpBoost;
			P.JumpBootCharge = Charges;
			// increase cost of high jump nodes so bots don't waste the boots for small shortcuts
			if (P.Controller != None)
			{
				P.Controller.HighJumpNodeCostModifier += 1000;
			}
		}
	}
}

simulated function OwnerEvent(name EventName)
{
	if (Role == ROLE_Authority)
	{
		if (EventName == 'MultiJump')
		{
			Charges--;
			UTPawn(Owner).JumpBootCharge = Charges;
			Spawn(class'UTJumpBootEffect', Owner,, Owner.Location, Owner.Rotation);
			Owner.PlaySound(ActivateSound, false, true, false);
		}
		else if (EventName == 'Landed' && Charges <= 0)
		{
			Destroy();
		}
	}
	else if (EventName == 'MultiJump')
	{
		Owner.PlaySound(ActivateSound, false, true, false);
	}
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	if (ItemClass == Class)
	{
		Charges = default.Charges;
		UTPawn(Owner).JumpBootCharge = Charges;
		Pickup.PickedUpBy(Instigator);
		AnnouncePickup(Instigator);
		return true;
	}

	return false;
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	if (Charges <= 0)
	{
		Destroy();
	}
	else
	{
		Super.DropFrom(StartLocation, StartVelocity);
	}
}

static function float BotDesireability(Actor PickupHolder, Pawn P, Controller C)
{
	local UTJumpBoots AlreadyHas;

	AlreadyHas = UTJumpBoots(P.FindInventoryType(default.Class));
	if (AlreadyHas != None)
	{
		return (default.MaxDesireability / (1 + AlreadyHas.Charges));
	}

	return default.MaxDesireability;
}

static function float DetourWeight(Pawn Other, float PathWeight)
{
	return (default.MaxDesireability / PathWeight);
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Pickups.JumpBoots.Mesh.S_UN_Pickups_Jumpboots002'
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		Translation=(X=0.0,Y=0.0,Z=-20.0)
		Scale=1.7
	End Object
	DroppedPickupMesh=StaticMeshComponent1
	PickupFactoryMesh=StaticMeshComponent1

	MaxDesireability=1.00
	RespawnTime=30.0
	bReceiveOwnerEvents=true
	bDropOnDeath=true
	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_PickupCue'

	Charges=3
	MultiJumpBoost=750.0
	ActivateSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_JumpCue'
}
