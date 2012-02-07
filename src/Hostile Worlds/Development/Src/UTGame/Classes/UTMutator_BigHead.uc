// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_BigHead extends UTMutator;

/* called by GameInfo.RestartPlayer()
	change the players jumpz, etc. here
*/
function ModifyPlayer(Pawn P)
{
	if ( UTPawn(P) != None )
	{
		UTPawn(P).SetBigHead();
	}
	Super.ModifyPlayer(P);
}

defaultproperties
{
	GroupNames[0]="BIGHEAD"
}


