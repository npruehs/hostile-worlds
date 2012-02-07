/**********************************************************************

Filename    :   GFxUDKFrontEnd_SettingsBase.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the base settings view.
                Associated Flash content: udk_settings.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_SettingsBase extends GFxUDKFrontEnd_Screen
    config(UI);

/** Reference to the list. */
var GFxClikWidget ListMC;

var string SelectedOptionSet;

/** Reference to the list's dataProvider array in AS. */
var GFxObject ListDataProvider;

/** Reference to the settings menu. Animation controller. */
var GFxObject MenuMC;

/** List of menu item settings. */
var array<UTUIDataProvider_MenuOption> SettingsList;

/** Reference to the settings datastore that we will use to create the game. */
var transient UIDataStore_OnlineGameSettings	SettingsDataStore;

/** Configures the view when it is first loaded. */
function OnViewLoaded()
{
    Super.OnViewLoaded();
    SettingsDataStore = UIDataStore_OnlineGameSettings(class'UIRoot'.static.StaticResolveDataStore('UTGameSettings'));     	           
}

function OnViewActivated()
{
	Super.OnViewActivated();
	LoadDataFromStore();
}

/**  Update the view.  */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
    Super.OnTopMostView(bPlayOpenAnimation);                   
    UpdateListDataProvider();    
    
    if (ListMC != none)
	{
		MenuManager.SetSelectionFocus(ListMC);    
		ListMC.SetFloat("selectedIndex", 0);
	}

    UpdateDescription();
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ListMC.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

function SetSelectedOptionSet();

/** 
 *  Loads in the appropriate settings options from the MenuItems DataStore.
 *  Parses the data for each settings and populates SettingsList based on the
 *  current state (online vs. offline, game mode, etc...)
 */
function LoadDataFromStore()
{
    local int i, j, k;
    local bool bIsRelevant, bIsDuplicate;
    local string CurrentOptionSet;
    local UTUIDataProvider_MenuOption CurrentOption;
    local array<UDKUIResourceDataProvider> ProviderList;   

    // Clear the previous SettingsList
    SettingsList.Length = 0;
    SetSelectedOptionSet();

    // Populate the list of settings.
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MenuOption', ProviderList);
	for (i = ProviderList.length-1; i > -1 ; i--)
	{
        // Check whether this setting is relevant to the current Option Set. If not, do not display it.
        bIsRelevant = false;
        CurrentOption = UTUIDataProvider_MenuOption(ProviderList[i]);
        for (j = 0; j < CurrentOption.OptionSet.Length; j++)
        {
            CurrentOptionSet = String(CurrentOption.OptionSet[j]);          
            if (CurrentOptionSet == SelectedOptionSet)
            {
                bIsRelevant = true;
                break;
            }
        }
        
        // If the setting is relevant, check that it A. is not a duplicate, B. should not be filtered 
        // out based on platform.
        if (bIsRelevant)
        {	  
            bIsDuplicate = false;
            for (k = 0; k < SettingsList.Length; k++)
            {                    
                // If it has the same data store markup, it is effectively equivalent.
                if (SettingsList[k].DataStoreMarkup == CurrentOption.DataStoreMarkup)
                {
                    bIsDuplicate = true;
                    break;                    
                }
            }

            if (!bIsDuplicate && !CurrentOption.IsFiltered())
            {                
                SettingsList.AddItem(CurrentOption);           
            }
         }   
	}
}

/** 
 *  Back button was pressed/clicked. 
 *	Play the close animation for the view and have the manager pop a view from the stack. 
 *  Saves the state of the Settings view back into the dataStore.
 */
function Select_Back(GFxClikWidget.EventData ev)
{    
    Select_BackImpl();
}

/** Save the data in the view to the backend. */
function SaveState()
{
    local int i;
    local int SelectedIndex;
    local int SettingIndex;
    local String ControlType;
    local String SettingMarkup;
    local GFxObject Data;
    local UTGameSettingsCommon LocalGameSettings;

	LocalGameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());

    for (i = 0; i < SettingsList.Length; i++)
    {        
        Data = ListDataProvider.GetElementObject(i);
        ControlType = Data.GetString("control");
        switch(ControlType)
        {
            case("stepper"):
                SelectedIndex = Data.GetFloat("optIndex");

                // Is this setting a localized setting? If so, its index will return > -1;
                SettingIndex = FindLocalizedSettingIndexByName(SettingsList[i].Name);
                SettingMarkup = SettingsList[i].DataStoreMarkup;                    

                // If the returned localized setting index > -1, save the data appropriately.
                if (SettingIndex > -1)
                {
                    SelectedIndex = LocalGameSettings.LocalizedSettingsMappings[SettingIndex].ValueMappings[SelectedIndex].Id;
                    LocalGameSettings.LocalizedSettings[SettingIndex].ValueIndex = SelectedIndex;
                    class'UIRoot'.static.SetDataStoreStringValue(SettingMarkup, String(SelectedIndex));
                }

                // This setting was not a localized setting, so we hope its a property.
                else 
                {
                    SelectedIndex = Data.GetFloat("optIndex");
                    SettingIndex = FindPropertyIndexByName(SettingsList[i].Name);
                    SettingMarkup = SettingsList[i].DataStoreMarkup;                   

                    // If the returned property index > -1, save the data appropriately.
                    if (SettingIndex > -1)
                    {
                        SelectedIndex = LocalGameSettings.PropertyMappings[SettingIndex].PredefinedValues[SelectedIndex].Value1;
                        class'UIRoot'.static.SetDataStoreStringValue(SettingMarkup, String(SelectedIndex));
                    }                      
                }
                break;
            default:
                break;
        }                     
    }
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
 *  Listener for the menu's list "CLIK_onChange" event. 
 *  When the selectedIndex of the list changes, update the title, description,
 *  and image information using the data from the list.
 */
function OnListChange(GFxClikWidget.EventData ev)
{
    UpdateDescription();
}

function OnOptionChanged(GFxClikWidget.EventData ev);

function UpdateDescription()
{
    local int SelectedIndex;
    local String Description;
   
    if (ListMC != none)
    {
        SelectedIndex = ListMC.GetFloat("selectedIndex");
        if (SelectedIndex >= 0)
        {
            Description = SettingsList[SelectedIndex].Description;
            InfoTxt.SetText(Description);
        }
        else 
        {
            InfoTxt.SetText("");
        }
    }    
}

/**
 * Sets up the list's dataProvider using the data pulled from
 * DefaultUI.ini.
 */
function UpdateListDataProvider();

/** 
 *  Finds the index of this setting in the localized string mappings array
 *  based on the setting's name. The localized string mappings are pulled from UTGame.int.
 *  @todo sf: This method can probably be replaced by something more efficient in Settings.uc
 */
function int FindLocalizedSettingIndexByName(coerce string InSettingName)
{
    local byte i;
    local int StringIndex;
    local UTGameSettingsCommon GameSettings;

	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
    for (i = 0; i < GameSettings.LocalizedSettingsMappings.Length; i++)
    {        
        StringIndex = InStr(InSettingName, String(GameSettings.LocalizedSettingsMappings[i].Name));
        if (StringIndex > -1)
        {
            return i;
        }
    }
    return -1;
}

function OnEscapeKeyPress()
{    
	Select_BackImpl();
}

function Select_BackImpl()
{
	SaveState();

	if (MenuManager != none)
	{
		PlayCloseAnimation();
		MenuManager.PopView();        
	}
}

/** 
 *  Finds the index of this setting in the properties array based on the property's name. 
 *  The localized string mappings are pulled from UTGame.int.
 *  @todo sf: This method can probably be replaced by something more efficient in Settings.uc
 */
function int FindPropertyIndexByName(coerce string InPropertyName)
{
    local byte i;
    local int StringIndex;
    local UTGameSettingsCommon GameSettings;

	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
    for (i = 0; i < GameSettings.PropertyMappings.Length; i++)
    {        
        //`log(String(GameSettings.PropertyMappings[i].Name) @ "vs." @ InPropertyName);
        StringIndex = InStr(InPropertyName, String(GameSettings.PropertyMappings[i].Name));
        if (StringIndex > -1)
        {
            return i;
        }
    }
    return -1;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool bWasHandled;
    bWasHandled = false;

    //`log("GFxUDKFrontEnd_Settings: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ('list'):  
            if (ListMC == none)
            {
                ListMC = GFxClikWidget(Widget);   
                SetList(ListMC);
                UpdateListDataProvider();

                ListMC.SetFloat("selectedIndex", 0);
                ListMC.AddEventListener('CLIK_change', OnListChange);
                ListMC.AddEventListener('CLIK_focusIn', OnListChange);
                ListMC.AddEventListener('CLIK_itemChange', OnOptionChanged);

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
        default:
            break;
    }

	
	if (!bWasHandled)
	{
		bWasHandled = Super.WidgetInitialized(WidgetName, WidgetPath, Widget);    
	}
    return bWasHandled;
}
