/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSimpleMenu extends UDKSimpleList;

function DrawSelectionBar(float YPos, float CellHeight)
{
	local float Height;
	local float AWidth, AHeight, AYPos;
	local bool b;


	Height = DefaultCellHeight * SelectionCellHeightMultiplier * ResScaling.Y;

	YPos = YPos + (CellHeight * 0.5) - (Height * 0.5);

	Canvas.DrawColor=SelectionBarColor;

	// ------------ Draw the up/Down Arrows


	// Calculate the sizes
	AYPos = YPos + (CellHeight * 0.5) - Height;
	AHeight = Height * 0.9;
	AWidth = AHeight * 0.5;

		// Draw The up button

	// Cache the bounds for mouse lookup later

	UpArrowBounds[0] = 0;
	UpArrowBounds[2] = UpArrowBounds[0] + AWidth;
	UpArrowBounds[1] = AYPos;
	UpArrowBounds[3] = AYPos + AHeight;

	b = CursorCheck(UpArrowBounds[0],UpArrowBounds[1],UpArrowBounds[2],UpArrowBounds[3]);
	DrawSpecial(UpArrowBounds[0],UpArrowBounds[1], AWidth, AHeight,77,198,63,126,SelectionBarColor,b,bUpArrowPressed);

		// Draw The down button

	// Cache the bounds for mouse lookup later

	AYPos = YPos + (CellHeight * 0.5) + (Height * 0.1);

	DownArrowBounds[0] = 0;
	DownArrowBounds[2] = DownArrowBounds[0] + AWidth;
	DownArrowBounds[1] = AYPos;
	DownArrowBounds[3] = AYPos + AHeight;

	b = CursorCheck(DownArrowBounds[0],DownArrowBounds[1],DownArrowBounds[2],DownArrowBounds[3]);
	DrawSpecial(DownArrowBounds[0],DownArrowBounds[1], AWidth, AHeight,77,358,63,126,SelectionBarColor,b,bDownArrowPressed);


	// Draw the Bar

	Canvas.DrawColor=SelectionBarColor;

	AWidth *= 1.1;
	Canvas.SetPos(AWidth,YPos);
	Canvas.DrawTile(SelectionImage, Canvas.ClipX-AWidth,Height, 269,264,360,64);
}


defaultproperties
{
	TextFont=Font'UI_Fonts_Final.Menus.Fonts_Positec'
`if(`notdefined(MOBILE))
	SelectionImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseD'
	ArrowImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseC'
`endif
}
