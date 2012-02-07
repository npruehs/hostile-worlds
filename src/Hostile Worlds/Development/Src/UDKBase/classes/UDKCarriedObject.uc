/**
 * Gameplay relevant carried object (such as a CTF Flag)
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKCarriedObject extends Actor
    native 
	abstract 
	notplaceable;

/** Team this CarriedObject is associated with */
var repnotify TeamInfo 		Team;

/** Recent nearest path */
var const NavigationPoint LastAnchor;	

/** last time a valid anchor was found */
var		float	LastValidAnchorTime;	

/** The Skeletal Mesh of the flag */
var SkeletalMeshComponent SkelMesh;

/** Replicated to indicate whether this CarriedObject is in its HomeBase */
var repnotify bool bHome;

/** Game objective which acts as home base for this CarriedObject */
var UDKGameObjective   HomeBase;

/** offset for placing object when at home */
var vector HomeBaseOffset;

// Keep track of our base-most actor.
var Actor	OldBase;
var Actor	OldBaseBase;

/** HUD Rendering (for minimap) - updated in SetHUDLocation() */
var vector HUDLocation;

cpptext
{
	/*
	 * Special handling of network replication
	 */
	virtual void PostNetReceiveBase(AActor* NewBase);
	virtual void PostNetReceiveLocation();

	/*
	 * Route finding notifications (sent to target)
	 */
	virtual ANavigationPoint* SpecifyEndAnchor(APawn* RouteFinder);
	virtual void NotifyAnchorFindingResult(ANavigationPoint* EndAnchor, APawn* RouteFinder);
	virtual void TickSpecial(FLOAT DeltaSeconds);

	virtual void ForceUpdateComponents(UBOOL bCollisionUpdate = FALSE,UBOOL bTransformOnly = TRUE);
}

replication
{
    if (Role == ROLE_Authority)
		bHome, HomeBase, Team;
}

/** function used to update where icon for this actor should be rendered on the HUD
 *  @param NewHUDLocation is a vector whose X and Y components are the X and Y components of this actor's icon's 2D position on the HUD
 */
simulated native function SetHUDLocation(vector NewHUDLocation);

/**
  * Called from C++ if this carried object can't be reached by Pawn P
  */
event NotReachableBy(Pawn P);

/**
  * Event called when there is a change in the base chain (base or the base of the base, etc.)
  */
simulated event OnBaseChainChanged();

/** GetTeamNum()
* returns teamindex of team with which this UDKCarriedObject is associated.
*/
simulated native function byte GetTeamNum();

