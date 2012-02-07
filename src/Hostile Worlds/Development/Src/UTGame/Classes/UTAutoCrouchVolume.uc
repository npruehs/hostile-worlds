/** this volume automatically crouches console players as there's no manual crouch on the console controls  
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTAutoCrouchVolume extends Volume
	placeable;

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local Pawn P;

	P = Pawn(Other);
	if (P != None && P.bCanCrouch)
	{
		SetCrouch(P, 1);
		SetTimer(0.1, true, 'CrouchTimer');
	}
}

/** turns on/off crouching for the specified Pawn if it is controlled by a console player */
simulated function SetCrouch(Pawn P, byte bCrouch)
{
	local UTConsolePlayerController PC;
	local vector Dir, HitLocation, HitNormal;

	PC = UTConsolePlayerController(P.Controller);
	// only if facing towards center of the volume
	Dir = vector(P.Rotation) * 5000.0;
	if (PC != None && (bCrouch == 0 || TraceComponent(HitLocation, HitNormal, CollisionComponent, P.Location + Dir, P.Location - Dir)))
	{
		PC.bDuck = bCrouch;
	}
}

simulated event UnTouch(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	if (P != None && P.bCanCrouch)
	{
		SetCrouch(P, 0);
	}
}

/** timer used to make sure console players in the volume stay crouched (in case some action resets it) */
simulated function CrouchTimer()
{
	local Pawn P;
	local bool bStillTouching;

	foreach TouchingActors(class'Pawn', P)
	{
		if (P.bCanCrouch)
		{
			SetCrouch(P, 1);
			bStillTouching = true;
		}
	}

	if (!bStillTouching)
	{
		ClearTimer('CrouchTimer');
	}
}

defaultproperties
{
	bCollideActors=true
	bColored=true
	bStatic=false
	bNoDelete=true
	BrushColor=(R=64,G=64,B=255,A=255)
}
