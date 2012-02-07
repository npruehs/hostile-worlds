/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//=============================
// UTJumppad - bounces players/bots up
//
//=============================
class UTJumpPad extends UDKJumpPad
	placeable;

defaultproperties
{
	JumpSound=SoundCue'A_Gameplay.JumpPad.Cue.A_Gameplay_JumpPad_Activate_Cue'

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'Pickups.jump_pad.S_Pickups_Jump_Pad'
		CollideActors=false
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
		Translation=(X=0.0,Y=0.0,Z=-47.0)

		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=JumpPadLightEnvironment
	End Object
 	Components.Add(StaticMeshComponent0)

	Begin Object Class=UTParticleSystemComponent Name=ParticleSystemComponent1
		Translation=(X=0.0,Y=0.0,Z=-35.0)
		Template=particleSystem'Pickups.jump_pad.P_Pickups_Jump_Pad_FX'
		bAutoActivate=true
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(ParticleSystemComponent1)

	Begin Object Class=AudioComponent Name=AmbientSound
		SoundCue=SoundCue'A_Gameplay.JumpPad.JumpPad_Ambient01Cue'
		bAutoPlay=true
		bUseOwnerLocation=true
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	JumpAmbientSound=AmbientSound
	Components.Add(AmbientSound)
}
