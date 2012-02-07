/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/
class SeqAct_GameCrowdPopulationManagerToggle extends SequenceAction
	dependsOn(SeqAct_GameCrowdSpawner)
	native;

/** Percentage of max population to immediately spawn when the population manager is toggled on (without respecting visibility checks).  Range is 0.0 to 1.0 */
var() float	WarmupPct;

/** If true, destroy all crowd agents instantly when the population manager is disabled, instead of  letting them die off slowly as they lose relevance */
var() bool	bKillAgentsInstantly;

/** List of Archetypes of agents for pop manager to spawn when this is toggled on */
var() GameCrowd_ListOfAgents	CrowdAgentList;

/** If true, clear old population manager archetype list rather than adding to it with this toggle action's CrowdAgentList. */
var() bool	bClearOldArchetypes;

/** The maximum number of agents alive at one time. */
var() int	MaxAgents;

/** How many agents per second will be spawned at the target actor(s).  */
var() float	SpawnRate;

/** Whether to enable the light environment on crowd members. */
var() bool	bEnableCrowdLightEnvironment;

/** Whether agents from this spawner should cast shadows */
var() bool	bCastShadows;

/** Max distance from camera relevant for population simulation */
var() float MaxSimulationDistance;

var class<GameCrowdPopulationManager> PopulationManagerClass;

cpptext
{
	virtual void Activated();
};

/**
  *  Find a population manager to toggle
  *  Called from Activated().
  */
event FindPopMgrTarget()
{
	Targets[0] = GameCrowdPopulationManager(GetWorldInfo().PopulationManager);

	if ( Targets[0] == None )
	{
		Targets[0] = GetWorldInfo().Spawn(PopulationManagerClass);
	}
}

static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 2;
}

defaultproperties
{
	ObjName="Population Manager Toggle"
	ObjCategory="Crowd"

	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")

	OutputLinks.Empty

	VariableLinks.Empty

	PopulationManagerClass=class'GameCrowdPopulationManager'

	SpawnRate=50
	MaxAgents=700
	MaxSimulationDistance=20000.0
}
