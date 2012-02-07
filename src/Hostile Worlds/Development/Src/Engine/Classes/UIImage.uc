/**
 * A simple widget for displaying images in the UI.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIImage extends UIObject
	native(UIPrivate)
	implements(UIDataStorePublisher);

/** the data store that this image retrieves its value from */
var(Data)	private						UIDataStoreBinding		ImageDataSource;

/** Component for rendering the actual image */
var(Components)	editinline	const	noclear	UIComp_DrawImage	ImageComponent;


cpptext
{
	/*=== UUIImage interface === */
	/**
	 * Changes this UIImage's Image to the specified surface, creating a wrapper for the surface
	 * (if necessary) and applies the current ImageStyle to the new wrapper.
	 *
	 * @param	NewImage		the new surface to use for this UIImage
	 */
	virtual void SetValue( USurface* NewImage );

	/* === UIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the ImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	// UUIScreenObject interface.
	/**
	 * Render this widget.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Retrieves the current value for some data currently being interpolated by this widget.
	 *
	 * @param	AnimationType		the type of animation data to retrieve
	 * @param	out_CurrentValue	receives the current data value; animation type determines which of the fields holds the actual data value.
	 *
	 * @return	TRUE if the widget supports the animation type specified.
	 */
	virtual UBOOL Anim_GetValue( BYTE AnimationType, FUIAnimationRawData& out_CurrentValue ) const;
	/**
	 * Updates the current value for some data currently being interpolated by this widget.
	 *
	 * @param	AnimationType		the type of animation data to set
	 * @param	out_CurrentValue	contains the updated data value; animation type determines which of the fields holds the actual data value.
	 *
	 * @return	TRUE if the widget supports the animation type specified.
	 */
	virtual UBOOL Anim_SetValue( BYTE AnimationType, const FUIAnimationRawData& NewValue );

	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

	/**
	 * Called after this object has been completely de-serialized.  This version migrates values for the deprecated Image & Coordinates
	 * properties over to the ImageComponent.
	 */
	virtual void PostLoad();
}

/**
 * Changes this UIImage's Image to the specified surface, creating a wrapper for the surface
 * (if necessary) and applies the current ImageStyle to the new wrapper.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetValue( Surface NewImage )
{
	ImageComponent.SetImage(NewImage);
}

/** UIDataSourceSubscriber interface */
/**
 * Sets the data store binding for this object to the text specified.
 *
 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
 *								<DataStoreTag:DataFieldTag>
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 */
native final virtual function SetDataStoreBinding( string MarkupText, optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the markup string corresponding to the data store that this object is bound to.
 *
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	a datastore markup string which resolves to the datastore field that this object is bound to, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
native final virtual function string GetDataStoreBinding( optional int BindingIndex=INDEX_NONE ) const;

/**
 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
 *
 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
 */
native final virtual function bool RefreshSubscriberValue( optional int BindingIndex=INDEX_NONE );

/**
 * Handler for the UIDataStore.OnDataStoreValueUpdated delegate.  Used by data stores to indicate that some data provided by the data
 * has changed.  Subscribers should use this function to refresh any data store values being displayed with the updated value.
 * notify subscribers when they should refresh their values from this data store.
 *
 * @param	SourceDataStore		the data store that generated the refresh notification; useful for subscribers with multiple data store
 *								bindings, to tell which data store sent the notification.
 * @param	PropertyTag			the tag associated with the data field that was updated; Subscribers can use this tag to determine whether
 *								there is any need to refresh their data values.
 * @param	SourceProvider		for data stores which contain nested providers, the provider that contains the data which changed.
 * @param	ArrayIndex			for collection fields, indicates which element was changed.  value of INDEX_NONE indicates not an array
 *								or that the entire array was updated.
 */
native final virtual function NotifyDataStoreValueUpdated( UIDataStore SourceDataStore, bool bValuesInvalidated, name PropertyTag, UIDataProvider SourceProvider, int ArrayIndex );

/**
 * Retrieves the list of data stores bound by this subscriber.
 *
 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
 */
native final virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final function ClearBoundDataStores();

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
native final virtual function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );

DefaultProperties
{
	Position=(Value[UIFACE_Right]=50,Value[UIFACE_Bottom]=50,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner)

	PrimaryStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	ImageDataSource=(RequiredFieldType=DATATYPE_Property)

	Begin Object Class=UIComp_DrawImage Name=ImageComponentTemplate
		ImageStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	End Object
	ImageComponent=ImageComponentTemplate
}
