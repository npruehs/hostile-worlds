/**
 * This conditional is used to branch based on whether some widget has focus.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UICond_IsFocused extends SequenceCondition
	native(UISequence);

/**
 * Used to ensure output link indices are synchronized between native and script.
 */
enum ECondIsFocusedResultIndex
{
	ISFOCUSEDRESULT_True,
	ISFOCUSEDRESULT_False,
};

cpptext
{
	/**
	 * Checks whether the target widget has focus and activates the appropriate output link.
	 */
	virtual void Activated();
}

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

DefaultProperties
{
	ObjName="Is Focused"
	ObjCategory="Focus"

	OutputLinks(ISFOCUSEDRESULT_True)=(LinkDesc="True")
	OutputLinks(ISFOCUSEDRESULT_False)=(LinkDesc="False")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target")
}
