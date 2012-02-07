/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFHUD extends UTTeamHUD;

var UTCTFBase FlagBases[2];
var EFlagState FlagStates[2];

simulated function PostBeginPlay()
{
	local UTCTFBase CTFBase;
	Super.PostBeginPlay();
	ForEach WorldInfo.AllNavigationPoints(class'UTCTFBase', CTFBase)
	{
		if (CTFBase.DefenderTeamIndex < 2)
		{
			FlagBases[CTFBase.DefenderTeamIndex] = CTFBase;
		}
	}

	SetTimer(1.0, True);

}

simulated function Timer()
{
	local UTPlayerReplicationInfo PawnOwnerPRI;

	Super.Timer();

	if ( Pawn(PlayerOwner.ViewTarget) == None )
		return;

	PawnOwnerPRI = UTPlayerReplicationInfo(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo);

    if ( (PawnOwnerPRI == None)
		|| (PlayerOwner.IsSpectating() && UTPlayerController(PlayerOwner).bBehindView) )
	return;

	if ( (UTGRI != None) && (PawnOwnerPRI.Team != None)
		&& UTGRI.FlagIsHeldEnemy(PawnOwnerPRI.Team.TeamIndex) )
	{
		if ( PawnOwnerPRI.bHasFlag )
		{
			PlayerOwner.ReceiveLocalizedMessage( class'UTCTFHUDMessage', 2 );
		}
		else
		{
			PlayerOwner.ReceiveLocalizedMessage( class'UTCTFHUDMessage', 1 );
		}
	}
	else if ( PawnOwnerPRI.bHasFlag )
	{
		PlayerOwner.ReceiveLocalizedMessage( class'UTCTFHUDMessage', 0 );
	}
}

function DisplayTeamLogos(byte TeamIndex, vector2d POS, optional float DestScale=1.0)
{
	local linearColor Alpha;
	local linearColor TC,Black;
	local float Modifier;
	local color TTC;

	Super.DisplayTeamLogos(TeamIndex, Pos, DestScale);

	GetTeamColor(TeamIndex, TC, TTC);
	Alpha = ColorToLinearColor(LightGoldColor);

	Black.A=1.0;

	TC.A = 1.0;
	Modifier = 1.0 + (0.5 * Abs(cos(WorldInfo.TimeSeconds * 3)));//0.25 + ( 0.75 * Abs(cos(WorldInfo.TimeSeconds * 3)));

	DestScale *= ResolutionScale * 0.7;

	if (UTGRI != None && (TeamIndex == 0 || TeamIndex == 1))
	{
		switch (UTGRI.FlagState[TeamIndex])
		{
		case FLAG_Home:
		case FLAG_Down:
			Canvas.SetPos(POS.X, POS.Y + (7*DestScale));
			DrawTileCentered(AltHudTexture, 46 * DestScale, 44 * DestScale, 843,86,46,44,TC);

			if ( UTGRI.FlagState[TeamIndex] == FLAG_Down )
			{
			    Canvas.SetPos(POS.X-2, POS.Y - (7 * DestScale * Modifier)+2);
				Canvas.DrawTile(AltHudTexture, 27 * DestScale * Modifier, 27 * DestScale * Modifier, 893,0,27,37,BLACK);

			    Canvas.SetPos(POS.X, POS.Y - (7 * DestScale * Modifier));
				Canvas.DrawTile(AltHudTexture, 27 * DestScale * Modifier, 27 * DestScale * Modifier, 893,0,27,37,Alpha);
			}

			break;

		case FLAG_HeldEnemy:

        	DestScale *=  Modifier;

			Canvas.SetPos(POS.X - (20 * DestScale), POS.Y - (22*DestScale));
			Canvas.DrawTile(AltHudTexture,27*DestScale, 27*DestScale,893,64,27,27,TC);

			Canvas.SetPos(POS.X-8, POS.Y - (15*DestScale)+2);
			Canvas.DrawTile(AltHudTexture,40*DestScale , 38*DestScale,843,48,40,38,BLACK);

			Canvas.SetPos(POS.X-6, POS.Y - (15*DestScale));
			Canvas.DrawTile(AltHudTexture,40*DestScale , 38*DestScale,843,48,40,38,Alpha);

			break;
		}
	}

}


function Actor GetDirectionalDest(byte TeamIndex)
{
	if( TeamIndex == 0 || TeamIndex == 1 )
	{
		return FlagBases[TeamIndex];
	}
	else
	{
		return none;
	}

}

defaultproperties
{
	bShowDirectional=true
	bShowFragCount=false
`if(`notdefined(MOBILE))
	ScoreboardSceneTemplate=Scoreboard_CTF'UI_Scenes_Scoreboards.sbCTF'
`endif
	MapPosition=(X=0.99,Y=0.01)
}

