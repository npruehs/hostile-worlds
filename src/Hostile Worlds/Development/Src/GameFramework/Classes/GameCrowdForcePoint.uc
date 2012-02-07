/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Used for attracting agents to an area.  If too strong, agents won't continue to destination
 *
 */

class GameCrowdForcePoint extends GameCrowdInteractionPoint
	native
	abstract;

cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual UBOOL IsOverlapping( AActor *Other, FCheckResult* Hit=NULL, UPrimitiveComponent* OtherPrimitiveComponent=NULL, UPrimitiveComponent* MyPrimitiveComponent=NULL );
}

/** 
  * Add to touching agent's RelevantAttractors list, even if not enabled
  * (because might get enabled while still touching agent
  */
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local GameCrowdAgent Agent;
	local int i;
	
	Agent = GameCrowdAgent(Other);
	if ( Agent != None )
	{
		// check if already in list - shouldn't happen!!!
		for ( i=0; i<Agent.RelevantAttractors.length; i++ )
		{
			if ( Agent.RelevantAttractors[i] == self )
			{
				`log(Agent$" UNEXPECTED ATTRACTOR IN LIST "$self);
				return;
			}
		}
		
		// find empty spot
		for ( i=0; i<Agent.RelevantAttractors.length; i++ )
		{
			if ( Agent.RelevantAttractors[i] == None )
			{
				Agent.RelevantAttractors[i] = self;
				return;
			}
		}
		
		Agent.RelevantAttractors[Agent.RelevantAttractors.Length] = self;
	}
}

/** 
  * Remove from touching agent's RelevantAttractors list
  */
event UnTouch( Actor Other )
{
	local GameCrowdAgent Agent;
	local int i;
	
	Agent = GameCrowdAgent(Other);
	if ( Agent != None )
	{
		// should always be in list!
		for ( i=0; i<Agent.RelevantAttractors.length; i++ )
		{
			if ( Agent.RelevantAttractors[i] == self )
			{
				Agent.RelevantAttractors[i] = None;
				return;
			}
		}
			
		`log(Agent$" DIDN'T HAVE ATTRACTOR IN LIST "$self);
	}
}

/** 
  * Returns force applied to Agent by this force point.
  */
event vector AppliedForce(GameCrowdAgent Agent);

defaultproperties
{
	bCollideActors=true

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.Crowd.T_Crowd_Attractor'
		Scale=0.5
	End Object

	Begin Object NAME=CollisionCylinder
		CollideActors=true
	End Object
}
