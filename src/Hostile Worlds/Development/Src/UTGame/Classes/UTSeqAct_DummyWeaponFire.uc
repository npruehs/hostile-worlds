/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** spawns a ghost to magically fire a weapon for cinematics
 * @note: no replication, expected to execute completely clientside
 */
class UTSeqAct_DummyWeaponFire extends SeqAct_Latent;

/** dummy pawn used to fire the weapon */
var UTDummyPawn DummyPawn;

/** number of shots to fire, <= 0 for shoot forever */
var() int ShotsToFire;
/** class of weapon to fire */
var() class<UTWeapon> WeaponClass;
/** which fire mode to use */
var() byte FireMode;
/** actor where the weapon fire is coming from */
var() Actor Origin;
/** target actor for the weapon fire */
var() Actor Target;
/** how far off the target shots can be */
var() rotator MaxSpread;
/** if set, weapon doesn't play any sounds */
var() bool bSuppressSounds;

/** number of shots fired so far */
var int ShotsFired;

event Activated()
{
	local UTWeapon NewWeapon;

	if (InputLinks[0].bHasImpulse)
	{
		if (WeaponClass == None)
		{
			ScriptLog("Error: DummyWeaponFire with no WeaponClass");
		}
		else if (Origin == None)
		{
			ScriptLog("Error: DummyWeaponFire with no Origin");
		}
		else if (Target == None)
		{
			ScriptLog("Error: DummyWeaponFire with no Target");
		}
		else
		{
			// start firing
			ShotsFired = 0;

			if (DummyPawn == None || DummyPawn.bDeleteMe)
			{
				// init the dummy pawn
				DummyPawn = Origin.Spawn(class'UTDummyPawn');
				if (DummyPawn == None)
				{
					ScriptLog("Error: Failed to spawn dummy actor");
				}
				else
				{
					DummyPawn.FireAction = self;
					// give it the weapon
					NewWeapon = DummyPawn.Spawn(WeaponClass, DummyPawn);
					NewWeapon.bAllowFiringWithoutController = true;
					NewWeapon.bSuppressSounds = bSuppressSounds;
					NewWeapon.GiveTo(DummyPawn);
					DummyPawn.InvManager.SetCurrentWeapon(NewWeapon);
					// make sure the weapon attachment is set up
					DummyPawn.WeaponAttachmentChanged();
					// start it firing
					DummyPawn.StartFire(FireMode);
				}
			}
			else
			{
				// restart already existing pawn
				DummyPawn.StopWeaponFiring();
				DummyPawn.StartFire(FireMode);
				DummyPawn.LifeSpan = 0.0;
			}
		}
	}
	else
	{
		if (DummyPawn != None)
		{
			DummyPawn.StopWeaponFiring();
			DummyPawn.LifeSpan = 1.0; // so final muzzle flash has time to play
			OutputLinks[2].bHasImpulse = true;
		}
	}
	OutputLinks[0].bHasImpulse = true;
}

/** notification that the dummy pawn has fired a shot */
function NotifyDummyFire()
{
	ShotsFired++;
	if (ShotsToFire > 0 && ShotsFired >= ShotsToFire)
	{
		// we're done
		DummyPawn.StopWeaponFiring();
		DummyPawn.LifeSpan = 1.0; // so final muzzle flash has time to play
		OutputLinks[1].bHasImpulse = true;
	}
}

event bool Update(float DeltaTime)
{
	// keep ticking as long as the dummy pawn is still going
	return (DummyPawn != None && DummyPawn.LifeSpan ~= 0.0);
}

defaultproperties
{
	ObjName="Dummy Weapon Fire"
	ObjCategory="Cinematic"
	bCallHandler=false
	bAutoActivateOutputLinks=false

	ShotsToFire=1

	InputLinks(0)=(LinkDesc="Start Firing")
	InputLInks(1)=(LinkDesc="Stop Firing")

	OutputLinks(0)=(LinkDesc="Out")
	OutputLinks(1)=(LinkDesc="Finished")
	OutputLinks(2)=(LinkDesc="Stopped")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Origin",PropertyName=Origin,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MaxVars=1)
}
