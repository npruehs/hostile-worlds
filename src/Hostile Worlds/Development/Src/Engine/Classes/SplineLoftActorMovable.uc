/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
 
class SplineLoftActorMovable extends SplineLoftActor
	placeable
	native(Spline);



defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyMeshLightEnvironment
		bEnabled=TRUE
	End Object
	MeshLightEnvironment=MyMeshLightEnvironment
	Components.Add(MyMeshLightEnvironment)

	Physics=PHYS_Interpolating

	bStatic=false
	bMovable=true
}