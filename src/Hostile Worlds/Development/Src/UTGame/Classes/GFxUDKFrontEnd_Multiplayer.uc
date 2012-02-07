/**********************************************************************

Filename    :   GFxUDKFrontEnd_Multiplayer.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of a multiplayer view for the GFx-UDK 
                front end.

                Associated Flash content: udk_multiplayer.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_Multiplayer extends GFxUDKFrontEnd_Screen
    config(UI);

/** Structure which defines a unique list option. */
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
    UpdateDescription();
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    ListMC.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

/** 
 *  Pushes the Join Game view on to the stack. This method is fired
 *  by the list's OnListItemPress() listener.
 */
function Select_JoinGame()
{    
    if ( MenuManager.CheckLinkConnectionAndError() )
	{
        MenuManager.PushViewByName('JoinGame');        
	}
}

/** 
 *  Pushes the Host Game view on to the stack. This method is fired
 *  by the list's OnListItemPress() listener.
 */
function Select_HostGame()
{    
    if ( MenuManager.CheckLinkConnectionAndError() )
    {
        MenuManager.PushViewByName('HostGame');
    }
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

    SelectedIndex = ListMC.GetFloat("selectedIndex");
    Selection = Name(ListDataProvider.GetElementMemberString(SelectedIndex, "name"));
    
    switch(Selection)
    {
        case('JoinGame'):  
            Select_JoinGame(); 
            break;
        case('HostGame'):    
            Select_HostGame();   
            break;
        default:
            break;
    }
}

/** 
 *  Listener for the menu's list "CLIK_onChange" event. 
 *  When the selectedIndex of the list changes, update the title, description,
 *  and information using the data from the list.
 */
function OnListChange(GFxClikWidget.EventData ev)
{
    UpdateDescription();
}

function UpdateDescription()
{
    local int SelectedIndex;
    local String Description;
   
    SelectedIndex = ListMC.GetFloat("selectedIndex");
    Description = ListOptions[SelectedIndex].OptionDesc;
    
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

    DataProvider = Outer.CreateArray();
    for (i = 0; i < ListOptions.Length; i++)
    {
        TempObj = CreateObject("Object");
        TempObj.SetString("name",	ListOptions[i].OptionName);
        TempObj.SetString("label",	ListOptions[i].OptionLabel);
        TempObj.SetString("desc",	ListOptions[i].OptionDesc);
     
        DataProvider.SetElementObject(i, TempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");
    ListMC.SetFloat("selectedIndex", 0);
    ListMC.AddEventListener('CLIK_itemPress', OnListItemPress);
    ListMC.AddEventListener('CLIK_change', OnListChange);
}

/**
 * Passes a reference to the list back to the AS View implementation.
 */
function SetList(GFxObject InList) 
{     
    ActionScriptVoid("setList"); 
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    local bool bWasHandled;
    bWasHandled = false;

    //`log("UTUIDataStore_Multiplayer: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);  
    switch(WidgetName)
    {
        case ('list'):  
            ListMC = GFxClikWidget(Widget);   
            SetList(ListMC);
            UpdateListDataProvider();
            bWasHandled = true;
            break;
        case ('menu'):            
            MenuMC = Widget;
            bWasHandled = true;
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

}