/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKTabPage extends UITabPage
	native;

/** If true, this object require tick */
var bool bRequiresTick;

cpptext
{
	virtual void Tick_Widget(FLOAT DeltaTime);

	/* === UUIScreenObject interface === */

	/**
	 * Perform all initialization for this widget. Called on all widgets when a scene is opened,
	 * once the scene has been completely initialized.
	 * For widgets added at runtime, called after the widget has been inserted into its parent's
	 * list of children.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );
}

/** Delegate for when the tab page is ticked. */
delegate OnTick(float DeltaTime);

function OnChildRepositioned( UIScreenObject Sender );

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	return false;
}

/**
 * Closes the parent Scene
 */
function CloseParentScene()
{
	local UDKUIScene S;

	S = UDKUIScene(GetScene());
	if ( S != none )
	{
		S.CloseScene(S);
	}
}

defaultproperties
{
}
