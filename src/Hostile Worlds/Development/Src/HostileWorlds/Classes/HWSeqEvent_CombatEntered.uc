// ============================================================================
// HWSeqEvent_CombatEntered
// A Hostile Worlds sequence event that is triggered every time a player is
// entering combat because he or she has been attacked.
//
// Author:  Nick Pruehs
// Date:    2011/04/11
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqEvent_CombatEntered extends HWSequenceEvent;

DefaultProperties
{
	ObjName="Player - Combat Entered"

	bPlayerOnly=true
	bClientSideOnly=true
}
