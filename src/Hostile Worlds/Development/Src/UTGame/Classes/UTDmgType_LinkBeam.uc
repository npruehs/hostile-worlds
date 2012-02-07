/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_LinkBeam extends UTDamageType
	abstract;

var ParticleSystem PS_AttachToGib;

var name BoneToAttach;
var ParticleSystem PS_AttachToBody;

static function DoCustomDamageEffects(UTPawn ThePawn, class<UTDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
	local Vector BoneLocation;

	if ( class'GameInfo'.static.UseLowGore(ThePawn.WorldInfo) )
	{
		return;
	}
	CreateDeathSkeleton( ThePawn, TheDamageType, HitInfo, HitLocation );
	//CreateDeathGoreChunks( ThePawn, TheDamageType, HitInfo, HitLocation );

	// we just want to spawn the bloody core explosion and not the individual gibs
	if( ThePawn.GetFamilyInfo().default.GibExplosionTemplate != None && ThePawn.EffectIsRelevant(ThePawn.Location, false, 7000) )
	{
		ThePawn.WorldInfo.MyEmitterPool.SpawnEmitter(ThePawn.GetFamilyInfo().default.GibExplosionTemplate, ThePawn.Location, ThePawn.Rotation);
	}

	ThePawn.bGibbed=TRUE; // this makes it so you can't then switch to a "gibbing" weapon and get chunks

	BoneLocation = ThePawn.Mesh.GetBoneLocation( default.BoneToAttach );

	ThePawn.WorldInfo.MyEmitterPool.SpawnEmitter( default.PS_AttachToBody, BoneLocation, Rotator(vect(0,0,1)), ThePawn );
}


/** allows special effects when gibs are spawned via DoCustomDamageEffects() instead of the normal way */
simulated static function SpawnExtraGibEffects(UTGib TheGib)
{
	if ( (TheGib.WorldInfo.GetDetailMode() != DM_Low) && !TheGib.WorldInfo.bDropDetail && FRand() < 0.70f )
	{
		TheGib.PSC_GibEffect = new(TheGib) class'UTParticleSystemComponent';
		TheGib.PSC_GibEffect.SetTemplate(default.PS_AttachToGib);
		TheGib.AttachComponent(TheGib.PSC_GibEffect);
	}
}

defaultproperties
{
	KillStatsName=KILLS_LINKGUN
	DeathStatsName=DEATHS_LINKGUN
	SuicideStatsName=SUICIDES_LINKGUN
	RewardCount=15
	RewardEvent=REWARD_SHAFTMASTER
	RewardAnnouncementSwitch=1
	DamageWeaponClass=class'UTWeap_LinkGun'
	DamageWeaponFireMode=1

	DamageBodyMatColor=(R=50,G=50,B=50)
	DamageOverlayTime=0.5
	DeathOverlayTime=1.0

	bCausesBlood=false
	bLeaveBodyEffect=true
	bUseDamageBasedDeathEffects=true
	VehicleDamageScaling=0.8
	VehicleMomentumScaling=0.1

	KDamageImpulse=100

	PS_AttachToGib=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Death_Gib_Effect'
	DamageCameraAnim=CameraAnim'Camera_FX.LinkGun.C_WP_Link_Beam_Hit'

	BoneToAttach="b_Spine1"
	PS_AttachToBody=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Skeleton_Dissolve'
}
