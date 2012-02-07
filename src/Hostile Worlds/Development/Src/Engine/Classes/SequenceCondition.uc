/**
 * Base class of any sequence operation that acts as a conditional statement, such as simple boolean expression.
 * When a SequenceCondition is activated, the values for each variable linked to this conditional are retrieved.
 * The appropriate output link (which is specific to each conditional type) is then activated based on the value of the
 * those variables.
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SequenceCondition extends SequenceOp
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

defaultproperties
{
	ObjName="Undefined Condition"
	ObjColor=(R=0,G=0,B=255,A=255)
	bAutoActivateOutputLinks=false
}
