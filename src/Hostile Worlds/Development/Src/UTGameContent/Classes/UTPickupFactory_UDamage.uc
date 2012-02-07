/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPickupFactory_UDamage extends UTPowerupPickupFactory;


simulated event InitPickupMeshEffects()
{
	Super.InitPickupMeshEffects();

	// Create a material instance for the pickup
	if (bDoVisibilityFadeIn && MeshComponent(PickupMesh) != None)
	{
		MIC_VisibilitySecondMaterial = MeshComponent(PickupMesh).CreateAndSetMaterialInstanceConstant(1);
		MIC_VisibilitySecondMaterial.SetScalarParameterValue(VisibilityParamName, bIsSuperItem ? 1.f : 0.f);
	}
}


simulated function SetResOut()
{
	Super.SetResOut();

	if (bDoVisibilityFadeIn && MIC_VisibilitySecondMaterial != None)
	{
		MIC_VisibilitySecondMaterial.SetScalarParameterValue(VisibilityParamName, 1.f);
	}
}



defaultproperties
{
	InventoryType=class'UTUDamage'

    PickupStatName=PICKUPS_UDAMAGE

	BaseBrightEmissive=(R=4.0,G=1.0,B=10.0)
	BaseDimEmissive=(R=1.0,G=0.25,B=2.5)

	RespawnSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_SpawnCue'

	Begin Object Class=UTParticleSystemComponent Name=DamageParticles
		Template=ParticleSystem'Pickups.UDamage.Effects.P_Pickups_UDamage_Idle'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
		Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	SpinningParticleEffects=DamageParticles
	Components.Add(DamageParticles)

	Begin Object Class=AudioComponent Name=DamageReady
		SoundCue=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_GroundLoopCue'
	End Object
	PickupReadySound=DamageReady
	Components.Add(DamageReady)

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheUdamage'

	Begin Object Name=BaseMeshComp
		StaticMesh=StaticMesh'Pickups.Base_Powerup.Mesh.S_Pickups_Base_Powerup01'
		Translation=(X=0.0,Y=0.0,Z=-44.0)
	End Object


 	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Pickups.Base_Powerup.Mesh.S_Pickups_Base_Powerup01_Disc'
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=PickupLightEnvironment

		Translation=(X=0.0,Y=0.0,Z=-40.0)
		CollideActors=false
		MaxDrawDistance=7000
	End Object
	Spinner=StaticMeshComponent1
 	Components.Add(StaticMeshComponent1)
}

