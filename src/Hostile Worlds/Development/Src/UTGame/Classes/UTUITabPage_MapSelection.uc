/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Map selection screen for UT3
 */

class UTUITabPage_MapSelection extends UTTabPage
	placeable;

/** Single map panel. */
var transient UTUIPanel_SingleMap	SingleMapPanel;

/** Delegate for when the user selected a map or accepted their map cycle. */
delegate OnMapSelected();

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	SingleMapPanel = UTUIPanel_SingleMap(FindChild('pnlSingleMap', true));
	SingleMapPanel.OnMapSelected=OnSingleMapSelected;

	// Setup tab caption
	SetDataStoreBinding("<Strings:UTGameUI.FrontEnd.TabCaption_Map>");

	SingleMapPanel.SetVisibility(true);
}

/** Callback for when a single map has been selected. */
function OnSingleMapSelected()
{
	OnMapSelected();
}

/** @return Returns the first map, either the map selected in the single map selection or the first map of the map cycle. */
function string GetFirstMap()
{
	local string Result;

	Result = SingleMapPanel.GetSelectedMap();

	return Result;
}

/** Callback for when the game mode changes, updates both panels. */
function OnGameModeChanged()
{
	// Update map cycle lists
	SingleMapPanel.MapList.RefreshSubscriberValue();
	SingleMapPanel.OnMapList_ValueChanged(SingleMapPanel.MapList);
}

/** @return Whether or not we can begin the match. */
function bool CanBeginMatch()
{
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

	bResult = SingleMapPanel.HandleInputKey(EventParms);

	return bResult;
}
