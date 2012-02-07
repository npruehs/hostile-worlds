/**
 * Base class for all sequence actions that are capable of changing the value of a SequenceVariable
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_SetSequenceVariable extends SequenceAction
	native(Sequence)
	abstract;

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return true;
}

DefaultProperties
{
	ObjName="Set Variable"
	ObjCategory="Set Variable"
}
