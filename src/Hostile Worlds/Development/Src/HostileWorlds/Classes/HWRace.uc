// ============================================================================
// HWRace
// A Hostile Worlds race, defined using a concept similar to the one of
// Unreal damage types. Holds information on the squad member classes belonging
// to a particular race.
//
// Author:  Nick Pruehs
// Date:    2011/04/27
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWRace extends Object
	abstract;

/** The class of the Commander of this race. */
var class<HWCommander> CommanderClass;

/** The squad members of this race. Used for spawning and sorting. */
var class<HWSquadMember> SquadMemberClasses[3];

/** The tactical abilities of this race. Used for displaying the icons in the GUI submenu. */
var class<HWAbility> TacticalAbilities[3];


DefaultProperties
{
}
