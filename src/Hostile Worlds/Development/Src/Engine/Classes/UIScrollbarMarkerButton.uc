/**
 * A special button used as the marker in the UIScrollbar class.  It processes input axis events while in the pressed state and
 * sends notifications to the owning scrollbar widget.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIScrollbarMarkerButton extends UIScrollbarButton
	native(inherit)
	notplaceable;

cpptext
{
	/* === UUIObject interface === */
	/**
	 * Function overwritten to autoposition the scrollbar within the owner widget
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

	/* === UUIScreenObject interface === */
	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames( TArray<FName>& out_KeyNames );

	/**
	 * Determines whether this widget should process the specified axis input event (mouse/joystick movement).
	 * If the widget is configured to respond to this axis input event, any actions associated with
	 * this input event are activated.
	 *
	 * Only called if this widget is in the owning scene's InputSubscribers map for the corresponding key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the axis movement, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputAxis( const struct FSubscribedInputEventParameters& EventParms );
}

/* == Delegates == */
/**
 * Called when the user presses the button and draggs it with a mouse
 * @param	Sender			the button that is submitting the event
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
delegate OnButtonDragged( UIScrollbarMarkerButton Sender, int PlayerIndex );

defaultproperties
{
	// the StyleResolverTags must match the name of the property in the owning scrollbar control in order for SetWidgetStyle to work correctly.
	Begin Object Name=BackgroundImageTemplate
		StyleResolverTag="MarkerStyle"
	End Object
}

