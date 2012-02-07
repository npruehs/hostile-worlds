/**********************************************************************

Filename    :   GFxUDKFrontEnd_Screen.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Base class for a view within the GFx-UDK Front End.                

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_Screen extends GFxUDKFrontEnd_View
    config(UI);

/** Title of the view. Defined in DefaultUI.ini. */
var config String ViewTitle;

/** Reference to Back button for returning to previous screen. */
var GFxClikWidget BackBtn;

/** Reference to the title text at the bottom within the footer. */
var GFxObject TitleMC;

/** Reference to the footer of the view. */
var GFxObject FooterMC;

/** Reference to the UDK Logo at the top left of the view. Animation control. */
var GFxObject LogoMC;

/** Reference to the text field of the help text in the footer which displays controls. */
var GFxObject HelpTxt; 

/** Reference to the info/description text area. */
var GFxObject InfoTxt;

/** Text for the "Accept" button in the Help section of the footer. */
var String AcceptButtonHelpText;

/** Text for the "Cancel" button in the Help section of the footer. */
var String CancelButtonHelpText;

/** Reference to the texture which should be substituted for the accept button. */
var String AcceptButtonImage;

/** Reference to the texture which should be substituted for the cancel button. */
var String CancelButtonImage;

/**
 * User has focused the "Back" button. Clears the info text area.
 */
function FocusIn_BackButton(GFxClikWidget.EventData ev)
{
    if (InfoTxt != none)
    {
        InfoTxt.SetText("");
    }
}

/** Updates the help button images in the footer. */
function UpdateHelpButtonImages()
{

	if (class'UIRoot'.static.IsConsole(CONSOLE_PS3))
	{
		AcceptButtonImage = "ps3_a_png";
		CancelButtonImage = "ps3_b_png";
	}
	else if (class'UIRoot'.static.IsConsole(CONSOLE_XBox360))
	{
		AcceptButtonImage = "xbox_a_png";
		CancelButtonImage = "xbox_b_png";		
	}
}

/** Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  Returns TRUE if the widget was handled, FALSE if not. */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget) 
{
    local bool bWasHandled;
    bWasHandled = false;

    //`log("GFxUDKFrontEnd_Screen: WidgetInitialized():: WidgetName: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ('help'):    
            HelpTxt = Widget.GetObject("textField");  
			UpdateHelpButtonImages();
            HelpTxt.SetString("htmlText", "<img vspace='-5' src='"$AcceptButtonImage$"'>" @ AcceptButtonHelpText @ "&nbsp;&nbsp;<img vspace='-5' src='"$CancelButtonImage$"'>"@ CancelButtonHelpText);
            bWasHandled = true;                  
            break;
        case ('title'):
            if (TitleMC == none)
            {
                TitleMC = Widget;   
                TitleMC.GetObject("textField").SetText(ViewTitle);
                bWasHandled = true;
            }
            break;
        case ('back'):   
            BackBtn = GFxClikWidget(Widget.GetObject("btn", class'GFxClikWidget'));
            BackBtn.SetString("label", "BACK");
            BackBtn.AddEventListener('CLIK_press', Select_Back);
            BackBtn.AddEventListener('CLIK_focusIn', FocusIn_BackButton);
            bWasHandled = true;            
            break;
        case ('footer'):
            FooterMC = Widget;
            bWasHandled = true;
            break;
        case ('info'): 
            if (InfoTxt == none)
            {
                InfoTxt = Widget.GetObject("textField"); 
                bWasHandled = true;
            }
            break;
        case ('logo'): 
            if (LogoMC == none)
            {
                LogoMC = Widget;
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
	AcceptButtonImage="pc_enter_png"
	CancelButtonImage="pc_esc_png"
	AcceptButtonHelpText="SELECT"
	CancelButtonHelpText="BACK"
}