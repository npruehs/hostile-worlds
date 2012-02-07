/**
 * This widget presents the user with an interface for choosing a value within a certain range.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - make rendering the caption optional
 * @todo - hook up data store resolution
 */
class UISlider extends UIObject
	native(UIPrivate)
	DontAutoCollapseCategories(Data)
	implements(UIDataStorePublisher);

/** Component for rendering the slider background image */
var(Components)	editinline	const	noclear	UIComp_DrawImage			BackgroundImageComponent;

/** Component for rendering the slider bar image */
var(Components)	editinline	const	noclear	UIComp_DrawImage			SliderBarImageComponent;

/** Component for rendering the slider marker image */
var(Components)	editinline	const	noclear	UIComp_DrawImage			MarkerImageComponent;

/**
 * The data source that this slider's value will be linked to.
 */
var(Data)	editconst private				UIDataStoreBinding			DataSource;

/** Renders the caption for this slider */
var(Components)	editinline	const			UIComp_DrawStringSlider		CaptionRenderComponent;

/**
 * The value and range parameters for this slider.
 */
var(Data)									UIRangeData				SliderValue;

/** Controls whether the caption is rendered above the slider marker */
var(Appearance)									bool					bRenderCaption;

/**
 * Controls whether this slider is vertical or horizontal
 * not fully implemented
 */
var(Appearance)									EUIOrientation			SliderOrientation;

/**
 * Controls the size of the slider's bar.  If slider is horizontal, controls the height of the bar; if slider
 * is vertical, controls the width of the bar
 */
var(Appearance)								UIScreenValue_Extent		BarSize;

/** @fixme - temp....the size of the region to use for rendering the marker */
var(Appearance)								UIScreenValue_Extent		MarkerHeight, MarkerWidth;

/** this sound is played when the slider is incremented */
var(Sound)				name						IncrementCue;

/** this sound is played when the slider is decremented */
var(Sound)				name						DecrementCue;

cpptext
{
	/* === UUISlider interface === */
	/**
	 * Changes the background image for this slider, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewBarImage		the new surface to use for the slider's background image
	 */
	void SetBackgroundImage( class USurface* NewBarImage );

	/**
	 * Changes the bar image for this slider, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewBarImage		the new surface to use for the slider's bar image
	 */
	void SetBarImage( class USurface* NewBarImage );

	/**
	 * Changes the marker image for this slider, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewMarkerImage		the new surface to use for the slider's marker
	 */
	void SetMarkerImage( class USurface* NewMarkerImage );

	/**
	 * Returns the screen location (along the axis of the slider) for the marker, in absolute pixels.
	 */
	FLOAT GetMarkerPosition();

	/**
	 * Retrieves the location of the mouse within the bounding region of this slider, in percentage of the
	 * slider width (if orientation is horizontal) or height (if vertical).
	 *
	 * @param	out_Percentage	a value between 0.0 and 1.0 representing the percentage of the slider's size for the current
	 *							position of the mouse cursor.
	 *
	 * @return	TRUE if the cursor is within the bounding region of this slider.
	 */
	UBOOL GetCursorPosition( FLOAT& out_Percentage );

	/* === UUIObject interface === */
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
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the image components (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/* === UUIScreenObject interface === */
	/**
	 * Initializes the button and creates the bar image.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/**
	 * Evalutes the Position value for the specified face into an actual pixel value.  Should only be
	 * called from UIScene::ResolvePositions.  Any special-case positioning should be done in this function.
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

protected:
	/**
	 * Marks the Position for any faces dependent on the specified face, in this widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face );

public:
	/**
	 * Render this slider.
	 *
	 * @param	Canvas	the canvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

protected:
	/**
	 * Handles input events for this slider.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const FSubscribedInputEventParameters& EventParms );

	/**
	 * Processes input axis movement. Only called while the slider is in the pressed state; handles adjusting the slider
	 * value and moving the marker to the appropriate position.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputAxis( const FSubscribedInputEventParameters& EventParms );

public:
	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames( TArray<FName>& out_KeyNames );

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
	 * Transfers the old individual range values to the new UIRangeData struct and migrates values for the deprecated image values
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
 * Change the value of this slider at runtime.
 *
 * @param	NewValue			the new value for the slider.
 * @param	bPercentageValue	TRUE indicates that the new value is formatted as a percentage of the total range of this slider.
 *
 * @return	TRUE if the slider's value was changed
 */
native final function bool SetValue( coerce float NewValue, optional bool bPercentageValue );

/**
 * Gets the current value of this slider
 *
 * @param	bPercentageValue	TRUE to format the result as a percentage of the total range of this slider.
 */
native final function float GetValue( optional bool bPercentageValue ) const;

/* === Unrealscript === */
/**
 * Changes the background image for this slider, creating the wrapper UITexture if necessary.
 *
 * @param	NewBarImage		the new surface to use for the slider's background image
 */
final function SetBackgroundImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

/**
 * Changes the bar image for this slider, creating the wrapper UITexture if necessary.
 *
 * @param	NewBarImage		the new surface to use for the slider's bar image
 */
final function SetBarImage( Surface NewImage )
{
	if ( SliderBarImageComponent != None )
	{
		SliderBarImageComponent.SetImage(NewImage);
	}
}

/**
 * Changes the marker image for this slider, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new surface to use for slider's marker
 */
final function SetMarkerImage( Surface NewImage )
{
	if ( MarkerImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

/**
 * Called when a new UIState becomes the widget's currently active state, after all activation logic has occurred.
 *
 * @param	Sender					the widget that changed states.
 * @param	PlayerIndex				the index [into the GamePlayers array] for the player that activated this state.
 * @param	NewlyActiveState		the state that is now active
 * @param	PreviouslyActiveState	the state that used the be the widget's currently active state.
 */
final function OnStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	if ( Sender == Self )
	{
		if ( UIState_Pressed(NewlyActiveState) != None )
		{
			SetMouseCaptureOverride(true);
		}
		else if ( UIState_Pressed(PreviouslyActiveState) != None )
		{
			SetMouseCaptureOverride(false);
		}
	}
}

DefaultProperties
{
	NotifyActiveStateChanged=OnStateChanged

	Position=(Value[EUIWidgetFace.UIFACE_Bottom]=32,ScaleType[EUIWidgetFace.UIFACE_Bottom]=EVALPOS_PixelOwner)
	DataSource=(RequiredFieldType=DATATYPE_RangeProperty)

	bRenderCaption=true

	SliderValue=(MinValue=0.f,MaxValue=100.f,NudgeValue=1.f)
	SliderOrientation=UIORIENT_Horizontal

	BarSize=(Value=32,ScaleType=UIEXTENTEVAL_Pixels)
	MarkerWidth=(Value=16,ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Horizontal)
	MarkerHeight=(Value=16,ScaleType=UIEXTENTEVAL_Pixels,Orientation=UIORIENT_Vertical)

	PrimaryStyle=(DefaultStyleTag="DefaultSliderStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	Begin Object Class=UIComp_DrawImage Name=SliderBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultSliderStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Slider Background Style"
	End Object
	BackgroundImageComponent=SliderBackgroundImageTemplate

	Begin Object Class=UIComp_DrawImage Name=SliderBarImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultSliderBarStyle",RequiredStyleClass=class'UIStyle_Image')
		StyleResolverTag="Slider Bar Style"
	End Object
	SliderBarImageComponent=SliderBarImageTemplate

	Begin Object Class=UIComp_DrawImage Name=SliderMarkerImageTemplate
		ImageStyle=(DefaultStyleTag="DefaultSliderMarkerStyle",RequiredStyleClass=class'UIStyle_Image')
		StyleResolverTag="Slider Marker Style"
	End Object
	MarkerImageComponent=SliderMarkerImageTemplate

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	// Sounds
	IncrementCue=SliderIncrement
	DecrementCue=SliderDecrement
}
