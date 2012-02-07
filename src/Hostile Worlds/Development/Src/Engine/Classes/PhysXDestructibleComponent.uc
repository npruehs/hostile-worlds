/*=============================================================================
	PhysXDestructibleComponent.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXDestructibleComponent extends PrimitiveComponent
	native(Mesh);


var		RB_BodySetup	DetailedCollision;

var		array<byte>		Fragmented;

var		array<int>		BoxElemStart;
var		array<int>		ConvexElemStart;

cpptext
{
	UBOOL							CreateDetailedCollisionFromDestructible( UPhysXDestructible * Destructible, URB_BodySetup * Template );
	
	UBOOL							DestroyStaticFragmentCollision( INT FragmentIndex );

	/* PrimitiveComponent interface */
	virtual class URB_BodySetup*	GetRBBodySetup();
	virtual void InitComponentRBPhys(UBOOL bFixed);
};
