
/** 
 * Given a list of actors we're interested in, will find the closest one to us (closest path distance)
 *  accomplished by seeding the working set with start nodes for all the actors
 *
 * Usage: 
 *     needs to go last in the GoalList as this does DetermineFinalGoal
 *     need to pass in a out_DestActor to the call to FindPath() as that will have the specific actor
*        (the returned GoalPoint is is the center of the poly (which could have N goals on it)
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class NavMeshGoal_ClosestActorInList extends NavMeshPathGoalEvaluator
	native(AI);

cpptext
{

	// ++ NavMeshPathGoalEvaluator Interface ++
	// overidden to add the polys all our goal points are in to the working set instead of just the anchor
	virtual UBOOL SeedWorkingSet( FNavMeshPolyBase*& OpenList, FNavMeshPolyBase* AnchorPoly, DWORD PathSessionID,UNavigationHandle* Handle, const FNavMeshPathParams& PathParams );
	virtual UBOOL InitializeSearch( UNavigationHandle* Handle, const FNavMeshPathParams& PathParams );
	// stop when we reach the anchor
	virtual UBOOL EvaluateGoal( FNavMeshPolyBase* PossibleGoal, const FNavMeshPathParams& PathParams, FNavMeshPolyBase*& out_GenGoal );
	// determine which goal actor we pathed to first (which was closest)
	virtual UBOOL DetermineFinalGoal( FNavMeshPolyBase*& out_GenGoal, class AActor** out_DestActor, INT* out_DestItem );
	// overidden to save the path in forward order since we're pathing backwards
	virtual void SaveResultingPath( FNavMeshPolyBase* StartingPoly,FNavMeshPolyBase* GoalPoly,UNavigationHandle* Handle );
}

var array<BiasedGoalActor> GoalList;

/** cached map of which polys match to which actors */

var	const private native transient MultiMap_Mirror	PolyToGoalActorMap{TMultiMap<FNavMeshPolyBase*,AActor*>};

/** Cached ref to the anchor poly we're trying to path back to */
var native pointer CachedAnchorPoly{FNavMeshPolyBase};

static function NavMeshGoal_ClosestActorInList ClosestActorInList(NavigationHandle NavHandle, const out array<BiasedGoalActor> InGoalList)
{
	local NavMeshGoal_ClosestActorInList Eval;

	Eval = NavMeshGoal_ClosestActorInList(NavHandle.CreatePathGoalEvaluator(default.class));

	Eval.GoalList = InGoalList;
	NavHandle.AddGoalEvaluator(Eval);
	return Eval;
}

event Recycle()
{
	Super.Recycle();
	GoalList.length = 0;
	RecycleInternal();
}
native function RecycleInternal();

defaultproperties
{
	MaxPathVisits=3000
}
