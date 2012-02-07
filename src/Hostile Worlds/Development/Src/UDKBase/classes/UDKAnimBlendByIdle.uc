/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByIdle extends UDKAnimBlendBase
	native(Animation);

cpptext
{
	// AnimNode interface
	virtual	void TickAnim(FLOAT DeltaSeconds);
}

defaultproperties
{
	Children(0)=(Name="Idle",Weight=1.0)
	Children(1)=(Name="Moving")
	bFixNumChildren=true
}
