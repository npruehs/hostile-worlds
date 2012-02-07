/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class FluidSurfaceActor extends Actor
	dependson(FluidSurfaceComponent)
	native(Fluid)
	AutoExpandCategories(FluidSurfaceActor,FluidSurfaceComponent)
	placeable;

var() editconst const FluidSurfaceComponent FluidComponent;

/** Particle effect to play when projectile hits water */
var() ParticleSystem ProjectileEntryEffect;

cpptext
{
	// UObject interface.
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	// AActor interface.
	virtual void PostEditImport();
	virtual void PostEditMove(UBOOL bFinished);
	virtual void EditorApplyScale(const FVector& DeltaScale, const FMatrix& ScaleMatrix, const FVector* PivotLocation, UBOOL bAltDown, UBOOL bShiftDown, UBOOL bCtrlDown);
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual void CheckForErrors();
	virtual UBOOL IsAFluidSurface() const					{ return TRUE; }
	virtual class AFluidSurfaceActor* GetAFluidSurface()	{ return this; }
}



simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	FluidComponent.ApplyForce( HitLocation, FluidComponent.ForceImpact, FluidComponent.TestRippleRadius, True );
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	Super.Touch( Other, OtherComp, HitLocation, HitNormal );

	Other.ApplyFluidSurfaceImpact(self, HitLocation);
}


defaultproperties
{
	bStatic=false
	bMovable=false
	bNoDelete=true
	bProjTarget=true
	bCollideActors=true
	bBlockActors=false

	Begin Object Class=FluidSurfaceComponent Name=NewFluidComponent
	End Object
	FluidComponent=NewFluidComponent
	Components.Add(NewFluidComponent)

	RemoteRole=ROLE_SimulatedProxy
}
