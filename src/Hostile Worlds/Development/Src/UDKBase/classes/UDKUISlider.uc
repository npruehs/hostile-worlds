/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Extended version of the slider for UT3.
 */
class UDKUISlider extends UISlider
	native;

cpptext
{
public:
	/**
	 * Initializes the button and creates the bar image.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/**
	 * Render this slider.
	 *
	 * @param	Canvas	the canvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Called whenever the value of the slider is modified.  Activates the SliderValueChanged kismet event and calls the OnValueChanged
	 * delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 * @param	NotifyFlags		optional parameter for individual widgets to use for passing additional information about the notification.
	 */
	virtual void NotifyValueChanged( INT PlayerIndex=INDEX_NONE, INT NotifyFlags=0 );

	/**
	 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
	 *
	 * @param	BindingIndex		indicates which data store binding should be modified.
	 *
	 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
	 */
	virtual UBOOL RefreshSubscriberValue(INT BindingIndex=INDEX_NONE);
}

/** Updates the slider's caption render component. */
native virtual function UpdateCaption();

defaultproperties
{
	BarSize=(Value=16.0)
	MarkerWidth=(Value=32.0)
	MarkerHeight=(Value=32.0)
}
