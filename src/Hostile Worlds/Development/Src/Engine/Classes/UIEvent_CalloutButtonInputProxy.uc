/**
 * This specialized UIEvent class serves as a container for the input keys associated with the UICalloutButtons contained
 * in a scene.  It is automatically added and removed from the scene's sequence based on whether the scene contains
 * a UICalloutButtonPanel object; it is never added by a designer and isn't visible in the UI editor's list of available
 * sequence events.
 *
 * The output links of this event are dictated by the input aliases assigned to the UICalloutButtons contained within the
 * scene.  Each UICalloutButton in the scene will be represented by an output link which is only activated by the input key
 * associated with that button.
 *
 * There are two ways for users to add output links to instances of this event class.
 * Designers can add output links to this event directly.  Doing so causes a new UICalloutButton to be automatically
 * inserted into the callout panel and assigned whichever alias is associated with the input key used to create the new
 * output link.
 * Alternately (and likely the more common case), when a designer adds a new callout button to a UICalloutButtonPanel,
 * an output link is created in this event object for the input key associated with that callout button's input alias.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent_CalloutButtonInputProxy extends UIEvent
	native(inherit);

/**
 * Reference to the callout panel this proxy is associated with.  Only useful when scenes contain more than one UICalloutButtonPanel.
 */
var		const		UICalloutButtonPanel		ButtonPanel;

cpptext
{
	/* === USequenceOp interface === */
	/**
	 * Called when this object is updated; repopulates the outputlinks array with the button aliases from the associated panel
	 */
	virtual void UpdateDynamicLinks();

	/* === USequenceObject interface === */
	/**
	 * Get the name of the class to use for handling user interaction events (such as mouse-clicks) with this sequence object
	 * in the kismet editor.
	 *
	 * @return	a string containing the path name of a class in an editor package which can handle user input events for this
	 *			sequence object.
	 */
	virtual const FString GetEdHelperClassName() const;

	/**
	 * Provides a way for non-deletable SequenceObjects (those with bDeletable=false) to be removed programatically.  The
	 * user will not be able to remove this object from the sequence via the UI, but calls to RemoveObject will succeed.
	 */
	virtual UBOOL IsDeletable() const { return TRUE; }
}

/* == Delegates == */

/* == Natives == */

/**
 * Creates a new output link using an input key name.
 *
 * @param	InputKeyName	the name of the input key (i.e. KEY_LeftMouseButton) to associate with the output link
 *
 * @return	TRUE if the key was successfully added to the list of outputs
 */
//native final function bool RegisterInputKey( name InputKeyName );

/**
 * Removes the output link associated with the key specified.
 *
 * @param	InputKeyName	the name of the input key (i.e. KEY_LeftMouseButton) to remove
 *
 * @return	TRUE if the key was successfully removed
 */
//native final function bool UnregisterInputKey( name InputKeyName );

/**
 * Creates a new output link using the specified alias.
 *
 * @param	ButtonAliasName		the name of the input alias assigned to a button in a UICalloutButtonBar
 *
 * @return	TRUE if the output link was successfully created for the alias
 */
native final function bool RegisterButtonAlias( name ButtonAliasName );

/**
 * Removes the output link associated with the button input alias specified.
 *
 * @param	ButtonAliasName		the name of the input alias assigned a button in a UICalloutButtonBar
 *
 * @return	TRUE if an output link for the alias was found and removed successfully.
 */
native final function bool UnregisterButtonAlias( name ButtonAliasName );

/**
 * Changes the button input alias associated with an output link, preserving the connections to any linked actions.
 *
 * @param	CurrentAliasName		the name of the button alias to replace
 * @param	NewAliasName			the name of the button alias to use instead
 *
 * @return	TRUE if the key was successfully replaced
 */
native final function bool ChangeButtonAlias( name CurrentAliasName, name NewAliasName );

/**
 * Find the location of the specified button input alias in this event's list of output links.
 *
 * @param	ButtonAliasName		the name of the button alias to find
 *
 * @return	an index into the OutputLinks array for the output associated with the specified button, or INDEX_NONE if
 *			it isn't found.
 */
native final function int FindButtonAliasIndex( name ButtonAliasName ) const;

/* == Events == */
/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	// we don't want this class to appear in the list of available events.
	return false;
}

/**
 * Determines whether objects of this class are allowed to be pasted into UI sequences.
 *
 * @return	TRUE if this sequence object can be pasted into UI sequences.
 */
event bool IsPastingIntoUISequenceAllowed()
{
	// pasting this object into UI sequences is allowed
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

/* == UnrealScript == */

/* == SequenceAction handlers == */

DefaultProperties
{
	ObjName="Callout Button Input Proxy"
	bDeletable=false

	// give it a sane default position
	ObjPosX=56
	ObjPosY=96

	// give it a different color to indicate that the designer cannot interact with it.
	ObjColor=(R=70,G=135,B=255,A=255)

	// clear all output links
	OutputLinks.Empty

	// don't auto-activate anything.
	bAutoActivateOutputLinks=false

	// this event only exists in a UIScene but we want to be able to activate it from child widgets
	bPropagateEvent=true

}
