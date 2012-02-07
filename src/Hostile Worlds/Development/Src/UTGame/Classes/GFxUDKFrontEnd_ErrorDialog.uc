/**********************************************************************

Filename    :   GFxUDKFrontEnd_ErrorDialog.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Dialog class for a basic error dialog with a title, info,
                and "OK" button. Parent views setup the dialog using
                mutators defined below.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_ErrorDialog extends GFxUDKFrontEnd_Dialog;

function OnTopMostView(optional bool bPlayOpenAnimation = FALSE)
{
    Super.OnTopMostView(bPlayOpenAnimation);   
    MenuManager.SetSelectionFocus(BackBtn);
}

function SetTitle(string Title)
{
    TitleTxt.SetText(Title);
}

function SetInfo(string Info)
{
    InfoTxt.SetText(Info);
}

function SetButtonLabel(string ButtonLabel)
{
    BackBtn.SetString("label", ButtonLabel);
}

/** Fired when a dialog is popped from the stack. */
function OnViewClosed()
{
    Super.OnViewClosed();
    DisableSubComponents(false);
}

/** Mutator for enable/disable sub-components of the view. */
function DisableSubComponents(bool bDisableComponents)
{
    BackBtn.SetBool("disabled", bDisableComponents);
}


defaultproperties
{

}