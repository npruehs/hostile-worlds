/**********************************************************************

Filename    :   GFxUDKFrontEnd_View.uc
Content     :   GFx UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Base class for any view (Screen/View) within the GFxUDK 
                front end menu. 

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_View extends GFxUIView
    dependsOn(Settings);

/** Reference to the manager which drives the front end. */
var GFxUDKFrontEnd MenuManager;

/** A unique name for this view which can be used to discern it from others. */
var name ViewName;

/** @todo sf Remove this placeholder when C++ logic GetPlayerIndex() has been implemented.*/
const FakePlayerIndex = 0;

/** Configures the view when it is first loaded. */
function OnViewLoaded();

/** 
 *  Update the view.  
 *  Called whenever the view becomes the topmost view on the view stack. 
 */
function OnTopMostView(optional bool bPlayOpenAnimation = false)
{
	DisableSubComponents(false);  
    
	if (bPlayOpenAnimation)
    {        
        PlayOpenAnimation();
    }       

    if (MenuManager != none)
    {
        MenuManager.SetEscapeDelegate(none);
        MenuManager.SetEscapeDelegate(OnEscapeKeyPress);   
    }  
}

/** Fired when a view is pushed on to the stack. */
function OnViewActivated();

/** Fired when a view is popped from the stack. */
function OnViewClosed()
{
    DisableSubComponents(true);
}

/** 
 *  Enable/disable sub-components of the view. 
 *  Because almost everything in the menu takes focus on rollOver, this is necessary to avoid 
 *  undesirable focus changes when screens are tweened in and out. This could and should be replaced
 *  using a proper ActionScript extension once one is implemented.
 */
function DisableSubComponents(bool bDisableComponents);

/** Plays the view's open animation. */
function PlayOpenAnimation();

/** Plays the view's close animation. */
function PlayCloseAnimation();

/**
 * User has selected "Back". Pop a view and move on.
 */
function Select_Back(GFxClikWidget.EventData ev)
{
    MoveBackImpl();
}

/** Moves the user backward on the view stack by popping the topmost view / dialog. */
function MoveBackImpl()
{
    if (MenuManager != none)
    {
        PlayCloseAnimation();
        MenuManager.PopView();        
    }
}

/** This method is tied to Escape / Back user input. Can be overriden by sub-classes for custom behavior per view. */
function OnEscapeKeyPress()
{
    MoveBackImpl(); 
}

/** Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  Returns TRUE if the widget was handled, FALSE if not. */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget) 
{
    return false;
}

defaultproperties
{
    
}