/*=============================================================================
	PhysXDestructible.uc: Destructible Vertical Component.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class PhysXDestructible extends Object
	hidecategories(Object)
	native(Mesh);

struct native PhysXDestructibleDepthParameters
{
	/** Setting to false allows an optimization for smaller pieces */
	var()	bool	bTakeImpactDamage;	
	
	/** Whether or not to play FractureSound */
	var()	bool	bPlaySoundEffect;

	/** Whether or not to play FracturedStaticMesh's FragmentDestroyEffect */
	var()	bool	bPlayParticleEffect;
	
	/** Whether or not to timeout after LOD lifetime */
	var()	bool	bDoNotTimeOut;

	var		bool	bNoKillDummy;	// Workaround for a strange array copying bug that would truncate the zero elements from the end of the array

	structdefaultproperties
	{
		bNoKillDummy=true
	}
};

struct native PhysXDestructibleParameters
{
	/** Damage needed for fracturing or crumbling.  Defines a damage scale for the destructible. */
	var()	float							DamageThreshold;

	/** Transformation of damage (in units of DamageThreshold) to damage radius (as a fraction of actor size). */
	var()	float							DamageToRadius;

	/** Cap on damage that can be applied.  0 => no cap. */
	var()	float							DamageCap;

	/** Transformation of impact force to damage.  (In units of DamageThreshold.)*/
	var()	float							ForceToDamage;

	/** Sound cue to play when pieces fracture. */
	var()	SoundCue						FractureSound;

	/** Particle system to spawn when pieces crumble. */
	var()	ParticleSystem					CrumbleParticleSystem;

	/** Spacing between crumble particles. */
	var()	float							CrumbleParticleSize;

	/** Depth at which a chunk is considered "debris."
	  * This may have several implications: network relevance, pathfinding relevance, and lifetime, e.g. 
	  */
	var()	bool							bAccumulateDamage;

	/** Cached derived value */
	var		float							ScaledDamageToRadius;
	
	/** Depth-dependent parameters */
	var()	editfixedsize	array<PhysXDestructibleDepthParameters>	DepthParameters;

	structdefaultproperties
	{
		DamageThreshold=5.0f
		DamageToRadius=0.1f
		ForceToDamage=0.0f
		CrumbleParticleSize=10.f
		bAccumulateDamage=true
	}
};

/** The original FracturedStaticMesh. */
var					FracturedStaticMesh				FracturedStaticMesh;

/** One asset for each top-level fractured piece. */
var					array<PhysXDestructibleAsset>	DestructibleAssets;

/** Destructible parameters. */
var()	editinline	PhysXDestructibleParameters		DestructibleParameters;

/** Scales at which to pre-cook meshes. */
var()				array<vector>					CookingScales;

cpptext
{
	/**	Editor change to CookingScales gets applied to all DestructibleAssets */
	UBOOL	ApplyCookingScalesToAssets();
}

defaultproperties
{
	CookingScales.add((X=1.0f,Y=1.0f,Z=1.0f));
}
