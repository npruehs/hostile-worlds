/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


/** used on non-owning clients when driving a UTWeaponPawn, as those aren't replicated for performance reasons
 * but lots of code looks for Pawn.DrivenVehicle so we need something there
 */
class UTClientSideWeaponPawn extends UTWeaponPawn;

simulated function PreBeginPlay();

simulated function AttachDriver(Pawn P)
{
	Driver = P;
	bDriving = true;
	Super.AttachDriver(P);
}

simulated function DetachDriver(Pawn P)
{
	Super.DetachDriver(P);
	Destroy();
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// make sure we get destroyed when no longer in use
	if (Driver == None || Driver.bDeleteMe || Driver.DrivenVehicle != self)
	{
		Destroy();
	}
}

