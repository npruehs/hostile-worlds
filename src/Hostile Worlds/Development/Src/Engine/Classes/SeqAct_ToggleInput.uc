/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_ToggleInput extends SeqAct_Toggle;

var() bool bToggleMovement;
var() bool bToggleTurning;

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return false;
}

defaultproperties
{
	ObjName="Toggle Input"
	ObjCategory="Toggle"
	VariableLinks.RemoveIndex(1)
	bToggleMovement=true
	bToggleTurning=true
}
