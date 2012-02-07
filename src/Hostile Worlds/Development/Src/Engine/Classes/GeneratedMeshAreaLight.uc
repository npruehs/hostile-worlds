/**
 * GeneratedMeshAreaLight - A light type that is created after a lighting build with Lightmass and handles mesh area light influence on dynamic objects.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GeneratedMeshAreaLight extends SpotLight
	native(Light)
	notplaceable;

defaultproperties
{
	// Don't want these to be modified by users since they will all be regenerated on the next lighting build
	bEditable=false
	Begin Object Name=SpotLightComponent0
		LightingChannels=(BSP=FALSE,Static=FALSE,Dynamic=TRUE,bInitialized=TRUE)
		CastStaticShadows=FALSE
	End Object
}
