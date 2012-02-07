/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Option widget that works similar to a read only combobox.
 */
class UDKUIOptionButton extends UDKUI_Widget
	native
	placeable
	DontAutoCollapseCategories(Data)
	implements(UIDataStorePublisher);

/** UI Key Action Events */
const UIKEY_MoveCursorLeft = 'UIKEY_MoveCursorLeft';
const UIKEY_MoveCursorRight = 'UIKEY_MoveCursorRight';

/** Arrow enums. */
enum EOptionButtonArrow
{
	OPTBUT_ArrowLeft,
	OPTBUT_ArrowRight
};

cpptext
{
	/* === UUIScreenObject interface === */

	/**
	 * Perform all initialization for this widget. Called on all widgets when a scene is opened,
	 * once the scene has been completely initialized.
	 * For widgets added at runtime, called after the widget has been inserted into its parent's
	 * list of children.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/* === UUIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the LabelBackground (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/**
	 * Called when a style reference is resolved successfully.
	 *
	 * @param	ResolvedStyle			the style resolved by the style reference
	 * @param	StyleProperty			the name of the style reference property that was resolved.
	 * @param	ArrayIndex				the array index of the style reference that was resolved.  should only be >0 for style reference arrays.
	 * @param	bInvalidateStyleData	if TRUE, the resolved style is different than the style that was previously resolved by this style reference.
	 */
	virtual void OnStyleResolved( UUIStyle* ResolvedStyle, const struct FStyleReferenceId& StyleProperty, INT ArrayIndex, UBOOL bInvalidateStyleData );

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

public:

	/**
	 * Called when a property is modified that could potentially affect the widget's position onscreen.
	 */
	virtual void RefreshPosition();

	/**
	 * Called to globally update the formatting of all UIStrings.
	 */
	virtual void RefreshFormatting( UBOOL bRequestSceneUpdate=TRUE );

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );

	/**
	 * Render this button.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Resolves DataSource into the list element provider that it references.
	 */
	void ResolveListElementProvider();

protected:
	/**
	 * Called when the option button's index has changed.
	 *
	 * @param	PreviousIndex	the list's Index before it was changed
	 * @param	PlayerIndex		the index of the player associated with this index change.
	 */
	void NotifyIndexChanged( INT PreviousIndex, INT PlayerIndex );

	/** @return Returns the number of possible values for the field we are bound to. */
	INT GetNumValues();

	/**
	 * @param ListIndex		List index to get the value of.
	 * @param OutValue	Storage string for the list value
	 *
	 * @return Returns TRUE if we were able to get a value, FALSE otherwise
	 */
	UBOOL GetListValue(INT ListIndex, FString &OutValue);

	/**
	 * Retrieves all values (along with their associated ids) for the collection this option button is bound to.
	 *
	 * @param	out_ValueCollection		receives the list of ids/strings contained in the collection this button is bound to
	 *
	 * @return	TRUE if the output value was successfully filled in (even if it's empty); FALSE if the button isn't bound or the data store
	 *			couldn't be resolved.
	 */
	UBOOL GetCollectionValues( TMap<INT,FString>& out_ValueCollection );

	/** Updates the string value using the current index. */
	void UpdateCurrentStringValue();

	/**
	 * Handles input events for this list.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const struct FSubscribedInputEventParameters& EventParms );

	/**
	 * Handles input events for this button.
	 *
	 * @param	InState		State class to activate.
	 * @param	Arrow		Which arrow to activate the state for, LEFT is 0, RIGHT is 1.
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	void ActivateArrowState( UClass* InState, EOptionButtonArrow Arrow );

	/**
	 * Returns the current arrow state(Enabled or disabled) depending on whether or not the widget can shift left or right.
	 */
	UClass* GetArrowEnabledState(EOptionButtonArrow Arrow);

	/**
	 * Activates the UIState_Focused menu state and updates the pertinent members of FocusControls.
	 *
	 * @param	FocusedChild	the child of this widget that should become the "focused" control for this widget.
	 *							A value of NULL indicates that there is no focused child.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL GainFocus( UUIObject* FocusedChild, INT PlayerIndex );

	/**
	 * Deactivates the UIState_Focused menu state and updates the pertinent members of FocusControls.
	 *
	 * @param	FocusedChild	the child of this widget that is currently "focused" control for this widget.
	 *							A value of NULL indicates that there is no focused child.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL LoseFocus( UUIObject* FocusedChild, INT PlayerIndex );
}


/** Left and right arrow buttons for this widget. */
var instanced UIButton	ArrowLeftButton;
var instanced UIButton	ArrowRightButton;

/**
 * The styles used for the increment, decrement and marker buttons
 */
var		private								UIStyleReference		IncrementStyle;
var		private								UIStyleReference		DecrementStyle;

/** Spacing between buttons and text. */
var(Appearance) UIScreenValue									ButtonSpacing;

/** Component for rendering the button background image */
var(Components)	editinline	const	noclear	UIComp_DrawImage		BackgroundImageComponent;

/** Renders the text displayed by this label */
var(Components)	editinline	const noclear	UIComp_DrawString		StringRenderComponent;

/** Profile settings current index. */
var			transient			int									CurrentIndex;

/** this sound is played when the index is incremented */
var(Sound)				name						IncrementCue;

/** this sound is played when the index is decremented */
var(Sound)				name						DecrementCue;


/** Whether we should wrap the options or not, meaning if the user hits the beginning or the end of the list, they will wrap to the other end of the list. */
var()					bool						bWrapOptions;

/** The data store that this list is bound to */
var(Data)						UIDataStoreBinding		DataSource;

/** the list element provider referenced by DataSource */
var	const	transient			UIListElementProvider	DataProvider;

/** If true, this widget won't attempt to align it's children */
var() bool bCustomPlacement;

/**
 * @return TRUE if the CurrentIndex is at the start of the ValueMappings array, FALSE otherwise.
 */
native function bool HasPrevValue();

/**
 * @return TRUE if the CurrentIndex is at the start of the ValueMappings array, FALSE otherwise.
 */
native function bool HasNextValue();

/**
 * Moves the current index back by 1 in the valuemappings array if it isn't already at the front of the array.
 */
native function SetPrevValue();

/**
 * Moves the current index forward by 1 in the valuemappings array if it isn't already at the end of the array.
 */
native function SetNextValue();

event Initialized()
{
	Super.Initialized();

	VerifyArrowButtons();

}

// since we now manage the styles for our internal buttons, make sure we're actually the owner of the button. (no flags were set on the buttons so you could reparent them in the editor)
function VerifyArrowButtons()
{
	if ( ArrowLeftButton != None && ArrowLeftButton.Outer != Self )
	{
		`warn(Name $  ".ArrowLeftButton (" $ ArrowLeftButton.Name $ ") has been reparented to " $ ArrowLeftButton.Outer $ "!  This will trigger an assertion in the style system because UDKUIOptionButton is responsible for resolving its style.  This must be fixed by a programmer - set the PrivateFlags for UTUIOptionButton.LeftArrowButtonTemplate object to 0, then reparent the button to this widget.");
	}
	if ( ArrowRightButton != None && ArrowRightButton.Outer != Self )
	{
		`warn(Name $  ".ArrowRightButton (" $ ArrowRightButton.Name $ ") has been reparented to " $ ArrowRightButton.Outer $ "!  This will trigger an assertion in the style system because UDKUIOptionButton is responsible for resolving its style.  This must be fixed by a programmer - set the PrivateFlags for UTUIOptionButton.ArrowRightButtonTempate object to 0, then reparent the button to this widget.");
	}
}

/** Called after the widget is done initializing. */
event PostInitialize()
{
	Super.PostInitialize();

	ArrowLeftButton.OnClicked = OnArrowLeft_Clicked;
	ArrowRightButton.OnClicked = OnArrowRight_Clicked;
}

/** Moves the current selection to the left. */
event OnMoveSelectionLeft(int PlayerIndex)
{
	if(HasPrevValue())
	{
		// Move to the prev value
		SetPrevValue();

		// Play the decrement sound
		PlayUISound(DecrementCue,PlayerIndex);
	}
}

/** Moves the current selection to the right. */
event OnMoveSelectionRight(int PlayerIndex)
{
	if(HasNextValue())
	{
		// Move to the next value
		SetNextValue();

		// Play the increment sound
		PlayUISound(IncrementCue,PlayerIndex);
	}
}

/** Arrow left clicked callback. */
function bool OnArrowLeft_Clicked(UIScreenObject InButton, int PlayerIndex)
{
	if(IsFocused()==false)
	{
		SetFocus(none);
	}

	OnMoveSelectionLeft(PlayerIndex);
	return true;
}

/** Arrow right clicked callback. */
function bool OnArrowRight_Clicked(UIScreenObject InButton, int PlayerIndex)
{
	if(IsFocused()==false)
	{
		SetFocus(none);
	}

	OnMoveSelectionRight(PlayerIndex);
	return true;
}

/** @return Returns the current index of the optionbutton. */
native function int GetCurrentIndex();

/**
 * Sets a new index for the option button.
 *
 * @param NewIndex		New index for the option button.
 */
native function SetCurrentIndex(INT NewIndex);



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
native function NotifyDataStoreValueUpdated( UIDataStore SourceDataStore, bool bValuesInvalidated, name PropertyTag, UIDataProvider SourceProvider, int ArrayIndex );

/**
 * Retrieves the list of data stores bound by this subscriber.
 *
 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
 */
native final virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final virtual function ClearBoundDataStores();

/** UIDataSourcePublisher interface */

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


defaultproperties
{
	ButtonSpacing=(Value=0.0f, ScaleType=EVALPOS_PixelOwner, Orientation=UIORIENT_Horizontal)
	Position={(	Value[UIFACE_Right]=256,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,
				Value[UIFACE_Bottom]=32,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner	)}

	// Left Arrow Button
	Begin Object Class=UIButton Name=LeftArrowButtonTemplate
		TabIndex=0
		WidgetTag=butArrowLeft

		Position={( Value[UIFACE_Left]=0.603122,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0.125,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.209372,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.750006,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
		//PRIVATE_NotFocusable|PRIVATE_TreeHidden|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle|PRIVATE_KeepFocusedState
		PrivateFlags=0x827
	End Object
	ArrowLeftButton=LeftArrowButtonTemplate

	// Right Arrow Button
	Begin Object Class=UIButton Name=RightArrowButtonTemplate
		TabIndex=1
		WidgetTag=butArrowRight

		Position={( Value[UIFACE_Left]=0.790628,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0.125,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=0.209372,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.75,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}

		//PRIVATE_NotFocusable|PRIVATE_TreeHidden|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle|PRIVATE_KeepFocusedState
		PrivateFlags=0x827
	End Object
	ArrowRightButton=RightArrowButtonTemplate

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	bWrapOptions=true

	DataSource=(RequiredFieldType=DATATYPE_Collection)
}

