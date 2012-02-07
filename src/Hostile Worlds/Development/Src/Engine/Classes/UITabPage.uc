`include(UIDev.uci)

/**
 * This widget is used by the UITabControl as a container for the widgets to be displayed when a tab is activated in the tab control.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UITabPage extends UIContainer
	native(inherit)
	DontAutoCollapseCategories(Data)
	implements(UIDataStoreSubscriber)
	placeable
	HideDropDown;

/*
todo
	- should probably hide the presentation category.
*/
cpptext
{
	/* === UIScreenObject interface === */
	/**
	 * Called when this widget is created.
	 */
	virtual void Created( UUIScreenObject* Creator );

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
}

/**
 * The UITabButton class to use for creating this page's button.
 */
var	const 				class<UITabButton>	ButtonClass;

/**
 * The tab button associated with this page; set in GetTabButton()
 */
var	protected			UITabButton			TabButton;

//@todo accessors to get the value of these guys
/** provides the caption for this page's tab button */
var(Data)	private		UIDataStoreBinding	ButtonCaption;

/** provides the tooltip for this page's tab button */
var(Data)	private		UIDataStoreBinding	ButtonToolTip;

/** provides the text that will appear in status bars while this page is active */
var(Data)	private		UIDataStoreBinding	PageDescription;

// the values to use in the UIDataStoreSubscriber methods for referencing this widget's data bindings.
const TABPAGE_CAPTION_DATABINDING_INDEX		=0;
const TABPAGE_DESCRIPTION_DATABINDING_INDEX	=1;

/* == Delegates == */

/* == Events == */
/**
 * Causes this page to become (or no longer be) the tab control's currently active page.
 *
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that wishes to activate this page.
 * @param	bActivate	TRUE if this page should become the tab control's active page; FALSE if it is losing the active status.
 * @param	bTakeFocus	specify TRUE to give this panel focus once it's active (only relevant if bActivate = true)
 *
 * @return	TRUE if this page successfully changed its active state; FALSE otherwise.
 */
event bool ActivatePage( int PlayerIndex, bool bActivate, optional bool bTakeFocus=true )
{
	local bool bResult;

	bResult = true;
	if ( bActivate )
	{
		if ( CanActivatePage(PlayerIndex) )
		{
			// show this page
			SetVisibility(true);
			if ( bTakeFocus )
			{
				//@todo ronp - hmmm, should I move this inside block so that we only do this if SetFocus is successful?

				// if the tab button is in the targeted state, deactivate it now
				if ( TabButton != None && TabButton.IsTargeted() )
				{
					TabButton.DeactivateStateByClass(class'Engine.UIState_TargetedTab',PlayerIndex);
				}

				// if we were hidden when focus targets were setup, we won't be able to activate the page.
				if ( IsFocusInitializationRequired(PlayerIndex) )
				{
					RebuildNavigationLinks();
				}

				if ( SetFocus(None, PlayerIndex) )
				{
					//@todo - do we need to track whether we're active?
					//bActive = true;
				}
				else
				{
					// if we couldn't become focused for some reason, bail out
					SetVisibility(false);
					bResult = false;

					//@todo - do we need to track whether we're active?
					//SetVisibility(bActive);
				}
			}
			else if ( TabButton != None && !TabButton.IsTargeted() )
			{
				// if we're not supposed to take focus, put our button into the targeted state to indicate
				// which tab page is currently visible.

				//@fixme ronp - if we are already focused, we need to kill focus on this tab and set focus to the tab control...
				TabButton.ActivateStateByClass(class'Engine.UIState_TargetedTab', PlayerIndex);
			}
		}
		else
		{
			bResult = false;
		}
	}
	else
	{
		// if we're being deactivated, make sure our button is not still in the targeted state.
		if ( TabButton != None && TabButton.IsTargeted() )
		{
			TabButton.DeactivateStateByClass(class'Engine.UIState_TargetedTab', PlayerIndex);
		}

		SetVisibility(false);

		//@todo - do we need to track whether we're active?
		//bActive = false;
	}

	return bResult;
}

/**
 * Creates a new UITabButton for this page.   Child classes can override this method in order to do perform additional
 * initialization of the tab button.
 *
 * @param	TabControl			the tab control that is requesting the button.
 */
protected static event UITabButton CreateTabButton( UITabControl TabControl )
{
	local UITabButton NewTabButton;

	if ( TabControl != None )
	{
		`assert(default.ButtonClass != None);

		NewTabButton = UITabButton(TabControl.CreateWidget(TabControl, default.ButtonClass));
	}

	return NewTabButton;
}

/**
 * Associates this UITabPage with the specified tab button.
 *
 * @param	NewButton	the tab button to link this tab page to
 * @param	TabControl	the tab control which will contain this tab page.
 *
 * @return	TRUE if this tab page was successfully linked to the tab button.
 */
event bool LinkToTabButton( UITabButton NewButton, UITabControl TabControl )
{
	local bool bResult;
	local UIObject CurrentOwner;
	local UITabControl CurrentTabControl;

	if ( NewButton != None )
	{
		CurrentOwner = GetOwner();

		if ( CurrentOwner != None )
		{
			// if we're already part of another tab control, remove ourselves first
			CurrentTabControl = GetOwnerTabControl();
			if ( CurrentTabControl != TabControl )
			{
				if ( CurrentTabControl != None )
				{
					CurrentTabControl.RemovePage(Self, GetBestPlayerIndex());
				}
				else
				{
					CurrentOwner.RemoveChild(Self);
				}
			}
			else
			{
				// if we're already correctly linked to this button, no need to do anything
				if ( CurrentOwner == NewButton
				&&	CurrentOwner.ContainsChild(Self,false)
				&&	TabButton == NewButton
				&&	NewButton.GetDataStoreBinding() == ButtonCaption.MarkupString )
				{
					bResult = true;
				}
			}
		}

		// the page is a child of the tab button
		if ( !bResult

		// if we were parented to the button successfully, or were already a child of the button
		&&	(NewButton.InsertChild(Self) != INDEX_NONE || NewButton.ContainsChild(Self,false)) )
		{
			TabButton = NewButton;

			// propagate the caption to the new button.
			NewButton.SetDataStoreBinding(ButtonCaption.MarkupString);
			bResult = true;
		}
	}

	return bResult;
}

/**
 * Notification that this widget's parent is about to remove this widget from its children array.  Allows the widget
 * to clean up any references to the old parent.
 *
 * This version clears the tab page's reference to it's tab button.
 *
 * @param	WidgetOwner		the screen object that this widget was removed from.
 */
event RemovedFromParent( UIScreenObject WidgetOwner )
{
	Super.RemovedFromParent(WidgetOwner);

	// Remove the reference to our parent button.
	if(WidgetOwner==TabButton)
	{
		TabButton = none;
	}
}


/* == Natives == */
/**
 * Returns the tab control that contains this tab page, or NULL if it's not part of a tab control.
 */
native final function UITabControl GetOwnerTabControl() const;

/**
 * Creates the UITabButton for this page, if necessary.   Child classes can override this method in order to do perform
 * additional initialization of the tab button.
 *
 * @param	TabControl	the tab control that is requesting the button.  Should only be specified if the tab page
 *						should a new button if one doesn't exist.
 *
 * @return	the page's tab button
 */
function UITabButton GetTabButton( UITabControl TabControl=None )
{
	if ( TabControl != None && TabButton == None )
	{
		LinkToTabButton(CreateTabButton(TabControl), TabControl);
	}

	return TabButton;
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
native final function bool RefreshSubscriberValue( optional int BindingIndex=INDEX_NONE );

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

/* == UnrealScript == */

/**
 * Called when this tab page is inserted into a tab control's list of pages.  Child classes can override this function
 * to perform any additional initialization.
 *
 * @param	TabControl	the tab control that this page was just added to.
 */
function AddedToTabControl( UITabControl TabControl );

/**
 * Callback for determining whether this page can be activated.
 *
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player that wishes to activate this page.
 */
function bool CanActivatePage( int PlayerIndex )
{
	local bool bResult;

	if ( TabButton != None )
	{
		// give our button a chance to abort the activation
		if ( TabButton.CanActivateButton(PlayerIndex) )
		{
			bResult = true;
		}
	}
	else
	{
		`log("NULL TabButton for" @ GetWidgetPathName() @ "in CanActivatePage()");
	}

	return bResult;
}

/**
 * Checks whether this tab page has initialized its propagation focus targets.
 *
 * @param	PlayerIndex		the index for the player that wants to activate the tab
 *
 * @return	TRUE if the focus propagation for this tab page hasn't been setup yet.
 */
function bool IsFocusInitializationRequired( int PlayerIndex )
{
	local UIScene SceneOwner;
	local bool bResult;

	if ( Children.Length > 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None && !IsEditor() && SceneOwner.bPerformedInitialUpdate )
		{
			// if we were hidden when focus targets were setup, we won't be able to activate the page.
			bResult =	Clamp(PlayerIndex, 0, MAX_SUPPORTED_GAMEPADS) >= FocusPropagation.Length
					||	FocusPropagation[PlayerIndex].FirstFocusTarget == None;
		}
	}

	return bResult;
}

/**
 * Sets the caption for this pages button
 *
 * @param	NewButtonMarkup		The Markup to set the caption to.
 */
function SetTabCaption(string NewButtonMarkup)
{
	TabButton.SetDataStoreBinding(NewButtonMarkup);
}

/**
 * Wrapper for determining whether this is the currently active page.
 *
 * @return	TRUE if this is the tab control's currently active page.
 */
function bool IsActivePage()
{
	local UITabControl TCOwner;

	TCOwner = GetOwnerTabControl();
	return TCOwner != None && TCOwner.ActivePage == Self;
}

DefaultProperties
{
	// PRIVATE_EditorNoDelete|PRIVATE_EditorNoReparent
	PrivateFlags=0x280

	ButtonClass=class'Engine.UITabButton'

	ButtonCaption=(RequiredFieldType=DATATYPE_Property,BindingIndex=TABPAGE_CAPTION_DATABINDING_INDEX)
	ButtonToolTip=(RequiredFieldType=DATATYPE_Property,BindingIndex=TOOLTIP_BINDING_INDEX)
	PageDescription=(RequiredFieldType=DATATYPE_Property,BindingIndex=TABPAGE_DESCRIPTION_DATABINDING_INDEX)
}
