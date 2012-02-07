/**
 * Controller that rotates a single bone to 'look at' a given target.
 * Extends engine functionality to add per-axis rotation limits.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSkelControl_LookAt extends SkelControlLookat
	native(Animation);

cpptext
{
protected:
	virtual UBOOL	ApplyLookDirectionLimits(FVector& DesiredLookDir, const FVector &CurrentLookDir, INT BoneIndex, USkeletalMeshComponent* SkelComp);
public:
	virtual void	TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	virtual void	DrawSkelControl3D(const FSceneView* View, FPrimitiveDrawInterface* PDI, USkeletalMeshComponent* SkelComp, INT BoneIndex);
}

/** If TRUE, apply limits to specified axis.  Ignore limits otherwise. */
var() protected bool bLimitYaw;
var() protected bool bLimitPitch;
var() protected bool bLimitRoll;

/** Angular limits for pitch, roll, yaw, in degrees */
var() protected float YawLimit;
var() protected float PitchLimit;
var() protected float RollLimit;

/** If TRUE, draw cone representing per-axis limits. */
var() protected bool bShowPerAxisLimits;

defaultproperties
{
}

