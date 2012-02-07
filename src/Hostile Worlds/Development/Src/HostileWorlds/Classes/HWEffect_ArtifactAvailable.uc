// ============================================================================
// HWEffect_ArtifactAvailable
// Allows showing a particle system for available artifacts.
//
// Author:  Marcel Koehler
// Date:    2010/12/05
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWEffect_ArtifactAvailable extends HWEffect;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	SetDrawScale(0.3);
}

DefaultProperties
{
	Begin Object Class=ParticleSystemComponent Name=PS
		Template=ParticleSystem'P_general.ArtifactSparks'
		bAutoActivate=false;
	End Object
	Components.Add(PS)
	ParticleSystem=PS
}
