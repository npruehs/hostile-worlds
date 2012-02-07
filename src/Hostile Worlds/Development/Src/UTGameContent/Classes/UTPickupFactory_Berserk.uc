/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPickupFactory_Berserk extends UTPowerupPickupFactory;

defaultproperties
{
	InventoryType=class'UTBerserk'

    PickupStatName=PICKUPS_BERSERK

	BaseBrightEmissive=(R=50.0,G=1.0)
	BaseDimEmissive=(R=5.0,G=0.1)

	RespawnSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Berzerk_SpawnCue'

	Begin Object Class=UTParticleSystemComponent Name=BerserkParticles
		Template=ParticleSystem'Pickups.Berserk.Effects.P_Pickups_Berserk_Idle'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
		Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	SpinningParticleEffects=BerserkParticles
	Components.Add(BerserkParticles)

	Begin Object Class=AudioComponent Name=BerserkReady
		SoundCue=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Berzerk_GroundLoopCue'
	End Object
	PickupReadySound=BerserkReady
	Components.Add(BerserkReady)

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheBerserk'

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

