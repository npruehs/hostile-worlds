/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class NavMeshGoal_OutOfViewFrom extends NavMeshPathGoalEvaluator
	native;


// the polygon that contains our goal point
var private native pointer GoalPoly{FNavMeshPolyBase};

var vector OutOfViewLocation;

/** show debug lines **/
// TODO: prob should promote this
var bool bShowDebug;


cpptext
{
	// Interface
	virtual UBOOL InitializeSearch( UNavigationHandle* Handle, const FNavMeshPathParams& PathParams);
	virtual UBOOL EvaluateGoal( FNavMeshPolyBase* PossibleGoal, const FNavMeshPathParams& PathParams, FNavMeshPolyBase*& out_GenGoal );
	virtual void  NotifyExceededMaxPathVisits( FNavMeshPolyBase* BestGuess, FNavMeshPolyBase*& out_GenGoal );
}



native function RecycleNative();


static function bool MustBeHiddenFromThisPoint( NavigationHandle NavHandle, Vector InOutOfViewLocation )
{
	local NavMeshGoal_OutOfViewFrom Eval;

	if( NavHandle != None )
	{
		Eval = NavMeshGoal_OutOfViewFrom(NavHandle.CreatePathGoalEvaluator(default.class));

		if( Eval != None )
		{
			Eval.OutOfViewLocation = InOutOfViewLocation;
			NavHandle.AddGoalEvaluator( Eval );
			return TRUE;
		}
	}

	return FALSE;
}


function Recycle()
{
	RecycleNative();
	Super.Recycle();
}

defaultproperties
{
	MaxPathVisits=1024
	bShowDebug=FALSE
}
