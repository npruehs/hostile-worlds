/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class DMC_Base extends Actor
	placeable
	native(Prefab);

var     array<ActorComponent>   CreatedComponents;

function k2call PrintString(string InString)
{
	`log(InString);
}

function k2call float GetWorldTime()
{
	return WorldInfo.TimeSeconds;
}

static function k2pure float Conv_IntToFloat(int InInt)
{
	return InInt;
}

static function k2pure string Conv_FloatToString(float InFloat)
{
	return string(InFloat);
}

static function k2pure string Conv_IntToString(int InInt)
{
	return string(InInt);
}

static function k2pure string Conv_BoolToString(bool InBool)
{
	return string(InBool);
}

static function k2pure string Conv_VectorToString(vector InVec)
{
	return string(InVec);
}

static function k2pure string Conv_RotatorToString(rotator InRot)
{
	return string(InRot);
}

static function k2pure vector MakeVector(float X, float Y, float Z)
{
	local vector RetVec;
	RetVec.X = X;
	RetVec.Y = Y;
	RetVec.Z = Z;
	return RetVec;
}

static function k2pure BreakVector(vector InVec, out float X, out float Y, out float Z)
{
	X = InVec.X;
	Y = InVec.Y;
	Z = InVec.Z;
}

static function k2pure rotator MakeRot(float Pitch, float Yaw, float Roll)
{
	local rotator RetRot;
	RetRot.Pitch = Round(65536.0 * (Pitch / 360.0));
	RetRot.Yaw = Round(65536.0 * (Yaw / 360.0));
	RetRot.Roll = Round(65536.0 * (Roll / 360.0));
	return RetRot;
}

static function k2pure BreakRot(rotator InRot, out float Pitch, out float Yaw, out float Roll)
{
	Pitch = 360.0 * (InRot.Pitch / 65536.0);
	Yaw = 360.0 * (InRot.Yaw / 65536.0);
	Roll = 360.0 * (InRot.Roll / 65536.0);
}

/** 
 *  Create a new component give the template.
 *  Not marked k2call, as there is a special K2 node type that knows it can call this function.
 */
native function ActorComponent AddComponent(ActorComponent Template);

event k2override DMCCreate();

event k2override DMCTakeDamage(int DamageAmount, vector HitLocation, vector Momentum);


event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	DMCTakeDamage(DamageAmount, HitLocation, Momentum);
}

cpptext
{
	void ClearDMC();

	void RegenDMC();

	virtual void ProcessEvent( UFunction* Function, void* Parms, void* UnusedResult=NULL );

	virtual void PostLoad();
	virtual void PostEditMove(UBOOL bFinished);

	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
}

defaultproperties
{
	bEdShouldSnap=TRUE
	bCollideActors=TRUE
	bBlockActors=TRUE
}