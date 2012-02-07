// ============================================================================
// HWSeqCond_IsInCombat
// A Hostile Worlds sequence condition that returns true if the local player
// currently is in combat, and false otherwise.
//
// Author:  Nick Pruehs
// Date:    2011/08/26
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqCond_IsInCombat extends SequenceCondition;

event Activated()
{
	local HWPlayerController PC;

	PC = HWPlayerController(GetWorldInfo().GetALocalPlayerController());
	ActivateOutputLink(PC.bInCombat ? 0 : 1);	
}


DefaultProperties
{
	ObjCategory="Hostile Worlds"
	ObjName="Is In Combat"

	InputLinks(0)=(LinkDesc="In")
	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
}
