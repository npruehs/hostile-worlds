/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Specific version of the menu list that draws an icon in addition to the menu text for selecting maps.
 */
class UTUIMapSelectionMenuList extends UTUIIconMenuList;

// @todo: Set the current icon based on the current game mode.

defaultproperties
{
	IconPadding=(X=0.05,Y=0.05)
	IconImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseD';
	IconU=442;
	IconV=76;
	IconUL=129;
	IconVL=104;
	IconColor=(R=1.0,G=1.0,B=1.0,A=0.99);
	bHotTracking=false;
}
