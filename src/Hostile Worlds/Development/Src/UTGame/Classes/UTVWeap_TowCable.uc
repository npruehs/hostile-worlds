/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_TowCable extends UTVehicleWeapon
	hidedropdown;

/** A quick reference to the hoverboard that owns this gun */
var UTVehicle_Hoverboard 	MyHoverboard;

/** How far away from the hoverboard can a vehicle be to attach */
var float MaxAttachRange;

var float CrossScaler;
var float CrossScaleTime;

var Texture2D CrossHairTexture;

replication
{
	if (bNetDirty)
		MyHoverBoard;
}

/**
 * Cache a reference to the hoverboard
 */
simulated function PostBeginPlay()
{
	if ( Role == ROLE_Authority )
	{
		MyHoverboard = UTVehicle_Hoverboard(Instigator);
	}

	Super.PostBeginPlay();

	AimTraceRange = 0.0;
}

simulated function float MaxRange()
{
	// return driver weapon MaxRange() so AI knows when it needs to get off and start shooting
	if (MyHoverboard != None && MyHoverboard.Driver != None && MyHoverboard.Driver.Weapon != None)
	{
		return MyHoverboard.Driver.Weapon.MaxRange();
	}
	else
	{
		return MaxAttachRange;
	}
}

function byte BestMode()
{
	return 0;
}

simulated function EndFire(Byte FireModeNum)
{
	if(MyHoverboard != None && MyHoverboard.Role == ROLE_Authority)
	{
		if(FireModeNum == 0)
		{
			MyHoverboard.bGrab1 = FALSE;
		}
		else if(FireModeNum == 1)
		{
			MyHoverboard.bGrab2 = FALSE;
		}
	}
}

simulated function CustomFire()
{
}

simulated function BeginFire(Byte FireModeNum)
{
	if(MyHoverboard != None && MyHoverboard.Role == ROLE_Authority)
	{
		if(FireModeNum == 0)
		{
			MyHoverboard.bGrab1 = TRUE;
		}
		else if(FireModeNum == 1)
		{
			MyHoverboard.bGrab2 = TRUE;
		}
	}
}

simulated function DrawWeaponCrosshair( Hud HUD )
{
	return; // No crosshair for towcable.
}

simulated function ResetCrosshair(Canvas Canvas)
{
	CrossScaler = Canvas.ClipX / 56;
	CrossScaleTime = 0.33;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

	WeaponFireSnd[0]=none
	WeaponFireSnd[1]=none
	FireInterval(0)=+0.6
	ShotCost(0)=0
	ShotCost(1)=0

	bInstantHit=true

	// Let rider look anywhere
	MaxFinalAimAdjustment=-1.0

	MaxAttachRange=1700

	CrossHairTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'
}
