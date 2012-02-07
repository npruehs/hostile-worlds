/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTRotatingDroppedPickup extends UTDroppedPickup;

var() float YawRotationRate;

simulated event Tick(float DeltaTime)
{
	Local Rotator NewRotation;

	if( PickupMesh != None && WorldInfo.NetMode != NM_DedicatedServer && (WorldInfo.TimeSeconds - LastRenderTime < 0.2) )
	{
		NewRotation = PickupMesh.Rotation;
		NewRotation.Yaw += DeltaTime * YawRotationRate;
		PickupMesh.SetRotation(NewRotation);

		if ( PickupParticles != None )
		{
			NewRotation = PickupParticles.Rotation;
			NewRotation.Yaw += DeltaTime * YawRotationRate;
			PickupParticles.SetRotation(NewRotation);
		}
	}
}

defaultproperties
{
	YawRotationRate=32768
}