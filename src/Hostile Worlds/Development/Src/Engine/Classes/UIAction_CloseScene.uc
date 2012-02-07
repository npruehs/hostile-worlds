/**
 * Closes a scene.  If no scene is specified and bAutoTargetOwner is true for this action, closes the owner scene.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_CloseScene extends UIAction_Scene
	native(inherit);

cpptext
{
	/* === USequenceOp interface === */
	/**
	 * Closes the scene specified by this action.
	 *
	 * @note: this action must be safe to execute from outside the scope of the UI system, since it can be used
	 *			in level sequences.
	 */
	virtual void Activated();
}

DefaultProperties
{
	ObjName="Close Scene"

	bAutoTargetOwner=true
}
