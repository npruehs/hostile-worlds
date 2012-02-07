/**
 * Version of UTWaterVolume that can be moved during gameplay (attached to matinee, etc)
 * More expensive, so only use when really needed
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDynamicWaterVolume extends UTWaterVolume;

defaultproperties
{
	bStatic=false

	bAlwaysRelevant=true
	bReplicateMovement=true
	bOnlyDirtyReplication=true
	RemoteRole=ROLE_None
}
