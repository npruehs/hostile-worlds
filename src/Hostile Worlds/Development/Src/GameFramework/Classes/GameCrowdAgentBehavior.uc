/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GameCrowdAgentBehavior extends Object
	native
	abstract;
	
/** If true, agent should idle (not move between destinations)/ */
var() bool bIdleBehavior;

/** actor to aim at during actions */
var		actor		ActionTarget;

/** Agent must be within this distance of the player to perform this behavior */
var() float MaxPlayerDistance;

/** If true, must face action target before starting behavior */
var() bool bFaceActionTargetFirst;

/** If true, pass on to agents encountered */
var() bool bIsViralBehavior;

/** true when agent is currently panicked */
var bool bIsPanicked;

/** Agent currently implementing this behavior instance */
var GameCrowdAgent MyAgent;

/**
  *  Called every tick when agent is currently idle (because bIdleBehavior is true)
  *
  * @RETURN true if should end idle (bIdleBehavior should also become false)
  */
native function bool ShouldEndIdle();

/**
  *  Agent's current behavior gets ticked
  */
native function Tick(float DeltaTime);

/** 
  * This function is called on an archetype - do not modify any properties here!
  */
function bool CanBeUsedBy(GameCrowdAgent Agent, vector CameraLoc)
{
	return VSizeSq(CameraLoc - Agent.Location) < MaxPlayerDistance*MaxPlayerDistance;
}

/** 
  *  Event when agent is facing action target, called if bFaceActionTarget=true
  */
event FinishedTargetRotation();

/**
  * Handles movement destination updating for agent.
  *
  * @RETURNS true if destination updating was handled
  */ 
native function bool HandleMovement();

/**
  * Called when Agent activates this behavior
  */
function InitBehavior(GameCrowdAgent Agent)
{
	MyAgent = Agent;
}

/**
  * Called when Agent stops this behavior
  */
function StopBehavior()
{
}

/**
  *  Anim end notification called by GameCrowdAgent.OnAnimEnd().
  */
event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime);

/** 
  * Get debug string about agent behavior
  */
function string GetBehaviorString()
{
	return "Behavior: "$self;
}

/**
  * Notification that MyAgent is changing destinations
  */
function ChangingDestination(GameCrowdDestination NewDest);

/**
  * Returns action agent wants behavior to be moving toward.
  */
function Actor GetDestinationActor()
{
	return MyAgent.CurrentDestination;
}

/**
  * Called if agent wants to provide an action target to its behavior.
  */
function ActivatedBy(Actor NewActionTarget)
{
	ActionTarget = NewActionTarget;
}

/**
  * When two agents encounter each other, and one has a viral behavior and the other doesn't,
  * the viral behavior is called to have a chance to propagate itself to the uninfected OtherAgent.
  */
event PropagateViralBehaviorTo(GameCrowdAgent OtherAgent);

/**
  * Return true if agent is allowed to go to destination while performing this behavior
  */
function bool AllowThisDestination(GameCrowdDestination Destination)
{
	return true;
}

/** 
  * return true if get kismet or new behavior from this destination
  */
function bool AllowBehaviorAt(GameCrowdDestination Destination)
{
	return true;
}

defaultproperties
{
	MaxPlayerDistance=10000.0
}
