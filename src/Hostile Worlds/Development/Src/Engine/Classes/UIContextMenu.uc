`include(UIDev.uci)

/**
 * Displays a list of options for the user to choose from.  Invoked when the user right-clicks on a widget which supports
 * context menus, and the list of available options are context sensitive.  Items can be either static (using static data
 * providers) or modified at runtime.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIContextMenu extends UIList
	native(inherit)
	HideCategories(List)
	notplaceable;

cpptext
{
	/**
	 * Resolves this context menu's position into actual pixel values.
	 */
	virtual void ResolveContextMenuPosition();

	/** === UUIList interface === */
	/**
	 * Called whenever the user chooses an item while this list is focused.  Activates the SubmitSelection kismet event and calls
	 * the OnSubmitSelection delegate.
	 */
	virtual void NotifySubmitSelection( INT PlayerIndex );

	/* === UIObject interface === */
protected:
	/**
	 * Deactivates the UIState_Focused menu state and updates the pertinent members of FocusControls.
	 *
	 * @param	FocusedChild	the child of this widget that is currently "focused" control for this widget.
	 *							A value of NULL indicates that there is no focused child.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 */
	virtual UBOOL LoseFocus( UUIObject* FocusedChild, INT PlayerIndex );

	/**
	 * Handles input events for this context menu.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const struct FSubscribedInputEventParameters& EventParms );

public:
	/** === UUIScreenObject interface === */
	/**
	 * Overridden to prevent any of this widget's inherited methods or components from triggering a scene update, as context menu
	 * positions are updated differently.
	 *
	 * @param	bDockingStackChanged	if TRUE, the scene will rebuild its DockingStack at the beginning
	 *									the next frame
	 * @param	bPositionsChanged		if TRUE, the scene will update the positions for all its widgets
	 *									at the beginning of the next frame
	 * @param	bNavLinksOutdated		if TRUE, the scene will update the navigation links for all widgets
	 *									at the beginning of the next frame
	 * @param	bWidgetStylesChanged	if TRUE, the scene will refresh the widgets reapplying their current styles
	 */
	virtual void RequestSceneUpdate( UBOOL bDockingStackChanged, UBOOL bPositionsChanged, UBOOL bNavLinksOutdated=FALSE, UBOOL bWidgetStylesChanged=FALSE );

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );
}

/*
	TODO

	- radio group support?
	- kismet events
	- notification that the console has been opened (close this context menu)
*/

/** Different types of context menu items */
enum EContextMenuItemType
{
	/** A normal menu item */
	CMIT_Normal,

	//@fixme - not implemented
	/** A context menu item that has a submenu which is shown when the mouse is held over this menu item for a few seconds */
	CMIT_Submenu,

	/** Separates a group of context menu items */
	CMIT_Separator,

	/** Context menu item that supports a two states - on and off.  State is represented by a check next to the item */
	CMIT_Check,

	/**
	 * Similar to CMIT_Check, except that only one menu item in a particular group can be selected at one time
	 * @todo ronp - determine how groups will be defined
	 */
	CMIT_Radio,
};


/**
 * Represents a single item in a context menu
 *
 * @note - temporary; not sure if this struct will actually be used
 */
struct native transient ContextMenuItem
{
	var			transient	const	UIContextMenu		OwnerMenu;
	var	native	transient	const	pointer				ParentItem{struct FContextMenuItem};


	var	EContextMenuItemType	ItemType;
	var	string					ItemText;
	var	int						ItemId;

	// is separator?
	// checkable items?

	// submenu?
structdefaultproperties
{
	ItemId=-1
	ItemType=CMIT_Normal
}
};

/** the widget that invoked this context menu */
var	transient	const	UIObject					InvokingWidget;

var	transient	const	array<ContextMenuItem>		MenuItems;

/** indicates that this context menu's position needs to be re-resolved during the next scene update */
var	transient	const	bool						bResolvePosition;


/* == Delegates == */

/* == Natives == */
/**
 * Returns TRUE if this context menu is the scene's currently active context menu.
 */
native final function bool IsActiveContextMenu() const;

/**
 * Opens this context menu.  Called by the owning scene when a new context menu is activated.
 *
 * @param	PlayerIndex		the index of the player that triggered the context menu to be opened.
 *
 * @return	TRUE if the context menu was successfully opened.
 */
native final function bool Open( int PlayerIndex=GetBestPlayerIndex() );

/**
 * Closes this context menu.
 *
 * @return	TRUE if the context menu closed successfully; FALSE if it didn't close (as a result of OnClose returning
 *			FALSE, for example)
 */
native final function bool Close( int PlayerIndex=GetBestPlayerIndex() );

/* == Events == */

/**
 * Sets the text that will be displayed in the context menu items.
 *
 * @param	Widget	the widget that invoked this context menu
 * @param	NewMenuItems	the menu items to use in the context menu
 * @param	bClearExisting	specify TRUE to clear any existing menu items; otherwise, the new items will be appended to the old
 * @param	InsertIndex		the location [in the list's items array] to insert the new menu items at; only relevant if bClearExisting is FALSE
 *
 * @return	TRUE if the operation was successful.
 */
event bool SetMenuItems( UIObject Widget, array<string> NewMenuItems, optional bool bClearExisting=true, optional int InsertIndex=INDEX_NONE )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				if ( SceneDS.SetCollectionValueArray(WidgetDSTag, NewMenuItems, bClearExisting, InsertIndex) )
				{
					RefreshSubscriberValue();
					bResult = true;
				}
			}
		}
	}

	return bResult;
}

/**
 * Sets the text for a single context menu item.
 *
 * @param	Widget				the widget that invoked this context menu
 * @param	Item				the text to add/insert to the context menu
 * @param	InsertIndex			the location [in the list's items array] to insert the new menu item; if not specified, will
 *								be appended to the end of the array.
 * @param	bAllowDuplicates	specify TRUE to allow multiple menu items with the same value; otherwise, the new value will
 *								not be added if an existing item has the same value.
 *
 * @return	TRUE if the operation was successful.
 */
event bool InsertMenuItem( UIObject Widget, string Item, optional int InsertIndex=INDEX_NONE, optional bool bAllowDuplicates )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				if ( SceneDS.InsertCollectionValue(WidgetDSTag, Item, InsertIndex, , bAllowDuplicates) )
				{
					RefreshSubscriberValue();
					bResult = true;
				}
			}
		}
	}

	return bResult;
}

/**
 * Removes all context menu items from this context menu.
 *
 * @param	Widget	the widget that invoked this context menu
 *
 * @return	TRUE if the operation was successful.
 */
event bool ClearMenuItems( UIObject Widget )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				if ( SceneDS.ClearCollectionValueArray(WidgetDSTag) )
				{
					RefreshSubscriberValue();
					bResult = true;
				}
			}
		}
	}

	return bResult;
}

/**
 * Removes a single menu item from the context menu.
 *
 * @param	Widget			the widget that invoked this context menu
 * @param	ItemToRemove	the string that should be removed from the context menu
 *
 * @return	TRUE if the value was successfully removed or didn't exist in the first place.
 */
event bool RemoveMenuItem( UIObject Widget, string ItemToRemove )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				if ( SceneDS.RemoveCollectionValue(WidgetDSTag, ItemToRemove) )
				{
					RefreshSubscriberValue();
					bResult = true;
				}
			}
		}
	}

	return bResult;
}

/**
 * Removes the context menu item located at a specified position in the array.
 *
 * @param	Widget			the widget that invoked this context menu
 * @param	IndexToRemove	the index of the item that should be removed.
 *
 * @return	TRUE if the value was successfully removed; FALSE if IndexToRemove wasn't valid or the value couldn't be removed.
 */
event bool RemoveMenuItemAtIndex( UIObject Widget, int IndexToRemove )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				if ( SceneDS.RemoveCollectionValueByIndex(WidgetDSTag, IndexToRemove) )
				{
					RefreshSubscriberValue();
					bResult = true;
				}
			}
		}
	}

	return bResult;
}


//@todo ronp - do we need a replace method?
/**
 * Gets a list of the current context menu items strings.
 *
 * @param	Widget			the widget that invoked this context menu
 * @param	out_MenuItems	receives the context menu item strings
 *
 * @return	TRUE if the operation was successful.
 */
event bool GetAllMenuItems( UIObject Widget, out array<string> out_MenuItems )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				bResult = SceneDS.GetCollectionValueArray(WidgetDSTag, out_MenuItems);
			}
		}
	}

	return bResult;
}

/**
 * Gets the value of the context menu item located at a specified position in the array.
 *
 * @param	Widget			the widget that invoked this context menu
 * @param	IndexToGet		the index of the context menu item to get
 * @param	out_MenuItem	receives the value of the context menu item text.
 *
 * @return	TRUE if the value was successfully retrieved and copied to out_MenuItem.
 */
event bool GetMenuItem( UIObject Widget, int IndexToGet, out string out_MenuItem )
{
	local bool bResult;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				bResult = SceneDS.GetCollectionValue(WidgetDSTag, IndexToGet, out_MenuItem);
			}
		}
	}

	return bResult;
}

/**
 * Finds the location of a string in the context menu's array of items.
 *
 * @param	Widget		the widget that invoked this context menu
 * @param	ItemToFind	the string to find
 *
 * @return	the index for the specified value, or INDEX_NONE if it couldn't be found.
 */
event int FindMenuItemIndex( UIObject Widget, string ItemToFind )
{
	local int Result;
	local UIScene SceneOwner;
	local SceneDataStore SceneDS;
	local name WidgetDSTag;

	Result = INDEX_NONE;
	// widgets inside UIPrefabs have a blank WidgetID; even though we should never be calling this function on a UIPrefab
	// widget, doesn't hurt to double-check
	if ( Widget != None && Widget.WidgetID.A != 0 )
	{
		SceneOwner = GetScene();
		if ( SceneOwner != None )
		{
			SceneDS = SceneOwner.GetSceneDataStore();
			if ( SceneDS != None )
			{
				WidgetDSTag = name(ConvertWidgetIDToString(Widget));
				Result = SceneDS.FindCollectionValueIndex(WidgetDSTag, ItemToFind);
			}
		}
	}

	return Result;
}

/* == UnrealScript == */

/* == SequenceAction handlers == */

DefaultProperties
{
	Position={(
				Value[UIFACE_Left]=0.0,ScaleType[UIFACE_Left]=EVALPOS_PixelViewport,
				Value[UIFACE_Top]=0.0,ScaleType[UIFACE_Top]=EVALPOS_PixelViewport,
				Value[UIFACE_Right]=16,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,
				Value[UIFACE_Bottom]=100,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner
			)}

	// start hidden
	bHidden=true
	bUpdateItemUnderCursor=true
	bEnableActiveCursorUpdates=true

	bEnableVerticalScrollbar=false
	bInitializeScrollbars=false

	ColumnAutoSizeMode=CELLAUTOSIZE_AdjustList
	RowAutoSizeMode=CELLAUTOSIZE_AdjustList
	WrapType=LISTWRAP_Jump
	bEnableMultiSelect=false
	bAllowDisabledItemSelection=false
	bSingleClickSubmission=true

	Begin Object Class=UIComp_ContextMenuListPresenter Name=ContextMenuDataComponent
	End Object
	CellDataComponent=ContextMenuDataComponent
}
