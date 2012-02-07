/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class MorphTestActor extends SkeletalMeshActor;

var()	Actor	LookAtActor;
var()	float	MinMorphDistance;
var()	float	MaxMorphDistance;

event Tick(float DeltaSeconds)
{
	local	SkelControlLookAt	LookControl;
	local	MorphNodeWeight		WeightNode;
	local	float				LookAtDist;
	local	float				ResultWeight;
	
	if(LookAtActor != None)
	{
		LookControl = SkelControlLookAt( SkeletalMeshComponent.FindSkelControl('LookAtControl') );
		if(LookControl != None)
		{
			LookControl.TargetLocation = LookAtActor.Location;
		}
		
		WeightNode = MorphNodeWeight( SkeletalMeshComponent.FindMorphNode('WeightNode') );
		if(WeightNode != None)
		{
			LookAtDist = Vsize( Location - LookAtActor.Location );
			ResultWeight = Fclamp( (LookAtDist - MinMorphDistance)/(MaxMorphDistance - MinMorphDistance), 0.0, 1.0 );
		
			WeightNode.SetNodeWeight(1.0 - ResultWeight);
		}
	}
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		Animations=None
	End Object
}