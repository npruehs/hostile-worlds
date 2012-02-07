// ============================================================================
// HWSeqAct_SpawnAliens
// A Hostile Worlds sequence action that causes the linked alien camps to
// spawn the specified number of aliens.
//
// Author:  Nick Pruehs
// Date:    2011/03/20
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSeqAct_SpawnAliens extends HWSequenceAction;

/** The camps to spawn new aliens. */
var() array<Object> SpawningCamps;

/** The number of aliens each camp should spawn. */
var() int AlienCount;


event Activated()
{
	local int i;
	local Object o;
	local HWAlienCamp Camp;

	foreach SpawningCamps(o)
	{
		Camp = HWAlienCamp(o);

		if (Camp != none)
		{
			// add aliens to spawn queue
			for (i = 0; i < AlienCount; i++)
			{
				Camp.AddUnitToSpawnQueue(class'HWAlien_Weak', class'HWAlienCamp'.const.MAX_SPAWN_OFFSET, Camp);
			}

			// start spawning
			Camp.SpawnUnits();
		}
		else
		{
			`log("(KISMET) "$self$" has been linked to target object "$o$" which is not an alien camp!");
		}
	}
	
	super.Activated();
}


DefaultProperties
{
	ObjName="Alien Camp - Spawn Aliens"

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="SpawningCamps",PropertyName=SpawningCamps)

	AlienCount=10
}
