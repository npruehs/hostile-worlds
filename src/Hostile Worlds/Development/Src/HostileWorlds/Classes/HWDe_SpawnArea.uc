// ============================================================================
// HWDe_SpawnArea
// Uses Unreal's decals system to indicate the areas where the player can
// respawn his or her commander.
//
// Author:  Nick Pruehs
// Date:    2011/06/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWDe_SpawnArea extends HWDecal;

/** 
 *  Returns true if this spawn area contains the passed point in
 *  the x-y-plane, and false otherwise.
 *  
 *  @param Point
 *      the point to check
 */
simulated function bool Contains(Vector Point)
{
	local Vector DistanceVector;
	local float Distance;

	DistanceVector.X = Point.X - Location.X;
	DistanceVector.Y = Point.Y - Location.Y;
    
	Distance = Sqrt((DistanceVector.X * DistanceVector.X) + (DistanceVector.Y * DistanceVector.Y));

	return (Distance <= InitialRadius);
}


DefaultProperties
{
	Begin Object Name=NewDecalComponent
		DecalMaterial=DecalMaterial'FX_Decals.M_FX_SpawnArea'
	End Object
}
