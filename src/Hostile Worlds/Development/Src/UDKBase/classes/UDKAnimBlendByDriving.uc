/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKAnimBlendByDriving extends AnimNodeBlend
	native(Animation);

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);
}

/** Force an update of the driving state now. */
native function UpdateDrivingState();

defaultproperties
{
	Children(0)=(Name="Not-Driving",Weight=1.0)
	Children(1)=(Name="Driving")
	bFixNumChildren=true
}
