/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Scene to let user's select which mutators to use.
 */

class UTUIFrontEnd_Mutators extends UTUIFrontEnd
	placeable;

/** List of available mutators. */
var transient UIList AvailableList;

/** List of enabled mutators. */
var transient UIList EnabledList;

/** The last list that was focused. */
var transient UIList LastFocusedList;

/** Label describing the currently selected mutator. */
var transient UILabel DescriptionLabel;

/** Arrow images. */
var transient UIImage ShiftRightImage;
var transient UIImage ShiftLeftImage;

/** Reference to the menu datastore */
var transient UTUIDataStore_MenuItems MenuDataStore;

/** Mutators that were enabled when we entered the scene. */
var transient array<int>	OldEnabledMutators;

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	AvailableList = UIList(FindChild('lstAvailable', true));
	EnabledList = UIList(FindChild('lstEnabled', true));

	// Set default focused list
	LastFocusedList = AvailableList;

	Super.PostInitialize();

	// Store widget references
	AvailableList.OnValueChanged = OnAvailableList_ValueChanged;
	AvailableList.OnSubmitSelection = OnAvailableList_SubmitSelection;
	AvailableList.NotifyActiveStateChanged = OnAvailableList_NotifyActiveStateChanged;
	AvailableList.OnRawInputKey=OnMutatorList_RawInputKey;

	EnabledList.OnValueChanged = OnEnabledList_ValueChanged;
	EnabledList.OnSubmitSelection = OnEnabledList_SubmitSelection;
	EnabledList.NotifyActiveStateChanged = OnEnabledList_NotifyActiveStateChanged;
	EnabledList.OnRawInputKey=OnMutatorList_RawInputKey;

	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	ShiftRightImage = UIImage(FindChild('imgArrowLeft', true));
	ShiftLeftImage = UIImage(FindChild('imgArrowRight', true));

	// Get reference to the menu datastore
	MenuDataStore = UTUIDataStore_MenuItems(StaticResolveDataStore('UTMenuItems'));

	// Get the list of mutators before we entered the scene.
	OldEnabledMutators = MenuDataStore.EnabledMutators;
}

/** Sets up the button bar for the parent scene. */
function SetupButtonBar()
{
	ButtonBar.Clear();

	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Accept>", OnButtonBar_Next);
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Cancel>", OnButtonBar_Cancel);

	if(EnabledList.IsFocused())
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.RemoveMutator>", OnButtonBar_RemoveMutator);
	}
	else
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.AddMutator>", OnButtonBar_AddMutator);
	}

	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ConfigureMutator>", OnButtonBar_ConfigureMutator);
}

/** @return Returns the current list of enabled mutators, separated by commas. */
static function string GetEnabledMutators()
{
	local string MutatorString;
	local string ClassName;
	local int MutatorIdx;
	local UTUIDataStore_MenuItems LocalMenuDataStore;

	LocalMenuDataStore = UTUIDataStore_MenuItems(StaticResolveDataStore('UTMenuItems'));

	for(MutatorIdx=0; MutatorIdx < LocalMenuDataStore.EnabledMutators.length; MutatorIdx++)
	{
		if(LocalMenuDataStore.GetValueFromProviderSet('EnabledMutators', 'ClassName', LocalMenuDataStore.EnabledMutators[MutatorIdx], ClassName))
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
static function ApplyGameModeFilter()
{
	local int MutatorIdx;
	local array<int> FinalItems;
	local UTUIDataStore_MenuItems LocalMenuDataStore;

	LocalMenuDataStore = UTUIDataStore_MenuItems(StaticResolveDataStore('UTMenuItems'));

	for(MutatorIdx=0; MutatorIdx<LocalMenuDataStore.EnabledMutators.length; MutatorIdx++)
	{
		if(LocalMenuDataStore.IsProviderFiltered('Mutators', LocalMenuDataStore.EnabledMutators[MutatorIdx])==false)
		{
			FinalItems.AddItem(LocalMenuDataStore.EnabledMutators[MutatorIdx]);
		}
	}

	LocalMenuDataStore.EnabledMutators = FinalItems;
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
	OnMutatorListChanged();
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
	AvailableList.RefreshSubscriberValue();
	EnabledList.RefreshSubscriberValue();

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
	SetupButtonBar();

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

	if(LastFocusedList==EnabledList)
	{
		if(IsCurrentMutatorConfigurable())
		{
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
					OpenScene(ConfigureScene);
				}
				else
				{
					`Log("UTUITabPage_Mutators::OnConfigureMutator() - Unable to find scene '"$ConfigureSceneName$"'");
				}
			}
		}
		else
		{
			DisplayMessageBox("<Strings:UTGameUI.Errors.CurrentMutatorCannotBeConfigured_Message>","<Strings:UTGameUI.Errors.CurrentMutatorCannotBeConfigured_Title>");
		}
	}
	else
	{
		DisplayMessageBox("<Strings:UTGameUI.Errors.CanOnlyConfigureEnabledMutators_Message>","<Strings:UTGameUI.Errors.CanOnlyConfigureEnabledMutators_Title>");
	}
}

/** The user has finished setting up their mutators and wants to continue on. */
function OnNext()
{
	CloseScene(self);
}

/** The user has finished setting up their mutators and wants to continue on. */
function OnCancel()
{
	MenuDataStore.EnabledMutators=OldEnabledMutators;
	CloseScene(self);
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
function OnAvailableList_NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	UIList(Sender).OnStateChanged(Sender, PlayerIndex, NewlyActiveState, PreviouslyActiveState);
	if(NewlyActiveState.Class == class'UIState_Focused')
	{
		LastFocusedList = AvailableList;
		OnSelectedMutatorChanged();
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

/** Callback for when the object's active state changes. */
function OnEnabledList_NotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	UIList(Sender).OnStateChanged(Sender, PlayerIndex, NewlyActiveState, PreviouslyActiveState);
	if(NewlyActiveState.Class == class'UIState_Focused')
	{
		LastFocusedList = EnabledList;
		OnSelectedMutatorChanged();
	}
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

function bool OnButtonBar_Cancel(UIScreenObject InButton, int PlayerIndex)
{
	OnCancel();

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
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')		// Accept mutators
		{
			OnCancel();

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

