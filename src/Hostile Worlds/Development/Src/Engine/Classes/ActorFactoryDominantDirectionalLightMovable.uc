/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryDominantDirectionalLightMovable extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;

defaultproperties
{
	MenuName="Add Light (DominantDirectionalLightMovable)"
	NewActorClass=class'Engine.DominantDirectionalLightMovable'
}
