/**********************************************************************

Filename    :   GFxUDKFrontEnd_MapSelect.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of a map selection view for the GFx-UDK 
                front end.

                Associated Flash content: udk_map.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_MapSelect extends GFxUDKFrontEnd_Screen
    config(UI)
    dependson(UTGame);

/** Reference to the list. */
var GFxClikWidget ListMC;

/** Reference to the list's dataProvider array in AS. */
var GFxObject ListDataProvider;

/** Reference to image scroller. Image scroller update is handled by AS. */
var GFxClikWidget ImgScrollerMC;

/** Reference to the left menu. Animation controller. */
var GFxObject MenuMC;

/** Avaiable maps list, provided by the MapInfo DataProvider. */
var array<UTUIDataProvider_MapInfo> MapList;

var int LastSelectedItem;

/** Space for updating and configuring the screen. Currently unused. */
function OnViewLoaded()
{
    Super.OnViewLoaded();
}

/** 
 *  Update the view.  
 *  This method is called whenever the view is pushed or popped from the view stakc.
 */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
    Super.OnTopMostView();
    if (bPlayOpenAnimation)
    {
        MenuMC.GotoAndPlay("open");
        FooterMC.GotoAndPlay("next");
    }

    MenuManager.SetSelectionFocus(ListMC);        
    UpdateListDataProvider();
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ListMC.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

/** 
 *  Save a reference to the selected map to be later used
 *  when launching the game.
 */
function OnMapList_ValueChanged(String InMapSelected, optional string InMapImageSelected = class'GFxUDKFrontEnd_LaunchGame'.const.MarkupForNoMapImage)
{
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedMap>", InMapSelected);
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedMapImage>", InMapImageSelected);
}

/**
 * Provides the ActionScript shadow for this view a reference
 * to the list for any extra configuration.
 */
function SetList(GFxObject List) 
{     
    ActionScriptVoid("setList"); 
}

/** 
 *  Listener for the menu's list "CLIK_itemPress" event. 
 *  When an item is pressed, retrieve the data associated with the item 
 *  and use it to trigger the appropriate function call.
 */
function OnListItemPress(GFxClikWidget.EventData ev)
{
    local int SelectedIndex;
    local String SelectedMapName;
    local String SelectedMapImage;	

    SelectedIndex = ev.index;
    SelectedMapName = MapList[SelectedIndex].MapName;        
    SelectedMapImage = MapList[SelectedIndex].PreviewImageMarkup;

    OnMapList_ValueChanged(SelectedMapName, SelectedMapImage);

    // If the user has made a select, return them to the previous screen.
    MenuManager.PopView();
}

/** 
 *  Creates the data provider for the map list based on the ListOptions array
 *  and passes it to the map list for display. 
 */
function UpdateListDataProvider()
{
    local int i, ListCounter;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    local array<UDKUIResourceDataProvider> ProviderList; 
	local array<UTUIDataProvider_MapInfo> LocalMapList;
        
	// fill the local map list    
	MapList.Length = 0;
    LocalMapList.Length = 0;
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', ProviderList);
	for (i = 0; i < ProviderList.length; i++)
	{		
		LocalMapList.AddItem(UTUIDataProvider_MapInfo(ProviderList[i]));
	}   
    
    // No need to create an object if no maps are available.
    if (LocalMapList.Length == 0)
    {
        return;
    }

    // Use a counter for the current list index so that items that are filtered are not added in
    // the incorrect position.
    ListCounter = 0;
    DataProvider = Outer.CreateArray();              
    for (i = 0; i < LocalMapList.Length; i++)
    {
        if (!LocalMapList[i].ShouldBeFiltered())
        {
            TempObj = CreateObject("Object");
            TempObj.SetString("label", Caps(GetMapFriendlyName(LocalMapList[i].MapName)));                
            TempObj.SetString("players", LocalMapList[i].NumPlayers);

            // If a preview image exists, use that.
            if (LocalMapList[i].PreviewImageMarkup != "")
            {
                TempObj.SetString("image", "img://" $ LocalMapList[i].PreviewImageMarkup);
            }            
            else
            {
				// Otherwise, use a placeholder "UDK" map image.
                TempObj.SetString("image", "img://" $ class'GFxUDKFrontEnd_LaunchGame'.const.MarkupForNoMapImage);
            }
            
            DataProvider.SetElementObject(ListCounter++, TempObj);
			MapList.AddItem(LocalMapList[i]);
        }
    }
    ListMC.SetObject("dataProvider", DataProvider); 
    ListDataProvider = ListMC.GetObject("dataProvider");

    ImgScrollerMC.SetObject("dataProvider", DataProvider);    
    ImgScrollerMC.SetFloat("selectedIndex", ListMC.GetFloat("selectedIndex"));
}

final function SetImgScroller(GFxClikWidget InImgScroller)
{ 
    ActionScriptVoid("setImgScroller");
}

final static function String GetImageMarkupByMapName(String InMapName)
{
	local int i;
	local String bResult;
	local array<UDKUIResourceDataProvider> ProviderList; 
	local array<UTUIDataProvider_MapInfo> LocalMapList;

	`log("GetImageMarkupByName(" @ InMapName @ ")");
	bResult = class'GFxUDKFrontEnd_LaunchGame'.const.MarkupForNoMapImage;

	// Get a list of all available maps.
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', ProviderList);
	for (i = 0; i < ProviderList.Length; i++)
	{		
		LocalMapList.AddItem(UTUIDataProvider_MapInfo(ProviderList[i]));
	}  

	// Find the appropriate map, retrieve its image markup.
	for (i = 0; i < LocalMapList.Length; i++)
	{				
		// Map names from Provider do not match capitalization in .INI files.
		if (Locs(LocalMapList[i].MapName) == Locs(InMapName))
		{			
			if (LocalMapList[i].PreviewImageMarkup != "")
			{
				bResult = LocalMapList[i].PreviewImageMarkup;
			}
		}		
	}

	return bResult;
}

/** UTUIPanel_SingleMap.uc **/

/** @return Returns the current game mode. */
final function name GetCurrentGameMode()
{
	local string GameMode;

	class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedGameMode>", GameMode);

	// strip out package so we just have class name
	return name(Right(GameMode, Len(GameMode) - InStr(GameMode, ".") - 1));
}

/** Sets up a map cycle consisting of 1 map. */
final function SetupMapCycle(string SelectedMap)
{
	local int CycleIdx;
	local name GameMode;
	local UTGame.GameMapCycle MapCycle;

	GameMode = GetCurrentGameMode();
    
	MapCycle.GameClassName = GameMode;
	MapCycle.Maps.length = 1;
	MapCycle.Maps[0] = SelectedMap;
    
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
final function string GetSelectedMap()
{
	local float SelectedItem;	
	local string MapName;    
	
    SelectedItem = ListMC.GetFloat("selectedIndex");
	MapName = MapList[SelectedItem].MapName;
	SetupMapCycle(MapName);

	return MapName;
}

/** Helper function for converting a MapName to a label for list. */
final function string GetMapFriendlyName(string Map)
{
	local int i, p, StartIndex, EndIndex;
	local array<string> LocPieces;

	// try to use a friendly name from the UI if we can find it
	for (i = 0; i < MapList.length; i++)
	{
		if (MapList[i].MapName ~= Map)
		{
			// try to resolve the UI string binding into a readable name
			StartIndex = InStr(Caps(MapList[i].FriendlyName), "<STRINGS:");
			if (StartIndex == INDEX_NONE)
			{
				return MapList[i].FriendlyName;
			}
			Map = Right(MapList[i].FriendlyName, Len(MapList[i].FriendlyName) - StartIndex - 9); // 9 = Len("<STRINGS:")
			EndIndex = InStr(Map, ">");
			if (EndIndex != INDEX_NONE)
			{
				Map = Left(Map, EndIndex);
				ParseStringIntoArray(Map, LocPieces, ".", true);
				if (LocPieces.length >= 3)
				{
					Map = Localize(LocPieces[1], LocPieces[2], LocPieces[0]);
				}
			}
			return Map;
		}
	}

	// just strip the prefix
	p = InStr(Map,"-");
	if (P > INDEX_NONE)
	{
		Map = Right(Map, Len(Map) - P - 1);
	}
	return Map;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
    local bool bWasHandled;
    bWasHandled = false;

    //`log("GFxUDKFrontEnd_MapSelect: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ('list'):  
            if (ListMC == none)
            {
                ListMC = GFxClikWidget(Widget);   
                SetList(ListMC);
                UpdateListDataProvider();

                ListMC.AddEventListener('CLIK_itemPress', OnListItemPress);                             
                ListMC.SetFloat("selectedIndex", 0);                                

                // Setting the Image Scroller needs to occur after the List has been initialized.
                // This is guaranteed based on the order of the layers.
                SetImgScroller(ImgScrollerMC);
				bWasHandled = true;
            }
            break;        
        case ('menu'):
            if (MenuMC == none)
            {
                MenuMC = Widget;
                bWasHandled = true;
            }
            break;
        case ('imgScroller'):
            if (ImgScrollerMC == none)
            {
                ImgScrollerMC = GFxClikWidget(Widget);
                ImgScrollerMC.SetFloat("selectedIndex", 0);
                bWasHandled = true;
            }
            break;
        default:
            break;
    }
	   
	if (!bWasHandled)
	{
		bWasHandled = Super.WidgetInitialized(WidgetName, WidgetPath, Widget); 
	}
    return bWasHandled;
}

defaultproperties
{
	AcceptButtonHelpText="SELECT"
	CancelButtonHelpText="CANCEL"
}