/**
 * used by SeqAct_DummyWeaponFire to hold the weapon 
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDummyPawn extends UTPawn;

/** pointer back to the Kismet action that created us */
var UTSeqAct_DummyWeaponFire FireAction;

simulated function PostBeginPlay()
{
	Super(Pawn).PostBeginPlay();

	UTInventoryManager(InvManager).bInfiniteAmmo = true;
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	// force update LastRenderTime so attachment doesn't cull effects due to its mesh being hidden
	LastRenderTime = WorldInfo.TimeSeconds;

	Super.WeaponFired(InWeapon, bViaReplication, HitLocation);

	FireAction.NotifyDummyFire();
}

simulated function SetPawnAmbientSound(SoundCue NewAmbientSound)
{
	if (!FireAction.bSuppressSounds)
	{
		Super.SetPawnAmbientSound(NewAmbientSound);
	}
}

simulated function SetWeaponAmbientSound(SoundCue NewAmbientSound)
{
	if (!FireAction.bSuppressSounds)
	{
		Super.SetWeaponAmbientSound(NewAmbientSound);
	}
}

simulated function rotator GetAdjustedAimFor(Weapon InWeapon, vector ProjStart)
{
	local rotator BaseRotation;

	if (FireAction.Target != None)
	{
		BaseRotation = rotator(FireAction.Target.Location - ProjStart);
	}
	else
	{
		BaseRotation = Rotation;
	}
	return (BaseRotation + (FireAction.MaxSpread * (1.0 - 2.0 * FRand())));
}

simulated function WeaponAttachmentChanged()
{
	if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass))
	{
		// Detach/Destroy the current attachment if we have one
		if (CurrentWeaponAttachment!=None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
		}

		// Create the new Attachment.
		if (CurrentWeaponAttachmentClass!=None)
		{
			CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass,self);
			CurrentWeaponAttachment.Instigator = self;
		}
		else
			CurrentWeaponAttachment = none;

		// If all is good, attach it to the Pawn's Mesh.
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.bSuppressSounds = FireAction.bSuppressSounds;
			CurrentWeaponAttachment.AttachTo(self);

			// hide the weapon attachment mesh, but leave effects visible
			CurrentWeaponAttachment.SetHidden(false);
			CurrentWeaponAttachment.Mesh.SetRotation(rot(0, -16384, 0)); // all are weapon attachments are sideways
			CurrentWeaponAttachment.AttachComponent(CurrentWeaponAttachment.Mesh);
			CurrentWeaponAttachment.Mesh.SetHidden(true);
		}
	}
}

simulated function vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	return GetPawnViewLocation();
}

simulated function vector GetPawnViewLocation()
{
	if (CurrentWeaponAttachment != None && CurrentWeaponAttachment.MuzzleFlashPSC != None)
	{
		return CurrentWeaponAttachment.MuzzleFlashPSC.GetPosition();
	}
	else
	{
		return Super.GetPawnViewLocation();
	}
}

simulated event Tick(float DeltaTime)
{
	// move the weapon attachment to the right location each frame
	if (CurrentWeaponAttachment != None && FireAction.Origin != None && FireAction.Target != None)
	{
		CurrentWeaponAttachment.SetLocation(FireAction.Origin.Location);
		CurrentWeaponAttachment.SetRotation(rotator(FireAction.Target.Location - FireAction.Origin.Location));
	}
}

defaultproperties
{
	Components.Empty()
	Mesh=None
	CollisionComponent=None

	RemoteRole=ROLE_None
	bCollideActors=false
	bGameRelevant=true
}
