/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Single map secreen for UT3.
 */

class UTUIPanel_SingleMap extends UTTabPage
	placeable;

/** Preview image for a map. */
var transient UIImage	MapPreviewImage;

/** Description label for the map. */
var transient UILabel	DescriptionLabel;

/** NumPlayers label for the map. */
var transient UILabel	NumPlayersLabel;

/** List of maps widget. */
var transient UTUIList MapList;

/** scrollframe which contains the description label - allows the player to read long descriptions */
var	transient UIScrollFrame DescriptionScroller;

/** Delegate for when the user selects a map on this page. */
delegate OnMapSelected();

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Setup delegates
	MapList = UTUIList(FindChild('lstMaps', true));
	if(MapList != none)
	{
		MapList.OnSubmitSelection = OnMapList_SubmitSelection;
		MapList.OnValueChanged = OnMapList_ValueChanged;
	}

	// Store widget references
	MapPreviewImage = UIImage(FindChild('imgMapPreview1', true));

	DescriptionLabel = UILabel(FindChild('lblDescription', true));
	NumPlayersLabel = UILabel(FindChild('lblNumPlayers', true));

	DescriptionScroller = UIScrollFrame(FindChild('DescriptionScrollFrame',true));
	
	// if we're on a console platform, make the scrollframe not focusable.
	if ( IsConsole() && DescriptionScroller != None )
	{
		DescriptionScroller.SetPrivateBehavior(PRIVATE_NotFocusable, true);
	}
}

/** @return Returns the current game mode. */
function name GetCurrentGameMode()
{
	local string GameMode;

	GetDataStoreStringValue("<Registry:SelectedGameMode>", GameMode);

	// strip out package so we just have class name
	return name(Right(GameMode, Len(GameMode) - InStr(GameMode, ".") - 1));
}

/** Sets up a map cycle consisting of 1 map. */
function SetupMapCycle(string SelectedMap)
{
	local int CycleIdx;
	local name GameMode;
	local GameMapCycle MapCycle;

	GameMode = GetCurrentGameMode();

	MapCycle.GameClassName = GameMode;
	MapCycle.Maps.length=1;
	MapCycle.Maps[0]=SelectedMap;

	CycleIdx = class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', GameMode);
	if (CycleIdx == INDEX_NONE)
	{
		CycleIdx = class'UTGame'.default.GameSpecificMapCycles.length;
	}
	class'UTGame'.default.GameSpecificMapCycles[CycleIdx] = MapCycle;

	// Save the config for this class.
	class'UTGame'.static.StaticSaveConfig();
}

/** @return Returns the currently selected map. */
function string GetSelectedMap()
{
	local int SelectedItem;
	local string MapName;

	MapName="";
	SelectedItem = MapList.GetCurrentItem();
	class'UDKUIMenuList'.static.GetCellFieldString(MapList, 'MapName', SelectedItem, MapName);

	SetupMapCycle(MapName);

	return MapName;
}

/**
 * Called when the user changes the current list index.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnMapList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	OnMapSelected();
}

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnMapList_ValueChanged( UIObject Sender, optional int PlayerIndex=0 )
{
	local int SelectedItem;
	local string StringValue;


	SelectedItem = MapList.GetCurrentItem();

	// Preview Image
	if(class'UDKUIMenuList'.static.GetCellFieldString(MapList, 'PreviewImageMarkup', SelectedItem, StringValue))
	{
		SetPreviewImageMarkup(StringValue);
	}

	// Map Description
	if(class'UDKUIMenuList'.static.GetCellFieldString(MapList, 'Description', SelectedItem, StringValue))
	{
		DescriptionLabel.SetDatastoreBinding(StringValue);
	}

	// Num Players
	if(class'UDKUIMenuList'.static.GetCellFieldString(MapList, 'NumPlayers', SelectedItem, StringValue))
	{
		NumPlayersLabel.SetDatastoreBinding(StringValue);
	}
}

/** Changes the preview image for a map. */
function SetPreviewImageMarkup(string InMarkup)
{
	MapPreviewImage.SetDatastoreBinding(InMarkup);
}
