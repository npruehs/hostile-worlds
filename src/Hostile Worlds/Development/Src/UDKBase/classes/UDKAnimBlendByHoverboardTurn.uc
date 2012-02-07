/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByHoverboardTurn extends AnimNodeBlendBase
	native(Animation);


cpptext
{
	// AnimNode interface
	virtual	void TickAnim(FLOAT DeltaSeconds);
}

var()	float TurnScale;
var()	float MaxBlendPerSec;
var		float CurrentAnimWeight;

defaultproperties
{
	Children(0)=(Name="Straight",Weight=1.0)
	Children(1)=(Name="TurnLeft")
	Children(2)=(Name="TurnRight")
	bFixNumChildren=true
	MaxBlendPerSec=1.0
}