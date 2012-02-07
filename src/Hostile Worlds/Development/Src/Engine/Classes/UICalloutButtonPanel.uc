`include(UIDev.uci)
/**
 * Container for a list of UICalloutButtons which handle navigation between scenes as well as activating special functionality
 * in the scene.  Each button is associated with a particular key or alias; the button's associated key is used to lookup
 * the display text and optionally an image of the keyboard or gamepad key required to activate the button.
 *
 * There are two ways to add buttons to a callout panel - via the panel's CalloutButtonAliases array, and adding new buttons
 * dynamically at runtime.  Any buttons added from code dynamically in the editor will be automatically published to the
 * persistent tag array (CalloutButtonAliases) and will be part of the button panel anytime an instance of one is created.
 *
 * The UIButtonCalloutPanel provides methods for adding, removing, positioning, or modifying the associated key for any button.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UICalloutButtonPanel extends UIContainer
	native(inherit)
	config(UI)
	PerObjectConfig
	placeable;

/**
 * Different button layout types
 */
enum ECalloutButtonLayoutType
{
	/** buttons are auto-sized to fit their contents, but button positions are not adjusted unless they overlap */
	CBLT_None,

	/** button are auto-sized to fit their contents, and docked to the left side of the panel */
	CBLT_DockLeft<DisplayName=Dock Left>,

	/** button are auto-sized to fit their contents, and docked to the right side of the panel */
	CBLT_DockRight<DisplayName=Dock Right>,

	/** buttons are auto-sized to fit their contents, then centered in the panel */
	CBLT_Centered<DisplayName=Centered>,

	/** buttons are evenly spaced out in the panel */
	CBLT_Justified<DisplayName=Spaced Evenly>,

	//@todo?  need these?
	//CBLT_Fill		this would adjust the sizes of all buttons until the group filled the width of this panel
};

/** the button template to use when creating child button instances for this panel */
var(ZDebug)	editinline	editconst	duplicatetransient		UICalloutButton			ButtonTemplate;

/**
 * The list of all buttons currently contained by this callout panel, whether generated based on this object's data store
 * binding, or added dynamically at runtime.
 * Although the buttons would be in the panel's Children array, this separate array provides quick and easy access to
 * the buttons without the need for casting to UICalloutButton everywhere.
 */
var(ZDebug)	editinline	editconst				transient	array<UICalloutButton>	CalloutButtons;

/**
 * Determines whether the button bar lays out its buttons vertically or horizontally.
 */
var(Appearance)										EUIOrientation					ButtonBarOrientation;

/** Determines how the buttons will be positioned within this panel */
var(Appearance)										ECalloutButtonLayoutType		ButtonLayout;

/** The amount of padding to apply to this panel's buttons. */
var(Appearance)										UIScreenValue_Extent			ButtonPadding[EUIOrientation.UIORIENT_MAX];

/**
 * Runtime mapping of input key name => button alias name; updated when buttons call Un/SubscribeToInputProxy; used
 * to quickly lookup the button input alias associated with an input key when an input event occurs.
 *
 * @fixme - doesn't support multiple players correctly
 */
var	native	const								transient	Map{FName,FName}		ButtonInputKeyMappings;

/**
 * The array of button string aliases used for generating the buttons in this panel.
 */
var												config		array<name>				CalloutButtonAliases;

/**
 * Prevents the ConfigureChildButton function from calling SetupDockingRelationships.  Used when populating the initial
 * list of buttons from the CalloutButtonAliases array (since we want to wait until all buttons have been added before
 * setting up docking).
 */
var												transient	bool					bGeneratingInitialButtons;

/** Indicates that the buttons in the panel should react to button press and repeat events, rather than release events */
var(Interaction)											bool					bSupportsButtonRepeat;

/**
 * Indicates that the panel should recalculate the docking between all buttons before the next tick.
 */
var(ZDebug)	private{private}					transient	bool					bRefreshButtonDocking;

/**
 * Indicates that the panel should recalculate the docking between all buttons before the next tick.
 */
//var(ZDebug)	private{private}					transient	bool					bRefreshButtonPositions;
//goes with PostSceneUpdate() - reposition all the buttons in a way that prevents another scene update

//@todo - add more variables to allow designers to customize the appearance of the panel

cpptext
{
	/* === UUICalloutButtonPanel interface === */
	/**
	 * Set up the docking links between the callout buttons.
	 */
	virtual void SetupDockingRelationships();

	/* === UUIObject interface === */
	/**
	 * Called immediately before the scene perform an update.  Recalculates the docking relationships between this panel's
	 * buttons.
	 */
	virtual void PreSceneUpdate();

	/**
	 * Called immediately after the scene perform an update.  Positions buttons when the layout mode is centered.
	 */
	virtual void PostSceneUpdate();

	/**
	 * Called when the scene receives a notification that the viewport has been resized.  Propagated down to all children.
	 *
	 * @param	OldViewportSize		the previous size of the viewport
	 * @param	NewViewportSize		the new size of the viewport
	 */
	virtual void NotifyResolutionChanged( const FVector2D& OldViewportSize, const FVector2D& NewViewportSize );

	/* === UObject interface === */
//	/**
//	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
//	 */
//	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
//
//	/**
//	 * Called after this object has been completely de-serialized.
//	 */
//	virtual void PostLoad();

	/**
	 * Presave function. Gets called once before an object gets serialized for saving. This function is necessary
	 * for save time computation as Serialize gets called three times per object from within UObject::SavePackage.
	 *
	 * @warning: Objects created from within PreSave will NOT have PreSave called on them!!!
	 *
	 * This version syncs the CalloutButtonAliases array with the tags of the buttons currently in the CalloutButtons
	 * array, then calls SaveConfig() to publish these tags to the .ini.
	 */
	virtual void PreSave();

	/**
	 * Serializer - this version serializes the lookup map during transactions.
	 */
	virtual void Serialize( FArchive& Ar );
}

/**
 * Iterates over the Children array, adding any child UICalloutButtons to the CalloutButtons array.  Safe to call multiple
 * times.
 */
function PopulateCalloutButtonArray()
{
	local int ButtonIdx, AliasIdx;
	local UICalloutButton ChildButton;
	local array<UICalloutButton> TempArray;
	local bool bCreateButton;

	// find all buttons currently in the Children array
	for ( ButtonIdx = 0; ButtonIdx < Children.Length; ButtonIdx++ )
	{
		ChildButton = UICalloutButton(Children[ButtonIdx]);
		if ( ChildButton != None )
		{
			ChildButton.bSupportsButtonRepeat = bSupportsButtonRepeat;
			ChildButton.NotifyVisibilityChanged = OnButtonVisibilityChanged;
			TempArray[TempArray.Length] = ChildButton;
		}
	}

	// first, clear any existing elements.
	CalloutButtons.Length = 0;

	// the order *should* match the order of the CalloutButtonAlaises array, but there's no guarantee of this
	for ( AliasIdx = 0; AliasIdx < CalloutButtonAliases.Length; AliasIdx++ )
	{
		bCreateButton = true;
		for ( ButtonIdx = 0; ButtonIdx < TempArray.Length; ButtonIdx++ )
		{
			ChildButton = TempArray[ButtonIdx];
			if ( ChildButton.InputAliasTag == CalloutButtonAliases[AliasIdx] )
			{
				// found the button that should be next in the list.
				bCreateButton = false;

				// remove it from our work array
				TempArray.Remove(ButtonIdx, 1);

				// add it to the main array
				CalloutButtons[CalloutButtons.Length] = ChildButton;

				// stop iterating through the buttons since we found the one matching this alias
				break;
			}
		}

		if ( bCreateButton )
		{
			// if we didn't find a button corresponding to this alias, create one now
			ChildButton = CreateCalloutButton(CalloutButtonAliases[AliasIdx], CalloutButtonAliases[AliasIdx]);
		}
	}

	// any buttons which are left over were added dynamically either at runtime or in the editor.
	for ( ButtonIdx = 0; ButtonIdx < TempArray.Length; ButtonIdx++ )
	{
		CalloutButtons[CalloutButtons.Length] = TempArray[ButtonIdx];
	}
}

/**
 * Ensures that the CalloutButtonAliases array matches
 */
event SynchronizeInputAliases()
{
	local int AliasIdx;

	CalloutButtonAliases.Length = CalloutButtons.Length;
	for ( AliasIdx = 0; AliasIdx < CalloutButtons.Length; AliasIdx++ )
	{
		CalloutButtonAliases[AliasIdx] = CalloutButtons[AliasIdx].InputAliasTag;
	}
}

/* == Overrides == */
/**
 * Called immediately after a child has been added to this screen object.
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	local UICalloutButton ChildButton;
	local int InsertIndex;

	Super.AddedChild(WidgetOwner, NewChild);

	ChildButton = UICalloutButton(NewChild);
	if ( ChildButton != None && WidgetOwner == Self )
	{
		ChildButton.bSupportsButtonRepeat = bSupportsButtonRepeat;
		ChildButton.NotifyVisibilityChanged = OnButtonVisibilityChanged;
		if ( !bGeneratingInitialButtons )
		{
			if ( CalloutButtons.Find(ChildButton) == INDEX_NONE )
			{
				InsertIndex = FindBestInsertionIndex(ChildButton, false);
				if ( InsertIndex == INDEX_NONE )
				{
					InsertIndex = CalloutButtons.Length;
				}

				CalloutButtons.InsertItem(InsertIndex, ChildButton);
			}

			ConfigureChildButton(ChildButton);
			SynchronizeInputAliases();
		}
	}

	//@todo ?
}

/**
 * Called immediately after a child has been removed from this screen object.
 *
 * @param	WidgetOwner		the screen object that the widget was removed from.
 * @param	OldChild		the widget that was removed
 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
 *							between the widgets being removed from being severed.
 *							NOTE: If a value is specified, OldChild will ALWAYS be part of the ExclusionSet, since it is being removed.
 */
event RemovedChild( UIScreenObject WidgetOwner, UIObject OldChild, optional array<UIObject> ExclusionSet )
{
	local UICalloutButton ChildButton;

	Super.RemovedChild(WidgetOwner, OldChild, ExclusionSet);

	//@todo ?
	ChildButton = UICalloutButton(OldChild);
	if ( ChildButton != None )
	{
		ChildButton.NotifyVisibilityChanged = None;
		CalloutButtons.RemoveItem(ChildButton);
		SynchronizeInputAliases();
	}

	//reapply formatting, reposition the buttons, clean up docking links? (though that last one should be done for us)
	RequestButtonDockingUpdate();
}

/* == Delegates == */

/* == Natives == */

/**
 * Retrieves the list of callout button input aliases which are available for use in the specified button panel.
 *
 * @param	AvailableAliases	receives the list of callout button aliases which aren't in use by this button panel.
 * @param	PlayerOwner			specifies the player that should be used for looking up the ButtonCallouts datastore; relevant
 *								when one player is using a gamepad and another is using a keyboard, for example.
 */
native final function GetAvailableCalloutButtonAliases( out array<name> AvailableAliases, optional LocalPlayer PlayerOwner );

/**
 * Create a new callout button and give it the specified input alias tag.
 *
 * @param	ButtonInputAlias	the input alias to assign to the button (i.e. Accept, Cancel, Conditional1, etc.); this
 *								tag will be used to generate the button's data store markup.
 * @param	ButtonName			allows the caller to specify a name to use when creating the button.
 * @param	bInsertChild		if TRUE is specified, the newly created button will also be added to this panel's
 *								Children array, using the index provided by calling GetBestInsertionIndex().
 *
 * @return	an instance of a new UICalloutButton which has ButtonInputAlias as its InputAliasTag.
 */
native function UICalloutButton CreateCalloutButton( name ButtonInputAlias, optional name ButtonName, optional bool bInsertChild=true );

/**
 * Returns a reference to the input proxy for this button's scene.
 *
 * @param	bCreateIfNecessary	specify TRUE to have an input proxy created for you if it doesn't exist.  Future calls
 *								to this function would then return that proxy.
 *
 * @return	a reference to the button bar input proxy used by this button's owner scene.
 */
native final function UIEvent_CalloutButtonInputProxy GetCalloutInputProxy( optional bool bCreateIfNecessary );

/**
 * Finds the most appropriate position to insert the specified button, based on its InputAliasTag.  Only relevant if this
 * button's InputAliasTag is contained in the CalloutButtonAliases array.
 *
 * @param	ButtonToInsert	the button that will be inserted into the panel
 * @param	bSearchChildren	specify TRUE to search for the best insertion index into the Children array, rather than the
 *			CalloutButtonAliases array.
 *
 * @return	index [into the Children or CalloutButtons array] for the position to insert the button, or INDEX_NONE if
 *			the button's InputAliasTag is not contained in the CalloutButtonAliases array (meaning that it's a dynamic button)
 */
native function int FindBestInsertionIndex( UICalloutButton ButtonToInsert, optional bool bSearchChildrenArray );

/**
 * Request that the docking relationships between the panel's buttons be updated at the beginning of the next scene update.
 * Calling this method will trigger a scene update as well.
 *
 * @param	bImmediately	specify TRUE to have the docking updated immediately rather than waiting until the next scene
 *							update.  A scene update will then only be triggered if any docking relationships changed.
 */
native final function RequestButtonDockingUpdate( optional bool bImmediately );

/* == Events == */
/**
 * Adds a new button to this callout panel.
 *
 * @param	NewButton	the button to add
 *
 * @return	the index where the button was actually inserted, or INDEX_NONE if it couldn't be inserted.
 *
 * not yet implemented (possible that this method will be changed to take the button's input key rather than a reference to the button itself).
 */
event int InsertButton( UICalloutButton NewButton )
{
	local int Result, InsertIndex;

	Result = INDEX_NONE;
	if ( NewButton != None && NewButton.InputAliasTag != 'None' )
	{
		if ( ContainsButton(NewButton.InputAliasTag) )
		{
			`log(`location@"Already contains a button with the tag '" $ NewButton.InputAliasTag $ "'");
		}
		else
		{
			InsertIndex = FindBestInsertionIndex(NewButton, true);

			// the call to InsertChild will take care of inserting the button into the CalloutButtons array (see AddedChild)
			Result = InsertChild(NewButton, InsertIndex);
		}
	}
	else
	{
		if ( NewButton == None )
		{
			`log(`location@"NewButton is NULL!");
		}
		else
		{
			`log(`location@"You must set the InputAliasTag for " $ NewButton $ " before it can be added to the list.");
		}
	}

	return Result;
}

/**
 * Removes the specified button from the CalloutButtons array (as well as the Children array).
 *
 * @param	ButtonToRemove	reference to the button that should be removed.
 *
 * @return	TRUE if the button was successfully removed.
 *
 * @todo - should we provide an option for allowing the user to control whether this button's alias is removed from the CalloutButtonAliases map?
 */
event bool RemoveButton( UICalloutButton ButtonToRemove )
{
	local bool bResult;

	if ( ButtonToRemove != None && ContainsButton(ButtonToRemove.InputAliasTag) )
	{
		// the call to remove child will take care of everything else (reconnecting docking links between
		// this button's neighbors, etc.) so don't have do anything else.  We do it this way so that if a
		// button is removed by calling RemoveChild rather than RemoveButton, we still do all the right stuff.
		bResult = RemoveChild(ButtonToRemove);
	}

	return bResult;
}

/**
 * Removes the specified button from the CalloutButtons array (as well as the Children array).
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 *
 * @return	TRUE if the button was successfully removed.
 *
 * @todo - should we provide an option for allowing the user to control whether this button's alias is removed from the CalloutButtonAliases map?
 */
event bool RemoveButtonByAlias( name ButtonInputAlias )
{
	local UICalloutButton TargetButton;
	local bool bResult;

	TargetButton = FindButton(ButtonInputAlias);
	if ( TargetButton != None )	// don't need to check ContainsButton because this is already handled by the call to FindButton.
	{
		// the call to remove child will take care of everything else (reconnecting docking links between
		// this button's neighbors, etc.) so don't have do anything else.  We do it this way so that if a
		// button is removed by calling RemoveChild rather than RemoveButton, we still do all the right stuff.
		bResult = RemoveChild(TargetButton);
	}

	return bResult;
}

/**
 * Remove all buttons from the button bar.
 *
 * @return	TRUE if all buttons were successfully removed.
 */
event bool RemoveAllButtons()
{
	RemoveChildren(CalloutButtons);
	return CalloutButtons.Length == 0;
}

/**
 * Wrapper for changing a button's caption.  Not yet implemented as this should be coming from the data store.
 */
event bool SetButtonCaption( name ButtonInputAlias, string NewButtonCaption )
{
	local UICalloutButton TargetButton;
	local bool bResult;

	TargetButton = FindButton(ButtonInputAlias);
	if ( TargetButton != None )	// don't need to check ContainsButton because this is already handled by the call to FindButton.
	{
		TargetButton.SetDataStoreBinding(NewButtonCaption);
		RequestButtonDockingUpdate();
		bResult = true;
	}

	return bResult;
}

/**
 * Wrapper method for changing a button's assigned input alias.
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 * @param	NewButtonInputAlias	the new input alias tag to apply to the button.
 *
 * @return	TRUE if the button's input alias tag was changed successfully.
 */
event bool SetButtonInputAlias( name ButtonInputAlias, coerce name NewButtonInputAlias )
{
	local UICalloutButton TargetButton;
	local bool bResult;

	TargetButton = FindButton(ButtonInputAlias);
	if ( TargetButton != None )	// don't need to check ContainsButton because this is already handled by the call to FindButton.
	{
		if ( !ContainsButton(NewButtonInputAlias) && TargetButton.SetInputAlias(NewButtonInputAlias) )
		{
			RequestSceneUpdate(true, false);
			bResult = true;
		}
	}

	return bResult;

}

/**
 * Wrapper method for changing the function assigned to the specified button's OnClicked delegate.
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 * @param	NewClickHandler		the function or delegate value to assign to the button's OnClicked delegate.
 *
 * @return	TRUE if the button's OnClicked delegate was set successfully.
 */
event bool SetButtonCallback( name ButtonInputAlias, delegate<UIObject.OnClicked> NewClickHandler )
{
	local UICalloutButton TargetButton;
	local bool bResult;

	TargetButton = FindButton(ButtonInputAlias);
	if ( TargetButton != None )	// don't need to check ContainsButton because this is already handled by the call to FindButton.
	{
		TargetButton.OnClicked = NewClickHandler;
		bResult = true;
	}

	return bResult;
}

/**
 * Wrapper for changing the visibility of the specified button
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 * @param	bShowButton			whether the show or hide the button.
 *
 * @return	TRUE if the button's visiblity was set successfully.
 */
event bool ShowButton( name ButtonInputAlias, optional bool bShowButton=true )
{
	local UICalloutButton TargetButton;
	local bool bResult, bVisible;

	TargetButton = FindButton(ButtonInputAlias);
	if ( TargetButton != None )	// don't need to check ContainsButton because this is already handled by the call to FindButton.
	{
		bVisible = TargetButton.IsVisible();

		TargetButton.SetVisibility(bShowButton);
		bResult = bVisible != bShowButton && bShowButton == TargetButton.IsVisible();
	}

	return bResult;
}

/**
 * Wrapper for changing the enabled state of the specified button
 *
 * @param	ButtonInputAlias			the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 * @param	bEnableButton				indicates whether the button should be enabled or disabled.
 * @param	bUpdateButtonVisibility		indicates that the button's visibility should be updated (if being enabled,
 *										show the button; if being disabled, hide the button).
 *
 * @return	TRUE if the button's enabled state was set successfully.
 */
event bool EnableButton( name ButtonInputAlias, optional int PlayerIndex=GetBestPlayerIndex(), optional bool bEnableButton=true, optional bool bUpdateButtonVisibility=true )
{
	local UICalloutButton TargetButton;
	local bool bResult;

	TargetButton = FindButton(ButtonInputAlias);
	if ( TargetButton != None )
	{
		if ( TargetButton.SetEnabled(bEnableButton, PlayerIndex) )
		{
			bResult = true;
			if ( bUpdateButtonVisibility || bEnableButton )
			{
				TargetButton.SetVisibility(bEnableButton);
			}
		}
	}

	return bResult;
}

/**
 * Returns a reference to the button associated with the input key.
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 *
 * @return	the button assocated with the specifed input key, or None if no buttons are associated with that input key.
 */
event UICalloutButton FindButton( name ButtonInputAlias )
{
	local int ButtonIdx;
	local UICalloutButton Result;

	ButtonIdx = FindButtonIndex(ButtonInputAlias);
	if ( ButtonIdx >= 0 && ButtonIdx < CalloutButtons.Length )
	{
		Result = CalloutButtons[ButtonIdx];
	}

	return Result;
}

/**
 * Find the index [into the CalloutButtons array] for the specified button.
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 *
 * @return	the index for the button assocated with the specifed input key, or INDEX_NONE if no buttons are associated with that input key.
 */
event int FindButtonIndex( name ButtonInputAlias )
{
	local int ButtonIdx, Result;

	Result = INDEX_NONE;
	for ( ButtonIdx = 0; ButtonIdx < CalloutButtons.Length; ButtonIdx++ )
	{
		if (CalloutButtons[ButtonIdx] != None
		&&	CalloutButtons[ButtonIdx].InputAliasTag == ButtonInputAlias
		&&	CalloutButtons[ButtonIdx].Outer == Self )
		{
			Result = ButtonIdx;
			break;
		}
	}

	return Result;
}

/**
 * Wrapper for easily determining whether this panel contains a button associated with the specified input key.
 *
 * @param	ButtonInputAlias	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 *
 * @return	TRUE if this panel contains the specified button.
 */
event bool ContainsButton( name ButtonInputAlias/*, optional ECalloutButtonSearchMode ButtonFilter=CBSM_Any*/ )
{
	local UICalloutButton TargetButton;

	TargetButton = FindButton(ButtonInputAlias);
	return TargetButton != None;
}

/**
 * Wrapper for easily determining whether the specified button should be able to process input.
 *
 * @param	InputAliasTag	the input alias tag (i.e. Conditional1, Accept, Cancel, etc.) used by the button to be found.
 * @param	PlayerIndex		index into the Engine.GamePlayers array; unless the scene is configured to allow any player
 *							to interact with any widget, filters out any buttons which are associated with players other
 *							than the one indicated by this value.
 *
 * @return	TRUE if the specified button is visible and enabled; FALSE if this panel doesn't contain the button or it
 *			isn't currently able to accept focus
 */
event bool CanButtonAcceptFocus( name InputAliasTag, optional int PlayerIndex=GetBestPlayerIndex() )
{
	local bool bResult;
	local UICalloutButton TargetButton;

	TargetButton = FindButton(InputAliasTag);
	if ( TargetButton != None )
	{
		bResult = TargetButton.CanAcceptFocus(PlayerIndex);
	}

	return bResult;
}

/* === UIScreenObject interface === */

/**
 * Called after this screen object's children have been initialized.  While the Initialized event is only called when
 * a widget is initialized for the first time, PostInitialize() will be called every time this widget receives a call
 * to Initialize(), even if the widget was already initialized.  Examples would be reparenting a widget.
 */
event PostInitialize()
{
	Super.PostInitialize();

	bGeneratingInitialButtons = true;

	// first, populate the CalloutButtons array with the buttons already in our Children array
	PopulateCalloutButtonArray();

	bGeneratingInitialButtons = false;

	// next, setup the docking relationships for all buttons.
	RequestButtonDockingUpdate();

	// now register the button's input keys
	InitializeInputProxy();
}

/**
 * Notification that this widget's parent is about to remove this widget from its children array.  Allows the widget
 * to clean up any references to the old parent.
 *
 * @param	WidgetOwner		the screen object that this widget was removed from.
 */
event RemovedFromParent( UIScreenObject WidgetOwner )
{
	local UISequence ProxyParentSequence;
	local UIEvent_CalloutButtonInputProxy InputProxy;
	local int ButtonIdx;

	Super.RemovedFromParent(WidgetOwner);

	// find the scene's buttonbar input proxy
	InputProxy = GetCalloutInputProxy(false);
	if ( InputProxy != None )
	{
		// unregister each button's associated input key from the buttonbar proxy
		for ( ButtonIdx = 0; ButtonIdx < CalloutButtons.Length; ButtonIdx++ )
		{
			if ( CalloutButtons[ButtonIdx] != None )
			{
				CalloutButtons[ButtonIdx].UnsubscribeFromInputProxy(InputProxy);
			}
		}

		// now remove the input proxy from the scene's sequence
		ProxyParentSequence = UISequence(InputProxy.ParentSequence);
		if ( ProxyParentSequence != None )
		{
			ProxyParentSequence.RemoveSequenceObject(InputProxy);
		}
	}
}


/* == UnrealScript == */
/**
 * Configures the button with all the appropriate settings to operate correctly in this callout panel (docking links, auto-size
 * settings, etc.)
 *
 * @param	ChildButton		the button to configure
 */
function ConfigureChildButton( UICalloutButton ChildButton )
{
	if ( ChildButton != None && ChildButton.Outer == Self )
	{
		// at this point, ChildButton should already be in our CalloutButtons array
		// hooking it into the docking links between the buttons
		RequestButtonDockingUpdate();

		ChildButton.bSupportsButtonRepeat = bSupportsButtonRepeat;
		ChildButton.NotifyVisibilityChanged = OnButtonVisibilityChanged;

		// locking width when docked and auto-sizing horizontally are taken care of by the defprops of the UICalloutButton class.
		//@todo - what else?
	}
	else
	{
		`log(`location@"NULL ChildButton specified.");
	}
}

/**
 * Creates CalloutButtonInputProxy object for the scene (if necessary) and register the input keys for all buttons in the panel.
 */
function InitializeInputProxy()
{
	local UIEvent_CalloutButtonInputProxy InputProxy;
	local int ButtonIdx;

	// make sure that the owning scene's sequence contains an instance of the buttonbar input proxy sequence object.
	// add one if necessary
	InputProxy = GetCalloutInputProxy(true);
	if ( InputProxy != None )
	{
		// for each button in this buttonbar, attempt to register its associated input key.  Since the buttons will do this
		// themselves in their PostInitialize() method (which will be executed before ours), there shouldn't actually be any
		// work to do
		for ( ButtonIdx = 0; ButtonIdx < CalloutButtons.Length; ButtonIdx++ )
		{
			if ( CalloutButtons[ButtonIdx] != None )
			{
				CalloutButtons[ButtonIdx].SubscribeToInputProxy(InputProxy);
			}
		}
	}
}

/**
 * Handler for the NotifyVisibilityChanged delegate in the buttons contained by this panel.
 *
 * @param	SourceWidget	the widget that changed visibility status
 * @param	bIsVisible		whether this widget is now visible.
 */
function OnButtonVisibilityChanged( UIScreenObject SourceWidget, bool bIsVisible )
{
	local UICalloutButton ButtonSender;

	ButtonSender = UICalloutButton(SourceWidget);
	if ( ButtonSender != None )
	{
		RequestButtonDockingUpdate();
	}
}


/* == SequenceAction handlers == */


DefaultProperties
{
	// UIButtonCalloutPanel members
	ButtonBarOrientation=UIORIENT_Horizontal
	ButtonLayout=CBLT_DockRight
	ButtonPadding(UIORIENT_Vertical)=(Orientation=UIORIENT_Vertical)

	bNeverFocus=true

	// Template to use for creating new callout buttons.
	Begin Object Class=UICalloutButton Name=CalloutButtonTemplate
		// for now, we don't really override anything, but here to make it easy to propagate data changes to existing instances
	End Object
	ButtonTemplate=CalloutButtonTemplate

	// UIObject members
	PrivateFlags=PRIVATE_PropagateState
	PrimaryStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	DockTargets=(bLockHeightWhenDocked=true,bLockWidthWhenDocked=true)

	// UIScreenObject members
	Position={( Value[UIFACE_Left]=0,
				ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,
				Value[UIFACE_Top]=0.95,
				ScaleType[UIFACE_Top]=EVALPOS_PercentageOwner,
				Value[UIFACE_Right]=1,
				ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,
				Value[UIFACE_Bottom]=0.05,
				ScaleType[UIFACE_Bottom]=EVALPOS_PercentageOwner)}
}
