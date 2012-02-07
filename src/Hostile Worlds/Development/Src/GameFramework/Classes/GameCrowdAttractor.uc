/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Used for attracting agents to an area.  If too strong, agents won't continue to destination
 *
 */

class GameCrowdAttractor extends GameCrowdForcePoint
	native;

/** How desireable this attractor is. */
var()	interp float	Attraction;

/** If attraction should falloff over the radius */
var()	bool			bAttractionFalloff;

/**
  *  bIsEnabled assumed checked before calling
  */
event vector AppliedForce(GameCrowdAgent Agent)
{
	local vector ToAttractor;
	local float CurrentAttraction, Distance;
	
	ToAttractor = Location - Agent.Location;
	Distance = VSize(ToAttractor);

	// Normalize vector from location to actor.
	ToAttractor = ToAttractor/Distance;

	CurrentAttraction = Attraction;

	// If desired, do falloff
	if( bAttractionFalloff )
	{
		CurrentAttraction *= FMax(0.f,(1.f - Distance/CylinderComponent.CollisionRadius));
	}

	return ToAttractor * CurrentAttraction;
}

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.Crowd.T_Crowd_Attractor'
		Scale=0.5
	End Object

	Attraction=100.0
	bAttractionFalloff=true
}
