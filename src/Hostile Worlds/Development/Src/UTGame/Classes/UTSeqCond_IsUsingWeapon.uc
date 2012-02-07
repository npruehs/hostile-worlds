/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqCond_IsUsingWeapon extends SequenceCondition;

/** player to look for inventory on */
var Actor Target;
/** weapon to check */
var() class<Weapon> RequiredWeapon;
/** whether subclasses of the specified class count */
var() bool bAllowSubclass;

/** Ii this is true, the weapon must be the Impact Hammer */
var() bool bMustBeImpactHammer;

event Activated()
{
	local Pawn P;
	local bool bHasItem;

	P = GetPawn(Target);
	if (P != None)
	{
		if (P.Weapon != None)
		{

			if ( bMustBeImpactHAmmer )
			{
				bHasItem = false;
			}
			else
			{
				bHasItem = (bAllowSubclass ? ClassIsChildOf(P.Weapon.Class, RequiredWeapon) : P.Weapon.Class == RequiredWeapon);
			}
		}

		OutputLinks[bHasItem ? 0 : 1].bHasImpulse = true;
	}
}

defaultproperties
{
	ObjName="Is Using Weapon"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
	OutputLinks[0]=(LinkDesc="Using It")
	OutputLinks[1]=(LinkDesc="Not Using It")
}
