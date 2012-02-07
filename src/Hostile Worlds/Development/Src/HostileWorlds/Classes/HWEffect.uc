// ============================================================================
// HWEffect
// Abstract class for all HostileWorlds effects.
// This class provides functions to activate and deactivate the used ParticleSystem.
// The ParticleSystem itself must be created by the subclass in DefaultProperties.
//
// Author:  Marcel Koehler
// Date:    2010/12/05
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWEffect extends Actor
	abstract;

/** The particle system used to show the visual feedback. */
var ParticleSystemComponent ParticleSystem;

/** Shows visual feedback at the current position of this actor. */
function Show() 
{
	ParticleSystem.ActivateSystem();
	ParticleSystem.SetHidden(false);
}

/** Hides the particle system associated with this actor. */
function Hide() 
{
	ParticleSystem.SetHidden(true);
	ParticleSystem.DeactivateSystem();
}

DefaultProperties
{
}