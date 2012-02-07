/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 * Reachspec class used by UDKJumpPads.
 */
class UDKJumpPadReachSpec extends UDKTrajectoryReachSpec
	native;

cpptext
{
	virtual FVector GetInitialVelocity();
	virtual INT CostFor(APawn* P);
}
