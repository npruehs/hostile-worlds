/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTGFxTeamHUD extends GFxMinimapHUD;

function UpdateGameHUD(UTPlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo MaxPRI;
	local int j, CurScores[2];
	local GFxObject.ASDisplayInfo DI;
	local UTTeamInfo Team;

	CurScores[0] = GRI.Teams[0].Score;
	CurScores[1] = GRI.Teams[1].Score;

	for (j = 0; j < 2; j++)
	{
		if (LastScore[j] != CurScores[j])
		{
			LastScore[j] = CurScores[j];
			if (CurScores[j] > -100000)
				ScoreTF[j].SetText(CurScores[j]);
			else
				ScoreTF[j].SetText("");
			DI.hasXScale = true;
			DI.XScale = FMax(0.0, (100.0 * float(LastScore[j])) / float(GRI.GoalScore));
			ScoreBarMC[j].SetDisplayInfo(DI);
		}

		Team = UTTeamInfo(GRI.Teams[j]);

		if (Team.TeamFlag != none)
		{
			MaxPRI = Team.TeamFlag.HolderPRI;

			if (LastFlagCarrier[j] != MaxPRI)
			{
				LastFlagCarrier[j] = MaxPRI;
				FlagCarrierTF[j].SetText(MaxPRI != none ? MaxPRI.PlayerName : "");
			}
			if (LastFlagHome[j] != byte(Team.TeamFlag.bHome))
			{
				LastFlagHome[j] = byte(Team.TeamFlag.bHome);
				FlagCarrierMC[j].SetVisible(LastFlagHome[j] == 0);
			}
		}
		else
		{
			FlagCarrierMC[j].SetVisible(false);
		}
	}
}

function string GetRank(PlayerReplicationInfo PRI)
{
	return "";
}

defaultproperties
{
	bIsTeamHUD=true
}
