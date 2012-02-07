/**
 * Abstract base class for UI actions.
 * Actions perform tasks for widgets, in response to some external event.  Actions are created by programmers and are
 * bound to widget events by designers using the UI editor.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIAction extends SequenceAction
	native(UISequence)
	dependson(UIRoot)
	abstract
	placeable;

/**
 * Controls whether this action is automatically executed on the owning widget.  If true, this action will add the owning
 * widget to the Targets array when it's activated, provided the Targets array is empty.
 */
var()		bool		bAutoTargetOwner;

cpptext
{
	/* === USequenceOp interface */
	/**
	 * Allows the operation to initialize the values for any VariableLinks that need to be filled prior to executing this
	 * op's logic.  This is a convenient hook for filling VariableLinks that aren't necessarily associated with an actual
	 * member variable of this op, or for VariableLinks that are used in the execution of this ops logic.
	 *
	 * Initializes the value of the Player Index VariableLinks
	 */
	virtual void InitializeLinkedVariableValues();

	virtual void Activated();
	virtual void DeActivated();

	/* === USequenceObject interface === */
	/** Get the name of the class used to help out when handling events in UnrealEd.
	 * @return	String name of the helper class.
	 */
	virtual const FString GetEdHelperClassName() const
	{
		return FString( TEXT("UnrealEd.UISequenceObjectHelper") );
	}

	/* === UObject interface === */
	/**
	 * Called after this object has been completely de-serialized.  This version validates that this action has at least one
	 * InputLink, and if not resets this action's InputLinks array to the default version
	 */
	virtual void PostLoad();
}

/**
 * Returns the widget that contains this UIAction.
 */
native final function UIScreenObject GetOwner() const;

/**
 * Returns the scene that contains this UIAction.
 */
native final function UIScene GetOwnerScene() const;

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

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
	return Super.GetObjClassVersion() + 4;
}


defaultproperties
{
	ObjCategory="UI"

	// the index for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Player Index",PropertyName=PlayerIndex,bWriteable=true,bHidden=true))

	// the gamepad id for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Gamepad Id",PropertyName=GamepadID,bWriteable=true,bHidden=true))
}
