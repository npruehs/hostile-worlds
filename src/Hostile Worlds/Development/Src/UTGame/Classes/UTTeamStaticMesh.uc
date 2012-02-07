/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTTeamStaticMesh extends StaticMeshActor;

/** material used when owned by a team */
var() array<MaterialInterface> TeamMaterials;
/** material used when not owned by a team or when the TeamMaterials array doesn't contain an entry for the requested team */
var() Material NeutralMaterial;

simulated event PreBeginPlay()
{
	local UTGameObjective O, Best;
	local float Distance, BestDistance;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		BestDistance = 1000000.f;
		foreach WorldInfo.AllNavigationPoints(class'UTGameObjective', O)
		{
			Distance = VSize(Location - O.Location);
			if (Distance < BestDistance)
			{
				BestDistance = Distance;
				Best = O;
			}
		}

		if (Best != None)
		{
			Best.AddTeamStaticMesh(self);
		}
		else
		{
			SetTeamNum(255);
		}
	}
}

simulated function SetTeamNum(byte NewTeam)
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (NewTeam < TeamMaterials.length)
		{
			if (TeamMaterials[NewTeam] != None)
			{
				StaticMeshComponent.SetMaterial(0, TeamMaterials[NewTeam]);
			}
		}
		else
		{
			if (NeutralMaterial != None)
			{
				StaticMeshComponent.SetMaterial(0, NeutralMaterial);
			}
		}
	}
}

defaultproperties
{
	bStatic=false
	bTickIsDisabled=true
	bMovable=false
	// pre-size array to two elements for convenience
	TeamMaterials[0]=None
	TeamMaterials[1]=None
}
