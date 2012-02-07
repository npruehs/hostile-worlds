/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 * penalizes specs of a certain class if they are within a set distance of another mantle in the predecessor chain
 */
class NavMeshPath_MinDistBetweenSpecsOfType extends NavMeshPathConstraint
	native(AI);

cpptext
{
	// Interface
	virtual UBOOL EvaluatePath( FNavMeshEdgeBase* Edge, FNavMeshPolyBase* SrcPoly, FNavMeshPolyBase* DestPoly, const FNavMeshPathParams& PathParams, INT& out_PathCost, INT& out_HeuristicCost );
	UBOOL IsWithinMinDistOfEdgeInPath(FNavMeshEdgeBase* Edge);
}

/** min dist between edges of the specified type type */
var float MinDistBetweenEdgeTypes;

/** can be used to indicate we last mantled at this location in previous path and we shouldn't take mantles within
   mindistbetweenmantles of that location */
var vector InitLocation;

/** 
  * the type of edge we want to enforce minimum distance between
*/
var ENavMeshEdgeType EdgeType;

static function bool EnforceMinDist( NavigationHandle NavHandle, float InMinDist, ENavMeshEdgeType InEdgeType, optional vector LastLocation )
{
	local NavMeshPath_MinDistBetweenSpecsOfType Con;

	if( NavHandle != None /*&& NavHandle.bCanMantle */ && InMinDist > 0.f )
	{
		Con = NavMeshPath_MinDistBetweenSpecsOfType(NavHandle.CreatePathConstraint(default.class));
		if( Con != None )
		{
			Con.MinDistBetweenEdgeTypes = InMinDist;
			Con.InitLocation = LastLocation;
			Con.EdgeType = InEdgeType;
			NavHandle.AddPathConstraint( Con );
			return TRUE;
		}
	}

	return FALSE;
}

function Recycle()
{
	Super.Recycle();
	MinDistBetweenEdgeTypes=default.MinDistBetweenEdgeTypes;
	EdgeType = NAVEDGE_Normal;
	InitLocation=vect(0,0,0);
}

defaultproperties
{
}
