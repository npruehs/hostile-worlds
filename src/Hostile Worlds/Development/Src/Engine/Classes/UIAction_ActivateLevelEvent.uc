/**
 * Allows designers to activate remote events in the current level.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_ActivateLevelEvent extends UIAction
	native(inherit);

cpptext
{
	void Activated();
}

/** Name of the event to activate */
var() Name EventName;

DefaultProperties
{
	ObjName="Activate Level Event"
	ObjCategory="Level"
	bAutoActivateOutputLinks=false

	EventName=DefaultEvent

	// remove the "Targets" variable link, as it's unnecessary for this action
	VariableLinks.RemoveIndex(0)

	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Failed")
	OutputLinks(1)=(LinkDesc="Success")
}
