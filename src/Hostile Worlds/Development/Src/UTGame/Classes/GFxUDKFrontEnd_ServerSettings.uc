/**********************************************************************

Filename    :   GFxUDKFrontEnd_ServerSettings.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the Settings view.
                Associated Flash content: udk_settings.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_ServerSettings extends GFxUDKFrontEnd_SettingsBase
    config(UI);

var bool bDataChangedByReqs;

/** Defines the set of data/options which we will retrieved for this view. */
function SetSelectedOptionSet()
{
    SelectedOptionSet = "Server";
}

/** 
 *  When a server setting changes, update all of the server settings and force any
 *  changes which are required including ensuring that Max/Min # players do not conflict.
 */
function OnOptionChanged(GFxClikWidget.EventData ev)
{     
    local string OptionName;
    local UTGameSettingsCommon GameSettings;    
    
	`log("OnOptionChanged()");

	// Setup server options based on server type.
	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());       
    OptionName = String(SettingsList[ev.index].Name);    
    bDataChangedByReqs = false;

	if ( OptionName=="MaxPlayers_PC" || OptionName=="MaxPlayers_Console" || OptionName=="PrivateSlots" 
			|| OptionName=="MinNumPlayers_PC" || OptionName=="MinNumPlayers_Console")
	{        
        SaveState();
		        
		if(GameSettings.MaxPlayers < GameSettings.NumPrivateConnections)
		{            
			GameSettings.NumPrivateConnections = GameSettings.MaxPlayers;            
            bDataChangedByReqs = true;
		}

		if(GameSettings.MinNetPlayers > GameSettings.MaxPlayers)
		{
			GameSettings.MinNetPlayers = GameSettings.MaxPlayers;                   
            bDataChangedByReqs = true;
		}     

        SaveState();
	}   
    
    if ( bDataChangedByReqs )
    {
        UpdateListDataProvider(); 
    }
}

/** Saves the state of the settings to the GameSettings object. */
function SaveState()
{
    local int i;

    local int PropertyIndex;
    local int StepperSelectedIndex;
    local String ValueToSave;
    local String ControlType;
    local String SettingMarkup;
    //local String SettingReturn;
    local String SettingName;
    local GFxObject Data;

    local UTGameSettingsCommon LocalGameSettings;
	LocalGameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());    

    for (i = 0; i < SettingsList.Length; i++)
    {   
        // Retrieve the data at the index from the list's dataProvider.
        Data = ListDataProvider.GetElementObject(i);

        // Check what type of control we're dealing with.
        ControlType = Data.GetString("control");
        switch(ControlType)
        {
            case("stepper"):                                
                // Retrieve the name for this setting to retrieve its index.
                SettingName = Data.GetString("name");

                // Retrieve the index in the PropertyMappings array for this Setting.                
                LocalGameSettings.GetPropertyId(Name(SettingName), PropertyIndex);                

                // Retrieve the selectedIndex for this optionStepper.
                StepperSelectedIndex = Data.GetFloat("optIndex");   

                // Retrieve the value that should be saved.
                ValueToSave = Data.GetObject("dataProvider").GetElementString(StepperSelectedIndex);

                if (bDataChangedByReqs)
                {                    
                    if ( SettingName == "MaxPlayers_PC" || SettingName == "MaxPlayers_Console" )
                    {
                        ValueToSave = String(LocalGameSettings.MaxPlayers);
                    }
                    else if ( SettingName == "MinNumPlayers_PC" || SettingName == "MinNumPlayers_Console" )
                    {
                        ValueToSave = String(LocalGameSettings.MinNetPlayers);
                    }
                }

                if ( SettingName == "MaxPlayers_PC" || SettingName == "MaxPlayers_Console" )
                {
                    LocalGameSettings.MaxPlayers = Int(ValueToSave);
                }
                else if ( SettingName == "MinNumPlayers_PC" || SettingName == "MinNumPlayers_Console" )
                {
                    LocalGameSettings.MinNetPlayers = Int(ValueToSave);
                }                

                SettingsList[i].RangeData.CurrentValue = Int(ValueToSave);
                SettingMarkup = SettingsList[i].DataStoreMarkup;      
                class'UIRoot'.static.SetDataStoreStringValue(SettingMarkup, ValueToSave); 
                break;
            
            case("input"):
                
                SettingName = StrinG(SettingsList[i].Name);
                ValueToSave = Data.GetString("text");
                SettingMarkup = SettingsList[i].DataStoreMarkup;
                class'UIRoot'.static.SetDataStoreStringValue(SettingMarkup, ValueToSave);
                if ( SettingName == "ServerDescription" )
                {
                    class'UIRoot'.static.SetDataStoreStringValue("<UTGameSettings:ServerDescription>", ValueToSave);
                }
                break;
            default:
                break;
        }
    }
}



/** Updates the list's dataProvider. */
function UpdateListDataProvider()
{
    local byte i;
    local string ControlType;
    local string DefaultValue;
    local int DefaultIndex;
    local GFxObject RendererDataProvider;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    
    DataProvider = Outer.CreateArray();
    for ( i = 0; i < SettingsList.Length; i++)
    {        
        // Create a AS object to hold the data for SettingsList[i].
        TempObj = CreateObject("Object");              

        // We need to keep track of the name so that we can update Min/Max players
        // if they are changed and become conflicting. OnSettingListChange will be
        // fired by the list, which will check which control fired the event and
        // update both steppers if one of them is the source.
        TempObj.SetString("name", String(SettingsList[i].Name));

        // Parse SettingsList[i] into TempObj.
        TempObj.SetString("label", Caps(SettingsList[i].FriendlyName));

        ControlType = FindControlByUTClassName(SettingsList[i].OptionType);
        TempObj.SetString("control", ControlType);    

        if (ControlType == "stepper")
        {
            RendererDataProvider = Outer.CreateArray();            
            if ( String(SettingsList[i].Name) == "ServerType" )
            {				
                DefaultValue = class'GFxUDKFrontEnd_LaunchGame'.static.GetStringFromMarkup(SettingsList[i].DataStoreMarkup);      				
                RendererDataProvider.SetElementString(0, DefaultValue);
                TempObj.SetBool("controlDisabled", true);				
            }       
			else 
			{
				PopulateOptionDataProviderForIndex(i, RendererDataProvider, DefaultValue, DefaultIndex);             
			}

            // Set the dataProvider and the selectedIndex for the embeddedOptionStepper control.
			TempObj.SetBool("bUpdateFromUnreal", true);
            TempObj.SetObject("dataProvider", RendererDataProvider);  
            TempObj.SetFloat("optIndex", DefaultIndex);
        }
        
        DefaultValue = class'GFxUDKFrontEnd_LaunchGame'.static.GetStringFromMarkup(SettingsList[i].DataStoreMarkup);
        TempObj.SetString("text", DefaultValue);
        TempObj.SetBool("bNumericCombo", SettingsList[i].bNumericCombo);
        TempObj.SetBool("bEditableCombo", SettingsList[i].bEditableCombo);
        TempObj.SetFloat("editBoxMaxLength", SettingsList[i].EditBoxMaxLength);   
        DataProvider.SetElementObject(i, TempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");

}

/** 
 *  Populates a dataProvider with option data based on the list retrieved using LoadDataFromDataStore().
 *  Requires the index of the dataSet, a GFxObject to populate with data, and a defaultIndex / defaultString
 */
function PopulateOptionDataProviderForIndex(const int Index, out GFxObject OutDataProvider, out string OutDefaultValue, out int OutDefaultIndex)
{   
    local int i, j;    
    local UTUIDataProvider_MenuOption CurrentSetting;

	CurrentSetting = SettingsList[Index];
    OutDefaultIndex = 0;            
   
    j = 0;
    for (i = CurrentSetting.RangeData.MinValue; i < CurrentSetting.RangeData.MaxValue; i = i + CurrentSetting.RangeData.NudgeValue)
    {
        OutDataProvider.SetElementString(j, String(i));
        if (i == CurrentSetting.RangeData.CurrentValue)
        {
            OutDefaultIndex = j;
        }
        j++;
    }
}

/** Converts the class name for a UTUIObject to a name that can be handled by AS class for the list's itemRenderers. */
function string FindControlByUTClassName(byte UTUIControlClass)
{
    switch(UTUIControlClass)
    {
        case (UTOT_Slider):
            return "stepper";
            break;
        
        case (UTOT_EditBox):
            return "input";
            break;

        default:
            return "stepper";
            break;
    }
}