/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryPylon extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;

defaultproperties
{
	MenuName="Add Pylon"
	NewActorClass=class'Engine.Pylon'
}
