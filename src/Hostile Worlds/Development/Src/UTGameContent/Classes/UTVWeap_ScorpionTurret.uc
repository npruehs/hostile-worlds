/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVWeap_ScorpionTurret extends UTVehicleWeapon
	HideDropDown;

var class<UTProj_ScorpionGlob_Base> TeamProjectiles[2];

/**
 * GetAdjustedAim begins a chain of function class that allows the weapon, the pawn and the controller to make
 * on the fly adjustments to where this weapon is pointing.
 */
simulated function Rotator GetAdjustedAim( vector StartFireLoc )
{
	local rotator R;

	// Start the chain, see Pawn.GetAdjustedAimFor()
	R = Instigator.GetAdjustedAimFor( Self, StartFireLoc );

	if ( PlayerController(Instigator.Controller) != None )
	{
		R.Pitch = R.Pitch & 65535;
		if ( R.Pitch < 16384 )
		{
			R.Pitch += (16384 - R.Pitch)/16;
		}
		else if ( R.Pitch > 49152 )
		{
			R.Pitch += 1024;
		}
	}
	else
	{
		// due to the way SuggestTossVelocity() tests in increments combined with the high projectile speed,
		// the bots tend to overshoot just a tiny bit, so we nudge their aim down a little here
		R.Pitch -= 100;
	}

	return R;
}

simulated function Projectile ProjectileFire()
{
	if(Role==ROLE_Authority)
	{
		WeaponProjectiles[0] = TeamProjectiles[(MyVehicle.GetTeamNum()==1)?1:0];
	}
	return super.ProjectileFire();
}

defaultproperties
{
	WeaponColor=(R=64,G=255,B=64,A=255)
	PlayerViewOffset=(X=11.0,Y=7.0,Z=-9.0)

	FireInterval(0)=+0.65
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_ScorpionGlob'
	TeamProjectiles[0]=class'UTProj_ScorpionGlob_Red'
	TeamProjectiles[1]=class'UTProj_ScorpionGlob'

	WeaponFireSnd[0]=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_AltFire'
	bFastRepeater=true

	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShotCost(0)=0
	ShotCost(1)=0

	FireOffset=(X=19,Y=10,Z=-10)
	IconX=382
	IconY=82
	IconWidth=27
	IconHeight=42
	VehicleClass=class'UTVehicle_Scorpion_Content'
	WeaponRange=7000
	AimError=650
}
