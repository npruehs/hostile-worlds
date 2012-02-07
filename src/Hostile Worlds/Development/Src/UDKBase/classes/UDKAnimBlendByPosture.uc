/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByPosture extends UDKAnimBlendBase
	native(Animation);                                         

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);
}


defaultproperties
{
	Children(0)=(Name="Run",Weight=1.0)
	Children(1)=(Name="Crouch")
	bFixNumChildren=true
}
