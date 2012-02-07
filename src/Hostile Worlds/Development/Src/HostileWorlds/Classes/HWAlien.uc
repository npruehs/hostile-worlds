// ============================================================================
// HWAlien
// An abstract alien of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2010/10/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAlien extends HWPawn abstract;

/** The time before alien camps and lanes are repopulated after an alien has been killed, in seconds. */
const ALIEN_RESPAWN_TIME = 30;

/** The number of shards that is awarded to a player killing this alien.*/
var config int ShardsAwarded;


function int GetShardsAwarded()
{
	return ShardsAwarded;
}


DefaultProperties
{
	RemoteRole = ROLE_SimulatedProxy
}
