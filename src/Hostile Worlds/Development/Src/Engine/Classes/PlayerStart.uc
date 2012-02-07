//=============================================================================
// Player start location.
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class PlayerStart extends NavigationPoint
	placeable
	native
	hidecategories(Collision);

cpptext
{
	void addReachSpecs(AScout *Scout, UBOOL bOnlyChanged=0);
}

var() bool bEnabled;
var() bool bPrimaryStart;		// None primary starts used only if no primary start available

/** Team specific player start, 255 for any team */
var() int TeamIndex;

/* epic ===============================================
* ::OnToggle
*
* Scripted support for toggling a playerstart, checks which
* operation to perform by looking at the action input.
*
* Input 1: turn on
* Input 2: turn off
* Input 3: toggle
*
* =====================================================
*/
simulated function OnToggle(SeqAct_Toggle action)
{
	if (action.InputLinks[0].bHasImpulse)
	{
		// turn on
		bEnabled = true;
	}
	else
	if (action.InputLinks[1].bHasImpulse)
	{
		// turn off
		bEnabled = false;
	}
	else
	if (action.InputLinks[2].bHasImpulse)
	{
		// toggle
		bEnabled = !bEnabled;
	}
}


defaultproperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00040.000000
		CollisionHeight=+00080.000000
	End Object

	Begin Object NAME=Sprite LegacyClassName=PlayerStart_PlayerStartSprite_Class
		Sprite=Texture2D'EditorResources.S_Player'
	End Object

	bPrimaryStart=true
 	bEnabled=true

	TeamIndex=0

	bEdShouldSnap=true
}
