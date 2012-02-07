/**
 * This basic widget allows the user to type text into an input field.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - auto-complete
 * @todo - multi-line support
 *
 *
 * @todo - add property to control whether change notifications are sent while the user is typing text (vs. only when the user presses enter or something).
 */
class UIEditBox extends UIObject
	native(UIPrivate)
	DontAutoCollapseCategories(Data)
	implements(UIDataStorePublisher);

/**
 * The name of the data source that this editbox's value will be associated with.
 * @todo - explain this a bit more
 */
var(Data)	private							UIDataStoreBinding		DataSource;

/** Renders the text for this editbox */
var(Components)	editinline	const	noclear	UIComp_DrawStringEditbox	StringRenderComponent;

/** Component for rendering the background image */
var(Components)	editinline	const			UIComp_DrawImage		BackgroundImageComponent;

/** The initial value to display in the editbox's text field */
var(Data)				localized			string					InitialValue<ToolTip=Initial value for editboxes that aren't bound to data stores>;

/** specifies whether the text in this editbox can be changed by user input */
var(Data)				private				bool					bReadOnly<ToolTip=Enable to prevent users from typing into this editbox>;

/** If enabled, the * character will be rendered instead of the actual text. */
var(Data)									bool					bPasswordMode<ToolTip=Displays asterisks instead of the characters typed into the editbox>;

/** the maximum number of characters that can be entered into the editbox */
var(Data)									int						MaxCharacters<ToolTip=The maximum number of character that can be entered; 0 means unlimited>;

var(Data)									EEditBoxCharacterSet	CharacterSet<ToolTip=Controls which type of characters are allowed in this editbox>;

cpptext
{
	/* === UUIEditBox interface === */
	/**
	 * Changes the background image for this widget, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewImage		the new surface to use for this UIImage
	 */
	virtual void SetBackgroundImage( class USurface* NewImage );

	/**
	 * Called whenever the user presses enter while this editbox is focused.  Activated the SubmitText kismet event and calls the
	 * OnSubmitText delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 */
	virtual void NotifySubmitText( INT PlayerIndex=INDEX_NONE );

protected:
	/**
	 * Processes special characters that affect the editbox but aren't displayed in the text field, such
	 * as arrow keys, backspace, delete, etc.
	 *
	 * Only called if this widget is in the owning scene's InputSubscriptions map for the KEY_Character key.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE if the character was processed, FALSE if it wasn't one a special character.
	 */
	virtual UBOOL ProcessControlChar( const FSubscribedInputEventParameters& EventParms );

	/**
	 * Determine whether the specified character should be displayed in the text field.
	 */
	virtual UBOOL IsValidCharacter( TCHAR Character ) const;

	/**
	 * Calculates the position of the first non-alphanumeric character that appears before the specified caret position.
	 *
	 * @param	StartingPosition	the location [index into UserText] to start searching.  If not specified, the
	 *								current caret position is used.  The character located at StartingPosition will
	 *								NOT be considered in the search.
	 *
	 * @return	an index into UserText for the location of the first non-alphanumeric character that appears
	 *			before the current caret position, or 0 if the beginning of the string is reached first.
	 */
	virtual INT FindPreviousCaretJumpPosition( INT StartingPosition=INDEX_NONE ) const;

	/**
	 * Calculates the position of the first non-alphanumeric character that appears after the current caret position.
	 *
	 * @param	StartingPosition	the location [index into UserText] to start searching.  If not specified, the
	 *								current caret position is used.  The character located at StartingPosition will
	 *								NOT be considered in the search.
	 *
	 * @return	an index into UserText for the location of the first non-alphanumeric character that appears
	 *			after the current caret position, or the length of the string if the end of the string is reached first.
	 */
	virtual INT FindNextCaretJumpPosition( INT StartingPosition=INDEX_NONE ) const;

public:
	/* === UUIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the BackgroundImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/**
	 * Called whenever the editbox's text is modified.  Activates the TextValueChanged kismet event and calls the OnValueChanged
	 * delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 * @param	NotifyFlags		optional parameter for individual widgets to use for passing additional information about the notification.
	 */
	virtual void NotifyValueChanged( INT PlayerIndex=INDEX_NONE, INT NotifyFlags=0 );

	/**
	 * Render this editbox.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	void Render_Widget( FCanvas* Canvas );

protected:
	/* === UUIScreenObject interface === */
	/**
	 * Handles input events for this editbox.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const FSubscribedInputEventParameters& EventParms );

	/**
	 * Processes input axis movement. Only called while the editbox is in the pressed state; updates the selection region
	 * according to the current mouse position.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputAxis( const FSubscribedInputEventParameters& EventParms );

public:

	/**
	 * Initializes the button and creates the background image.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );

	/**
	 * Adds the specified face to the DockingStack for the specified widget
	 *
	 * @param	DockingStack	the docking stack to add this docking node to.  Generally the scene's DockingStack.
	 * @param	Face			the face that should be added
	 *
	 * @return	TRUE if a docking node was added to the scene's DockingStack for the specified face, or if a docking node already
	 *			existed in the stack for the specified face of this widget.
	 */
	virtual UBOOL AddDockingNode( TArray<FUIDockingNode>& DockingStack, EUIWidgetFace Face );

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

	/**
	 * Activates the UIState_Focused menu state and updates the pertinent members of FocusControls.
	 *
	 * @param	FocusedChild	the child of this widget that should become the "focused" control for this widget.
	 *							A value of NULL indicates that there is no focused child.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL GainFocus( UUIObject* FocusedChild, INT PlayerIndex );

public:
	/**
	 * Changes this widget's position to the specified value.  This version changes the default value for the bClampValues parameter to TRUE
	 *
	 * @param	LeftFace		the value (in pixels or percentage) to set the left face to
	 * @param	TopFace			the value (in pixels or percentage) to set the top face to
	 * @param	RightFace		the value (in pixels or percentage) to set the right face to
	 * @param	BottomFace		the value (in pixels or percentage) to set the bottom face to
	 * @param	InputType		indicates the format of the input value.  All values will be evaluated as this type.
	 *								EVALPOS_None:
	 *									NewValue will be considered to be in whichever format is configured as the ScaleType for the specified face
	 *								EVALPOS_PercentageOwner:
	 *								EVALPOS_PercentageScene:
	 *								EVALPOS_PercentageViewport:
	 *									Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
	 *									base's actual size.
	 *								EVALPOS_PixelOwner
	 *								EVALPOS_PixelScene
	 *								EVALPOS_PixelViewport
	 *									Indicates that NewValue is an actual pixel value, relative to the corresponding base.
	 * @param	bIncludesViewportOrigin
	 *							TRUE indicates that the value is relative to the 0,0 on the screen (or absolute position); FALSE to indicate
	 *							the value is relative to the viewport's origin.
	 * @param	bClampValues	if TRUE, clamps the values of RightFace and BottomFace so that they cannot be less than the values for LeftFace and TopFace
	 */
	virtual void SetPosition( const FLOAT LeftFace, const FLOAT TopFace, const FLOAT RightFace, const FLOAT BottomFace, EPositionEvalType InputType=EVALPOS_PixelViewport, UBOOL bIncludesViewportOrigin=FALSE, UBOOL bClampValues=TRUE )
	{
		Super::SetPosition(LeftFace, TopFace, RightFace, BottomFace, InputType, bIncludesViewportOrigin, bClampValues);
	}

	/**
	 * Adds the specified character to the editbox's text field, if the text field is currently eligible to receive
	 * new characters
	 *
	 * Only called if this widget is in the owning scene's InputSubscriptions map for the KEY_Unicode key.
	 *
	 * @param	PlayerIndex		index [into the Engine.GamePlayers array] of the player that generated this event
	 * @param	Character		the character that was received
	 *
	 * @return	TRUE to consume the character, false to pass it on.
	 */
	virtual UBOOL ProcessInputChar( INT PlayerIndex, TCHAR Character );

	/**
	 * Called when a property is modified that could potentially affect the widget's position onscreen.
	 */
	virtual void RefreshPosition();

	/**
	 * Called to globally update the formatting of all UIStrings.
	 */
	virtual void RefreshFormatting( UBOOL bRequestSceneUpdate=TRUE );

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
	 * Called after this object has been completely de-serialized.  This version migrates values for the deprecated EditBoxBackground
	 * and Coordinates properties over to the BackgroundImageComponent.
	 */
	virtual void PostLoad();
}

/* == Delegates == */
/**
 * Called when the user presses enter (or any other action bound to UIKey_SubmitText) while this editbox has focus.
 *
 * @param	Sender	the editbox that is submitting text
 * @param	PlayerIndex		the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 *
 * @return	if TRUE, the editbox will clear the existing value of its textbox.
 */
delegate bool OnSubmitText( UIEditBox Sender, int PlayerIndex );

/* === Natives === */
/**
 * Changes the background image for this editbox.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetBackgroundImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

/**
 * Change the value of this editbox at runtime.
 *
 * @param	NewText				the new text that should be displayed in the label
 * @param	PlayerIndex			the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *								UIEvents
 * @param	bSkipNotification	specify TRUE to prevent the OnValueChanged delegate from being called.
 */
native final function SetValue( string NewText, optional int PlayerIndex=GetBestPlayerIndex(), optional bool bSkipNotification );

/**
 * Gets the text that is currently in this editbox
 *
 * @param	bReturnUserText		if TRUE, returns the text typed into the editbox by the user;  if FALSE, returns the resolved value
 *								of this editbox's data store binding.
 */
native final function string GetValue( optional bool bReturnUserText=true ) const;

/**
 * Calculates the character position for the point under the mouse or joystick cursor
 *
 * @param	PlayerIndex			the index of the player that generated the call to this method; if not specified,
 *								the value of GetBestPlayerIndex() is used instead.
 *
 * @return	the index into the editbox's value string for character under the mouse/joystick cursor.  If the cursor is within the
 *			"client region" of the editbox but not over a character (for example, if the string is very short and the mouse
 *			is hovering towards the right side of the region), then the length of the editbox's value string is returend.  Otherwise,
 *			returns INDEX_NONE,
 */
native function int CalculateCaretPositionFromCursorLocation( optional int PlayerIndex=GetBestPlayerIndex() ) const;

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
native virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

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
native virtual function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );

/* === Events === */
event Initialized()
{
	Super.Initialized();

	if ( EventProvider != None )
	{
		if ( bReadOnly )
		{
			EventProvider.DisabledEventAliases.AddItem('Consume');
		}
		else
		{
			EventProvider.DisabledEventAliases.RemoveItem('Consume');
		}
	}
}

/* === Unrealscript === */
/**
 * @return	TRUE if this editbox is readonly
 */
final function bool IsReadOnly()
{
	return bReadOnly;
}

/**
 * Changes whether this editbox is read-only.
 *
 * @param	bShouldBeReadOnly	TRUE if the editbox should be read-only.
 */
function SetReadOnly( bool bShouldBeReadOnly )
{
	bReadOnly = bShouldBeReadOnly;
	if ( EventProvider != None )
	{
		if ( bReadOnly )
		{
			EventProvider.DisabledEventAliases.AddItem('Consume');
		}
		else
		{
			EventProvider.DisabledEventAliases.RemoveItem('Consume');

			//@todo ronp - if this editbox is already in the focused/enabled state, we'll need to re-register the input
			// keys for that state.
		}
	}
}

/**
 * Changes whether this editbox's string should process markup
 *
 * @param	bShouldIgnoreMarkup		if TRUE, markup will not be processed by this editbox's string
 *
 * @note: does not update any existing text contained by the editbox.
 */
final function IgnoreMarkup( bool bShouldIgnoreMarkup )
{
	StringRenderComponent.bIgnoreMarkup = bShouldIgnoreMarkup;
}

DefaultProperties
{
	PrimaryStyle=(DefaultStyleTag="DefaultEditboxStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	DataSource=(RequiredFieldType=DATATYPE_Property)
	bSupportsPrimaryStyle=false

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	// Rendering
	Begin Object Class=UIComp_DrawStringEditbox Name=EditboxStringRenderer
		bIgnoreMarkup=true
		StringCaret=(bDisplayCaret=true)
	End Object
	StringRenderComponent=EditboxStringRenderer

	Begin Object class=UIComp_DrawImage Name=EditboxBackgroundTemplate
		ImageStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=EditboxBackgroundTemplate

	CharacterSet=CHARSET_All
}
