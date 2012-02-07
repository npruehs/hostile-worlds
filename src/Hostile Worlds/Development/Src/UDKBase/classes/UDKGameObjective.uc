/**
 * 
 * 
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKGameObjective extends NavigationPoint
	abstract
	hidecategories(VehicleUsage)
	native
	nativereplication;

/** pre-calculated list of nearby NavigationPoints this objective is shootable from */
var array<NavigationPoint> ShootSpots;

/** if true, allow this objective to be unreachable as long as we could find some ShootSpots for it */
var bool bAllowOnlyShootable;

/** HUD Rendering (for minimap) - updated in SetHUDLocation() */
var vector HUDLocation;

/** Texture from which minimap icon for this objective should be grabbed */
var const Texture2D IconHudTexture;

/** Coordinates on IconHudTextures for this objective's minimap icon */
var TextureCoordinates IconCoords;

/** TeamIndex of team which defends this objective */
var		repnotify byte	DefenderTeamIndex;	

/** Replicated notification of whether this objective is currently under attack */
var repnotify bool bUnderAttack;

cpptext
{
	virtual void CheckForErrors();
	INT* GetOptimizedRepList(BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel);
	virtual void AddForcedSpecs(AScout* Scout);
	virtual void SetNetworkID(INT InNetworkID);
}

replication
{
	if ( (Role==ROLE_Authority) && bNetDirty )
		DefenderTeamIndex, bUnderAttack;
}

/**
 * Used for a notification chain when an objective changes
 */
function ObjectiveChanged();

/**
 * Returns the actual viewtarget for this actor.  Should be subclassed
 */
event actor GetBestViewTarget()
{
	return self;
}

/**
  * Should return true if bot controlled by C is considered "near" this objective
  */
function bool BotNearObjective(AIController C);

function TriggerFlagEvent(name EventType, Controller EventInstigator);

/** function used to update where icon for this actor should be rendered on the HUD
 *  @param NewHUDLocation is a vector whose X and Y components are the X and Y components of this actor's icon's 2D position on the HUD
 */
simulated native function SetHUDLocation(vector NewHUDLocation);

/**
  * Draw this objective's icon on the HUD minimap
  */
simulated native function DrawIcon(Canvas Canvas, vector IconLocation, float IconWidth, float IconAlpha, UDKPlayerController PlayerOwner, LinearColor DrawColor);

/**
  * Returns TeamIndex of Team currently associated with (defending) this objective.
  */
simulated native function byte GetTeamNum();

defaultproperties
{
	bMustBeReachable=true
}
