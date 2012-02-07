/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTCTFBase_Content extends UTCTFBase
	abstract;


defaultproperties
{
	bStatic=false
	bTickIsDisabled=false
	bHidden=false

	bAlwaysRelevant=true
	NetUpdateFrequency=1
	RemoteRole=ROLE_SimulatedProxy
	BaseExitTime=+8.0
	bHasSensor=true

	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	GoodSprite=None
	BadSprite=None

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0060.000000
		CollisionHeight=+0060.000000
	End Object

	// define here as lot of sub classes which have moving parts will utilize this
	Begin Object Class=DynamicLightEnvironmentComponent Name=FlagBaseLightEnvironment
	    bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(FlagBaseLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'Pickups.Base_Flag.Mesh.S_Pickups_Base_Flag'
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=TRUE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=FlagBaseLightEnvironment

		CollideActors=false
		MaxDrawDistance=7000
		Translation=(X=0.0,Y=0.0,Z=-64.0)
	End Object
	FlagBaseMesh=StaticMeshComponent0
 	Components.Add(StaticMeshComponent0)

 	Begin Object Class=AudioComponent Name=TakenSoundComponent
 		SoundCue=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagAlarm_Cue'
 	End Object
 	TakenSound=TakenSoundComponent

	//Mat_BaseFlagMaterial=Material'Pickups.Base_Flag.Materials.M_Pickups_Base_Flag'

	CTFAnnouncerMessagesClass=class'UTCTFMessage'

	IconCoords=(U=377,V=438,UL=45,VL=44)

}



