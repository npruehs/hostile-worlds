/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTSkelControl_Oscillate extends SkelControlSingleBone
	hidecategories(Rotation);

/** maximum amount to move the bone */
var() vector MaxDelta;
/** the amount of time it takes to go from the starting position (no delta) to MaxDelta */
var() float Period;
/** current time of the oscillation (-Period <= CurrentTime <= Period) */
var() float CurrentTime;
/** indicates which direction we're oscillating in */
var bool bReverseDirection;

event TickSkelControl(float DeltaTime, SkeletalMeshComponent SkelComp)
{
	if (bReverseDirection)
	{
		CurrentTime -= DeltaTime;
		if (CurrentTime <= -Period)
		{
			CurrentTime = -Period - (CurrentTime + Period);
			bReverseDirection = FALSE;
		}
	}
	else
	{
		CurrentTime += DeltaTime;
		if (CurrentTime >= Period)
		{
			CurrentTime = Period - (CurrentTime - Period);
			bReverseDirection = TRUE;
		}
	}

	BoneTranslation = MaxDelta * (CurrentTime / Period);
}

defaultproperties
{
	bShouldTickInScript=true
	bApplyTranslation=true
	bAddTranslation=true
	bIgnoreWhenNotRendered=true

	Period=0.5
}
