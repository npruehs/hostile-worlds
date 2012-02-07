// ============================================================================
// HWDe_SpawnProtectionArea
// Uses Unreal's decals system to indicate where respawning a commander is
// prohibited.
//
// Author:  Nick Pruehs
// Date:    2011/03/03
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWDe_SpawnProtectionArea extends HWDecal;

/** 
 *  Returns true if this spawn protection area contains the passed point in
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
		DecalMaterial=DecalMaterial'FX_Decals.M_FX_SpawnProtectionRadius'
	End Object
}
