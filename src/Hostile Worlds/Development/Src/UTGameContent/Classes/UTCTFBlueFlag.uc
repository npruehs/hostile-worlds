/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTCTFBlueFlag extends UTCTFFlag;

var ParticleSystemComponent BlueGlow;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SkelMesh.AttachComponentToSocket(BlueGlow,'PoleEmitter');
}


defaultproperties
{
	MessageClass=class'UTCTFMessage'

	Begin Object Class=ParticleSystemComponent Name=BlueParticle
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Template=ParticleSystem'CTF_Flag_IronGuard.Effects.P_CTF_Flag_IronGuard_Idle_Blue'
		bAcceptsLights=false
		bAutoActivate=true
	End Object
	BlueGlow=BlueParticle

	Begin Object Class=ParticleSystemComponent Name=ScoreEffect
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Template=ParticleSystem'Pickups.Flag.Effects.P_Flagbase_FlagCaptured_Blue'
		bAcceptsLights=false
		bAutoActivate=false
	End Object
	SuccessfulCaptureSystem=ScoreEffect
	Components.Add(ScoreEffect)

	Begin Object Name=TheFlagSkelMesh
		SkeletalMesh=SkeletalMesh'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard'
		PhysicsAsset=PhysicsAsset'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard_Physics'
		Materials(1)=Material'CTF_Flag_IronGuard.Materials.M_CTF_Flag_IG_Flagblue'
	End Object

	Begin Object name=FlagLightComponent
		LightColor=(R=64,G=128,B=255)
	End Object

	RespawnEffect=ParticleSystem'CTF_Flag_IronGuard.Effects.P_CTF_Flag_IronGuard_Spawn_Blue'

	ReturnedSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagReturn_Cue'
	DroppedSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagDropped01Cue'
	PickupSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagPickedUp01Cue'
}
