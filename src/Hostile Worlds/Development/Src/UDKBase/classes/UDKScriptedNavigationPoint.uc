/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
/** Navigation points with pathing interface exposed to script */
class UDKScriptedNavigationPoint extends NavigationPoint
	native
	abstract;

/** If true, calls script event SpecifyEndAnchor() */
var bool bScriptSpecifyEndAnchor;

/** If true, calls script event NotifyAnchorFindingResult() */
var bool bScriptNotifyAnchorFindingResult;

/** Whether path anchor must be reachable by route finder to even try to path toward it */
var bool bAnchorMustBeReachable;
	
cpptext
{
	virtual class ANavigationPoint* SpecifyEndAnchor(APawn* RouteFinder);
	virtual void NotifyAnchorFindingResult(ANavigationPoint* EndAnchor, APawn* RouteFinder);
	virtual UBOOL AnchorNeedNotBeReachable();
}

/**
  * Returns the end anchor to use for path finding when this actor is the goal.
  * Called from C++ if bScriptSpecifyEndAnchor is true.
  */
event NavigationPoint SpecifyEndAnchor(Pawn RouteFinder);

/**
 * Notify actor of anchor finding result.
 * Called from C++ if bScriptNotifyAnchorFindingResult is true.
 * @PARAM EndAnchor is the anchor found
 * @PARAM RouteFinder is the pawn which requested the anchor finding
  */
event NotifyAnchorFindingResult(NavigationPoint EndAnchor, Pawn RouteFinder);

defaultproperties
{
	bAnchorMustBeReachable=true
}