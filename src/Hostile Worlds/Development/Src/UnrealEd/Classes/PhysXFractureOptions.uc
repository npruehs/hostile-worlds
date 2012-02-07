/*=============================================================================
	PhysXFractureOptions.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXFractureOptions extends Object	
	hidecategories(Object)
	config(Editor)
	native;	

struct native PhysXSlicingParameters
{
	/** Number of slices in X, Y and Z. */
	var()	int		SlicesInX, SlicesInY, SlicesInZ;

	/** The linear noise on the splitting planes.*/
	var()	vector	LinearNoise;

	/** The angular noise on the splitting planes. */
	var()	vector	AngularNoise;

	structdefaultproperties
	{
		SlicesInX=1
		SlicesInY=1
		SlicesInZ=1
		LinearNoise=(X=0.1f,Y=0.1f,Z=0.1f)
		AngularNoise=(X=20.0f,Y=20.0f,Z=20.0f)
	}
};

/** Per-level slicing parameters */
var()	array<PhysXSlicingParameters>	SlicingLevels;

defaultproperties
{
	SlicingLevels.add(());
}
