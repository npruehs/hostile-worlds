/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for a set of options to filter join game server results by.
 */

class UTUITabPage_ServerFilter extends UTUITabPage_Options
	placeable;

/** Reference to the menu items datastore. */
var UTUIDataStore_MenuItems	MenuDataStore;

/** Reference to the game search datastore. */
var UTDataStore_GameSearchDM SearchDataStore;

/** Indicates that the list of options are out of date and need to be regenerated */
var	private transient bool bOptionsDirty;

/** Called when the user changes the game type */
delegate transient OnSwitchedGameType();

/* == Events == */
/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.JoinGame.Filter>");

	MenuDataStore = UTUIDataStore_MenuItems(UTUIScene(GetScene()).FindDataStore('UTMenuItems'));
	SearchDataStore = UTDataStore_GameSearchDM(UTUIScene(GetScene()).FindDataStore('UTGameSearch'));
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
	local UIObject SelectedOption;

	bResult = Super.ActivatePage(PlayerIndex, bActivate, bTakeFocus);

	if ( bResult && bActivate )
	{
		if ( bOptionsDirty )
		{
			OptionList.RefreshAllOptions();
			bOptionsDirty = false;
		}

		SelectedOption = OptionList.GetCurrentlySelectedOption();

		// if the currently selected option is disabled, select the next item
		if ( !SelectedOption.IsEnabled(PlayerIndex) )
		{
			OptionList.SelectNextItem(true);
		}
	}

	return bResult;
}

/**
 * Marks the options list as out of date and if visible, refreshes the options list.  Called when the user
 * changes the gametype.
 */
function MarkOptionsDirty()
{
	if ( IsVisible() )
	{
		OptionList.RefreshAllOptions();
		bOptionsDirty = false;
	}
	else
	{
		bOptionsDirty = true;
	}
}

/**
 * Enables / disables the "match type" control based on whether we are signed in online.
 *
 * @param	bIsCampaignMode		TRUE if the join game scene was entered through the campaign's "Join Campaign" option
 */
function ValidateServerType( bool bIsCampaignMode )
{
	local int PlayerIndex, PlayerControllerID;
	local UTUIScene UTOwnerScene;

	UTOwnerScene = UTUIScene(GetScene());
	if ( UTOwnerScene != None )
	{
		// find the "MatchType" control (contains the "LAN" and "Internet" options);  if we aren't signed in online,
		// don't have a link connection, or not allowed to play online, don't allow them to select one.
		PlayerIndex = UTOwnerScene.GetPlayerIndex();
		PlayerControllerID = UTOwnerScene.GetPlayerControllerId( PlayerIndex );
		if ( !IsLoggedIn(PlayerControllerID,true) )
		{
			ForceLANOption(PlayerIndex);
		}
	}
}

final function ForceLANOption( int PlayerIndex )
{
	local UIObject ServerTypeOption, GameTypeOption;
	local int ValueIndex;
	local name MatchTypeName;

	ServerTypeOption = FindChild('MatchType', true);
	if ( ServerTypeOption != None )
	{
		MatchTypeName = IsConsole(CONSOLE_XBox360) ? 'MatchType360' : 'MatchType';
		ValueIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);
		if ( ValueIndex != class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN )
		{
			// make sure the "LAN" option is selected
			StringListDataStore.SetCurrentValueIndex(MatchTypeName,class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN);
			UIDataStoreSubscriber(ServerTypeOption).RefreshSubscriberValue();
		}

		// LAN queries show all gametypes, so switch to "DeathMatch" so that search results are always in the same place
		ValueIndex = MenuDataStore.FindValueInProviderSet('GameModeFilter', 'GameSearchClass', "UTGameSearchDM");
		if ( ValueIndex != INDEX_NONE && MenuDataStore.GameModeFilter != ValueIndex )
		{
			MenuDataStore.GameModeFilter = ValueIndex;
			MarkOptionsDirty();
			SearchDataStore.SetCurrentByName('UTGameSearchDM', true);
		}

		GameTypeOption = FindChild('GameModeFilter', true);

		// use the accessor so that if the match or server type options are selected, we select the next possible one
		OptionList.EnableItem(PlayerIndex, ServerTypeOption, false);
		OptionList.EnableItem(PlayerIndex, GameTypeOption, false);
	}
}

/** Pass through the option callback. */
function OnOptionList_OptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	local string OutStringValue;
	local int ProviderIdx;
	local int ValueIndex;
	local UIObject GameModeOption;
	local array<UIDataStore> OutDataStores;
	local UIDataStorePublisher Publisher;

	Super.OnOptionList_OptionChanged(InObject, OptionName, PlayerIndex);

	// if we're the active page, publish this option's value to its data store so that the value won't be reset
	// if the option list is regenerated
	if ( IsActivePage() || GetOwnerTabControl() == None )
	{
		Publisher = UIDataStorePublisher(InObject);
		if ( Publisher != None )
		{
			Publisher.SaveSubscriberValue(OutDataStores);
		}
	}

	if(OptionName=='GameMode_Client')
	{
		if(GetDataStoreStringValue("<UTMenuItems:GameModeFilterClass>", OutStringValue))
		{
			// make sure to update the GameSettings value - this is used to build the join URL
			SetDataStoreStringValue("<UTGameSettings:CustomGameMode>", OutStringValue);

			// find the index into the UTMenuItems data store for the gametype with the specified class name
			ProviderIdx = MenuDataStore.FindValueInProviderSet('GameModeFilter','GameMode', OutStringValue);

			// now that we know the index into the UTMenuItems data store, we can retrieve the tag that is used to identify the corresponding
			// game search object in the Game Search data store.
			if(ProviderIdx != INDEX_NONE && MenuDataStore.GetValueFromProviderSet('GameModeFilter','GameSearchClass', ProviderIdx, OutStringValue))
			{
				// Set the search settings class
				SearchDataStore.SetCurrentByName(name(OutStringValue), false);
			}

			// fire the delegate
			OnSwitchedGameType();

			MarkOptionsDirty();
		}
	}
	else if ( OptionName == 'MatchType' || OptionName == 'MatchType360' )
	{
		GameModeOption = FindChild('GameModeFilter',true);
		if ( GameModeOption != None )
		{
			ValueIndex = StringListDataStore.GetCurrentValueIndex(OptionName);

			// if the user wants to search for LAN matches, disable the gametype combo
			OptionList.EnableItem(PlayerIndex, GameModeOption, ValueIndex != class'UTUITabPage_ServerBrowser'.const.SERVERBROWSER_SERVERTYPE_LAN);
		}
	}
}

