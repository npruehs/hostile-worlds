/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPickupFactory_SuperHealth extends UTHealthPickupFactory;


var ParticleSystemComponent Crackle; // the crackling lightning effect that surrounds the keg on spawn

simulated function RespawnEffect()
{
	super.RespawnEffect();
	Crackle.SetActive(true);
}

simulated function SetPickupHidden()
{
	Glow.SetFloatParameter('LightStrength',0.0f);
	Super.SetPickupHidden();
}

simulated function SetPickupVisible()
{
	Super.SetPickupVisible();
	Glow.SetFloatParameter('LightStrength', 1.0f);
}

defaultproperties
{
	bSuperHeal=true
	bPredictRespawns=true
	bIsSuperItem=true
	RespawnTime=60.000000
	MaxDesireability=2.000000
	HealingAmount=100
	PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Super_Cue'

	Begin Object Name=BaseMeshComp
		StaticMesh=StaticMesh'Pickups.Health_Large.Mesh.S_Pickups_Base_Health_Large'
		Translation=(Z=-44)
		Rotation=(Yaw=16384)
		Scale=0.8
	End Object

	Begin Object Name=HealthPickUpMesh
		StaticMesh=StaticMesh'Pickups.Health_Large.Mesh.S_Pickups_Health_Large_Keg'
		MaxDrawDistance=7000
		Materials(0)=Material'Pickups.Health_Large.Materials.M_Pickups_Health_Large_Keg'
	End Object

	Begin Object Class=UTParticleSystemComponent Name=ParticleGlow
		Template=ParticleSystem'Pickups.Health_Large.Effects.P_Pickups_Base_Health_Glow'
		Translation=(Z=-50.0)
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(ParticleGlow)
	Glow=ParticleGlow

	Begin Object Class=UTParticleSystemComponent Name=ParticleCrackle
		Template=ParticleSystem'Pickups.Health_Large.Effects.P_Pickups_Base_Health_Spawn'
		Translation=(Z=-50.0)
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(ParticleCrackle)
	Crackle=ParticleCrackle

	YawRotationRate=16384
	bRotatingPickup=true

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheSuperHealth'
}
