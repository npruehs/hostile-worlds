/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Game mode selection page for UT3.
 */

class UTUITabPage_GameModeSelection extends UTTabPage
	placeable;

/** Preview image for a game mode. */
var transient UIImage	GameModePreviewImage;

/** Description of the currently selected game mode. */
var transient UILabel	GameModeDescription;

/** Reference to the game mode list. */
var transient UTUIList GameModeList;

/** Delegate for when the user selects a game mode on this page. */
delegate OnGameModeSelected(string InGameMode, string InDefaultMap, string GameSettingsClass, bool bSelectionSubmitted);

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Setup delegates
	GameModeList = UTUIList(FindChild('lstGameModes', true));
	if(GameModeList != none)
	{
		GameModeList.OnSubmitSelection = OnGameModeList_SubmitSelection;
		GameModeList.OnValueChanged = OnGameModeList_ValueChanged;
	}

	// Store widget references
	GameModePreviewImage = UIImage(FindChild('imgGameModePreview1', true));
	GameModeDescription = UILabel(FindChild('lblDescription', true));

	// Setup tab caption
	SetDataStoreBinding("<Strings:UTGameUI.FrontEnd.TabCaption_GameMode>");
}

/** Callback for when the game mode changes, issues the delegate and sets some registry values. */
function OnGameModeChanged(bool bSubmitted)
{
	local int SelectedItem;
	local string GameMode;
	local string DefaultMap;
	local string Prefixes;
	local string GameSettingsClass;

	SelectedItem = GameModeList.GetCurrentItem();

	if(class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'GameMode', SelectedItem, GameMode) &&
		class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'DefaultMap', SelectedItem, DefaultMap) &&
		class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'Prefixes', SelectedItem, Prefixes) &&
		class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'GameSettingsClass', SelectedItem, GameSettingsClass))
	{
		//`Log("UTUITabPage::OnGameModeChanged() - Current Game Mode: " $ GameMode);
		SetDataStoreStringValue("<Registry:SelectedGameModePrefix>", Prefixes);

		OnGameModeSelected(GameMode, DefaultMap, GameSettingsClass, bSubmitted);
	}
}

/** @return Returns the option set for the currently selected game mode. */
function string GetOptionSet()
{
	local string OptionSet;
	local int SelectedItem;

	SelectedItem = GameModeList.GetCurrentItem();
	if(class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'OptionSet', SelectedItem, OptionSet))
	{
		return OptionSet;
	}
	else
	{
		return "DM";
	}
}

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnGameModeList_SubmitSelection( UIList Sender, optional int PlayerIndex=0 )
{
	OnGameModeChanged(true);
}


/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnGameModeList_ValueChanged( UIObject Sender, optional int PlayerIndex=0 )
{
	local int SelectedItem;
	local string StringValue;

	SelectedItem = GameModeList.GetCurrentItem();

	if(class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'PreviewImageMarkup', SelectedItem, StringValue))
	{
		GameModePreviewImage.SetDatastoreBinding(StringValue);
	}

	if(class'UDKUIMenuList'.static.GetCellFieldString(GameModeList, 'Description', SelectedItem, StringValue))
	{
		GameModeDescription.SetDatastoreBinding(StringValue);
	}

	OnGameModeChanged(false);
}
