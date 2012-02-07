/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTActorFactoryAI extends ActorFactoryAI;

var() bool bForceDeathmatchAI;

/** Try and use physics hardware for this spawned object. */
var() bool bUseCompartment;

/** 
  * Initialize factory created bot 
  */
simulated event PostCreateActor(Actor NewActor)
{
	local UTBot Bot;
	local Pawn NewPawn;
	local int idx;

	NewPawn = Pawn(NewActor);
	
	if ( NewPawn != None )
	{
		// give the pawn a controller here, since we don't define a ControllerClass
		Bot = NewPawn.Spawn(class'UTBot',,, NewPawn.Location, NewPawn.Rotation);
		if ( Bot != None )
		{
			// handle the team assignment
			Bot.SetTeam(TeamIndex);
			// force the controller to possess, etc
			Bot.Possess(newPawn, false);

			if ( bForceDeathmatchAI )
			{
				Bot.Squad = Bot.Spawn(class'UTSquadAI');
				if (Bot.Squad != None)
				{
					if (Bot.PlayerReplicationInfo != None)
					{
						Bot.Squad.Team = UTTeamInfo(Bot.PlayerReplicationInfo.Team);
					}
					UTSquadAI(Bot.Squad).SetLeader(Bot);
				}
			}
	
			if (Bot.PlayerReplicationInfo != None && PawnName != "" )
				Bot.PlayerReplicationInfo.SetPlayerName(PawnName);
		}

		// create any inventory
		if (bGiveDefaultInventory && newPawn.WorldInfo.Game != None)
		{
			newPawn.WorldInfo.Game.AddDefaultInventory(newPawn);
		}
		for ( idx=0; idx<InventoryList.Length; idx++ )
		{
			newPawn.CreateInventory( InventoryList[idx], false  );
		}
		
		/* FIXMESTEVE
		// Set the 'use hardware for physics' flag as desired on the spawned Pawn.
		if( bUseCompartment && (NewPawn.Mesh != None) )
		{
			NewPawn.Mesh.bUseCompartment = true;
		}
		*/
	}
}

defaultproperties
{
	ControllerClass=None
}
