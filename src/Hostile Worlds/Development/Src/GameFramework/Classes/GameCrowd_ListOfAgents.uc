/**
 * This is the class for list of GoreEffect
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class GameCrowd_ListOfAgents extends Object
	hidecategories(Object)
	dependson(SeqAct_GameCrowdSpawner)
	placeable; // needed to show up in the Actor Classes list;

/** List of archetypes of agents to spawn when a population manager or crowd spawner is using this list.  */
var() array<AgentArchetypeInfo> ListOfAgents;

defaultproperties
{

}

