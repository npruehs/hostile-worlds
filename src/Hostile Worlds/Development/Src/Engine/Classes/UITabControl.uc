`include(UIDev.uci)

/**
 * This widget manages a collection of panels.  Only one panel can be active at a time.  Each panel is associated with a tab,
 * which is displayed in a row across one edge of the tab control.  Users select the tab corresponding to the panel they wish
 * to interact with by clicking with the mouse or using the keyboard/gamepad to activate neighboring panels.
 *
 * A UITabControl is composed of two main areas - the "tab region" and the "client region".  The tab region is where the
 * tabs are rendered, while the client region is where the currently active panel is rendered.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UITabControl extends UIObject
	native(UIPrivate)
	config(UI)
	placeable;

/*
	- implement TAST_Manual
	- implement tabs docking on the left and right
*/

cpptext
{
	/* === UITabControl interface === */
	/**
	 * Positions and resizes the tab buttons according the tab control's configuration.
	 */
	virtual void ReapplyLayout();

protected:
	/**
	 * Set up the docking links between the tab control, buttons, and pages, based on the TabDockFace.
	 */
	virtual void SetupDockingRelationships();

public:
	/* === UIObject interface === */
	/**
	 * Render this widget.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Adds docking nodes for all faces of this widget to the specified scene
	 *
	 * @param	DockingStack	the docking stack to add this widget's docking.  Generally the scene's DockingStack.
	 *
	 * @return	TRUE if docking nodes were successfully added for all faces of this widget.
	 */
	virtual UBOOL AddDockingLink( TArray<FUIDockingNode>& DockingStack );

	/**
	 * Adds the specified face to the DockingStack for the specified widget.
	 *
	 * This version ensures that the tab buttons faces (and thus, the size of their captions) have already been resolved
	 * Only relevant when the TabSizeMode is TAST_Fill, because we must make sure that all buttons are at least wide enough
	 * to fit the largest caption of the group.
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
	 * Called when a style reference is resolved successfully.  Applies the TabButtonCaptionStyle and TabButtonBackgroundStyle
	 * to the tab buttons.
	 *
	 * @param	ResolvedStyle			the style resolved by the style reference
	 * @param	StylePropertyId			the name of the style reference property that was resolved.
	 * @param	ArrayIndex				the array index of the style reference that was resolved.  should only be >0 for style reference arrays.
	 * @param	bInvalidateStyleData	if TRUE, the resolved style is different than the style that was previously resolved by this style reference.
	 */
	virtual void OnStyleResolved( UUIStyle* ResolvedStyle, const FStyleReferenceId& StylePropertyId, INT ArrayIndex, UBOOL bInvalidateStyleData );

public:
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

	/**
	 * Generates a array of UI Action keys that this widget supports.
	 *
	 * @param	out_KeyNames	Storage for the list of supported keynames.
	 */
	virtual void GetSupportedUIActionKeyNames( TArray<FName>& out_KeyNames );

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
	virtual UBOOL SetFocus(UUIScreenObject* Sender,INT PlayerIndex=0);

	/**
	 * Sets focus to the first focus target within this container.
	 *
	 * @param	Sender	the widget that generated the focus change.  if NULL, this widget generated the focus change.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 *
	 * @return	TRUE if focus was successfully propagated to the first focus target within this container.
	 */
	virtual UBOOL FocusFirstControl(UUIScreenObject* Sender,INT PlayerIndex=0);

	/**
	 * Sets focus to the last focus target within this container.
	 *
	 * @param	Sender			the widget that generated the focus change.  if NULL, this widget generated the focus change.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 *
	 * @return	TRUE if focus was successfully propagated to the last focus target within this container.
	 */
	virtual UBOOL FocusLastControl(UUIScreenObject* Sender,INT PlayerIndex=0);

	/**
	 * Sets focus to the next control in the tab order (relative to Sender) for widget.  If Sender is the last control in
	 * the tab order, propagates the call upwards to this widget's parent widget.
	 *
	 * @param	Sender			the widget to use as the base for determining which control to focus next
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 *
	 * @return	TRUE if we successfully set focus to the next control in tab order.  FALSE if Sender was the last eligible
	 *			child of this widget or we couldn't otherwise set focus to another control.
	 */
	virtual UBOOL NextControl(UUIScreenObject* Sender,INT PlayerIndex=0);

	/**
	 * Sets focus to the previous control in the tab order (relative to Sender) for widget.  If Sender is the first control in
	 * the tab order, propagates the call upwards to this widget's parent widget.
	 *
	 * @param	Sender			the widget to use as the base for determining which control to focus next
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 *
	 * @return	TRUE if we successfully set focus to the previous control in tab order.  FALSE if Sender was the first eligible
	 *			child of this widget or we couldn't otherwise set focus to another control.
	 */
	virtual UBOOL PrevControl(UUIScreenObject* Sender,INT PlayerIndex=0);

	/**
	 * Sets focus to the widget bound to the navigation link for specified direction of the Sender.  This function
	 * is used for navigation between controls in scenes that support unbound (i.e. any direction) navigation.
	 *
	 * @param	Sender		Control that called NavigateFocus.  Possible values are:
	 *						-	if NULL is specified, it indicates that this is the first step in a focus change.  The widget will
	 *							attempt to set focus to its most eligible child widget.  If there are no eligible child widgets, this
	 *							widget will enter the focused state and start propagating the focus chain back up through the Owner chain
	 *							by calling SetFocus on its Owner widget.
	 *						-	if Sender is the widget's owner, it indicates that we are in the middle of a focus change.  Everything else
	 *							proceeds the same as if the value for Sender was NULL.
	 *						-	if Sender is a child of this widget, it indicates that focus has been successfully changed, and the focus is now being
	 *							propagated upwards.  This widget will now enter the focused state and continue propagating the focus chain upwards through
	 *							the owner chain.
	 * @param	Direction 		the direction to navigate focus.
	 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated the focus change.
	 * @param	bFocusChanged	TRUE if the focus was changed
	 *
	 * @return	TRUE if the navigation event was handled successfully.
	 */
	virtual UBOOL NavigateFocus(UUIScreenObject* Sender,BYTE Direction,INT PlayerIndex=0,BYTE* bFocusChanged=NULL);

	/**
	 * Called when the scene receives a notification that the viewport has been resized.  Propagated down to all children.
	 *
	 * @param	OldViewportSize		the previous size of the viewport
	 * @param	NewViewportSize		the new size of the viewport
	 */
	virtual void NotifyResolutionChanged( const FVector2D& OldViewportSize, const FVector2D& NewViewportSize );

protected:
	/**
	 * Handles input events for this widget.
	 *
	 * @param	EventParms		the parameters for the input event
	 *
	 * @return	TRUE to consume the key event, FALSE to pass it on.
	 */
	virtual UBOOL ProcessInputKey( const FSubscribedInputEventParameters& EventParms );

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

/**
 * Different ways to adjust the sizes of tab buttons used in this control.
 */
enum EUITabAutosizeType
{
	/** No autosizing; the size for each tab button will be set manually. */
	TAST_Manual,

	/** all tab buttons will be the same width, and will be expanded to fill the entire width of this control */
	TAST_Fill,

	/** Standard autosizing; all tab buttons will be resized to fit their captions */
	TAST_Auto,

	/** All tabs will have the width of the widest tab, which is auto-sized according to its caption */
//	TAST_Justified,
};

/*================================================
	Components
================================================*/
/**
 * the list of tab pages managed by this UITabControl
 */
var()	protected{protected} editinline editfixedsize editconst array<UITabPage>	Pages;

/**
 * Reference to the currently active page
 */
var(ZDebug) editconst editinline	transient	UITabPage			ActivePage;

/**
 * Reference to the page which is about to become active.
 */
var(ZDebug) editconst editinline	transient	UITabPage			PendingPage;

/*================================================
	Configuration
================================================*/
/**
 * Controls which face of this UITabControl the tab buttons will be docked to
 * @todo ronp - currently only top and bottom are properly supported.  In order to support left & right, we'll probably
 * need to rotate the buttons, but first need to figure out what the docking relationship should be in that case.
 */
var(Appearance)	EUIWidgetFace				TabDockFace;

/** The mode to use for sizing the tab buttons */
var(Appearance)	EUITabAutosizeType			TabSizeMode;

/**
 * The size to use for the tab buttons along the orientation of the TabDockFace (i.e. if tabs are docked at top or bottom,
 * this determines the height of the tabs)
 */
var(Appearance)	UIScreenValue_Extent		TabButtonSize;

/**
 * The amount of padding to apply to each button's text.  The specified value will be evenly distributed to each sides of
 * the button's caption.
 */
var(Appearance)	UIScreenValue_Extent		TabButtonPadding[EUIOrientation.UIORIENT_MAX];

/** The style to use for the tab button background image */
var	private			UIStyleReference			TabButtonBackgroundStyle;

/** The style to use for the tab button labels */
var	private			UIStyleReference			TabButtonCaptionStyle;

/** Controls whether tab buttons are allowed to enter the targeted state */
var(Appearance)	config	bool				bAllowPagePreviews;

/*================================================
	Sounds
================================================*/
/** this sound is played when a new tab is activated */
var(Sound)				name					ActivateTabCue;

/*================================================
	Runtime
================================================*/
/** set to indicate that the tab control should layout the buttons and panels during the next tick */
var	transient				bool				bUpdateLayout;

//@todo ronp - implement this
//var UIDataStoreBinding	InitiallyActiveTab;

/* == Delegates == */
/**
 * Called when a new page is activated.
 *
 * @param	Sender			the tab control that activated the page
 * @param	NewlyActivePage	the page that was just activated
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 */
delegate OnPageActivated( UITabControl Sender, UITabPage NewlyActivePage, int PlayerIndex );

/**
 * Called when a new page is added to this tab control.
 *
 * @param	Sender			the tab control that added the page
 * @param	NewPage			the page that was just added
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 */
delegate OnPageInserted( UITabControl Sender, UITabPage NewPage, int PlayerIndex );

/**
 * Called when a page is removed from this tab control.
 *
 * @param	Sender			the tab control that removed the page
 * @param	OldPage			the page that was removed
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 */
delegate OnPageRemoved( UITabControl Sender, UITabPage OldPage, int PlayerIndex );

/* == Natives == */
/**
 * Enables the bUpdateLayout flag and triggers a scene update to occur during the next frame.
 */
native final function RequestLayoutUpdate();

/**
 * Returns the number of pages in this tab control.
 */
native final function int GetPageCount() const;

/**
 * Returns a reference to the page at the specified index.
 */
native final function UITabPage GetPageAtIndex( int PageIndex ) const;

/**
 * Returns a reference to the tab button which is currently in the Targeted state, or NULL if no buttons are in that state.
 */
native final function UITabButton FindTargetedTab( int PlayerIndex ) const;

/**
 * Creates a new UITabPage of the specified class as well as its associated tab button.
 *
 * @param	TabPageClass	the class to use for creating the tab page.
 * @param	PagePrefab		if specified, the prefab to use for creating this tab page.
 *
 * @return	a pointer to a new instance of the specified UITabPage class
 */
native function UITabPage CreateTabPage( class<UITabPage> TabPageClass, optional UITabPage PagePrefab );

/* == Events == */
/**
 * Worker method for setting a new active page.  Handles deactivating the previously active page and firing the appropriate notifications.
 *
 * @param	PageToActivate		the tab page that should be become the active page
 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player to activate this tab for.
 *
 * @return	TRUE if the specified page was successfully activated.
 */
protected event PrivateActivatePage( UITabPage PageToActivate, int PlayerIndex )
{
	// de-activate the currently active page
	if ( ActivePage != None && PageToActivate != ActivePage )
	{
		ActivePage.ActivatePage(PlayerIndex, false);
	}

	// clear the pending page ref
	PendingPage = None;

	// assign the active page ref
	ActivePage = PageToActivate;

	// fire the page changed delegate -- CAUTION! ActivePage might be none!
	OnPageActivated(Self, ActivePage, PlayerIndex);
}

/**
 * Inserts a page at the specified location.
 *
 * @param	PageToInsert	the tab page to insert
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this action.
 * @param	InsertIndex		location to insert the page in the Pages array.  If not specified, page is inserted at the end.
 * @param	bActivateImmediately
 *							if TRUE, immediately activates the page and gives it focus
 *
 * @return	TRUE if the page was successfully added to this tab control
 */
event bool InsertPage( UITabPage PageToInsert, int PlayerIndex, int InsertIndex=INDEX_NONE, optional bool bActivateImmediately=true )
{
	local bool bResult;
	local UITabButton NewTab;
	local int ChildInsertIndex;

//	`log(">>>" @ `location @ `showobj(PageToInsert) @ `showvar(bActivateImmediately),,'DevUI' );
	if ( PageToInsert != None && Pages.Find(PageToInsert) == INDEX_NONE )
	{
		// if this is the first page being inserted, we always activate it
		bActivateImmediately = bActivateImmediately || (Pages.Length == 1 && IsVisible());

		// call the CreateButton() method on the page to get a UITabButton
		NewTab = PageToInsert.GetTabButton(Self);
		if ( NewTab != None )
		{
			// verify that we have a valid insertion index
			if ( InsertIndex < 0 || InsertIndex >= Pages.Length )
			{
				InsertIndex = Pages.Length;
			}

			// for now, let's try having the tab button in our Children array, and having the page as a child of the tab
			if ( InsertIndex > 0 )
			{
				`assert(Pages[InsertIndex-1]!=None);			// hmmm, this might happen if this page was a custom class and that class was removed
				`assert(Pages[InsertIndex-1].GetTabButton()!=None);	// hmmm, this might happen if this page was a custom class and that class was removed

				// find the location of the previous page's button in the Children array; we'll insert this new page's
				// button into the Children array just after that one
				ChildInsertIndex = Children.Find(Pages[InsertIndex - 1].GetTabButton());
				`assert(ChildInsertIndex!=INDEX_NONE);	// the previous page's button should be in the Children array.

				ChildInsertIndex++;
			}
			else
			{
				ChildInsertIndex = InsertIndex;
			}

			// make sure that the page is linked to the tab
			PageToInsert.LinkToTabButton(NewTab, Self);

			// add the tab to our Children array
			if ( InsertChild(NewTab, ChildInsertIndex, false) != INDEX_NONE )
			{
				// add the page to the list
				Pages.Insert(InsertIndex, 1);
				Pages[InsertIndex] = PageToInsert;

				// set the TabIndex for the button to the same value as its index in the Pages array so that
				// our FocusPropagation references are set correctly (i.e. the first tab button is our FirstFocusedControl, etc.)
				NewTab.TabIndex = ChildInsertIndex;

				// allow the page to perform additional initialization
				PageToInsert.AddedToTabControl(Self);

				// fire the notification that we've added a new page
				OnPageInserted(Self, PageToInsert, PlayerIndex);

				// if we want to activate the page as well, do that now.
				if ( !bActivateImmediately || !ActivatePage(PageToInsert, PlayerIndex, true) )
				{
					// otherwise, hide it
					PageToInsert.SetVisibility(false);
				}

				RequestLayoutUpdate();
				bResult = true;
			}
		}
	}

//	`log("<<<" @ `location @ `showobj(PageToInsert) @ `showvar(bActivateImmediately) @ `showvar(bResult),,'DevUI');
	return bResult;
}

/**
 * Removes the specified page from this tab control's list of pages.
 *
 * @param	PageToRemove	the tab page to remove
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this action.
 *
 * @return	TRUE if the page was successfully removed from the pages array.
 */
event bool RemovePage( UITabPage PageToRemove, int PlayerIndex )
{
	local bool bResult;
	local int PageIndex;

//	`log(">>>" @ `location @ `showobj(PageToRemove),,'DevUI' );
	if ( PageToRemove != None )
	{
		// locate the page that should be removed
		PageIndex = FindPageIndexByPageRef(PageToRemove);
		if ( PageIndex >= 0 && PageIndex < Pages.Length )
		{
			Pages.Remove(PageIndex,1);

			// remove the tab page's button from our children array; this will clear the button's OnClicked delegate.
			if ( PageToRemove.GetTabButton() != None )
			{
				RemoveChild(PageToRemove.GetTabButton());
			}

			// fire the notication that we've removed a page
			OnPageRemoved(Self, PageToRemove, PlayerIndex);

			// notify both panel and button that they are being removed?

			// if this was the active tab, attempt to activate the next tab in the list
			if ( PageToRemove == ActivePage )
			{
				ActivePage = None;
				ActivateBestTab( PlayerIndex, true, PageIndex );
			}

			// anything else?

			RequestLayoutUpdate();
			bResult = true;
		}
	}

//	`log("<<<" @ `location @ `showobj(PageToRemove) @ `showvar(bResult),,'DevUI');
	return bResult;
}

/**
 * Replaces one tab page with another one.
 *
 * @param	ExistingPage	the tab page to replace; must be a page that is currently in this tab control's Pages array.
 * @param	NewPage			the tab page that will replace the existing one.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this action.
 * @param	bFocusPage		if TRUE, immediately activates the page and gives it focus
 *
 * @return	TRUE if the page was successfully replaced.
 */
event bool ReplacePage( UITabPage ExistingPage, UITabPage NewPage, int PlayerIndex, optional bool bFocusPage=true )
{
	local bool bResult;
	local int PageIndex;

//	`log(">>>" @ `location @ `showobj(ExistingPage) @ `showobj(NewPage) @ `showvar(bFocusPage),,'DevUI' );

	if ( ExistingPage != None && NewPage != None )
	{
		PageIndex = FindPageIndexByPageRef(ExistingPage);
		if ( PageIndex != INDEX_NONE )
		{
			//@todo ronp - might be able to optimize this

			// insert new page at the location of the old page
			if ( InsertPage(NewPage, PlayerIndex, PageIndex, bFocusPage) )
			{
				// remove old page
				if ( RemovePage(ExistingPage, PlayerIndex) )
				{
					bResult = true;
					RequestLayoutUpdate();
				}
				else
				{
					// if we couldn't remove the old page, abort the whole thing which means we need
					// to undo the insertion of the new page
					RemovePage(NewPage, PlayerIndex);
				}
			}
		}
	}

//	`log("<<<" @ `location @ `showobj(ExistingPage) @ `showobj(NewPage) @ `showvar(bResult),,'DevUI');
	return bResult;
}

/**
 * Attempts to activate the specified tab page.
 *
 * @param	PageToActivate		the tab page that should be become the active page
 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player to activate this tab for.
 * @param	bFocusPage			specify FALSE if the tab control itself should maintain focus.
 *
 * @return	TRUE if the specified page was successfully activated.
 */
event bool ActivatePage( UITabPage PageToActivate, int PlayerIndex, optional bool bFocusPage=true )
{
	local bool bResult;

//	`log(">>>" @ `location @ `showobj(PageToActivate) @ `showvar(bFocusPage) @ "(" $ `showobj(ActivePage) $ ")",,'DevUI' );
	// verify that the tab can become active (button might call into its panel to see if something would prevent the panel from becoming active)
	// and that we don't have a PendingPage (which indicates that another page is currently in the process of becoming the active page)
	if ( PageToActivate != None && PendingPage == None && PageToActivate.CanActivatePage(PlayerIndex) )
	{
		// PageToActivate.bForceFlash = false;

		if ( PageToActivate != ActivePage )
		{
			// set pending tab
			PendingPage = PageToActivate;
			if ( PendingPage.ActivatePage(PlayerIndex, true, bFocusPage) )
			{
				// call the activatepage worker (PrivateActivatePage), which actually switches the active page ref.
				//@todo ronp - here is where we would insert the code to perform any type of transition animations
				// see the UT2004 source....
				PrivateActivatePage(PageToActivate, PlayerIndex);

				// play tab switched sound
				PlayUISound(ActivateTabCue);

				bResult = true;
			}
			else
			{
				PendingPage = None;
			}
		}
		else
		{
			bResult = ActivePage.ActivatePage(PlayerIndex, true, bFocusPage);
		}
	}

//	`log("<<<" @ `location @ `showobj(PageToActivate) @ `showvar(bResult) @ "(" $ `showobj(ActivePage) $ ")",,'DevUI');
	return bResult;
}

/**
 * Activates the page immediately after the currently active page.  If the currently active page is the last one,
 * activates the first page.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 * @param	bFocusPage		specify FALSE if the tab control itself should maintain focus.
 * @param	bAllowWrapping	specify false to prevent the first page from being activated if the currently active page
 *							is the last page in the stack.
 *
 * @return	TRUE if the next page was successfully activated.
 */
event bool ActivateNextPage( int PlayerIndex, optional bool bFocusPage=true, optional bool bAllowWrapping=true )
{
	local bool bResult;
	local int PageIndex, NumPages;
	local UITabPage NextPage;

//	`log(">>>" @ `location,,'DevUI');
	NumPages = GetPageCount();
	if ( NumPages > 1 )
	{
		PageIndex = FindPageIndexByPageRef(ActivePage);
		if ( PageIndex >= 0 && PageIndex < NumPages - 1 )
		{
			// if the index of currently active page is valid, increment the index so that we activate the next one
			PageIndex++;
		}
		else if ( ActivePage == None || bAllowWrapping )
		{
			// otherwise, reset back to zero so that we activate the first one
			PageIndex = 0;
		}
		else
		{
			PageIndex = NumPages;
		}

		NextPage = GetPageAtIndex(PageIndex);
		bResult = ActivatePage(NextPage, PlayerIndex, bFocusPage);
	}

//	`log("<<<" @ `location @ `showvar(bResult),,'DevUI');
	return bResult;
}

/**
 * Activates the page immediately before the currently active page.  If the currently active page is the first one,
 * activates the last page.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 * @param	bFocusPage		specify FALSE if the tab control itself should maintain focus.
 * @param	bAllowWrapping	specify false to prevent the first page from being activated if the currently active page
 *							is the last page in the stack.
 *
 * @return	TRUE if the previous page was successfully activated.
 */
event bool ActivatePreviousPage( int PlayerIndex, optional bool bFocusPage=true, optional bool bAllowWrapping=true )
{
	local bool bResult;
	local int PageIndex, NumPages;
	local UITabPage PreviousPage;

//	`log(">>>" @ `location,,'DevUI');
	NumPages = GetPageCount();
	if ( NumPages > 1 )
	{
		PageIndex = FindPageIndexByPageRef(ActivePage);
		if ( PageIndex > 0 && PageIndex < NumPages )
		{
			// if the index of currently active page is valid, decrement the index so that we activate the previous one
			PageIndex--;
		}
		else if ( ActivePage == None || bAllowWrapping )
		{
			// otherwise, reset back to the last index so that we activate the last one
			PageIndex = NumPages - 1;
		}
		else
		{
			PageIndex = INDEX_NONE;
		}

		PreviousPage = GetPageAtIndex(PageIndex);
		bResult = ActivatePage(PreviousPage, PlayerIndex, bFocusPage);
	}

//	`log("<<<" @ `location @ `showvar(bResult),,'DevUI');
	return bResult;
}

/**
 * Enables/disables a tab page and its associated tab button.
 *
 * @param	PageToEnable	the page to enable/disable.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this event.
 * @param	bEnablePage		controls whether the page should be enabled or disabled.
 * @param	bActivatePage	if true, the page will also be activated (only relevant if bEnablePage is true).
 * @param	bFocusPage		specify FALSE if the new page should not become the focused control (only relevant if bActivatePage is true)
 *
 * @return	TRUE if the page was successfully enabled/disabled.
 */
event bool EnableTabPage( UITabPage PageToEnable, int PlayerIndex, bool bEnablePage=true, optional bool bActivatePage, optional bool bFocusPage=true )
{
	local bool bResult;
	local int PageIndex;

	if ( PageToEnable != None )
	{
		// we want to enable the page
		if ( bEnablePage )
		{
			// if the page is already enabled, just perform the activation
			if ( PageToEnable.IsEnabled(PlayerIndex) )
			{
				// page is already enabled - indicate success
				bResult = true;

				// make sure the button is also enabled.
				PageToEnable.GetTabButton().EnableWidget(PlayerIndex);
			}
			else
			{
				// enable the page's button
				if ( PageToEnable.GetTabButton().EnableWidget(PlayerIndex) )
				{
					// enable the page
					bResult = PageToEnable.EnableWidget(PlayerIndex);
				}
			}

			if ( bResult && bActivatePage )
			{
				ActivatePage(PageToEnable, PlayerIndex, bFocusPage);
			}
		}
		else
		{
			// disable its button first
			PageToEnable.GetTabButton().DisableWidget(PlayerIndex);

			// we want to disable the page - this is a bit trickier
			if ( !PageToEnable.IsEnabled(PlayerIndex) )
			{
				bResult = true;
			}
			else
			{
				PageIndex = FindPageIndexByPageRef(PageToEnable);	//@fixme ronp - no check for valid PageIndex

				// next, before we disable the page itself, we need to make sure
				if ( PageToEnable == ActivePage )	//@todo ronp - what about PendingPage?
				{
					ActivePage = None;
					PendingPage = None;
					ActivateBestTab(PlayerIndex, PageToEnable.IsFocused(PlayerIndex), PageIndex);
					//@fixme ronp - no check for ActivateBestTab failure.
				}

				bResult = PageToEnable.DisableWidget(PlayerIndex);
			}
		}
	}

	return bResult;
}

/* === UIScreenObject interface === */

/**
 * Called after this screen object's children have been initialized
 */
event PostInitialize()
{
	Super.PostInitialize();

	// because the FocusPropagation arrays haven't been setup by this point, this won't actually set focus
	// but it will put the tab button for the initially active page in a state which allows it to recieve focus as soon
	// as the FocusPropagation arrays are initialized.
	ActivateBestTab(GetBestPlayerIndex());
}

/**
 * Called immediately after a child has been added to this screen object.
 *
 * This version hooks up the OnClicked delegate for the newly added button.
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	local UITabButton TabButton;

	Super.AddedChild(WidgetOwner, NewChild);

	if ( WidgetOwner == Self )
	{
		TabButton = UITabButton(NewChild);
		if ( TabButton != None )
		{
			TabButton.OnClicked = TabButtonClicked;
		}
	}
}

/* == Unrealscript == */
/**
 * Attempts to activate the specified tab page.
 *
 * @param	PageToActivate		the tab page that should be become the active page
 * @param	PlayerIndex			the index [into the Engine.GamePlayers array] for the player to activate this tab for.
 * @param	bFocusPage			specify FALSE if the tab control itself should maintain focus.
 *
 * @return	TRUE if the specified page was successfully activated.
 */
function bool ActivatePageByCaption( string PageCaption, int PlayerIndex, optional bool bFocusPage=true )
{
	local int PageIndex;
	local bool bResult;

	PageIndex = FindPageIndexByCaption(PageCaption);
	if ( PageIndex != INDEX_NONE )
	{
		bResult = ActivatePage(Pages[PageIndex], PlayerIndex, bFocusPage);
	}

	return bResult;
}

/**
 * Chooses the best tab to activate and activates it.
 *
 * @param	PlayerIndex	the index [into the Engine.GamePlayers array] for the player to activate this tab for.
 * @param	bFocusPage			specify FALSE if the tab control itself should maintain focus.
 * @param	StartIndex	if specified, starts the iteration at this index when searching for a new tab to activate.
 *
 * @return	TRUE if a tab was successfully activated.
 */
function bool ActivateBestTab( int PlayerIndex, optional bool bFocusPage=true, optional int StartIndex=0 )
{
	local int PageIndex;
	local bool bResult;

	if ( Pages.Length > 0 )
	{
		// make sure we have a valid starting index so that the loop can eventually stop
		if ( StartIndex < 0 || StartIndex >= Pages.Length )
		{
			StartIndex = 0;
		}

		PageIndex = StartIndex;
		do
		{
			// attempt to activate the next page in the list
			if ( ActivatePage(Pages[PageIndex], PlayerIndex, bFocusPage) )
			{
				bResult = true;
				break;
			}

			// couldn't activate that one, so try to next one
			if ( ++PageIndex >= Pages.Length )
			{
				PageIndex = 0;
			}
		} until ( PageIndex == StartIndex );
	}

	return bResult;
}

/**
 * Returns the index [into the Pages array] for the page which has a button with the specified caption.
 *
 * @param	PageCaption		the caption to use for searching for the page
 * @param	bMarkupString	if TRUE, searches for the button that has PageCaption as its data store binding.
 *
 * @return	INDEX_NONE if no page was found with the specified caption.
 */
function int FindPageIndexByCaption( string PageCaption, optional bool bMarkupString )
{
	local int PageIndex;
	local UITabButton btn;

	PageIndex = INDEX_NONE;
	if ( Len(PageCaption) > 0 )
	{
		for ( PageIndex = Pages.Length - 1; PageIndex >= 0; PageIndex-- )
		{
			if ( Pages[PageIndex] != None )
			{
				btn = Pages[PageIndex].GetTabButton();
				if ( btn != None )
				{
					if ( bMarkupString )
					{
						if ( btn.GetDataStoreBinding() ~= PageCaption )
						{
							break;
						}
					}
					else
					{
						if ( btn.GetCaption() ~= PageCaption )
						{
							break;
						}
					}
				}
			}
		}
	}

	return PageIndex;
}

/**
 * Returns the index [into the Pages array] for the page which has the specified button.
 *
 * @return	INDEX_NONE if no page was found with the specified button.
 */
function int FindPageIndexByButton( UITabButton SearchButton )
{
	local int PageIndex;

	PageIndex = INDEX_NONE;
	if ( SearchButton != None )
	{
		for ( PageIndex = Pages.Length - 1; PageIndex >= 0; PageIndex-- )
		{
			if ( Pages[PageIndex] != None && Pages[PageIndex].GetTabButton() == SearchButton )
			{
				break;
			}
		}
	}

	return PageIndex;
}

/**
 * Returns the index [into the Pages array] for the specified page.
 *
 * @return	INDEX_NONE if the specified was None or isn't in the Pages array.
 */
function int FindPageIndexByPageRef( UITabPage SearchPage )
{
	local int PageIndex;

	PageIndex = INDEX_NONE;
	if ( SearchPage != None )
	{
		for ( PageIndex = Pages.Length - 1; PageIndex >= 0; PageIndex-- )
		{
			if ( Pages[PageIndex] == SearchPage )
			{
				break;
			}
		}
	}

	return PageIndex;
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * Allows the user to use the left/right arrow keys to preview other panels if this widget is the globally focused control
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool ProcessInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;
	local name PrevKey, NextKey;

	// tab page preview mode is only active when the tab control is focused but doesn't have a focused control of its own
	if ( IsVisible() && bAllowPagePreviews
	&&	(EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat)
	&&	IsFocused(EventParms.PlayerIndex) && GetFocusedControl(false, EventParms.PlayerIndex) == None )
	{
		switch ( TabDockFace )
		{
		case UIFACE_Top:
		case UIFACE_Bottom:
			PrevKey = 'Left';
			NextKey = 'Right';
			break;

		case UIFACE_Left:
		case UIFACE_Right:
			PrevKey = 'Up';
			NextKey = 'Down';
			break;
		}

		if ( EventParms.InputKeyName == PrevKey )
		{
			// Send false for bFocusPanel to ActivatePreviousPage so that we remain the focused control and the user
			// can continue using left/right to preview other pages.
			ActivatePreviousPage(EventParms.PlayerIndex, false, true);
			bResult = true;
		}
		else if ( EventParms.InputKeyName == NextKey )
		{
			// Send false for bFocusPanel to ActivateNextPage so that we remain the focused control and the user
			// can continue using left/right to preview other pages.
			ActivateNextPage(EventParms.PlayerIndex, false, true);
			bResult = true;
		}
	}

	return bResult;
}

/**
 * Called when the user clicks on a tab button and releases the mouse.  Begins activating the associated tab page.
 *
 * @param EventObject	Object that issued the event.
 * @param PlayerIndex	Player that performed the action that issued the event.
 *
 * @return	return TRUE to prevent the kismet OnClick event from firing.
 */
function bool TabButtonClicked(UIScreenObject EventObject, int PlayerIndex)
{
	local UITabButton ClickedButton;
	local UITabPage PageToActivate;
	local bool bResult;

	ClickedButton = UITabButton(EventObject);
	if ( ClickedButton != None )
	{
		PageToActivate = ClickedButton.GetTabPage();
		if ( PageToActivate != None && Pages.Find(PageToActivate) != INDEX_NONE )
		{
			// activate the page
			ActivatePage(PageToActivate, PlayerIndex, true);

			// if the page was in our list, don't allow kismet to process it even if ActivatePage returned false.
			bResult = true;
		}
		// if this page wasn't in our list, allow kismet to process it
	}

	return bResult;
}

DefaultProperties
{
	bSupportsPrimaryStyle=false

	OnRawInputKey=ProcessInputKey

	TabDockFace=UIFACE_Top
	TabSizeMode=TAST_Auto
	TabButtonSize=(Value=0.02,ScaleType=UIEXTENTEVAL_PercentOwner,Orientation=UIORIENT_Vertical)
	TabButtonPadding(UIORIENT_Horizontal)=(Value=0.02,ScaleType=UIEXTENTEVAL_PercentOwner,Orientation=UIORIENT_Horizontal)
	TabButtonPadding(UIORIENT_Vertical)=(Value=0.02,ScaleType=UIEXTENTEVAL_PercentOwner,Orientation=UIORIENT_Vertical)

	bUpdateLayout=true

	// Styles
	TabButtonBackgroundStyle=(DefaultStyleTag="TabButtonBackgroundStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	TabButtonCaptionStyle=(DefaultStyleTag="DefaultTabButtonStringStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Pressed')
	DefaultStates.Add(class'Engine.UIState_Active')
}
