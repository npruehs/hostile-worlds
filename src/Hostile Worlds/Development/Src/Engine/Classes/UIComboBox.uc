`include(UIDev.uci)

/**
 * A complex widget which contains a list, a button for toggling the visibility of the list, and an editbox for displaying
 * the currently selected item when the list is not visible.  Also supports rendering a caption to left, right, above, or below
 * the editbox.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

//`define requires_unique_list_datasource 1

class UIComboBox extends UIObject
	native(UIPrivate)
	placeable
	DontAutoCollapseCategories(Data)
	implements(UIDataStorePublisher);

/*
	Kismet events needed:
		- [N/A] selected item changed (wouldn't be necessary if sequence events were propagated up the parent chain)
		- [N/A] user typed into the editbox (handled by editbox?) (wouldn't be necessary if sequence events were propagated up the parent chain)
			- event propagation is now enabled....make compatible.

	General todo:
		- implement the CaptionRenderComponent.
		- Also, if we have a CaptionRenderComponent, need to adjust the region available for rendering the editbox/button so that we have room to render the caption.
		- refactor UIComp_DrawString to not assume that the entire bounds of the owning widget should be considered the "adjustable region" when the component is configured
			to autosize itself.

		- should we add a data store binding property for the combo's background image component?

		- [N/A (as long as we don't support instant update of the editbox text)] if the list loses focus, restore the editbox's text to the previous item
*/


/**
 * The class to use for creating the combo box's editbox.  If more control of the creation is necessary, or to use an existing
 * editbox, subscribe to the CreateCustomComboEditbox delegate instead.
 */
var		const	class<UIEditBox>								ComboEditboxClass;

/**
 * The class to use for creating the combo box's button.  If more control of the creation is necessary, or to use an existing
 * button, subscribe to the CreateCustomComboButton delegate instead.
 */
var		const	class<UIToggleButton>							ComboButtonClass;

/**
 * The class to use for creating the combo box's list.  If more control of the creation is necessary, or to use an existing
 * list, subscribe to the CreateCustomComboList delegate instead.
 */
var		const	class<UIList>									ComboListClass;

/**
 * Used to display the currently selected value
 * @todo - need script accessors for safely replacing the editbox with a new type, since the var is const
 */
var(Controls)	editinline	const	noclear		UIEditBox				ComboEditbox;

/**
 * Used to toggle the visibility of the list
 * @todo - need script accessors for safely replacing the button with a new type, since the var is const
 */
var(Controls)	editinline	const	noclear		UIToggleButton			ComboButton;

/**
 * Contains the collection of available choices for this combo box
 * @todo - need script accessors for safely replacing the list with a new type, since the var is const
 */
var(Controls)	editinline	const	noclear		UIList					ComboList;


//@todo - specify where the caption should render; left/right/top/bottom
/**
 * Optional component for rendering a caption next to the editbox.  No value given by default.
 */
var(Components)	editinline	const 	UIComp_DrawCaption		CaptionRenderComponent;

/**
 * Optional component for rendering a background image for this combo box.  No value given by default.
 */
var(Components)	editinline	const	UIComp_DrawImage		BackgroundRenderComponent;

/**
 * The data source this this combo box's caption will link to, if applicable.
 */
var(Data)	editconst	const	private		UIDataStoreBinding	CaptionDataSource;

/* = Sounds = */
/**
 * This sound is played when the list is made visible.  It will be played at the same time as the combobox button's clicked sound, so it's recommended to
 * clear any sound cues assign to the combo box button's ClickedCue.
 */
var(Sound)									name				OpenList;

/**
 * This sound is played when the combo's list is hidden  It will be played at the same time as the combobox button's clicked sound, so it's recommended to
 * clear any sound cues assign to the combo box button's ClickedCue.
 */
var(Sound)									name				DecrementCue;


/* = Constraints & Parameters = */
/**
 * Controls whether the list is docked to the combobox itself or the inside face of the button.
 */
var(Appearance)	private					bool				bDockListToButton<Tooltip=If enabled, the list will be the same width as the editbox.  If disabled, the list will be the same width as the entire combobox (default behavior).>;

const TEXT_CHANGED_NOTIFY_MASK=0x1;
const INDEX_CHANGED_NOTIFY_MASK=0x2;

const	COMBO_CAPTION_DATABINDING_INDEX	=1;


cpptext
{
	/* === UUIComboBox interface === */
	/**
	 * Creates the support controls which make up the combo box - the list, button, and editbox.
	 */
	virtual void CreateInternalControls();

	/* === UIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the BackgroundImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/**
	 * Called whenever the selected item is modified.  Activates the SliderValueChanged kismet event and calls the OnValueChanged
	 * delegate.
	 *
	 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
	 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
	 * @param	NotifyFlags		optional parameter for individual widgets to use for passing additional information about the notification.
	 */
	virtual void NotifyValueChanged( INT PlayerIndex=INDEX_NONE, INT NotifyFlags=0 );

protected:
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

public:
	/**
	 * Activates the focused state for this widget and sets it to be the focused control of its parent (if applicable)
	 *
	 * @param	Sender		Control that called SetFocus.  Possible values are:
	 *						-	if NULL is specified, it indicates that this is the first step in a focus change.  The widget will
	 *							attempt to set focus to its most eligible child widget.  If there are no eligible child widgets, this
	 *							widget will enter the focused state and start propagating the focus chain back up through the Owner chain
	 *							by calling SetFocus on its Owner widget.
	 *						-	if Sender is the widget's owner, it indicates that we are in the middle of a focus change.  Everything else
	 *							proceeds the same as if the value for Sender was NULL.
	 *						-	if Sender is a child of this widget, it indicates that focus has been successfully changed, and the focus is now being
	 *							propagated upwards.  This widget will now enter the focused state and continue propagating the focus chain upwards through
	 *							the owner chain.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL SetFocus(class UUIScreenObject* Sender,INT PlayerIndex=0);

	/**
	 * Sets focus to the specified child of this widget.
	 *
	 * @param	ChildToFocus	the child to set focus to.  If not specified, attempts to set focus to the most elibible child,
	 *							as determined by navigation links and FocusPropagation values.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL SetFocusToChild(class UUIObject* ChildToFocus=NULL,INT PlayerIndex=0);

	/**
	 * Deactivates the focused state for this widget.
	 *
	 * @param	Sender			the control that called KillFocus.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL KillFocus(class UUIScreenObject* Sender,INT PlayerIndex=0);


	/* === UUIScreenObject interface === */
	/**
	 * Perform all initialization for this widget. Called on all widgets when a scene is opened,
	 * once the scene has been completely initialized.
	 * For widgets added at runtime, called after the widget has been inserted into its parent's
	 * list of children.
	 *
	 * Creates the components of this combobox, if necessary.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/**
	 * Assigns values to the links which are used for navigating through this widget using the keyboard.  Sets the first and
	 * last focus targets for this widget as well as the next/prev focus targets for all children of this widget.
	 *
	 * @return	TRUE if any sibling navigation links were created.
	 */
	virtual UBOOL RebuildKeyboardNavigationLinks();

	/**
	 * Adds the specified face to the DockingStack, along with any dependencies that face might have.
	 *
	 * This version routes the call to the CaptionRenderComponent, if applicable.
	 *
	 * @param	DockingStack	the docking stack to add this docking node to.  Generally the scene's DockingStack.
	 * @param	Face			the face that should be added
	 *
	 * @return	TRUE if a docking node was added to the scene's DockingStack for the specified face, or if a docking node already
	 *			existed in the stack for the specified face of this widget.
	 */
	virtual UBOOL AddDockingNode( TArray<struct FUIDockingNode>& DockingStack, EUIWidgetFace Face );

	/**
	 * Evalutes the Position value for the specified face into an actual pixel value.  Should only be
	 * called from UIScene::ResolvePositions.  Any special-case positioning should be done in this function.
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

	/**
	 * Render this widget.  This version routes the render call to the draw components, if applicable.
	 *
	 * @param	Canvas	the canvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames( TArray<FName>& out_KeyNames );

protected:
	/**
	 * Handles input events for this slider.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const struct FSubscribedInputEventParameters& EventParms );

	/**
	 * Marks the Position for any faces dependent on the specified face, in this widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face );

public:

	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
}

/* == Delegates == */

/**
 * Provides a convenient way to override the creation of the combo's components.  Called when this UIComboBox is first initialized.
 *
 * @return	if a custom component is desired, a pointer to a fully configured instance of the desired component class.  You must use
 *			UIScreenObject.CreateWidget to create the widget instances.  The returned instance will be inserted into the combo box's
 *			Children array and initialized.
 */
delegate UIEditBox		CreateCustomComboEditbox( UIComboBox EditboxOwner );
delegate UIToggleButton	CreateCustomComboButton( UIComboBox ButtonOwner );
delegate UIList			CreateCustomComboList( UIComboBox ListOwner );

//@todo - add OnVisibilityChanged delegate to UIScreenObject, to allow hooking into the showing/hiding of the list

/* == Events == */

/* == Natives == */

/**
 * Sets the data store binding for this object to the text specified.
 *
 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
 *								<DataStoreTag:DataFieldTag>
 * @param	BindingIndex		indicates which data store binding should be modified.  Valid values and their meanings are:
 *									0:	list data source
 *									1:	caption data source
 */
native final virtual function SetDataStoreBinding( string MarkupText, optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the markup string corresponding to the data store that this object is bound to.
 *
 * @param	BindingIndex		indicates which data store binding should be modified.  Valid values and their meanings are:
 *									0:	list data source
 *									1:	caption data source
 *
 * @return	a datastore markup string which resolves to the datastore field that this object is bound to, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
native final virtual function string GetDataStoreBinding( optional int BindingIndex=INDEX_NONE ) const;

/**
 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
 *
 * @param	BindingIndex		indicates which data store binding should be modified.  Valid values and their meanings are:
 *									-1:	all data sources
 *									0:	list data source
 *									1:	caption data source
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
native function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native function ClearBoundDataStores();

/**
 * Resolves this subscriber's data store binding and publishes this subscriber's value to the appropriate data store.
 *
 * @param	out_BoundDataStores	contains the array of data stores that widgets have saved values to.  Each widget that
 *								implements this method should add its resolved data store to this array after data values have been
 *								published.  Once SaveSubscriberValue has been called on all widgets in a scene, OnCommit will be called
 *								on all data stores in this array.
 * @param	BindingIndex		indicates which data store binding should be modified.  Valid values and their meanings are:
 *									-1:	all data sources
 *									0:	list data source
 *									1:	caption data source
 *
 * @return	TRUE if the value was successfully published to the data store.
 */
native function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );


/** Initializes styles for child widgets. */
native function SetupChildStyles();

/* == Unrealscript == */
/**
 * Propagate the enabled state of this widget.
 */
event PostInitialize()
{
	Super.PostInitialize();

	if ( ComboButton != None )
	{
		ComboButton.OnPressed = ButtonPressed;
		ComboButton.OnClicked = None;
	}

	if ( ComboList != None )
	{
		// Assign this delegate to have the editbox's text update instantly when the user mouses over an item in the list
		ComboList.OnValueChanged = SelectedItemChanged;
		ComboList.OnSubmitSelection = ListItemSelected;
	}

	if ( ComboEditbox != None )
	{
		ComboEditbox.OnValueChanged = EditboxTextChanged;
		ComboEditbox.OnPressed = EditboxPressed;

		if ( ComboEditbox.IsReadOnly() )
		{
			ComboEditbox.OnClicked = None;
		}
	}

	// when this widget is enabled/disabled, its children should be as well.
	ConditionalPropagateEnabledState(GetBestPlayerIndex());
}

/**
 * Changes whether this widget is visible or not.  Should be overridden in child classes to perform additional logic or
 * abort the visibility change.
 *
 * @param	bIsVisible	TRUE if the widget should be visible; false if not.
 */
event SetVisibility( bool bIsVisible )
{
	Super.SetVisibility(bIsVisible);

	HideList();
}

event ShowList( optional int PlayerIndex=GetBestPlayerIndex() )
{
//	`log(">>>>>" @ `location);
	if ( ComboList != None )
	{
		// toggle the list's visibility
		ComboList.SetVisibility(true);

		// change the graphic of the toggle button to the list open graphic
		ComboButton.SetValue(true, PlayerIndex);

		// give the list focus if it's visible
		ComboList.SetFocus(None, PlayerIndex);
		ComboList.SetTopIndex(ComboList.Index);
	}
//	`log("<<<<<" @ `location);
}

event HideList( optional int PlayerIndex=GetBestPlayerIndex() )
{
//	`log(">>>>>" @ `location);
	if ( ComboList != None )
	{
		// change the graphic of the toggle button to the normal graphic
		ComboButton.SetValue(false, PlayerIndex);

		// hide the list
		ComboList.SetVisibility(false);

		// reset the list's index to the item corresponding to the value in the editbox.
		//ComboList.SilentSetIndex( ComboList.FindIndex(TextStr) );
	}
//	`log("<<<<<" @ `location);
}

/**
 * Changes the editbox's text to the string specified.
 *
 * @param	NewText				the text to apply to the editbox
 * @param	PlayerIndex			Player that performed the action that issued the event.
 * @param	bListItemsOnly		if TRUE, will only apply the specified text if matches an existing element in the list
 * @param	bSkipNotification	specify TRUE to prevent the OnValueChanged delegate from being called.
 */
function SetEditboxText( string NewText, int PlayerIndex, optional bool bListItemsOnly, optional bool bSkipNotification )
{
//	`log(">>>" @ `location@`showvar(NewText));
	if ( ComboEditbox != None )
	{
		if ( (bListItemsOnly || ComboEditbox.IsReadOnly()) && ComboList != None )
		{
			// if the string isn't one the list's elements, bail
			/*
			if ( !ComboList.ContainsItem(NewText) )
			{
				return;
			}
			*/
		}
		ComboEditbox.SetValue(NewText, PlayerIndex, bSkipNotification);
	}
//	`log("<<<" @ `location@`showvar(NewText));
}

/**
 * Retrieves the value of bDockListToButton.
 */
final function bool IsListDockedToButton()
{
	return bDockListToButton;
}

/**
 * Changes the value of bDockListToButton to the specified value.
 */
function SetListDocking( bool bDockToButton )
{
	if ( bDockListToButton != bDockToButton )
	{
		bDockListToButton = bDockToButton;
		if ( ComboList != None )
		{
			if ( bDockListToButton && ComboButton != None )
			{
				ComboList.SetDockTarget(UIFACE_Right, ComboButton, UIFACE_Left);
			}
			else
			{
				ComboList.SetDockTarget(UIFACE_Right, Self, UIFACE_Right);
			}
			ComboList.RequestFormattingUpdate();
		}
	}
}

/* == Delegate Handlers == */
/**
 * Handler for the editbox's OnPress delegate.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 */
function EditboxPressed( UIScreenObject EventObject, int PlayerIndex )
{
//	`log(`location@`showobj(EventObject));
	if ( ComboList != None && ComboList.IsHidden() && ComboEditbox.IsReadOnly() )
	{
		ComboEditbox.OnClicked = ShowListClickHandler;
	}
}

/**
 * Handler for the button's OnPressed delegate
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 */
function ButtonPressed( UIScreenObject EventObject, int PlayerIndex )
{
//	`log(" >>>>" @ `location@`showobj(EventObject)@`showvar(ComboList.IsVisible(),ComboListVisible));

	if ( ComboList != None && ComboList.IsHidden() )
	{
		// we can't call ShowList() from here because immediate after the OnPressed delegate call returns, the button will
		// take focus which would cause the list to be hidden.  Instead, we set the OnClicked delegate so that when the user releases
		// the mouse button, the list will be shown and take focus.
		ComboButton.OnClicked = ShowListClickHandler;
	}

//	`log(" <<<<" @ `location@`showobj(EventObject)@`showvar(ComboList.IsVisible(),ComboListVisible));
}

/**
 * Handler for the button and editbox's OnClicked delegate; Used to show the combobox list.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 *
 * @return	return TRUE to prevent the kismet OnClick event from firing.
 */
function bool ShowListClickHandler( UIScreenObject EventObject, int PlayerIndex )
{
	local bool bResult;

//	`log(" >>>>" @ `location@`showobj(EventObject)@`showvar(ComboList.IsVisible(),ComboListVisible));
	if ( ComboList != None )
	{
		ShowList(PlayerIndex);

		// now clear the OnClicked delegate because if the user clicks the button or editbox again to close the list, the act of clicking
		// the button will automatically hide the list as a result of the list losing focus.
		UIObject(EventObject).OnClicked = None;

		// don't fire the kismet on click event.
		bResult = true;
	}

//	`log(" <<<<" @ `location@`showobj(EventObject)@`showvar(ComboList.IsVisible(),ComboListVisible));
	return bResult;
}

/**
 * Handler for the editbox's OnValueChanged delegate.  Called when the user types text into the editbox.
 *
 * @param	Sender			the UIObject whose value changed
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
function EditboxTextChanged( UIObject Sender, int PlayerIndex )
{
	//@todo - verify that the editbox isn't set to be read-only?
	NotifyValueChanged(PlayerIndex, TEXT_CHANGED_NOTIFY_MASK);
}

/**
 * Handler for the list's OnValueChanged delegate.  Called when the list's index changes.
 *
 * @param	Sender			the UIObject whose value changed
 * @param	PlayerIndex		the index of the player that generated the call to this method; used as the PlayerIndex when activating
 *							UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
function SelectedItemChanged( UIObject Sender, int PlayerIndex )
{
	local string SelectedItemText;

//	`log(`location@`showobj(Sender));
	if ( ComboEditbox != None && Sender == ComboList && ComboList != None && ComboList.IsHidden() )
	{
		// retrieve the text for the selected element
		SelectedItemText = ComboList.GetElementValue(ComboList.Index);

		// now change the editbox's text to this value
		SetEditboxText(SelectedItemText, PlayerIndex, true, true);

		NotifyValueChanged(PlayerIndex, INDEX_CHANGED_NOTIFY_MASK);
	}
}

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function ListItemSelected( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
//	`log(`location@`showobj(Sender));
	if ( ComboEditbox != None )
	{
		// update the editbox's text; prevent the list from firing the OnValueChanged notification since we'll do that after
		// we update everything.
		SetEditboxText( Sender.GetElementValue(Sender.Index), PlayerIndex, true, true );

		HideList();
		ComboEditbox.SetFocus(None, PlayerIndex);

		NotifyValueChanged(PlayerIndex, INDEX_CHANGED_NOTIFY_MASK);
	}
}

// @todo ronp - all accessors for settings and retrieving the value of this combobox, by value or by index

DefaultProperties
{
	Position={(	Value[UIFACE_Right]=256,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,
				Value[UIFACE_Bottom]=32,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner	)}

	bSupportsPrimaryStyle=false
	PrivateFlags=PRIVATE_PropagateState

	ComboEditboxClass=class'Engine.UIEditBox'
	ComboButtonClass=class'Engine.UIToggleButton'
	ComboListClass=class'Engine.UIList'

	// States
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	// Data
	CaptionDataSource=(RequiredFieldType=DATATYPE_Property,BindingIndex=COMBO_CAPTION_DATABINDING_INDEX)

`if(`isdefined(dev_build))
	ContextMenuData=(RequiredFieldType=DATATYPE_Collection,BindingIndex=CONTEXTMENU_BINDING_INDEX,MarkupString="<GameResources:GameTypes>")
`endif

//
//	Begin Object class=UIComp_DrawImage Name=EditboxBackgroundTemplate
//		ImageStyle=(DefaultStyleTag="DefaultImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
//		StyleResolverTag="Background Image Style"
//	End Object
//	BackgroundImageComponent=EditboxBackgroundTemplate
}
