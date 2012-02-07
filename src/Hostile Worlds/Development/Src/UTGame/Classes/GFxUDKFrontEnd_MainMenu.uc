/**********************************************************************

Filename    :   GFxUDKFrontEnd_MainMenu.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of a main menu for the GFx-UDK front end.

                Associated Flash content: udk_main_menu.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_MainMenu extends GFxUDKFrontEnd_Screen
    config(UI);

/** Structure which defines a unique game mode. */
struct Option
{
	var string OptionName;
    var string OptionLabel;
    var string OptionDesc;
};

/** Aray of all list options, defined in DefaultUI.ini */
var config array<Option> ListOptions;

/** Reference to the list. */
var GFxClikWidget ListMC;

/** Reference to the list's dataProvider array in AS. */
var GFxObject ListDataProvider;

/** Reference to the "USER" label at the bottom right. Label for username textField. */
var GFxObject UserLabelTxt;

/** Reference to the User Name textField.  This only appears if the user is properly logged in. */
var GFxObject UserNameTxt;

var byte LastSelectedIndex;

/** Configures the view when it is first loaded. */
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
    Super.OnTopMostView(bPlayOpenAnimation);    		          
	
	MenuManager.SetSelectionFocus(ListMC);	
    UpdateDescription();    
}

/** Enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{	
    if (ListMC != none)
	{				
		ListMC.SetBool("disabled", bDisableComponents);    			
	}
}

/** 
 *  Pushes the Instant Action view on to the stack. This method is fired
 *  by the list's OnListItemPress() listener.
 */
function Select_InstantAction()
{    
    MenuManager.PushViewByName('InstantAction');
}

/** 
 *  Pushes the Multiplayer view on to the stack. This method is fired
 *  by the list's OnListItemPress() listener.
 */
function Select_Multiplayer()
{    
    if ( MenuManager.CheckLinkConnectionAndError() )
	{
        MenuManager.PushViewByName('Multiplayer');
	}
}

/** Before exiting the game, spawn a dialog asking the user to confirm his selection. */
function Select_ExitGame()
{
    local GFxUDKFrontEnd_InfoDialog ExitDialogMC;
    ExitDialogMC = GFxUDKFrontEnd_InfoDialog(MenuManager.SpawnDialog('InfoDialog')); 
    ExitDialogMC.SetTitle("EXIT GAME");
    ExitDialogMC.SetInfo("Are you sure you with to exit?");    
    ExitDialogMC.SetBackButtonLabel("CANCEL");
    ExitDialogMC.SetAcceptButtonLabel("EXIT GAME");
    ExitDialogMC.SetAcceptButton_OnPress(ExitDialog_SelectOK);
    ExitDialogMC.SetBackButton_OnPress(ExitDialog_SelectBack);
}

/** Listener for ExitDialog's "OK" button press. Quits the game. */
function ExitDialog_SelectOK( GFxClikWidget.EventData ev )
{
    ConsoleCommand("quit");
}

/** Listener for ExitDialog's "Cancel" button press. Pops a dialog from the view stack. */
function ExitDialog_SelectBack( GFxClikWidget.EventData ev )
{
    MenuManager.PopView();
}

/** 
 *  Listener for the menu's list "CLIK_itemPress" event. 
 *  When an item is pressed, retrieve the data associated with the item 
 *  and use it to trigger the appropriate function call.
 */
private final function OnListItemPress(GFxClikWidget.EventData ev)
{
    local int SelectedIndex;
    local name Selection;

    SelectedIndex = ev.index;    
    Selection = Name(ListOptions[SelectedIndex].OptionName);
    
    switch(Selection)
    {
        case('InstantAction'):  
            Select_InstantAction(); 
            break;
        case('Multiplayer'):    
            Select_Multiplayer();   
            break;
        case('Exit'):           
            Select_ExitGame();      
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
private final function OnListChange(GFxClikWidget.EventData ev)
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
        if (SelectedIndex < 0)
        {
            SelectedIndex = 0;
        }
        
        Description = ListOptions[SelectedIndex].OptionDesc;        
        InfoTxt.SetText(Description);
    }
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
        TempObj.SetString("name", ListOptions[i].OptionName);
        TempObj.SetString("label", ListOptions[i].OptionLabel);
        TempObj.SetString("desc", ListOptions[i].OptionDesc);
        
        DataProvider.SetElementObject(i, TempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");    
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

function OnEscapeKeyPress()
{    
    Select_ExitGame();
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;
	bWasHandled = false;

    //`log("GFxUDKFrontEnd_MainMenu: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);     
    switch(WidgetName)
    {
        case ('list'):  
			if (ListMC == none)
			{
				ListMC = GFxClikWidget(Widget);   
				SetList(ListMC);

				UpdateListDataProvider();  				
				MenuManager.SetSelectionFocus(ListMC);				
				ListMC.SetFloat("selectedIndex", 0);				

				UpdateDescription();            
				bWasHandled = true;
			}
            break;

        case ('username'):
			if (UserNameTxt == none)
			{
				UserLabelTxt = Widget.GetObject("label");
				UserNameTxt = Widget.GetObject("textField");

				UserLabelTxt.SetText("");
				UserNameTxt.SetText("");
				bWasHandled = true;
			}
            break;

        default:
            bWasHandled = false;
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
	CancelButtonHelpText="EXIT GAME"
}