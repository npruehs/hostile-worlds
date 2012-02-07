/**
 * Default widget state.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIState_Enabled extends UIState
	native(inherit);

cpptext
{
	/**
	 * Notification that Target has made this state its active state.
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
	StackPriority=5
}
