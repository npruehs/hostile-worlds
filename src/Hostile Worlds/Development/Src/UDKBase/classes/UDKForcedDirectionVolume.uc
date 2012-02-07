//=============================================================================
// used to force UDKVehicles [of a certain class if wanted] in a certain direction
//
// Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class UDKForcedDirectionVolume extends PhysicsVolume
	placeable
	native;

/** Allows the ForceDirectionVolume to be limited to certain types of vehicles */
var() class<UDKVehicle> TypeToForce;

/** If true, doesn't affect hoverboards */
var() bool bIgnoreHoverboards;

/** For editing - specifies the forced direction */
var() const ArrowComponent Arrow;

/** if the vehicle is being affected by a force volume with this flag set, the player cannot exit the vehicle. */
var() bool bDenyExit; 

/** Whether non-vehicle pawns should be blocked by this volume */
var() bool bBlockPawns;

/** Whether spectators should be blocked by this volume. */
var() bool bBlockSpectators;

/** Direction arrow is pointing */
var vector ArrowDirection;

/** Array of vehicles currently touching this volume */
var array<UDKVehicle> TouchingVehicles;

cpptext
{
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	UBOOL IgnoreBlockingBy( const AActor *Other ) const;
	virtual void TickSpecial(FLOAT DeltaSeconds );
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if ( !bBlockSpectators && (BrushComponent != None) )
	{
		BrushComponent.SetTraceBlocking(false,true);
	}
}

event ActorEnteredVolume(Actor Other)
{
	if ( PlayerController(Other) != None )
	{
		Other.FellOutOfWorld(None);
	}
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local UDKVehicle V;

	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	V = UDKVehicle(Other);
	if ((V != None) && ClassIsChildOf(V.Class, TypeToForce) && V.OnTouchForcedDirVolume(self))
	{
		TouchingVehicles.AddItem(V);
		if (bDenyExit)
		{
			V.bAllowedExit = false;
		}
	}
}

simulated event UnTouch(Actor Other)
{
	local bool bInAnotherVolume;
	local UDKForcedDirectionVolume AnotherVolume;

	if (ClassIsChildOf(Other.class, TypeToForce))
	{
		TouchingVehicles.RemoveItem(UDKVehicle(Other));
		if (bDenyExit)
		{
			foreach Other.TouchingActors(class'UDKForcedDirectionVolume', AnotherVolume)
			{
				if (AnotherVolume.bDenyExit)
				{
					bInAnotherVolume = true;
					break;
				}
			}
			if (!bInAnotherVolume)
			{
				UDKVehicle(Other).bAllowedExit = UDKVehicle(Other).default.bAllowedExit;
			}
		}
	}
}

simulated function bool StopsProjectile(Projectile P)
{
	return false;
}

defaultproperties
{
	Begin Object Class=ArrowComponent Name=AC
		ArrowColor=(R=150,G=100,B=150)
		ArrowSize=5.0
		AbsoluteRotation=true
		bDisableAllRigidBody=false
	End Object
	Components.Add(AC)
	Arrow=AC

	TypeToForce=class'UDKVehicle'

	Begin Object Name=BrushComponent0
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=TRUE
		RBChannel=RBCC_Untitled4
	End Object

	bPushedByEncroachers=FALSE
	bMovable=FALSE
	bWorldGeometry=false
	bCollideActors=true
	bBlockActors=true
	bBlockSpectators=true
	bStatic=false
	bNoDelete=true
}
