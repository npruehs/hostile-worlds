/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTGib_RobotTorso extends UTGib_Robot;

defaultproperties
{
	GibMeshesData[0]=(TheStaticMesh=StaticMesh'CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part05',TheSkelMesh=None,ThePhysAsset=None,DrawScale=2.0)
	GibMeshesData[1]=(TheStaticMesh=StaticMesh'CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part06',TheSkelMesh=None,ThePhysAsset=None,DrawScale=2.0)
	GibMeshesData[2]=(TheStaticMesh=StaticMesh'CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part11',TheSkelMesh=None,ThePhysAsset=None,DrawScale=2.0)

	HitSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_GibLarge_Cue'
}
