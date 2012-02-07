/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFRedFlag extends UTCTFFlag;

var ParticleSystemComponent RedGlow;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SkelMesh.AttachComponentToSocket(RedGlow,'PoleEmitter');
}

defaultproperties
{
	MessageClass=class'UTCTFMessage'

	Begin Object Class=ParticleSystemComponent Name=RedParticle
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Template=ParticleSystem'CTF_Flag_IronGuard.Effects.P_CTF_Flag_IronGuard_Idle_Red'
		bAcceptsLights=false
		bAutoActivate=true
	End Object
	RedGlow=RedParticle

	Begin Object Class=ParticleSystemComponent Name=ScoreEffect
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Template=ParticleSystem'Pickups.Flag.Effects.P_Flagbase_FlagCaptured_Red'
		bAcceptsLights=false
		bAutoActivate=false
	End Object
	Components.Add(ScoreEffect)
	SuccessfulCaptureSystem=ScoreEffect

	Begin Object name=FlagLightComponent
		LightColor=(R=255,G=64,B=0)
	End Object

	Begin Object Name=TheFlagSkelMesh
		SkeletalMesh=SkeletalMesh'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard'
		PhysicsAsset=PhysicsAsset'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard_Physics'
	End Object

	RespawnEffect=ParticleSystem'CTF_Flag_IronGuard.Effects.P_CTF_Flag_IronGuard_Spawn_Red'

	ReturnedSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagReturn_Cue'
	DroppedSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagDropped01Cue'
	PickupSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagPickedUp01Cue'
}
