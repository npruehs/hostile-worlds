/**
 * Activated when a widget that responds to mouse button clicks receives a button down event, and is deactivated when
 * the widget receives the corresonding button up event.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * @note: native because C++ code activates this state
 */
class UIState_Pressed extends UIState
	native(UIPrivate);

cpptext
{
	/**
	 * Notification that Target has made this state its active state.
	 *
	 * This version activates the focused state for the widget as well.
	 *
	 * @param	Target			the widget that activated this state.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
	 * @param	bPushState		TRUE if this state needs to be added to the state stack for the owning widget; FALSE if this state was already
	 *							in the state stack of the owning widget and is being activated for additional split-screen players.
	 */
	virtual void OnActivate( UUIScreenObject* Target, INT PlayerIndex, UBOOL bPushState );
}


DefaultProperties
{
	StackPriority=20
}
