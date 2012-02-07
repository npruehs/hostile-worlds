/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleLifetimeBase extends ParticleModule
	native(Particle)
	editinlinenew
	hidecategories(Object)
	abstract;

cpptext
{
	/** Return the maximum lifetime this module would return. */
	virtual FLOAT	GetMaxLifetime()
	{
		return 0.0f;
	}
}
