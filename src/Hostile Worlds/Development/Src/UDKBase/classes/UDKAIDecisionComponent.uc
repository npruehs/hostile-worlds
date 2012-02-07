/**
 * when this component gets triggered, it calls its owner UTBot's ExecuteWhatToDoNext() in its next tick.
 * This is so the AI's state code, timers, etc happen in TG_PreAsyncWork while the decision logic happens
 * in TG_DuringAsyncWork for improved parallelism ("during async work" executes in parallel with physics update)
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKAIDecisionComponent extends ActorComponent
	native;

/** bTriggered is true while bot is waiting for DecisionComponent to call back event ExecuteWhatToDoNext() */
var bool bTriggered;

cpptext
{
	virtual void Tick(FLOAT DeltaTime);
}

defaultproperties
{
	TickGroup=TG_DuringAsyncWork
}
