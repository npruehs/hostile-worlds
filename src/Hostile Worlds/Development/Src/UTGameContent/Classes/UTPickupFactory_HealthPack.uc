/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPickupFactory_HealthPack extends UTHealthPickupFactory;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Glow.SetFloatParameter('LightStrength',1.0f);
}

defaultproperties
{
	bPredictRespawns=false
	bIsSuperItem=false
	RespawnTime=30.000000
	MaxDesireability=0.700000
	HealingAmount=25
	PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Medium_Cue'

	bRotatingPickup=true
	YawRotationRate=16384

	bFloatingPickup=true
	bRandomStart=true
	BobSpeed=1.0
	BobOffset=5.0

	Begin Object Name=BaseMeshComp
		StaticMesh=StaticMesh'Pickups.Health_Large.Mesh.S_Pickups_Base_Health_Large'
		Translation=(Z=-44)
		Scale=0.8
	End Object

	Begin Object Name=HealthPickUpMesh
		StaticMesh=StaticMesh'Pickups.Health_Medium.Mesh.S_Pickups_Health_Medium'
		MaxDrawDistance=7000
	End Object


	Begin Object Class=UTParticleSystemComponent Name=Glowcomp
	    Template=ParticleSystem'Pickups.Health_Large.Effects.P_Pickups_Base_Health_Glow'
		Translation=(Z=-50.0)
		SecondsBeforeInactive=1.0f
	End Object
	Glow=Glowcomp
	Components.Add(Glowcomp)
}
