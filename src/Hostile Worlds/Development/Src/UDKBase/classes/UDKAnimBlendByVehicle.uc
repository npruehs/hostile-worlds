/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKAnimBlendByVehicle extends UDKAnimBlendBase
	native(Animation);

var bool	  	bLastPawnDriving;
var Vehicle 	LastVehicle;

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);
}

/** Force an update of the vehicle state now. */
native function UpdateVehicleState();

defaultproperties
{
	Children(0)=(Name="Default",Weight=1.0)
	Children(1)=(Name="UTVehicle_Hoverboard")
	bFixNumChildren=true
}
