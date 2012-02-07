/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Specific version of the menu list that draws an icon in addition to the menu text.
 */
class UTUIIconMenuList extends UDKUIMenuList;

/** Icon information. */
var transient vector2D IconPadding;
var transient Texture2D IconImage;
var transient float IconU;
var transient float IconV;
var transient float IconUL;
var transient float IconVL;
var transient LinearColor IconColor;

function DrawSelectionBG(float YPos)
{
	local float Width,Height;

	Height = DefaultCellHeight * SelectionCellHeightMultiplier * ResScaling.Y;
	Width = Height * ScrollWidthRatio;

	Super.DrawSelectionBG(YPos);

	Canvas.SetPos(Width*IconPadding.X, YPos+Height*IconPadding.Y);
	Canvas.DrawTile(IconImage, Width*(1.0 - IconPadding.X*2), Height*(1.0 - IconPadding.Y*2), IconU, IconV, IconUL, IconVL, IconColor);
}

/** Copies the icon from another icon menu list. */
function CopyIcon(UTUIIconMenuList OtherList)
{
	IconU=OtherList.IconU;
	IconV=OtherList.IconV;
	IconUL=OtherList.IconUL;
	IconVL=OtherList.IconVL;
	IconImage=OtherList.IconImage;
}

defaultproperties
{
	TextFont=Font'UI_Fonts_Final.Menus.Fonts_Positec'
	SelectionImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseD'
	ArrowImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseC'

	IconPadding=(X=0.05,Y=0.05)
	IconImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseD';
	IconU=442;
	IconV=76;
	IconUL=129;
	IconVL=104;
	IconColor=(R=1.0,G=1.0,B=1.0,A=0.99);
}
