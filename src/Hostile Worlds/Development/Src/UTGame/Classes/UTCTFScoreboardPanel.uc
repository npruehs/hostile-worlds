/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTCTFScoreboardPanel extends UTTDMScoreboardPanel;

/** Sets the header strings using localized values */
function SetHeaderStrings()
{
	HeaderTitle_Name = Localize( "Scoreboards", "Name", "UTGameUI" );
	HeaderTitle_Score = Localize( "Scoreboards", "Score", "UTGameUI" );
}

simulated function DrawPlayerNum(UTPlayerReplicationInfo PRI, int PIndex, out float YPos, float FontIndex, float FontScale)
{
	local float W,H,Y;
	local float XL, YL;
	local color C;

	if ( FlagTexture != none && PRI.bHasFlag )
	{
		C = Canvas.DrawColor;

		// Figure out how much space we have

		StrLen("00",XL,YL, FontIndex, FontScale);
		W = XL * 0.8;
		H = W * (FlagCoords.VL / FlagCoords.UL);

		Y = YPos + (YL * 0.5) - (H * 0.5);

		Canvas.SetPos(0, Y);
		Canvas.SetDrawColor(255,255,0,255);
		Canvas.DrawTile(FlagTexture, W, H, FlagCoords.U, FlagCoords.V, FlagCoords.UL, FlagCoords.VL);

		Canvas.DrawColor = C;
	}
	else
	{
		super.DrawPlayerNum(PRI, PIndex, YPos, FontIndex, FontScale);
	}
}


function string GetRightMisc(UTPlayerReplicationInfo PRI)
{
	return super.GetRightMisc(PRI);
}


defaultproperties
{
	FlagTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseE'
	FlagCoords=(U=756,V=0,UL=67,VL=40)
	bDrawPlayerNum=true
	HeaderTitle_Score="Score"
}
