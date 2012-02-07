/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*
* Extended version of UIList for UT3.
*/
class UDKUIList extends UIList
	native;

/** Whether or not this list should be able to save out to its dataprovider. */
var transient bool bAllowSaving;

cpptext
{
	/* === UIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the BackgroundImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/* === UUIScreenObject interface === */
	/**
	 * Render this widget.  This version routes the render call to the draw components, if applicable.
	 *
	 * @param	Canvas	the canvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
	
	virtual void RenderBackgroundImage( FCanvas* Canvas, const FRenderParameters& Parameters ) {}
}

/**
 * Resolves this subscriber's data store binding and publishes this subscriber's value to the appropriate data store.
 *
 * @param	out_BoundDataStores	contains the array of data stores that widgets have saved values to.  Each widget that
 *								implements this method should add its resolved data store to this array after data values have been
 *								published.  Once SaveSubscriberValue has been called on all widgets in a scene, OnCommit will be called
 *								on all data stores in this array.
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	TRUE if the value was successfully published to the data store.
 */
native virtual function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );

DefaultProperties
{
	// No UT lists nav up or down, so disable these events.
	Begin Object Name=WidgetEventComponent
		DisabledEventAliases.Add(NavFocusUp)
		DisabledEventAliases.Add(NavFocusDown)
	End Object

	bAllowSaving=true
}
