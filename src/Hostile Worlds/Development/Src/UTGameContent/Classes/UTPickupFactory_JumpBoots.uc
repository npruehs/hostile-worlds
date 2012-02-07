/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPickupFactory_JumpBoots extends UTPowerupPickupFactory;

defaultproperties
{
	InventoryType=class'UTGameContent.UTJumpBoots'
	bIsSuperItem=FALSE

    PickupStatName=PICKUPS_JUMPBOOTS

	BaseBrightEmissive=(R=25.0,G=25.0,B=1.0)
	BaseDimEmissive=(R=1.0,G=1.0,B=0.01)
	PivotTranslation=(Y=20.0)

	Begin Object Class=AudioComponent Name=BootsReady
		SoundCue=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_GroundLoopCue'
	End Object
	PickupReadySound=BootsReady
	Components.Add(BootsReady)
	RespawnSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_JumpBoots_SpawnCue'

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheJumpBoots'

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
