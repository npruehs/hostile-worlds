/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** UT version of the teleporter with custom effects */
class UTTeleporter extends UDKTeleporterBase
	hidecategories(SceneCapture);

/** component that plays the render-to-texture portal effect */
var ParticleSystemComponent PortalEffect;

/**
 * The base of the teleporter.  We hold a reference to it so that
 * it gets serialized to disk, and so we can statically light it.
 */
var() StaticMeshComponent TeleporterBaseMesh;

simulated function InitializePortalEffect(Actor Dest)
{
	Super.InitializePortalEffect(Dest);
	if (Dest != None)
	{
		SceneCapture2DComponent(PortalCaptureComponent).SetCaptureParameters(TextureTarget);
		SceneCapture2DComponent(PortalCaptureComponent).SetView(Dest.Location + vector(Dest.Rotation) * 15.0, Dest.Rotation);
		PortalEffect.SetMaterialParameter('Portal', PortalMaterialInstance);
	}
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=AudioComponent Name=AmbientSound
		SoundCue=SoundCue'A_Gameplay.Portal.Portal_Loop01Cue'
		bAutoPlay=true
		bUseOwnerLocation=true
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	Components.Add(AmbientSound)

	TeleportingSound=SoundCue'A_Gameplay.Portal.Portal_WalkThrough01Cue'

	Begin Object Class=SceneCapture2DComponent Name=SceneCapture2DComponent0
		FrameRate=15.0
		bSkipUpdateIfOwnerOccluded=true
		MaxUpdateDist=1000.0
		MaxStreamingUpdateDist=1000.0
		bUpdateMatrices=false
		NearPlane=10
		FarPlane=-1
	End Object
	PortalCaptureComponent=SceneCapture2DComponent0

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'Pickups.Base_Powerup.Mesh.S_Pickups_Base_Powerup01'
		Translation=(X=0.0,Y=0.0,Z=-30.0)
		CollideActors=true
		BlockActors=true
		CastShadow=true
		bCastDynamicShadow=false
		bForceDirectLightMap=true
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		Scale=1.25
		BlockNonZeroExtent=false
	End Object
 	Components.Add(StaticMeshComponent0)
 	TeleporterBaseMesh=StaticMeshComponent0

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
		Template=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Base_Idle'
	End Object
	Components.Add(ParticleSystemComponent0)

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
		Template=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Idle'
	End Object
	Components.Add(ParticleSystemComponent1)
	PortalEffect=ParticleSystemComponent1
	PortalMaterial=MaterialInterface'Pickups.Base_Teleporter.Material.M_T_Pickups_Teleporter_Portal_Destination'
}
