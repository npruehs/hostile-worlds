/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

/**
 * Scoreboard implementation.
 * Related Flash content:   ut3_scoreboard.fla
 * 
 */
class GFxUIScoreboard extends UTGFxTweenableMoviePlayer;

var GFxObject RootMC;
var GFxObject ScoreboardMC, OverlayMC, TitleMC, BlueTeamMC, RedTeamMC;
var GFxObject TimeMC, TimeTF, Title_TitleGMC, TitleTF, TitleGMC;

var GFxObject BlueHeaderMC, BlueScoreTF, BlueTitleTF;
var GFxObject RedHeaderMC, RedScoreTF, RedTitleTF;

var GFxObject FooterMC, FooterItemMC;

var byte RedTeamIndex, BlueTeamIndex;
var GFxObject PlayerRow;

var bool bPlayerRowTween;
var bool bTeamGame;

struct ScoreEntry
{
	var string PlayerName;
	var int PlayerScore;
	var int PlayerDeaths;
	var bool bHasFlag;
};

/** Cached version of data being displayed by scoreboard - used to avoid querying/updating Flash UI unnecessarily (for performance) */
var ScoreEntry RedEntries[12], BlueEntries[12];

struct ScoreboardState
{
    var int     RemainingTime;
    var int     RedScore;
    var int     BlueScore;
	var String	PlayerName;		
	var byte    PlayerPlace;
	var float	PlayerScore;
	var int		PlayerDeaths;
};

var ScoreboardState PreviousState;

struct ScoreRow
{
    var GFxObject MovieClip;
	var GFxObject InnerMovieClip;
    var GFxObject DeathsTF;
    var GFxObject ScoreTF;
    var GFxObject NameTF;
};

var array<ScoreRow> BlueItems, RedItems;

var transient int NameCnt;

/** Comment. */
var GFxObject Footer_NameTF;

/** Comment. */
var GFxObject Footer_PlaceLabelTF;

/** Comment. */
var GFxObject Footer_PlaceTF;

/** Comment. */
var GFxObject Footer_ScoreLabelTF;

/** Comment. */
var GFxObject Footer_ScoreTF;

/** Comment. */
var GFxObject Footer_DeathsLabelTF;

/** Comment. */
var GFxObject Footer_DeathsTF;

var bool bInitialized;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

	if (!bInitialized)
	{		
		ConfigScoreboard();		
	}	

	Draw();

    return true;
}

function PlayOpenAnimation()
{	
	TitleMC.GotoAndPlay("open");
	FooterMC.GotoAndPlay("open");
    OverlayMC.GotoAndPlay("open");	
}

function PlayCloseAnimation()
{	
	TitleMC.GotoAndPlay("close");
	FooterMC.GotoAndPlay("close");
	OverlayMC.GotoAndPlay("close");	
}

/*
 * Cache references to Scoreboard's MovieClips for later use.
 */
function ConfigScoreboard()
{
	local PlayerController PC;
	
	RootMC = GetVariableObject("_root");
	ScoreboardMC = RootMC.GetObject("scoreboard");

	// Scale and shift for 16:9.  Last minute hack.
	RootMC.SetFloat("_xscale", 95);
	RootMC.SetFloat("_yscale", 95);
	RootMC.SetFloat("_y", RootMC.GetFloat("_y")+25);

	PC = GetPC();		
	if (PC != none)
	{
		bTeamGame = UTGFxTeamHUDWrapper(PC.MyHUD) != None;
		if ( bTeamGame )
		{
			ScoreboardMC.GotoAndStop("tdm");	
			OverlayMC = ScoreboardMC.GetObject("team");
			BlueTeamMC = OverlayMC.GetObject("blue_team");
			RedTeamMC = OverlayMC.GetObject("red_team");
		}
		else
		{
			ScoreboardMC.GotoAndStop("dm");
			OverlayMC = ScoreboardMC.GetObject("dm");
			RedTeamMC = ScoreboardMC.GetObject("dm");
		}
	}

	TitleMC = ScoreboardMC.GetObject("title");
	
	TimeMC = TitleMC.GetObject("time");
	Title_TitleGMC = TitleMC.GetObject("title_g");

	TimeTF = TimeMC.GetObject("textField");
	TitleTF = Title_TitleGMC.GetObject("textField");

	FooterMC = ScoreboardMC.GetObject("footer");
	FooterItemMC = FooterMC.GetObject("footer_item");
	Footer_NameTF = FooterItemMC.GetObject("name");
	Footer_PlaceLabelTF = FooterItemMC.GetObject("tplace");
	Footer_PlaceTF = FooterItemMC.GetObject("place");
	Footer_ScoreLabelTF = FooterItemMC.GetObject("tscore");
	Footer_ScoreTF = FooterItemMC.GetObject("score");
	Footer_DeathsLabelTF = FooterItemMC.GetObject("tdeaths");
	Footer_DeathsTF = FooterItemMC.GetObject("deaths");	

	PreviousState.PlayerDeaths = -1;
	PreviousState.PlayerScore = -1.0;
	PreviousState.PlayerPlace = -1;	

	Footer_PlaceLabelTF.SetText("YOUR PLACEMENT");
	Footer_ScoreLabelTF.SetText("SCORE");
	Footer_DeathsLabelTF.SetText("DEATHS");
		
	SetupRedTeam();
	if (bTeamGame)
	{
		SetupBlueTeam();
	}

	FloatScoreboardAnimationX(true);
    FloatScoreboardAnimationY(true);

	bInitialized = true;
}

/*
 * Cache references to MovieClips used for the Blue Team.
 */
function SetupBlueTeam()
{
    local byte i;    
    local ScoreRow sr;
    local ASDisplayInfo dI;

    for (i = 0; i < 12; i++)
    {
        BlueItems[i] = sr;
        BlueItems[i].MovieClip = BlueTeamMC.GetObject("item"$(i+1));
        BlueItems[i].MovieClip.SetFloat("_z", 200);

		// Give 50% Alpha blend to all rows.
		// Non-empty rows will be corrected to 100% later.
        dI = BlueItems[i].MovieClip.GetDisplayInfo();
        dI.Alpha = 50.0;
        BlueItems[i].MovieClip.SetDisplayInfo(dI);

        BlueItems[i].InnerMovieClip = BlueItems[i].MovieClip.GetObject("item_g");
        BlueItems[i].DeathsTF   = BlueItems[i].InnerMovieClip.GetObject("deaths");
        BlueItems[i].ScoreTF    = BlueItems[i].InnerMovieClip.GetObject("score");
        BlueItems[i].NameTF     = BlueItems[i].InnerMovieClip.GetObject("name");
    }

    BlueHeaderMC = BlueTeamMC.GetObject("header");
	BlueHeaderMC.GetObject("header1").SetFloat("_z", 200);
    BlueScoreTF = BlueHeaderMC.GetObject("score").GetObject("textField");
    BlueTitleTF = BlueHeaderMC.GetObject("title").GetObject("textField");
}

/*
 * Cache references to MovieClips used for the Red Team.
 */
function SetupRedTeam()
{
    local byte i;    
    local ScoreRow sr;
    local ASDisplayInfo dI;

    for (i = 0; i < 12; i++)
    {
        RedItems[i] = sr;
        RedItems[i].MovieClip = RedTeamMC.GetObject("item"$(i+1));
        RedItems[i].MovieClip.SetFloat("_z", 200);

		// Give 50% Alpha blend to all rows.
		// Non-empty rows will be corrected to 100% later.
        dI = RedItems[i].MovieClip.GetDisplayInfo();
        dI.Alpha = 50.0f;
        RedItems[i].MovieClip.SetDisplayInfo(dI);

        RedItems[i].InnerMovieClip = RedItems[i].MovieClip.GetObject("item_g");
        RedItems[i].DeathsTF    =  RedItems[i].InnerMovieClip.GetObject("deaths");
        RedItems[i].ScoreTF     =  RedItems[i].InnerMovieClip.GetObject("score");
        RedItems[i].NameTF      =  RedItems[i].InnerMovieClip.GetObject("name");
    }

    RedHeaderMC = RedTeamMC.GetObject("header");
	RedHeaderMC.GetObject("header1").SetFloat("_z", 200);
    RedScoreTF = RedHeaderMC.GetObject("score").GetObject("textField");
    RedTitleTF = RedHeaderMC.GetObject("title").GetObject("textField");
}


/*
 * Initial setup of Scoreboard.
 */
function Draw()
{
    local UTGameReplicationInfo GRI;
	local PlayerController PC;

	PC = GetPC();
    if (PC != none)
	{
        GRI = UTGameReplicationInfo(PC.WorldInfo.GRI);
	}
	bTeamGame = UTGFxTeamHUDWrapper(PC.MyHUD) != None;

	if ( !bTeamGame )
	{
		RedTitleTF.SetText(Caps("<Strings:UTGameUI.JoinGame.Players>"));
	}

	if ( GRI != None )
	{
		TitleTF.SetText(GRI.GameClass.default.GameName);
		UpdateHeaders(GRI);
		UpdatePreviousState(GRI);
	}
}

/** 
  *  Make sure the PRI lists reflect current player state
  */
function UpdatePRILists(UTGameReplicationInfo GRI)
{
	local int i, redPlayers, bluePlayers;
	local UTPlayerReplicationInfo PRI;
	local GFxObject NewPlayerRow;

	redPlayers = 0;
	bluePlayers = 0;

	// Set up lists of Red/Blue players - each list only has 12 slots.
	for ( i=0; i<GRI.PRIArray.Length; i++ )
	{
		PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
		
		if ( PRI != none && IsValidScoreboardPlayer(PRI) )
		{
			NewPlayerRow = None;
			if ( (PRI.Team == None) || (PRI.Team.TeamIndex == RedTeamIndex) )
			{
				if ( !PRI.bOnlySpectator && (redPlayers < 12) )
				{
					NewPlayerRow = RedItems[redPlayers].MovieClip;
					UpdateRow(RedItems[redPlayers], RedEntries[redPlayers], PRI);
					redPlayers++;
				}
			}
			else if ( (PRI.Team.TeamIndex == BlueTeamIndex) && (bluePlayers < 12) )
			{
				NewPlayerRow = BlueItems[BluePlayers].MovieClip;
				UpdateRow(BlueItems[BluePlayers], BlueEntries[BluePlayers], PRI);
				bluePlayers++;
			}
			if ( PRI.IsLocalPlayerPRI() )
			{
				if ( PlayerRow != NewPlayerRow )
				{
					SetPlayerRow(NewPlayerRow);
				}
				UpdateFooter(GRI, PRI, i);
			}
		}
	}

	// clear now empty rows
	for ( i=RedPlayers; i<12; i++ )
	{
		if ( RedEntries[i].PlayerName != "" )
		{
			RedEntries[i].PlayerName = "";
			ClearRow(RedItems[i]);
		}
	}

	for ( i=BluePlayers; i<12; i++ )
	{
		if ( BlueEntries[i].PlayerName != "" )
		{
			BlueEntries[i].PlayerName = "";
			ClearRow(BlueItems[i]);
		}
	}
}

/** 
  *  Clear all data displayed on scoreboard row ThisRow
  */
function ClearRow(ScoreRow ThisRow)
{
	local ASDisplayInfo displayInfo;

	displayInfo = ThisRow.MovieClip.GetDisplayInfo();
	displayInfo.Alpha = 50.0;
	ThisRow.MovieClip.SetDisplayInfo(displayInfo);
	ThisRow.ScoreTF.SetText("");
	ThisRow.DeathsTF.SetText("");
	ThisRow.NameTF.SetString("htmlText", "");
}

/** 
  * Check if current and cached version of score info matches, if not update Flash UI.
  * Avoid updating Flash UI unnecessarily because of performance cost.
  * @PARAM ThisRow is the GFx object holding this row of scoreboard info
  * @PARAM ThisEntry is the cached info about the current settings of ThisRow
  * @PARAM ThisPRI is the PRI whose state needs to be reflected in ThisRow
  */
function UpdateRow(ScoreRow ThisRow, out ScoreEntry ThisEntry, UTPlayerReplicationInfo ThisPRI)
{
	local ASDisplayInfo displayInfo;
	local bool bUpdateItemRenderer;		
	local String NameAndFlagText;
	local array<ASValue> args;
	
	bUpdateItemRenderer = false;	

	// update row if it has changed
	if ( (ThisPRI.PlayerName != ThisEntry.PlayerName) || (ThisPRI.bHasFlag != ThisEntry.bHasFlag) )
	{
		if ( ThisEntry.PlayerName == "" )
		{
			// need to initialize the row's displayinfo since wasn't displayed
			displayInfo = thisRow.MovieClip.GetDisplayInfo();
			displayInfo.Alpha = 100.0;
			ThisRow.MovieClip.SetDisplayInfo(displayInfo);

			// force update score and deaths (so 0s will be displayed)
			ThisRow.ScoreTF.SetText(string(int(ThisPRI.Score)));
			ThisEntry.PlayerScore = ThisPRI.Score;
			ThisRow.DeathsTF.SetText(string(ThisPRI.Deaths));
			ThisEntry.PlayerDeaths = ThisPRI.Deaths;
		}

		NameAndFlagText = "";
		if (ThisPRI.bHasFlag)
		{
			NameAndFlagText $= "<img src=\"flag_noglow\">&nbsp;";
		}		

		NameAndFlagText $= ThisPRI.PlayerName;
		ThisEntry.PlayerName = ThisPRI.PlayerName;
		ThisEntry.bHasFlag = ThisPRI.bHasFlag;
		bUpdateItemRenderer = true;
	}
	if ( ThisPRI.Score != ThisEntry.PlayerScore )
	{		
		ThisEntry.PlayerScore = ThisPRI.Score;
		bUpdateItemRenderer = true;
	}
	if ( ThisPRI.Deaths != ThisEntry.PlayerDeaths )
	{			
		ThisEntry.PlayerDeaths = ThisPRI.Deaths;
		bUpdateItemRenderer = true;
	}	

	if (bUpdateItemRenderer)
	{	
		args.length = 0;
		ThisRow.InnerMovieClip.SetString("PlayerName", NameAndFlagText);
		ThisRow.InnerMovieClip.SetString("PlayerScore", String(ThisEntry.PlayerScore));
		ThisRow.InnerMovieClip.SetString("PlayerDeaths", String(ThisEntry.PlayerDeaths));
		ThisRow.InnerMovieClip.Invoke("UpdateAfterStateChange", args);		
	}
}

function Tick(Float DeltaTime)
{
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(GetPC().WorldInfo.GRI);
	if ( GRI != None )
	{
		UpdatePRILists(GRI);
		UpdateHeaders(GRI);
		UpdatePreviousState(GRI);	
	}

	super.Tick(DeltaTime);
}

/*
 * Manage this player's row. The this row will have a 3D Tween
 * and yellow text. Revert the previous player's row to default 
 * if necessary.
 */
function SetPlayerRow(GFxObject UpdatedPlayerRow)
{
    if (PlayerRow != none)
    {
        ClearsTweensOnMovieClip(PlayerRow);
		PlayerRow.SetFloat("_z", 200); // Force the Z change if the TweenManager refuses to behave.
        PlayerRow.GetObject("item_g").GotoAndStop("default");
    }
	PlayerRow = UpdatedPlayerRow;

	if ( PlayerRow != None )
	{
		TweenPlayerRow(UpdatedPlayerRow);
		PlayerRow.GetObject("item_g").GotoAndStop("player");
	}
}

/*
 * Store the current Game State. Data is used for checking if an update
 * to the view is necessary.
 */
function UpdatePreviousState(UTGameReplicationInfo GRI)
{
    PreviousState.RemainingTime = GRI.RemainingTime;  	

    if (bTeamGame)
    {
		PreviousState.RedScore = GRI.Teams[RedTeamIndex].Score;
        PreviousState.BlueScore = GRI.Teams[BlueTeamIndex].Score;
    }
}

static function string FormatTime(int Seconds)
{
	local int Hours, Mins;
	local string NewTimeString;

	Hours = Seconds / 3600;
	Seconds -= Hours * 3600;
	Mins = Seconds / 60;
	Seconds -= Mins * 60;
	if (Hours > 0)
		NewTimeString = ( Hours > 9 ? String(Hours) : "0"$String(Hours)) $ ":";
	NewTimeString = NewTimeString $ ( Mins > 9 ? String(Mins) : "0"$String(Mins)) $ ":";
	NewTimeString = NewTimeString $ ( Seconds > 9 ? String(Seconds) : "0"$String(Seconds));

	return NewTimeString;
}

/*
 * Updates the following text fields:
 *      Red Team's Score
 *      Blue Team's Score
 *      Remaining Time
 */
function UpdateHeaders(UTGameReplicationInfo GRI)
{
    if (bTeamGame)
    {
		if (PreviousState.RedScore != GRI.Teams[RedTeamIndex].Score)
			RedScoreTF.SetText(Min(GRI.Teams[RedTeamIndex].Score, 9999));

        if (PreviousState.BlueScore != GRI.Teams[BlueTeamIndex].Score)
            BlueScoreTF.SetText(Min(GRI.Teams[BlueTeamIndex].Score, 9999));
    }

    if (GRI.RemainingTime != PreviousState.RemainingTime)
        TimeTF.SetText(FormatTime(GRI.TimeLimit != 0 ? GRI.RemainingTime : GRI.ElapsedTime));
}

/*
 * Updates the footer with information relevant to the player.
 */
function UpdateFooter(UTGameReplicationInfo GRI, UTPlayerReplicationInfo LocalPlayerPRI, optional byte PRIIndex)
{	
	local byte PlayerRelRank;
	local byte PlayerTeamIndex;

	// Discover the place.
	if (!bTeamGame)
	{
		// If it's a deathmatch, the player's index in the array is equivalent to his placement.
		PlayerRelRank = PRIIndex+1;
	}
	else 
	{
		// If it's a team game, check if the player's team is winning.
		PlayerTeamIndex = LocalPlayerPRI.GetTeamNum();	
		if (GRI.Teams[RedTeamIndex].Score > GRI.Teams[BlueTeamIndex].Score && PlayerTeamIndex == RedTeamIndex)
		{
			PlayerRelRank = 1;
		}
		else 
		{
			PlayerRelRank = 2;
		}
	}

	// Update the footer as necessary.
	if (PreviousState.PlayerPlace != PlayerRelRank)
	{
		Footer_PlaceTF.SetText(String(PlayerRelRank));	
	}
	if (PreviousState.PlayerScore != LocalPlayerPRI.Score)
	{
		Footer_ScoreTF.SetText(String(int(LocalPlayerPRI.Score)));
	}
	if (PreviousState.PlayerName != LocalPlayerPRI.PlayerName)
	{
		Footer_NameTF.SetText(LocalPlayerPRI.PlayerName);	
	}	
	if (PreviousState.PlayerDeaths != LocalPlayerPRI.Deaths)
	{
		Footer_DeathsTF.SetText(String(LocalPlayerPRI.Deaths));			
	}

	// Update the previous state for the player. Left here for time's sake.
	PreviousState.PlayerName = LocalPlayerPRI.PlayerName;
	PreviousState.PlayerScore = int(LocalPlayerPRI.Score);
	PreviousState.PlayerDeaths = LocalPlayerPRI.Deaths;	
	PreviousState.PlayerPlace = PlayerRelRank;
}

/* 
 * Tween for constant _xrotation of Scoreboard. 
 */
function FloatScoreboardAnimationX(bool direction)
{
    if (direction)
        TweenTo(ScoreboardMC, 5.0, "_xrotation", 4, TWEEN_Linear, "FloatScoreboard1");
    else
        TweenTo(ScoreboardMC, 5.0, "_xrotation", -4, TWEEN_Linear, "FloatScoreboard2");
}

/* 
 * Tween for constant _yrotation of Scoreboard.
 */
function FloatScoreboardAnimationY(bool direction)
{
    if (direction)
        TweenTo(ScoreboardMC, 7.0, "_yrotation", 7.0, TWEEN_Linear, "FloatScoreboard3");
    else
        TweenTo(ScoreboardMC, 7.0, "_yrotation", -7.0, TWEEN_Linear, "FloatScoreboard4");
}

/* 
 * Z tween for the player's row.
 */
function TweenPlayerRow(GFxObject RowMC)
{
    if (bPlayerRowTween)
       TweenTo(RowMC, 1.5, "_z", -450, TWEEN_Linear, "TweenPlayerRow");
    else
       TweenTo(RowMC, 1.5, "_z", 0, TWEEN_Linear, "TweenPlayerRow");

    bPlayerRowTween = !bPlayerRowTween;
}

/*
 * Callback processor for TweenManager. Interface from UTGFxTweenableMoviePlayer.
 */
function ProcessTweenCallback(String Callback, GFxObject TargetMC)
{
     switch(Callback)
     {
        case ("TweenPlayerRow"):
            TweenPlayerRow(TargetMC);
        break;
        case ("FloatScoreboard1"):
            FloatScoreboardAnimationX(false);
        break;
        case ("FloatScoreboard2"):
            FloatScoreboardAnimationX(true);
        break;
        case ("FloatScoreboard3"):
            FloatScoreboardAnimationY(false);
        break;
        case ("FloatScoreboard4"):
            FloatScoreboardAnimationY(true);
        break;
        default:
        break;
     }
}


/**
 * Tests a PRI to see if we should display it on the scoreboard
 *
 * @Param PRI		The PRI to test
 * @returns TRUE if we should display it, returns FALSE if we shouldn't
 */
function bool IsValidScoreboardPlayer( UTPlayerReplicationInfo PRI)
{
	if ( !PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
		(PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None)) )
	{
		return false;
	}

	return true;
}

/**
 * Returns the time online as a string
 */
function string GetTimeOnline(UTPlayerReplicationInfo PRI)
{
	return ""@ class'UTHUD'.static.FormatTime( PRI.WorldInfo.GRI.ElapsedTime );
}

defaultproperties
{
    BlueTeamIndex = 1
    RedTeamIndex = 0
    bPlayerRowTween = false

    bDisplayWithHudOff=TRUE
    bEnableGammaCorrection=FALSE
    bTeamGame=FALSE
	MovieInfo=SwfMovie'UDKHud.udk_scoreboard'
}
