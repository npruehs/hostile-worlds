/**********************************************************************

Filename    :   GFxUDKFrontEnd_GameMode.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the Game Mode selection view.
                Associated Flash content: udk_game_mode.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_GameMode extends GFxUDKFrontEnd_Screen
    config(UI);

/** Reference to the settings datastore that we will use to create the game. */
var transient UIDataStore_OnlineGameSettings	SettingsDataStore;

/** Reference to the stringlist datastore that we will use to create the game. */
var transient UTUIDataStore_StringList	StringListDataStore;

/** Current match settings, used to launch the game. .*/
var transient string GameMode;
var transient string MapName;

/** Reference to the list. */
var GFxClikWidget ListMC;

/** Reference to the list's dataProvider array in AS. */
var GFxObject ListDataProvider;

/** Reference to the left menu. Animation controller. */
var GFxObject MenuMC;

/** Reference to image scroller. Image scroller update is handled by AS. */
var GFxClikWidget ImgScrollerMC;

/** Avaiable maps list, provided by the MapInfo DataProvider. */
var array<UTUIDataProvider_GameModeInfo> GameModeList;

/** Configures the view when it is first loaded. */
function OnViewLoaded()
{
    local byte i;
    local DataStoreClient DSClient;
    local array<UDKUIResourceDataProvider> ProviderList;   
    Super.OnViewLoaded();

	// get the global data store client
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
    
	// Get reference to the menu datastore
	//MenuDataStore = UTUIDataStore_MenuItems(class'UIRoot'.static.StaticResolveDataStore('UTMenuItems'));

    SettingsDataStore = UIDataStore_OnlineGameSettings(DSClient.FindDataStore('UTGameSettings'));
	StringListDataStore = UTUIDataStore_StringList(DSClient.FindDataStore('UTStringList'));
        
	// fill the local game mode list
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_GameModeInfo', ProviderList);
	for (i = 0; i < ProviderList.Length; i++)
	{
	    GameModeList.InsertItem(0, UTUIDataProvider_GameModeInfo(ProviderList[i]));        
	}
}

/** 
 *  Update the view.  
 *  This method is called whenever the view is pushed or popped from the view stakc.
 */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
    Super.OnTopMostView(bPlayOpenAnimation);

    MenuManager.SetSelectionFocus(ListMC);
    UpdateDescription();
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ListMC.SetBool("disabled", bDisableComponents);    
    BackBtn.SetBool("disabled", bDisableComponents);
}

/** 
 *  Save a reference to the selected game mode to be later used
 *  when launching the game.
 */
final function OnGameModeSelected(string InGameMode, string InDefaultMap, optional string InGameSettingsClass = "")
{
	local String MapImageMarkup;

	GameMode = InGameMode;
	MapName = InDefaultMap;

	// Set the game settings object to use    
	SettingsDataStore.SetCurrentByName(name(InGameSettingsClass));

	// Retrieve the default map's image markup.
	MapImageMarkup = class'GFxUDKFrontEnd_MapSelect'.static.GetImageMarkupByMapName(InDefaultMap);

	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", InGameMode);
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedMap>", InDefaultMap);    
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedMapImage>", MapImageMarkup);

	class'GFxUDKFrontEnd_Mutators'.static.ApplyGameModeFilter();    	
}

final function OnGameModeChange(int SelectedIndex)
{
	local string LocalGameMode;
	local string DefaultMap;
	local string Prefixes;
	local string GameSettingsClass;

    LocalGameMode = GameModeList[SelectedIndex].GameMode;
    DefaultMap = GameModeList[SelectedIndex].DefaultMap;
    Prefixes = GameModeList[SelectedIndex].Prefixes;
    GameSettingsClass = GameModeList[SelectedIndex].GameSettingsClass;
   
	`log("OnGameModeChange: " $ LocalGameMode $ ", DefaultMap: " $ DefaultMap $ ", " $ GameSettingsClass $ ", " $ Prefixes);
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameModePrefix>", Prefixes);		
	OnGameModeSelected(LocalGameMode, DefaultMap, GameSettingsClass);		
}

/** 
 *  Listener for the menu's list "CLIK_itemPress" event. 
 *  When an item is pressed, retrieve the data associated with the item 
 *  and use it to trigger the appropriate function call.
 */
function OnListItemPress(GFxClikWidget.EventData ev)
{
    local int SelectedIndex;

    SelectedIndex = ev.index;    
    OnGameModeChange(SelectedIndex);

    MenuManager.PopView();
}

/** 
 *  Listener for the menu's list "CLIK_onChange" event. 
 *  When the selectedIndex of the list changes, update the title, description,
 *  and image information using the data from the list.
 */
function OnListChange(GFxClikWidget.EventData ev)
{
    UpdateDescription();
}

/** Updates the description textField based on the selected map's data. */
function UpdateDescription()
{
	local int SelectedIndex;
    local String Description;      

    SelectedIndex = ListMC.GetFloat("selectedIndex");
    Description = ""; 
	
	if (SelectedIndex >= 0 && SelectedIndex < GameModeList.Length)
	{	
		Description = GameModeList[SelectedIndex].Description;        
	}

    InfoTxt.SetText(Description);
}

/**
 * Sets up the list's dataProvider using the data pulled from
 * DefaultUI.ini.
 */
function UpdateListDataProvider()
{
    local byte i;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    local String    FriendlyGameModeName;

    DataProvider = Outer.CreateArray();
    for (i = 0; i < GameModeList.Length; i++)
    {
        TempObj = CreateObject("Object");

        FriendlyGameModeName  = class'GFxUDKFrontEnd_LaunchGame'.static.GetGameModeFriendlyString(GameModeList[i].GameMode);
        TempObj.SetString("label", Caps(FriendlyGameModeName));
        TempObj.SetString("image", "img://"$GameModeList[i].PreviewImageMarkup);

        // Hack to avoid displaying undefined textField below image.
        TempObj.SetString("players", "");
     
        DataProvider.SetElementObject(i, TempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");
    ListMC.SetFloat("selectedIndex", 0);    

    ListMC.AddEventListener('CLIK_itemPress', OnListItemPress);
    ListMC.AddEventListener('CLIK_change', OnListChange);

    ImgScrollerMC.SetObject("dataProvider", DataProvider);
    ImgScrollerMC.SetFloat("selectedIndex", 0);
}

/** Updates the layout of all views in MenuManager.as view stack. */
final function SetImgScroller(GFxClikWidget InImgScroller) 
{ 
    ActionScriptVoid("setImgScroller");
}

/**
 * Provides the ActionScript shadow for this view a reference
 * to the list for any extra configuration.
 */
function ASSetList(GFxObject List) 
{     
    ActionScriptVoid("setList"); 
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    //`log("GFxUDKFrontEnd_GameMode: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    super.WidgetInitialized(WidgetName, WidgetPath, Widget);
    switch(WidgetName)
    {
        case ('list'):  
            if (ListMC == none)
            {
                ListMC = GFxClikWidget(Widget);   
                ASSetList(ListMC);
                UpdateListDataProvider();

                // Setting the Image Scroller needs to occur after the List has been initialized.
                // This is guaranteed based on the order of the layers.
				ListMC.AddEventListener('CLIK_focusIn', OnListChange);
                SetImgScroller(ImgScrollerMC);
                return true;
            }
            break;  
        case ('menu'):            
            MenuMC = Widget;
            return true;
            break;
        case ('imgScroller'):
            ImgScrollerMC = GFxClikWidget(Widget);
            return true;
            break;
        default:
            break;
    }

    return false;
}

defaultproperties
{
	AcceptButtonHelpText="SELECT"
	CancelButtonHelpText="CANCEL"
}