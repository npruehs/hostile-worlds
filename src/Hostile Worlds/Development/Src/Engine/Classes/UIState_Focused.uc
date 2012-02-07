/**
 * Represents the "focused" widget state.  Focused widgets recieve the first chance to process input events.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIState_Focused extends UIState
	native(UIPrivate)
	hidedropdown;

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

/**
 * Activate this state for the specified target.
 *
 * @param	Target			the widget that is activating this state.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE to allow this state to be activated for the specified Target.
 */
event bool ActivateState( UIScreenObject Target, int PlayerIndex )
{
	local bool bResult;

	bResult = Super.ActivateState(Target,PlayerIndex);
	if ( Target != None )
	{
		// ensure that Target has the enabled state on its StateStack
		bResult = Target.HasActiveStateOfClass(class'UIState_Enabled',PlayerIndex);
	}

	return bResult;
}

DefaultProperties
{
	StackPriority=10
}
