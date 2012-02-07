/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVWeap_CicadaTurret extends UTVehicleWeapon
	HideDropDown;

var Projectile Incoming;
var Projectile IgnoredMissile, WatchedMissile;
/** array of all missiles known to be targeting us */
var array<Projectile> Missiles;

simulated function AddMissile(Projectile P)
{
	local int i;

	for (i = 0; i < Missiles.length; i++)
	{
		if (Missiles[i] == P)
		{
			// already in list
			return;
		}
	}

	Missiles[Missiles.length] = P;
}

//Notify vehicle that an enemy has locked on to it
simulated function IncomingMissile(Projectile P)
{
	local UTBot B;

	AddMissile(P);
	if (Role == ROLE_Authority && IgnoredMissile != P && Instigator != None)
	{
		if (WatchedMissile != P)
		{
			B = UTBot(Instigator.Controller);
			if (B == None || B.Skill < 2.0 + 3.0 * FRand())
			{
				if (Instigator.Controller != None || UTBot(MyVehicle.Controller) == None || UTBot(MyVehicle.Controller).Skill < 3.0 + 3.0 * FRand())
				{
					IgnoredMissile = P;
					return;
				}
			}
			WatchedMissile = P;
		}

		// FIRE CHAFF if missile nearby
		if (VSize(MyVehicle.Location - P.Location) < 1000.0 + class'UTDecoy'.default.DecoyRange)
		{
			if (Instigator.Controller == None)
			{
				if (UTBot(MyVehicle.Controller) == None)
				{
					IgnoredMissile = P;
					return;
				}
				MyVehicle.StopFiring();
			}
			else if (UTBot(Instigator.Controller) == None)
			{
				IgnoredMissile = P;
				return;
			}
			Incoming = P;
			IgnoredMissile = P;
			Instigator.StartFire(1);
		}
	}
}

simulated function rotator GetAdjustedAim(vector StartFireLoc)
{
	local rotator Result;

	if (CurrentFireMode == 1 && Instigator.Controller == None && Incoming != None)
	{
		Result = rotator(Incoming.Location + Incoming.Velocity * (VSize(Incoming.Location - StartFireLoc) / class'UTDecoy'.default.Speed) - StartFireLoc);
		if (Result.Pitch > 0 && Result.Pitch < 32768)
		{
			Result.Pitch = 0;
		}
		return Result;
	}
	else
	{
		return Super.GetAdjustedAim(StartFireLoc);
	}
}

simulated function Projectile ProjectileFire()
{
	local UTDecoy D;
	local UTVehicle_Cicada_Content V;

	D = UTDecoy(Super.ProjectileFire());
	if (D != None)
	{
		V = UTVehicle_Cicada_Content(MyVehicle);
		if (V != None)
		{
			V.Decoys[V.Decoys.length] = D;
			D.ProtectedTarget = V;
		}
	}

	return D;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_Projectile
	bInstantHit=true
	WeaponProjectiles(1)=class'UTDecoy'
	FireInterval(0)=0.2
	FireInterval(1)=1.5
	InstantHitDamageTypes(0)=class'UTDmgType_CicadaLaser'
	InstantHitDamageTypes(1)=None
	ShotCost(0)=0
	ShotCost(1)=0
	InstantHitDamage(0)=25
	InstantHitMomentum(0)=+20000.0
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TurretFire'
	WeaponFireSnd[1]=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TurretAltFire'

	FireTriggerTags=(TurretWeapon00,TurretWeapon01,TurretWeapon02,TurretWeapon03)

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndPrim_impact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	bFastRepeater=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	VehicleClass=class'UTVehicle_Cicada_Content'
}
