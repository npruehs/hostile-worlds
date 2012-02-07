/**********************************************************************

Filename    :   GFxUDKFrontEnd_Settings.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the Settings view.
                Associated Flash content: udk_settings.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_Settings extends GFxUDKFrontEnd_SettingsBase
    config(UI);

function SetSelectedOptionSet()
{
    // Check which Game Mode / Option Set is currently set. This is used as a filter for the settings.
    SelectedOptionSet = "";
    class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedGameModePrefix>", SelectedOptionSet);	
	if (SelectedOptionSet == "")
	{
        SelectedOptionSet = "DM";
	}
}

/**
 * Sets up the list's dataProvider using the data pulled from
 * DefaultUI.ini.
 */
function UpdateListDataProvider()
{
    local byte i;

    local string DefaultValue;
    local int DefaultIndex;
    local GFxObject RendererDataProvider;
    local GFxObject DataProvider;
    local GFxObject TempObj;
    
    DataProvider = Outer.CreateArray();
    for (i = 0; i < SettingsList.Length; i++)
    {
        // Create a AS object to hold the data for SettingsList[i].
        TempObj = CreateObject("Object");           

        // Parse SettingsList[i] into TempObj.
        TempObj.SetString("label", Caps(SettingsList[i].FriendlyName));
        TempObj.SetString("control", "stepper"); //SettingsList[i].OptionType);        

        RendererDataProvider = Outer.CreateArray();
        PopulateOptionDataProviderForIndex(i, RendererDataProvider, DefaultValue, DefaultIndex);
		
        TempObj.SetBool("bUpdateFromUnreal", true);
        TempObj.SetObject("dataProvider", RendererDataProvider);  

        // Set a default index for the option stepper.
        TempObj.SetFloat("optIndex", DefaultIndex);

        TempObj.SetBool("bNumericCombo", SettingsList[i].bNumericCombo);
        TempObj.SetBool("bEditableCombo", SettingsList[i].bEditableCombo);
        TempObj.SetFloat("editBoxMaxLength", SettingsList[i].EditBoxMaxLength);
   
        DataProvider.SetElementObject(i, TempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");
}

function PopulateOptionDataProviderForIndex(const int Index, out GFxObject OutDataProvider, out string OutDefaultValue, out int OutDefaultIndex)
{   
    local int i;
    local UTGameSettingsCommon GameSettings;
    local int SettingIndex;

	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
    OutDefaultIndex = 0;

    // Create a dataProvider for the embedded component.
    
    // Check if this setting has associated localized labels.
    SettingIndex = FindLocalizedSettingIndexByName(SettingsList[Index].Name);
    if (SettingIndex > -1)
    {
        // If it does, use those localized strings as the labels for the control.
        for (i = 0; i <  GameSettings.LocalizedSettingsMappings[SettingIndex].ValueMappings.Length; i++)
        {
            OutDataProvider.SetElementString(i, String(GameSettings.LocalizedSettingsMappings[SettingIndex].ValueMappings[i].Name));
        }
        OutDefaultIndex = GameSettings.LocalizedSettings[SettingIndex].ValueIndex;
    }

    // If it has no associated localized labels, search GameSetting's properties array instead.
    else
    {
        SettingIndex = FindPropertyIndexByName(SettingsList[Index].Name);   
        //`log("FindPropertyIndexByName: " @ SettingsList[i].Name @ " :: " @ SettingIndex);
        OutDefaultValue = String(GameSettings.Properties[SettingIndex].Data.Value1);
        for (i = 0; i <  GameSettings.PropertyMappings[SettingIndex].PredefinedValues.Length; i++)
        {
            if (OutDefaultValue == String(GameSettings.PropertyMappings[SettingIndex].PredefinedValues[i].Value1))
            {
                OutDefaultIndex = i;
            }
            //`log(j @ ": " @ String(GameSettings.PropertyMappings[SettingIndex].PredefinedValues[j].Value1));
            OutDataProvider.SetElementString(i, String(GameSettings.PropertyMappings[SettingIndex].PredefinedValues[i].Value1));
        }            
    }
}


