// ============================================================================
// HWSelectable
// An abstract class for any game object that can be selected by a player.
//
// Author:  Marcel Koehler, Nick Pruehs
// Date:    2010/11/01
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSelectable extends Pawn
	config(HostileWorldsUnitData);

/** The radius to check for other colliding actors within around a random spawn location. */
const COLLISION_CHECK_RADIUS = 75;

/** The time to wait before trying again to spawn new units, in seconds. */
const SPAWN_TICK_TIME = 0.2;

/** A reference to the local player, if he or she has selected this unit. */
var HWPlayerController SelectedBy;

/** The draw scale of this unit. */
var config float Scale;

/** The prefab to load. */
var Prefab PrefabToLoad;

/** Set this vector in subclasses to modify the prefab's location. */
var Vector PrefabTranslation;

/** The meshes this object consists of. */
var array<StaticMeshComponent> Meshes;

/** The sight radius of this pawn in each direction, in UU. */
var config float SightRadiusUU;

/** The number of tiles that are visible to this pawn in each direction. */
var int SightRadiusTiles;

/** The tiles this pawn can see. */
var array<IntPoint> VisibleTiles;

/** Whether this unit is subject to visibility checks, or not. */
var bool bApplyFogOfWar;

/** The acquisition radius of this pawn in each direction, in UU. */
var config int AcquisitionRadiusUU;

/** The index of the team this unit belongs to. */
var repnotify int TeamIndex;  // repnotify, hahahahafafgagagagagagga!!1!1

/** Whether this object changes its color when changing owner. */
var bool bUsesTeamColors;

/** The team colors that are applied to owned objects. */
var LinearColor TeamColors[8];

/** The names of the materials that change their color when this object changes its owner. */
var array<name> TeamMaterialNames;

/** The name of the color parameter of the team material. */
var name TeamColorParameterName;

/** The MaterialInstanceConstants used for changing the team color of this object. */
var array<MaterialInstanceConstant> TeamMatInsts;

/** The map actor describing the map this object lives in. */
var HWMapInfoActor Map;

/** The sound to be played whenever this object is selected. */
var SoundCue SoundSelected;

/** The icon of this unit to be shown in the status window of the UI while this unit is selected. */
var Texture2D UnitPortrait;

/** Holds information about which unit to spawn, where, and how to initialize it. */
struct SpawnInfo
{
	var class<HWPawn> UnitClass;
	var float MaxSpawnOffsetUU;
	var Actor InfoActor;
};

/** The queue of units to be spawned around this object. */
var array<SpawnInfo> UnitsToSpawn;

/** Whether this HWSelectable is inside the view frustum or not. */
var bool bCulled;

/** Whether or not to show a health bar for this unit. */
var bool bShowHealthbar;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// load prefab, if any
	if(PrefabToLoad != none)
	{
		LoadPrefab(PrefabToLoad, true, PrefabTranslation);	
	}

	InitializeTeamColors();

	// read and set draw scale from the config file
	if (Scale > 0)
	{
		SetDrawScale(Scale);
	}
}

/** 
 *  Called for each HWSelectable by HWGame to allow further initialization.
 *  Subclasses may use this function to do all stuff that can't be done in
 *  PostBeginPlay due to the unknown order of Actors for which that function
 *  is called.
 *  
 * @param TheMap            
 *      the HWMapInfoActor of the level the object lives in
 * @param A
 *      a reference to an actor that is required for initializing subclasses
 */
function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	Map = TheMap;
	HearingThreshold = AcquisitionRadiusUU;

	// compute sight radius
	SightRadiusTiles = Round(SightRadiusUU / Map.TileSizeUU);
}

/** 
 *  Performs selection logic for this object, like showing effects and adding
 *  this unit to the collection of selected units of the selecting player.
 *  Returns true if the unit could be selected, false otherwise.
 *  
 *  @param SelectingPlayer
 *      the player that selected this unit
  *  @param bAddToList
 *      whether to add this unit to the collection of selected units of the
 *      selecting player; defaults to true
 */
simulated function bool Select(HWPlayerController SelectingPlayer, optional bool bAddToList = true)
{
	// return if already selected or hidden
	if(SelectedBy == SelectingPlayer || bHidden)
	{
		return false;
	}

	SelectedBy = SelectingPlayer;

	if (bAddToList)
	{
		SelectingPlayer.SelectedUnits.AddItem(self);
	}

	return true;
}

/** 
 *  Performs deselection logic for this object, like hiding effects and
 *  removing this unit from the collection of selected units of the local
 *  player. The latter is optional; if the list is to be cleared anyway,
 *  pass false to save CPU time.
 *  
 *  @param bRemoveFromList
 *      whether to remove this unit from the collection of selected units of
 *      the local player; defaults to true
 */
simulated function Deselect(optional bool bRemoveFromList = true)
{
	if (SelectedBy != none)
	{
		if (bRemoveFromList)
		{
			SelectedBy.SelectedUnits.RemoveItem(self);
			SelectedBy.NotifySelectionChanged();
		}

		SelectedBy = none;
	}
}

/** Returns a bool indicating if this HWSelectable actor shall currently be shown on the mini map.
 *  Default is true, subclasses with another value must override this.
 */
simulated function bool ShowOnMiniMap()
{
	return true;
}

/** 
 *  Helper function which calls AddStaticMesh() on all objects of the given prefab. 
 *  (http://forums.epicgames.com/showthread.php?t=725478)
 *  
 *   @param LocalPrefab
 *      The prefab for which to call AddStaticMesh() on all of its objects
 *      
 *   @param bPhysicsEnabled
 *      Passed on to the AddStaticMesh(StaticMeshActor TMesh, bool bPhysicsEnabled, optional Vector Translation) call
 *      
 *   @param Translation
 *      Passed on to the AddStaticMesh(StaticMeshActor TMesh, bool bPhysicsEnabled, optional Vector Translation) call
 */
simulated function LoadPrefab(Prefab LocalPrefab, bool bPhysicsEnabled, optional Vector Translation)
{
	local int a;

	for(a = 0; a < LocalPrefab.PrefabArchetypes.Length; a++)
	{
		if(StaticMeshActor(LocalPrefab.PrefabArchetypes[a]) != none)
		{
			AddStaticMesh(StaticMeshActor(LocalPrefab.PrefabArchetypes[a]), bPhysicsEnabled, Translation);
		}
	}
}

/** 
 *  Helper function which attaches the given TMesh as component to this actor instance.
 *  Returns the attached StaticMeshComponent. 
 *  (http://forums.epicgames.com/showthread.php?t=725478)
 *  
 *   @param TMesh
 *      The StaticMeshActor to attach as component to this actor instance
 *      
 *   @param bPhysicsEnabled
 *      Set to true in order to let the given mesh block actors and collide with them, and to do collision checks
 *      
 *   @param Translation
 *      Use this vector to modify the TMesh's location
 */
simulated function StaticMeshComponent AddStaticMesh(StaticMeshActor TMesh, bool bPhysicsEnabled, optional Vector Translation)
{
	local StaticMeshComponent SMC;

	if(TMesh != none)
	{
		SMC = new(self) class'StaticMeshComponent';
		AttachComponent(SMC);

		SMC.SetStaticMesh(TMesh.StaticMeshComponent.StaticMesh);
		SMC.SetTranslation(TMesh.Location + Translation);
		SMC.SetRotation(TMesh.Rotation);
		SMC.SetScale3D(TMesh.DrawScale3D);
		SMC.SetScale(TMesh.DrawScale);

		SMC.SetActorCollision(bPhysicsEnabled, bPhysicsEnabled, bPhysicsEnabled);

		SMC.ForceUpdate(false);

		// setup our own list of meshes as Actor::Components is private...
		Meshes.AddItem(SMC);
	}

	return SMC;
}

/** 
 *  Remembers that this object can see the tile with the passed coordinates.
 *  See HWVisibilityMask::HideMapTiles(HWSelectable) for further information. 
 *  
 *  @param x
 *      the x-coordinate of the tile to remember
 *  @param y
 *      the y-coordinate of the tile to remember
 */
simulated function RememberVisibleTile(int X, int Y)
{
	local IntPoint Tile;

	Tile.X = X;
	Tile.Y = Y;

	VisibleTiles.AddItem(Tile);
}

/** Shows this unit if it's hidden and subject to visibility checks. */
simulated function Show()
{
	if (bApplyFogOfWar && bHidden)
	{
		SetHidden(false);

		// change color on clients
		ChangeColor(TeamIndex);
	}
}

/** Hides this unit if it's visible and subject to visibility checks, deselecting it. */
simulated function Hide()
{
	if (bApplyFogOfWar && !bHidden)
	{
		Deselect();
		SetHidden(true);
	}
}

/** Finds and initializes the team color material of this unit. */
simulated function InitializeTeamColors()
{
	local StaticMeshComponent SMC;
	local MaterialInterface TeamMaterial;
	local MaterialInstanceConstant TeamMatInst;
	local int i;

	if (bUsesTeamColors)
	{
		// search for the correct material on static mesh components
		foreach Meshes(SMC)
		{
			for (i = 0; i < SMC.GetNumElements(); i++)
			{
				TeamMaterial = SMC.GetMaterial(i);

				if (TeamMaterial != none && IsTeamMaterialName(TeamMaterial.Name))
				{
					// initialize team color material
					TeamMatInst = new(None) Class'MaterialInstanceConstant';
					TeamMatInst.SetParent(TeamMaterial);
					SMC.SetMaterial(i, TeamMatInst);
					TeamMatInsts.AddItem(TeamMatInst);
				}
			}
		}
		
		if (Mesh != none)
		{
			// search for the correct material on the skeletal mesh
			for (i = 0; i < Mesh.GetNumElements(); i++)
			{
				TeamMaterial = Mesh.GetMaterial(i);

				if (TeamMaterial != none && IsTeamMaterialName(TeamMaterial.Name))
				{
					// initialize team color material
					TeamMatInst = new(None) Class'MaterialInstanceConstant';
					TeamMatInst.SetParent(TeamMaterial);
					Mesh.SetMaterial(i, TeamMatInst);
					TeamMatInsts.AddItem(TeamMatInst);
				}
			}
		}
	}
}

/**
 * Returns true, if the name with the specified name is used for indicating
 * player colors, and false otherwise.
 * 
 * @param MaterialName
 *      the name to check
 */                 
simulated function bool IsTeamMaterialName(name MaterialName)
{
	local name TeamMaterialName;

	foreach TeamMaterialNames(TeamMaterialName)
	{
		if (TeamMaterialName == MaterialName)
		{
			return true;
		}
	}
	
	return false;
}

/**
 * Changes the owner of this object to the specified team, changing its
 * color.
 * 
 * @param NewTeamIndex
 *      the number of the new owner of this object
 */
function ChangeOwner(int NewTeamIndex)
{
	local HWPlayerController aPlayer;

	TeamIndex = NewTeamIndex;

	// hide all map tiles this unit has vision on
	foreach WorldInfo.AllControllers(class'HWPlayerController', aPlayer)
	{
		aPlayer.ResetVisionFor(self);
	}

	`log(self$" is now owned by team: "$NewTeamIndex);

	ChangeColor(NewTeamIndex);
}

/**
 * Changes the color of this object to the color of the specified team.
 * 
 * @param NewTeamIndex
 *      the number of the new color of this object
 */
simulated function ChangeColor(int NewTeamIndex)
{
	local MaterialInstanceConstant TeamMatInst;

	if (bUsesTeamColors)
	{
		foreach TeamMatInsts(TeamMatInst)
		{
			TeamMatInst.SetVectorParameterValue(TeamColorParameterName, TeamColors[NewTeamIndex]);
		}

		`log(self$" changed color to "$TeamIndex);
	}
}

/**
 * Adds a unit of the specified class to this object's spawn queue. The unit
 * will spawn at a random position within the specified radius and be
 * initialized with the passed InfoActor after.
 * 
 * Note that calling this function does not trigger the spawning itself; call
 * SpawnUnits() after the queue has been filled.
 * 
 * @param UnitClass
 *      the class of the unit to spawn
 * @param MaxSpawnOffsetUU
 *      the radius to spawn the new unit within
 * @param InfoActor
 *      the actor to initialize the spawned unit with
 */
function AddUnitToSpawnQueue(class<HWPawn> UnitClass, float MaxSpawnOffsetUU, Actor InfoActor)
{
	local SpawnInfo UnitToSpawn;

	UnitToSpawn.UnitClass = UnitClass;
	UnitToSpawn.MaxSpawnOffsetUU = MaxSpawnOffsetUU;
	UnitToSpawn.InfoActor = InfoActor;

	UnitsToSpawn.AddItem(UnitToSpawn);
}

/**
 * Iterates the spawn queue of this object, trying to spawn all specified units
 * and trying again later if any spawns fail.
 */
function SpawnUnits()
{
	local int i;

	for (i = 0; i < UnitsToSpawn.Length; i++)
	{
		// try to spawn a unit of the queue
		if (SpawnUnit(UnitsToSpawn[i]))
		{
			// remove if successful
			UnitsToSpawn.Remove(i, 1);
			i--;
		}
	}

	// try again later if any spawns failed
	if (UnitsToSpawn.Length > 0)
	{
		SetTimer(SPAWN_TICK_TIME, false, 'SpawnUnits');
	}
}

/** 
 * Tries to spawn a unit of the specified class at a random position within the
 * specified radius. Initialized that unit with the passed information if
 * successful, returning true, and returns false otherwise.
 * 
 * @param UnitToSpawn
 *      the class, spawn offset and initialization information of the unit to spawn
 */
function bool SpawnUnit(SpawnInfo UnitToSpawn)
{
	local HWPawn Unit;
	local Actor a;

	local Vector SpawnOffset;
	local Vector SpawnLocation;

	local Vector CollisionBoxExtent;

	// compute random spawn offset within MaxSpawnOffsetUU
	SpawnOffset.X = rand(UnitToSpawn.MaxSpawnOffsetUU) - UnitToSpawn.MaxSpawnOffsetUU / 2;
	SpawnOffset.Y = rand(UnitToSpawn.MaxSpawnOffsetUU) - UnitToSpawn.MaxSpawnOffsetUU / 2;
	
	// compute the probable spawn location
	SpawnLocation.X = Location.X + SpawnOffset.X;
	SpawnLocation.Y = Location.Y + SpawnOffset.Y;
	SpawnLocation.Z = Location.Z;

	CollisionBoxExtent.X = COLLISION_CHECK_RADIUS;
	CollisionBoxExtent.Y = COLLISION_CHECK_RADIUS;

	// check SpawnLocation for collision with the world geometry
	if (FindSpot(CollisionBoxExtent, SpawnLocation))
	{
		// check for encroaching actors
		foreach CollidingActors(class'Actor', a, COLLISION_CHECK_RADIUS, SpawnLocation)
		{
			return false;
		}

		// try and spawn a new unit
		Unit = Spawn(UnitToSpawn.UnitClass, Owner,, SpawnLocation);

		if (Unit != none)
		{
			Unit.Initialize(Map, UnitToSpawn.InfoActor);
			return true;
		}
	}

	return false;
}

/** Returns the height level this object is currently on. */
simulated function byte GetHeightLevel()
{
	return Map.GetTileHeightFromLocation(Location);
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'TeamIndex')
	{
		ChangeColor(TeamIndex);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

state RoundEnded
{
	ignores SpawnUnits;
}

replication
{
	// Replicate if server
	if (Role == ROLE_Authority && (bNetInitial || bNetDirty))
		TeamIndex, SightRadiusTiles;
}

defaultproperties
{
	bAlwaysRelevant=true

	TeamIndex=7
	
	TeamColors(0)=(R=0.000000,G=1.000000,B=0.000000,A=1.000000) // green
	TeamColors(1)=(R=0.000000,G=0.000000,B=1.000000,A=1.000000) // blue
	TeamColors(2)=(R=1.000000,G=0.000000,B=0.000000,A=1.000000) // red
	TeamColors(3)=(R=1.000000,G=0.000000,B=1.000000,A=1.000000) // purple

	bApplyFogOfWar=true

	bShowHealthbar=true

	TeamColorParameterName=TeamColor
}