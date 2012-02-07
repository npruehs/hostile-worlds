/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponLocker_Content extends UTWeaponLocker;


defaultproperties
{
	Begin Object Name=BaseMeshComp
	    StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Weapon_Locker'
		BlockNonZeroExtent=false
		BlockZeroExtent=true
		BlockActors=true
		BlockRigidBody=true
		CollideActors=true
		bForceDirectLightMap=TRUE
		RBChannel=RBCC_Nothing
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		Translation=(X=0.0,Y=0.0,Z=-50.0)
		MaxDrawDistance=8000
		//LightEnvironment=PickupLightEnvironment
	End Object

	Begin Object Class=UTParticleSystemComponent Name=ParticleSystem0
	Translation=(X=0.0,Y=0.0,Z=-50.0)
 		MaxDrawDistance=8000
 		SecondsBeforeInactive=1.0f
 	End Object
 	AmbientEffect=ParticleSystem0
 	Components.Add(ParticleSystem0)

	Begin Object Class=UTParticleSystemComponent Name=ParticleSystem1
 		Template=ParticleSystem'GP_Onslaught.Effects.P_Ons_WeaponLocker_Core_Active'
 		Translation=(X=0.0,Y=0.0,Z=-50.0)
 		MaxDrawDistance=1000
 		SecondsBeforeInactive=1.0f
 	End Object
 	ProximityEffect=ParticleSystem1
 	Components.Add(ParticleSystem1)

 	ActiveEffectTemplate=ParticleSystem'GP_Onslaught.Effects.P_Ons_WeaponLocker_Core_Equipped'
 	InactiveEffectTemplate=ParticleSystem'GP_Onslaught.Effects.P_Ons_WeaponLocker_Core_Neutral'
 	WeaponSpawnEffectTemplate=ParticleSystem'GP_Onslaught.Effects.P_Ons_WeaponLocker_Weapon_Spawn'
}

