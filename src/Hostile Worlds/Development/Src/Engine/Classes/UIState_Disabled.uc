/**
 * Represents the "disabled" widget state.  Disabled widgets cannot respond to input or recieve focus.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIState_Disabled extends UIState
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
	local int i, EnabledIndex;
	local bool bResult;

	bResult = Super.ActivateState(Target, PlayerIndex);
	if ( Target != None && bResult )
	{
		// removes all states except for the enabled state, which will be removed after the disabled state is activated.
		if ( Target.HasActiveStateOfClass(class'UIState_Enabled', PlayerIndex, EnabledIndex) )
		{
			for ( i = Target.StateStack.Length - 1; i > EnabledIndex; i-- )
			{
				if ( !Target.DeactivateState(Target.StateStack[i], PlayerIndex) )
				{
					break;
				}
			}
		}

		bResult = true;
	}

	return bResult;
}

/**
 * Allows states currently in a widget's StateStack to prevent the widget from entering a new state.  This
 * function is only called for states currently in the widget's StateStack.
 *
 * @param	Target			the widget that wants to enter the new state
 * @param	NewState		the new state that widget wants to enter
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE if the widget should be allowed to enter the state specified.
 */
event bool IsStateAllowed( UIScreenObject Target, UIState NewState, int PlayerIndex )
{
	if ( Super.IsStateAllowed(Target,NewState,PlayerIndex) )
	{
		// when in the disabled state, only the enabled state is allowed
		return NewState.Class == class'UIState_Enabled';
	}

	return false;
}

DefaultProperties
{
	StackPriority=5
}
