/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Where crowd agent is going.  Destinations can kill agents that reach them or route them to another destination
 * 
 */
class GameCrowdDestination extends GameCrowdInteractionPoint
	implements(GameCrowdSpawnInterface)
	implements(EditorLinkSelectionInterface)
	dependsOn(GameCrowdAgent)
	native;

/** If TRUE, kill crowd members when they reach this destination. */
var()	bool			bKillWhenReached;

// randomly pick from this list of active destinations
var() duplicatetransient array<GameCrowdDestination> NextDestinations;

/** queue point to use if this destination is at capacity */
var() duplicatetransient GameCrowdDestinationQueuePoint QueueHead;

// whether agents previous destination can be used as a destination if in list of NextDestinations
var() bool bAllowAsPreviousDestination;

/** How many agents can simultaneously have this as a destination */
var() int Capacity;

/** Adjusts the likelihood of agents to select this destination from list at previous destination*/
var() float Frequency;

/** Current number of agents using this destination */
var private int CustomerCount;

/** if set, only agents of this class can use this destination */
var(Restrictions) array<class<GameCrowdAgent> >  SupportedAgentClasses;

/** if set, agents from this archetype can use this destination */
var(Restrictions) array<object>  SupportedArchetypes;

/** if set, agents of this class cannot use this destination */
var(Restrictions) array<class<GameCrowdAgent> >  RestrictedAgentClasses;

/** if set, agents from this archetype cannot use this destination */
var(Restrictions) array<object>  RestrictedArchetypes;

/** Caches most recent AllowableDestinationFor() result */
var bool bLastAllowableResult;

/** Don't go to this destination if panicked */
var() bool bAvoidWhenPanicked;

/** Don't perform kismet or custom behavior at this destination if panicked */
var() bool bSkipBehaviorIfPanicked;

/** Always run toward this destination */
var() bool bFleeDestination;

/** Must reach this destination exactly - will force movement when close */
var() bool bMustReachExactly;

var float ExactReachTolerance;

/** True if has supported class/archetype restrictions */
var bool bHasRestrictions;

/** Type of interaction */
var()	Name			InteractionTag;

/** Time before an agent is allowed to attempt this sort of interaction again */
var()	float			InteractionDelay;

/** True if spawning permitted at this node */
var(Spawning)	bool	bAllowsSpawning;

/** Spawn in a line rather than in a circle. */
var(Spawning)	bool	bLineSpawner;

/** Radius to spawn around center of this destination */
var(Spawning)	float	SpawnRadius;

/** Whether to spawn agents only at the edge of the circle, or at any point within the circle. */
var(Spawning)	bool	bSpawnAtEdge;

/** Agents reaching this destination will pick a behavior from this list */
var() array<BehaviorEntry>  ReachedBehaviors;

/** Whether agent should stop on reach edge of destination radius (if not reach exactly), or have a "soft" perimeter */
var() bool bSoftPerimeter;

/** Agent currently coming to this destination.  Not guaranteed to be correct/exhaustive.  Used to allow agents to trade places with nearer agent for destinations with queueing */
var GameCrowdAgent AgentEnRoute;

//=========================================================
/** The following properties are set and used by the GameCrowdPopulationManager class for selecting at which destinations to spawn agents */

/** True if currently in line of sight of a player (may not be within view frustrum) */
var bool bIsVisible;

/** True if will become visible shortly based on player's current velocity */ 
var bool bWillBeVisible;

/** This destination is currently available for spawning */
var bool bCanSpawnHereNow;

/** This destination is beyond the maximum spawn distance */
var bool bIsBeyondSpawnDistance;

/** Cache that node is currently adjacent to a visible node */
var bool bAdjacentToVisibleNode;

/** Whether there is a valid NavigationMesh around this destination */
var bool bHasNavigationMesh;

/** Priority for spawning agents at this destination */
var float Priority;

/** Most recent time at which agent was spawned at this destination */
var float LastSpawnTime;

/** Population manager with which this destination is associated */
var transient GameCrowdPopulationManager MyPopMgr;

cpptext
{
	/** EditorLinkSelectionInterface */
	virtual void LinkSelection(USelection* SelectedActors);
	virtual void UnLinkSelection(USelection* SelectedActors);
	
	/**
	 * Function that gets called from within Map_Check to allow this actor to check itself
	 * for any potential errors and register them with map check dialog.
	 */
	virtual void CheckForErrors();
};



/**
  * @PARAM Agent is the agent being checked
    @PARAM Testposition is the position to be tested
    @PARAM bTestExactly if true and GameCrowdDestination.bMustReachExactly is true means ReachedByAgent() only returns true if right on the destination
  * @RETURNS TRUE if Agent has reached this destination
  */
native simulated function bool ReachedByAgent(GameCrowdAgent Agent, vector TestPosition, bool bTestExactly);

simulated function PostBeginPlay()
{
	local int i;
	local GameCrowdPopulationManager PopMgr;

	super.PostBeginPlay();
	
	bHasRestrictions = (SupportedAgentClasses.Length > 0) || (SupportedArchetypes.Length > 0) || (RestrictedAgentClasses.Length > 0) || (RestrictedArchetypes.Length > 0);

	// don't allow automatic agent spawning at destinations with Queues, or small capacities
	if ( (QueueHead != None) || (Capacity < 10) || bKillWhenReached )
	{
		bAllowsSpawning = false;
	}

	// verify behavior lists
	for ( i=0; i< ReachedBehaviors.Length; i++ )
	{
		if ( ReachedBehaviors[i].BehaviorArchetype == None )
		{
			`warn(self$" missing BehaviorArchetype at ReachedBehavior "$i);
			ReachedBehaviors.remove(i,1);
			i--;
		}
	}

	// Add self to population manager list
	PopMgr = GameCrowdPopulationManager(WorldInfo.PopulationManager);
	if ( PopMgr != None )
	{
		PopMgr.AddSpawnPoint(self);
	}
}

simulated function Destroyed()
{
	super.Destroyed();

	if ( MyPopMgr != None )
	{
		MyPopMgr.RemoveSpawnPoint(self);
	}
}

	
/** 
  * Called after Agent reaches this destination
  * Will be called every tick as long as ReachedByAgent() is true and agent is not idle, so should change
  * Agent to avoid this (change current destination, make agent idle, or kill agent) )
  * 
  * @PARAM Agent is the crowd agent that just reached this destination
  * @PARAM bIgnoreKismet skips generating Kismet event if true.
  */
simulated event ReachedDestination(GameCrowdAgent Agent)
{
	local int i,j;
	local SeqEvent_CrowdAgentReachedDestination ReachedEvent;
	local bool bEventActivated;

	// kill agent that reached me?
	if ( bKillWhenReached )
	{
		// If desired, kill actor when it reaches an attractor
		DecrementCustomerCount(Agent);
		Agent.CurrentDestination = None;
		Agent.KillAgent();
		return;
	}

	// mark the interaction if tagged
	if (InteractionTag != '')
	{
		i = Agent.RecentInteractions.Add(1);
		Agent.RecentInteractions[i].InteractionTag = InteractionTag;
		if (InteractionDelay > 0.f)
		{
			// mark the time to remove this interaction from history
			Agent.RecentInteractions[i].InteractionDelay = WorldInfo.TimeSeconds + InteractionDelay;
		}
	}
	
	// Can agent perform a custom behavior here 
	if ( (Agent.BehaviorDestination != self) && ((Agent.CurrentBehavior == None) || Agent.CurrentBehavior.AllowBehaviorAt(self)) )
	{
		// Assign a reachedbehavior to the agent
		if ( ReachedBehaviors.Length > 0 )
		{
			Agent.PickBehaviorFrom(ReachedBehaviors);
		}
		
		// check if kismet event on reaching this destination
		for ( i=0; i<GeneratedEvents.Length; i++)
		{
			ReachedEvent = SeqEvent_CrowdAgentReachedDestination(GeneratedEvents[i]);
			if ( ReachedEvent != None )
			{
				Agent.BehaviorDestination = self;
				// HACKY - clear bActive on output ops so this agent can get in on an already active latent action
				for ( j=0; j<ReachedEvent.OutputLinks[0].Links.Length; j++ )
				{
					ReachedEvent.OutputLinks[0].Links[j].LinkedOp.bActive = false;
				}
				bEventActivated = ReachedEvent.CheckActivate(self, Agent);
				break;
			}
		}
	}
	
	// choose next destination
	if( !bEventActivated && (NextDestinations.Length > 0) )
	{
		PickNewDestinationFor(Agent, false);
		
		if ( Agent.CurrentDestination == None )
		{
			// if haven't been visible for a while, just kill
			if ( WorldInfo.TimeSeconds - Agent.LastRenderTime > Agent.default.NotVisibleLifeSpan )
			{
				Agent.KillAgent();
			}
			else
			{
				// failed with restrictions, so pick any - FIXMESTEVE probably want more refined fallback
				PickNewDestinationFor(Agent, true);
			}
		}
	}
	
	// first in group to get new destination should update others
	if ( Agent.MyGroup != None )
	{
		Agent.MyGroup.UpdateDestinations(Agent.CurrentDestination);
	}
}

/** 
  * Pick a new destination from this one for agent.
  */
simulated function PickNewDestinationFor(GameCrowdAgent Agent, bool bIgnoreRestrictions )
{
	local int i;
	local float DestinationFrequencySum, DestinationPickValue;
	
	// Pick a new destination from available list
	DecrementCustomerCount(Agent);
	Agent.CurrentDestination = None;
	Agent.BehaviorDestination = None;
	
	// init DestinationFrequencySum
	for ( i=0; i< NextDestinations.Length; i++ )
	{
		if ( (NextDestinations[i] != None) && (bIgnoreRestrictions || NextDestinations[i].AllowableDestinationFor(Agent)) )
		{
			// bonus to this potential destination's frequency if current destination is not visible, and destination is, and agent prefers visible destinations
			DestinationFrequencySum += NextDestinations[i].Frequency * ((!bIsVisible && Agent.bPreferVisibleDestination && (NextDestinations[i].bIsVisible || NextDestinations[i].bWillBeVisible)) ? 2.0 : 1.0);
		}
	}
	
	DestinationPickValue = DestinationFrequencySum * FRand();
	DestinationFrequencySum = 0.0;
	for ( i=0; i<NextDestinations.Length; i++ )
	{
		if ( (NextDestinations[i] != None) && (bIgnoreRestrictions || NextDestinations[i].bLastAllowableResult) )
		{
			// bonus to this potential destination's frequency if current destination is not visible, and destination is, and agent prefers visible destinations
			DestinationFrequencySum += NextDestinations[i].Frequency * ((!bIsVisible && Agent.bPreferVisibleDestination && (NextDestinations[i].bIsVisible || NextDestinations[i].bWillBeVisible)) ? 2.0 : 1.0);
			if ( DestinationPickValue < DestinationFrequencySum )
			{
				Agent.SetCurrentDestination(NextDestinations[i]);
				Agent.PreviousDestination = self;
				Agent.UpdateIntermediatePoint();
				break;
			}
		}
	}
	Agent.PreviousDestination = self;
}

/**
  * Decrement customer count.  Update Queue if have one
  * Be sure to decrement customer count from old destination before setting a new one!
  * FIXMESTEVE - should probably wrap decrement old customercount into GameCrowdAgent.SetDestination()
  */
simulated event DecrementCustomerCount(GameCrowdAgent DepartingAgent)
{
	local GameCrowdDestinationQueuePoint QP;
	local bool bIsInQueue;
	
	// Check to make sure that the current destination is ourself, to prevent double decrementing
	if( DepartingAgent.CurrentDestination == self )
	{
		// check if departing agent is in queue
		For ( QP=QueueHead; QP!=None; QP = QP.NextQueuePosition )
		{
			if ( QP.QueuedAgent == DepartingAgent )
			{
				bIsInQueue = true;
				QP.ClearQueue(DepartingAgent);
				break;
			}
		}
		
		if ( !bIsInQueue )
		{
			// agent was customer, so clear him out
			CustomerCount--;
			if ( (QueueHead != None) && QueueHead.HasCustomer() )
			{
				QueueHead.AdvanceCustomerTo(self);
			}
		}
	}
}

/**
  * Increment customer count, or add agent to queue if needed 
  */
simulated event IncrementCustomerCount(GameCrowdAgent ArrivingAgent)
{
	// if at capacity, or queue is about to move forward, add to queue rather than directly
	if ( (CustomerCount >= Capacity) || ((Queuehead != None) && Queuehead.bPendingAdvance) )
	{
		// add to queue
		if ( (QueueHead != None) && QueueHead.HasSpace() )
		{
			// maybe switch with agent currently in route, if ArrivingAgent is closer
			if ( (AgentEnRoute != None) && (AgentEnRoute.CurrentBehavior == None) && !ReachedByAgent(AgentEnRoute, AgentEnRoute.Location, false) 
				 && (VSizeSq(ArrivingAgent.Location - Location) < VSizeSq(AgentEnRoute.Location - Location)) )
			{
				// switch places
				//`log("Switching "$ArrivingAgent$" for "$AgentEnRoute);
				QueueHead.AddCustomer(AgentEnRoute,self);
				AgentEnRoute = ArrivingAgent;
			}
			else
			{
				QueueHead.AddCustomer(ArrivingAgent,self);
			}
		}
		else
		{
			`warn(self$" added customer "$ArrivingAgent$" beyond capacity with queue "$QueueHead);
		}
	}
	else
	{
		AgentEnRoute = ArrivingAgent;
		CustomerCount++;
	}
}

simulated function bool AtCapacity()
{
	return CustomerCount >= Capacity;
}

/**
  * Returns true if this destination is valid for Agent
  */
simulated event bool AllowableDestinationFor(GameCrowdAgent Agent)
{
	local int i, num;
	
	bLastAllowableResult = bHasNavigationMesh;

	if ( bLastAllowableResult )
	{
		// FIXMESTEVE - maybe allow moving to beyond max spawn distance destination if currently close enough
		bLastAllowableResult = !bIsBeyondSpawnDistance;
	}

	if ( bLastAllowableResult )
	{
		// check if allowed by agent's behavior
		bLastAllowableResult = bIsEnabled && ((Agent.CurrentBehavior != None) ? Agent.CurrentBehavior.AllowThisDestination(self) : (bAllowAsPreviousDestination || (Agent.PreviousDestination != self)));
	}

	// check if destination has room
	if ( bLastAllowableResult )
	{
		if ( Agent.MyGroup != None )
		{
			// make sure there is room for the whole group
			bLastAllowableResult = (CustomerCount + Agent.MyGroup.Members.Length <= Capacity);
		}
		else
		{
			bLastAllowableResult = (CustomerCount < Capacity) || ((QueueHead !=None) && QueueHead.HasSpace());
		}
	}
	
	// check if this interaction is tagged
	if ( bLastAllowableResult && InteractionTag != '' )
	{
		i = Agent.RecentInteractions.Find('InteractionTag',InteractionTag);
		if ( i != INDEX_NONE && (Agent.RecentInteractions[i].InteractionDelay == 0.f || WorldInfo.TimeSeconds < Agent.RecentInteractions[i].InteractionDelay) )
		{
			bLastAllowableResult = false;
			return false;
		}
		else if ( i != INDEX_NONE )
		{
			// clear out the old interaction
			Agent.RecentInteractions.Remove(i,1);
		}
	}

	if ( bLastAllowableResult && bHasRestrictions )
	{
		// make sure the agent class/archetype is supported
		
		// first check if in supported classes list - if list is empty, anyone is OK.
		num = SupportedAgentClasses.length;
		bLastAllowableResult = (num == 0) && (SupportedArchetypes.Length == 0);
		if ( num > 0 )
		{
			for ( i=0; i<num; i++ )
			{
				if ( ClassIsChildOf(Agent.Class, SupportedAgentClasses[i]) )
				{
					bLastAllowableResult = true;
					break;
				}
			}
		}
		
		// only check against supported archetypes if failed supported classes list
		if ( !bLastAllowableResult )
		{
			num = SupportedArchetypes.length;
			if ( num > 0 )
			{
				for ( i=0; i<num; i++ )
				{
					if ( SupportedArchetypes[i] == Agent.MyArchetype )
					{
						bLastAllowableResult = true;
						break;
					}
				}
			}
		}
		
		// if passed the supported test, make sure not in restricted classes list
		if ( bLastAllowableResult )
		{
			num = RestrictedAgentClasses.length;
			if ( num > 0 )
			{
				for ( i=0; i<num; i++ )
				{
					if ( ClassIsChildOf(Agent.Class, RestrictedAgentClasses[i]) )
					{
						bLastAllowableResult = false;
						break;
					}
				}
			}
		}
		
		// if not in restricted class, check the restricted archetypes list
		if ( bLastAllowableResult )
		{
			num = RestrictedArchetypes.length;
			if ( num > 0 )
			{
				for ( i=0; i<num; i++ )
				{
					if ( RestrictedArchetypes[i] == Agent.MyArchetype )
					{
						bLastAllowableResult = false;
						break;
					}
				}
			}
		}
	}
	return bLastAllowableResult;
}

// FIXMESTEVE - natively show the spawn line in the editor if bLineSpawner
simulated function GetSpawnPosition(SeqAct_GameCrowdSpawner Spawner, out vector SpawnPos, out rotator SpawnRot)
{
	local vector SpawnLine;
	local float	RandScale;
	
	// LINE SPAWN
	if(bLineSpawner)
	{
		// Scale between -1.0 and 1.0
		RandScale = -1.0 + (2.0 * FRand());
		// Get line along which to spawn.
		SpawnLine = vect(0,1,0) >> Rotation;
		// Now make the position
		SpawnPos = Location + (RandScale * SpawnLine * SpawnRadius);

		// Always face same way as spawn location
		SpawnRot.Yaw = Rotation.Yaw;
	}
	else
	{
		// CIRCLE SPAWN
		SpawnRot = RotRand(false);
		SpawnRot.Pitch = 0;

		if(bSpawnAtEdge)
		{
			SpawnPos = Location + ((vect(1,0,0) * SpawnRadius) >> SpawnRot);
		}
		else
		{
			SpawnPos = Location + ((vect(1,0,0) * FRand() * SpawnRadius) >> SpawnRot);
		}
	}
}

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.Crowd.T_Crowd_Destination'
		Scale=0.5
	End Object

	bAllowAsPreviousDestination=false
	bAvoidWhenPanicked=false
	bSkipBehaviorIfPanicked=true
	Capacity=1000
	Frequency=1.0
	ExactReachTolerance=3.0
	bAllowsSpawning=true
	SpawnRadius=200.0
	bSoftPerimeter=true
	bStatic=true
	bForceAllowKismetModification=true
	bHasNavigationMesh=true
	
	SupportedEvents.Empty
	SupportedEvents(0)=class'SeqEvent_CrowdAgentReachedDestination'
	
	Begin Object Class=GameDestinationConnRenderingComponent Name=ConnectionRenderer
	End Object
	Components.Add(ConnectionRenderer)

}