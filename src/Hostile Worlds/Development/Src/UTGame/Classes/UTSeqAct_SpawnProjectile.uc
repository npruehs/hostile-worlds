/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
/** spawns a projectile at a certain location that moves toward the given location with the given Instigator */
class UTSeqAct_SpawnProjectile extends SequenceAction;

/** Class of projectile to spawn */
var() class<Projectile> ProjectileClass;

event Activated()
{
	local Controller InstigatorController;
	local Pawn InstigatorPawn;
	local vector SpawnLoc, TargetLoc;
	local Projectile Proj;

	if ( VariableLinks.length < 3 || VariableLinks[0].LinkedVariables.length == 0 ||
		VariableLinks[1].LinkedVariables.length == 0 || VariableLinks[2].LinkedVariables.length == 0 )
	{
		ScriptLog("ERROR: All variable links must be filled");
	}
	else
	{
		// get the instigator
		if (VariableLinks[2].LinkedVariables.length > 0)
		{
			InstigatorController = Controller(SeqVar_Object(VariableLinks[2].LinkedVariables[0]).GetObjectValue());
			if (InstigatorController != None)
			{
				InstigatorPawn = InstigatorController.Pawn;
			}
			else
			{
				InstigatorPawn = Pawn(SeqVar_Object(VariableLinks[2].LinkedVariables[0]).GetObjectValue());
				if (InstigatorPawn != None)
				{
					InstigatorController = InstigatorPawn.Controller;
				}
				else if (SeqVar_Object(VariableLinks[2].LinkedVariables[0]).GetObjectValue() != None)
				{
					ScriptLog("ERROR: Instigator specified for" @ self @ "is not a Controller");
				}
			}
		}
		// get the spawn location
		SpawnLoc = SeqVar_Vector(VariableLinks[0].LinkedVariables[0]).VectValue;
		TargetLoc = SeqVar_Vector(VariableLinks[1].LinkedVariables[0]).VectValue;

		// spawn a projectile at the requested location and point it at the requested target
		Proj = GetWorldInfo().Spawn(ProjectileClass,,, SpawnLoc);
		if (InstigatorController != None)
		{
			Proj.Instigator = InstigatorPawn;
			Proj.InstigatorController = InstigatorController;
		}
		Proj.Init(Normal(TargetLoc - SpawnLoc));
	}
}


defaultproperties
{
	bCallHandler=false
	ObjName="Spawn Projectile"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Spawn Location",MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Target Location",MinVars=1,MaxVars=1)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Instigator",MinVars=0,MaxVars=1)
}
