/**********************************************************************

Filename    :   GFxUDKFrontEnd_JoinDialog.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Base class for a dialog for the GFx-UDK front end.             

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_JoinDialog extends GFxUDKFrontEnd_Dialog
    config(UI);

var GFxClikWidget ServerInfoListMC;
var GFxClikWidget MutatorListMC;
var GFxClikWidget JoinBtn;
var GFxClikWidget SpectateBtn;

/** 
 *  Update the view.  
 *  Called whenever the view becomes the topmost view on the viewstack. 
 */
function OnTopMostView(optional bool bPlayOpenAnimation = FALSE)
{
    if (MenuManager != none)
    {
        MenuManager.SetSelectionFocus(JoinBtn);
    }

    BackBtn.SetString("label", "BACK");   
    BackBtn.RemoveAllEventListeners("CLIK_press");
    BackBtn.RemoveAllEventListeners("press");
    BackBtn.AddEventListener('CLIK_press', Select_Back);
}

function DisableSubComponents(bool bDisableComponents)
{
    AcceptBtn.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

function PopulateServerInfo(OnlineGameSettings GameSettings)
{
    local byte i, DPArrayIndex;
    local int CurrentPlayers, MaxPlayers;
    local string PlayersString;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    local array<ASValue> args;
    local ASValue ASVal;      
    local UTGameSettingsCommon UTGameSettings;

    local int Index;
    local int SettingId, PropertyId;
    local String SettingValue, SettingName;
    local String PropertyValue, PropertyName;
    
    DPArrayIndex = 0;
    
    // Set the title of the window to the name of the server.
    TitleTxt.SetText(GameSettings.OwningPlayerName);    
    UTGameSettings = UTGameSettingsCommon(GameSettings);
   
    DataProvider = Outer.CreateArray();

    // Players
    TempObj = CreateObject("Object");
    TempObj.SetString("label",  "PLAYERS");        
    
    CurrentPlayers = GameSettings.NumPublicConnections - GameSettings.NumOpenPublicConnections;
    MaxPlayers = GameSettings.NumPublicConnections;
    PlayersString = CurrentPlayers $ "/" $ MaxPlayers;

    TempObj.SetString("value",  PlayersString);
    DataProvider.SetElementObject(DPArrayIndex++, TempObj);

    // Ping 
    TempObj = CreateObject("Object");
    TempObj.SetString("label",  "PING");        
    TempObj.SetString("value",  String(GameSettings.PingInMs));
    DataProvider.SetElementObject(DPArrayIndex++, TempObj);

    // MatchQuality
    TempObj = CreateObject("Object");
    TempObj.SetString("label",  "MATCH QUALITY");        
    TempObj.SetString("value",  String(GameSettings.MatchQuality));
    DataProvider.SetElementObject(DPArrayIndex++, TempObj);
    
    // Populate the rest of the server info from the UTGameSettings
    for ( i = 0; i < UTGameSettings.PropertyMappings.Length; i++ )
    {         
        PropertyId = UTGameSettings.Properties[i].PropertyId;
        if (PropertyId == PROPERTY_GOALSCORE || PropertyId == PROPERTY_TIMELIMIT || PropertyId == PROPERTY_NUMBOTS)
        {        
            TempObj = CreateObject("Object");
            PropertyName = Caps(String(UTGameSettings.PropertyMappings[i].Name));
            PropertyValue = String(UTGameSettings.Properties[i].Data.Value1);
            TempObj.SetString("label", PropertyName);
            TempObj.SetString("value", PropertyValue);           
            DataProvider.SetElementObject(DPArrayIndex++, TempObj);
        }
    }

    for ( i = 0; i < UTGameSettings.LocalizedSettings.Length; i++ )
    {         
        SettingId = UTGameSettings.LocalizedSettings[i].Id;
        if (SettingId != CONTEXT_ALLOWKEYBOARD_NO && SettingId != CONTEXT_ALLOWKEYBOARD_NO && 
            SettingId != CONTEXT_FULLSERVER && SettingId != CONTEXT_EMPTYSERVER)
        {
            TempObj = CreateObject("Object");
            Index = UTGameSettings.LocalizedSettings[i].ValueIndex;
            SettingName = Caps(String(UTGameSettings.LocalizedSettingsMappings[i].Name));
            SettingValue = String(UTGameSettings.LocalizedSettingsMappings[i].ValueMappings[Index].Name);
            TempObj.SetString("label", SettingName);
            TempObj.SetString("value", SettingValue);            
            DataProvider.SetElementObject(DPArrayIndex++, TempObj);
        }
    }

    // bAllowJoinViaPresenceFriendsO... bAllowJoinViaPresenceFriendsOnly
    // GameState
    // MatchQuality MatchQuality
    // Bot Skill
    // Vs Bots
    // Forced Respawn
    // Frags Limit
    // Time LImit
    // bAntiCheatProtected
    
      /*
        LatestGameSearch.Results[i].GameSettings.bIsDedicated);
        //`log("Results["$i$"]: Ping: " @ LatestGameSearch.Results[i].GameSettings.PingInMs);
        //`log("LatestGameSearchCfg: SearchName: " @ LatestGameSearchCfg.Name);     
        //`log("LatestGameSearchCfg: GameSearchClass: " @ LatestGameSearchCfg.GameSearchClass);
        //`log("LatestGameSearchCfg: DefaultGameSettingsClass: " @ LatestGameSearchCfg.DefaultGameSettingsClass);
        //`log("LatestGameSearchCfg: SearchResultsProviderClass: " @ LatestGameSearchCfg.SearchResultsProviderClass);
        //`log("LatestGameSearchCfg: Search: " @ LatestGameSearchCfg.Search);
        //`log("LatestGameSearchCfg: SearchResults[0]: " @ LatestGameSearchCfg.SearchResults[0]); 
        
        TempObj = CreateObject("Object");
        TempObj.SetString("label",        LatestGameSearch.Results[i].GameSettings.OwningPlayerName);        
        TempObj.SetString("value",       (LatestGameSearch.Results[i].GameSettings.NumPublicConnections-LatestGameSearch.Results[i].GameSettings.NumOpenPublicConnections));
        TempObj.SetFloat("MaxPlayers",    LatestGameSearch.Results[i].GameSettings.NumPublicConnections);
        //TempObj.SetFloat("Ping",           LatestGameSearch.Results[i].GameSettings.PingInMs);
        //TempObj.SetBool("bIsLocked",        LatestGameSearch.Results[i].GameSettings. Locked);
        
        //CurrentSearchResult = UTUIDataProvider_SearchResult(SearchDataStore.ServerDetailsProvider.GetSearchResultsProvider());
        
        //CurrentSearchResult.GetDataStoreValue( CurrentSearchResult.GameModeFriendlyNameTag, GameModeFriendlyName);
        //CurrentSearchResult.GetFieldValue(String(CurrentSearchResult.ServerFlagsTag), ServerFlags);
        //CurrentSearchResult.GetFieldValue(String(CurrentSearchResult.MapNameTag), MapName);
        //CurrentSearchResult.GetProviderFieldType( CurrentSearchResult.PlayerRatioTag, PlayerRatio );
        //CurrentSearchResult.GetFieldValue( String(CurrentSearchResult.PlayerRatioTag), PlayerRatio );          
    }
    */

    ServerInfoListMC.SetObject("dataProvider", DataProvider);  

    ASVal.Type = AS_String;
    ASVal.s = "";
    Args[0] = ASVal;

    ServerInfoListMC.Invoke("validateNow", args);
}

function SetJoinButtonPress(delegate<GFxClikWidget.EventListener> JoinButtonListener)
{    
    JoinBtn.RemoveAllEventListeners("CLIK_press");
    JoinBtn.RemoveAllEventListeners("press");
    JoinBtn.AddEventListener('CLIK_press', JoinButtonListener);
}

function SetSpectateButtonPress(delegate<GFxClikWidget.EventListener> SpectateButtonListener)
{
    SpectateBtn.RemoveAllEventListeners("CLIK_press");
    SpectateBtn.RemoveAllEventListeners("press");
    SpectateBtn.AddEventListener('CLIK_press', SpectateButtonListener);
}
         
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool bWasHandled;
    bWasHandled = false;

    //`log("GFxUDKFrontEnd_JoinDialog: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    bWasHandled = Super.WidgetInitialized(WidgetName, WidgetPath, Widget);    
    if (bWasHandled)
    {
        return true;
    }

    switch(WidgetName)
    {
        case ('serverinfo_label'):
            Widget.SetText("SERVER INFO");
            return true;
            break;
        case ('serverinfo_list'):
            if (ServerInfoListMC == none)
            {
                ServerInfoListMC = GFxClikWidget(Widget);
                return true;
            }
            break;
        case ('mutatorinfo_label'):
            Widget.SetText("MUTATORS");
            return true;
            break;   
        case ('mutatorinfo_list'):
            if (MutatorListMC == none)
            {
                MutatorListMC = GFxClikWidget(Widget);
                return true;
            }
            break;
        case ('join'):
            JoinBtn = GFxClikWidget(Widget.GetObject("btn", class'GFxClikWidget'));            
            JoinBtn.SetString("label", "JOIN GAME");
            return true;
            break;
        case ('spectate'):                       
            SpectateBtn = GFxClikWidget(Widget.GetObject("btn", class'GFxClikWidget'));
            SpectateBtn.SetString("label", "SPECTATE");
            return true;
            break;
        default:
            break;
    }

    return false;
}