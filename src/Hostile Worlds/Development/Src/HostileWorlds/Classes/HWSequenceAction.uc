// ============================================================================
// HWSequenceAction
// A Hostile Worlds sequence action to be used in Unreal Kismet.
//
// Author:  Nick Pruehs
// Date:    2011/03/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSequenceAction extends SequenceAction
	abstract;

event Activated()
{
	`log("(KISMET) "$self$" has been activated.");

	// trigger next action in sequence
	ActivateOutputLink(0);
}

DefaultProperties
{
	// disable default handler function calls
	bCallHandler=false

	ObjCategory="Hostile Worlds"

	// rename In and Out links to Start and Finished
	InputLinks.Empty
	InputLinks(0)=(LinkDesc="Start")

	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Finished")

	// remove superflous Targets variable links
	VariableLinks.Empty
}
