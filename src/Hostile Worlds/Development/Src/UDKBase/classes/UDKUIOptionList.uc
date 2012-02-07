/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Options tab page, autocreates a set of options widgets using the datasource provided.
 */

class UDKUIOptionList extends UDKDrawPanel
	placeable
	native
	DontAutoCollapseCategories(Data)
	implements(UIDataStoreSubscriber);

cpptext
{
	/* === UUIObject interface === */
	/** Updates the positioning of the background prefab. */
	virtual void Tick_Widget(FLOAT DeltaTime);

	/**
	 * Repositions all option widgets.
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

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
	virtual void GetSupportedUIActionKeyNames(TArray<FName> &out_KeyNames );

	/**
	 * Callback that happens the first time the scene is rendered, any widget positioning initialization should be done here.
	 *
	 * By default this function recursively calls itself on all of its children.
	 */
	virtual void PreInitialSceneUpdate();

	/**
	* Routes rendering calls to children of this screen object.
	*
	* @param	Canvas	the canvas to use for rendering
	* @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	*/
	virtual void Render_Children( FCanvas* Canvas, EUIPostProcessGroup UIPostProcessGroup );
}

/** Scrollbar to let PC users scroll up and down the list freely. */
var	transient UIScrollbar					VerticalScrollbar;

/** Info about an option we have generated. */
struct native GeneratedObjectInfo
{
	var name			OptionProviderName;
	var UIObject		LabelObj;
	var UIObject		OptionObj;
	var UIDataProvider	OptionProvider;
	var float OptionY;
	var float OptionHeight;
	var float OptionX;
	var float OptionWidth;
};

/** Current option index. */
var transient int CurrentIndex;

/** Previously selected option index. */
var transient int PreviousIndex;

/** Start time for animating option switches. */
var transient float StartMovementTime;

/** Whether or not we are currently animating the background prefab. */
var transient bool	bAnimatingBGPrefab;

/** List of auto-generated objects, anything in this array will be removed from the children's array before presave. */
var transient array<GeneratedObjectInfo>	GeneratedObjects;

/** The data store that this list is bound to */
var(Data)						UIDataStoreBinding		DataSource;

/** the list element provider referenced by DataSource */
var	const	transient			UIListElementProvider	DataProvider;

/** Background prefab for the currently selected item. */
var() UIPrefab	BGPrefab;

/** Instance of the background prefab. */
var transient					UIPrefabInstance BGPrefabInstance;

/** Maximum number of visible items. */
var transient					int	 MaxVisibleItems;

/** Flag to let the optionlist know that it should regenerate its options on next tick. */
var transient					bool bRegenOptions;

/** Properties for the scroll arrows. */
var float ScrollArrowWidth;
var color ArrowColor;
var texture2D SelectionImage;
var texture2D ArrowImage;

/** Current state of the arrows. */
var transient float DragDeadZone;
var transient bool bDragging;
var transient float SelectionSpeed; /** Speed to increase or decrease the currently selected element when dragging, in seconds. */
var transient float LastDragSelection; /** Last time we changed the current selection due to dragging. */
var transient vector DragClickPosition;
var transient float UpArrowBounds[4];
var transient float DownArrowBounds[4];
var transient bool bUpArrowPressed;
var transient bool bDownArrowPressed;

/** Classes of widget types to create */
var class<UINumericEditBox> NumericEditBoxClass;
var class<UDKUISlider> SliderClass;
var class<UIEditBox> EditBoxClass;
var class<UICheckBox> CheckBoxClass;
var class<UIComboBox> ComboBoxClass;
var class<UDKUIOptionButton> OptionButtonClass;

/** Delegate called when an option gains focus. */
delegate OnOptionFocused(UIScreenObject InObject, UIDataProvider OptionProvider);

/** Delegate for when the user changes one of the options in this option list. */
delegate OnOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex);

/** Accept button was pressed on the option list. */
delegate OnAcceptOptions(UIScreenObject InObject, int PlayerIndex);

event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'MouseMoveX';
	out_KeyNames[out_KeyNames.Length] = 'MouseMoveY';
	out_KeyNames[out_KeyNames.Length] = 'Click';
	out_KeyNames[out_KeyNames.Length] = 'SelectionUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionDown';
	out_KeyNames[out_KeyNames.Length] = 'SelectionHome';
	out_KeyNames[out_KeyNames.Length] = 'SelectionEnd';
	out_KeyNames[out_KeyNames.Length] = 'SelectionPgUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionPgDn';
	out_KeyNames[out_KeyNames.Length] = 'AcceptOptions';
}

/** Generates widgets for all of the options. */
native function RegenerateOptions();

/** Repositions all of the visible options. */
native function RepositionOptions();

/** Sets the currently selected option index. */
native function SetSelectedOptionIndex(int OptionIdx);

/** Refreshes the value of all of the options by having them pull their options from the datastore again. */
function RefreshAllOptions()
{
	local int OptionIdx;

	for(OptionIdx=0; OptionIdx<GeneratedObjects.length; OptionIdx++)
	{
		UIDataStoreSubscriber(GeneratedObjects[OptionIdx].OptionObj).RefreshSubscriberValue();
	}
}

/** Post initialize, binds callbacks for all of the generated options. */
event PostInitialize()
{
	Super.PostInitialize();

	// Setup handler for input keys
	OnProcessInputKey=ProcessInputKey;
	OnProcessInputAxis=ProcessInputAxis;

	RegenerateOptions();
}

/** Sets up the option bindings. */
event SetupOptionBindings()
{
	local int ObjectIdx;

	// Go through all of the generated object and set the OnValueChanged delegate.
	for(ObjectIdx=0; ObjectIdx < GeneratedObjects.length; ObjectIdx++)
	{
		GeneratedObjects[ObjectIdx].OptionObj.OnValueChanged = OnValueChanged;
		GeneratedObjects[ObjectIdx].OptionObj.NotifyActiveStateChanged = OnOption_NotifyActiveStateChanged;
	}

	// Setup scroll callbacks
	if ( VerticalScrollbar != None )
	{
		VerticalScrollbar.OnScrollActivity = ScrollVertical;
		VerticalScrollbar.OnClickedScrollZone = ClickedScrollZone;
	}
}

/** Initializes combobox widgets. */
native function InitializeComboboxWidgets();

/** Initializes the scrollbar widget for the option list. */
native function InitializeScrollbars();

/**
 * Handler for the vertical scrollbar's OnClickedScrollZone delegate.  Scrolls the list by a full page (MaxVisibleItems).
 *
 * @param	Sender			the scrollbar that was clicked.
 * @param	PositionPerc	a value from 0.0 - 1.0, representing the location of the click within the region between the increment
 *							and decrement buttons.  Values closer to 0.0 means that the user clicked near the decrement button; values closer
 *							to 1.0 are nearer the increment button.
 * @param	PlayerIndex		Player that performed the action that issued the event.
 */
function ClickedScrollZone( UIScrollbar Sender, float PositionPerc, int PlayerIndex )
{
	local int MouseX, MouseY;
	local float MarkerPosition;
	local bool bDecrement;

	local int NewTopItem;

	if ( GetCursorPosition(MouseX, MouseY) )
	{
		// this is the position of the marker's minor side (left or top)
		MarkerPosition = Sender.GetMarkerButtonPosition();

		// determine whether the user clicked in the region above or below the marker button.
		bDecrement = (Sender.ScrollbarOrientation == UIORIENT_Vertical)
			? MouseY < MarkerPosition
			: MouseX < MarkerPosition;

		NewTopItem = bDecrement ? (CurrentIndex - 1) : (CurrentIndex + 1);
		SelectItem(NewTopItem);
	}
}

/**
 * Handler for vertical scrolling activity
 * PositionChange should be a number of nudge values by which the slider was moved
 *
 * @param	Sender			the scrollbar that generated the event.
 * @param	PositionChange	indicates how many items to scroll the list by
 * @param	bPositionMaxed	indicates that the scrollbar's marker has reached its farthest available position,
 *                          unused in this function
 */
function bool ScrollVertical( UIScrollbar Sender, float PositionChange, optional bool bPositionMaxed=false )
{
	local int NewIndex;

	if ( bPositionMaxed )
	{
		NewIndex = Clamp(PositionChange > 0 ? GeneratedObjects.Length - 1 : 0, 0, GeneratedObjects.Length - 1);
	}
	else
	{
		NewIndex = CurrentIndex + Round(PositionChange);
	}

	SelectItem(NewIndex);
	return true;
}

/** @return Returns the object info struct index given a provider namename. */
function int GetObjectInfoIndexFromName(name ProviderName)
{
	local int ObjectIdx;
	local int Result;

	Result = INDEX_NONE;

	// Reoslve the option name
	for(ObjectIdx=0; ObjectIdx < GeneratedObjects.length; ObjectIdx++)
	{
		if(GeneratedObjects[ObjectIdx].OptionProviderName==ProviderName)
		{
			Result = ObjectIdx;
			break;
		}
	}

	return Result;
}

/** @return Returns the object info struct given a sender object. */
function int GetObjectInfoIndexFromObject(UIObject Sender)
{
	local int ObjectIdx;
	local int Result;

	Result = INDEX_NONE;

	// Reoslve the option name
	for(ObjectIdx=0; ObjectIdx < GeneratedObjects.length; ObjectIdx++)
	{
		if(GeneratedObjects[ObjectIdx].OptionObj==Sender)
		{
			Result = ObjectIdx;
			break;
		}
	}

	return Result;
}

/** Callback for all of the options we generated. */
function OnValueChanged( UIObject Sender, int PlayerIndex )
{
	local name OptionProviderName;
	local int ObjectIdx;

	OptionProviderName = '';

	// Reoslve the option name
	ObjectIdx = GetObjectInfoIndexFromObject(Sender);

	if(ObjectIdx != INDEX_NONE)
	{
		OptionProviderName = GeneratedObjects[ObjectIdx].OptionProviderName;
	}

	// Call the option changed delegate
	OnOptionChanged(Sender, OptionProviderName, PlayerIndex);
}

/** Callback for when the object's active state changes. */
function OnOption_NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	local int ObjectIndex;

	ObjectIndex = GetObjectInfoIndexFromObject(UIObject(Sender));

	if(ObjectIndex != INDEX_NONE)
	{
		if(NewlyActiveState.Class == class'UIState_Focused'.default.Class)
		{
			SetSelectedOptionIndex(ObjectIndex);
			OnOptionFocused(Sender, GeneratedObjects[ObjectIndex].OptionProvider);

			// Play a sound cue depending on which way the selection moved.
			if(CurrentIndex != PreviousIndex)
			{
				if(CurrentIndex < PreviousIndex)
				{
					if(CurrentIndex==0 && PreviousIndex==GeneratedObjects.length-1)
					{
						PlayUISound('ListDown');
					}
					else
					{
						PlayUISound('ListUp');
					}
				}
				else
				{
					if(PreviousIndex==0 && CurrentIndex==GeneratedObjects.length-1)
					{
						PlayUISound('ListUp');
					}
					else
					{
						PlayUISound('ListDown');
					}
				}
			}

		}
	}
}

/**
 * Enables / disables an item in the list.  If the item is the currently selected item, selects the next item in the list, if possible.
 *
 * @param	OptionIdx		the index for the option that should be updated
 * @param	bShouldEnable	TRUE to enable the item; FALSE to disable.
 *
 * @return	TRUE if the item's state was successfully changed; FALSE if it couldn't be changed or OptionIdx was invalid.
 */
function bool EnableItem( int PlayerIndex, UIObject ChosenObj, bool bShouldEnable=true )
{
	return EnableItemAtIndex(PlayerIndex, GetObjectInfoIndexFromObject(ChosenObj), bShouldEnable);
}
function bool EnableItemAtIndex( int PlayerIndex, int OptionIdx, bool bShouldEnable=true )
{
	local bool bResult, bStateChangeAllowed;
	local int idx;
	local UIObject ChosenObj;

	if ( OptionIdx >= 0 && OptionIdx < GeneratedObjects.Length )
	{
		ChosenObj = GeneratedObjects[OptionIdx].OptionObj;
		if ( ChosenObj != None )
		{
			bStateChangeAllowed = true;
			if ( !bShouldEnable )
			{
				if ( OptionIdx == CurrentIndex )
				{
					bStateChangeAllowed = false;
					for ( idx = (OptionIdx + 1) % GeneratedObjects.Length; idx != CurrentIndex; idx = (idx + 1) % GeneratedObjects.Length )
					{
						if ( SelectItem(idx, PlayerIndex, false) )
						{
							bStateChangeAllowed = true;
							break;
						}
					}
				}
				else if ( ChosenObj == GetFocusedControl(false, PlayerIndex) )
				{
					bStateChangeAllowed = ChosenObj.KillFocus(None, PlayerIndex);
				}
			}

			if ( bStateChangeAllowed )
			{
				bResult = ChosenObj.SetEnabled(bShouldEnable, PlayerIndex);
			}
		}
	}

	return bResult;
}

/** Returns the currently selected option object */
function UIObject GetCurrentlySelectedOption()
{
	if ( CurrentIndex >= 0 && CurrentIndex < GeneratedObjects.Length )
	{
		return GeneratedObjects[CurrentIndex].OptionObj;
	}

	return None;
}

/** Selects the specified option item. */
function bool SelectItem(int OptionIdx, optional int PlayerIndex=GetBestPlayerIndex(), optional bool bClampValue=true )
{
	local bool bResult;

	if ( bClampValue )
	{
		OptionIdx = Clamp(OptionIdx, 0, GeneratedObjects.length - 1);
	}

	if ( OptionIdx >= 0 && OptionIdx < GeneratedObjects.length
	&&	GeneratedObjects[OptionIdx].OptionObj.IsEnabled(GetBestPlayerIndex()))
	{
		if ( IsFocused(PlayerIndex) )
		{
			bResult = GeneratedObjects[OptionIdx].OptionObj.SetFocus(none);
		}
		else
		{
			OverrideLastFocusedControl(PlayerIndex, GeneratedObjects[OptionIdx].OptionObj);
			bResult = true;
		}
	}

	return bResult;
}

/** Selects the next item in the list. */
function bool SelectNextItem(optional bool bWrap=false, optional int PlayerIndex=GetBestPlayerIndex())
{
	local int TargetIndex;

	TargetIndex = CurrentIndex+1;

	if(bWrap)
	{
		TargetIndex = TargetIndex%(GeneratedObjects.length);
	}

	return SelectItem(TargetIndex, PlayerIndex);
}

/** Selects the previous item in the list. */
function bool SelectPreviousItem(optional bool bWrap=false, optional int PlayerIndex=GetBestPlayerIndex())
{
	local int TargetIndex;

	TargetIndex = CurrentIndex-1;

	if(bWrap && TargetIndex<0)
	{
		TargetIndex=GeneratedObjects.length-1;
	}

	return SelectItem(TargetIndex, PlayerIndex);
}

/** Checks to see if the user has clicked on the scroll arrows. */
function CheckArrowInput(const SubscribedInputEventParameters EventParms)
{
	if(EventParms.EventType==IE_Pressed||EventParms.EventType==IE_DoubleClick)
	{
		if(CursorCheck(UpArrowBounds[0],UpArrowBounds[1],UpArrowBounds[2],UpArrowBounds[3]))
		{
			bUpArrowPressed=true;
		}
		else if(CursorCheck(DownArrowBounds[0],DownArrowBounds[1],DownArrowBounds[2],DownArrowBounds[3]))
		{
			bDownArrowPressed=true;
		}

		DragClickPosition=GetMousePosition();
	}
	else if(EventParms.EventType==IE_Released)
	{
		// If we are not dragging, check for a mouse click.
		if(bDragging==false)
		{
			if(bUpArrowPressed && CursorCheck(UpArrowBounds[0],UpArrowBounds[1],UpArrowBounds[2],UpArrowBounds[3]))
			{
				// The user released their mouse on the button.
				SelectPreviousItem();
			}
			else if(bDownArrowPressed && CursorCheck(DownArrowBounds[0],DownArrowBounds[1],DownArrowBounds[2],DownArrowBounds[3]))
			{
				// The user released their mouse on the button.
				SelectNextItem();
			}
		}

		bDragging = false;
		bDownArrowPressed=false;
		bUpArrowPressed=false;
	}
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */

function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	local int OptionIdx;

	if (EventParms.EventType == IE_Pressed)
	{
		if ( EventParms.InputAliasName == 'SelectionUp' )
		{
			SelectPreviousItem(true);
		}
		else if ( EventParms.InputAliasName == 'SelectionDown' )
		{
			SelectNextItem(true);
		}
		else if ( EventParms.InputAliasName == 'SelectionHome' )
		{
			SelectItem(0);
		}
		else if ( EventParms.InputAliasName == 'SelectionEnd' )
		{
			SelectItem(GeneratedObjects.Length-1);
		}
		else if ( EventParms.InputAliasName == 'SelectionPgUp' )
		{
			SelectItem(CurrentIndex - MaxVisibleItems);
		}
		else if ( EventParms.InputAliasName == 'SelectionPgDn' )
		{
			SelectItem(CurrentIndex + MaxVisibleItems);
		}
		else if ( EventParms.InputAliasName == 'Click' )
		{
			CheckArrowInput(EventParms);
		}
	}
	else if ( EventParms.EventType == IE_Released )
	{
		if ( EventParms.InputAliasName == 'AcceptOptions' )
		{
			PlayUISound('ListSubmit');
			OnAcceptOptions(self, EventParms.PlayerIndex);
		}
		else if ( EventParms.InputAliasName == 'Click' )
		{
			CheckArrowInput(EventParms);

			for(OptionIdx=0; OptionIdx<GeneratedObjects.length; OptionIdx++)
			{
				if(CursorCheck(GeneratedObjects[OptionIdx].OptionX, GeneratedObjects[OptionIdx].OptionY,
					GeneratedObjects[OptionIdx].OptionX+GeneratedObjects[OptionIdx].OptionWidth, GeneratedObjects[OptionIdx].OptionY+GeneratedObjects[OptionIdx].OptionHeight))
				{
					if(CurrentIndex!=OptionIdx)
					{
						SelectItem(OptionIdx);
					}

					break;
				}
			}
		}
	}

	return true;
}

/**
 * Enable hottracking if we are dragging
 */
function bool ProcessInputAxis( const out SubscribedInputEventParameters EventParms )
{
	local vector CurrentMousePosition;
	local vector DeltaPosition;

	// If the user pressed down on the up or down arrow and then dragged their mouse
	// a distance greater than the 'deadzone' then enable drag mode.
	if ( (bUpArrowPressed || bDownArrowPressed) && EventParms.InputKeyName=='MouseY' )
	{
		CurrentMousePosition = GetMousePosition();
		DeltaPosition = CurrentMousePosition-DragClickPosition;

		if(Abs(DeltaPosition.Y) > DragDeadZone)
		{
			bDragging = true;
		}

		return true;
	}

	return false;
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

/** If we are dragging, this function will increment the current selection based on the location of the mouse cursor. */
function CheckAndUpdateDragging()
{
	local vector MousePos;
	local int OptionIdx;

	// See if we are dragging, if we are, then try to select the item under the mouse cursor.
	if(bDragging)
	{
		MousePos = GetMousePosition();

		for(OptionIdx=0; OptionIdx<GeneratedObjects.length; OptionIdx++)
		{
			if(MousePos.Y >= GeneratedObjects[OptionIdx].OptionY && MousePos.Y <= (GeneratedObjects[OptionIdx].OptionY+GeneratedObjects[OptionIdx].OptionHeight))
			{
				SelectItem(OptionIdx);
				break;
			}
		}
	}
}

/**
 * Render's the list's selection elements.
 */
event DrawPanel()
{
	/*  - Disabled completely, we use scrollbars on all platforms.
	local float Width,Height;
	local float AWidth, AHeight, AYPos;
	local bool bOverArrow;
	local float YPos;

	CheckAndUpdateDragging();

	YPos = BGPrefabInstance.GetPosition(UIFACE_Top, EVALPOS_PixelOwner);
	Height = BGPrefabInstance.GetPosition(UIFACE_Bottom, EVALPOS_PixelOwner);
	Width = ScrollArrowWidth * GetPosition(UIFACE_Right, EVALPOS_PixelOwner);

	// Draw up down arrows on the console.
	if(IsConsole())
	{
		// ------------ Draw the up/Down Arrows

		// Calculate the sizes
		AWidth = Width * 0.8;
		AHeight = AWidth * 2.0;
		AYPos = YPos - AHeight - (Height * 0.1);

			// Draw The up button

		// Cache the bounds for mouse lookup later

		UpArrowBounds[0] = Width*0.5f - (AWidth * 0.5);
		UpArrowBounds[2] = UpArrowBounds[0] + AWidth;
		UpArrowBounds[1] = AYPos;
		UpArrowBounds[3] = AYPos + AHeight;

		bOverArrow = CursorCheck(UpArrowBounds[0],UpArrowBounds[1],UpArrowBounds[2],UpArrowBounds[3]);
		DrawSpecial(UpArrowBounds[0],UpArrowBounds[1], AWidth, AHeight, 77, 198, 63, 126, ArrowColor, bOverArrow, bUpArrowPressed);

			// Draw The down button

		// Cache the bounds for mouse lookup later

		AYPos = YPos + Height + (Height * 0.1);

		DownArrowBounds[0] = Width*0.5f - (AWidth * 0.5);
		DownArrowBounds[2] = DownArrowBounds[0] + AWidth;
		DownArrowBounds[1] = AYPos;
		DownArrowBounds[3] = AYPos + AHeight;

		bOverArrow = CursorCheck(DownArrowBounds[0],DownArrowBounds[1],DownArrowBounds[2],DownArrowBounds[3]);
		DrawSpecial(DownArrowBounds[0],DownArrowBounds[1], AWidth, AHeight, 77, 358, 63, 126, ArrowColor, bOverArrow, bDownArrowPressed);
	}
	*/
}

function DrawSpecial(float x, float y, float w, float h, float u, float v, float ul, float vl, color DrawColor, bool bOver, bool bPressed)
{
	if (bDragging || bOver || bPressed)
	{
		Canvas.SetDrawColor(255,0,0,255);
		Canvas.SetPos(x-2,y-2);
		Canvas.DrawTile(ArrowImage, w+4, h+4, u,v,ul,vl);
	}

	if (!bDragging && !bPressed )
	{
		Canvas.SetPos(x,y);
		Canvas.DrawColor = DrawColor;
		Canvas.DrawTile(ArrowImage, w, h, u, v, ul, vl);
	}
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


defaultproperties
{
	DefaultStates.Add(class'Engine.UIState_Active')
	DataSource=(RequiredFieldType=DATATYPE_Collection)
	bRequiresTick=true

	DragDeadZone = 10;
	ScrollArrowWidth=0.04f
	ArrowColor=(R=128,G=0,B=1,A=255)

	NumericEditBoxClass=class'UINumericEditBox'
	SliderClass=class'UDKUISlider'
	EditBoxClass=class'UIEditBox'
	CheckBoxClass=class'UICheckBox'
	ComboBoxClass=class'UIComboBox'
	OptionButtonClass=class'UDKUIOptionButton';
}

