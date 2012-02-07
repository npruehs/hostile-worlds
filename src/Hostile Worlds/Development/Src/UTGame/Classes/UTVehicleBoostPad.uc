/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleBoostPad extends Actor
	placeable;

var()	bool						bInitiallyOn;
var() 	float						BoostPower, BoostDamping;
var()	array<class<UTVehicle> >	AffectedVehicles;

var		bool 						bCurrentlyActive;
var		array<UTVehicle>			VehicleList;

simulated event PostBeginPlay()
{
	bCurrentlyActive = bInitiallyOn;
	Disable('Tick');
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	bCurrentlyActive = !bCurrentlyActive;
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local bool bFound;
	local UTVehicle UTV;

	UTV = UTVehicle(Other);

	if (UTV != None && bCurrentlyActive)
	{
		if (AffectedVehicles.Length > 0)
			bFound = (AffectedVehicles.Find(UTV.Class) != -1);
		else
			bFound = TRUE;
	}

	if (bFound)
	{
		VehicleList[VehicleList.Length] = UTV;
		Enable('Tick');

		// If we have a sound to play, and not dedicated server, play it
		if(WorldInfo.NetMode != NM_DedicatedServer && UTV.BoostPadSound != None)
		{
			PlaySound(UTV.BoostPadSound, TRUE, , , UTV.Location);
		}
	}
}

event UnTouch(Actor Other)
{
	local int Idx;
	local UTVehicle UTV;

	UTV = UTVehicle(Other);

	if (UTV != None)
	{
		Idx = VehicleList.Find(UTV);

		if (Idx >= 0)
			VehicleList.Remove(Idx, 1);
	}
}

simulated function vector CalculateForce(vector CarLocation, vector CarVelocity)
{
	local vector X,Y,Z;
	local vector BoostForce, BoostNormal;

	GetAxes(rotation, X, Y, Z);

	BoostForce = X * BoostPower;
	BoostNormal = Normal(BoostForce);

	BoostForce -= BoostNormal * (CarVelocity dot BoostNormal) * BoostDamping;

	return BoostForce;
}

function Tick(float DT)
{
	local vector CalculatedForce;
	local int i;

	if (VehicleList.Length == 0)
		Disable('Tick');

	if (bCurrentlyActive)
	{
		for (i = 0; i < VehicleList.Length; i++)
		{
			CalculatedForce = CalculateForce(VehicleList[i].Location, VehicleList[i].Velocity);
			VehicleList[i].Mesh.AddForce(CalculatedForce);
		}
	}
}

DefaultProperties
{
	Begin Object Class=ArrowComponent Name=ArrowComponent0
		ArrowColor=(R=0,G=255,B=128)
		ArrowSize=5.5
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(ArrowComponent0)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'UN_SimpleMeshes.TexPropCube_Dup'
		Materials(0)=Material'Envy_Effects.Energy.Materials.M_EFX_Energy_Loop_Scroll_01'
		CollideActors=True
		CastShadow=False
		HiddenGame=True
		bAcceptsLights=False
		BlockRigidBody=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=TRUE
		Scale3D=(X=2.0,Y=1.0,Z=0.4)
	End Object
	CollisionComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	BoostPower=1500
	BoostDamping=0.01

	bCollideActors=True
	bAlwaysRelevant=true
	bMovable=true
	bWorldGeometry=false
	bInitiallyOn=true
}
