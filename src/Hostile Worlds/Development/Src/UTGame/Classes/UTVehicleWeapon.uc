/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleWeapon extends UTWeapon
	abstract
	dependson(UTVehicle);

/** Holds a link in to the Seats array in MyVehicle that represents this weapon */
var int SeatIndex;

/** Holds a link to the parent vehicle */
var RepNotify UTVehicle	MyVehicle;

/** Triggers that should be activated when a weapon fires */
var array<name>	FireTriggerTags, AltFireTriggerTags;

/** impact effects by material type */
var array<MaterialImpactEffect> ImpactEffects, AltImpactEffects;

/** default impact effect to use if a material specific one isn't found */
var MaterialImpactEffect DefaultImpactEffect, DefaultAltImpactEffect;

/** sound that is played when the bullets go whizzing past your head */
var SoundCue BulletWhip;

/** last time aim was correct, used for looking up GoodAimColor */
var float LastCorrectAimTime;

/** last time aim was incorrect, used for looking up GoodAimColor */
var float LastInCorrectAimTime;

var float CurrentCrosshairScaling;

/** This value is used to cap the maximum amount of "automatic" adjustment that will be made to a shot
    so that it will travel at the crosshair.  If the angle between the barrel aim and the player aim is
    less than this angle, it will be adjusted to fire at the crosshair.  The value is in radians */
var float MaxFinalAimAdjustment;

var bool bPlaySoundFromSocket;

/** used for client to tell server when zooming, as that is clientside
 * but on console it affects the controls so the server needs to know
 */
var bool bCurrentlyZoomed;

/**
 * If the weapon is attached to a socket that doesn't pitch with
 * player view, and should fire at the aimed pitch, then this should be enabled.
 */
var bool bIgnoreSocketPitchRotation;
/**
 * Same as above, but only allows for downward direction, for vehicles with 'bomber' like behavior.
 */
var bool bIgnoreDownwardPitch;

/** Vehicle class used for drawing kill icons */
var class<UTVehicle> VehicleClass;

/** for debugging turret aiming */
var bool bDebugTurret;

replication
{
	if (bNetInitial && bNetOwner)
		SeatIndex, MyVehicle;
}

/** checks if the weapon is actually capable of hitting the desired target, including trace test (used by crosshair)
 * if false because trace failed, RealAimPoint is set to what the trace hit
 */
simulated function bool CanHitDesiredTarget(vector SocketLocation, rotator SocketRotation, vector DesiredAimPoint, Actor TargetActor, out vector RealAimPoint)
{
	local int i;
	local array<Actor> IgnoredActors;
	local Actor HitActor;
	local vector HitLocation, HitNormal;
	local bool bResult;

	if ((Normal(DesiredAimPoint - SocketLocation) dot Normal(RealAimPoint - SocketLocation)) >= GetMaxFinalAimAdjustment())
	{
		// turn off bProjTarget on Actors we should ignore for the aiming trace
		for (i = 0; i < AimingTraceIgnoredActors.length; i++)
		{
			if (AimingTraceIgnoredActors[i] != None && AimingTraceIgnoredActors[i].bProjTarget)
			{
				AimingTraceIgnoredActors[i].bProjTarget = false;
				IgnoredActors[IgnoredActors.length] = AimingTraceIgnoredActors[i];
			}
		}
		// perform the trace
		HitActor = GetTraceOwner().Trace(HitLocation, HitNormal, DesiredAimPoint, SocketLocation, true,,, TRACEFLAG_Bullet);
		if (HitActor == None || HitActor == TargetActor)
		{
			bResult = true;
		}
		else
		{
			RealAimPoint = HitLocation;
		}
		// restore bProjTarget on Actors we turned it off for
		for (i = 0; i < IgnoredActors.length; i++)
		{
			IgnoredActors[i].bProjTarget = true;
		}
	}

	return bResult;
}


simulated static function DrawKillIcon(Canvas Canvas, float ScreenX, float ScreenY, float HUDScaleX, float HUDScaleY)
{
	if ( default.VehicleClass != None )
	{
		default.VehicleClass.static.DrawKillIcon(Canvas, ScreenX, ScreenY, HUDScaleX, HUDScaleY);
	}
}

simulated function GetCrosshairScaling(Hud HUD)
{
	if ( LastCorrectAimTime > LastInCorrectAimTime )
	{
		CrosshairScaling = FMax(CurrentCrosshairScaling - 0.6*(WorldInfo.TimeSeconds - LastInCorrectAimTime), 1.0);
	}
	else
	{
		CrosshairScaling = FMin(CurrentCrosshairScaling + 0.6*(WorldInfo.TimeSeconds - LastCorrectAimTime), 2.0);
	}
}
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local vector SocketLocation, DesiredAimPoint, RealAimPoint;
	local rotator SocketRotation;
	local Actor TargetActor;
	local bool bAimIsCorrect;
	local float CenterSize;
	local UTPlayerController PC;

	PC = UTPlayerController(Instigator.Controller);
	if ( (PC != None) && PC.bSimpleCrosshair )
	{
		super.DrawWeaponCrosshair(HUD);
		return;
	}
	DesiredAimPoint = GetDesiredAimPoint(TargetActor);
	GetFireStartLocationAndRotation(SocketLocation, SocketRotation);
	RealAimPoint = SocketLocation + Vector(SocketRotation) * GetTraceRange();
	bAimIsCorrect = CanHitDesiredTarget(SocketLocation, SocketRotation, DesiredAimPoint, TargetActor, RealAimPoint);

	GetCrosshairScaling(Hud);
	CurrentCrosshairScaling = CrosshairScaling;

	CrosshairColor.A = 255.0 - 127.0 * (CrosshairScaling - 1.0);
	Super.DrawWeaponCrosshair(HUD);

	if (bAimIsCorrect)
	{
		// if recently aim became correct, show center part of crosshair
		CenterSize = UTHUDBase(HUD).ConfiguredCrosshairScaling * 24.0*HUD.Canvas.ClipX/1280;
		Hud.Canvas.SetPos(0.5*(HUD.Canvas.ClipX - CenterSize), 0.5*(HUD.Canvas.ClipY - CenterSize));
		Hud.Canvas.DrawTile(Texture2D'UI_HUD.HUD.UTCrossHairs', CenterSize, CenterSize, 380, 320, 26, 26);
		LastCorrectAimTime = WorldInfo.TimeSeconds;
	}
	else
	{
		LastInCorrectAimTime = WorldInfo.TimeSeconds;
		// show debug actual aim position of turret
		if ( bDebugTurret )
		{
			RealAimPoint = Hud.Canvas.Project(RealAimPoint);
			if (RealAimPoint.X < 12 || RealAimPoint.X > Hud.Canvas.ClipX-12)
			{
				RealAimPoint.X = Clamp(RealAimPoint.X,12,Hud.Canvas.ClipX-12);
			}
			if (RealAimPoint.Y < 12 || RealAimPoint.Y > Hud.Canvas.ClipY-12)
			{
				RealAimPoint.Y = Clamp(RealAimPoint.Y,12,Hud.Canvas.ClipY-12);
			}
			Hud.Canvas.SetPos(RealAimPoint.X - 10.0, RealAimPoint.Y - 10.0);
			CenterSize = UTHUDBase(HUD).ConfiguredCrosshairScaling * 25.0*HUD.Canvas.ClipX/1280;
			Hud.Canvas.DrawTile(Texture2D'UI_HUD.HUD.UTCrossHairs', CenterSize, CenterSize, 380, 320, 26, 26);
		}
	}
}

/** GetDesiredAimPoint - Returns the desired aim given the current controller
 * @param TargetActor (out) - if specified, set to the actor being aimed at
 * @return The location the controller is aiming at
 */
simulated event vector GetDesiredAimPoint(optional out Actor TargetActor)
{
	local vector CameraLocation, HitLocation, HitNormal, DesiredAimPoint;
	local rotator CameraRotation;
	local Controller C;
	local PlayerController PC;

	C = (MyVehicle != None) ? MyVehicle.Seats[SeatIndex].SeatPawn.Controller : None;

	PC = PlayerController(C);
	if (PC != None)
	{
		PC.GetPlayerViewPoint(CameraLocation, CameraRotation);
		DesiredAimPoint = CameraLocation + Vector(CameraRotation) * GetTraceRange();
		TargetActor = GetTraceOwner().Trace(HitLocation, HitNormal, DesiredAimPoint, CameraLocation);
		if (TargetActor != None)
		{
			DesiredAimPoint = HitLocation;
		}
	}
	else if ( C != None )
	{
		DesiredAimPoint = C.GetFocalPoint();
		TargetActor = C.Focus;
	}
	return DesiredAimPoint;
}

/** returns the location and rotation that the weapon's fire starts at */
simulated function GetFireStartLocationAndRotation(out vector StartLocation, out rotator StartRotation)
{
	if ( MyVehicle == None )
	{
		return;
	}
	if ( MyVehicle.Seats[SeatIndex].GunSocket.Length>0 )
	{
		MyVehicle.GetBarrelLocationAndRotation(SeatIndex, StartLocation, StartRotation);
	}
	else
	{
		StartLocation = MyVehicle.Location;
		StartRotation = MyVehicle.Rotation;
	}
}

/**
 * IsAimCorrect - Returns true if the turret associated with a given seat is aiming correctly
 *
 * @return TRUE if we can hit where the controller is aiming
 */
simulated event bool IsAimCorrect()
{
	local vector SocketLocation, DesiredAimPoint, RealAimPoint;
	local rotator SocketRotation;

	DesiredAimPoint = GetDesiredAimPoint();

	GetFireStartLocationAndRotation(SocketLocation, SocketRotation);

	RealAimPoint = SocketLocation + Vector(SocketRotation) * GetTraceRange();
	return ((Normal(DesiredAimPoint - SocketLocation) dot Normal(RealAimPoint - SocketLocation)) >= GetMaxFinalAimAdjustment());
}


simulated static function Name GetFireTriggerTag(int BarrelIndex, int FireMode)
{
	if (FireMode==0)
	{
		if (default.FireTriggerTags.Length > BarrelIndex)
		{
			return default.FireTriggerTags[BarrelIndex];
		}
	}
	else
	{
		if (default.AltFireTriggerTags.Length > BarrelIndex)
		{
			return default.AltFireTriggerTags[BarrelIndex];
		}
	}
	return '';
}

/**
 * Returns interval in seconds between each shot, for the firing state of FireModeNum firing mode.
 *
 * @param	FireModeNum	fire mode
 * @return	Period in seconds of firing mode
 */
simulated function float GetFireInterval( byte FireModeNum )
{
	local UTPawn UTP;

	if (Vehicle(Owner) != None)
	{
		UTP = UTPawn(Vehicle(Owner).Driver);
		if (UTP != None)
		{
			return (FireInterval[FireModeNum] * UTP.FireRateMultiplier);
		}
	}

	return Super.GetFireInterval(FireModeNum);
}

/** returns the impact effect that should be used for hits on the given actor and physical material */
simulated static function MaterialImpactEffect GetImpactEffect(Actor HitActor, PhysicalMaterial HitMaterial, byte FireModeNum)
{
	local int i;
	local UTPhysicalMaterialProperty PhysicalProperty;

	if (HitMaterial != None)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
	}
	if (FireModeNum > 0)
	{
		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
		{
			i = default.AltImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
			if (i != -1)
			{
				return default.AltImpactEffects[i];
			}

		}
		return default.DefaultAltImpactEffect;
	}
	else
	{
		if (PhysicalProperty != None && PhysicalProperty.MaterialType != 'None')
		{
			i = default.ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
			if (i != -1)
			{
				return default.ImpactEffects[i];
			}
		}
		return default.DefaultImpactEffect;
	}
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName );
simulated function DetachWeapon();

simulated function Activate()
{
	// don't reactivate if already firing
	if (!IsFiring())
	{
		GotoState('Active');
	}
}

simulated function PutDownWeapon()
{
	GotoState('Inactive');
}

simulated function Vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	if ( MyVehicle != none )
		return MyVehicle.GetPhysicalFireStartLoc(self);
	else
		return Location;
}

simulated function BeginFire(byte FireModeNum)
{
	local UTVehicle V;

	// allow the vehicle to override the call
	V = UTVehicle(Instigator);
	if (V == None || (!V.bIsDisabled && !V.OverrideBeginFire(FireModeNum)))
	{
		Super.BeginFire(FireModeNum);
	}
}

simulated function EndFire(byte FireModeNum)
{
	local UTVehicle V;

	// allow the vehicle to override the call
	V = UTVehicle(Instigator);
	if (V == None || !V.OverrideEndFire(FireModeNum))
	{
		Super.EndFire(FireModeNum);
	}
}

simulated function Rotator GetAdjustedAim( vector StartFireLoc )
{
	// Start the chain, see Pawn.GetAdjustedAimFor()
	// @note we don't add in spread here because UTVehicle::GetWeaponAim() assumes
	// that a return value of Instigator.Rotation or Instigator.Controller.Rotation means 'no adjustment', which spread interferes with
	return Instigator.GetAdjustedAimFor( Self, StartFireLoc );
}

/**
 * Create the projectile, but also increment the flash count for remote client effects.
 */
simulated function Projectile ProjectileFire()
{
	local Projectile SpawnedProjectile;

	IncrementFlashCount();

	if (Role==ROLE_Authority)
	{
		SpawnedProjectile = Spawn(GetProjectileClass(),,, MyVehicle.GetPhysicalFireStartLoc(self));

		if ( SpawnedProjectile != None )
		{
			SpawnedProjectile.Init( vector(AddSpread(MyVehicle.GetWeaponAim(self))) );
		}
	}
	return SpawnedProjectile;
}

/**
* Overriden to use vehicle starttrace/endtrace locations
* @returns position of trace start for instantfire()
*/
simulated function vector InstantFireStartTrace()
{
	return (MyVehicle != None) ? MyVehicle.GetPhysicalFireStartLoc(self) : vect(0,0,0);
}

/**
* @returns end trace position for instantfire()
*/
simulated function vector InstantFireEndTrace(vector StartTrace)
{
	if  (MyVehicle == None )
	{
		return StartTrace;
	}
	return StartTrace + vector(AddSpread(MyVehicle.GetWeaponAim(self))) * GetTraceRange();;
}

simulated function Actor GetTraceOwner()
{
	return (MyVehicle != None) ? MyVehicle : Super.GetTraceOwner();
}

simulated function float GetMaxFinalAimAdjustment()
{
	return MaxFinalAimAdjustment;
}

/** notification that MyVehicle has been deployed/undeployed, since that often changes how its weapon works */
simulated function NotifyVehicleDeployed();
simulated function NotifyVehicleUndeployed();

simulated function WeaponPlaySound( SoundCue Sound, optional float NoiseLoudness )
{
	local int Barrel;
	local name Pivot;
	local vector Loc;
	local rotator Rot;
	if(bPlaySoundFromSocket && MyVehicle != none && MyVehicle.Mesh != none)
	{
		if( Sound == None || Instigator == None )
		{
			return;
		}
		Barrel = MyVehicle.GetBarrelIndex(SeatIndex);
		Pivot = MyVehicle.Seats[SeatIndex].GunSocket[Barrel];
		MyVehicle.Mesh.GetSocketWorldLocationAndRotation(Pivot, Loc, Rot);
		Instigator.PlaySound(Sound, false, true,false,Loc);
	}
	else
		super.WeaponPlaySound(Sound,NoiseLoudness);
}

simulated function EZoomState GetZoomedState()
{
	// override on server to use what the client told us
	if (Role == ROLE_Authority && Instigator != None && !Instigator.IsLocallyControlled())
	{
		return bCurrentlyZoomed ? ZST_Zoomed : ZST_NotZoomed;
	}
	else
	{
		return Super.GetZoomedState();
	}
}

reliable server function ServerSetZoom(bool bNowZoomed)
{
	bCurrentlyZoomed = bNowZoomed;
}

simulated function StartZoom(UTPlayerController PC)
{
	Super.StartZoom(PC);

	ServerSetZoom(true);
}

simulated function EndZoom(UTPlayerController PC)
{
	Super.EndZoom(PC);

	ServerSetZoom(false);
}

defaultproperties
{
	TickGroup=TG_PostAsyncWork
	InventoryGroup=100
	GroupWeight=0.5
	bExportMenuData=false

	ShotCost[0]=0
	ShotCost[1]=0

	// ~ 5 Degrees
	MaxFinalAimAdjustment=0.995;

	CrossHairCoordinates=(U=320,V=320,UL=60,VL=56)
	AimError=600
}
