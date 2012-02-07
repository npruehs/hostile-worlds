/**********************************************************************

Filename    :   GFxUDKFrontEnd_Dialog.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Base class for a dialog for the GFx-UDK front end.             

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_InfoDialog extends GFxUDKFrontEnd_Dialog;

/** Fired when a dialog is popped from the stack. */
public function OnViewClosed()
{
    Super.OnViewClosed();
    DisableSubComponents(false);
}

/** 
 *  Update the view.  
 *  Called whenever the view becomes the topmost view on the viewstack. 
 */
function OnTopMostView(optional bool bPlayOpenAnimation = FALSE)
{
    Super.OnTopMostView(bPlayOpenAnimation);
    MenuManager.SetSelectionFocus( BackBtn );
}

function DisableSubComponents(bool bDisableComponents)
{
    AcceptBtn.SetBool("disabled", bDisableComponents);
    BackBtn.SetBool("disabled", bDisableComponents);
}

public function SetTitle(string Title)
{
    TitleTxt.SetText(Title);
}

public function SetInfo(string Info)
{
    InfoTxt.SetText(Info);
}

public function SetAcceptButtonLabel( string Label )
{
    AcceptBtn.SetString( "label", Label );
}

public function SetBackButtonLabel( string Label )
{
    BackBtn.SetString( "label", Label );
}

function SetAcceptButton_OnPress( delegate<GFxClikWidget.EventListener> EventListener )
{    
    AcceptBtn.RemoveAllEventListeners("CLIK_press");
    AcceptBtn.RemoveAllEventListeners("press");
    AcceptBtn.AddEventListener('CLIK_press', EventListener); 
}

defaultproperties
{

}