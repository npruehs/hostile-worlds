/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Specific version of the menu list that draws an icon in addition to the menu text for game modes.
 */
class UTUIGameModeMenuList extends UTUIIconMenuList;

event SelectItem(int NewSelection)
{
	local string OutValue;

	// Clamp selection.
	if(NewSelection<0)
	{
		NewSelection = List.length-1;
	}
	else
	{
		NewSelection=NewSelection%List.length;
	}

	// IconImage
	GetCellFieldString(self, 'IconImage', NewSelection, OutValue);
	IconImage = Texture2D(DynamicLoadObject(OutValue, class'Texture2D'));

	// IconU
	GetCellFieldString(self, 'IconU', NewSelection, OutValue);
	IconU = float(OutValue);

	// IconV
	GetCellFieldString(self, 'IconV', NewSelection, OutValue);
	IconV = float(OutValue);

	// IconUL
	GetCellFieldString(self, 'IconUL', NewSelection, OutValue);
	IconUL = float(OutValue);

	// IconVL
	GetCellFieldString(self, 'IconVL', NewSelection, OutValue);
	IconVL = float(OutValue);

	Super.SelectItem(NewSelection);
}

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
