/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTScout extends UDKScout;

defaultproperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+0034.000000
	End Object

	PathSizes.Empty
	PathSizes(0)=(Desc=Crouched,Radius=22,Height=29)
	PathSizes(1)=(Desc=Human,Radius=22,Height=44)
	PathSizes(2)=(Desc=Small,Radius=72,Height=44)
	PathSizes(3)=(Desc=Common,Radius=100,Height=44)
	PathSizes(4)=(Desc=Max,Radius=140,Height=100)
	PathSizes(5)=(Desc=Vehicle,Radius=260,Height=100)

	TestJumpZ=322
	TestGroundSpeed=440
	TestMaxFallSpeed=2500
	MaxStepHeight=26.0
	MaxJumpHeight=49.0
	MaxDoubleJumpHeight=85.0
	MinNumPlayerStarts=1
	WalkableFloorZ=0.78

	PrototypePawnClass=class'UTGame.UTPawn'
	SizePersonFindName=Human
	
	NavMeshGen_EntityHalfHeight=44.0
}
