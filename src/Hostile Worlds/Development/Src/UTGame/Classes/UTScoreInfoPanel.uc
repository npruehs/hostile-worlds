/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTScoreInfoPanel extends UTDrawPanel;

var() linearColor BarColor;


var() texture2D PanelTex;
var() TextureCoordinates PanelCoords;
var() float PanelPct;

var() texture2D BarTex;
var() TextureCoordinates BarCoords;
var() float BarPct;

var() texture2D LogoTex;
var() TextureCoordinates LogoCoords;
var() vector2D LogoPos;
var() vector2D LogoSize;

var() font GameTypeFont;
var() font MapNameFont;
var() font RulesFont;

var() float MapNameYPad;

var() Color GameTypeColor;
var() Color MapNameColor;
var() Color RulesColor;

/** Cached reference to the HUDSceneOwner */
var UTUIScene UTHudSceneOwner;
var transient string LastMapPlayed;

var transient string RulesString;
var transient string GameNameString;

event PostInitialize()
{
	Super.PostInitialize();
	UTHudSceneOwner = UTUIScene( GetScene() );
	if ( UTHudSceneOwner.IsGame() )
	{
		PanelPct *= 0.8;
	}
}

event DrawPanel()
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local float X,Y, XL,YL, PanelSize, RulesY, Scaler;
	local string Work;
	local class<UTGame> GIC;
	local float YOffset;
	local string Clock;
	local float TextWidth, TextHeight, TempClipX;
	local float PadWidth, PadHeight;
	local FontRenderInfo RenderInfo;

	if ( class'Engine'.static.IsSplitScreen() )
	{
		// don't draw it in splitscreen mode
		return;
	}

	if ( MapNameFont == none )
	{
		return;
	}

	WI = UTHudSceneOwner.GetWorldInfo();
	GRI = UTGameReplicationInfo(WI.GRI);

	Canvas.Font = MapNameFont;
	Canvas.StrLen("Q",XL,YL);
	RenderInfo.bClipText = true;

	PanelSize = Canvas.ClipY * PanelPct;

	YOffset = (UTUIScene_MidGameMenu(UTHUDSceneOwner) != None) ? -0.05*Canvas.ClipY : -0.1*Canvas.ClipY;

	// Draw the Panel and the Icon
	Canvas.SetPos(0,YOffset);
	Canvas.DrawTile(PanelTex, PanelSize, PanelSize, PanelCoords.U, PanelCoords.V, PanelCoords.UL, PanelCoords.VL, BarColor);

	// Draw the Icon
	X = PanelSize * 0.5 - (LogoSize.X * PanelSize * 0.5);
	Y = PanelSize * 0.5 - (LogoSize.Y * PanelSize * 0.5);

	Canvas.SetPos(X,Y+YOffset);
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.DrawTile(LogoTex, LogoSize.X * PanelSize, LogoSize.Y * PanelSize, LogoCoords.U, LogoCoords.V, LogoCoords.UL, LogoCoords.VL);

	// Draw the bar.
	Y = PanelSize - (YL * BarPct);
	Canvas.SetPos(PanelSize + 2, Y+YOffset);
	Canvas.DrawTile(BarTex, Canvas.ClipX - PanelSize - 2, YL * BarPct, BarCoords.U,BarCoords.V,BarCoords.UL,BarCoords.VL, BarColor);

	// Draw the Map Name
	Canvas.DrawColor = MapNameColor;
	Canvas.SetPos(PanelSize + 6, Y + (YL * BarPct * 0.5) - (YL * 0.5)+YOffset );
	Work = WI.GetMapName();
	if (Work~="EnvyEntry")
	{
		Work = LastMapPlayed;
	}
	else
	{
		LastMapPlayed = Work;
	}

	Canvas.DrawText( Work,,,, RenderInfo );

	// draw clock
	if (GRI != None && !GRI.bMatchISOver)
	{
		Clock = class'UTHUD'.static.FormatTime( GRI.TimeLimit != 0 ? GRI.RemainingTime : GRI.ElapsedTime );
		Canvas.Font = MapNameFont;
		Canvas.StrLen(Clock, TextWidth, TextHeight);
		Canvas.StrLen("00", PadWidth, PadHeight);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos( Canvas.ClipX - (TextWidth + PadWidth*0.5f), Y + (YL * BarPct * 0.5) - (YL * 0.5) + YOffset );
		Canvas.DrawText(Clock,,,, RenderInfo);
	}

	// Cache the position of the Captures Message here
	RulesY = Y + (YL * BarPct);

	// Draw the Game Type
	if ( WI != none )
	{
		GIC = class<UTGame>(WI.GetGameClass());
	}

	if ( GameTypeFont != none )
	{
		if ( GIC != none )
		{
			GameNameString = GIC.default.GameName;
		}

		Canvas.Font  = MapNameFont;
		Canvas.StrLen(GameNameString,XL,YL);
		Canvas.DrawColor = GameTypeColor;

		if (XL > Canvas.ClipX - PanelSize - 2)
		{
			Scaler = (Canvas.ClipX - (PanelSize * 1.2) - 2)/XL;
		}
		else
		{
			Scaler = 1.0;
		}
		Canvas.SetPos(PanelSize + 6,Y+YOffset-1.1*YL);
		Canvas.DrawText(GameNameString,,Scaler,Scaler, RenderInfo);
	}

	if ( RulesFont != none )
	{
		if ( GIC != none )
		{
			RulesString = GIC.static.GetEndOfMatchRules(GRI.GoalScore, GRI.TimeLimit);
		}

		Canvas.Font = RulesFont;
		Canvas.StrLen(RulesString,XL,YL);
		Canvas.SetPos(PanelSize + 6,RulesY+YOffset);
		Canvas.DrawColor = RulesColor;
		TempClipX = Canvas.ClipX;
		Canvas.ClipX = PanelSize + 6 + XL + 1;
		Canvas.DrawText(RulesString,,,, RenderInfo);
		Canvas.ClipX = TempClipX;
	}
}

defaultproperties
{
}
