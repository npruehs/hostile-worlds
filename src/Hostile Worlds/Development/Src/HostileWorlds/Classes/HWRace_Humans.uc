// ============================================================================
// HWRace_Humans
// The Human race in Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2011/04/27
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWRace_Humans extends HWRace;

DefaultProperties
{
	CommanderClass=class'HWSM_Commander'

	SquadMemberClasses(0)=class'HWSM_Rusher'
	SquadMemberClasses(1)=class'HWSM_Engineer'
	SquadMemberClasses(2)=class'HWSM_Hunter'

	TacticalAbilities(0)=class'HWAb_Cloak'
	TacticalAbilities(1)=class'HWAb_AirStrike'
	TacticalAbilities(2)=class'HWAb_Scan'
}
