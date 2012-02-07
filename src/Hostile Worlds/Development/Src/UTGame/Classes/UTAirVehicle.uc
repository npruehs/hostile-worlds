/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


/** base class for vehicles that fly or hover */
class UTAirVehicle extends UTVehicle
	abstract;

var bool bAutoLand;
var float PushForce;	// for AI when landing;

var localized string RadarLockMessage;				/** Displayed when enemy raptor fires locked missile at you */

var float LastRadarLockWarnTime;

simulated event LockOnWarning(UDKProjectile IncomingMissile)
{
	SendLockOnMessage(1);
}

simulated function SetDriving(bool bNewDriving)
{
	if (bAutoLand && !bNewDriving && !bChassisTouchingGround && Health > 0)
	{
		if (Role == ROLE_Authority)
		{
			GotoState('AutoLanding');
		}
	}
	else
	{
		Super.SetDriving(bNewDriving);
	}
}

/** state to automatically land when player jumps out while high above land */
state AutoLanding
{
	simulated function SetDriving(bool bNewDriving)
	{
		if ( bNewDriving )
		{
			GotoState('Auto');
			Global.SetDriving(bNewDriving);
		}
	}

	function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
	{
		if (Global.Died(Killer, DamageType, HitLocation))
		{
			SetDriving(false);
			return true;
		}
		else
		{
			return false;
		}
	}

	function Tick(float DeltaTime)
	{
		local actor HitActor;
		local vector HitNormal, HitLocation;

		if (bChassisTouchingGround)
		{
			GotoState('Auto');
			SetDriving(false);
		}
		else
		{
			HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2500), Location, false);
			if ( Velocity.Z < -1200 )
				OutputRise = 1.0;
			else if ( HitActor == None )
				OutputRise = -1.0;
			else if ( VSize(HitLocation - Location) < -2*Velocity.Z )
			{
				if ( Velocity.Z > -100 )
					OutputRise = 0;
				else
					OutputRise = 1.0;
			}
			else if ( Velocity.Z > -500 )
				OutputRise = -0.4;
			else
				OutputRise = -0.1;
		}
	}
}

//==============================
// AI interface
function bool RecommendLongRangedAttack()
{
	return true;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = WorldInfo.TimeSeconds + 1;
		Rise = 1;
	}
	return false;
}

defaultproperties
{
	bAutoLand=true
	ContrailColorParameterName=ContrailColor
	bHomingTarget=true
	bNoZDampingInAir=false

	bReducedFallingCollisionDamage=true

	bCanStrafe=true
	bCanFly=true
	bTurnInPlace=true
	bFollowLookDir=true
	bDriverHoldsFlag=false
	bCanCarryFlag=false

	LookForwardDist=100.0

	IconCoords=(U=989,V=24,UL=43,VL=48)

	bEjectPassengersWhenFlipped=false
	bMustBeUpright=false
	UpsideDownDamagePerSec=0.0

	bDropDetailWhenDriving=true
	bFindGroundExit=false

	//@todo: it would be nice if the alternate path code would count being in a VolumePathNode above the intended alternate path
	bUseAlternatePaths=false
	
	bJostleWhileDriving=true
	bFloatWhenDriven=true
}
