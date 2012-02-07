/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVWeap_CicadaMissileLauncher extends UTVehicleWeapon
	HideDropDown;

/** current number of rockets loaded */
var int RocketsLoaded;

/** maximum number of rockets that can be loaded */
var(CicadaWeapon) int MaxRockets;

/** sound played when loading a rocket */
var SoundCue WeaponLoadSnd;

/** if bLocked, all missiles will home to this location */
var vector LockedTargetVect;

/** position vehicle was at when lock was acquired */
var vector LockPosition;

/** How fast should the rockets accelerate towards it's cross or away */
var(CicadaWeapon) float AccelRate;

/* How long between each shot when launching a load of rockets */
var(CicadaWeapon) float LoadedFireTime;

/** Sound Effect to play when Locking */
var SoundCue 			LockAcquiredSound;

/** used to maintain InstigatorController for rockets if you switch to the secondary seat while loading or firing */
var Controller RocketLoader;

var float AltCrosshairBounceInTime;
var float AltCrosshairBounceOutTime;

var int TargetRotYaw;

struct CHSlot
{
	var float u,v,ul,vl;
	var float xOfst,yOfst;
	var float gx,gy;
	var float FadeTime;
};

var CHSlot CrosshairSlots[16];

replication
{
	if (bNetOwner && Role == ROLE_Authority)
		LockedTargetVect;
}

// this weapon uses homing rockets so it can always hit where it's being aimed
simulated function bool IsAimCorrect()
{
	return true;
}
simulated function bool CanHitDesiredTarget(vector SocketLocation, rotator SocketRotation, vector DesiredAimPoint, Actor TargetActor, out vector RealAimPoint)
{
	return true;
}

simulated function int GetAmmoCount()
{
	return RocketsLoaded;
}

function vector FindInitialTarget(bool bAdjustUp, vector AdjustLoc)
{
	local vector HitLocation,HitNormal, End, Start;
	local rotator Dir;

	if (AIController(MyVehicle.Controller) != None)
	{
		return MyVehicle.Controller.GetFocalPoint();
	}
	else
	{
		if ( MyVehicle.Controller != None )
		{
			MyVehicle.Controller.GetPlayerViewPoint( Start, Dir );
		}
		else
		{
			MyVehicle.GetActorEyesViewPoint(Start, Dir);
		}
		if (bAdjustUp && (UTBot(Instigator.Controller) != None) && !FastTrace(LockedTargetVect, AdjustLoc))
		{
			Dir.Pitch = FastTrace(AdjustLoc + 3000.0 * vector(Dir), AdjustLoc) ? 12000 : 16000;
		}

		End = Start + WeaponRange * vector(Dir);
		return (Trace(HitLocation, HitNormal, End, Start, true) != None) ? HitLocation : End;
	}
}

simulated function CustomFire()
{
	// ProjectileFire() will handle switching the side the missile is spawned on
	ProjectileFire();
}

simulated function Projectile ProjectileFire()
{
	local UTProj_CicadaRocket P;
	local Vector Aim, AccelAdjustment, CrossVec;
	local float TargetDist, LockedDist;

	P = UTProj_CicadaRocket( Super.ProjectileFire() );
	if (P!=none)
	{
		// make sure that a player still gets kill credit for the rockets even if he/she switches to the turret while firing
		if (P.InstigatorController == None)
		{
			P.InstigatorController = RocketLoader;
		}

		// Set their initial velocity

		Aim = Vector( MyVehicle.GetWeaponAim(self) );

		CrossVec = Vect(0,0,1) * ( MyVehicle.GetBarrelIndex(SeatIndex) > 0 ? 1 : -1);
		CrossVec *= (CurrentFireMode > 0 ? 1 : -1);

		CrossVec = Normal(Aim Cross CrossVec);
		AccelAdjustment = 0.5 * CrossVec * AccelRate;

		if (CurrentFireMode == 1)
		{
		   	AccelAdjustment.Z += ( (400.0 * FRand()) - 100.0 ) * ( FRand() * 2.f);
		}
		P.Target = FindInitialTarget((CurrentFireMode == 1), P.Location);

		if (CurrentFireMode == 1)
		{
			TargetDist = VSize(P.Target - Location);
			LockedDist = VSize(LockedTargetVect - Location);
			if ( TargetDist > 0.75*LockedDist )
			{
				P.Target = Location + 0.75 * LockedDist * (P.Target - Location)/TargetDist;
			}
			P.bFinalTarget = false;
			P.SecondTarget = LockedTargetVect;
			P.SwitchTargetTime = 0.5;
		}
		else
		{
			P.DesiredDistanceToAxis = 64;
			P.bFinalTarget = true;
		}
		CrossVec *= (CurrentFireMode > 0 ? 1 : -1);
		P.ArmMissile(AccelAdjustment, 0.67 * (Vector(MyVehicle.Rotation) + 0.5*CrossVec) * (P.Speed + VSize(MyVehicle.Velocity)) );
	}
	return p;
}

function byte BestMode()
{
	if (Instigator.Controller == None || Instigator.Controller.Focus == None)
	{
		return 1;
	}
	if ( Pawn(Instigator.Controller.Focus) != None && !Pawn(Instigator.Controller.Focus).bStationary )
	{
		return 0;
	}

	return 1;
}

function FireLoadedRocket();


simulated state WeaponLoadAmmo
{
	// if we're locked on to a target the rockets should be able to hit it, so if Other is near the lock location, we can always attack it
	function bool CanAttack(Actor Other)
	{
		local float Radius, Height;

		Other.GetBoundingCylinder(Radius, Height);
		if (VSize(LockedTargetVect - Other.Location) < 100.f + Radius + Height)
		{
			return true;
		}
		return Global.CanAttack(Other);
	}

	simulated function bool TryPutdown()
	{
		bWeaponPutDown = true;
		return true;
	}

	/**
	 * Adds a rocket to the count and uses up some ammo.  In addition, it plays
	 * a sound so that other pawns in the world can hear it.
	 */
	simulated function LoadRocket()
	{
		if (RocketsLoaded < MaxRockets && HasAmmo(CurrentFireMode))
		{
			CrosshairSlots[RocketsLoaded].FadeTime = FireInterval[1];

			// Add the rocket
			RocketsLoaded++;
			ConsumeAmmo(CurrentFireMode);
			if (RocketsLoaded > 1)
			{
				MakeNoise(0.5);
				WeaponPlaySound(WeaponLoadSnd);
			}
		}
	}

	/**
	 * Fire off a shot w/ effects
	 */
	simulated function WeaponFireLoad()
	{
		if (RocketsLoaded > 0)
		{
			GotoState('WeaponFiringLoad');
		}
		else
		{
			GotoState('Active');
		}
	}

	/**
	 * This is the timer event for each shot
	 */
	simulated event RefireCheckTimer()
	{
		if (!StillFiring(1))
		{
			WeaponFireLoad();
		}
		else
		{
			LoadRocket();
		}
	}

	simulated function SendToFiringState(byte FireModeNum)
	{
	}

	simulated function BeginState(Name PreviousStateName)
	{
		RocketLoader = Instigator.Controller;
		RocketsLoaded = 0;

		if (Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
		{
			PlayerController(Instigator.Controller).ClientPlaySound(LockAcquiredSound);
		}
		else if ( (UTBot(Instigator.Controller) != None) && (Instigator == MyVehicle) && !UTBot(Instigator.Controller).bScriptedFrozen )
		{
			if (MyVehicle.Rise <= 0.f && FastTrace(Instigator.Location - vect(0,0,500), Instigator.Location))
			{
				MyVehicle.Rise = -0.5;
			}
			else
			{
				MyVehicle.Rise = 1.0;
			}
		}
		LockedTargetVect = FindInitialTarget(false, vect(0,0,0));

		Super.BeginState(PreviousStateName);
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('RefireCheckTimer');
		ClearTimer('FireLoadedRocket');
		Super.EndState(NextStateName);
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function GetCrosshairScaling(Hud HUD)
	{
		local float Perc;
		if ( AltCrosshairBounceInTime > 0)
		{
			Perc = AltCrosshairBounceInTime / default.AltCrosshairBounceInTime;

			if (Perc > 0.75)
			{
				CrossHairScaling = 1.0 + (1.0 - (Perc / 0.25));
			}
			else
			{
				CrossHairScaling = 1.0 + (1.0 * (Perc / 0.75));
			}
		}
		else
		{
			CrosshairScaling = 1.0;
		}

	}

	simulated function DrawBrackets(UTHudBase H, float CX, float CY)
	{
		local float X,Y;
		local Color TileColor;
		local float Perc;

       	Perc = 1.0 - (AltCrosshairBounceInTime / default.AltCrosshairBounceInTime);

		TileColor = H.WhiteColor;
		TileColor.A = 255 * Perc;

		Y = CY - 48 * H.ResolutionScale;
		X = 60 * H.ResolutionScale * Perc;
		H.DrawShadowedStretchedTile(CrosshairImage,CX-X-24*H.ResolutionScale,Y,24,96,305,256,24,64,TileColor,true);
		H.DrawShadowedStretchedTile(CrosshairImage,CX+X,Y,24,96,330,256,24,64,TileColor,true);
	    AltCrosshairBounceInTime = FMax(AltCrosshairBounceInTime - H.RenderDelta, 0.0);

	}

	simulated function DrawWeaponCrosshair( Hud HUD )
	{
		DrawLoadedCrosshair(Hud);
		Global.DrawWeaponCrosshair(Hud);
	}

	simulated function DrawTarget(UTHudBase H)
	{
		local Vector TV2D;
		local Rotator Rot;
		local float OldOrgX, OldOrgY, OldClipX, OldClipY;
		
		if ( ((LockedTargetVect - MyVehicle.Location) dot vector(H.PlayerOwner.Rotation)) < 0.f )
		{
			return;
		}
		
		// the cicada target icon is a special case that we want to ignore the safe region
		OldOrgX = H.Canvas.OrgX;
		OldOrgY = H.Canvas.OrgY;
		OldClipX = H.Canvas.ClipX;
		OldClipY = H.Canvas.ClipY;
		H.Canvas.OrgX = 0.0;
		H.Canvas.OrgY = 0.0;
		H.Canvas.ClipX = H.Canvas.SizeX;
		H.Canvas.ClipY = H.Canvas.SizeY;

		TargetRotYaw += 8192 * H.RenderDelta;
		TargetRotYaw = TargetRotYaw & 65535;

		Rot.Yaw = TargetRotYaw;

		TV2D = H.Canvas.Project(LockedTargetVect);

		// make sure not clipped out
		if (TV2D.X >= 0 &&
			TV2D.X < H.Canvas.ClipX &&
			TV2D.Y >= 0 &&
			TV2D.Y < H.Canvas.ClipY)
		{
			H.DrawShadowedRotatedTile(CrosshairImage,Rot,TV2D.X - 32 * H.ResolutionScale, TV2D.Y - 32 * H.ResolutionScale, 64,64, 384,256,64,64,H.GoldColor,true);
		}

		// restore the canvas parameters
		H.Canvas.OrgX = OldOrgX;
		H.Canvas.OrgY = OldOrgY;
		H.Canvas.ClipX = OldClipX;
		H.Canvas.ClipY = OldClipY;
	}


Begin:
	AltCrosshairBounceInTime = default.AltCrosshairBounceInTime;
	LoadRocket();
	TimeWeaponFiring(CurrentFireMode);
}

simulated state WeaponFiringLoad
{
	simulated function SendToFiringState(byte FireModeNum);

	simulated function FireLoadedRocket()
	{
		PlayFiringSound();
		ProjectileFire();
		RocketsLoaded--;
		if (RocketsLoaded <= 0)
		{
			if (RocketsLoaded < 0)
			{
				`Warn("Extra rockets fired! RocketsLoaded:" @ RocketsLoaded);
				// ScriptTrace();
			}

			GotoState('Active');
		}
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		ClearTimer('FireLoadedRocket');
		ClearFlashCount();
		ClearFlashLocation();
		ClearPendingFire(1);

		RocketsLoaded = 0;
		LockedTargetVect = vect(0,0,0);

	}

	simulated function TimeLoadedFiring()
	{
		SetTimer(LoadedFireTime,true,'FireLoadedRocket');
	}


	simulated function DrawBrackets(UTHudBase H, float CX, float CY)
	{
		local float X,Y;
		local Color TileColor;
		local float Perc;

		Perc = AltCrosshairBounceOutTime / default.AltCrosshairBounceOutTime;


		TileColor = H.WhiteColor;
		TileColor.A = 255 * Perc;

		Y = CY - 48 * H.ResolutionScale;
		X = 60 * H.ResolutionScale * Perc;
		H.DrawShadowedStretchedTile(CrosshairImage,CX-X-24*H.ResolutionScale,Y,24,96,305,256,24,64,TileColor,true);
		H.DrawShadowedStretchedTile(CrosshairImage,CX+X,Y,24,96,330,256,24,64,TileColor,true);
	    AltCrosshairBounceOutTime = FMax(AltCrosshairBounceOutTime - H.RenderDelta, 0.0);

	}

	simulated function DrawWeaponCrosshair( Hud HUD )
	{
		DrawLoadedCrosshair(Hud);
		Global.DrawWeaponCrosshair(Hud);
	}


Begin:
	AltCrosshairBounceOutTime = default.AltCrosshairBounceOutTime;
	FireLoadedRocket();
	TimeLoadedFiring();
}

simulated function DrawBrackets(UTHudBase H, float CX, float CY);
simulated function DrawTarget(UTHudBase H);

simulated function DrawLoadedCrosshair( Hud HUD )
{
	local float CX,CY, CenterSize, XAdj, Alpha, X, Y,U,V;
	local UTHudBase H;
	local int i;
	local Color Gray;

	H = UTHUDBase(Hud);

    CenterSize = 20.0*HUD.Canvas.ClipX/1024;

	CX = H.Canvas.ClipX * 0.5;
	CY = H.Canvas.ClipY * 0.5;

	DrawBrackets(H, CX,CY);

	XAdj= (CenterSize + 10 * H.ResolutionScale) * -1;

	Gray.R=128;
	Gray.G=128;
	Gray.B=128;
	Gray.A=255;

	for (i=0;i<16;i++)
	{
		X = CX + XAdj + CrossHairSlots[i].xOfst * H.ResolutionScale;
		Y = CY + CrossHairSlots[i].yOfst * H.ResolutionScale;
		if (i < RocketsLoaded)
		{
			if (CrossHairSlots[i].FadeTime > 0)
			{
				U = Abs(CrosshairSlots[i].UL) * H.ResolutionScale * 3.1;
				V = Abs(CrosshairSlots[i].VL) * H.ResolutionScale * 3.1;
				Alpha = CrossHairSlots[i].FadeTime / FireInterval[1];
				H.Canvas.SetPos(X+CrosshairSlots[i].gx * H.ResolutionScale - (U * 0.5), Y + CrossHairSlots[i].gy * H.ResolutionScale - (V*0.5));
				H.Canvas.DrawColor = H.WhiteColor;
				H.Canvas.DrawColor.A = 255 * Alpha;
				H.Canvas.DrawTile(CrosshairImage, U, V, 48,322, 25,24);
				CrossHairSlots[i].FadeTime -= H.RenderDelta;

			}

			H.Canvas.DrawColor = H.WhiteColor;
		}
		else
		{
			H.Canvas.DrawColor = Gray;
		}

		H.Canvas.SetPos(X, Y);
		H.Canvas.DrawTile(CrosshairImage, Abs(CrossHairSlots[i].UL * H.ResolutionScale), Abs(CrossHairSlots[i].VL * H.ResolutionScale),
					CrossHairSlots[i].U,CrossHairSlots[i].V,CrossHairSlots[i].UL,CrossHairSlots[i].VL);
		XAdj *= -1;
	}

	DrawTarget(H);
}




defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	WeaponProjectiles(0)=class'UTProj_CicadaRocket'
	WeaponProjectiles(1)=class'UTProj_CicadaRocket'

	WeaponFireSnd[0]=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Fire'
	WeaponFireSnd[1]=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileEject'

	LockAcquiredSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock'
	WeaponLoadSnd=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileLoad'

	FireInterval(0)=0.25
	FireInterval(1)=0.5
	FiringStatesArray(1)=WeaponLoadAmmo

	ShotCost(0)=0
	ShotCost(1)=0

	bFastRepeater=true
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	FireTriggerTags=(CicadaWeapon01,CicadaWeapon02)
	AltFireTriggerTags=(CicadaWeapon01,CicadaWeapon02)

	MaxRockets=16
	AccelRate=1500
	LoadedFireTime=0.1

	VehicleClass=class'UTVehicle_Cicada_Content'
	AltCrosshairBounceInTime=0.5
	AltCrosshairBounceOutTime=0.33

	CrosshairSlots(0)=(u=24,ul=12,v=322,vl=10,xofst=-24,yofst=-21,gx=7,gy=5)
	CrosshairSlots(1)=(u=36,ul=-12,v=322,vl=10,xofst=12,yofst=-21,gx=5,gy=5)

	CrosshairSlots(2)=(u=24,ul=9,v=332,vl=11,xofst=-24,yofst=-11,gx=4,gy=6)
	CrosshairSlots(3)=(u=33,ul=-9,v=332,vl=11,xofst=15,yofst=-11,gx=5,gy=6)

	CrosshairSlots(4)=(u=24,ul=9,v=343,vl=12,xofst=-24,yofst=0,gx=4,gy=6)
	CrosshairSlots(5)=(u=33,ul=-9,v=343,vl=12,xofst=15,yofst=0,gx=5,gy=6)

	CrosshairSlots(6)=(u=24,ul=12,v=355,vl=10,xofst=-24,yofst=12,gx=7,gy=5)
	CrosshairSlots(7)=(u=36,ul=-12,v=355,vl=10,xofst=12,yofst=12,gx=5,gy=5)


	CrosshairSlots(8)=(u=36,ul=12,v=322,vl=10,xofst=-12,yofst=-21,gx=6,gy=5)
	CrosshairSlots(9)=(u=48,ul=-12,v=322,vl=10,xofst=0,yofst=-21,gx=7,gy=5)

	CrosshairSlots(10)=(u=33,ul=10,v=332,vl=11,xofst=-14,yofst=-11,gx=5,gy=6)
	CrosshairSlots(11)=(u=43,ul=-10,v=332,vl=11,xofst=5,yofst=-11,gx=6,gy=6)

	CrosshairSlots(12)=(u=33,ul=10,v=343,vl=12,xofst=-14,yofst=0,gx=5,gy=6)
	CrosshairSlots(13)=(u=33,ul=-9,v=343,vl=12,xofst=5,yofst=0,gx=5,gy=6)

	CrosshairSlots(14)=(u=36,ul=12,v=355,vl=10,xofst=-12,yofst=12,gx=6,gy=6)
	CrosshairSlots(15)=(u=48,ul=-12,v=355,vl=10,xofst=0,yofst=12,gx=7,gy=6)
}
