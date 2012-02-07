/**
 * Base class for all events implemented by scenes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent_Scene extends UIEvent
	native(inherit)
	abstract;

DefaultProperties
{
	bPlayerOnly=false
	MaxTriggerCount=0
}
