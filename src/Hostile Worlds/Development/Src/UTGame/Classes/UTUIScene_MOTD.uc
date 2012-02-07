/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_MOTD extends UTUIScene_Hud;

var bool bFadingOut;
var transient UISafeRegionPanel Panel;
var transient UTDrawPanel DrawPanel;


event TickScene(float DeltaTime)
{
	local LocalPlayer LP;

	if ( !bFadingOut )
	{
		LP = GetPlayerOwner(0);
		if ( (LP != None) && (LP.Actor != None) && (LP.Actor.PlayerReplicationInfo != None) && !LP.Actor.PlayerReplicationInfo.bIsSpectator )
		{
			Finish();
		}
	}
}

event PostInitialize()
{
	local worldinfo WI;
	local UTGameReplicationInfo GRI;
	local class<UTGame> GC;
	local UILabel Lbl;
	Super.PostInitialize();

	Panel = UISafeRegionPanel(FindChild('SafePanel',true));
//	Panel.PlayUIAnimation('FadeIn',,,0.5);

	WI = GetWorldInfo();
	if ( WI != none )
	{
		GC = class<UTGame>(WI.GetGameClass());
		GRI = UTGameReplicationInfo(WI.GRI);
		if (GRI != none && GC != none)
		{
		 	Lbl = UILabel(FindChild('ServerRules',true));
		 	if ( Lbl != none )
		 	{
		 		Lbl.SetDatastorebinding( GC.static.GetEndOfMatchRules(GRI.GoalScore, GRI.TimeLimit) );
		 	}
		}
	}
}

event Finish()
{
	bFadingOut = true;
	Panel.PlayUIAnimation('FadeOut',,,0.5);
}

event UIAnimationEnded( UIScreenObject AnimTarget, name AnimName, int TrackType )
{
	Super.UIAnimationEnded(AnimTarget, AnimName, TrackType);
	if (AnimName == 'FadeOut')
	{
		SceneClient.CloseScene(Self);
	}
}

defaultproperties
{
}
