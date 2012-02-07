/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleCTFGame_Content extends UTVehicleCTFGame;

var class<UTVehicle> HoverboardClass;

/* SetPlayerDefaults()
 * Give appropriate hoverboard class to UTPawns
  */
function SetPlayerDefaults(Pawn PlayerPawn)
{
	if ( UTPawn(PlayerPawn) != None )
	{
		UTPawn(PlayerPawn).HoverboardClass = HoverboardClass;
	}
	super.SetPlayerDefaults(PlayerPawn);
}

defaultproperties
{
	HUDType=class'UTGame.UTVehicleCTFHUD'

	AnnouncerMessageClass=class'UTCTFMessage'
 	TeamScoreMessageClass=class'UTGameContent.UTTeamScoreMessage'

	HoverboardClass=class'UTVehicle_Hoverboard_Content'
}
