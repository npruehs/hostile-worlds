/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


/** superclass of damagetypes that cause hit players to burst into flame */
class UTDmgType_Burning extends UTDamageType
	HideDropDown
	abstract;

/** SpawnHitEffect()
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UTEmit_BodyFlame BF;
	local vector EffectLocation;
	local TraceHitInfo MyHitInfo;
	local UTPawn UTP;

	UTP = UTPawn(P);
	if (UTP != None && !UTP.bGibbed && Damage > FMin(95, 0.19 * P.HealthMax))
	{
		EffectLocation = HitLocation;

		if ( BoneName == '' )
		{
			MyHitInfo.HitComponent = P.Mesh;
			P.CheckHitInfo( MyHitInfo, P.Mesh, Momentum, EffectLocation );
			BoneName = MyHitInfo.BoneName;
			if ( (BoneName == '') && (UTPawn(P) != None) )
			{
				EffectLocation = 0.5 * (HitLocation + P.Location);
				EffectLocation.Z = HitLocation.Z;
			}
		}

		BF = P.Spawn(class'UTEmit_BodyFlame',P,, EffectLocation, rotator(Momentum));
		BF.AttachTo(P, BoneName);
		BF.LifeSpan = GetHitEffectDuration(P, Damage);
	}
}

static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return (P.Health <= 0) ? 5.0 : 5.0 * FClamp(Damage * 0.01, 0.5, 1.0);
}

defaultproperties
{
	GibTrail=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1'
}
