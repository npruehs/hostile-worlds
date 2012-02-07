/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTGib_ScorpionHatch extends UTGib_Vehicle;

defaultproperties
{
	Begin Object Class=UTGibStaticMeshComponent Name=GibStaticMeshComp
		StaticMesh=StaticMesh'FX_VehicleExplosions.ScorpionParts.S_FX_ScorpionCanopy'
	End Object
	CollisionComponent=GibStaticMeshComp
	GibMeshComp=GibStaticMeshComp
	Components.Add(GibStaticMeshComp)
}
