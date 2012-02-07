/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 *  Used for repelling crowd agents from an area
 */

class GameCrowdRepulsor extends GameCrowdForcePoint
	native;

/** How repulsive this repulsor is. */
var()	interp float	Repulsion;

/** If attraction should falloff over the radius */
var()	bool			bAttractionFalloff;

/**
  *  bIsEnabled assumed checked before calling
  */
event vector AppliedForce(GameCrowdAgent Agent)
{
	local vector FromAttractor;
	local float CurrentRepulsion, Distance;
	
	FromAttractor = Agent.Location - Location;
	Distance = VSize(FromAttractor);

	// Normalize vector from location to actor.
	FromAttractor = FromAttractor/Distance;

	CurrentRepulsion = Repulsion;

	// If desired, do falloff
	if( bAttractionFalloff )
	{
		CurrentRepulsion *= FMax(0.f,(1.f - Distance/CylinderComponent.CollisionRadius));
	}

	return FromAttractor * CurrentRepulsion;
}

defaultproperties
{
	Repulsion=180.0
	bAttractionFalloff=true

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.Crowd.T_Crowd_Repulsor'
		Scale=0.5
	End Object

	Begin Object NAME=CollisionCylinder
		CylinderColor=(R=0,G=0,B=255)
	End Object
}