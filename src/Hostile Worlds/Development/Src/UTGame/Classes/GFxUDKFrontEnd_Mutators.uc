/**********************************************************************

Filename    :   GFxUDKFrontEnd_Mutators.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of a mutators view for the GFx-UDK 
                front end.

                Associated Flash content: udk_mutators.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_Mutators extends GFxUDKFrontEnd_Screen
    config(UI);

/** The list of all mutators. */
var array<UTUIDataProvider_Mutator> AllMutatorsList;

/** The list of all mutators available based on the game type. */
var array<UTUIDataProvider_Mutator> AvailableMutatorList;

/** Reference to the menu datastore */
var transient UTUIDataStore_MenuItems MenuDataStore;

/** List of currently enabled mutators. */
var array<int> EnabledList;

/** Reference to the list. */
var GFxClikWidget ListMC;

/** Reference to the container MovieClip which controls animations. **/
var GFxObject MenuMC;

/** Reference to the list's AS "dataProvider" array. */
var GFxObject ListDataProvider;

/** Reference to the mutator configuration list. */
var GFxCLIKWidget ConfigListMC;

/** Reference to the mutator configuration list's AS "dataProvider" array. */
var GFxObject ConfigListDataProvider;

/** Bool that informs the list's renderers to force an update to their toggled state. */
var bool bFirstUpdateAfterActivation;

function OnViewLoaded()
{     
    Super.OnViewLoaded();
    
	// Get reference to the menu datastore
	MenuDataStore = UTUIDataStore_MenuItems(class'UIRoot'.static.StaticResolveDataStore('UTMenuItems'));        
}

function OnViewActivated()
{
	local int i;
	local array<UDKUIResourceDataProvider> ProviderList;  
	Super.OnViewActivated();

	/** list of local maps - used to get more friendly names when possible */
	// fill the local map list
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_Mutator', ProviderList);
	AllMutatorsList.Length = 0;
	for (i = 0; i < ProviderList.Length; i++)
	{
		AllMutatorsList.InsertItem(0, UTUIDataProvider_Mutator(ProviderList[i]));        
	}

	bFirstUpdateAfterActivation = true;
	SortAllMutatorsBasedOnOfficialArray();	
}

function SortAllMutatorsBasedOnOfficialArray()
{
	local int MutatorIdx;
	local byte i;
	local String GameModeString;
	local array<UTUIDataProvider_Mutator> TempList;
	
	// Clear SelectedGameMode.
	class'UIRoot'.static.GetDataStoreStringValue("<Registry:SelectedGameMode>", GameModeString);
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", "");

	TempList.Length = 10;
	for (i = 0; i < AllMutatorsList.Length; i++)
	{
		MutatorIdx = MenuDataStore.FindValueInProviderSet('OfficialMutators', 'ClassName', AllMutatorsList[i].ClassName);
		if ( MutatorIdx != INDEX_NONE )
		{
			TempList[MutatorIdx] = AllMutatorsList[i];
		}
	}
	
	AllMutatorsList = TempList;
	class'UIRoot'.static.SetDataStoreStringValue("<Registry:SelectedGameMode>", GameModeString);	
}
/** 
 *  Update the view.  
 *  This method is called whenever the view is pushed or popped from the view stakc.
 */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
    Super.OnTopMostView(bPlayOpenAnimation);    

    UpdateDescription();    
    UpdateListDataProvider();    

    MenuManager.SetSelectionFocus(ListMC);
	ListMC.SetFloat("selectedIndex", 0);
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ListMC.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

/** Plays the view's open animation. */
function PlayOpenAnimation()
{
    MenuMC.GotoAndPlay("open");
    FooterMC.GotoAndPlay("next");
}

/** 
 *  Listener for the menu's list "CLIK_itemPress" event. 
 *  When an item is pressed, retrieve the data associated with the item 
 *  and use it to trigger the appropriate function call.
 */
function OnListItemPress(GFxClikWidget.EventData ev)
{
    local byte SelectedIndex;
	local byte OfficialSelectedIndex;
	local GFxObject MutatorData;	

    SelectedIndex = ev.target.GetFloat("selectedIndex");	
	if (SelectedIndex != INDEX_NONE)
	{
		MutatorData = ListDataProvider.GetElementObject(SelectedIndex);			
		OfficialSelectedIndex = FindMutatorIndexByClass(MutatorData.GetString("class"));		
	}
	
	SetMutatorEnabled(OfficialSelectedIndex);    	
}

/** Finds a mutator in MutatorList by its ClassName property. */
final function byte FindMutatorIndexByClass(string MutatorClass)
{
    local byte MutatorIdx;
    for (MutatorIdx = 0; MutatorIdx < AllMutatorsList.Length; MutatorIdx++)
    {
        if (AllMutatorsList[MutatorIdx].ClassName == MutatorClass)
        {
            return MutatorIdx;
        }
    }
    return INDEX_NONE;
}

/** 
 *  Listener for the menu's list "CLIK_onChange" event. 
 *  When the selectedIndex of the list changes, update the title, description,
 *  and image information using the data from the list.
 */
function OnListChange(GFxClikWidget.EventData ev)
{
    UpdateDescription();

    // @todo sf: data that was changed in mutator config needs to be saved.
    // configuration of a mutator is unimplemented.
    /*
    SetupConfigListDataProvider();
    if (IsCurrentMutatorConfigurable())
    {
        ConfigListMC.SetBool("disabled", false);
    }
    else
    {
        ConfigListMC.SetBool("disabled", true);
    }
    */
}

/**
 * Update the info text field with a description of the 
 * currently selected index.
 */
function UpdateDescription()
{
	local int SelectedIndex;
	local String MutatorClass;
	local String Description;

	if (ListMC != none)
	{
		SelectedIndex = ListMC.GetFloat("selectedIndex");
		if (SelectedIndex >= 0)
		{
			MutatorClass = ListDataProvider.GetElementObject(SelectedIndex).GetString("class");
			SelectedIndex = FindMutatorIndexByClass(MutatorClass);
			Description = AllMutatorsList[SelectedIndex].Description;    
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
function UpdateListDataProvider()
{
    local byte i;    
    local int EnabledIndex;  
	local byte IndexInAllMutatorsList;
    local GFxObject DataProvider;
    local GFxObject TempObj;
	local array<UTUIDataProvider_Mutator> FilteredMutatorList;
	local bool bMutatorEnabled;
   
	// Filter out mutators which should not be displayed based on the game type.
	for (i = 0; i < AllMutatorsList.Length; i++)
	{
        if (AllMutatorsList[i] != none && !AllMutatorsList[i].ShouldBeFiltered())
        {
	        FilteredMutatorList.AddItem(AllMutatorsList[i]);        
        }
	}

	AvailableMutatorList = FilteredMutatorList;
    DataProvider = Outer.CreateArray();
    for (i = 0; i < AvailableMutatorList.Length; i++)
    { 
		TempObj = CreateObject("Object");                        
		TempObj.SetString("label", Caps(AvailableMutatorList[i].FriendlyName));            
		TempObj.SetString("class", AvailableMutatorList[i].ClassName);

		// Get the official index of the mutator and check if it is enabled.
		IndexInAllMutatorsList = AllMutatorsList.Find(AvailableMutatorList[i]);
		EnabledIndex = MenuDataStore.EnabledMutators.Find(IndexInAllMutatorsList); 
		
		bMutatorEnabled = (EnabledIndex != INDEX_NONE);
		TempObj.SetBool("toggled", bMutatorEnabled);
	    DataProvider.SetElementObject(i, TempObj);

		// On first update, force all the item renderers to update their toggled state based
		// on the list on enabled mutators. This is necessary due to the conditions of the
		// item renderer's class (CheckBoxRenderer.as) update for the toggled property.
		TempObj.SetBool("bForceToggledUpdate", bFirstUpdateAfterActivation);
    }

	bFirstUpdateAfterActivation = false;		
    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");
}

/**
 * Sets up the mutator configuration list's dataProvider using data unique
 * to whichever mutator is currently selected.
 */
function UpdateConfigListDataProvider()
{
    //    
}

/** Modifies the enabled mutator array to enable/disable a mutator. */
function SetMutatorEnabled(int MutatorId)
{	
	if(MenuDataStore.EnabledMutators.Find(MutatorId) == INDEX_NONE)
	{
		AddMutatorAndFilterList( MutatorId );
	}
	else if(MenuDataStore.EnabledMutators.Find(MutatorId) != INDEX_NONE)
	{	
		EnabledList.RemoveItem( MutatorId );
		MenuDataStore.EnabledMutators.RemoveItem( MutatorId );
		UpdateListDataProvider();
	}
}

/** Attempts to filter the mutator list to ensure that there are no duplicate groups or mutators enabled that can not be enabled. */
function AddMutatorAndFilterList(int NewMutator)
{
	local bool bFiltered;
    local int EnabledIdx;
	local int MutatorIdx, GroupIdx;    
	local string StringValue;
	local array<string> GroupNames, CompareGroupNames;
	local array<int> FinalItems;

    if (AllMutatorsList[NewMutator] != none)
    {
        StringValue = AllMutatorsList[NewMutator].GroupNames;
        ParseStringIntoArray(StringValue, GroupNames, "|", true);
        //`log("Group Names for this Filter: " @ StringValue);
    }

	// we can only have 1 mutator of a specified group enabled at a time, so filter all of the mutators that are of the group we are currently adding.
	if (GroupNames.Length > 0)
	{
		//`Log("Filtering group: '" $ StringValue $ "'");
		for (MutatorIdx = 0; MutatorIdx < EnabledList.length; MutatorIdx++)
		{
			bFiltered = false;
            EnabledIdx = EnabledList[MutatorIdx];
			ParseStringIntoArray(AllMutatorsList[EnabledIdx].GroupNames, CompareGroupNames, "|", true);
			for (GroupIdx = 0; GroupIdx < GroupNames.length; GroupIdx++)
			{
				if (CompareGroupNames.Find(GroupNames[GroupIdx]) != INDEX_NONE)
				{
					bFiltered = true;
					break;
				}
			}
			
			if (!bFiltered)
			{                
				FinalItems.AddItem(MenuDataStore.EnabledMutators[MutatorIdx]);
			}
		}
	}
	else
	{
		FinalItems = EnabledList;
	}

	// Update final item list.
	FinalItems.AddItem(NewMutator);    
	MenuDataStore.EnabledMutators = FinalItems;
    EnabledList = MenuDataStore.EnabledMutators;

	//ApplyGameModeFilter();
	UpdateListDataProvider();
}

/** @return Returns the current list of enabled mutators, separated by commas. */
static function string GetEnabledMutators()
{
	local string MutatorString;
	local string ClassName;
	local int MutatorIdx;
	local UTUIDataStore_MenuItems LocalMenuDataStore;

	LocalMenuDataStore = UTUIDataStore_MenuItems(class'UIRoot'.static.StaticResolveDataStore('UTMenuItems'));
	for(MutatorIdx = 0; MutatorIdx < LocalMenuDataStore.EnabledMutators.length; MutatorIdx++)
	{
        // @todo sf: How is a ClassName pulled from EnabledMutators, an array of integers?
        //           As a consequence, the mutators that were enabled from the view do not
        //           match the classes pulled down here.
		if(LocalMenuDataStore.GetValueFromProviderSet(  'EnabledMutators', 
		                                                'ClassName', 
		                                                LocalMenuDataStore.EnabledMutators[MutatorIdx], 
		                                                ClassName))
		{
			if(MutatorIdx > 0)
			{
				MutatorString $= ",";
			}

			MutatorString $= ClassName;
		}
	}

	return MutatorString;
}

/** @return Returns the current list of enabled mutators, separated by commas. */
static function int GetNumEnabledMutators()
{
	local UTUIDataStore_MenuItems LocalMenuDataStore;
	LocalMenuDataStore = UTUIDataStore_MenuItems(class'UIRoot'.static.StaticResolveDataStore('UTMenuItems'));
	return LocalMenuDataStore.EnabledMutators.length;	
}

/** Applies the game mode filter to the enabled and available mutator lists. */
static function ApplyGameModeFilter()
{
	local int MutatorIdx;
	local array<int> FinalItems;
	local UTUIDataStore_MenuItems LocalMenuDataStore;
		
	LocalMenuDataStore = UTUIDataStore_MenuItems(class'UIRoot'.static.StaticResolveDataStore('UTMenuItems'));		
	for(MutatorIdx=0; MutatorIdx<LocalMenuDataStore.EnabledMutators.length; MutatorIdx++)
	{
		if(LocalMenuDataStore.IsProviderFiltered('Mutators', LocalMenuDataStore.EnabledMutators[MutatorIdx]) == false)
		{
			FinalItems.AddItem(LocalMenuDataStore.EnabledMutators[MutatorIdx]);
		}
	}

	LocalMenuDataStore.EnabledMutators = FinalItems;
}

/** @return Returns whether or not the current mutator is configurable. */
function bool IsCurrentMutatorConfigurable()
{
	local string ConfigureSceneName;
    local int SelectedIndex;
	local bool bResult;

	bResult = false;

    // Check the UIConfigScene to see whether or not it is configurable.     
    SelectedIndex = ListMC.GetFloat("selectedIndex");
	ConfigureSceneName = AvailableMutatorList[SelectedIndex].UIConfigScene;
    bResult = ConfigureSceneName != "";

	return bResult;
}

/**
 * Provides the ActionScript shadow for this view a reference
 * to the list for any extra configuration.
 */
function SetList(GFxObject List) { ActionScriptVoid("setList"); }

/**
 * Provides the ActionScript shadow for this view a reference
 * to the list for any extra configuration.
 */
function SetConfigList(GFxObject ConfigList) { ActionScriptVoid("setConfigList"); }

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool bWasHandled;
    bWasHandled = false;

    //`log("GFxUDKFrontEnd_GameMode: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ('mutator_list'):  
            if (ListMC == none)
            {                
                ListMC = GFxClikWidget(Widget);  
                SetList(ListMC);
                UpdateListDataProvider();                
                ListMC.SetFloat("selectedIndex", 0);
                ListMC.AddEventListener('CLIK_itemPress', OnListItemPress);
                ListMC.AddEventListener('CLIK_change', OnListChange);
                ListMC.AddEventListener('CLIK_focusIn', OnListChange);                
                bWasHandled = true;
            }
            break;
        case ('mutator_config'):
            if (ConfigListMC == none)
            {                
                ConfigListMC = GFxClikWidget(Widget.GetObject("list", class'GFxObject'));
                if (ConfigListMC != none)
				{
					ConfigListMC.SetBool("disabled", false);
				}
				// This should be added once a configurable mutators implementation has been finished
				// and the AS shadow class supports it.
                //SetConfigList(ConfigListMC);
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