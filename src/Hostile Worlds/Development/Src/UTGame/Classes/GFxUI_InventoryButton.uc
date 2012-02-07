/**********************************************************************

Copyright   :   (c) 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright © 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

/**
 * Button class which extends from GFxClikWidget.
 * 
 * Contains custom logic and variables for the buttons 
 * in the Inventory menu.
 * 
 */

class GFxUI_InventoryButton extends GFxClikWidget;

var string Content;
var GFxObject IconMC;

function SetContent(String newContent)
{
    Content = newContent;
}

function SetIconMC(GFxObject iconClip)
{
    IconMC = iconClip;
}

defaultproperties
{
    Content = "none";
}
