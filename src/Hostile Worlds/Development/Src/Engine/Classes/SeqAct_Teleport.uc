/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_Teleport extends SequenceAction;

/** If true, actor rotation will be aligned with destination actor */
var() bool bUpdateRotation;
/** If actor is more than this far away, it will be teleported. Ignored if < 0 */
var() float TeleportDistance;
/** If actor is NOT in one of these volumes, it will be teleported */
var() array<Volume> TeleportVolumes;

/** @return Whether the given Actor should be teleported */
final function bool ShouldTeleport(Actor TestActor, vector TeleportLocation)
{
	local int VolumeIdx;

	if (TeleportDistance > 0.0 && VSizeSq(TestActor.Location - TeleportLocation) < TeleportDistance*TeleportDistance)
	{
		return false;
	}
	else if (TeleportVolumes.length > 0)
	{
		for (VolumeIdx = 0; VolumeIdx < TeleportVolumes.length; ++VolumeIdx)
		{
			if (TeleportVolumes[VolumeIdx] != None && TeleportVolumes[VolumeIdx].Encompasses(TestActor))
			{
				return false;
			}
		}
	}

	return true;
}

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjName="Teleport"
	ObjCategory="Actor"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Destination")
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Teleport Volumes",PropertyName=TeleportVolumes,bHidden=TRUE))
	bUpdateRotation=TRUE

	TeleportDistance=-1.f
}
