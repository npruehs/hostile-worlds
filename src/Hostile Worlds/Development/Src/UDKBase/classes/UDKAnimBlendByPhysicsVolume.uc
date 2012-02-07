/** selects child based on parameters of the owner's current physics volume
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByPhysicsVolume extends UDKAnimBlendBase
	native(Animation);

struct native PhysicsVolumeParams
{
	/** index of child that should become active when the owner's physics volume matches these parameters */
	var() int ChildIndex;
	/** whether the volume is a water volume */
	var() bool bWaterVolume;
	/** whether we care about the volume's gravity */
	var() bool bCheckGravity;
	/** gravity thresholds for bCheckGravity */
	var() float MinGravity, MaxGravity;
};
var() array<PhysicsVolumeParams> PhysicsParamList;

/** last volume owner was using, to detect changes */
var transient PhysicsVolume LastPhysicsVolume;

cpptext
{
	virtual void RenameChildConnectors();
	virtual	void TickAnim(FLOAT DeltaSeconds);
}

/** called when this node detects that its Owner's PhysicsVolume has been changed
 * choose the appropriate child here
 */
event PhysicsVolumeChanged(PhysicsVolume NewVolume)
{
	local int i, DesiredChild;
	local float GravityZ;

	for (i = 0; i < PhysicsParamList.length; i++)
	{
		if (PhysicsParamList[i].bWaterVolume == NewVolume.bWaterVolume)
		{
			if (!PhysicsParamList[i].bCheckGravity)
			{
				DesiredChild = PhysicsParamList[i].ChildIndex;
				break;
			}
			else
			{
				GravityZ = NewVolume.GetGravityZ();
				if (GravityZ >= PhysicsParamList[i].MinGravity && GravityZ <= PhysicsParamList[i].MaxGravity)
				{
					DesiredChild = PhysicsParamList[i].ChildIndex;
					break;
				}
			}
		}
	}

	SetActiveChild(DesiredChild, GetBlendTime(DesiredChild));
}

defaultproperties
{
	Children[0]=(Name="Default",Weight=1.0)
}
