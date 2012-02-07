/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKSimpleList extends UDKDrawPanel
	native;

/************ These values can be set in the editor ***********/

/** The font to use for rendering */
var() font TextFont;

var() color NormalColor;
var() color AboveBelowColor;
var() color SelectedColor;
var() color SelectionBarColor;
var() color ArrowColor;

/** Selection Image texture. */
var() texture2D SelectionImage;

/** Selection bar icon bg UVs. */
var() float	SelectionImageIconBGU;
var() float	SelectionImageIconBGV;
var() float	SelectionImageIconBGUL;
var() float	SelectionImageIconBGVL;

/** Selection bar image UVs. */
var() float	SelectionImageBarU;
var() float	SelectionImageBarV;
var() float	SelectionImageBarUL;
var() float	SelectionImageBarVL;

var() texture2D ArrowImage;

/** This is how big the normal cell of text is at 1024x768. */
var() float DefaultCellHeight;

/** How mucbh to multiply the above and below cells by */
var() float AboveBelowCellHeightMultiplier;

/** How much to multiply the selected cell by */
var() float SelectionCellHeightMultiplier;

/** How fast should we transition between objects */
var() float TransitionTime;

/** This is the ratio of Height to widget for the selection widget's box.  It will be used to size the list*/
var() float ScrollWidthRatio;
var() bool bHideScrollArrows;	/** Whether or not we should draw scroll arrows. */

/** Padding and offset percentage for a normal list item's text. */
var() vector2D NormalTextPadding;
var() vector2D NormalTextOffset;

/** Padding and offset percentage for a selected list item's text. */
var() vector2D SelectedTextPadding;
var() vector2D SelectedTextOffset;

/** Distance of the text drop shadow. */
var() float ShadowDist;

/** Color of text drop shadow. */
var() color ShadowColor;

struct native SimpleListData
{
	// Text for this entry.  Can be markup as it will be resolved when set
	var()	string	Text;

	// A general int TAG for indexing extra data.
	var() int		Tag;

	// The current Height Multiplier
	var float CurHeightMultiplier;

	/** Alpha to use to transition this item. */
	var float TransitionAlpha;

	// Is set to true if this cell was actually rendered this frame
	var bool bWasRendered;

	structdefaultproperties
	{
		CurHeightMultiplier=1.0
		TransitionAlpha=1.0
	}
};

/** The list itself. */
var() editinline array<SimpleListData> List;

/** Index of the current top widget */
var transient int Top;

/** Index of the currently selected widget */
var() transient int Selection;

/** Floating point selection position (0 .. (List.length - 1)) */
var transient float SelectionPos;

/** Index of the previously selected widget. */
var transient float OldSelection;

/** Whether we are a vertical or horizontal list. */
var() bool bHorizontalList;

/** Whether or not the list should wrap. */
var() bool bWrapList;

/** Whether or not to hot track the current item mouse cursor. */
var() bool bHotTracking;

/** Size of the selection bubble, used to calculate alpha for items around the selected item. */
var() int BubbleRadius;

/** If true, the positions have been invalidated so recalculate the sizes/etc. */
var transient bool bInvalidated;

/** This is calculated once each frame and cached.  It holds the resolution scaling factor
    that is forced to a 4:3 aspect ratio.  */
var transient vector2D ResScaling;

/** Last time this scene was rendered */
var transient float LastRenderTime;

/** Defines the top of the window in to the overall list to begin rendering */
var transient float WindowTop;

/** How big is the rendering window */
var transient float WindowHeight;

/** How big is the list in pixels */
var transient float ListHeightInPixel;

/** Used to animate the scroll.  These hold the target top position and the current transition timer */
var transient float TargetWindowTop;
var transient float WindowTopTransitionTime;

/** We cache the rendering bounds of the Up/Down arrows for quick mouse look up. */
var transient float UpArrowBounds[4];
var transient float DownArrowBounds[4];

/** Used to animate the transition from one selection to another. */
var transient float StartSelectionTime;
var transient float SelectionAlpha;
var transient bool bTransitioning;
var transient float OldBarPosition;
var transient float BarPosition;

/** Whether or not the up arrow is currently pressed. */
var transient bool bUpArrowPressed;

/** Whether or not the down arrow is currently pressed. */
var transient bool bDownArrowPressed;

var transient bool bDragging;
var transient float DragAdjustment;

var float LastMouseUpdate;

/** True if the mouse cursor is currently over the menu */
var transient bool bIsMouseOverMenu;

/** True if we're currently using the mouse to navigate the menu */
var transient bool bIsUsingMouseNavigation;


/*	======================================================================
		Natives
	====================================================================== */

cpptext
{
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);


	/**
	 * Called when the scene receives a notification that the viewport has been resized.  Propagated down to all children.
	 *
	 * @param	OldViewportSize		the previous size of the viewport
	 * @param	NewViewportSize		the new size of the viewport
	 */
	virtual void NotifyResolutionChanged( const FVector2D& OldViewportSize, const FVector2D& NewViewportSize );

}



/**
 * @Returns the index of the first entry matching SearchText
 */
native function int Find(string SearchText);

/**
 * @Returns the index of the first entry with a tag that matches SearchTag
 */
native function int FindTag(int SearchTag);


/**
 * Sorts the list
 */

native function SortList();

native function UpdateAnimation(FLOAT DeltaTime);


/**
 * Setup the input system
 */
event PostInitialize()
{
	local int i;
	Super.PostInitialize();
	OnProcessInputKey=ProcessInputKey;
	OnProcessInputAxis=ProcessInputAxis;

	// Force resolve of everything

	for (i=0;i<List.Length;i++)
	{
		List[i].Text = ResolveText(List[i].Text);
	}

	// Default to using mouse navigation on PC platform.  If the user presses a keyboard button, this will turn off.
	// Moving the mouse will reactivate it.
	if( !IsConsole() )
	{
		bIsUsingMouseNavigation = true;
	}
}



/*	======================================================================
		Input
	====================================================================== */


event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'SelectionUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionDown';
	out_KeyNames[out_KeyNames.Length] = 'SelectionLeft';
	out_KeyNames[out_KeyNames.Length] = 'SelectionRight';
	out_KeyNames[out_KeyNames.Length] = 'SelectionHome';
	out_KeyNames[out_KeyNames.Length] = 'SelectionEnd';
	out_KeyNames[out_KeyNames.Length] = 'SelectionPgUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionPgDn';
	out_KeyNames[out_KeyNames.Length] = 'Select';
	out_keyNames[out_KeyNames.Length] = 'Click';
	out_keyNames[out_KeyNames.Length] = 'MouseMoveX';
	out_keyNames[out_KeyNames.Length] = 'MouseMoveY';
}

/**
 * @Returns the mouse position in widget space
 */
function Vector GetMousePosition()
{
	local int x,y;
	local vector2D MousePos;
	local vector AdjustedMousePos;
	class'UIRoot'.static.GetCursorPosition( X, Y );
	MousePos.X = X;
	MousePos.Y = Y;
	AdjustedMousePos = PixelToCanvas(MousePos);
	AdjustedMousePos.X -= GetPosition(UIFACE_Left,EVALPOS_PixelViewport);
	AdjustedMousePos.Y -= GetPosition(UIFACE_Top, EVALPOS_PixelViewport);
	return AdjustedMousePos;
}

function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	local bool bHandled;
	local bool bIsMouseAction;

	// We'll figure out whether we're handled or not as we go.  Also, we'll figure out if we're a mouse action, too!
	bHandled = true;
	bIsMouseAction = false;


	if (EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat || EventParms.EventType == IE_DoubleClick)
	{
		if(bHorizontalList)
		{
			if ( EventParms.InputAliasName == 'SelectionLeft' )
			{
				SelectItem(Selection - 1);
				PlayUISound('ListUp');
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionRight' )
			{
				SelectItem(Selection + 1);
				PlayUISound('ListDown');
				bHandled = true;
			}
		}
		else
		{
	 		if ( EventParms.InputAliasName == 'SelectionUp' )
	 		{
				bUpArrowPressed = true;
		 		SelectItem(Selection - 1);
		 		PlayUISound('ListUp');
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionDown' )
			{
				bDownArrowPressed = true;
				SelectItem(Selection + 1);
				PlayUISound('ListDown');
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionPgUp' )
			{
				bUpArrowPressed = true;
				PgUp();
				PlayUISound('ListUp');
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionPgDn' )
			{
				bDownArrowPressed = true;
				PgDn();
				PlayUISound('ListDown');
				bHandled = true;
			}
		}


		if ( EventParms.InputAliasName == 'SelectionHome' )
		{
			SelectItem(0);
			PlayUISound('ListUp');
			bHandled = true;
		}
		else if ( EventParms.InputAliasName == 'SelectionEnd' )
		{
			SelectItem(List.Length-1);
			PlayUISound('ListDown');
			bHandled = true;
		}
		else if ( EventParms.InputAliasName == 'Click' )
		{
			bIsMouseAction = true;
			if(SelectUnderCursor())
			{
				if ( bHotTracking ? (EventParms.EventType == IE_DoubleClick) : (EventParms.EventType == IE_Pressed) )
				{
					PlayUISound('ListSubmit');
					ItemChosen(EventParms.PlayerIndex);
				}

				bHandled = true;
			}
		}

	}
	else if ( EventParms.EventType == IE_Released )
	{
		if(bHorizontalList==false)
		{
			if ( EventParms.InputAliasName == 'SelectionUp' )
			{
				bUpArrowPressed = false;
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionDown' )
			{
				bDownArrowPressed = false;
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionPgUp' )
			{
				bUpArrowPressed = false;
				bHandled = true;
			}
			else if ( EventParms.InputAliasName == 'SelectionPgDn' )
			{
				bDownArrowPressed = false;
				bHandled = true;
			}
		}

		if(EventParms.InputAliasName == 'Click')
		{
			bIsMouseAction = true;
			SetFocus(none);

			if(bDragging)
			{
				bDragging = false;
				bHandled = true;
			}
			else
			{
				if(bHotTracking && MouseInBounds() && SelectUnderCursor())
				{
					PlayUISound('ListSubmit');
					ItemChosen(EventParms.PlayerIndex);
					bHandled = true;
				}
			}
		}
		else if ( EventParms.InputAliasName == 'Select' )
		{
			PlayUISound('ListSubmit');
			ItemChosen(EventParms.PlayerIndex);
			bHandled = true;
		}
	}


	if( bHandled && !bIsMouseAction )
	{
		// Turn off mouse navigation
		bIsUsingMouseNavigation = false;
	}


	return bHandled;
}

function ItemChosen(int PlayerIndex)
{
	// Lock in on the currently selected item.  The bar may not be entirely centered on it yet!
	RefreshBarPosition();
	SetItemSelectionIndex( Selection );

	OnItemChosen(self, Selection,PlayerIndex);
}

function bool MouseInBounds()
{
	local Vector MousePos;
	local float w,h;

	MousePos = GetMousePosition();

    w = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);
    h = GetBounds(UIORIENT_Vertical, EVALPOS_PixelViewport);

	return ( MousePos.X >=0 && MousePos.X < w && MousePos.Y >=0 && MousePos.Y < h );
}



/**
 * Returns true if the mouse cursor is currently over the menu
 *
 * @return True if the mouse cursor is over the menu
 */
function bool IsMouseOverMenu()
{
	local Vector MousePos;
	local float MinListHeight;

	MousePos = GetMousePosition();

	// Compute the maximum height of the list.  We'll use this to figure out of the mouse is over the list
	MinListHeight = ComputeListHeightWithSelection( true );  // Compute maximum height?

	return( MouseInBounds() && MousePos.Y > 0.0 && MousePos.Y < MinListHeight );
}



/**
 * Updates whether or not the mouse is currently over the menu and runs the appropriate callback if needed
 */
function UpdateMouseOverMenu()
{
	local bool bIsMouseOverMenuNow;

	// Update whether the mouse cursor is over the menu
	bIsMouseOverMenuNow = IsMouseOverMenu();
	if( bIsMouseOverMenuNow != bIsMouseOverMenu )
	{
		// Mouse rollover state has changed for the menu
		bIsMouseOverMenu = bIsMouseOverMenuNow;

		// Run rollover event
		OnMouseOverMenu( bIsMouseOverMenu );
	}


	// Also update the currently selected menu item based on what's under the cursor
	if ( bDragging || bHotTracking )
	{
		if ( MouseInBounds() )
		{
			SelectUnderCursor();

			// Force bar position to mouse position if we are hot tracking.
			if(bHotTracking)
			{
				SetBarPositionUsingMouseY();
			}
		}
	}
}



/**
 * Enable hottracking if we are dragging
 */
function bool ProcessInputAxis( const out SubscribedInputEventParameters EventParms )
{
	if ( EventParms.InputKeyName=='MouseX' || EventParms.InputKeyName=='MouseY' )
	{
		// Turn on mouse navigation
		bIsUsingMouseNavigation = true;

		// Update whether the mouse cursor is over the menu
		UpdateMouseOverMenu();

		return true;
	}

	return false;
}

/**
 * All are in pixels
 *
 * @Param X1		Left
 * @Param Y1		Top
 * @Param X2		Right
 * @Param Y2		Bottom
 *
 * @Returns true if the mouse is within the bounds given
 */
function bool CursorCheck(float X1, float Y1, float X2, float Y2)
{
	local vector MousePos;;

	MousePos = GetMousePosition();

	return ( (MousePos.X >= X1 && MousePos.X <= X2) && (MousePos.Y >= Y1 && MousePos.Y <= Y2) );
}



/**
 * Select whichever widget happens to be under the cursor
 *
 * @return	Returns TRUE if we selected something, FALSE otherwise.
 */
function bool SelectUnderCursor()
{
	local int w;
	local vector AdjustedMousePos;
	local int CurItemIndex;
	local float CurY;
	local float CurItemScale;
	local float CurItemHeight;
	local float IgnoredTransitionAlpha;
	local bool bResult;

	bResult = false;
	AdjustedMousePos = GetMousePosition();

	w = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);

	if ( (CursorCheck(UpArrowBounds[0],UpArrowBounds[1],UpArrowBounds[2],UpArrowBounds[3])) ||
		 (CursorCheck(DownArrowBounds[0],DownArrowBounds[1],DownArrowBounds[2],DownArrowBounds[3])) )
	{
		bDragging = true;
		bResult = true;
	}
	else if( AdjustedMousePos.X >= 0 && AdjustedMousePos.X < w)
	{
		CurY = 0.0f;

		// For each item in the list
		for( CurItemIndex = 0; CurItemIndex < List.length; ++CurItemIndex )
		{
			// Ignore items that are not in view
			if( List[ CurItemIndex ].bWasRendered )
			{
				// Grab the "bubbled" scale of the current element
				CurItemScale = GetItemScale( CurItemIndex, SelectionPos, IgnoredTransitionAlpha );

				// Compute the item's height
				CurItemHeight = GetItemHeightInPixels( CurItemScale );

				// Bounds test
				if( AdjustedMousePos.Y >= CurY && AdjustedMousePos.Y < CurY + CurItemHeight )
				{
					// Found it!
					SelectItem( CurItemIndex );
					bResult = true;
					break;
				}

				// Now compute the actual height in pixels of this element and increment our total!
				CurY += CurItemHeight;
			}
		}
	}

	return bResult;
}




/**
 * Move up 10 items
 */
function PgUp()
{
	local int NewSelection;
	NewSelection = Clamp(Selection - 10, 0, List.Length-1);
	SelectItem(NewSelection);
}

/**
 * Move down 10 items
 */
function PgDn()
{
	local int NewSelection;
	NewSelection = Clamp(Selection + 10, 0, List.Length-1);
	SelectItem(NewSelection);
}


/*	======================================================================
		List Management
	====================================================================== */


/**
 * Imports a string list and fills the array
 *
 * @Param StringList 	The Stringlist to import
 */
 event ImportStringList(array<string> StringList)
{
	local int i;
	for (i=0;i<StringList.Length;i++)
	{
		AddItem(StringList[i]);
	}
}


/**
 * Attempt to resolve markup to it's string value
 *
 * @Returns the resolve text or the original text if unresolable
 */
function string ResolveText(string Markup)
{
	local string s;
	if ( class'UIRoot'.static.GetDataStoreStringValue(Markup, S) )
	{
		return s;
	}
	return Markup;
}

/**
 * Adds an item to the list
 *
 * @Param Text		String caption of what to add
 * @Param Tag		A generic tag that can be assoicated with this list
 *
 * @ToDo: Add support for resolving markup on assignment.
 */
event AddItem(string Text, optional int Tag=-1)
{
	local int Index;
	Index = List.Length;
	List.Length = Index+1;
	List[Index].Text = ResolveText(Text);
	List[Index].Tag = Tag;
	List[Index].CurHeightMultiplier = 1.0;

	bInvalidated = true;

	// Select the first item

	if (List.Length == 1)
	{
		SelectItem(Index);
	}
	else
	{
		SelectItem(Selection);
	}

}

/**
 * Inserts a string somewhere in the stack
 *
 * @Param Text		String caption of what to add
 * @Param Tag		A generic tag that can be assoicated with this list
 *
 * @ToDo: Add support for resolving markup on assignment.
 */
event InsertItem(int Index, string Text, optional int Tag=-1)
{
	List.Insert(Index,1);
	List.Length = Index+1;
	List[Index].Text = ResolveText(Text);
	List[Index].Tag = Tag;
	List[Index].CurHeightMultiplier = 1.0;

	bInvalidated = true;

	// Select the first item

	if (List.Length == 1)
	{
		SelectItem(Index);
	}
	else
	{
		SelectItem(Selection);
	}


}

/**
 * Removes an item from the list
 */
event RemoveItem(int IndexToRemove)
{
	List.Remove(IndexToRemove,1);
	bInvalidated = true;

}


/**
 * Attempts to find a string then remove it from the list
 *
 * @Param TextToRemove		The String to remove
 */
 event RemoveString(string TextToRemove)
 {
 	local int i;
 	i = Find(TextToRemove);
 	if (i > INDEX_None)
 	{
 		RemoveItem(i);
 	}

	bInvalidated = true;

}

/**
 * Empties the list
 */
event Empty()
{
	Selection = -1;
	Top = -1;
	List.Remove(0,List.Length);
	bInvalidated = true;

}

/**
 * @Returns the list as an array of strings
 */
function ToStrings(out array<string> StringList, optional bool bAppend)
{
	local int i;

	if (!bAppend)
	{
		StringList.Remove(0,StringList.Length);
	}

	for (i=0;i<List.Length;i++)
	{
		StringList[i] = List[i].Text;
	}
}


/**
 * Selects an item
 */

event SelectItem(int NewSelection)
{
	if(NewSelection != Selection)
	{
		// wrap list ends if we arent dragging the mouse.
		if(bWrapList && !bDragging)
		{
			if(NewSelection==List.Length)
			{
				NewSelection = 0;
			}
			else if(NewSelection==-1)
			{
				NewSelection=List.length-1;
			}
		}

		NewSelection = Clamp(NewSelection,0,List.Length-1);

		OldSelection = Selection;
		Selection = NewSelection;

		StartSelectionTime = UDKUIScene( GetScene() ).GetWorldInfo().RealTimeSeconds;
		SelectionAlpha = 0.0f;
		bTransitioning = true;
		RefreshBarPosition();

		WindowTopTransitionTime = FClamp(WindowTopTransitionTime+0.15, 0.0, TransitionTime);

		if (Selection != OldSelection)
		{
			OnSelectionChange(self, Selection);
		}
	}
}

/*	======================================================================
		Rendering / Sizing - All of these function assume Canvas is valid.
	====================================================================== */



/** Refreshes the selection bar's position.  Should be used when selection has changed or screen res has changed. */
event RefreshBarPosition()
{
	OldBarPosition = CalculateSelectionBGPosition(OldSelection);
	BarPosition = CalculateSelectionBGPosition(Selection);
}


/**
 * Computes the maximum possible height of the list, taking into account 'bubble scaling'
 *
 * @param bMaximum True to compute the maximum height of the list, or false for the minimum
 *
 * @return Returns the maximum height of the list in pixels
 */
function float ComputeListHeightWithSelection( bool bMaximum )
{
	local float MaxHeight;
	local int CurItemIndex;
	local int FocusedItemIndex;
	local float IgnoredTransitionAlpha;
	local float CurItemScale;

	MaxHeight = 0.0f;

	// The maximum height is the height of the bubble-scaled list when the selection focus in the middle of the
	// list somewhere, since every item within the bubble's radius will be scaled.  For minimum height, the
	// selection bar is at the top of the list
	FocusedItemIndex = bMaximum ? ( List.length / 2 ) : 0;

	// For each item in the list
	for( CurItemIndex = 0; CurItemIndex < List.length; ++CurItemIndex )
	{
		// Grab the "bubbled" scale of the current element, pretending that the center item is selected
		CurItemScale = GetItemScale( CurItemIndex, FocusedItemIndex, IgnoredTransitionAlpha );

		// Now compute the actual height in pixels of this element and increment our total!
		MaxHeight += GetItemHeightInPixels( CurItemScale );
	}

	return MaxHeight;
}



/**
* Sets the bar position using the current mouse position.
*/
function SetBarPositionUsingMouseY()
{
	local Vector MousePos;
	local float HalfBarHeight;
	local float MinListHeight;
	local float NewSelectionPos;
	local float MaxBarPos;

	MousePos = GetMousePosition();

	// Cache half the height of the selection bar
	HalfBarHeight = GetSelectedCellHeight() * 0.5f;

	// Compute the maximum height of the list.  We'll use this to figure out of the mouse is over the list
	MinListHeight = ComputeListHeightWithSelection( false );  // Compute maximum height?
	MinListHeight += 0.5f;	// Half pixel offset to account for float accumulation error

	if( MousePos.Y > 0.0 && MousePos.Y < MinListHeight )
	{
		// Kill any transition animation in progress since we're going to move the selection bar instantly!
		bTransitioning = false;

		// Note that bar positions are offset by half bar height because we want the center of the bar to be at
		// the mouse Y position.

		// Compute the maximum position for the bar.  We don't want the bar to extend beyond the bottom item
		// in the list.
		MaxBarPos = MinListHeight - GetSelectedCellHeight();

		// Set the position of the selection bar
		BarPosition = Clamp( MousePos.Y - HalfBarHeight, 0.0, MaxBarPos );

		// NOTE: Passing in a value between 0 and N-1
		NewSelectionPos = FClamp( BarPosition / GetDefaultCellHeight() - 0.5f, 0, List.length - 1.0f );
		SetItemSelectionIndex( NewSelectionPos );
	}
	else
	{
		// Mouse isn't over the menu?
	}

}



/**
 * Called when the mouse cursor moves onto or off of the menu
 *
 * @param bIsOverMenu True if mouse cursor is over the menu, otherwise false
 */
function OnMouseOverMenu( bool bIsOverMenu )
{
	local float TargetBarPosition;

	if( bIsOverMenu )
	{
		// We're over the menu.  Big deal!
	}
	else
	{
		// Mouse rolled off the menu, so let's make sure we don't leave the visuals in a weird state by
		// leaving the selection bar in between menu items.
		if( !bTransitioning )
		{
			// Don't bother transitioning if we're already practically on top of the target
			TargetBarPosition = CalculateSelectionBGPosition( Selection );
			if( Abs( TargetBarPosition - BarPosition ) > 1.0 )
			{
				// Smoothly interpolate to the currently selected item
				OldBarPosition = BarPosition;
				OldSelection = FClamp( OldBarPosition / GetDefaultCellHeight() - 0.5f, 0, List.length - 1.0f );
				BarPosition = TargetBarPosition;
				StartSelectionTime = UDKUIScene( GetScene() ).GetWorldInfo().RealTimeSeconds;
				SelectionAlpha = 0.0f;
				bTransitioning = true;
			}
		}
	}
}



/**
 * Sets the selection index for all items.  This is used to calculate item scaling as the bar moves around.
 *
 * @param SelectionIndex	New selection index for the items, the item's distance from this value in the List array determines how much they scale.
 */
event SetItemSelectionIndex(float SelectionIndex)
{
	local int ItemIdx;
	local float TransitionAlpha;

	// Store new selection position
	SelectionPos = SelectionIndex;

	for( ItemIdx = 0; ItemIdx < List.length; ItemIdx++ )
	{
		// How much should we scale this menu item's text?
		List[ItemIdx].CurHeightMultiplier = GetItemScale( ItemIdx, SelectionPos, TransitionAlpha );

		// Store the opacity for transition animations
		List[ItemIdx].TransitionAlpha = TransitionAlpha;
	}
}


/**
 * SizeList is called directly before rendering anything in the list.
 */
event SizeList()
{
	local int i;
	local Vector2D ViewportSize;
	local float SelectedPosition;
	local float SelectedSize;
	local float Size;

	/** Calculate the resolution scaling factor */

	GetViewportSize(ViewportSize);

	ResScaling.Y = ViewportSize.Y / 768;
	ResScaling.X = ResScaling.Y;	// Scale proportionally

	ListHeightInPixel = 0;
	for (i=0;i<List.Length;i++)
	{

		Size = GetDefaultCellHeight() * List[i].CurHeightMultiplier;

		if (i == Selection )
		{
			SelectedPosition = ListHeightInPixel;
			SelectedSize = Size;
		}

		ListHeightInPixel += Size;
	}

	WindowHeight = GetBounds(UIORIENT_Vertical, EVALPOS_PixelViewport);

	WindowHeight = FMin(WindowHeight, ListHeightInPixel);

	// Try and position the selected item in the center of the list.

	if ( bDragging )
	{
		if (SelectedPosition < WindowTop)
		{
			TargetWindowTop = SelectedPosition;
		}
		else if (SelectedPosition > WindowTop + WindowHeight - (DefaultCellHeight * SelectionCellHeightMultiplier) )
		{
			TargetWindowTop = SelectedPosition - WindowHeight + (DefaultCellHeight * SelectionCellHeightMultiplier);
		}
	}
	else
	{
		TargetWindowTop = SelectedPosition + (SelectedSize * 0.5) - (WindowHeight * 0.5);
	}

	TargetWindowTop = FClamp(TargetWindowTop, 0, ListHeightInPixel - WindowHeight);
	if (TargetWindowTop != WindowTop && WindowTopTransitionTime <= 0.0)
	{
		WindowTopTransitionTime = 0.15;
	}
}

/**
 * Render the list.  At this point each cell should be sized, etc.
 */
event DrawPanel()
{
	local int DrawIndex;
	local float XPos, YPos, CellHeight;
	local float TimeSeconds,DeltaTime;
	local float FinalSelectionBarPos;
	local vector MousePos;
	local WorldInfo WI;

	// If the list is empty, exit right away.

	if ( List.Length == 0 )
	{
		return;
	}


	// Update whether the mouse cursor is over the menu.  We need to do this frequently because we currently
	// have no way of getting updates about the mouse cursor when it's *not* over the UI object; this means
	// there's no event-based way to be notified about a mouse *leaving* the menu
	if( bIsUsingMouseNavigation )
	{
		UpdateMouseOverMenu();
	}


	WI = UDKUIScene( GetScene() ).GetWorldInfo();
	TimeSeconds = WI.RealTimeSeconds * WI.TimeDilation;
	DeltaTime = TimeSeconds - LastRenderTime;
	LastRenderTime = TimeSeconds;

	if (bDragging )
	{
		if (!MouseInBounds() && LastMouseUpdate <= 0.0)
		{
			MousePos = GetMousePosition();
			if (MousePos.Y < 0)
			{
				SelectItem(Selection-1);
			}
			else
			{
				SelectItem(Selection+1);
			}
			LastMouseUpdate = 0.15;
		}
		else
		{
			LastMouseUpdate -= Deltatime;
		}
	}

	if (TargetWindowTop != WindowTop)
	{
		if ( WindowTopTransitionTime > 0.0 )
		{
			WindowTop += (TargetWindowTop - WindowTop) * (DeltaTime / WindowTopTransitionTime);
			WindowTopTransitionTime -= DeltaTime;
		}

		if ( WindowTopTransitionTime <= 0.0 )
		{
			WindowTop = TargetWindowTop;
			WindowTopTransitionTime = 0;
		}
	}
	else
	{
		WindowTopTransitionTime = 0.0f;
	}



	UpdateAnimation(DeltaTime * UDKUIScene( GetScene() ).GetWorldInfo().TimeDilation);


	// FIXME: Big optimization if we don't have to recalc the
	// list size each frame.  We should only have to do this the resoltuion changes,
	// if we have added items to the list, or if the list is moving.  But for now this is
	// fine.

	bInvalidated = true;

	Canvas.Font = TextFont;

	SizeList();

	XPos = DefaultCellHeight * SelectionCellHeightMultiplier * ScrollWidthRatio * ResScaling.X;
	YPos = 0 - WindowTop;	// Figure out where to start rendering

	// Draw selection bar first
	if( bTransitioning )
	{
		FinalSelectionBarPos = YPos + SelectionAlpha * (BarPosition-OldBarPosition) + OldBarPosition;
	}
	else
	{
		FinalSelectionBarPos = YPos + BarPosition;
	}

	if ( !OnDrawSelectionBar( self, FinalSelectionBarPos ) )
	{
		DrawSelectionBG( FinalSelectionBarPos );
	}


	// Draw all items
	DrawIndex = 0;
	for (DrawIndex = 0; DrawIndex < List.Length; DrawIndex++)
	{
		// Determine if we are past the end of the visible portion of the list..

		CellHeight = GetDefaultCellHeight() * List[DrawIndex].CurHeightMultiplier;


		// Clear the rendered flag

    	List[DrawIndex].bWasRendered = false;

		// Render if we should.

		if ( YPos < WindowHeight )	// Check for the bottom edge clip
		{
			// Ok, we haven't gone past the window, so see if we are before it

			if (YPos + CellHeight > 0)
			{
				// Allow a delegate first crack at rendering, otherwise use the default
				// string rendered.

				if ( !OnDrawItem(self, DrawIndex, XPos, YPos) )
				{
					DrawItem(DrawIndex, XPos, YPos);
			    	List[DrawIndex].bWasRendered = true;
				}
			}
		}
		YPos += CellHeight;
	}

}


/**
 * Calculates the scaling of the item as a value between 1.0f and SelectionCellHeightMultiplier given the item's index and the current selection position.
 *
 * @param ItemIdx			Index of the item to calculate scale for.
 * @param SelectionPos		Current position of the selection bar.
 * @param Alpha				Out variable, between 0.0 - 1.0 of what the widget's transition alpha should be.
 *
 * @return Returns an item's scale height given the current position of the selection bar.
 */
event float GetItemScale(int ItemIdx, float SelectionPosValue, optional out float Alpha)
{
	local float Dist;

	// We'll only enable the bubble effect if BubbleRadius is set
	Dist = 1.0f;
	if( BubbleRadius > 0 )
	{
		Dist = FClamp(ItemIdx - SelectionPosValue, -BubbleRadius, BubbleRadius);
		Dist /= BubbleRadius;
		Dist = 1.0f - Abs(Dist);
		Alpha = Dist;
		Dist = Dist * (SelectionCellHeightMultiplier-1.0f) + 1.0f;
	}

	return Dist;
}

/** @return Converts an item's scale height to pixels. */
function float GetItemHeightInPixels(float ItemScale)
{
	return ItemScale * GetDefaultCellHeight();
}

/**
 * Calculates where the selection bar should be given a selected item index.
 *
 * @param SelectedIdx	Item to calculate selection position for.
 *
 * @return Returns the position of the selection bar in pixels.
 */
function float CalculateSelectionBGPosition(int SelectedIdx)
{
	local float YPos;
	local int ItemIdx;
	local float ItemScalingFactor;
	local float TransitionAlpha;

	YPos = 0;

	for(ItemIdx=0; ItemIdx<SelectedIdx; ItemIdx++)
	{
		ItemScalingFactor = GetItemScale(ItemIdx, float(SelectedIdx),TransitionAlpha);
		YPos += GetItemHeightInPixels( ItemScalingFactor );
	}

	return YPos;
}

/**
 * This delegate allows anyone to alter the drawing code of the list.
 *
 * @Returns true to skip the default drawing
 */
delegate bool OnDrawItem(UDKSimpleList SimpleList, int ItemIndex, float XPos, out float YPos)
{
	return false;
}

delegate bool OnDrawSelectionBar( UDKSimpleList SimpleList, float YPos )
{
	return false;
}

delegate bool OnPostDrawSelectionBar(UDKSimpleList SimpleList, float YPos, float Width, float Height)
{
	return false;
}


/**
 * This delegate is called when an item in the list is chosen.
 */
delegate OnItemChosen(UDKSimpleList SourceList, int SelectedIndex, int PlayerIndex);

/**
 * This delegate is called when the selection index changes
 */
delegate OnSelectionChange(UDKSimpleList SourceList, int NewSelectedIndex);


/**
 * Draws an item to the screen.  NOTE this function can assume that the item
 * being drawn is not the selected item
 */

function DrawItem(int ItemIndex, float XPos, out float YPos)
{
	local float H, PaddingHeight, PaddedYpos;
	local vector2d DrawScale;
	local float PaddingAmount;
	local float PaddingOffset;
	local float ShadowOffset;

	DrawScale = ResScaling;
	DrawScale.X *= List[ItemIndex].CurHeightMultiplier;
	DrawScale.Y *= List[ItemIndex].CurHeightMultiplier;

	// Figure out the total height of this cell
	H = DefaultCellHeight * DrawScale.Y;

	if ( List[ItemIndex].Text != "" )
	{

		// Handle text padding
		PaddingAmount = List[ItemIndex].TransitionAlpha * SelectedTextPadding.Y + (1.0f - List[ItemIndex].TransitionAlpha) * NormalTextPadding.Y;
		PaddingOffset = List[ItemIndex].TransitionAlpha * SelectedTextOffset.Y + (1.0f - List[ItemIndex].TransitionAlpha) * NormalTextOffset.Y;
		PaddingHeight = PaddingAmount * H;
		PaddedYpos = YPos + PaddingHeight + PaddingOffset*H;

		// Draw text shadow
		ShadowOffset = ShadowDist*DrawScale.Y;
		Canvas.DrawColor = ShadowColor;
		DrawStringToFit(List[ItemIndex].Text,XPos+ShadowOffset, PaddedYpos+ShadowOffset, PaddedYpos+(H-PaddingHeight*2)+ShadowOffset);


		// On PC when we're using the mouse we'll snap the color for selected item, so the user knows exactly which
		// menu item will be selected when clicking the mouse
		if( (!IsConsole() && bIsUsingMouseNavigation) || BubbleRadius == 0 )
		{
			Canvas.DrawColor = (ItemIndex==Selection) ? SelectedColor : NormalColor;
		}
		else
		{
			// Take power of the alpha to make the falloff a bit stronger.
			Canvas.DrawColor = LinearColorToColor( InterpLinearColor( ColorToLinearColor( SelectedColor ), ColorToLinearColor( NormalColor ), List[ItemIndex].TransitionAlpha ** 5 ) );
		}

		DrawStringToFit(List[ItemIndex].Text,XPos, PaddedYpos, PaddedYpos+(H-PaddingHeight*2));

	}
}


/** @return Returns the height of an menu item (without any 'bubble scaling' applied) */
function float GetDefaultCellHeight()
{
	return DefaultCellHeight * ResScaling.Y;
}


/** @return Returns the height of a selected menu item in pixels. */
function float GetSelectedCellHeight()
{
	return GetDefaultCellHeight() * SelectionCellHeightMultiplier;
}


/**
 * Draw the selection Bar
 */
function DrawSelectionBG(float YPos)
{
	local float Width,Height;
	local float AWidth, AHeight, AYPos;
	local bool bOverArrow;

	Height = GetSelectedCellHeight();
	Width = Height * ScrollWidthRatio;

	// Draw the Bar

	Canvas.SetPos(0,YPos);
	Canvas.DrawTileStretched(Selectionimage, Width,Height, SelectionImageIconBGU,SelectionImageIconBGV,SelectionImageIconBGUL,SelectionImageIconBGVL, ColorToLinearColor(SelectionBarColor));

	Canvas.SetPos(Width,YPos);
	Canvas.DrawTileStretched(Selectionimage, Canvas.ClipX-Width,Height, SelectionImageBarU,SelectionImageBarV,SelectionImageBarUL,SelectionImageBarVL, ColorToLinearColor(SelectionBarColor));

	// ------------ Draw the up/Down Arrows

	// Calculate the sizes
	AHeight = Height * 0.8;
	AWidth = AHeight * 0.5;
	AYPos = YPos - AHeight - (Height * 0.1);

	if(bHideScrollArrows==false)
	{
		// Draw The up button

		// Cache the bounds for mouse lookup later

		UpArrowBounds[0] = Width*0.5f - (AWidth * 0.5);
		UpArrowBounds[2] = UpArrowBounds[0] + AWidth;
		UpArrowBounds[1] = AYPos;
		UpArrowBounds[3] = AYPos + AHeight;

		bOverArrow = CursorCheck(UpArrowBounds[0],UpArrowBounds[1],UpArrowBounds[2],UpArrowBounds[3]);
		ArrowColor.A = (1.0f-List[0].TransitionAlpha)*255; // Fade out upper arrow near top of list
		DrawSpecial(UpArrowBounds[0],UpArrowBounds[1], AWidth, AHeight,77,198,63,126,ArrowColor,bOverArrow, bUpArrowPressed);

		// Draw The down button

		// Cache the bounds for mouse lookup later

		AYPos = YPos + Height + (Height * 0.1);

		DownArrowBounds[0] = Width*0.5f - (AWidth * 0.5);
		DownArrowBounds[2] = DownArrowBounds[0] + AWidth;
		DownArrowBounds[1] = AYPos;
		DownArrowBounds[3] = AYPos + AHeight;

		bOverArrow = CursorCheck(DownArrowBounds[0],DownArrowBounds[1],DownArrowBounds[2],DownArrowBounds[3]);
		ArrowColor.A = (1.0f-List[List.length-1].TransitionAlpha)*255; // Fade out lower arrow near bottom of list
		DrawSpecial(DownArrowBounds[0],DownArrowBounds[1], AWidth, AHeight,77,358,63,126,ArrowColor,bOverArrow, bDownArrowPressed);
	}

	OnPostDrawSelectionBar(self, YPos, Width, Height);
}

/** @return Linearly interpolates between 2 linear colors. */
function LinearColor InterpLinearColor(LinearColor A, LinearColor B, float Alpha)
{
	local LinearColor Result;
	local float InvAlpha;

	InvAlpha = 1.0 - Alpha;

	Result.A = A.A*Alpha + InvAlpha*B.A;
	Result.R = A.R*Alpha + InvAlpha*B.R;
	Result.G = A.G*Alpha + InvAlpha*B.G;
	Result.B = A.B*Alpha + InvAlpha*B.B;

	return Result;
}

/** @return Creates a color from a linear color by clamping values to 0-255. */
function color LinearColorToColor(LinearColor Src)
{
	local color Result;

	Result.A = int(FClamp(Src.A, 0.0, 1.0)*255);
	Result.R = int(FClamp(Src.R, 0.0, 1.0)*255);
	Result.G = int(FClamp(Src.G, 0.0, 1.0)*255);
	Result.B = int(FClamp(Src.B, 0.0, 1.0)*255);

	return Result;
}

function DrawSpecial(float x, float y, float w, float h, float u, float v, float ul, float vl, color DrawColor, bool bOver, bool bPressed)
{
	if (bDragging || bOver || bPressed)
	{
		Canvas.SetDrawColor(255,0,0,DrawColor.A);
		Canvas.SetPos(x-2,y-2);
		Canvas.DrawTile(ArrowImage, w+4, h+4, u,v,ul,vl);
	}

	if ( !bDragging && !bPressed )
	{
		Canvas.SetPos(x,y);
		Canvas.DrawColor = DrawColor;
		Canvas.DrawTile(ArrowImage, w, h, u, v, ul, vl);
	}
}


function DrawStringToFit(string StringToDraw, float XPos, float Y1, float Y2)
{
	local float XL, YL;
	local float H;
	local float TextScale;
	local float OldClipX;
	local FontRenderInfo RenderInfo;

	OldClipX = Canvas.ClipX;
	Canvas.ClipX = 10000;	// Make sure that ClipX doesnt affect the string size.
	Canvas.StrLen(StringToDraw,XL,YL);
	Canvas.ClipX = OldClipX;

	H = Y2-Y1;
	TextScale = H / YL;
	Canvas.SetPos(XPos, Y1 + (H*0.5) - (YL * TextScale * 0.5));
	RenderInfo.bClipText = true;
	Canvas.DrawText(StringToDraw,, TextScale, TextScale, RenderInfo);
}


function string GetText()
{
	if (Selection != INDEX_None)
	{
		return List[Selection].Text;
	}

	return "";
}

function int GetTag()
{
	if (Selection != INDEX_None)
	{
		return List[Selection].Tag;
	}

	return Index_None;
}

defaultproperties
{
	// States
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	bHideScrollArrows=true
	DefaultCellHeight=23
	AboveBelowCellHeightMultiplier=1.5
	SelectionCellHeightMultiplier=3.25

	NormalTextPadding=(X=0.0,Y=0.0)
	NormalTextOffset=(X=0.0,Y=0.0)
	SelectedTextPadding=(X=0.0,Y=0.2)
	SelectedTextOffset=(X=0.0,Y=0.05)

    TransitionTime=0
	BubbleRadius=2

	/** Selection Image UVs. */
	SelectionImageIconBGU=260;
	SelectionImageIconBGV=0;
	SelectionImageIconBGUL=80;
	SelectionImageIconBGVL=76;

	/** Selection bar image UVs. */
	SelectionImageBarU=340;
	SelectionImageBarV=0;
	SelectionImageBarUL=361;
	SelectionImageBarVL=76;

	NormalColor=(R=192,G=64,B=64,A=255)
	AboveBelowColor=(R=128,G=32,B=32,A=255)
	SelectedColor=(R=255,G=255,B=255,A=255)
	SelectionBarColor=(R=64,G=0,B=1,A=225)
	ArrowColor=(R=128,G=0,B=1,A=255)
	ShadowColor=(R=0,G=0,B=0,A=255)
	ShadowDist=1.0f
	Selection=-1
	Top=0
	ScrollWidthRatio=1.29347;

	bWrapList=true
}
