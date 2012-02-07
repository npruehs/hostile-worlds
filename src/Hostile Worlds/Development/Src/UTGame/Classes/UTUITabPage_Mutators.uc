/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page to let user's select which mutators to use.
 */

class UTUITabPage_Mutators extends UTTabPage
	placeable;

/** List of available mutators. */
var transient UIList AvailableList;
var	transient UIImage ListBackground_Available;

/** List of enabled mutators. */
var transient UIList EnabledList;
var	transient UIImage ListBackground_Enabled;

/** The last list that was focused. */
var transient UIList LastFocusedList;

/** Label describing the currently selected mutator. */
var transient UILabel DescriptionLabel;

/** Arrow images. */
var transient UIImage ShiftRightImage;
var transient UIImage ShiftLeftImage;

/** Reference to the menu datastore */
var transient UTUIDataStore_MenuItems MenuDataStore;

const MANUAL_LIST_REFRESH_DATABINDING_INDEX=50;

/** Callback for when the user decides to accept the current set of mutators. */
delegate OnAcceptMutators(string InEnabledMutators);

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Store widget references
	AvailableList = UIList(FindChild('lstAvailable', true));
	AvailableList.OnValueChanged = None;
	AvailableList.OnSubmitSelection = None;
	AvailableList.NotifyActiveStateChanged = OnList_NotifyActiveStateChanged;
	AvailableList.OnRawInputKey=None;
	AvailableList.OnRefreshSubscriberValue = None;

	EnabledList = UIList(FindChild('lstEnabled', true));
	EnabledList.OnValueChanged = None;
	EnabledList.OnSubmitSelection = None;
	EnabledList.NotifyActiveStateChanged = OnList_NotifyActiveStateChanged;
	EnabledList.OnRawInputKey=None;
	EnabledList.OnRefreshSubscriberValue = None;

	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	ShiftRightImage = UIImage(FindChild('imgArrowLeft', true));
	ShiftLeftImage = UIImage(FindChild('imgArrowRight', true));
	ListBackground_Available = UIImage(FindChild('imgAvailable', true));
	ListBackground_Enabled = UIImage(FindChild('imgEnabled', true));

	// Get reference to the menu datastore
	MenuDataStore = UTUIDataStore_MenuItems(StaticResolveDataStore('UTMenuItems'));

	// Set default focused list
	LastFocusedList = AvailableList;

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.FrontEnd.TabCaption_Mutators>");
}

/**
 * Called when this widget receives a call to RefreshSubscriberValue.
 *
 * @param	BindingIndex		optional parameter for indicating which data store binding is being refreshed, for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0,
 *								while values greater than FIRST_DEFAULT_DATABINDING_INDEX correspond to tooltips and context
 *								menus.
 *
 * @return	TRUE to indicate that this widget is going to refresh its value manually.
 */
function bool HandleRefreshSubscriberValue( UIObject Sender, int BindingIndex )
{
	if ( BindingIndex < FIRST_DEFAULT_DATABINDING_INDEX && Sender.IsInitialized() )
	{
		if ( BindingIndex != MANUAL_LIST_REFRESH_DATABINDING_INDEX
		&&	Sender != EnabledList )
		{
			OnMutatorListChanged();
			return true;
		}
	}

	return false;
}

/** Sets up the button bar for the parent scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	if(IsVisible())
	{
		ButtonBar.SetButton(1,"<Strings:UTGameUI.ButtonCallouts.Next>", OnButtonBar_Next);

		if(EnabledList.IsFocused())
		{
			ButtonBar.SetButton(2,"<Strings:UTGameUI.ButtonCallouts.RemoveMutator>", OnButtonBar_RemoveMutator);
		}
		else
		{
			ButtonBar.SetButton(2,"<Strings:UTGameUI.ButtonCallouts.AddMutator>", OnButtonBar_AddMutator);
		}

		// Only set the configure button if they are able to configure the currently selected mutator.
		ButtonBar.ClearButton(3);

		if(EnabledList.IsFocused() && IsCurrentMutatorConfigurable())
		{
			ButtonBar.SetButton(3,"<Strings:UTGameUI.ButtonCallouts.ConfigureMutator>", OnButtonBar_ConfigureMutator);
		}
	}
}

/** @return Returns the current list of enabled mutators, separated by commas. */
function string GetEnabledMutators()
{
	local string MutatorString;
	local string ClassName;
	local int MutatorIdx;

	for(MutatorIdx=0; MutatorIdx < MenuDataStore.EnabledMutators.length; MutatorIdx++)
	{
		if ( class'UDKUIMenuList'.static.GetCellFieldString(EnabledList, 'ClassName', MenuDataStore.EnabledMutators[MutatorIdx], ClassName))
		{
			if(MutatorIdx > 0)
			{
				MutatorString $= ",";
			}

			MutatorString $= ClassName;
		}
	}

	return MutatorString;
}



/** Applies the game mode filter to the enabled and available mutator lists. */
function ApplyGameModeFilter()
{
	local int MutatorIdx;
	local array<int> FinalItems;

	for(MutatorIdx=0; MutatorIdx<MenuDataStore.EnabledMutators.length; MutatorIdx++)
	{
		if(MenuDataStore.IsProviderFiltered('Mutators', MenuDataStore.EnabledMutators[MutatorIdx])==false)
		{
			FinalItems.AddItem(MenuDataStore.EnabledMutators[MutatorIdx]);
		}
	}

	MenuDataStore.EnabledMutators = FinalItems;
	OnMutatorListChanged();
}

/** Attempts to filter the mutator list to ensure that there are no duplicate groups or mutators enabled that can not be enabled. */
function AddMutatorAndFilterList(int NewMutator)
{
	local bool bFiltered;
	local int MutatorIdx, GroupIdx;
	local string StringValue;
	local array<string> GroupNames, CompareGroupNames;
	local array<int> FinalItems;

	// Group Name
	if (class'UDKUIMenuList'.static.GetCellFieldString(EnabledList, 'GroupNames', NewMutator, StringValue))
	{
		ParseStringIntoArray(StringValue, GroupNames, "|", true);
	}

	// we can only have 1 mutator of a specified group enabled at a time, so filter all of the mutators that are of the group we are currently adding.
	if (GroupNames.length > 0)
	{
		`Log("Filtering group: '" $ StringValue $ "'");
		for (MutatorIdx = 0; MutatorIdx < EnabledList.Items.length; MutatorIdx++)
		{
			bFiltered = false;

			if (class'UDKUIMenuList'.static.GetCellFieldString(EnabledList, 'GroupNames', EnabledList.Items[MutatorIdx], StringValue))
			{
				ParseStringIntoArray(StringValue, CompareGroupNames, "|", true);
				for (GroupIdx = 0; GroupIdx < GroupNames.length; GroupIdx++)
				{
					if (CompareGroupNames.Find(GroupNames[GroupIdx]) != INDEX_NONE)
					{
						bFiltered = true;
						break;
					}
				}
			}

			if (!bFiltered)
			{
				FinalItems.AddItem(EnabledList.Items[MutatorIdx]);
			}
		}
	}
	else
	{
		FinalItems = EnabledList.Items;
	}

	// Update final item list.
	FinalItems.AddItem(NewMutator);
	MenuDataStore.EnabledMutators = FinalItems;
	ApplyGameModeFilter();
}

function name GetClassNameFromIndex(int MutatorIndex)
{
	local name Result;
	local string DataStoreMarkup;
	local string OutValue;

	Result = '';

	DataStoreMarkup = "<UTMenuItems:Mutators;"$MutatorIndex$".ClassName>";
	if(GetDataStoreStringValue(DataStoreMarkup, OutValue))
	{
		Result = name(OutValue);
	}

	return Result;
}

/**
 * Repopulate the lists; called whenever items are added or removed to one of the lists.
 */
function OnMutatorListChanged()
{
	local int i, EnabledIndex, EnabledItem, AvailableIndex, AvailableItem;

	AvailableIndex = AvailableList.Index;
	AvailableItem = AvailableList.GetCurrentItem();

	EnabledIndex = EnabledList.Index;
	EnabledItem = EnabledList.GetCurrentItem();

	// Have both lists refresh their subscriber values
	AvailableList.IncrementAllMutexes();
	EnabledList.IncrementAllMutexes();

	// directly set the indexes to a bad value so that when we call SetIndex later, we're guaranteed to get an update notification
	AvailableList.Index = -2;
	EnabledList.Index = -2;

	// now repopulate the lists
	AvailableList.RefreshSubscriberValue(MANUAL_LIST_REFRESH_DATABINDING_INDEX);
	EnabledList.RefreshSubscriberValue(MANUAL_LIST_REFRESH_DATABINDING_INDEX);

	// first, we'll attempt to reselect the same mutator that was previously selected by searching for the previously
	// selected item.  it might not be there if that item was just moved to another list or something, in which case we'll
	// just select the item now in that position in the list
	i = AvailableList.Items.Find(AvailableItem);
	if ( i == INDEX_NONE )
	{
		i = AvailableIndex;
	}

	AvailableList.DecrementAllMutexes();
	AvailableList.SetIndex(i);


	// now do the same for the list of active mutators.
	i = EnabledList.Items.Find(EnabledItem);
	if ( i == INDEX_NONE )
	{
		i = EnabledIndex;
	}

	EnabledList.DecrementAllMutexes();
	EnabledList.SetIndex(i);

	// if the number of items in one of the lists was less than the number of items it can display but now is more, then
	// the list that didn't lose an item will have re-selected the same element, meaning that it won't trigger a scene update
	// so let's do that manually ourselves
	RequestFormattingUpdate();
	RequestSceneUpdate(false,true);
}

/** Modifies the enabled mutator array to enable/disable a mutator. */
function SetMutatorEnabled(int MutatorId, bool bEnabled)
{
	`Log("UTUITabPage_Mutators::SetMutatorEnabled() - MutatorId: "$MutatorId$", bEnabled: "$bEnabled);

	// Get Mutator class from index
	if(bEnabled)
	{
		if(MenuDataStore.EnabledMutators.Find(MutatorId)==INDEX_NONE)
		{
			AddMutatorAndFilterList(MutatorId);

			// no need to call this here - AddMutatorAndFilterList calls ApplyGameModeFilter, which calls OnMutatorListChanged.
			//OnMutatorListChanged();
		}
	}
	else
	{
		if(MenuDataStore.EnabledMutators.Find(MutatorId)!=INDEX_NONE)
		{
			MenuDataStore.EnabledMutators.RemoveItem(MutatorId);

			// If we removed all of the enabled mutators, set focus back to the available list.
			if(MenuDataStore.EnabledMutators.length==0 && EnabledList.IsFocused())
			{
				AvailableList.SetFocus(none);
			}

			OnMutatorListChanged();
		}
	}
}

/** Clears the enabled mutator list. */
function OnClearMutators()
{
	MenuDataStore.EnabledMutators.length=0;

	// Set focus to the available list.
	AvailableList.SetFocus(none);

	// now repopulate the lists
	OnMutatorListChanged();
}

/** Updates widgets when the currently selected mutator changes. */
function OnSelectedMutatorChanged()
{
	UpdateDescriptionLabel();
	SetupButtonBar(UTUIFrontEnd(GetScene()).ButtonBar);

	// Update arrows
	if(LastFocusedList==EnabledList)
	{
		ShiftLeftImage.SetEnabled(false);
		ShiftRightImage.SetEnabled(true);
	}
	else
	{
		ShiftLeftImage.SetEnabled(true);
		ShiftRightImage.SetEnabled(false);
	}
}

/** Callback for when the user tries to move a mutator from one list to another. */
function OnMoveMutator(bool bAddMutator)
{
	if(bAddMutator==false)
	{
		if(EnabledList.Items.length > 0)
		{
			SetMutatorEnabled(EnabledList.GetCurrentItem(), false);
		}
	}
	else
	{
		if(AvailableList.Items.length > 0)
		{
			SetMutatorEnabled(AvailableList.GetCurrentItem(), true);
		}
	}

//	OnSelectedMutatorChanged();
}

/** @return Returns whether or not the current mutator is configurable. */
function bool IsCurrentMutatorConfigurable()
{
	local string ConfigureSceneName;
	local bool bResult;

	bResult = false;

	if(class'UDKUIMenuList'.static.GetCellFieldString(EnabledList, 'UIConfigScene', EnabledList.GetCurrentItem(), ConfigureSceneName))
	{
		bResult = ConfigureSceneName != "";
	}

	return bResult;
}

/** Loads the configuration scene for the currently selected mutator. */
function OnConfigureMutator()
{
	local string ConfigureSceneName;
	local UIScene ConfigureScene;
	local UTUIScene OwnerUTScene;

	if(class'UDKUIMenuList'.static.GetCellFieldString(EnabledList, 'UIConfigScene', EnabledList.GetCurrentItem(), ConfigureSceneName))
	{
		if (class'WorldInfo'.static.IsConsoleBuild())
		{
			ConfigureScene = UIScene(FindObject(ConfigureSceneName, class'UIScene'));
		}
		else
		{
			ConfigureScene = UIScene(DynamicLoadObject(ConfigureSceneName, class'UIScene'));
		}

		if(ConfigureScene != none)
		{
			OwnerUTScene = UTUIScene(GetScene());
			OwnerUTScene.OpenScene(ConfigureScene);
		}
		else
		{
			`Log("UTUITabPage_Mutators::OnConfigureMutator() - Unable to find scene '"$ConfigureSceneName$"'");
		}
	}
}

/** The user has finished setting up their mutators and wants to continue on. */
function OnNext()
{
	// Fire our mutators accepted delegate.
	OnAcceptMutators(GetEnabledMutators());
}

/** Updates the description label. */
function UpdateDescriptionLabel()
{
	local string NewDescription;
	local int SelectedItem;

	SelectedItem = LastFocusedList.GetCurrentItem();

	if(class'UDKUIMenuList'.static.GetCellFieldString(LastFocusedList, 'Description', SelectedItem, NewDescription))
	{
		DescriptionLabel.SetDataStoreBinding(NewDescription);
	}
}

/**
 * Callback for when the user selects a new item in the available list.
 */
function OnAvailableList_ValueChanged( UIObject Sender, int PlayerIndex )
{
	if ( Sender == LastFocusedList )
	{
		OnSelectedMutatorChanged();
	}
}

/**
 * Callback for when the user submits the selection on the available list.
 */
function OnAvailableList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	OnMoveMutator(true);
}

/** Callback for when the object's active state changes. */
function OnList_NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	local UIList ListSender;

	ListSender = UIList(Sender);
	if ( ListSender != None )
	{
		ListSender.OnStateChanged(Sender, PlayerIndex, NewlyActiveState, PreviouslyActiveState);
		if ( UIState_Focused(NewlyActiveState) != None )
		{
			LastFocusedList = ListSender;
			OnSelectedMutatorChanged();


			// for visual effect - the disabled state of these images contains the data to make the background image appear focused
			if ( ListSender == EnabledList )
			{
				if ( ListBackground_Enabled != None )
				{
					ListBackground_Enabled.SetEnabled(false, PlayerIndex);
				}
			}
			else
			{
				if ( ListBackground_Available != None )
				{
					ListBackground_Available.SetEnabled(false, PlayerIndex);
				}
			}
		}
		else if ( UIState_Focused(PreviouslyActiveState) != None &&	!ListSender.IsFocused(PlayerIndex) )
		{
			// for visual effect - the enabled state of these images contains the data to make the background image appear not-focused
			if ( ListSender == EnabledList )
			{
				if ( ListBackground_Enabled != None )
				{
					ListBackground_Enabled.SetEnabled(true, PlayerIndex);
				}
			}
			else
			{
				if ( ListBackground_Available != None )
				{
					ListBackground_Available.SetEnabled(true, PlayerIndex);
				}
			}
		}
	}
}

/**
 * Callback for when the user selects a new item in the enabled list.
 */
function OnEnabledList_ValueChanged( UIObject Sender, int PlayerIndex )
{
	if ( Sender == LastFocusedList )
	{
		OnSelectedMutatorChanged();
	}
}

/**
 * Callback for when the user submits the selection on the enabled list.
 */
function OnEnabledList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	OnMoveMutator(false);
}

/** Callback for the mutator lists, captures the accept button before the mutators get to it. */
function bool OnMutatorList_RawInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult = false;

	if(EventParms.EventType==IE_Released && EventParms.InputKeyName=='XboxTypeS_A')
	{
		OnNext();
		bResult = true;
	}

	return bResult;
}


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

	bResult = Super.ActivatePage(PlayerIndex, bActivate, bTakeFocus);

	if ( bResult && bActivate && bTakeFocus )
	{
		AvailableList.SetFocus(None);
	}

	return bResult;
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_ConfigureMutator(UIScreenObject InButton, int PlayerIndex)
{
	OnConfigureMutator();

	return true;
}

function bool OnButtonBar_ClearMutators(UIScreenObject InButton, int PlayerIndex)
{
	OnClearMutators();

	return true;
}

function bool OnButtonBar_AddMutator(UIScreenObject InButton, int PlayerIndex)
{
	AvailableList.SetFocus(none);
	OnMoveMutator(true);

	return true;
}

function bool OnButtonBar_RemoveMutator(UIScreenObject InButton, int PlayerIndex)
{
	EnabledList.SetFocus(none);
	OnMoveMutator(false);

	return true;
}


function bool OnButtonBar_Next(UIScreenObject InButton, int PlayerIndex)
{
	OnNext();

	return true;
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
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult=false;

	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_A' || EventParms.InputKeyName=='XboxTypeS_Enter')		// Accept mutators
		{
			OnNext();

			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_Y')		// Move mutator
		{
			OnMoveMutator(AvailableList.IsFocused());
			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_X')		// Clear mutators
		{
			OnConfigureMutator();

			bResult=true;
		}
	}

	return bResult;
}



