/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTGFxTeamHUDWrapper extends UTGFxHUDWrapper;

/** 
  * Support for displaying CTF flag status messages
  */
simulated function Timer()
{
	local UTPlayerReplicationInfo PawnOwnerPRI;

	Super.Timer();

	if ( Pawn(PlayerOwner.ViewTarget) == None )
		return;

	PawnOwnerPRI = UTPlayerReplicationInfo(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo);

	if ( (PawnOwnerPRI == None)
		|| (PlayerOwner.IsSpectating() && UTPlayerOwner.bBehindView) )
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

defaultproperties
{
	MinimapHUDClass=class'UTGFxTeamHUD'
}