/**
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/
class SeqAct_GameCrowdSpawner extends SeqAct_Latent
	abstract
	native;

/** Set by kismet action inputs - controls whether we are actively spawning agents. */
var		bool	bSpawningActive;

/** Index of next destination to pick */
var int NextDestinationIndex;

/** Cached set of spawn locations. */
var	transient array<Actor>		SpawnLocs;

/** If true, the spawner will cycle through the spawn locations instead of spawning from a randomly chosen one */
var() bool  bCycleSpawnLocs;

/** Holds the last SpawnLoc index used */
var private transient int   LastSpawnLocIndex;

/** How many agents per second will be spawned at the target actor(s).  */
var()	float	SpawnRate;

/** The maximum number of agents alive at one time. If agents are destroyed, more will spawn to meet this number. */
var()	int		SpawnNum;

/** If TRUE, agents that are totally removed (ie blown up) are respawned */
var()	bool	bRespawnDeadAgents;

/** Radius around target actor(s) to spawn agents. */
var()	float	SpawnRadius;

/** Whether we have already done the number reduction */
var		bool	bHasReducedNumberDueToSplitScreen;

/** How much to reduce number by in splitscreen */
var()	float	SplitScreenNumReduction;

/** Used by spawning code to accumulate partial spawning */
var		float	Remainder;

struct native AgentArchetypeInfo
{
	var() object		AgentArchetype;
	/** added to selection rate. **/
	var() float			FrequencyModifier;
	/** 
	 * No matter the frequency, we want to limit the number of this type of crowd agent.  Another knob to easily set. 
     * Basically, we often want to adjust the number of crowds members / density but don't want a certain Archetype to also grow/shrink
	 * Due to native struct properties not being properly updated in already existing instanced objects we say MaxAllowed of 0 means infi guys
	 **/
	var() int           MaxAllowed;
	var transient int   CurrSpawned;
	/** additional agents to spawn with this one as part of group **/
	var() array<object>	GroupMembers; 
	
	structdefaultproperties
	{
		FrequencyModifier=+1.0
	}
};

/** Sum of agent types + frequency modifiers */
var float AgentFrequencySum;

/** List of Archetypes of agents for pop manager to spawn when this is toggled on */
var()	GameCrowd_ListOfAgents	CrowdAgentList;

/** Archetypes of agents spawned by this crowd spawner */
var transient array<AgentArchetypeInfo>	AgentArchetypes;

/** Used to keep track of currently spawned crowd members. */
var transient array<GameCrowdAgent> SpawnedList;

/** Lighting channels to put the agents in. */
var(Lighting)	LightingChannelContainer	AgentLightingChannel;

/** Whether to enable the light environment on crowd members. */
var(Lighting)	bool						bEnableCrowdLightEnvironment;

/** Used for replicating crowd inputs to clients. */
var		GameCrowdReplicationActor		RepActor;

/** If true, force obstacle checking for all agents from this spawner */
var() bool bForceObstacleChecking;

/** If true, force nav mesh navigation for all agents from this spawner */
var() bool bForceNavMeshPathing;

/** If true, only spawn agents if player can't see spawn point */
var() bool bOnlySpawnHidden;

/** Average time to "warm up" spawned agents before letting them sleep if not rendered */
var() float AgentWarmupTime;

/** If true, and initial spawn positiong is not in player's line of sight, and agent is not part of a group,
  * agent will try to find an starting position at a random spot between the initial spawn positing and its initial destination
  * that isn't in the player's line of sight.
  */
var() bool bWarmupPosition;

/** Whether agents from this spawner should cast shadows */
var(Lighting)   bool    bCastShadows;

cpptext
{
	virtual void Activated();
	virtual UBOOL UpdateOp(FLOAT deltaTime);
	virtual void Initialize();
	virtual void CleanUp();
	virtual UBOOL SpawnIsHidden(AActor *SpawnLoc);
};

/** Called when agent is spawned - sets agent output and triggers spawned event */
native function SpawnedAgent(GameCrowdAgent NewAgent);

/** Cache SpawnLocs from attached Kismet vars. */
native simulated function CacheSpawnerVars();

/** Immediately destroy all agents spawned by this action. */
native simulated function KillAgents();

/** Manually update spawning (for use on clients where action does not become active) */
native simulated function UpdateSpawning(float DeltaSeconds);

/** Called from C++ to actually create a new CrowdAgent actor, and initialise it */
event GameCrowdAgent SpawnAgent(Actor SpawnLoc)
{
	local GameCrowdAgent	Agent;
	local float AgentPickValue, PickSum;
	local int i, PickedInfo;
	local GameCrowdAgent AgentTemplate;
	local GameCrowdGroup NewGroup;

	// pick agent class
	if ( AgentFrequencySum == 0.0 )
	{
		if ( CrowdAgentList != None )
		{
			AgentArchetypes.Length = 0;
			// get agent archetypes to use from CrowdAgentList
			for (i=0; i<CrowdAgentList.ListOfAgents.Length; i++ )
			{
				AgentArchetypes[AgentArchetypes.Length] = CrowdAgentList.ListOfAgents[i];
			}
		}

		// make sure initialized
		for ( i=0; i<AgentArchetypes.length; i++ )
		{
			if ( GameCrowdAgent(AgentArchetypes[i].AgentArchetype) != None )
			{
				AgentFrequencySum = AgentFrequencySum + FMax(0.0,AgentArchetypes[i].FrequencyModifier);
			}
		}
	}
	AgentPickValue = AgentFrequencySum * FRand();
	PickedInfo = -1;
	for ( i=0; i<AgentArchetypes.Length; i++ )
	{
		AgentTemplate = GameCrowdAgent(AgentArchetypes[i].AgentArchetype);
		if ( AgentTemplate != None )
		{
			PickSum = PickSum + FMax(0.0,AgentArchetypes[i].FrequencyModifier);
			if ( PickSum > AgentPickValue )
			{
				PickedInfo = i;
				break;
			}
		} 
	}	

	if ( PickedInfo == -1 )
	{
		// failed to find valid archetype
		return None;
	}

	if ( AgentArchetypes[PickedInfo].GroupMembers.Length > 0 )
	{
		NewGroup = New(None) class'GameCrowdGroup';
	}
	Agent = CreateNewAgent(SpawnLoc, AgentTemplate, NewGroup);

	// notify kismet (fills "spawned agent" output variable, and triggers "agent spawned" event)
	SpawnedAgent(Agent);
	
	// spawn other agents in group
	for ( i=0; i<AgentArchetypes[PickedInfo].GroupMembers.Length; i++ )
	{
		if ( GameCrowdAgent(AgentArchetypes[PickedInfo].GroupMembers[i]) != None )
		{
			CreateNewAgent(SpawnLoc, GameCrowdAgent(AgentArchetypes[PickedInfo].GroupMembers[i]), NewGroup);
		}
	}
	return Agent;
}
	
function GameCrowdAgent CreateNewAgent(Actor SpawnLoc, GameCrowdAgent AgentTemplate, GameCrowdGroup NewGroup)
{
	local GameCrowdAgent	Agent;
	local rotator	SpawnRot;
	local vector	SpawnPos;
	
	// GameCrowdSpawnInterface provides spawn location (can be line/circle/volume/etc. based)
	if ( GameCrowdSpawnInterface(SpawnLoc) != None )
	{
		GameCrowdSpawnInterface(SpawnLoc).GetSpawnPosition(self, SpawnPos, SpawnRot);
	}
	else
	{
		// Circle spawn by default
		SpawnRot = RotRand(false);
		SpawnRot.Pitch = 0;
		SpawnPos = SpawnLoc.Location + ((vect(1,0,0) * FRand() * SpawnRadius) >> SpawnRot);
	}
	
	Agent = SpawnLoc.Spawn( AgentTemplate.Class,SpawnLoc,,SpawnPos,SpawnRot,AgentTemplate);

	Agent.SetLighting(bEnableCrowdLightEnvironment, AgentLightingChannel, bCastShadows);

	if ( bForceObstacleChecking )
	{
		Agent.bCheckForObstacles = true;
	}
	
	if ( bForceNavMeshPathing )
	{
		Agent.bUseNavMeshPathing = true;
	}
	
	Agent.InitializeAgent(SpawnLoc, AgentTemplate, NewGroup, AgentWarmUpTime*2.0*FRand(), bWarmupPosition, true);
	SpawnedList[SpawnedList.Length] = Agent;
	return Agent;
}

static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 3;
}

defaultproperties
{
	ObjName="Crowd Spawner (New)"
	ObjCategory="Crowd"

	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")
	InputLinks(2)=(LinkDesc="Destroy All")

	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Agent Spawned");
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Points",PropertyName=SpawnPoints)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned Agent",bWriteable=true)

	AgentLightingChannel=(Crowd=TRUE,bInitialized=TRUE)

	SpawnRadius=200
	SpawnRate=10
	SpawnNum=100
	bRespawnDeadAgents=TRUE

	SplitScreenNumReduction=0.5
	
	bOnlySpawnHidden=true
	
	AgentWarmupTime=5.0
}
