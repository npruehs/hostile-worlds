/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKAnimBlendBySpeed extends AnimNodeBlend
	native(Animation);

/** minimum speed; at this or below the "Slow" anim is used completely */
var() float MinSpeed;
/** maximum speed; at this or above the "Fast" anim is used completely */
var() float MaxSpeed;

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);
}

defaultproperties
{
	MinSpeed=100.0
	MaxSpeed=1000.0

	Children(0)=(Name="Slow",Weight=1.0)
	Children(1)=(Name="Fast")
}
