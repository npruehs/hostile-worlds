/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTGameCrowdAgent extends GameCrowdAgentSkeletal;

/** Stop agent moving and pay death anim */
function PlayDeath(vector KillMomentum)
{
	if ( WorldInfo.TimeSeconds - LastRenderTime > 1 )
	{
		LifeSpan = 0.01;
	}
	else
	{
		SkeletalMeshComponent.SetHasPhysicsAssetInstance(true);
		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		SkeletalMeshComponent.MinDistFactorForKinematicUpdate = 0.f;
		SkeletalMeshComponent.ForceSkelUpdate();
		SkeletalMeshComponent.UpdateRBBonesFromSpaceBases(TRUE, TRUE);

		CollisionComponent = SkeletalMeshComponent;
		SetTickGroup(TG_PostAsyncWork);
		SkeletalMeshComponent.SetTickGroup(TG_PostAsyncWork);
		SkeletalMeshComponent.PhysicsWeight = 1.0;
		SetPhysics(PHYS_RigidBody);
		SkeletalMeshComponent.SetBlockRigidBody(true);
		SkeletalMeshComponent.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		SkeletalMeshComponent.SetRBChannel(RBCC_Pawn);
		SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
		SkeletalMeshComponent.SetTraceBlocking(false,true); 

		if( KillMomentum != vect(0,0,0) )
		{
			SkeletalMeshComponent.AddImpulse(0.5*KillMomentum, Location, '', false);
		}
		LifeSpan = DeadBodyDuration;
;
	}
}

defaultproperties
{
	Health=20
	bProjTarget=true
	
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'UTExampleCrowd.Mesh.SK_Crowd_Robot'
		AnimTreeTemplate=AnimTree'UTExampleCrowd.AnimTree.AT_CH_Crowd'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		Translation=(Z=-42.0)
		TickGroup=TG_DuringAsyncWork
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics''
	End Object
	
	RotateToTargetSpeed=60000.0
	FollowPathStrength=600.0
	MaxWalkingSpeed=200.0
}

