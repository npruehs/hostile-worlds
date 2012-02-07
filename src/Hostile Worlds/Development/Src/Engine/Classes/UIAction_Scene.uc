/**
 * Base class for all actions that manipulate scenes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_Scene extends UIAction
	abstract
	native(UISequence);

const ACTION_SUCCESS_INDEX=0;
const ACTION_FAILURE_INDEX=1;
/** the default priority for all UIScenes */
const DEFAULT_SCENE_PRIORITY=10;

/** the scene that this action will manipulate */
var()	UIScene		Scene;

/** Allows the designer to override the scene's default stack priority */
var()	byte		ForcedScenePriority;

cpptext
{
	/** USequenceOp interface */
	/**
	 * Allows the operation to initialize the values for any VariableLinks that need to be filled prior to executing this
	 * op's logic.  This is a convenient hook for filling VariableLinks that aren't necessarily associated with an actual
	 * member variable of this op, or for VariableLinks that are used in the execution of this ops logic.
	 *
	 * Initializes the value of the Scene linked variables
	 */
	virtual void InitializeLinkedVariableValues();
}

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return true;
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
	ObjCategory="UI Scenes"
	bAutoActivateOutputLinks=false
	bCallHandler=false

	ForcedScenePriority=DEFAULT_SCENE_PRIORITY

	OutputLinks(ACTION_SUCCESS_INDEX)=(LinkDesc="Success")
	OutputLinks(ACTION_FAILURE_INDEX)=(LinkDesc="Failed")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Scene",PropertyName=Scene)
}
