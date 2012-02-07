/*=============================================================================
	PhysXDestructiblePart.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXDestructiblePart extends Actor
	native(Mesh)
	notplaceable;

var	transient	int								FirstChunk;
var	transient	int								NumChunks;

var				PhysXDestructibleStructure		Structure;	// Copied from DestructibleActor->Structure
var				PhysXDestructibleActor			DestructibleActor;	// "Parent" actor
var				PhysXDestructibleAsset			DestructibleAsset;	// Static data

var				LightEnvironmentComponent		LightEnvironment;
var				array<SkeletalMeshComponent>	SkeletalMeshComponents;

var				array<byte>						NumChunksRemaining;	// Count for each SkeletalMeshComponent
var				byte							NumMeshesRemaining;	// Number of attached skeletal mesh components

cpptext
{
	FBox	GetSkeletalMeshComponentsBoundingBox();

	// AActor interface
	virtual void InitRBPhys();
	virtual void TermRBPhys( FRBPhysScene* Scene );
	virtual void SyncActorToRBPhysics();
	virtual void OnRigidBodyCollision( const FRigidBodyCollisionInfo& MyInfo, const FRigidBodyCollisionInfo& OtherInfo, const FCollisionImpactData& RigidCollisionData );
}

native event TakeDamage
(
	int						Damage,
	Controller				EventInstigator,
	vector					HitLocation,
	vector					Momentum,
	class<DamageType>		DamageType,
	optional TraceHitInfo	HitInfo,
	optional Actor			DamageCauser
);

simulated native function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
);

defaultproperties
{
	TickGroup=TG_PostAsyncWork

	bStatic=false
	bMovable=true
	bNoDelete=false

	bNetInitialRotation=true
	Physics=PHYS_None
	bEdShouldSnap=true
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=false
	bCollideWorld=false
	bProjTarget=true
	bNoEncroachCheck=TRUE

	bAlwaysRelevant=true
	bSkipActorPropertyReplication=false
	bUpdateSimulatedPosition=true
	bReplicateMovement=true
	RemoteRole=ROLE_SimulatedProxy
	bReplicateRigidBodyLocation=true

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bEnabled = false
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	SupportedEvents.Add(class'SeqEvent_ConstraintBroken')
	SupportedEvents.Add(class'SeqEvent_RigidBodyCollision')
}
