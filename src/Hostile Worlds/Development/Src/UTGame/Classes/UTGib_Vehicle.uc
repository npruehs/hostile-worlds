/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTGib_Vehicle extends UTGib
	abstract;


var float TimeBeforeGibExplosionEffect;

/** Effect to have when gib is first spawned.  Actually happens at TimeBeforeGibExplosionEffect after being spawned **/
var ParticleSystem PS_GibExplosionEffect;

/** PS to attach and trail behind the gib **/
var ParticleSystem PS_GibTrailEffect;

/** Played when the Gib has been spawned **/
var SoundCue LoopedSound;

var name BurnName;
var float BurnDuration;

var MaterialInstanceTimeVarying MITV;

var class<UTVehicle> OwningClass;



simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	CreateAudioComponent( LoopedSound, TRUE, TRUE );
}


simulated function ActivateGibExplosionEffect()
{
	local int TeamNum;
	local ParticleSystemComponent PSC_Trail;

	if(WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}
	if ( Instigator != None )
	{
		TeamNum = Instigator.GetTeamNum();
	}
	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	if( OwningClass.default.BurnOutMaterial[TeamNum] != None )
	{
		GibMeshComp.SetMaterial( 0, OwningClass.default.BurnOutMaterial[TeamNum] );
	}

	// don't spawn the particle system
	if(WorldInfo.TimeSeconds - GibMeshComp.LastRenderTime < 1.0)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter( PS_GibExplosionEffect, Location, Rotation );
		
		// we can't use the pool for trails as they have a long (infi) duration
		//WorldInfo.MyEmitterPool.SpawnEmitter( PS_GibTrailEffect, Location, Rotation, self );
		PSC_Trail = new(self) class'ParticleSystemComponent';
		PSC_Trail.SetTemplate( PS_GibTrailEffect );
		AttachComponent( PSC_Trail );
	}

	// if the vehicle could be close to us go ahead and do the MITV so that gibs near us will burn out nicely
	if(WorldInfo.TimeSeconds - GibMeshComp.LastRenderTime < 3.0)
	{	
		MITV = GibMeshComp.CreateAndSetMaterialInstanceTimeVarying( 0 );
		MITV.SetScalarStartTime( 'BurnTime', (LifeSpan-(BurnDuration-(FRand()*1.0f))) );
		//`log( "BurnDuration: " $ BurnDuration $ " LifeSpan: " $ LifeSpan $ " MITV: " $ MITV.Parent );
	}
}



defaultproperties
{
	BurnDuration=3.5f
	BurnName="BurnTime"

	TimeBeforeGibExplosionEffect=0.100f

	PS_GibExplosionEffect=ParticleSystem'Envy_Effects.Particles.P_VH_Gib_Explosion'
	PS_GibTrailEffect=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1'

	LoopedSound=SoundCue'A_Vehicle_Generic.Fire.VehicleDerbisLoop_Cue'

	HitSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleImpact_MetalSmallCue'

	//MITV_DecalTemplate=MaterialInstanceTimeVarying'VH_All.Decals.MITV_VehicleDebrisImpactDecal'
}
