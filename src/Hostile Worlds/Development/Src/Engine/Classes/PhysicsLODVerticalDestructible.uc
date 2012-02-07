/*=============================================================================
	PhysXLODVerticalDestructible.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysicsLODVerticalDestructible extends Object
	native(Physics)
	config(Engine);

var native config int	MaxDynamicChunkCount;
var native config float	DebrisLifetime;

defaultproperties
{
}
