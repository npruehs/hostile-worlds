/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class PhysAnimTestActor extends Actor
	placeable;

/** Names of bones that make up the 'lower half' of this actor. */
var()	array<name>		LowerBoneNames;
var()	array<name>		LinearBoneSpringNames;
var()	array<name>		AngularBoneSpringNames;

enum EPATAState
{
	PATA_FixedAll,
	PATA_FixedLower,
	PATA_MotorRagdoll,
	PATA_Floppy,
	PATA_Recover
};

var()	SkeletalMeshComponent			SkeletalMeshComponent;

var EPATAState			CurrentState;

var		bool				bBlendToGetUp;
var		bool				bBlendingBack;
var		bool				bRampingDownMotors;
var		bool				bNextPokeKnocksDown;

var		float				GetUpBlendStartTime;
var()	float				GetUpBlendTime;
var()	float				GetUpToIdleTime;
var()	float				ActorOriginHeight;

var()	float				PokePauseTime;
var()	float				PokeBlendTime;
var		float				BlendBackStartTime;

var		float				MotorDownStartTime;
var()	float				MotorDownTime;
var()	float				MotorDownAnimTime;
var()	float				BlendStaggerAnimTime;
var()	float				StaggerSpeedAdj;
var()	float				StaggerVel;
var		vector				MoveDir;

var()	float				AngularHipDriveScale;
var()	float				StaggerMuscleScale;

var	AnimNodeBlend		BlendNode;
var AnimNodeSequence	GetUpNode;
var AnimNodeSequence	RunNode;
var	RB_BodyInstance		HipBody;

/** When game begins, get anim playing, and go into FixedLower state. */
function PostBeginPlay()
{
	BlendNode	= AnimNodeBlend(SkeletalMeshComponent.FindAnimNode('Blend'));
	GetUpNode	= AnimNodeSequence(SkeletalMeshComponent.FindAnimNode('GetUp'));
	RunNode		= AnimNodeSequence(SkeletalMeshComponent.FindAnimNode('Run'));

	// Find the hip body instance
	HipBody		= SkeletalMeshComponent.FindBodyInstanceNamed('b_Hips');

	SetPATAState(PATA_FixedAll);
}

function bool PrePokeActor(vector PokeDir)
{
	local float StaggerRate;

	if(bNextPokeKnocksDown && CurrentState == PATA_FixedAll)
	{
		bNextPokeKnocksDown = false;
		bRampingDownMotors = true;
		MotorDownStartTime = WorldInfo.TimeSeconds;

		SetPATAState(PATA_FixedLower);

		// Set the other node to play the stagger animation, and start blending to it.
		GetUpNode.SetAnim('Stumble_Bwd');

		StaggerRate = 1.f + (StaggerSpeedAdj * (0.5 - FRand()));
		GetUpNode.PlayAnim(true, StaggerRate, FRand() * GetUpNode.AnimSeq.SequenceLength);
		BlendNode.SetBlendTarget(1, BlendStaggerAnimTime);

		MoveDir = PokeDir;
		MoveDir.Z = 0;
	}
	else
	{
		// If we are all locked, or we have not actually started blending back yet, reset counter and be in fixed-lower mode.
		if(CurrentState == PATA_FixedAll || WorldInfo.TimeSeconds < BlendBackStartTime)
		{
			SetPATAState(PATA_FixedLower);

			bBlendingBack = true;
			BlendBackStartTime = WorldInfo.TimeSeconds + PokePauseTime;
		}
	}

	return true;
}

function bool PreGrab()
{
	if(CurrentState == PATA_FixedLower)
	{
		return false;
	}

	if(CurrentState == PATA_FixedAll)
	{
		bNextPokeKnocksDown = true;

		SetPATAState(PATA_FixedLower);
	}

	return true;
}

function EndGrab()
{
	if(CurrentState == PATA_FixedLower)
	{
		bBlendingBack = true;
		BlendBackStartTime = WorldInfo.TimeSeconds;
	}
}

/** Function for changing what state we are in. */
function SetPATAState(EPATAState NewState)
{
	// Don't allow changing state while recovering from ragdoll.
	if(CurrentState == PATA_Recover)
	{
		return;
	}

	// Can only recover from floppy state.
	if(NewState == PATA_Recover && CurrentState != PATA_Floppy)
	{
		return;
	}

	if(NewState == PATA_FixedAll)
	{
		RunNode.bPlaying = true;
		SetPhysics(PHYS_Interpolating);
		SetBodiesFixed(true);
	}
	else if(NewState == PATA_FixedLower)
	{
		RunNode.bPlaying = true;
		SetPhysics(PHYS_Interpolating);
		SetLowerFixed();
		EnableMotors(true);
		SetBoneSprings(true);
	}
	else if(NewState == PATA_MotorRagdoll)
	{
		RunNode.bPlaying = true;
		SetPhysics(PHYS_RigidBody);
		SetBodiesFixed(false);
		EnableMotors(true);
		bBlendingBack = false;
		SetBoneSprings(false);
	}
	else if(NewState == PATA_Floppy)
	{
		RunNode.bPlaying = false;
		SetPhysics(PHYS_RigidBody);
		SetBodiesFixed(false);
		EnableMotors(false);
		bBlendingBack = false;
		SetBoneSprings(false);
		DetachAttachments();
	}
	else if(NewState == PATA_Recover)
	{
		RecoverFromRagdoll();
	}

	CurrentState = NewState;
}

/** Handler for SeqAct_SetPATAState Kismet action. */
function OnSetPATAState(SeqAct_SetPATAState Action)
{
	SetPATAState(Action.NewState);
}

/** Turn all motors on or off */
function EnableMotors(bool InEnabled)
{
	SkeletalMeshComponent.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(InEnabled, InEnabled);
}

/** Fix or unfix all bodies */
function SetBodiesFixed(bool InFixed)
{
	SkeletalMeshComponent.PhysicsAssetInstance.SetAllBodiesFixed(InFixed);
}

/** Util for determining if a bone is in the LowerBoneNames array. */
function bool IsLowerBodyName(name InName)
{
	local int i;
	for(i=0; i<LowerBoneNames.Length; i++)
	{
		if(LowerBoneNames[i] == InName)
		{
			return true;
		}
	}

	return false;
}

function DetachAttachments()
{
	local int i;
	local actor A;
	local array<Actor> TempAttachments;

	for(i=0; i<Attached.Length; i++)
	{
		TempAttachments[i] = Attached[i];
	}

	for(i=0; i<TempAttachments.Length; i++)
	{
		A = TempAttachments[i];
		if(A != None)
		{
			A.SetBase(None);
			A.SetPhysics(PHYS_RigidBody);
			A.CollisionComponent.SetBlockRigidBody(true);
		}
	}
}

/** Set lower half bones to fixed. */
function SetLowerFixed()
{
	local RB_BodyInstance BodyInst;
	local RB_BodySetup BodySetup;
	local int i;

	// Set some lower to kinematic, and other to free.
	for(i=0; i<SkeletalMeshComponent.PhysicsAsset.BodySetup.Length; i++)
	{
		BodyInst = SkeletalMeshComponent.PhysicsAssetInstance.Bodies[i];
		BodySetup = SkeletalMeshComponent.PhysicsAsset.BodySetup[i];

		if( IsLowerBodyName(BodySetup.BoneName) )
		{
			BodyInst.SetFixed(true);
		}
		else
		{
			BodyInst.SetFixed(false);
		}
	}
}

function bool IsLinearBoneSpringName(name InName)
{
	local int i;
	for(i=0; i<LinearBoneSpringNames.Length; i++)
	{
		if(LinearBoneSpringNames[i] == InName)
		{
			return true;
		}
	}

	return false;
}

function bool IsAngularBoneSpringName(name InName)
{
	local int i;
	for(i=0; i<AngularBoneSpringNames.Length; i++)
	{
		if(AngularBoneSpringNames[i] == InName)
		{
			return true;
		}
	}

	return false;
}

function SetBoneSprings(bool bEnabled)
{
	local RB_BodyInstance BodyInst;
	local RB_BodySetup BodySetup;
	local int i, BoneIndex;
	local bool bEnableLinear;
	local bool bEnableAngular;
	local matrix BoneMatrix;

	for(i=0; i<SkeletalMeshComponent.PhysicsAsset.BodySetup.Length; i++)
	{
		BodyInst = SkeletalMeshComponent.PhysicsAssetInstance.Bodies[i];
		BodySetup = SkeletalMeshComponent.PhysicsAsset.BodySetup[i];

		bEnableLinear = IsLinearBoneSpringName(BodySetup.BoneName);
		bEnableAngular = IsAngularBoneSpringName(BodySetup.BoneName);

		if(bEnableLinear || bEnableAngular)
		{
			BoneIndex = SkeletalMeshComponent.MatchRefBone(BodySetup.BoneName);
			BoneMatrix = SkeletalMeshComponent.GetBoneMatrix(BoneIndex);

			BodyInst.EnableBoneSpring(bEnabled && bEnableLinear, bEnabled && bEnableAngular, BoneMatrix);
		}
	}
}

/** Enter recovery from ragdoll mode. */
function RecoverFromRagdoll()
{
	local vector HitLocation, HitNormal, TraceStart, TraceEnd;
	local vector HeightVec;
	local rotator NewRotation;
	local bool GetUpFromBack;

	// Stop updating the physics bones to match the animation
	SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = false;

	// Move Actor origin so it feet will be on the ground.
	HeightVec = vect(0,0,1) * ActorOriginHeight;
	TraceStart = Location + HeightVec;
	TraceEnd = Location - HeightVec;


	if (Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, vect(20,20,0) + HeightVec) != None)
	{
		`Log("Location Adjusted");
		SetLocation(HitLocation);
	}

	// This will fix all bones, and stop Actor location being changed.
	SetPhysics(PHYS_Interpolating);

	GetUpFromBack = (SkeletalMeshComponent.GetBoneAxis('b_head', AXIS_Y).Z > 0.0);

	// force rotation to match the body's direction so the blend to the getup animation looks more natural
	NewRotation = Rotation;
	NewRotation.Yaw = rotator(SkeletalMeshComponent.GetBoneAxis('b_Hips', AXIS_X)).Yaw;
	// flip it around if the head is facing upwards, since the animation for that makes the character
	// end up facing in the opposite direction that its body is pointing on the ground
	if (GetUpFromBack)
	{
		NewRotation.Yaw += 32768;
	}
	SetRotation(NewRotation);

	// Choose correct get-up animation and rewind get up animation to start
	if(GetUpFromBack)
	{
		GetUpNode.SetAnim('feigndeath_getup_back');
	}
	else
	{
		GetUpNode.SetAnim('feigndeath_getup_front');
	}
	GetUpNode.SetPosition(0.f, false);

	// Set blend to show the get up animation
	BlendNode.SetBlendTarget(1, 0.f);

	// Start changing PhysicsWeight from 1.f (showing ragdoll position) to 0.f (showing first frame of get up anim)
	bBlendToGetUp = true;
	GetUpBlendStartTime = WorldInfo.TimeSeconds;
}

/** Tick function */
function Tick(float DeltaSeconds)
{
	local float MotorScale;
	local int HipIndex;
	local matrix HipMatrix;

	Super.Tick(DeltaSeconds);

	if(bRampingDownMotors)
	{
		if(MotorDownStartTime + MotorDownAnimTime > WorldInfo.TimeSeconds)
		{
			// Pausing before blend - animate pawn packwards
			SetLocation( Location + (DeltaSeconds * StaggerVel * MoveDir) );
		}
		else if(MotorDownStartTime + MotorDownTime > WorldInfo.TimeSeconds)
		{
			// Need to change to motorised
			if(CurrentState != PATA_MotorRagdoll)
			{
				HipIndex = SkeletalMeshComponent.MatchRefBone('b_Hips');
				HipMatrix = SkeletalMeshComponent.GetBoneMatrix(HipIndex);
				SetPATAState(PATA_MotorRagdoll);
				SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = false;
				HipBody.SetBoneSpringParams(50.f, 1.f, AngularHipDriveScale * 50.f, 0.1f);
				HipBody.EnableBoneSpring(true, true, HipMatrix);
				SkeletalMeshComponent.SetRBLinearVelocity(MoveDir * StaggerVel, true);
			}

			MotorScale = 1.f - (WorldInfo.TimeSeconds - (MotorDownStartTime + MotorDownAnimTime)/(MotorDownTime - MotorDownAnimTime));
			MotorScale = MotorScale * MotorScale * MotorScale;
			SkeletalMeshComponent.PhysicsAssetInstance.SetAngularDriveScale(MotorScale * StaggerMuscleScale, MotorScale * StaggerMuscleScale, 1.f);
			HipBody.SetBoneSpringParams(50.f, 1.f, MotorScale * AngularHipDriveScale * 50.f, 0.1f);
		}
		else
		{
			bRampingDownMotors = false;
			SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = true;
			SetPATAState(PATA_Floppy);
			HipBody.EnableBoneSpring(false, false, HipMatrix); // Turn off hip spring.
			GetUpNode.StopAnim();// Stop the stagger animation from playing
			BlendNode.SetBlendTarget(0, 0.f); // Set blender back to default right away

			// can turn this back to full now, as we turned off the motors by setting state to floppy.
			SkeletalMeshComponent.PhysicsAssetInstance.SetAngularDriveScale(1.f, 1.f, 1.f);
		}
	}
	else if(bBlendingBack)
	{
		if(BlendBackStartTime > WorldInfo.TimeSeconds)
		{
			// Pausing before blend
		}
		else if(BlendBackStartTime + PokeBlendTime > WorldInfo.TimeSeconds)
		{
			SkeletalMeshComponent.PhysicsWeight = 1.f - ((WorldInfo.TimeSeconds - BlendBackStartTime)/PokeBlendTime);
		}
		else
		{
			bBlendingBack = false;
			SetPATAState(PATA_FixedAll);
			SkeletalMeshComponent.PhysicsWeight = 1.f;
		}
	}
	else if(bBlendToGetUp)
	{
		// If we are in process of blending to get up animation, modify physics weight between ragdoll finish pose and get-up start pose.
		if(GetUpBlendStartTime + GetUpBlendTime > WorldInfo.TimeSeconds)
		{
			SkeletalMeshComponent.PhysicsWeight = 1.f - ((WorldInfo.TimeSeconds - GetUpBlendStartTime)/GetUpBlendTime);
		}
		// Done with blend, start the get-up animation, start updating physics bones again, and show result.
		// Bones should all be fixed at this point.
		else
		{
			bBlendToGetUp = false;

			SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = true;
			SkeletalMeshComponent.PhysicsWeight = 1.f;

			// Start playing the get up animation.
			GetUpNode.PlayAnim(false, 1.f, 0.f);
		}
	}
}

event OnAnimEnd(AnimNodeSequence InSeqNode, float PlayedTime, float ExcessTime)
{
	// Don't do this for stumbling animation!
	if(InSeqNode.AnimSeqName != 'Stumble_Bwd')
	{
		SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation = true;
		SkeletalMeshComponent.PhysicsWeight = 1.f;

		// Make sure run anim is playing
		RunNode.bPlaying = true;

		// Blend from end of get-up animation to running node.
		BlendNode.SetBlendTarget(0, GetUpToIdleTime);

		// Got to the 'fixed all' state.
		SetBodiesFixed(true);
		CurrentState = PATA_FixedAll;
	}
}

defaultproperties
{
	LowerBoneNames=("b_LeftLegUpper","b_LeftLeg","b_LeftAnkle","b_RightLegUpper","b_RightLeg","b_RightAnkle","b_Hips")
	LinearBoneSpringNames=("b_LeftHand","b_RightHand")
	AngularBoneSpringNames=("b_Head")

	GetUpBlendTime=0.2
	GetUpToIdleTime=0.4
	ActorOriginHeight=50

	PokePauseTime=0.7
	PokeBlendTime=0.5

	StaggerMuscleScale=200.0
	AngularHipDriveScale=5.0

	StaggerSpeedAdj=0.1
	BlendStaggerAnimTime=0.15
	MotorDownTime=1.4
	MotorDownAnimTime=0.4

	StaggerVel=100

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		Animations=None
		SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
		AnimSets.Add(AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale')
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimTreeTemplate=AnimTree'TestAnimPhys.TestAnimPhys_Tree'
		bHasPhysicsAssetInstance=true
		bUpdateKinematicBonesFromAnimation=true
		bUpdateJointsFromAnimation=true
		PhysicsWeight=1.0
		BlockRigidBody=true
		CollideActors=true
		BlockActors=false
		BlockZeroExtent=true
		BlockNonZeroExtent=false
		RBChannel=RBCC_EffectPhysics
		RBCollideWithChannels=(Default=true,BlockingVolume=TRUE,EffectPhysics=true,GameplayPhysics=true)
	End Object
	CollisionComponent=SkeletalMeshComponent0
	SkeletalMeshComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

	bStatic=false
	bCollideActors=true
	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=false
	bProjTarget=true

	RemoteRole=ROLE_None
	bNoDelete=true

}
