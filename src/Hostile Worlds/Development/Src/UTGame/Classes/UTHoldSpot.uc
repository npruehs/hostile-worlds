/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTHoldSpot extends UTDefensePoint
	notplaceable;

var UTVehicle HoldVehicle;

/** since HoldSpots aren't part of the prebuilt nav network we need to hook them to another NavigationPoint */
var NavigationPoint LastAnchor;

function PreBeginPlay()
{
	Super(NavigationPoint).PreBeginPlay();
}

function Actor GetMoveTarget()
{
	if ( HoldVehicle != None )
	{
		if ( HoldVehicle.Health <= 0 )
			HoldVehicle = None;
		if ( HoldVehicle != None )
			return HoldVehicle.GetMoveTargetFor(None);
	}

	return self;
}

function FreePoint()
{
	Destroy();
}

event NavigationPoint SpecifyEndAnchor(Pawn RouteFinder)
{
	if ( (LastAnchor != None) && !LastAnchor.IsUsableAnchorFor(RouteFinder) )
	{
		LastAnchor = None;
	}
	return LastAnchor;
}

event NotifyAnchorFindingResult(NavigationPoint EndAnchor, Pawn RouteFinder)
{
	LastAnchor = EndAnchor;
}

defaultproperties
{
	bCollideWhenPlacing=false
	bStatic=false
	bNoDelete=false
	bAnchorMustBeReachable=false
	bScriptSpecifyEndAnchor=true
	bScriptNotifyAnchorFindingResult=true
}
