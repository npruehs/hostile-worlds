/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_MantaBolt extends UTProjectile;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector x;
	if ( WorldInfo.NetMode != NM_DedicatedServer && EffectIsRelevant(Location,false,MaxEffectDistance) )
	{
		x = normal(Velocity cross HitNormal);
		x = normal(HitNormal cross x);

		WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(x));
		bSuppressExplosionFX = true;
	}

	if (ExplosionSound!=None)
	{
		PlaySound(ExplosionSound);
	}
}


defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Projectile'
	ProjExplosionTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_Impact'
	ExplosionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Shot'
    Speed=2000
    MaxSpeed=7000
    AccelRate=16000.0

    Damage=36
    DamageRadius=0
    MomentumTransfer=4000
	CheckRadius=30.0
    MyDamageType=class'UTDmgType_MantaBolt'
    LifeSpan=1.6

    bCollideWorld=true
    DrawScale=2.0
}
