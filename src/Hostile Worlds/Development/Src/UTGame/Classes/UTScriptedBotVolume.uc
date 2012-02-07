/**
 * volume that kills Kismet created bots that leave it
 * 
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTScriptedBotVolume extends PhysicsVolume;

event PawnLeavingVolume(Pawn Other)
{
	local UTBot Bot;

	Bot = UTBot(Other.Controller);
	if (Bot != None && Bot.bSpawnedByKismet)
	{
		Other.Died(None, class'UTDmgType_Instagib', Other.Location);
	}
}
