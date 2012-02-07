// ============================================================================
// HWSeqEvent_CombatLeft
// A Hostile Worlds sequence event that is triggered every time a player has
// left combat a short amount of time after he or she has been attacked.
//
// Author:  Nick Pruehs
// Date:    2011/04/11
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqEvent_CombatLeft extends HWSequenceEvent;

DefaultProperties
{
	ObjName="Player - Combat Left"

	bPlayerOnly=true
	bClientSideOnly=true
}
