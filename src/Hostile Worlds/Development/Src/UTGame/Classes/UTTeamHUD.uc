/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTTeamHUD extends UTHUD;

var bool bShowDirectional;
var int LastScores[2];
var int ScoreTransitionTime[2];
var vector2D TeamIconCenterPoints[2];
var float LeftTeamPulseTime, RightTeamPulseTime;
var float OldLeftScore, OldRightScore;

/** The scaling modifier will be applied to the widget that coorsponds to the player's team */
var() float TeamScaleModifier;

function DisplayScoring()
{
	Super.DisplayScoring();

	if ( !bIsSplitScreen || bIsFirstPlayer )
	{
		DisplayTeamScore();
	}
}

function DisplayTeamScore()
{
	local float DestScale, W, H, POSX;
	local vector2d Logo;
	local byte TeamIndex;
	local LinearColor TeamLC;
	local color TextC;
	local int NewScore;

	Canvas.DrawColor = WhiteColor;
    W = 214 * ResolutionScaleX;
    H = 87 * ResolutionScale;

	// Draw the Left Team Indicator
	DestScale = 1.0;
	TeamIndex = UTPlayerOwner.GetTeamNum();
	if ( (TeamIndex == 255) || bIsSplitScreen )
	{
		// spectator
		TeamIndex = 0;
		DestScale = TeamScaleModifier;
	}
	GetTeamColor(TeamIndex, TeamLC, TextC);
	POSX = Canvas.ClipX * 0.49 - W;

	Canvas.SetPos(POSX, 0);
	Canvas.DrawTile(IconHudTexture, W * DestScale, H * DestScale, 0, 491, 214, 87, TeamLC);

	NewScore = GetTeamScore(TeamIndex);
	if ( NewScore != OldLeftScore )
	{
		LeftTeamPulseTime = WorldInfo.TimeSeconds;
	}
	OldLeftScore = NewScore;
	
	if (DestScale < 1.0)
	{
		DrawGlowText(string(NewScore), POSX + 97 * ResolutionScaleX, -2 * ResolutionScale, 50 * ResolutionScale, LeftTeamPulseTime, true);
	}
	else
	{
		DrawGlowText(string(NewScore), POSX + 124 * ResolutionScaleX, -2 * ResolutionScale, 60 * ResolutionScale, LeftTeamPulseTime, true);
	}

	Logo.X = POSX + ((TeamIconCenterPoints[0].X) * DestScale * ResolutionScaleX) + (30 * ResolutionScaleX);
	Logo.Y = ((TeamIconCenterPoints[0].Y) * DestScale * ResolutionScale) + (27.5 * ResolutionScale);


   	DisplayTeamLogos(TeamIndex,Logo, 1.5);

	// Draw the Right Team Indicator
	DestScale = TeamScaleModifier;
	TeamIndex = 1 - TeamIndex;
	GetTeamColor(TeamIndex, TeamLC, TextC);
	POSX = Canvas.ClipX * 0.51;

	NewScore = GetTeamScore(TeamIndex);
	if ( NewScore != OldRightScore )
	{
		RightTeamPulseTime = WorldInfo.TimeSeconds;
	}
	OldRightScore = NewScore;

	Canvas.SetPos(POSX,0);
	Canvas.DrawTile(IconHudTexture, W * DestScale, H * DestScale, 0, 582, 214, 87, TeamLC);
	Canvas.DrawColor = WhiteColor;
	DrawGlowText(string(NewScore), POSX + 0.66*W, -4 * ResolutionScaleX, 50 * ResolutionScale, RightTeamPulseTime, true);

	Logo.X = (POSX + (TeamIconCenterPoints[1].X) * DestScale * ResolutionScaleX) + (30 * ResolutionScaleX);
	Logo.Y = ((TeamIconCenterPoints[1].Y) * DestScale * ResolutionScale) + (27.5 * ResolutionScale);
   	DisplayTeamLogos(TeamIndex,Logo, 1.0);
}

function int GetTeamScore(byte TeamIndex)
{
	if( (TeamIndex == 0 || TeamIndex == 1) && (UTGRI != None) && (UTGRI.Teams[TeamIndex] != None) )
	{
		return INT(UTGRI.Teams[TeamIndex].Score);
	}
	else
	{
		return 0;
	}

}

function Actor GetDirectionalDest(byte TeamIndex)
{
	return none;
}

function DisplayTeamLogos(byte TeamIndex, vector2d POS, optional float DestScale=1.0)
{
	if ( bShowDirectional )
	{
		DisplayDirectionIndicator(TeamIndex, POS, GetDirectionalDest(TeamIndex), DestScale );
	}
}

function DisplayDirectionIndicator(byte TeamIndex, vector2D POS, Actor DestActor, float DestScale)
{
	local rotator Dir,Angle;
	local vector start;

	if ( DestActor != none )
	{
		Start = (PawnOwner != none) ? PawnOwner.Location : UTPlayerOwner.Location;
		Dir  = Rotator(DestActor.Location - Start);
		Angle.Yaw = (Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535;


		// Boost the colors a bit to make them stand out
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(POS.X - (28.5 * DestScale * ResolutionScaleX), POS.Y - (26 * DestScale * ResolutionScale));
		Canvas.DrawRotatedTile( AltHudTexture, Angle, 57 * DestScale * ResolutionScaleX, 52 * DestScale * ResolutionScale, 897, 452, 43, 43);
	}
}

defaultproperties
{
	bHasLeaderboard=false
	bShowDirectional=false

`if(`notdefined(MOBILE))
	ScoreboardSceneTemplate=UTUIScene_TeamScoreboard'UI_Scenes_Scoreboards.sbTeamDM'
`endif
	TeamScaleModifier=0.75

	TeamIconCenterPoints(0)=(x=140.0,y=27.0)
	TeamIconCenterPoints(1)=(x=5,y=13)

}

