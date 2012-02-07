/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTEmit_VehicleHit extends UTEmit_HitEffect;

defaultproperties
{
	Begin Object Name=ParticleSystemComponent0
		bOwnerNoSee=true
		Template=ParticleSystem'FX_VehicleExplosions.Effects.PS_Vehicle_DamageImpact'
	End Object
	ParticleSystemComponent=ParticleSystemComponent0
}
