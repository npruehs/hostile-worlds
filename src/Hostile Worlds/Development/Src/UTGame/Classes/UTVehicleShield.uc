/**
 * shield that vehicles can attach to themselves and activate/deactivate 
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
 
class UTVehicleShield extends UDKWeaponShield
	abstract;

var SoundCue ActivatedSound, DeactivatedSound;
var AudioComponent AmbientComponent;
var ParticleSystemComponent ShieldEffectComponent;
var float ShieldActivatedTime;
var bool bFullyActive;

/** turns the shield on or off */
function SetActive(bool bNowActive)
{
	if (bHidden != !bNowActive)
	{
		SetCollision(bNowActive, false);
		SetHidden(!bNowActive);
		// need to unhide the shield effect separately since it might be attached to the vehicle instead of us
		if (ShieldEffectComponent != None)
		{
			ShieldEffectComponent.SetHidden(bHidden);
			if (bHidden)
			{
				ShieldEffectComponent.DeactivateSystem();
				ShieldEffectComponent.KillParticlesForced();
			}
			else
			{
				ShieldEffectComponent.ActivateSystem();
			}
		}
		if (bNowActive)
		{
			PlaySound(ActivatedSound, false);
			AmbientComponent.Play();
			SetTimer(ShieldActivatedTime, false, 'ShieldFullyOnline');
		}
		else
		{
			PlaySound(DeactivatedSound, false);
			AmbientComponent.Stop();
			bFullyActive = false;
		}
	}
}

simulated function ShieldFullyOnline()
{
	bFullyActive = true;
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// pass on damage events to our owner
	HitInfo.HitComponent = CollisionComponent;
	Base.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

defaultproperties
{
	bHidden=true
	bCollideActors=false
	bHardAttach=true
	ShieldActivatedTime=1.8f
	bFullyActive=false
}
