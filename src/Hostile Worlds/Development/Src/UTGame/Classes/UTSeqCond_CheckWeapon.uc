/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqCond_CheckWeapon extends SequenceCondition;

var Actor Target;
var() class<UTWeapon> TestForWeaponClass;

event Activated()
{
	local UTPawn P;
	local UTPlayerController PC;
	local bool Results;

	PC = UTPlayerController(Target);
	if ( PC != none )
	{
		P = UTPawn(PC.Pawn);
		if ( P != none  )
		{
			Results = P.Weapon.Class == TestForWeaponClass;
		}
	}

	OutputLinks[ Results ? 0 : 1].bHasImpulse = true;
}


defaultproperties
{
	ObjName="UTWeaponTest"
	OutputLinks(0)=(LinkDesc="Weapon Equipped")
	OutputLinks(1)=(LinkDesc="Weapon Not Equipped")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)

}


