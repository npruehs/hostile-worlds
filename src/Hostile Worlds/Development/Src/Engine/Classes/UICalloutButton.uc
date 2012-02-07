/**
 * This button class is used in UIButtonCalloutPanels to providing the user with feedback regarding the actions available
 * for a scene.  Each UICalloutButton is associatd with a specific input key / alias.  The button's caption and input key
 * handling are automatically handled based on the input key / alias the button is associated with.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UICalloutButton extends UILabelButton
	native(inherit)
	config(UI)
	notplaceable;

/**
 * The value used to build the data store markup string; default is <StringAliasMap:`InputAliasTag`>, where `InputAlias`
 * must exist in the string, as this is used to find the location where the button's input alias tag should be placed.
 */
var		const		config		string			DefaultMarkupStringTemplate;

/**
 * Provides a way for child classes to easily override the data store used for looking up button callouts.  If blank, uses
 * the engine's default - ButtonCallouts
 */
var		const		config		name			CalloutDataStoreTag;

/**
 * the input alias tag this button will use to generate the markup string required to grab its label text from the
 * StringAliasMap data store
 */
var(Data)	editconst	const	name			InputAliasTag;

/**
 * Determines where to place the markup string for the button icon, in relation to the caption's markup string.  If Center
 * is selected, the icon will be placed to the left of the first text in the markup string.  If Default is chosen, the icon
 * markup string will not be added at all - useful when the data binding already contains the button icon's markup string.
 */
var(Appearance)		const		EUIAlignment	IconAlignment;

/**
 * indicates that this button should generate trigger its alias when a press or repeat event is received, as opposed to a button release
 * Set by the owning buttonbar panel.
 */
var		transient				bool			bSupportsButtonRepeat;

/** Controls whether an error sound is played when this button is disabled */
var		const		config		bool			bPlayErrorSoundWhenDisabled;


`define		ClearColorMarkupStart	"<Color:R=1,B=1,G=1>"
`define		ClearColorMarkupEnd		"<Color:/>"

cpptext
{
	/* === UUIObject interface === */
	/**
	 * Adds the specified state to the screen object's StateStack and refreshes the widget style using the new state.
	 *
	 * @param	StateToActivate		the new state for the widget
	 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player that generated this call
	 *
	 * @return	TRUE if the widget's state was successfully changed to the new state.  FALSE if the widget couldn't change
	 *			to the new state or the specified state already exists in the widget's list of active states
	 */
	virtual UBOOL ActivateState( class UUIState* StateToActivate, INT PlayerIndex );

	/**
	 * Changes the player input mask for this control, which controls which players this control will accept input from.
	 *
	 * @param	NewInputMask	the new mask that should be assigned to this control
	 * @param	bRecurse		if TRUE, calls SetInputMask on all child controls as well.
	 * @param	bForcedOverride	by default, the widget's PlayerInputMask is only changed if it still matches the default value.
	 */
	virtual void SetInputMask( BYTE NewInputMask, UBOOL bRecurse=TRUE, UBOOL bForcedOverride=FALSE );

	/** === UIDataStoreSubscriber interface === */
	/**
	 * Sets the data store binding for this object to the text specified.
	 *
	 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
	 *								<DataStoreTag:DataFieldTag>
	 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
	 *								objects which have multiple data store bindings.  How this parameter is used is up to the
	 *								class which implements this interface, but typically the "primary" data store will be index 0.
	 */
	virtual void SetDataStoreBinding( const FString& MarkupText, INT BindingIndex=INDEX_NONE );

	/**
	 * Sets the data store binding for this object to the text specified.
	 *
	 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
	 *								<DataStoreTag:DataFieldTag>
	 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
	 *								objects which have multiple data store bindings.  How this parameter is used is up to the
	 *								class which implements this interface, but typically the "primary" data store will be index 0.
	 */
	virtual UBOOL RefreshSubscriberValue( INT BindingIndex=INDEX_NONE );

	/* === UObject interface === */
//	/**
//	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
//	 */
//	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );
//
	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
}

/* == Delegates == */

/* == Natives == */
/**
 * Wrapper method for attaining a reference to the input alias data store.
 *
 * @param	AlternatePlayer		specifies the player that should be used for looking up the ButtonCallouts datastore; relevant
 *								when one player is using a gamepad and another is using a keyboard, for example.  If not specified,
 *								uses the value returned from GetPlayerOwner().
 */
native final function UIDataStore_InputAlias GetCalloutDataStore( optional LocalPlayer AlternatePlayer );

/**
 * Wrapper for changing the InputAliasTag for this button.
 *
 * Protected access because only SetInputAlias should be available to clients of this class.
 *
 * @param	NewInputAlias	the new input alias to use for this button (such as Conditional1, ShiftUp, Accept, etc.);
 *							native code does not perform any validity checks (to support changing the InputAliasTag to
 *							'None', if desired), so callers should perform this step themselves if appropriate.
 */
native final protected function SetInputTag( name NewInputAlias );

/**
 * Registers this callout button's associated input key with the scene's callout input proxy.  This is required in order
 * to receive calls to ProcessInputKey for this button's input key.
 *
 * @param	InputProxy					the input proxy to subscribe to; should be the proxy from this button's scene, which can be
 *										retrieved by calling GetCalloutInputProxy().
 * @param	bUpdateProxyOutputLinks		specify FALSE to update the scene's subscribers array only (e.g. when the widget is just changing
 *										states); a value of TRUE means that the associated output link will be removed as well (for example,
 *										when changing a button's input alias).
 * @param	PlayerIndex					if specified, the button mapping will only be added for that player; otherwise, adds button mappings
 *										for all players which this callout button accepts input from.
 *
 * @return	TRUE if the button was successfully subscribed to the proxy.
 */
native final function bool SubscribeToInputProxy( UIEvent_CalloutButtonInputProxy InputProxy, optional bool bUpdateProxyOutputLinks=true, optional int PlayerIndex=INDEX_NONE );

/**
 * Unregisters this callout button's associated input key with the scene's callout input proxy.  This is required in order
 * to stop handling input for this button's input key.
 *
 * @param	InputProxy					the input proxy to subscribe to; should be the proxy from this button's scene, which can be
 *										retrieved by calling GetCalloutInputProxy().
 * @param	bUpdateProxyOutputLinks		specify FALSE to update the scene's subscribers array only (e.g. when the widget is just changing
 *										states); a value of TRUE means that the associated output link will be removed as well (for example,
 *										when changing a button's input alias).
 * @param	PlayerIndex					if specified, the button mapping will only be removed for that player; otherwise, removed button mappings
 *										for all players which this callout button accepts input from.
 *
 * @return	TRUE if the button was successfully subscribed to the proxy.
 */
native final function bool UnsubscribeFromInputProxy( UIEvent_CalloutButtonInputProxy InputProxy, optional bool bUpdateProxyOutputLinks=true, optional int PlayerIndex=INDEX_NONE );

/**
 * Handler for OnRawInputKey delegate.  Looks up the alias associated with the input key and if it matches the button's
 * InputAliasTag, activates the input proxy's output link for this button.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
native function bool OnReceivedInputKey( const out InputEventParameters EventParms );

/* == Events == */
/**
 * Public method for changing this button's input alias.  Rebuilds the markup string and updates the data store binding.
 *
 * @param	NewInputAlias	the new input alias to associate with this button, such as Accept, Cancel, ShiftUp, Conditional1, etc.
 *							valid values are listed in the [UIDataStore_StringAliasMap] (or subclass, if applicable) section of
 *							the game's .ini.
 *
 * @return	TRUE if the new alias was valid and was applied successfully to this button's data store binding.
 */
event bool SetInputAlias( name NewInputAlias )
{
	local bool bResult;
	local string CurrentMarkup, NewMarkup;

	if ( NewInputAlias != 'None' )
	{
		// save the current markup string in case we can't bind to the new one.
		CurrentMarkup = GetDataStoreBinding();

		// create a new markup string using the new input alias.
		NewMarkup = GenerateCompleteCaptionMarkup(NewInputAlias);
		if ( NewMarkup != "" )
		{
			SetDataStoreBinding(NewMarkup, FIRST_DEFAULT_DATABINDING_INDEX - 1);
			if ( CaptionDataSource.MarkupString == NewMarkup )
			{
				SetInputTag(NewInputAlias);
				bResult = true;
			}
			else
			{
				SetDataStoreBinding(CurrentMarkup, FIRST_DEFAULT_DATABINDING_INDEX - 1);
			}
		}
	}

	return bResult;
}

/**
 * @return	the name of the data store that should be used for looking up button callouts.
 */
event name GetCalloutDataStoreName()
{
	return CalloutDataStoreTag != 'None' ? CalloutDataStoreTag : 'ButtonCallouts';
}

/**
 * @return	the data store markup string required to access the callout icon data store for this button's alias, or
 *			an empty string if this button isn't assigned an alias.
 */
event string GetCalloutMarkupString( optional name AlternateInputAlias )
{
	local string Result;

	if ( InputAliasTag != 'None' || AlternateInputAlias != 'None' )
	{
		Result = `ClearColorMarkupStart
				$ Repl(
					VerifyDefaultMarkupString()
						? DefaultMarkupStringTemplate
						: "<" $ GetCalloutDataStoreName() $ ":\`InputAliasTag\`>",
					"\`InputAliasTag\`",
					AlternateInputAlias == 'None' ? InputAliasTag : AlternateInputAlias
					)
				$ `ClearColorMarkupEnd;
	}

	return Result;
}

/**
 * Generates a markup string for this button's caption, preserving any additional text present in the data store binding's
 * current value.  The callout markup string will be positioned within the total markup string according to this button's
 * configured IconAlignment.
 *
 * @param	InputAlias	allows the caller to specify the alias that should be used in the markup string returned.  If not
 *						specified, the button's currently assigned input alias will be used.
 *
 * @return	a complete data store markup string which includes a markup node for referencing the callout associated with
 *			the alias, along with any additional text that was applied to this button's caption data store binding.
 */
event string GenerateCompleteCaptionMarkup( optional name InputAlias )
{
	local string IconMarkup, CurrentMarkup, NewMarkup, CalloutMarkupString;

	CurrentMarkup = GetDataStoreBinding();
	CalloutMarkupString = GetCalloutMarkupString();

	if ( CurrentMarkup != "" && InStr(CurrentMarkup, `{ClearColorMarkupEnd}) == INDEX_NONE )
	{
		// this button was created before we added the fix for the icon color - remove the color markup from the string
		// that is used to rebuild to new markup string
		CalloutMarkupString = Repl(Repl(CalloutMarkupString, `ClearColorMarkupStart, ""), `ClearColorMarkupEnd, "");
	}

	if ( InputAliasTag != 'None' )
	{
		// save the current markup string in case we can't bind to the new one.
		if ( CurrentMarkup != "" )
		{
			// make sure we have already replaced any tokens in the current markup string
			CurrentMarkup = Repl(CurrentMarkup, "\`InputAliasTag\`", InputAliasTag);
		}

		switch ( IconAlignment )
		{
		case UIALIGN_Left:
			IconMarkup = GetCalloutMarkupString(InputAlias);

			// remove the icon markup from the existing markup string, then put the callout markup on the left side
			NewMarkup = IconMarkup $ Repl(CurrentMarkup, CalloutMarkupString, "");
			break;

		case UIALIGN_Center:
			//@todo ronp - add a static function to UIString for finding the position of the first non-markup piece of text
			break;

		case UIALIGN_Right:
			IconMarkup = GetCalloutMarkupString(InputAlias);

			// remove the icon markup from the existing markup string, then put the callout markup on the left side
			NewMarkup = Repl(CurrentMarkup, CalloutMarkupString, "") $ IconMarkup;
			break;

		case UIALIGN_Default:
			if ( InputAlias != 'None' && InStr(CurrentMarkup, InputAliasTag) != INDEX_NONE )
			{
				NewMarkup = Repl(CurrentMarkup, InputAliasTag, InputAlias);
			}
			break;
		}
	}
	else
	{
		// if we have a valid markup string and it contains the alias tag token, replace the token with the specified alias
		if ( InputAlias != 'None' && CurrentMarkup != "" && InStr(CurrentMarkup, "\`InputAliasTag\`") != INDEX_NONE )
		{
			NewMarkup = Repl(CurrentMarkup, "\`InputAliasTag\`", InputAlias);
		}
		else
		{
			// not currently assigned an alias, so just generate a markup string based on the default version which contains the alias specified
			NewMarkup = GetCalloutMarkupString(InputAlias);
		}
	}

	return NewMarkup;
}

/**
 * Called after this screen object's children have been initialized.  While the Initialized event is only called when
 * a widget is initialized for the first time, PostInitialize() will be called every time this widget receives a call
 * to Initialize(), even if the widget was already initialized.  Examples would be reparenting a widget.
 */
event PostInitialize()
{
	local string CurrentMarkup;
	local UIEvent_CalloutButtonInputProxy InputProxy;

	Super.PostInitialize();

	CurrentMarkup = GenerateCompleteCaptionMarkup();
	if ( CurrentMarkup != "" && CurrentMarkup != CaptionDataSource.MarkupString )
	{
		// this button was created before we added the fix for the icon color - remove the color markup from the string
		// that is used to rebuild to new markup string
		SetDataStoreBinding(CurrentMarkup);
	}

	// make sure that the owning scene's sequence contains an instance of the buttonbar input proxy sequence object.
	// add one if necessary
	InputProxy = GetCalloutInputProxy(true);

	// now register this button's input alias with the buttonbar input proxy, one for each player that can interact with
	// this scene
	SubscribeToInputProxy(InputProxy);
}

/**
 * Notification that this widget's parent is about to remove this widget from its children array.  Allows the widget
 * to clean up any references to the old parent.
 *
 * @param	WidgetOwner		the screen object that this widget was removed from.
 */
event RemovedFromParent( UIScreenObject WidgetOwner )
{
	local UIEvent_CalloutButtonInputProxy InputProxy;

	Super.RemovedFromParent(WidgetOwner);

	// find the scene's buttonbar input proxy
	InputProxy = GetCalloutInputProxy();

	// unregister this button's input key from the buttonbar proxy
	UnsubscribeFromInputProxy(InputProxy);

	//@todo ronp - if this button is the scene's last remaining buttonbar button, remove the input proxy
}

/* == UnrealScript == */

/**
 * Accessor for grabbing a reference to the CalloutButtonPanel that owns this button.  Might return None if this button
 * doesn't currently have an owner for some reason.
 */
function UICalloutButtonPanel GetPanelOwner()
{
	return UICalloutButtonPanel(GetOwner());
}

/**
 * Verifies that the DefaultMarkupStringTemplate contains the `InputAliasTag` token.
 *
 * @return	TRUE if the default markup string contains the InputAliasTag token.
 */
protected function bool VerifyDefaultMarkupString()
{
	local bool bResult;

	if ( InStr(DefaultMarkupStringTemplate, "\`InputAliasTag\`") != INDEX_NONE )
	{
		bResult = true;
	}

	return bResult;
}

/**
 * Returns a reference to the input proxy for this button's scene.
 *
 * @param	bCreateIfNecessary	specify TRUE to have an input proxy created for you if it doesn't exist.  Future calls
 *								to this function would then return that proxy.
 *
 * @return	a reference to the button bar input proxy used by this button's owner scene.
 */
function UIEvent_CalloutButtonInputProxy GetCalloutInputProxy( optional bool bCreateIfNecessary )
{
	local UICalloutButtonPanel PanelOwner;
	local UIEvent_CalloutButtonInputProxy InputProxy;

	PanelOwner = GetPanelOwner();
	if ( PanelOwner != None )
	{
		InputProxy = PanelOwner.GetCalloutInputProxy(bCreateIfNecessary);
	}

	return InputProxy;
}

/* == SequenceAction handlers == */



DefaultProperties
{
	PrivateFlags=0x280	// PRIVATE_EditorNoReparent|PRIVATE_EditorNoDelete
	DockTargets=(bLockWidthWhenDocked=true)
	bNeverFocus=true
	bOverrideInputOrder=true

	OnRawInputKey=OnReceivedInputKey

	Begin Object Name=BackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="CalloutButtonBackgroundStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	End Object

	Begin Object Name=LabelStringRenderer
		StringStyle=(DefaultStyleTag="CalloutButtonStringStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
		AutoSizeParameters[0]=(bAutoSizeEnabled=true)
		AutoSizeParameters[1]=(bAutoSizeEnabled=true)
	End Object
}
