/**********************************************************************

Filename    :   GFxUDKFrontEnd_LaunchGame.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of a front end view which is used to
                configure and launch a game. 

                Associated Flash content: udk_instant_action.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_LaunchGame extends GFxUDKFrontEnd_Screen
    abstract;

/** Reference to the settings datastore that we will use to create the game. */
var transient UIDataStore_OnlineGameSettings	SettingsDataStore;

/** Reference to the stringlist datastore that we will use to create the game. */
var transient UTUIDataStore_StringList	        StringListDataStore;

/** Reference to the menu datastore */
var transient UTUIDataStore_MenuItems MenuDataStore;

/** Default match settings. */
var transient string    DefaultMapName;
var transient string    DefaultGameMode;
var transient string    DefaultGameModeSettings;
var transient string    DefaultMapImage;
var transient string    DefaultGameModePrefixes;

/** Map image for those maps without images defined. */
const MarkupForNoMapImage = "UDKFrontEnd.gm_map_none";

/** Structure which defines a unique game mode. */
struct Option
{
	var string OptionName;
    var string OptionLabel;
    var string OptionDesc;
};

/** Aray of all list options, defined in DefaultUI.ini */
var config array<Option>		ListOptions;

/** Reference to the list. */
var GFxClikWidget ListMC;

/** Reference to the list's dataProvider array in AS. */
var GFxObject ListDataProvider;

/** Reference to the left menu. Animation controller. */
var GFxObject MenuMC;

/** Reference to the map image on the right side. */
var GFxObject MapImageMC;

/** Reference to the textField for the map name on the right side. */
var GFxObject MapNameTxt;

/** Reference to the textField for the game mode name. */
var GFxObject GameTitleTxt;

/** Reference to the textField for the bot difficulty level. */
var GFxObject BotLvlTxt; 

/** Reference to the textField for the number of opponents. */
var GFxObject OpponentsTxt;

/** Reference to the textField for the score limit. */
var GFxObject ScoreTxt;

/** Reference to the textField for the time limit. */
var GFxObject TimeTxt;

/** Reference to the textField for the currently selected map name. */
var GFxObject MapTxt;

/** Reference to the textField for the respawn settings. */
var GFxObject RespawnTxt;

/** Reference to the textField for the mutators enabled/disabled. */
var GFxObject MutatorsTxt;

/** Reference to the textField for the map name label. */
var GFxObject MapLabelTxt;

/** Reference to the textField for the bot level label. */
var GFxObject BotLvlLabelTxt;

/** Reference to the textField for the # of opponents label. */
var GFxObject OpponentsLabelTxt;

/** Reference to the textField for the score limit label. */
var GFxObject ScoreLabelTxt;

/** Reference to the textField for the time limit label. */
var GFxObject TimeLabelTxt;

/** Reference to the textField for the force respawn label. */
var GFxObject RespawnLabelTxt;

/** Reference to the textField for the # mutators enabled label. */
var GFxObject MutatorsLabelTxt;

/** Configures the view when it is first loaded. */
function OnViewLoaded()
{
   	local DataStoreClient DSClient;
    Super.OnViewLoaded();

	// Get the global data store client
	DSClient = class'UIInteraction'.static.GetDataStoreClient();

    // Get a reference to the settings datastore.
    SettingsDataStore = UIDataStore_OnlineGameSettings(DSClient.FindDataStore('UTGameSettings'));
	StringListDataStore = UTUIDataStore_StringList(DSClient.FindDataStore('UTStringList'));

    // Get a reference to the menu datastore
	MenuDataStore = UTUIDataStore_MenuItems(class'UIRoot'.static.StaticResolveDataStore('UTMenuItems'));
}

/** Fired when a view is pushed on to the stack. */
function OnViewActivated()
{
	local bool bFoundDefaultMap;
	local array<UDKUIResourceDataProvider> ProviderList; 
	local int i;

	// make sure default map exists
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', ProviderList);
	for (i = 0; i < ProviderList.length; i++)
	{		
		if ( UDKUIDataProvider_MapInfo(ProviderList[i]).MapName ~= DefaultMapName )
		{
			 bFoundDefaultMap = true;
			 break;
		}
	} 
	if ( !bFoundDefaultMap )
	{
		DefaultMapName = (ProviderList.length > 0 ) ? UDKUIDataProvider_MapInfo(ProviderList[0]).MapName : "";
	}

    // Set defaults 
	SettingsDataStore.SetCurrentByName(name(DefaultGameModeSettings));
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameModePrefix>", DefaultGameModePrefixes);	
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", DefaultGameMode);
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedMap>", DefaultMapName);
    class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedMapImage>", DefaultMapImage);
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ListMC.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

/** 
 *  Updates the view.  
 *  This method is called whenever the view is pushed or popped from the view stakc.
 */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{    
    Super.OnTopMostView(bPlayOpenAnimation);        
    MenuManager.SetSelectionFocus(ListMC);

    UpdateDescription();
    UpdateGameSettingsPanel();
}

/** Plays the view's open animation. */
function PlayOpenAnimation()
{
    MenuMC.GotoAndPlay("open");
    FooterMC.GotoAndPlay("next");
}

/** Plays the view's close animation. */
function PlayCloseAnimation() 
{ 
    MenuMC.GotoAndPlay("close"); 
}

/** Start Game stub, to be overriden by sub-classes. */
function OnStartGame_Confirm();

/** 
 *  Updates the GameSettings Panel on the right side of the view with the 
 *  latest information from the UTGameSettings DataStore.
 */
final function UpdateGameSettingsPanel()
{   
    local ASValue ASVal;
    local array<ASValue> Args;
    local int EnabledMutatorCount;
    local String SelectedMapImage;

    GameTitleTxt.SetText( Caps(GetGameModeFriendlyString(GetStringFromMarkup("<Registry:SelectedGameMode>"))) );
    MapNameTxt.SetText( GetStringFromMarkup("<Registry:SelectedMap>") );

    SelectedMapImage = GetStringFromMarkup("<Registry:SelectedMapImage>");
	SelectedMapImage = (SelectedMapImage != "") ? SelectedMapImage : MarkupForNoMapImage;

    ASVal.Type = AS_String;
	ASVal.s = "img://" $ SelectedMapImage;    
    Args[0] = ASVal;
    MapImageMC.Invoke("loadMovie", Args);    

    BotLvlTxt.SetText( GetStringFromMarkup("<UTGameSettings:BotSkill>") );
    OpponentsTxt.SetText( GetStringFromMarkup("<UTGameSettings:NumBots>") );
    ScoreTxt.SetText( GetStringFromMarkup("<UTGameSettings:GoalScore>") );
    TimeTxt.SetText( GetStringFromMarkup("<UTGameSettings:TimeLimit>") );
    RespawnTxt.SetText( GetStringFromMarkup("<UTGameSettings:ForceRespawn>") );

    EnabledMutatorCount = class'GFxUDKFrontEnd_Mutators'.static.GetNumEnabledMutators();
    MutatorsTxt.SetText( String( EnabledMutatorCount ) );
}

/** 
 *  Listener for the menu's list "CLIK_itemPress" event. 
 *  When an item is pressed, retrieve the data associated with the item 
 *  and use it to trigger the appropriate function call.
 */
function OnListItemPress(GFxClikWidget.EventData ev)
{
    local int SelectedIndex;
    local name Selection;

    SelectedIndex = ev.index;    
    Selection = Name(listOptions[SelectedIndex].OptionName);
    
    switch(Selection)
    {
        case('GameMode'):  
            MenuManager.PushViewByName('GameMode');
            break;
        case('MapSelect'):    
            MenuManager.PushViewByName('MapSelect');
            break;
        case('Settings'):           
            MenuManager.PushViewByName('Settings');
            break;
        case('ServerSettings'):           
            MenuManager.PushViewByName('ServerSettings');
            break;
        case('Mutators'):
            MenuManager.PushViewByName('Mutators');
            break;
        case('StartGame'):
            OnStartGame_Confirm(); 
            break;
        default:
            break;
    }
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

/**
 * Update the info text field with a description of the 
 * currently selected index.
 */
function UpdateDescription()
{
    local int SelectedIndex;
    local String Description;
   
    if (ListMC != none)
    {
        SelectedIndex = ListMC.GetFloat("selectedIndex");
        if (SelectedIndex >= 0)
        {
            Description = ListOptions[SelectedIndex].OptionDesc;
            InfoTxt.SetText(Description);
        }
    }        
}

/** 
 *  Creates the data provider for the options list based on the ListOptions array
 *  and passes it to the list's dataProvider in AS for display. 
 */
function UpdateListDataProvider()
{
    local byte i;
    local GFxObject DataProvider;
    local GFxObject TempObj;

    DataProvider = Outer.CreateArray();
    for (i = 0; i < ListOptions.Length; i++)
    {
        TempObj = CreateObject("Object");
        TempObj.SetString("name", ListOptions[i].OptionName);
        TempObj.SetString("label", ListOptions[i].OptionLabel);
     
        DataProvider.SetElementObject(i, tempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");
}

/** Helper function for Game Mode conversion to friendly String. */
static function String GetGameModeFriendlyString(String InGameMode)
{
    local string RetString;
    switch(InGameMode)
    {
        case ("UTGame.UTDeathmatch"): 
            RetString = "Deathmatch";
            break;
        case ("UTGame.UTTeamGame"):                 
            RetString = "Team Deathmatch";
            break;
        case ("UTGameContent.UTVehicleCTFGame_Content"):
            RetString = "Capture the Flag";
            break;
        default:
            RetString = InGameMode;
            break;
    }

    return RetString;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool bWasHandled;
    bWasHandled = false;

    //`log("GFxUDKFrontEnd_LaunchGame: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ('list'): 
            if (ListMC == none)
            {
                ListMC = GFxClikWidget(Widget);                 
                UpdateListDataProvider();

                ListMC.SetFloat("selectedIndex", ListOptions.Length-1);                
                ListMC.AddEventListener('CLIK_itemPress', OnListItemPress);
                ListMC.AddEventListener('CLIK_change', OnListChange);
                ListMC.AddEventListener('CLIK_focusIn', OnListChange);
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
        case ('map'):
            if (MapNameTxt == none)
            {
                MapNameTxt = Widget;
                bWasHandled = true;
            }
            break;
        case ('gamestats_gamemode'): 
            if (GameTitleTxt == none)
            {
                GameTitleTxt = Widget.GetObject("gamemode");                
                bWasHandled = true;
            }
            break;
        case ('rightside'):            
            if (MapImageMC == none)
            {
                MapImageMC = Widget.GetObject("map");
                bWasHandled = true;
            }
            break;
        case ('bot_lvl'):        
            if (BotLvlTxt == none)
            {
                BotLvlTxt = Widget;  
                bWasHandled = true;
            }
            break;
        case ('opponents'):     
            if (OpponentsTxt == none)
            {
                OpponentsTxt = Widget; 
                bWasHandled = true;
            }
            break;
        case ('score'):         
            if (ScoreTxt == none)
            {
                ScoreTxt = Widget;  
                bWasHandled = true;
            }   
            break;
        case ('time'):          
            if (TimeTxt == none)
            {
                TimeTxt = Widget;  
                bWasHandled = true;
            }
            break;
        case ('respawn'):       
            if (RespawnTxt == none)
            {
                RespawnTxt = Widget;   
                bWasHandled = true;
            }
            break;
        case ('mutators'):      
            if (MutatorsTxt == none)
            {
                MutatorsTxt = Widget;   
                bWasHandled = true;
            }
            break;
        case ('map'):           
            if (MapTxt == none)
            {
                MapTxt = Widget; 
                bWasHandled = true;
            }
            break;
        case ('label1'):           
            if (MapLabelTxt == none)
            {
                MapLabelTxt = Widget; 
                Widget.SetText("MAP");
                bWasHandled = true;
            }
            break;
        case ('label2'):           
            if (BotLvlLabelTxt == none)
            {
                BotLvlLabelTxt = Widget; 
                Widget.SetText("BOT SKILL LVL");
                bWasHandled = true;
            }
            break;
        case ('label3'):           
            if (OpponentsLabelTxt == none)
            {
                OpponentsLabelTxt = Widget; 
                Widget.SetText("OPPONENTS");
                bWasHandled = true;
            }
            break;
        case ('label4'):           
            if (ScoreLabelTxt == none)
            {
                ScoreLabelTxt = Widget; 
                Widget.SetText("SCORE");
                bWasHandled = true;
            }
            break;
        case ('label5'):           
            if (TimeLabelTxt == none)
            {
                TimeLabelTxt = Widget; 
                Widget.SetText("TIME LIMIT");
                bWasHandled = true;
            }
            break;
        case ('label6'):           
            if (RespawnLabelTxt == none)
            {
                RespawnLabelTxt = Widget; 
                Widget.SetText("RESPAWN");
                bWasHandled = true;
            }
            break;
        case ('label7'):      
            if (MutatorsLabelTxt == none)
            {
                MutatorsLabelTxt = Widget; 
                Widget.SetText("ENABLED MUTATORS");
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

/** Static utility function to retrieve a String from a MarkupString. */
static function String GetStringFromMarkup(String MarkupString)
{
    local String RetVal;
    RetVal = "";
    class'UIRoot'.static.GetDataStoreStringValue(MarkupString, RetVal);
    return RetVal;
}

DefaultProperties
{
	DefaultMapName="DM-Deck"
	DefaultGameMode="UTGame.UTDeathmatch"
	DefaultGameModeSettings="UTgameSettingsDM"
    DefaultMapImage="UI_FrontEnd_Art.MapPics.___map-pic-dm-deck"
    DefaultGameModePrefixes="DM"
}