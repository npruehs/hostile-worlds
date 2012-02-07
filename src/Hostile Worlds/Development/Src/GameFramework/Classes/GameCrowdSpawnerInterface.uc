/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Used by classes which spawn crowd agents and want to be notified when they are destroyed.
 */

interface GameCrowdSpawnerInterface;

function AgentDestroyed(GameCrowdAgent Agent);

function bool AddToAgentPool(GameCrowdAgent Agent);

function float GetMaxSpawnDist();
