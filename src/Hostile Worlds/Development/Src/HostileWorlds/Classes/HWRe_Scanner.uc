// ============================================================================
// HWRe_Scanner
// A scan reinforcements unit of Hostile Worlds.
//
// Author:  Marcel Koehler 
// Date:    2011/04/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWRe_Scanner extends HWReinforcement;

/** The particle system to be shown while this unit is active. */
var ParticleSystemComponent PscActive;


function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	super.Initialize(TheMap, A);
	
	bBlinded = true;
	Activate();
}

simulated function bool ShowOnMiniMap()
{
	return false;
}

simulated function bool Select(HWPlayerController SelectingPlayer, optional bool bAddToList = true)
{
	return false;
}

simulated function Show()
{	
}

simulated function Hide()
{
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super(Pawn).TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

simulated function OnOwningPlayerRIChanged()
{
	if(OwningPlayerRI != none)
	{
		Activate();
	}
}

/** Activates the particle system corresponding to the team. */
simulated function Activate()
{
	PscActive = new(self) class'ParticleSystemComponent';  // move this to the object pool once it can support attached to bone/socket and relative translation/rotation
	PscActive.SetTemplate(ActivatedTemplateTeam1);
	PscActive.ActivateSystem(true);

	AttachComponent(PscActive);
}

DefaultProperties
{
	AnimDurationDeath=0.1f

	ActivatedTemplateTeam1=ParticleSystem'FX_Abilities.P_Ability_Scan'

	// Workaround to show the pawn's visual assets
	Components.Remove(Sprite)

	CollisionType=COLLIDE_NoCollision
	bCollideActors=false
	bBlockActors=false
	bCloaked=true
	bShowHealthbar=false
	bImmuneToKnockbacks=true
}
