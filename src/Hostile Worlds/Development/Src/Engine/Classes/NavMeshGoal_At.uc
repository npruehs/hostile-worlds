/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class NavMeshGoal_At extends NavMeshPathGoalEvaluator
	native(AI);

cpptext
{
	// Interface
	virtual UBOOL InitializeSearch( UNavigationHandle* Handle, const FNavMeshPathParams& PathParams);
	virtual UBOOL EvaluateGoal( FNavMeshPolyBase* PossibleGoal, const FNavMeshPathParams& PathParams, FNavMeshPolyBase*& out_GenGoal );
	virtual void  NotifyExceededMaxPathVisits( FNavMeshPolyBase* BestGuess, FNavMeshPolyBase*& out_GenGoal );
	virtual UBOOL DetermineFinalGoal( FNavMeshPolyBase*& out_GenGoal, class AActor** out_DestActor, INT* out_DestItem );
}

/** Location to reach */
var Vector Goal;
/** Within this acceptable distance */
var float GoalDist;
/** Should keep track of cheapest path even if don't reach goal */
var bool  bKeepPartial;


// the polygon that contains our goal point
var private native pointer GoalPoly{FNavMeshPolyBase};

// the last partial goal (used when no true path is found)
var private native pointer PartialGoal{FNavMeshPolyBase};

native function RecycleNative();

static function bool AtActor( NavigationHandle NavHandle, Actor GoalActor, optional float Dist, optional bool bReturnPartial )
{
	local Controller GoalController;
	local Controller MyController;
	local float Radius, Height;
	local vector TargetLoc;

	if( NavHandle != None )
	{
		GoalController = Controller(GoalActor);
		if( GoalController != None )
		{
			GoalActor = GoalController.Pawn;
		}

		if( GoalActor != None )
		{
			MyController = Controller(NavHandle.Outer);
			NavHandle.PopulatePathfindingParamCache();
			TargetLoc = GoalActor.GetDestination(MyController);
			GoalActor.GetBoundingCylinder(Radius, Height);
			TargetLoc.Z -= Height - NavHandle.CachedPathParams.SearchExtent.Z;
			return AtLocation(NavHandle, TargetLoc, Dist, bReturnPartial);
		}
	}

	return FALSE;
}

static function bool AtLocation( NavigationHandle NavHandle, Vector GoalLocation, optional float Dist, optional bool bReturnPartial )
{
	local NavMeshGoal_At Eval;

	if( NavHandle != None )
	{
		Eval = NavMeshGoal_At(NavHandle.CreatePathGoalEvaluator(default.class));

		if( Eval != None )
		{
			Eval.Goal			= GoalLocation;
			Eval.GoalDist		= Dist;
			Eval.bKeepPartial	= bReturnPartial;
			NavHandle.AddGoalEvaluator( Eval );
			return TRUE;
		}
	}

	return FALSE;
}


function Recycle()
{
	Goal = vect(0,0,0);
	GoalDist = default.GoalDist;
	bKeepPartial = default.bKeepPartial;
	RecycleNative();
	Super.Recycle();
}

defaultproperties
{
	MaxPathVisits=1024
}
