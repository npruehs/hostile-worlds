/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Modified version of button that fires events when the user begins and ends press, also doesn't accept focus on the console
 */
class UTUIPressButton extends UIButton;

/** Delegates for when the user starts and ends their press of the buttons. */
delegate OnBeginPress(UIScreenObject InObject, INT InPlayerIndex);
delegate OnEndPress(UIScreenObject InObject, INT InPlayerIndex);

/** Input handling, fires press/released delegates. */
function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	if ( EventParms.InputAliasName=='Clicked' )
	{
		if (EventParms.EventType==IE_Pressed || EventParms.EventType==IE_DoubleClick)
		{
			OnBeginPress(self, EventParms.PlayerIndex);
		}
		else if(EventParms.EventType==IE_Released)
		{
			OnEndPress(self, EventParms.PlayerIndex);
		}
	}

	return false; // Purposely call super process input key even if we handled the key.
}

/** === Focus Handling === */
/**
 * Determines whether this widget can become the focused control.
 *
 * @param	PlayerIndex					the index [into the Engine.GamePlayers array] for the player to check focus availability
 * @param	bIncludeParentVisibility	indicates whether the widget should consider the visibility of its parent widgets when determining
 *										whether it is eligible to receive focus.  Only needed when building navigation networks, where the
 *										widget might start out hidden (such as UITabPanel).
 *
 * @return	TRUE if this widget (or any of its children) is capable of becoming the focused control.
 */
function bool CanAcceptFocus( optional int PlayerIndex=0, optional bool bIncludeParentVisibility=true )
{
	return !IsConsole() && Super.CanAcceptFocus(PlayerIndex,bIncludeParentVisibility);
}

defaultproperties
{
	OnProcessInputKey=ProcessInputKey
}
