/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 * this goal eval will not stop until its out of paths, and will simply return the node with the least cost
 */
class NavMeshGoal_GenericFilterContainer extends NavMeshPathGoalEvaluator
	native(AI);

cpptext
{
	// NavMeshPathGoalEvaluator Interface
	virtual UBOOL EvaluateGoal( FNavMeshPolyBase* PossibleGoal, const FNavMeshPathParams& PathParams, FNavMeshPolyBase*& out_GenGoal );
	
	/**
	 * this will ask each filter in this guy's list if the passed poly is a viable seed to get added at start time
	 * @param PossibleSeed - the seed to check viability for
	 * @param PathParams - params for entity searching
	 */
	virtual UBOOL IsValidSeed( FNavMeshPolyBase* PossibleSeed, const FNavMeshPathParams& PathParams );

	/** 
	 * sets up internal vars for path searching, and will early out if something fails
	 * @param Handle - handle we're initializing for
	 * @param PathParams - pathfinding parameter packet
	 * @return - whether or not we should early out form this search
	 */
	virtual UBOOL InitializeSearch( UNavigationHandle* Handle,
									const FNavMeshPathParams& PathParams );

}

var transient instanced array<NavMeshGoal_Filter> GoalFilters;

/** storage of the goal we found an determined was OK (for use when goal does not have a path, but we still want to know what the goal was) */
var transient private native pointer SuccessfulGoal{FNavMeshPolyBase};

/** Ref to our NavHandle so we can interrogate it for Debug flags. **/
var transient protected NavigationHandle MyNavigationHandle;



static function NavMeshGoal_GenericFilterContainer CreateAndAddFilterToNavHandle( NavigationHandle NavHandle, optional int InMaxPathVisits=-1)
{
	local NavMeshGoal_GenericFilterContainer	Eval;

	if( NavHandle != None )
	{
		Eval = NavMeshGoal_GenericFilterContainer(NavHandle.CreatePathGoalEvaluator(default.class));

		if( Eval != None )
		{
			if(InMaxPathVisits > 0)
			{
				Eval.MaxPathVisits = InMaxPathVisits;
			}

			Eval.MyNavigationHandle = NavHandle;
			NavHandle.AddGoalEvaluator( Eval );
			return Eval;
		}
	}

	return none;
}

// indireciton to hook into a pool or something if we want
function NavMeshGoal_Filter GetFilterOfType(class<NavMeshGoal_Filter> Filter_Class)
{
	return new(self) Filter_Class;
}

/**
 * returns the center of the poly we found as a valid goal, or 0,0,0 if none found (uses SuccessfulGoal member var0
 */
native function vector GetGoalPoint();



function Recycle()
{
	Super.Recycle();

	GoalFilters.length = 0;
	MaxPathVisits = default.maxPathVisits;
	MyNavigationHandle = None;
}

defaultproperties
{
	MaxPathVisits=2048
}
