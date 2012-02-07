// ============================================================================
// HWSequenceEvent
// A Hostile Worlds sequence event to be used in Unreal Kismet.
//
// Author:  Nick Pruehs
// Date:    2011/04/11
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSequenceEvent extends SequenceEvent
	abstract;

event Activated()
{
	`log("(KISMET) "$self$" has been triggered.");

	// trigger next action in sequence
	ActivateOutputLink(0);
}

DefaultProperties
{	
	ObjCategory="Hostile Worlds"

	// disable trigger limit
	MaxTriggerCount=0
}
