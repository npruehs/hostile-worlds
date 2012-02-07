/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTScoreboardPanel extends UTDrawPanel
	config(Game);

/** Defines the different font sizes */
enum EFontType
{
	EFT_Tiny,
	EFT_Small,
	EFT_Med,
	EFT_Large,
};

/**
 * Holds the font data.  We cache the max char height for quick lookup
 */
struct SBFontData
{
	var() font Font;
	var transient int CharHeight;

};

/** Font Data 0 = Tiny, 1=Small, 2=Med, 3=Large */
var() SBFontData Fonts[4];

/** If true, this scoreboard will be considered to be interactive */
var() bool bInteractive;

/** Holds a list of PRI's currently being worked on.  Note it cleared every frame */
var transient array<UTPlayerReplicationInfo> PRIList;

/** Cached reference to the HUDSceneOwner */
var UTUIScene UTHudSceneOwner;

var(Test) transient int EditorTestNoPlayers;

var() float MainPerc;
var() float ClanTagPerc;
var() float MiscPerc;
var() float SpacerPerc;
var() float BarPerc;
var() Texture2D SelBarTex;
var() int AssociatedTeamIndex;
var() bool bDrawPlayerNum;
var() config string LeftMiscStr;
var() config string RightMiscStr;

var() Texture2D BackgroundTex;
var() TextureCoordinates BackgroundCoords;
var() Texture2D BlingTex;
var() TextureCoordinates BlingCoords;
var() TextureCoordinates BlingPct;

var() float TextPctWidth;
var() float TextPctHeight;
var() float TextLeftPadPct;
var() float TextTopPadPct;

var() vector2D ScorePosition;
var() font ScoreFont;

var() font HeaderFont;
var() float HeaderXPct;
var() float HeaderYPos;

var() float FragsXPct;

var(Test) transient bool bShowTextBounds;
var transient UTPlayerController PlayerOwner;

var transient int NameCnt;
var transient string FakeNames[32];

var transient color TeamColors[2];

/** The Player Index of the currently selected player */
var transient int SelectedPI;

/** We cache this so we don't have to resize everything for a mouse click */
var transient float LastCellHeight;

var string HeaderTitle_Name;
var string HeaderTitle_Score;
var string HeaderTitle_Deaths;

var transient bool bCensor;

// X screen position for the right stat on the panel.
var transient float RightColumnPosX;
// Width of the header drawn for the right column.
var transient float RightColumnWidth;

// X screen position for the left stat on the panel.
var transient float LeftColumnPosX;
// Width of the header drawn for the left column.
var transient float LeftColumnWidth;

// Padding between the top/bottom of the highlighter and the string(s) it is behind.
var() float HighlightPad;
// Padding on either side of the playername string, for when other strings (clan, location) are drawn above or under it.
var() float PlayerNamePad;

// Minimum scale percentage we will scale a font.
var() float MinFontScale;

// Pixels to adjust ClanName position.
var() float ClanPosAdjust;
var() float ClanMultiplier;
// Pixels to adjust Misc position.
var() float MiscPosAdjust;
var() float MiscMultiplier;

var localized string PingString;

/** whether or not this list should always attempt to include the local player's PRI, skipping other players if necessary to make it fit */
var bool bMustDrawLocalPRI;

var() Texture2D FlagTexture;
var() TextureCoordinates FlagCoords;

/** Scoreboard color for allies (in betrayal gametype)*/
var  color AllyColor;

event PostInitialize()
{
	local UDKPlayerController PC;
	local EFeaturePrivilegeLevel Level;
	local GameReplicationInfo GRI;

	Super.PostInitialize();
	SizeFonts();

	UTHudSceneOwner = UTUIScene( GetScene() );
	NotifyResolutionChanged = OnNotifyResolutionChanged;

	if (bInteractive)
	{
		OnRawInputKey=None;
		OnProcessInputKey=ProcessInputKey;
	}

	// Set the localized header strings.
	SetHeaderStrings();

	PC = UTHudSceneOwner.GetUDKPlayerOwner();
	if (PC != none )
	{
		Level = PC.OnlineSub.PlayerInterface.CanCommunicate( LocalPlayer(PC.Player).ControllerId );
		bCensor = Level != FPL_Enabled;
		GRI = PC.WorldInfo.GRI;
	}

	HighlightPad = 3.0f;
	PlayerNamePad = 1.0f;

	// increase scoreboard panel on PC
	if (UTHudSceneOwner.IsGame())
	{
		if ( (GRI != None) && (GRI.GameClass != None) && GRI.GameClass.default.bTeamGame )
		{
			SetPosition( 0.12 , UIFACE_Top, EVALPOS_PercentageOwner);
			SetPosition( 0.85, UIFACE_Bottom, EVALPOS_PercentageOwner);
		}
		else
		{
			SetPosition( 0.14, UIFACE_Top, EVALPOS_PercentageOwner);
			SetPosition( 0.84, UIFACE_Bottom, EVALPOS_PercentageOwner);
		}
	}
}

/** Sets the header strings using localized values */
function SetHeaderStrings()
{
	HeaderTitle_Name = Localize( "Scoreboards", "Name", "UTGameUI" );
	HeaderTitle_Score = Localize( "Scoreboards", "Kills", "UTGameUI" );
	HeaderTitle_Deaths = Localize( "Scoreboards", "Deaths", "UTGameUI" );
}

/**
 * Setup Input subscriptions
 */
event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'SelectionUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionDown';
	out_KeyNames[out_KeyNames.Length] = 'Select';

}


/**
 * Whenever there is a resolution change, make sure we recache the font sizes
 */
function OnNotifyResolutionChanged( const out Vector2D OldViewportsize, const out Vector2D NewViewportSize )
{
	SizeFonts();
}

function NotifyGameSessionEnded()
{
	SelectedPI = INDEX_None;
	PRIList.Length = 0;
	PlayerOwner = None;
	Super.NotifyGameSessionEnded();
}


/**
 * Precache the sizing of the fonts so we don't have to constant look it up
 */
function SizeFonts()
{
	local int i;
	for (i = 0; i < ARRAYCOUNT(Fonts); i++)
	{
		if ( Fonts[i].Font != none )
		{
			Fonts[i].CharHeight = Fonts[i].Font.GetMaxCharHeight();
		}
	}
}

/** Get the header color */
function LinearColor GetHeaderColor()
{
	local LinearColor LC;
	LC = MakeLinearColor(1.0f,0.15f,0.0f,1.0f);
	return LC;
}

/**
 * Draw the Scoreboard
 */

event DrawPanel()
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local int i;
	local float YPos;
	local float CellHeight;

	/** Which font to use for clan tags */
	local int ClanTagFontIndex;

	/** Which font to use for the Misc line */
	local int MiscFontIndex;

	/** Which font to use for the main text */
	local int FontIndex;

	/** Finally, if we must, scale it */
	local float FontScale;

	local LinearColor LC;

	local float OrgX, OrgY, ClipX, ClipY, tW, tH;
	local int NumPRIsToDraw;
	local bool bHasDrawnLocalPRI;
	local float LastPRIY;
	local PlayerReplicationInfo OwningPRI;

	WI = UTHudSceneOwner.GetWorldInfo();
	GRI = UTGameReplicationInfo(WI.GRI);

	MainPerc = 1.0f;
 	ClanTagPerc = 0.35f;
	ClanMultiplier = -1.25f;
 	MiscPerc = 0.35f;
 	MiscMultiplier = -1.75f;
	ClanPosAdjust = 8.0f * ((ResolutionScale-1.0f)/ClanTagPerc * ClanMultiplier);
	MiscPosAdjust = 8.0f * ((ResolutionScale-1.0f)/MiscPerc * MiscMultiplier);

	// Grab the PawnOwner.  We will ditch this at the end of the draw
	// cycle to make sure there are no Object->Actor references laying around
	PlayerOwner = UTPlayerController(UTHudSceneOwner.GetUDKPlayerOwner());
	OwningPRI = UTHudSceneOwner.GetPRIOwner();

	// Figure out if we can fit everyone at the default font levels
	FontIndex = EFT_Large;

	if ( bInteractive )
	{
		ClanTagFontIndex = -1;
		MiscFontIndex = -1;
	}
	else
	{
		ClanTagFontIndex = EFT_Small;
		MiscFontIndex = EFT_Small;
	}

    OrgX = Canvas.OrgX;
    OrgY = Canvas.OrgY;
    ClipX = Canvas.ClipX;
    ClipY = Canvas.ClipY;

	// Draw the background
	Canvas.SetPos(0,0);
	LC = GetHeaderColor();
	Canvas.DrawTileStretched(BackgroundTex, Canvas.ClipX, Canvas.ClipY, BackgroundCoords.U, BackgroundCoords.V, BackgroundCoords.UL, BackgroundCoords.VL,LC,,,ResolutionScale);

    	// Readjust the clip region
	tW = ClipX * TextPctWidth;
	tH = ClipY * TextPctHeight;

	Canvas.OrgX += (tW * TextLeftPadPct);
	Canvas.ClipX -= tW;

	// Draw the scoring header.  We remain at full height here
	DrawScoreHeader();

	Canvas.OrgY += (tH * TextTopPadPct);
	Canvas.ClipY -= tH;

    if (bShowTextBounds)
    {
    	Canvas.SetPos(0,0);
    	Canvas.SetDrawColor(255,255,255,255);
    	Canvas.DrawBox(Canvas.ClipX, Canvas.ClipY);
    }

	if (bCensor)	// Hide the ClanTag
	{
		ClanTagFontIndex = 0;
	}

	// Adjust font
	FontScale = 1.0f;

	// Attempt to AutoFit the text.
	CellHeight = AutoFit(GRI, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, true);
	LastCellHeight = CellHeight;

	// Draw each score.
	NameCnt=0;
	YPos = 0.0;

    	//Number of player scores to draw is canvas size dependent (rounded up)
	NumPRIsToDraw = Min( ((Canvas.ClipY-YPos)/CellHeight) + 0.5, PRIList.length );
	bHasDrawnLocalPRI = !bMustDrawLocalPRI;

	for (i=0;i<PRIList.length;i++)
	{
		// If we are at the end of the draw list and haven't drawn the local player yet, wait until we find him to draw the last PRI.
		if ( !bHasDrawnLocalPRI && (OwningPRI != None) && (OwningPRI.GetTeamNum() == AssociatedTeamIndex || AssociatedTeamIndex == -1) && (NameCnt == NumPRIsToDraw-1) && (PRIList[i] != OwningPRI) )
		{
			continue;
		}

		// Keep track of whether the local PRI has been drawn yet.
		if ( OwningPRI != None && PRIList[i] == OwningPRI )
		{
			bHasDrawnLocalPRI = true;
		}

		// Draw the score
		LastPRIY = YPos;
		DrawPRI(i, PRIList[i], CellHeight, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, YPos);
		YPos = LastPRIY + CellHeight;
		NameCnt++;

		if ( NameCnt >= NumPRIsToDraw )
		{
			break;
		}
	}

	// Clear up Object->Actor references
	PlayerOwner = none;
	PRIList.Length = 0;

    	// Restore Clip Region
    	Canvas.OrgX = OrgX;
    	Canvas.OrgY = OrgY;
    	Canvas.ClipX = ClipX;
    	Canvas.ClipY = ClipY;

	// If we have a team, draw it's score here
	DrawTeamScore();

	Canvas.SetPos(Canvas.ClipX * BlingPct.U, Canvas.ClipY * BlingPct.V);
	Canvas.DrawTileStretched(BlingTex, (Canvas.CLipX * BlingPct.UL), (Canvas.ClipY * BlingPct.VL), BlingCoords.U, BlingCoords.V, BlingCoords.UL, BlingCoords.VL,MakeLinearColor(1.0,1.0,1.0,1.0));
}


/** Default to drawing nothing */
function DrawTeamScore();

function DrawScoreHeader()
{
	local float xl, yl, columnWidth, numXL, numYL;
	local FontRenderInfo RenderInfo;

	if ( HeaderFont != none )
	{
		Canvas.SetDrawColor(255,255,255,255);
		RenderInfo.bClipText = true;

		Canvas.Font = Fonts[EFT_Large].Font;
		Canvas.StrLen("0000",numXL,numYL);

		Canvas.Font = HeaderFont;
		Canvas.SetPos(Canvas.ClipX * HeaderXPct,Canvas.ClipY * HeaderYPos);
		Canvas.DrawText( HeaderTitle_Name, , , , RenderInfo );

		Canvas.StrLen(HeaderTitle_Deaths,xl,yl);
		RightColumnWidth = xl;
		columnWidth = Max(xl+0.25f*numXL, numXL);
		RightColumnPosX = Canvas.ClipX - columnWidth;
		Canvas.SetPos(RightColumnPosX,Canvas.ClipY * HeaderYPos);
		Canvas.DrawText( HeaderTitle_Deaths, , , , RenderInfo );

		Canvas.StrLen(HeaderTitle_Score,xl,yl);
		LeftColumnWidth = xl;
		columnWidth = Max(xl, numXL);
		columnWidth += 0.25f*numXL;
		LeftColumnPosX = RightColumnPosX - columnWidth;
		Canvas.SetPos(LeftColumnPosX, Canvas.ClipY * HeaderYPos);
		Canvas.DrawText( HeaderTitle_Score, , , , RenderInfo );
	}
}


function CheckSelectedPRI()
{
	local int i;

	for (i=0;i<PRIList.Length;i++)
	{
		if ( PRIList[i].PlayerID == SelectedPI )
		{
			return;
		}
	}

	SelectedPI = INDEX_None;
}

/** Scan the PRIArray and get any valid PRI's for display */
function GetPRIList(UTGameReplicationInfo GRI)
{
	local int i,Idx;
	local UTPlayerReplicationInfo PRI;

	if (GRI != None)
	{
		for (i=0; i < GRI.PRIArray.Length; i++)
		{
			PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
			if ( PRI != none && IsValidScoreboardPlayer(PRI) )
			{
				Idx = PRIList.Length;
				PRIList.Length = Idx + 1;
				PRIList[Idx] = PRI;
			}
		}
	}
}

/**
 * Figure a way to fit the data.  This will probably be specific to each game type
 *
 * @Param	GRI 				The Game ReplicationIfno
 * @Param	FontIndex			The Index to use for the main text
 * @Param 	ClanTagFontIndex	The Index to use for the Clan Tag
 * @Param	MiscFontIndex		The Index to use for the Misc tag
 * @Param	FontSCale			The final font scaling factor to use if all else fails
 * @Param	bPrimeList			Should only be true the first call.  Will build a list of
 *								who needs to be checked.
 */
function float AutoFit(UTGameReplicationInfo GRI, out int FontIndex,out int ClanTagFontIndex,
					out int MiscFontIndex, out float FontScale, bool bPrimeList)
{
	local float CellHeight;
	local bool bRecurse;

	// We need to prime our list, so do that first.
	if ( bPrimeList )
	{
		if ( UTHudSceneOwner.IsGame() )
		{
			GetPRIList(GRI);

			if (bInteractive)
			{
				if (SelectedPI != INDEX_None )
				{
					CheckSelectedPRI();
				}
			}
		}
		else
		{
			// Create Fake Entries for the editor
			PRIList.Length = EditorTestNoPlayers;
		}
	}

	// Calculate the Actual Cell Height given all the data
	CellHeight  = (Fonts[FontIndex].CharHeight * MainPerc * FontScale) + (HighlightPad * 2 * ResolutionScale) - MiscPosAdjust;
	CellHeight += (ClanTagFontIndex >= 0) ? (Fonts[ClanTagFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) - ClanPosAdjust : 0.0f;
	CellHeight += MiscFontIndex >= 0 ? (Fonts[MiscFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) : 0.0f;

	// Check to see if we fit
	if ( CellHeight * PRIList.Length > Canvas.ClipY )
	{
		bRecurse = false;		// By default, don't recurse

		if ( FontScale > 0.75 )
		{
			FontScale = FClamp( (Canvas.ClipY/(CellHeight * PRIList.Length)), 0.75f, 1.0f );
			bRecurse = (FontScale <= 0.75);
		}
		else if ( MiscFontIndex > 0 || (ClanTagFontIndex == 0 && MiscFontIndex == 0) )
		{
		// MiscFontIndex is the first to go
			MiscFontIndex--;
			bRecurse = true;
		}
		else if ( ClanTagFontIndex >= 0 )
		{
			// Then the Clan Tag
			ClanTagFontIndex--;
			bRecurse = (ClanTagFontIndex >= 0);
		}

		// If we adjusted the ClanTag or Misc sizes, we need to retest the fit.
		if (bRecurse)
		{
			return AutoFit(GRI, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, false);
		}
	}

	CellHeight  = (Fonts[FontIndex].CharHeight * MainPerc * FontScale) + (HighlightPad * 2 * ResolutionScale) - MiscPosAdjust;
	CellHeight += (ClanTagFontIndex >= 0) ? (Fonts[ClanTagFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) - ClanPosAdjust : 0.0f;
	CellHeight += MiscFontIndex >= 0 ? (Fonts[MiscFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) : 0.0f;

	return CellHeight;
}


/**
 * Tests a PRI to see if we should display it on the scoreboard
 *
 * @Param PRI		The PRI to test
 * @returns TRUE if we should display it, returns FALSE if we shouldn't
 */
function bool IsValidScoreboardPlayer( UTPlayerReplicationInfo PRI)
{
	//@hack: workaround for ghost PRIs - don't show a PRI on the scoreboard for the server if it's unowned
	if ( !PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
		(PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None)) )
	{
		return false;
	}

	if ( AssociatedTeamIndex < 0 || PRI.GetTeamNum() == AssociatedTeamIndex )
	{
		return !PRI.bOnlySpectator;
	}

	return false;
}

/**
 * Draw any highlights.  These should render underneath the full width of the cell
 */
function DrawHighlight(UTPlayerReplicationInfo PRI, float YPos, float CellHeight, float FontScale)
{
	local float X;
	local UTPlayerController PC;
 	local LinearColor LC;

	PC = PRI != none ? UTPlayerController(PRI.Owner) : None;

	if ( (!bInteractive && PC != none && PC.Player != none && LocalPlayer(PC.Player) != none ) ||
		 ( bInteractive && PRI != None && PRI.PlayerID == SelectedPI ) )
	{

		if ( !bInteractive || IsFocused() )
		{
			// Figure out where to draw the bar
			X = (Canvas.ClipX * 0.5) - (Canvas.ClipX * BarPerc * 0.5);
			Canvas.SetPos(X,YPos);
			LC = MakeLinearColor( 0.02f, 0.02f, 0.02f, 1.0f );
 			Canvas.DrawTileStretched(SelBarTex,Canvas.ClipX * BarPerc,CellHeight /** FontScale*/,650,310,325,64,LC);
		}
		Canvas.SetDrawColor(255,255,255,255);
	}
	else
	{
		Canvas.SetDrawColor(255,255,255,160);
	}
}

/**
 * Draw the player's clan tag.
 */
function DrawClanTag(UTPlayerReplicationInfo PRI, float X, out float YPos, int FontIndex, float FontScale)
{
	if ( FontIndex < 0 )
	{
		return;
	}

	// Draw the clan tag
	DrawString( GetClanTagStr(PRI),X, YPos, FontIndex, FontScale);
	YPos += Fonts[FontIndex].CharHeight * FontScale + (PlayerNamePad*ResolutionScale) - ClanPosAdjust;
}

/**
 * Draw the Player's Score
 */
function float DrawScore(UTPlayerReplicationInfo PRI, float YPos, int FontIndex, float FontScale)
{
	local string Spot;
	local float Width, Height;

	// Draw the player's Kills
	Spot = GetPlayerDeaths(PRI);
	Canvas.Font = Fonts[FontIndex].Font;
	Canvas.StrLen( Spot, Width, Height );
	DrawString( Spot, RightColumnPosX+RightColumnWidth-Width, YPos,FontIndex,FontScale * MainPerc);

	// Draw the player's Frags
	Spot = GetPlayerScore(PRI);
	Canvas.StrLen( Spot, Width, Height );
	DrawString( Spot, LeftColumnPosX+LeftColumnWidth-Width, YPos,FontIndex,FontScale * MainPerc);

	return LeftColumnPosX;
}

/**
 * Draw's the player's Number (ie "1.")
 */
simulated function DrawPlayerNum(UTPlayerReplicationInfo PRI,int PIndex, out float YPos, float FontIndex, float FontScale)
{
	local float XL, YL, Y, W, H;
	local color C;

	// draw icon if player has the flag
	if ( PRI.bHasFlag )
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
}

/**
 * Draw the Player's Name
 */
function DrawPlayerName(UTPlayerReplicationInfo PRI, float NameOfst, float NameClipX, out float YPos, int FontIndex, float FontScale, bool bIncludeClan)
{
	local float XL, YL;
	local string Spot;

	Spot = bIncludeClan ? GetPlayerNameStr(PRI) : GetClanTagStr(PRI)$GetPlayerNameStr(PRI);
	StrLen(Spot, XL, YL, FontIndex, FontScale * MainPerc);
	YL = Fonts[FontIndex].CharHeight * FontScale * MainPerc;

	if ( XL > (NameClipX - NameOfst) && !bIncludeClan )
	{
		Spot = GetPlayerNameStr(PRI);
	}

	DrawString( Spot, NameOfst, YPos, FontIndex, FontScale * MainPerc);

	YPos += YL;
}

/**
 * Draw any Misc data
 */
function DrawMisc(UTPlayerReplicationInfo PRI, float NameOfst, out float YPos, int FontIndex, float FontScale)
{
	local string Spot;
	local float XL,YL;

	// Draw the Misc Strings
	if ( FontIndex < 0 )
	{
		return;
	}

	YPos += PlayerNamePad * ResolutionScale;
	Spot = GetRightMisc(PRI);
	StrLen(Spot,XL,YL, FontIndex, FontScale);
	DrawString( Spot, Canvas.ClipX-XL-15, YPos - MiscPosAdjust, FontIndex,FontScale);
	YPos += Fonts[FontIndex].CharHeight * FontScale - MiscPosAdjust;
}


/**
 * Draw an full cell.. Call the functions above.
 */
function DrawPRI(int PIndex, UTPlayerReplicationInfo PRI, float CellHeight, int FontIndex, int ClanTagFontIndex, int MiscFontIndex, float FontScale, out float YPos)
{
	local float NameOfst, NameClipX;
	local PlayerReplicationInfo OwnerPRI;
	local float AvatarOfst;
	local float AvatarSize;
	local color C;
	
	// Set the default Drawing Color
	DrawHighlight(PRI, YPos, CellHeight, FontScale);

	OwnerPRI = UTUIScene(GetScene()).GetPRIOwner();
	if ( PRI == OwnerPRI )
	{
		Canvas.DrawColor = class'UTHUD'.default.GoldColor;
	}
	else
	{
		Canvas.DrawColor = class'HUD'.default.WhiteColor;
	}

	// Line up the Avatar with the header.
	AvatarOfst = Canvas.ClipX * HeaderXPct;
	AvatarSize = CellHeight - (CellHeight * 0.4);

	// Name to the right of the avatar.
	NameOfst = AvatarOfst + CellHeight;

	YPos += (HighlightPad*ResolutionScale);

	if (PRI.Avatar != None)
	{
		C = Canvas.DrawColor;
		Canvas.SetPos(AvatarOfst, YPos + (((CellHeight - AvatarSize) * 0.5) * ResolutionScale) );
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawTile(PRI.Avatar, AvatarSize, AvatarSize, 0.0, 0.0, PRI.Avatar.SizeX, PRI.Avatar.SizeY);
		Canvas.DrawColor = C;
	}
	
	Canvas.DrawColor.A = 105;
	DrawClanTag(PRI, NameOfst, YPos, ClanTagFontIndex, FontScale);

	// Draw the player's Score so we can see how much room we have to draw the name
	if ( PRI == OwnerPRI )
	{
		Canvas.DrawColor.A = 255;
	}
	else
	{
		Canvas.DrawColor.A = 128;
	}
	if ( PRI == None || !PRI.bFromPreviousLevel || PRI.WorldInfo.IsInSeamlessTravel() ||
		(PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None && PlayerOwner.PlayerReplicationInfo.bFromPreviousLevel) )
	{
		NameClipX = DrawScore(PRI, YPos, FontIndex, FontScale);
	}
	else
	{
		NameClipX = Canvas.ClipX;
	}


	// Draw the Player's Name and position on the team - NOTE it doesn't increment YPos
		DrawPlayerNum(PRI, PIndex, YPos, FontIndex, FontScale);

	DrawPlayerName(PRI, NameOfst, NameClipX, YPos, FontIndex, FontScale, (ClanTagFontIndex >= 0));

	Canvas.DrawColor.A = 105;
	DrawMisc(PRI, NameOfst, YPos, MiscFontIndex, FontScale);

	YPos += (HighlightPad*ResolutionScale);
}

/**
 * Returns the Clan Tag in the PRI
 */
function string GetClanTagStr(UTPlayerReplicationInfo PRI)
{
	if ( PRI != none )
	{
		return PRI.ClanTag != "" ? ("["$PRI.ClanTag$"]") : "";
	}
	else
	{
		return "[Clan]";
	}
}

/**
 * Returns the Player's Name
 */
function string GetPlayerNameStr(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		return PRI.PlayerName;
	}
	else
	{
		return FakeNames[NameCnt];
	}
}

/**
 * Returns the # of deaths as a string
 */
function string GetPlayerDeaths(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		return string(PRI.Deaths);
	}
	else
	{
		return "0000";
	}
}

/**
 * Returns the score as a string
 */
function string GetPlayerScore(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		return string(int(PRI.Score));
	}
	else
	{
		return "0000";
	}
}

/**
 * Returns the time online as a string
 */
function string GetTimeOnline(UTPlayerReplicationInfo PRI)
{
	return "Time:"@ class'UTHUD'.static.FormatTime( PRI.WorldInfo.GRI.ElapsedTime );
}

/**
 * Get the Right Misc string
 */
function string GetRightMisc(UTPlayerReplicationInfo PRI)
{
	local int TotalSeconds, Hours, Minutes, Seconds;
	local string TimeString;
	local bool bHasHours;

	if ( (PRI.WorldInfo.NetMode != NM_Standalone) && !PRI.bBot )
	{
		TotalSeconds = PRI.WorldInfo.GRI.ElapsedTime - PRI.StartTime;
		hours = TotalSeconds/3600;
		if ( hours > 0 )
		{
			TimeString = Hours$":";
			TotalSeconds -= 3600*Hours;
			bHasHours = true;
		}
		minutes = TotalSeconds/60;
		if ( bHasHours && (minutes < 10) )
		{
			TimeString = TimeString$"0";
		}
		TimeString = TimeString$minutes$":";

		seconds = TotalSeconds - 60*minutes;
		if ( seconds < 10 )
{
			TimeString = TimeString$"0";
		}
		TimeString = TimeString$seconds;
		return TimeString$"   "$PingString@(4*PRI.Ping);
	}
	return "";
}

/**
 * Our own implementation of DrawString that manages font lookup and scaling
 */
function float DrawString(String Text, float XPos, float YPos, int FontIdx, float FontScale)
{
	local FontRenderInfo RenderInfo;

	if (FontIdx >= 0 && Text != "")
	{
		Canvas.Font = Fonts[FontIdx].Font;
		RenderInfo.bClipText = true;
		Canvas.SetPos(XPos, YPos);
		Canvas.DrawText(Text,,FontScale,FontScale, RenderInfo);
		return Fonts[FontIdx].CharHeight* FontScale;
	}
	return 0;
}

/**
 * Our own version of StrLen that manages font lookup and scaling
 */
function StrLen(String Text, out float XL, out float YL, int FontIdx, float FontScale)
{
	if (FontIdx >= 0 && Text != "")
	{
		Canvas.Font = Fonts[FontIdx].Font;
		Canvas.StrLen(Text, xl,yl);
		xl *= FontScale;
		yl *= FontScale;
	}
	else
	{
		xl = 0;
		yl = 0;
	}
}

/*********************************[ InteractiveMode ]*****************************/

function ChangeSelection(int Ofst)
{
	local UTGameReplicationInfo GRI;
	local array<UTPlayerReplicationInfo> PRIs;
	local UTPlayerReplicationInfo PRI;
	local int i,idx;

	GRI = UTGameReplicationInfo(UTHudSceneOwner.GetWorldInfo().GRI);

	for (i=0; i < GRI.PRIArray.Length; i++)
	{
		PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
		if ( PRI != none && IsValidScoreboardPlayer(PRI) )
		{
			if (PRI.PlayerID == SelectedPI)
			{
				idx = PRIs.Length;
			}
			PRIs[PRIs.Length] = PRI;
		}
	}

	if ( (ofst>0 && idx < PRIs.Length-1) || (ofst<0 && idx >0) )
	{
		SelectedPI = PRIs[Idx+Ofst].PlayerID;
		OnSelectionChange(self,PRIs[Idx+Ofst]);
	}

}

delegate OnSelectionChange(UTScoreboardPanel TargetScoreboard, UTPlayerReplicationInfo PRI);

function Vector GetMousePosition()
{
	local int x,y;
	local float w,h,tw,th;
	local vector2D MousePos;
	local vector AdjustedMousePos;

	// Figure out where the press was in overall widget space

	class'UIRoot'.static.GetCursorPosition( X, Y );
	MousePos.X = X;
	MousePos.Y = Y;
	AdjustedMousePos = PixelToCanvas(MousePos);
	AdjustedMousePos.X -= GetPosition(UIFACE_Left,EVALPOS_PixelViewport);
	AdjustedMousePos.Y -= GetPosition(UIFACE_Top, EVALPOS_PixelViewport);

	// Now figure out where it is just in list space (minus headers / padding / etc)


	w = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);
	h = GetBounds(UIORIENT_Vertical, EVALPOS_PixelViewport);

	tW = w * TextPctWidth;
	tH = h * TextPctHeight;

	AdjustedMousePos.X -= tW * 0.5;		// We center the horiz.
	AdjustedMousePos.Y -= tH;

	return AdjustedMousePos;
}


function SelectUnderCursor()
{
	local UTGameReplicationInfo GRI;
	local Vector CursorVector;
	local int Item, c, i;
	local UTPlayerReplicationInfo PRI;

	CursorVector = GetMousePosition();

	// Attampt to figure out


	Item = int( CursorVector.Y / LastCellHeight);

	GRI = UTGameReplicationInfo(UTHudSceneOwner.GetWorldInfo().GRI);
	for (i=0; i < GRI.PRIArray.Length; i++)
	{
		PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
		if ( PRI != none && IsValidScoreboardPlayer(PRI) )
		{
			if (c == Item)
			{
				SelectedPI = PRI.PlayerID;
				OnSelectionChange(self,PRI);
				return;
			}
			c++;
		}
	}
}

function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	if (EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat)
	{
		if (EventParms.InputAliasName == 'SelectionUp')
		{
		 	ChangeSelection(-1);
		 	return true;
		}
		else if (EventParms.InputAliasName == 'SelectionDown')
		{
			ChangeSelection(1);
			return true;
		}
		else if (EventParms.InputAliasName == 'Select')
		{
			SetFocus(none);
			SelectUnderCursor();
			return true;
		}
	}

    return false;
}

defaultproperties
{
	Fonts(0)=(Font=Font'EngineFonts.SmallFont');
 	Fonts(1)=(Font=Font'UI_Fonts_Final.HUD.MF_Small');
 	Fonts(2)=(Font=Font'UI_Fonts_Final.HUD.MF_Medium');
 	Fonts(3)=(Font=Font'UI_Fonts_Final.HUD.MF_Large');

	ClanTagPerc=0.7
	MiscPerc=1.1
	MainPerc=0.95
	SelBarTex=Texture2D'UI_HUD.HUD.UI_HUD_BaseC'
	AssociatedTeamIndex=-1
	BarPerc=1.2
	bDrawPlayerNum=false

	FakeNames(0)="WWWWWWWWWWWWWWW"
	FakeNames(1)="DrSiN"
	FakeNames(2)="Mysterial"
	FakeNames(3)="Reaper"
	FakeNames(4)="ThomasDaTank"
	FakeNames(5)="Luke Skywalker"
	FakeNames(6)="Indy"
	FakeNames(7)="UTBabe"
	FakeNames(8)="Mulder"
	FakeNames(9)="Starbuck"
	FakeNames(10)="Scully"
	FakeNames(11)="Starbuck"
	FakeNames(12)="Quiet Riot"
	FakeNames(13)="BonusPoint"
	FakeNames(14)="Gripper"
	FakeNames(15)="Midnight"
	FakeNames(16)="too damn tired"
	FakeNames(17)="Spiff"
	FakeNames(18)="Mr. Sckum"
	FakeNames(19)="SkummyBoy"
	FakeNames(20)="DrSiN"
	FakeNames(21)="Mysterial"
	FakeNames(22)="Reaper"
	FakeNames(23)="Mr.PooPoo"
	FakeNames(24)="ThomasDaTank"
	FakeNames(25)="Luke Skywalker"
	FakeNames(26)="Indy"
	FakeNames(27)="UTBabe"
	FakeNames(28)="Mulder"
	FakeNames(29)="Scully"
	FakeNames(30)="Screwy"
	FakeNames(31)="Starbuck"

    TeamColors(0)=(R=51,G=0,B=0,A=255)
    TeamColors(1)=(R=0,G=0,B=51,A=255)

	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Focused')
	SelectedPI=-1

	bMustDrawLocalPRI=true

	FlagTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseE'
	FlagCoords=(U=756,V=0,UL=67,VL=40)

	AllyColor=(R=64,G=128,B=255)
}
