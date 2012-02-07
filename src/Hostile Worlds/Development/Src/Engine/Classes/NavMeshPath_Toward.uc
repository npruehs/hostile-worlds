/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class NavMeshPath_Toward extends NavMeshPathConstraint
	native(AI);

cpptext
{
	// Interface
	virtual UBOOL EvaluatePath( FNavMeshEdgeBase* Edge, FNavMeshPolyBase* SrcPoly, FNavMeshPolyBase* DestPoly, const FNavMeshPathParams& PathParams, INT& out_PathCost, INT& out_HeuristicCost );
}

/** Goal trying to find path toward */
var Actor	GoalActor;
/** Goal trying to find path toward */
var Vector GoalPoint;

static function bool TowardGoal( NavigationHandle NavHandle, Actor Goal )
{
	local NavMeshPath_Toward Con;

	if( NavHandle != None && Goal != None )
	{
		Con = NavMeshPath_Toward(NavHandle.CreatePathConstraint(default.class));
		if( Con != None )
		{
			Con.GoalActor = Goal;
			NavHandle.AddPathConstraint( Con );
			return TRUE;
		}
	}

	return FALSE;
}

static function bool TowardPoint( NavigationHandle NavHandle, Vector Point )
{
	local NavMeshPath_Toward Con;

	if( NavHandle != None && Point != Vect(0,0,0) )
	{
		Con = NavMeshPath_Toward(NavHandle.CreatePathConstraint(default.class));
		if( Con != None )
		{
			Con.GoalPoint = Point;
			NavHandle.AddPathConstraint( Con );
			return TRUE;
		}
	}

	return FALSE;
}

function Recycle()
{
	Super.Recycle();
	GoalActor=none;
	GoalPoint=default.GoalPoint;
}

defaultproperties
{
}
