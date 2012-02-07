/**
 * Opens a new scene.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_OpenScene extends UIAction_Scene
	native(inherit);

/** Output variable for the scene that was opened. */
var	UIScene		OpenedScene;

/**
 * the index for the player that should be set as the player owner of the scene being opened.  Value of -1 indicates that the player index
 * should come from the op that applies impulse to this op's input link
 */
var()	int		DesiredPlayerIndex;

cpptext
{
	/* === USequenceOp interface === */
	/**
	 * Opens the scene specified by this action.
	 *
	 * @note: this action must be safe to execute from outside the scope of the UI system, since it can be used
	 *			in level sequences.
	 */
	virtual void Activated();

	/**
	 * Called after all the op has been deactivated and all linked variable values have been propagated to the next op
	 * in the sequence.
	 *
	 * This version clears the value of OpenedScene.
	 */
    virtual void PostDeActivated();
}

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

DefaultProperties
{
	DesiredPlayerIndex=INDEX_NONE

	ObjName="Open Scene"
	VariableLinks.Add((ExpectedType=class'SeqVar_Object',LinkDesc="Opened Scene",PropertyName=OpenedScene,bWriteable=true))

	// the index for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Player Index Override",PropertyName=DesiredPlayerIndex,bHidden=true))
}
