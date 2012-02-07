/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//-----------------------------------------------------------
//  When out in the world, this can be used to decoy an avril.
//-----------------------------------------------------------
class UTDecoy extends UTProjectile;

/** Max distance a missile can be to be affected */
var float DecoyRange;
/** Protect this vehicle */
var UTVehicle_Cicada_Content ProtectedTarget;

function bool CheckRange(Actor Aggressor)
{
	return VSize(Aggressor.Location - Location) <= DecoyRange;
}

simulated event Destroyed()
{
	local int i;

	Super.Destroyed();

	if (ProtectedTarget != None)
	{
		// Remove it from the Dual Attack craft's array
		for (i = 0; i < ProtectedTarget.Decoys.Length; i++)
		{
			if (ProtectedTarget.Decoys[i] == self)
			{
				ProtectedTarget.Decoys.Remove(i, 1);
				return;
			}
		}
	}
}


simulated function Landed(vector HitNormal, Actor FloorActor)
{
	Super.Landed(HitNormal, FloorActor);
	Destroy();
}

defaultproperties
{
	LifeSpan=5.0
	DecoyRange=2048
	Speed=1000
	MaxSpeed=1500
	MomentumTransfer=10000
	Damage=50.0
	DamageRadius=250.0
	RemoteRole=ROLE_SimulatedProxy
	bBounce=true
	bNetTemporary=True
	Physics=PHYS_Falling

	ProjFlightTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_DecoyFlare'
	ProjExplosionTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_Decoy_Explo'
}
