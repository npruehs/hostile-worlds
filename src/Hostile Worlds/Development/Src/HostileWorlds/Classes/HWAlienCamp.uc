// ============================================================================
// HWAlienCamp
// A alien camp of Hostile Worlds. Allows remembering the initial positions of
// its aliens that have been placed in the level editor and repopulating
// itself.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/10/16
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAlienCamp extends HWGameObject
	placeable;

/** The minimum number of aliens spawning around a camp. */
const MINIMUM_ALIEN_COUNT = 10;

/** The maximum number of aliens spawning around a camp. */
const MAXIMUM_ALIEN_COUNT = 10;

/** The maximum offset aliens spawn around a camp. */
const MAX_SPAWN_OFFSET = 300;


/** The mesh of this alien camp. */
var() transient StaticMeshComponent CampMesh;


/** Initializes this camp, spawning a random number of aliens around. */
function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	local int AliensToSpawn;
	local int i;

	super.Initialize(TheMap, A);

	// compute random number of aliens to spawn
	AliensToSpawn = MINIMUM_ALIEN_COUNT + Rand(MAXIMUM_ALIEN_COUNT - MINIMUM_ALIEN_COUNT + 1); 

	// add aliens to spawn queue
	for (i = 0; i < AliensToSpawn; i++)
	{
		AddUnitToSpawnQueue(class'HWAlien_Weak', MAX_SPAWN_OFFSET, self);
	}

	// start spawning
	SpawnUnits();
}

/** 
 *  Notifies this camp that an alien has died and should be respawned
 *  after RespawnTime.
 *  
 *  @param RespawnTime
 *      the time after an alien shall be respawned, in seconds
 */
function NotifyAlienDied(int RespawnTime)
{
	`Log(self$" has been notified that an alien has died.");

	AddUnitToSpawnQueue(class'HWAlien_Weak', MAX_SPAWN_OFFSET, self);

	SetTimer(RespawnTime, false, 'SpawnUnits');
}

/** AlienCamps shall never be shown on the minimap. */
simulated function bool ShowOnMiniMap()
{
	return false;
}

/** 
 *  Overriding the base implementation in order
 *  to prevent the default destruction of the HWAlienCamp
 *  and return to the "no state".
 */
function Reset()
{
	GoToState('');
}

state RoundEnded
{
	ignores NotifyAlienDied, Initialize;
}

DefaultProperties
{
	SoundSelected=SoundCue'A_Test_Voice_Units.LizardDogBattleCry_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_AlienCamp_Test'

	Begin Object Class=StaticMeshComponent Name=Mesh
	    CastShadow=true
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		CollideActors=false
		BlockActors=true
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		Scale=0.3
		MaxDrawDistance=4000
		StaticMesh=StaticMesh'DEMO_GeneralAssets.Mesh.S_creepCave'
		Translation=(X=0,Y=-250.0,Z=-50)
	End Object
	CampMesh=Mesh
	Components.Add(Mesh)

	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=24.0
		CollisionHeight=14.4
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
}
