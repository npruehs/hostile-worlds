/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_Toggle extends SequenceAction
	native(Sequence);

cpptext
{
	virtual void PostLoad();
	virtual void Activated();
};

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

defaultproperties
{
	ObjName="Toggle"
	ObjCategory="Toggle"

	InputLinks(0)=(LinkDesc="Turn On")
	InputLinks(1)=(LinkDesc="Turn Off")
	InputLinks(2)=(LinkDesc="Toggle")

	VariableLinks(0)=(bModifiesLinkedObject=true)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",MinVars=0)
	EventLinks(0)=(LinkDesc="Event")
}
