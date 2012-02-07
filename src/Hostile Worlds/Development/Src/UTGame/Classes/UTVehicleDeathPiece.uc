/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleDeathPiece extends UTGib_Vehicle
	notplaceable;


var ParticleSystemComponent PSC;

/** We need to skip the UTGib_Vehicle PreBeginPlay because UTGib_Vehicle tries to ChooseGib which we don't want to do **/
simulated event PreBeginPlay()
{
	Super(Actor).PreBeginPlay();
}


defaultproperties
{
	Begin Object Class=UTGibStaticMeshComponent Name=VehicleGibStaticMeshComp
		BlockActors=false
		CollideActors=true
		BlockRigidBody=true
		CastShadow=false
		bCastDynamicShadow=false
		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=1.0
		bUseCompartment=FALSE
		RBCollideWithChannels=(Default=true,BlockingVolume=TRUE,Pawn=true,Vehicle=true,GameplayPhysics=true,EffectPhysics=true)
		LightEnvironment=GibLightEnvironmentComp
	End Object
	CollisionComponent=VehicleGibStaticMeshComp
	GibMeshComp=VehicleGibStaticMeshComp
	Components.Add(VehicleGibStaticMeshComp);

	Begin Object Class=ParticleSystemComponent Name=Particles
		Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SpecialCase_1_Attach'
		bAutoActivate=true
	End Object
	PSC=Particles
	Components.Add(Particles)

	Physics=PHYS_RigidBody
	TickGroup=TG_PostAsyncWork
	RemoteRole=ROLE_None

	Lifespan=10.0
}