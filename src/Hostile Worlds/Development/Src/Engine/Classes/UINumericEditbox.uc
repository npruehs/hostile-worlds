/**
 * This  widget allows the user to type numeric text into an input field.
 * The value of the text in the input field can be incremented and decremented through the buttons associated with this widget.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * @todo - selection highlight support
 */
class UINumericEditBox extends UIEditBox
	native(inherit);

/** the style to use for the editbox's increment button */
var											UIStyleReference		IncrementStyle;

/** the style to use for the editbox's decrement button */
var											UIStyleReference		DecrementStyle;

/** Buttons that can be used to increment and decrement the value stored in the input field. */
var		private								UINumericEditBoxButton	IncrementButton;
var		private								UINumericEditBoxButton	DecrementButton;

/**
 * The value and range parameters for this numeric editbox.
 */
var(Data)									UIRangeData				NumericValue;

/** The number of digits after the decimal point. */
var(Data)									int						DecimalPlaces;

/** The position of the faces of the increment button. */
var(Appearance)								UIScreenValue_Bounds	IncButton_Position;

/** The position of the faces of the Decrement button. */
var(Appearance)								UIScreenValue_Bounds	DecButton_Position;


cpptext
{
	/**
	 * Initializes the buttons and creates the background image.
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
	 * Evalutes the Position value for the specified face into an actual pixel value.  Should only be
	 * called from UIScene::ResolvePositions.  Any special-case positioning should be done in this function.
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

	/**
	 * Called when a style reference is resolved successfully.
	 *
	 * @param	ResolvedStyle			the style resolved by the style reference
	 * @param	StyleProperty			the name of the style reference property that was resolved.
	 * @param	ArrayIndex				the array index of the style reference that was resolved.  should only be >0 for style reference arrays.
	 * @param	bInvalidateStyleData	if TRUE, the resolved style is different than the style that was previously resolved by this style reference.
	 */
	virtual void OnStyleResolved( UUIStyle* ResolvedStyle, const FStyleReferenceId& StyleProperty, INT ArrayIndex, UBOOL bInvalidateStyleData );

	/**
	 * Render this editbox.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	void Render_Widget( FCanvas* Canvas );

	/**
	 * Called whenever the user presses enter while this editbox is focused.  Activated the SubmitText kismet event and calls the
	 * OnSubmitText delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 */
	virtual void NotifySubmitText( INT PlayerIndex=INDEX_NONE );

	/**
	 * Evaluates the value string of the string component to verify that it is a legit numeric value.
	 */
	UBOOL ValidateNumericInputString();

	/**
	 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
	 *
	 * @param	BindingIndex		indicates which data store binding should be modified.
	 *
	 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
	 */
	virtual UBOOL RefreshSubscriberValue(INT BindingIndex=INDEX_NONE);

	/**
	 * Retrieves the list of data stores bound by this subscriber.
	 *
	 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
	 */
	virtual void GetBoundDataStores(TArray<class UUIDataStore*>& out_BoundDataStores);

	/** Saves the value for this subscriber. */
	virtual UBOOL SaveSubscriberValue(TArray<class UUIDataStore*>& out_BoundDataStores,INT BindingIndex=INDEX_NONE);

protected:

	/**
	 * Determine whether the specified character should be displayed in the text field.
	 */
	virtual UBOOL IsValidCharacter( TCHAR Character ) const;

	/**
	 * Handles input events for this editbox.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const FSubscribedInputEventParameters& EventParms );

public:
	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

}

/**
 * Increments the numeric editbox's value.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function IncrementValue( UIScreenObject Sender, int PlayerIndex );

/**
 * Decrements the numeric editbox's value.
 *
 * @param	EventObject	Object that issued the event.
 * @param	PlayerIndex	Player that performed the action that issued the event.
 */
native final function DecrementValue( UIScreenObject Sender, int PlayerIndex );

/**
 * Initializes the clicked delegates in the increment and decrement buttons to use the editbox's increment and decrement functions.
 * @todo - this is a fix for the issue where delegates don't seem to be getting set properly in defaultproperties blocks.
 */
event Initialized()
{
	local int ModifierFlags;

	Super.Initialized();

	IncrementButton.OnPressed = IncrementValue;
	IncrementButton.OnPressRepeat = IncrementValue;

	DecrementButton.OnPressed = DecrementValue;
	DecrementButton.OnPressRepeat = DecrementValue;

	ModifierFlags = PRIVATE_NotFocusable|PRIVATE_NotDockable|PRIVATE_TreeHidden|PRIVATE_NotEditorSelectable|PRIVATE_ManagedStyle;

	if ( !IncrementButton.IsPrivateBehaviorSet(ModifierFlags) )
	{
		IncrementButton.SetPrivateBehavior(ModifierFlags, true);
	}
	if ( !DecrementButton.IsPrivateBehaviorSet(ModifierFlags) )
	{
		DecrementButton.SetPrivateBehavior(ModifierFlags, true);
	}
}

/**
 * Propagate the enabled state of this widget.
 */
event PostInitialize()
{
	Super.PostInitialize();

	// when this widget is enabled/disabled, its children should be as well.
	ConditionalPropagateEnabledState(GetBestPlayerIndex());
}

/**
 * Change the value of this numeric editbox at runtime. Takes care of conversion from float to internal value string.
 *
 * @param	NewValue				the new value for the editbox.
 * @param	bForceRefreshString		Forces a refresh of the string component, normally the string is only refreshed when the value is different from the current value.
 *
 * @return	TRUE if the editbox's value was changed
 */
native final function bool SetNumericValue( float NewValue, optional bool bForceRefreshString=false );

/**
 * Gets the current value of this numeric editbox.
 */
native final function float GetNumericValue( ) const;


DefaultProperties
{
	DataSource=(MarkupString="Numeric Editbox Text",RequiredFieldType=DATATYPE_RangeProperty)
	PrivateFlags=PRIVATE_PropagateState

	PrimaryStyle=(DefaultStyleTag="DefaultEditboxStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')

	// Increment and Decrement Button Styles
	IncrementStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	DecrementStyle=(DefaultStyleTag="ButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')

	// Restrict the acceptable character set just numbers.
	CharacterSet=CHARSET_NumericOnly

	NumericValue=(MinValue=0.f,MaxValue=100.f,NudgeValue=1.f)
	DecimalPlaces=4
}
