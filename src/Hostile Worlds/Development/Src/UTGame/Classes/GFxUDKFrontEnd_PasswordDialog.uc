/**********************************************************************

Filename    :   GFxUDKFrontEnd_PasswordDialog.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation for password dialog within the server browser 
                (GFxUDKFrontEnd_JoinGame).

                Associated Flash content: udk_dialog_password.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_PasswordDialog extends GFxUDKFrontEnd_Dialog;    

/** Reference to the password renderer. */
var GFxClikWidget PasswordRendererMC;

/** Reference to the input textField within the password renderer. */
var GFxObject PasswordTextField;

/** Reference to the join button that connects the user to the game using the password. */
var GFxClikWidget JoinBtn;

/** Update the dialog. */
function OnTopMostView( optional bool bPlayOpenAnimation = FALSE )
{       
    // Setup the text and button listeners.
    TitleTxt.SetText("SERVER REQUIRES A PASSWORD"); 

    SetBackButtonListener(Select_Back);
    MenuManager.SetSelectionFocus(PasswordRendererMC);

    // Update the data provider for the filters.
    ClearPasswordRenderer();
}

/** Fired when a dialog is popped from the stack. */
function OnViewClosed()
{
    Super.OnViewClosed();
    DisableSubComponents( false );
}

/** Mutator for enable/disable sub-components of the dialog. */
function DisableSubComponents(bool bEnableComponents)
{
    PasswordRendererMC.SetBool("disabled", bEnableComponents);
    BackBtn.SetBool("disabled", bEnableComponents);
}

function SetBackButtonListener( delegate<GFxClikWidget.EventListener> DelegateListener )
{
    BackBtn.SetString("label", "BACK");   
    BackBtn.RemoveAllEventListeners("CLIK_press");
    BackBtn.RemoveAllEventListeners("press");
    BackBtn.AddEventListener('CLIK_press', DelegateListener);
}

function SetOKButtonListener( delegate<GFxClikWidget.EventListener> DelegateListener )
{    
    JoinBtn.SetString("label", "OK");   
    JoinBtn.RemoveAllEventListeners("CLIK_press");
    JoinBtn.RemoveAllEventListeners("press");
    JoinBtn.AddEventListener('CLIK_press', DelegateListener);    
}

public function String GetPassword()
{
    return PasswordTextField.GetText();
}

private final function ClearPasswordRenderer()
{
    PasswordTextField.SetText("");
    PasswordTextField.SetBool("password", true);
}
          
event bool WidgetInitialized( name WidgetName, name WidgetPath, GFxObject Widget )
{
    local bool bWasHandled;
    bWasHandled = false;

    // `log("GFxUDKFrontEnd_PasswordDialog: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
    switch(WidgetName)
    {
        case ( 'item1' ):
            if ( PasswordRendererMC == none )
            {
                PasswordRendererMC = GFxClikWidget(Widget);
                PasswordRendererMC.SetString("label", "PASSWORD:");
                PasswordTextField = GFxClikWidget(PasswordRendererMC.GetObject("textinput", class'GFxClikWidget'));
                bWasHandled = true;
            }
            break;
        case ( 'join' ):            
            JoinBtn = GFxClikWidget(Widget.GetObject("btn", class'GFxClikWidget'));                        
            JoinBtn.SetString("label", "OK");  
            bWasHandled = true;    
            break;
        case ( 'popup_title' ):            
            if ( TitleTxt == none )
            {
                TitleTxt = Widget;
                bWasHandled = true;            
            }
            break;   
        default:
            break;
    }
	   
	if (bWasHandled)
	{
		bWasHandled = Super.WidgetInitialized(WidgetName, WidgetPath, Widget); 
	}

    return bWasHandled;
}
