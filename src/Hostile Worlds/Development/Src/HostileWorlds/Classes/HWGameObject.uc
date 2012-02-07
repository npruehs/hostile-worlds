// ============================================================================
// HWGameObject
// An abstract game object of Hostile Worlds that can be interacted with.
//
// Author:  Nick Pruehs
// Date:    2010/11/04
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGameObject extends HWSelectable;

/** The first line of this object's description to be shown in the HUD. */
var localized string DescriptionLineOne;

/** The second line of this object's description to be shown in the HUD. */
var localized string DescriptionLineTwo;

/** The third line of this object's description to be shown in the HUD. */
var localized string DescriptionLineThree;


/** Returns additional information to be shown in the HUD while selected. */
simulated function string GetAdditionalInfo();

/** Overriding the base implementation in order to destroy all HWGameObjects per default on a Reset() call. */
function Reset()
{
	super.Reset();

	Destroy();
}

DefaultProperties
{
	bApplyFogOfWar=false

	TeamColors(0)=(R=0.628834,G=3.183391,B=0.557060,A=1.000000) // green
	TeamColors(1)=(R=0.900000,G=0.900000,B=4.000000,A=1.000000) // blue
	TeamColors(2)=(R=4.972973,G=0.848248,B=0.737642,A=1.000000) // red
	TeamColors(3)=(R=3.066667,G=0.509065,B=2.407024,A=1.000000) // purple
	TeamColors(4)=(R=0.788296,G=2.453333,B=2.303576,A=1.000000) // cyan
	TeamColors(5)=(R=2.796353,G=2.500218,B=0.514438,A=1.000000) // yellow
	TeamColors(6)=(R=3.450000,G=1.175214,B=0.467957,A=1.000000) // orange
	TeamColors(7)=(R=2.000000,G=2.000000,B=2.000000,A=1.000000) // grey
}
