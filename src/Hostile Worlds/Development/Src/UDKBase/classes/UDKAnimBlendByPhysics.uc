/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByPhysics extends UDKAnimBlendBase
	native(Animation);

/** Maps the PSY_enums to child nodes */

var(Animations) int    		PhysicsMap[12];

/** Holds the last known physics type for the tree's owner. */

var int						LastPhysics;		// Track the last physics

var()	float	LandBlendDelay;

var		int		PendingChildIndex;

var		float	PendingTimeToGo;

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);
}


defaultproperties
{
	PhysicsMap(0)=-1
	PhysicsMap(1)=-1
	PhysicsMap(2)=-1
	PhysicsMap(3)=-1
	PhysicsMap(4)=-1
	PhysicsMap(5)=-1
	PhysicsMap(6)=-1
	PhysicsMap(7)=-1
	PhysicsMap(8)=-1
	PhysicsMap(9)=-1
	PhysicsMap(10)=-1
	PhysicsMap(11)=-1

	Children(0)=(Name="PHYS_Walking",Weight=1.0)
	Children(1)=(Name="PHYS_Falling")
	Children(2)=(Name="PHYS_Swimming")
}
