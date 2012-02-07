/**
 * Represents the "active" widget state.  This state indicates that the widget is currently being moused over or
 * is otherwise selected without necessarily having focus.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIState_Active extends UIState
	native(UIPrivate);

cpptext
{
	/**
	 * Activate this state for the specified target.  This version ensures that the StackPriority for the Active and
	 * Pressed states have been reset to their default values.
	 *
	 * @param	Target			the widget that is activating this state.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
	 *
	 * @return	TRUE if Target's StateStack was modified; FALSE if this state couldn't be activated for the specified
	 *			Target or this state was already part of the Target's state stack.
	 */
	virtual UBOOL ActivateState( UUIScreenObject* Target, INT PlayerIndex );

	/**
	 * Deactivate this state for the specified target.  This version changes the StackPriority on the Active and Pressed states
	 * so that the widget uses the style data from whichever state the widget was previously in.
	 *
	 * @param	Target			the widget that is deactivating this state.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
	 *
	 * @return	TRUE if Target's StateStack was modified; FALSE if this state couldn't be deactivated for the specified
	 *			Target or this state wasn't part of the Target's state stack.
	 */
	virtual UBOOL DeactivateState( UUIScreenObject* Target, INT PlayerIndex );

	/**
	 * Notification that Target has made this state its active state.
	 *
	 * @param	Target			the widget that activated this state.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
	 * @param	bPushState		TRUE if this state needs to be added to the state stack for the owning widget; FALSE if this state was already
	 *							in the state stack of the owning widget and is being activated for additional split-screen players.
	 */
	virtual void OnActivate( UUIScreenObject* Target, INT PlayerIndex, UBOOL bPushState );

	/**
	 * Notification that Target has just deactivated this state.
	 *
	 * @param	Target			the widget that deactivated this state.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
	 * @param	bPopState		TRUE if this state needs to be removed from the owning widget's StateStack; FALSE if this state is
	 *							still active for at least one player (i.e. in splitscreen)
	 */
	virtual void OnDeactivate( UUIScreenObject* Target, INT PlayerIndex, UBOOL bPopState );
}

DefaultProperties
{
	StackPriority=15
}
