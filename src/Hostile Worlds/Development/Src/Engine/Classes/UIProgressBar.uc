/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */



class UIProgressBar extends UIObject
	native(UIPrivate)
	DontAutoCollapseCategories(Data)
	implements(UIDataStorePublisher);

/** Component for rendering the background image */
var(Components)	editinline	const	noclear	UIComp_DrawImage		BackgroundImageComponent;

/** Component for rendering the fill image */
var(Components)	editinline	const	noclear	UIComp_DrawImage		FillImageComponent;

/** Component for rendering the overlay image */
var(Components)	editinline	const	noclear	UIComp_DrawImage		OverlayImageComponent;

/**
 * specifies whether to draw the overlay texture or not
 */
var(Appearance)								bool					bDrawOverlay;

/**
 * The data source that this progressbar's value will be linked to.
 */
var(Data)	editconst private				UIDataStoreBinding		DataSource;

/**
 * The value and range parameters for this progressbar.
 */
var(Data)									UIRangeData				ProgressBarValue;

/**
 * Controls whether this progressbar is vertical or horizontal
 */
var(Appearance)								EUIOrientation			ProgressBarOrientation;

cpptext
{
	/* === UUIProgressBar interface === */
	/**
	 * Changes the background image for this progressbar, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewBarImage		the new surface to use for the progressbar's background image
	 */
	void SetBackgroundImage( class USurface* NewBarImage );

	/**
	 * Changes the fill image for this progressbar, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewFillImage		the new surface to use for the progressbar's marker
	 */
	void SetFillImage( class USurface* NewFillImage );

	/**
	 * Changes the overlay image for this progressbar, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewOverlayImage		the new surface to use for the progressbar's overlay image
	 */
	void SetOverlayImage( class USurface* NewOverlayImage );

	/**
	 * Returns the pixel extent of the progressbar fill based on the current progressbar value
	 */
	FLOAT GetBarFillExtent();

	/* === UIObject interface === */
	/**
	 * Called whenever the value of the progressbar is modified.  Activates the ProgressBarValueChanged kismet event and calls the OnValueChanged
	 * delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 * @param	NotifyFlags		optional parameter for individual widgets to use for passing additional information about the notification.
	 */
	virtual void NotifyValueChanged( INT PlayerIndex=INDEX_NONE, INT NotifyFlags=0 );

	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the image components (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/* === UUIScreenObject interface === */

	/**
	 * Render this progressbar.
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

	/**
	 * Called after this object has been completely de-serialized.  This version migrates values for the deprecated image values
	 * over to the corresponding components.
	 */
	virtual void PostLoad();
}

/* === Natives === */

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

/**
 * Change the value of this progressbar at runtime.
 *
 * @param	NewValue			the new value for the progressbar.
 * @param	bPercentageValue	TRUE indicates that the new value is formatted as a percentage of the total range of this progressbar.
 *
 * @return	TRUE if the progressbar's value was changed
 */
native final function bool SetValue( coerce float NewValue, optional bool bPercentageValue );

/**
 * Gets the current value of this progressbar
 *
 * @param	bPercentageValue	TRUE to format the result as a percentage of the total range of this progressbar.
 */
native final function float GetValue( optional bool bPercentageValue ) const;

/* === Unrealscript === */
/**
 * Changes the background image for this progressbar, creating the wrapper UITexture if necessary.
 *
 * @param	NewBarImage		the new surface to use for the progressbar's background image
 */
final function SetBackgroundImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

/**
 * Changes the fill image for this progressbar, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new surface to use for progressbar's marker
 */
final function SetFillImage( Surface NewImage )
{
	if ( FillImageComponent != None )
	{
		FillImageComponent.SetImage(NewImage);
	}
}

/**
 * Changes the overlay image for this progressbar, creating the wrapper UITexture if necessary.
 *
 * @param	NewOverlayImage		the new surface to use for the progressbar's overlay image
 */
final function SetOverlayImage( Surface NewImage )
{
	if ( OverlayImageComponent != None )
	{
		OverlayImageComponent.SetImage(NewImage);
	}
}

DefaultProperties
{
	Position=(Value[EUIWidgetFace.UIFACE_Bottom]=32,ScaleType[EUIWidgetFace.UIFACE_Bottom]=EVALPOS_PixelOwner)
	DataSource=(RequiredFieldType=DATATYPE_RangeProperty)

	bDrawOverlay=false

	ProgressBarValue=(MinValue=0.f,MaxValue=100.f,NudgeValue=1.f,CurrentValue=33.f)
	ProgressBarOrientation=UIORIENT_Horizontal

	PrimaryStyle=(DefaultStyleTag="DefaultSliderStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	Begin Object Class=UIComp_DrawImage Name=ProgressBarBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultSliderStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=ProgressBarBackgroundImageTemplate

	Begin Object Class=UIComp_DrawImage Name=ProgressBarFillImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultSliderBarStyle",RequiredStyleClass=class'UIStyle_Image')
		StyleResolverTag="Fill Image Style"
	End Object
	FillImageComponent=ProgressBarFillImageTemplate

	Begin Object Class=UIComp_DrawImage Name=ProgressBarOverlayImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'UIStyle_Image')
		StyleResolverTag="Overlay Image Style"
	End Object
	OverlayImageComponent=ProgressBarOverlayImageTemplate

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')
}
