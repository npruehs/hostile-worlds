// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
class UTMutator_NoPowerups extends UTMutator;

function bool CheckReplacement(Actor Other)
{
	local UTPickupFactory F;

	F = UTPickupFactory(Other);
	return (F == None || (!F.bIsSuperItem && !F.IsA('UTPickupFactory_JumpBoots')));
}

defaultproperties
{
	GroupNames[0]="POWERUPS"
}
