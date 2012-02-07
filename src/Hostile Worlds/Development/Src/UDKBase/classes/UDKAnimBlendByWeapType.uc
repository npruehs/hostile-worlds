/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 * This node blends in the 'Weapon' branch when anything other than the rifle is being used.
 */

class UDKAnimBlendByWeapType extends AnimNodeBlendPerBone
	native(Animation);

cpptext
{
	void WeapTypeChanged(FName NewAimProfileName);
}

defaultproperties
{
	Children(0)=(Name="Default",Weight=1.0)
	Children(1)=(Name="Weapon")
}
