/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeapon extends UDKWeapon
	dependson(UTPlayerController)
	config(Weapon)
	abstract;

/** if set, when this class is compiled, a menu entry for it will be automatically added/updated in its package.ini file
 * (abstract classes are skipped even if this flag is set)
 */
var bool bExportMenuData;

/*********************************************************************************************
 Ammo / Pickups / Inventory
********************************************************************************************* */

var class<UTAmmoPickupFactory> AmmoPickupClass;

/** Initial ammo count if in weapon locker */
var int LockerAmmoCount;

/** Max ammo count */
var int MaxAmmoCount;

/** Holds the amount of ammo used for a given shot */
var array<int> ShotCost;

/** Holds the min. amount of reload time that has to pass before you can switch */
var array<float> MinReloadPct;

/** camera anim to play when firing (for camera shakes) */
var array<CameraAnim> FireCameraAnim;

/** controller rumble to play when firing. */
var ForceFeedbackWaveform WeaponFireWaveForm;

var array<name> EffectSockets;

var int IconX, IconY, IconWidth, IconHeight;

/** used when aborting a weapon switch (WeaponAbortEquip and WeaponAbortPutDown) */
var float SwitchAbortTime;

/*********************************************************************************************
 Crosshair
********************************************************************************************* */

var UIRoot.TextureCoordinates IconCoordinates;
var UIRoot.TextureCoordinates CrossHairCoordinates;
var UIRoot.TextureCoordinates SimpleCrossHairCoordinates;

/** Holds the image to use for the crosshair. */
var Texture2D CrosshairImage;

/** Holds the image to use for the crosshair. */
var UIRoot.TextureCoordinates LockedCrossHairCoordinates;

/** Locked indicator current scale */
var float CurrentLockedScale;

/** Locked indicator start scale */
var float StartLockedScale;

/** Locked indicator final scale */
var float FinalLockedScale;

/** Locked indicator scale time */
var float LockedScaleTime;

/** Lock start time */
var float LockedStartTime;

var bool bWasLocked;

/** Used to decide whether to red color crosshair */
var float LastHitEnemyTime;

/** color to use when drawing the crosshair */
var config color CrosshairColor;

var float CrosshairScaling;

var config bool bUseCustomCoordinates;

var config UIRoot.TextureCoordinates CustomCrosshairCoordinates;

/*********************************************************************************************
 Misc
********************************************************************************************* */

/** If true, use smaller 1st person weapons */
var globalconfig databinding bool bSmallWeapons;

/** offset for dropped pickup mesh */
var float DroppedPickupOffsetZ;

/*********************************************************************************************
 Zooming
********************************************************************************************* */

/** If set to non-zero, this fire mode will zoom the weapon. */
var array<byte>	bZoomedFireMode;

/** Are we zoomed */
enum EZoomState
{
	ZST_NotZoomed,
	ZST_ZoomingOut,
	ZST_ZoomingIn,
	ZST_Zoomed,
};

/** Holds the fire mode num of the zoom */
var byte 	ZoomedFireModeNum;

var float	ZoomedTargetFOV;

var float	ZoomedRate;

var float 	ZoomFadeTime;

/** Sounds to play when zooming begins/ends/etc. */
var SoundCue ZoomInSound, ZoomOutSound;

/*********************************************************************************************
 Attachments
********************************************************************************************* */

/** The class of the attachment to spawn */
var class<UTWeaponAttachment> 	AttachmentClass;

/** If true, this weapon is a super weapon.  Super Weapons have longer respawn times a different
    pickup base and never respect weaponstay */
var bool bSuperWeapon;

/** Adjust pivot of rotating pickup */
var vector	PivotTranslation;

/*********************************************************************************************
 Inventory Grouping/etc.
********************************************************************************************* */

/** The weapon/inventory set, 0-9. */
var byte InventoryGroup;

/** position within inventory group. (used by prevweapon and nextweapon) */
var float GroupWeight;

/** The final inventory weight.  It's calculated in PostBeginPlay() */
var float InventoryWeight;

/** If true, this will will never accept a forwarded pending fire */
var bool bNeverForwardPendingFire;

/*********************************************************************************************
 Animations and Sounds
********************************************************************************************* */

var bool bSuppressSounds;

/** Animation to play when the weapon is fired */
var(Animations)	array<name>	WeaponFireAnim;
var(Animations) array<name> ArmFireAnim;
var(Animations) AnimSet ArmsAnimSet;
/** Animation to play when the weapon is Put Down */
var(Animations) name	WeaponPutDownAnim;
var(Animations) name	ArmsPutDownAnim;
/** Animation to play when the weapon is Equipped */
var(Animations) name	WeaponEquipAnim;
var(Animations) name	ArmsEquipAnim;

var(Animations) array<name> WeaponIdleAnims;
var(Animations) array<name> ArmIdleAnims;

var(Animations) bool bUsesOffhand;
/** Sound to play when the weapon is fired */
var(Sounds)	array<SoundCue>	WeaponFireSnd;

/** Sound to play when the weapon is Put Down */
var(Sounds) SoundCue 	WeaponPutDownSnd;

/** Sound to play when the weapon is Equipped */
var(Sounds) SoundCue 	WeaponEquipSnd;

/*********************************************************************************************
 First person weapon view positioning and rendering
********************************************************************************************* */

/** How much to damp view bob */
var() float	BobDamping;

/** How much to damp jump and land bob */
var() float	JumpDamping;

/** Limit for pitch lead */
var		float MaxPitchLag;

/** Limit for yaw lead */
var		float MaxYawLag;

/** Last Rotation update time for this weapon */
var		float LastRotUpdate;

/** Last Rotation update for this weapon */
var		Rotator LastRotation;

/** How far weapon was leading last tick */
var float OldLeadMag[2];

/** rotation magnitude last tick */
var int OldRotDiff[2];

/** max lead amount last tick */
var float OldMaxDiff[2];

/** Scaling faster for leading speed */
var float RotChgSpeed;

/** Scaling faster for returning speed */
var float ReturnChgSpeed;

/** If true, will be un-hidden on the next setPosition call. */
var bool bPendingShow;

/*********************************************************************************************
 Misc
********************************************************************************************* */

/** The Color used when drawing the Weapon's Name on the Hud */
var color WeaponColor;

/** Percent (from right edge) of screen space taken by weapon on x axis. */
var float WeaponCanvasXPct;

/** Percent (from bottom edge) of screen space taken by weapon on y axis. */
var float WeaponCanvasYPct;

/*********************************************************************************************
 Muzzle Flash
********************************************************************************************* */

/** Holds the name of the socket to attach a muzzle flash too */
var name					MuzzleFlashSocket;

/** Muzzle flash PSC and Templates*/
var UTParticleSystemComponent	MuzzleFlashPSC;

/** If true, always show the muzzle flash even when the weapon is hidden. */
var bool					bShowAltMuzzlePSCWhenWeaponHidden;

/** Normal Fire and Alt Fire Templates */
var ParticleSystem			MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;

/** UTWeapon looks to set the color via a color parameter in the emitter */
var color					MuzzleFlashColor;

/** Set this to true if you want the flash to loop (for a rapid fire weapon like a minigun) */
var bool					bMuzzleFlashPSCLoops;

/** dynamic light */
var	UDKExplosionLight		MuzzleFlashLight;

/** dynamic light class */
var class<UDKExplosionLight> MuzzleFlashLightClass;

/** How long the Muzzle Flash should be there */
var() float					MuzzleFlashDuration;

/** Whether muzzleflash has been initialized */
var bool					bMuzzleFlashAttached;

/** Offset from view center */
var(FirstPerson) vector	PlayerViewOffset;

/** additional offset applied when using small weapons */
var(FirstPerson) vector SmallWeaponsOffset;

/** additional offset applied when using small weapons */
var(FirstPerson) float WideScreenOffsetScaling;

/** rotational offset only applied when in widescreen */
var rotator WidescreenRotationOffset;

/** special offset when using hidden weapons, as we need to still place the weapon for e.g. attached beams */
var vector HiddenWeaponsOffset;

var float ProjectileSpawnOffset;

/*********************************************************************************************
 Weapon locker
********************************************************************************************* */
var rotator LockerRotation;
var vector LockerOffset;

/*********************************************************************************************
 * AI Hints
 ********************************************************************************************* */

var		bool	bSplashJump;
var		bool	bRecommendSplashDamage;
var 	bool	bSniping;

/** Whether bots should consider this a spray/fast firing weapon */
var		bool	bFastRepeater;
/** set for weapons that lock weapon rotation while firing, so bots know to retarget after each shot when shooting moving targets */
var		bool	bLockedAimWhileFiring;

/** Most recently calculated rating */
var		float	CurrentRating;

/** How much error to add to each shot */
var float AimError;

var ObjectiveAnnouncementInfo NeedToPickUpAnnouncement;

/** Distance from target collision box to accept near miss when aiming help is enabled */
var float AimingHelpRadius[2];

/** Set for ProcessInstantHit based on whether aiminghelp was used for this shot */
var bool bUsingAimingHelp;

/** whether to allow this weapon to fire by uncontrolled pawns */
var bool bAllowFiringWithoutController;

enum AmmoWidgetDisplayStyle
{
	EAWDS_Numeric,
	EAWDS_BarGraph,
	EAWDS_Both,
	EAWDS_None,
};

var AmmoWidgetDisplayStyle AmmoDisplayType;

//// start of adhesion friction vars

/** When the weapon is zoomed in then the turn speed is reduced by this much **/
var() config float ZoomedTurnSpeedScalePct;

/** Target friction enabled? */
var() config bool bTargetFrictionEnabled;

/** Min distance for friction */
var() config float TargetFrictionDistanceMin;

/** Peak distance for friction */
var() config float TargetFrictionDistancePeak;

/** Max distance allow for friction */
var() config float TargetFrictionDistanceMax;

/** Interp curve that allows for piece wise functions for the TargetFrictionDistance amount at different ranges **/
var() config InterpCurveFloat TargetFrictionDistanceCurve;

/** Min/Max friction multiplier applied when target acquired */
var() config Vector2d TargetFrictionMultiplierRange;

/** Amount of additional radius/height given to target cylinder when at peak distance */
var() config float TargetFrictionPeakRadiusScale;
var() config float TargetFrictionPeakHeightScale;

/** Offset to apply to friction target location (aim for the chest, etc) */
var() config vector TargetFrictionOffset;

/** Boost the Target Friction by this much when zoomed in **/
var() config float TargetFrictionZoomedBoostValue;

var() config bool bTargetAdhesionEnabled;

/** Max time to attempt adhesion to the friction target */
var() config float TargetAdhesionTimeMax;

/** Max distance to allow adhesion to still kick in */
var() config float TargetAdhesionDistanceMax;

/** Max distance from edge of cylinder for adhesion to be valid */
var() config float TargetAdhesionAimDistY;
var() config float TargetAdhesionAimDistZ;

/** Min/Max amount to scale for adhesive purposes */
var() config Vector2d TargetAdhesionScaleRange;

/** Min amount to scale for adhesive purposes */
var() config float TargetAdhesionScaleAmountMin;

/** Require the target to be moving for adhesion to kick in? */
var() config float TargetAdhesionTargetVelocityMin;

/** Require the player to be moving for adhesion to kick in? */
var() config float TargetAdhesionPlayerVelocityMin;

/** Boost the Target Adhesion by this much when zoomed in **/
var() config float TargetAdhesionZoomedBoostValue;

//// end of adhesion friction vars

var bool bForceHidden;

var bool bHasLocationSpeech;

var Array<SoundNodeWave> LocationSpeech;

/*********************************************************************************************
 * Hint strings
 ********************************************************************************************* */
var localized string UseHintString;

reliable server function ServerStartFire(byte FireModeNum)
{
	// don't allow firing if no controller (generally, because player entered/exited a vehicle while simultaneously pressing fire)
	if (Instigator == None || Instigator.Controller != None || bAllowFiringWithoutController)
	{
		Super.ServerStartFire(FireModeNum);
	}
}

/*********************************************************************************************
 * Initialization / System Messages / Utility
 *********************************************************************************************/

/**
 * Initialize the weapon
 */
simulated function PostBeginPlay()
{
	local UTGameReplicationInfo GRI;

	Super.PostBeginPlay();

	CalcInventoryWeight();

	// tweak firing/reload/putdown/bringup rate if on console
	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if (GRI != None && GRI.bConsoleServer)
	{
		AdjustWeaponTimingForConsole();
	}

	if ( Mesh != None )
	{
		Mesh.CastShadow = class'UTPlayerController'.default.bFirstPersonWeaponsSelfShadow;
	}

	bConsiderProjectileAcceleration = bConsiderProjectileAcceleration
										&& (((WeaponProjectiles[0] != None) && (class<UTProjectile>(WeaponProjectiles[0]).Default.AccelRate > 0))
											|| ((WeaponProjectiles[1] != None) && (class<UTProjectile>(WeaponProjectiles[1]).Default.AccelRate > 0)) );

	// make sure small weapons matches config
	// this is needed because if the UI modifies UTWeapon's defaults at runtime, it won't propagate to the child classes
	bSmallWeapons = class'UTWeapon'.default.bSmallWeapons;

	if ( bUseCustomCoordinates )
	{
		SimpleCrosshairCoordinates = CustomCrosshairCoordinates;
	}
}

/**
  * Adjust weapon equip and fire timings so they match between PC and console
  * This is important so the sounds match up.
  */
simulated function AdjustWeaponTimingForConsole()
{
	local int i;

	For ( i=0; i<FireInterval.Length; i++ )
	{
		FireInterval[i] = FireInterval[i]/1.1;
	}
	EquipTime = EquipTime/1.1;
	PutDownTime = PutDownTime/1.1;
}

simulated function CreateOverlayMesh()
{
	local SkeletalMeshComponent SKM_Source, SKM_Target;
	local StaticMeshComponent STM;
	local UTPawn P;

	if (OverlayMesh == None && WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
	{
		if ( WorldInfo.NetMode != NM_Client )
		{
			P = UTPawn(Instigator);
			if ( (P == None) || !P.bUpdateEyeHeight )
			{
				return;
			}
		}

		OverlayMesh = new(outer) Mesh.Class;
		if (OverlayMesh != None)
		{
			OverlayMesh.SetScale(1.00);
			OverlayMesh.SetOwnerNoSee(Mesh.bOwnerNoSee);
			OverlayMesh.SetOnlyOwnerSee(true);
			OverlayMesh.SetDepthPriorityGroup(SDPG_Foreground);
			OverlayMesh.CastShadow = false;

			SKM_Target = SkeletalMeshComponent(OverlayMesh);
			if ( SKM_Target != none )
			{
				SKM_Source = SkeletalMeshComponent(Mesh);

				SKM_Target.SetSkeletalMesh(SKM_Source.SkeletalMesh);
				SKM_Target.AnimSets = SKM_Source.AnimSets;
				SKM_Target.SetParentAnimComponent(SKM_Source);
				SKM_Target.bUpdateSkelWhenNotRendered = false;
				SKM_Target.bIgnoreControllersWhenNotRendered = true;

				if (UDKSkeletalMeshComponent(SKM_Target) != none)
				{
					UDKSkeletalMeshComponent(SKM_Target).SetFOV(UDKSkeletalMeshComponent(SKM_Source).FOV);
				}
			}
			else if ( StaticMeshComponent(OverlayMesh) != none )
			{
				STM = StaticMeshComponent(OverlayMesh);
				STM.SetStaticMesh(StaticMeshComponent(Mesh).StaticMesh);
				STM.SetScale3D(Mesh.Scale3D);
				STM.SetTranslation(Mesh.Translation);
				STM.SetRotation(Mesh.Rotation);
			}
			OverlayMesh.SetHidden(Mesh.HiddenGame);
		}
		else
		{
			`Warn("Could not create Weapon Overlay mesh for" @ self @ Mesh);
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'AmmoCount' )
	{
		if ( !HasAnyAmmo() )
		{
			WeaponEmpty();
		}
	}
	else if ( VarName == 'HitEnemy' )
	{
		LastHitEnemyTime = WorldInfo.TimeSeconds;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/**
 * Each Weapon needs to have a unique InventoryWeight in order for weapon switching to
 * work correctly.  This function calculates that weight using the various inventory values
 */
simulated function CalcInventoryWeight()
{
	InventoryWeight = ((InventoryGroup+1) * 1000) + (GroupWeight * 100);
	if ( Priority < 0 )
	{
		Priority = InventoryWeight;
	}
}

/**
 * returns true if this weapon is currently lower priority than InWeapon
 * used to determine whether to switch to InWeapon
 * this is the server check, so don't check clientside settings (like weapon priority) here
 */
simulated function bool ShouldSwitchTo(UTWeapon InWeapon)
{
	// if we should, but can't right now, tell InventoryManager to try again later
	if (IsFiring() || DenyClientWeaponSet())
	{
		UTInventoryManager(InvManager).RetrySwitchTo(InWeapon);
		return false;
	}
	else
	{
		return true;
	}
}

/**
 * Material control
 *
 * @Param 	NewMaterial		The new material to apply or none to clear it
 */
simulated function SetSkin(Material NewMaterial)
{
	local int i,Cnt;

	if ( NewMaterial == None )
	{
		// Clear the materials
		if ( default.Mesh.Materials.Length > 0 )
		{
			Cnt = Default.Mesh.Materials.Length;
			for (i=0;i<Cnt;i++)
			{
				Mesh.SetMaterial( i, Default.Mesh.GetMaterial(i) );
			}
		}
		else if (Mesh.Materials.Length > 0)
		{
			Cnt = Mesh.Materials.Length;
			for ( i=0; i < Cnt; i++ )
			{
				Mesh.SetMaterial(i, none);
			}
		}
	}
	else
	{
		// Set new material
		if ( default.Mesh.Materials.Length > 0 || Mesh.GetNumElements() > 0 )
		{
			Cnt = default.Mesh.Materials.Length > 0 ? default.Mesh.Materials.Length : Mesh.GetNumElements();
			for ( i=0; i < Cnt; i++ )
			{
				Mesh.SetMaterial(i, NewMaterial);
			}
		}
	}
}

/*********************************************************************************************
 * Hud/Crosshairs
 *********************************************************************************************/

/**
 * Access to HUD and Canvas.
 * Event always called when the InventoryManager considers this Inventory Item currently "Active"
 * (for example active weapon)
 *
 * @param	HUD			- HUD with canvas to draw on
 */
simulated function ActiveRenderOverlays( HUD H )
{
	local UTPlayerController PC;

	PC = UTPlayerController(Instigator.Controller);
	if ( (PC != None) && !PC.bNoCrosshair )
	{
		CrossHairCoordinates = PC.bSimpleCrosshair ? SimpleCrosshairCoordinates : default.CrosshairCoordinates;
		DrawWeaponCrosshair( H );
	}
}

/**
 * Draw the Crosshairs
 */
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y,PickupScale, ScreenX, ScreenY;
	local UTHUDBase	H;
	
	local float TargetDist;

	H = UTHUDBase(HUD);
	if ( H == None )
		return;

	TargetDist = GetTargetDistance();

	// Apply pickup scaling
	if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.3 )
	{
		if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.15 )
		{
			PickupScale = (1 + 5 * (WorldInfo.TimeSeconds - H.LastPickupTime));
		}
		else
		{
			PickupScale = (1 + 5 * (H.LastPickupTime + 0.3 - WorldInfo.TimeSeconds));
		}
	}
	else
	{
		PickupScale = 1.0;
	}

 	CrosshairSize.Y = H.ConfiguredCrosshairScaling * CrosshairScaling * CrossHairCoordinates.VL * PickupScale * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( CrossHairCoordinates.UL / CrossHairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = H.BlackColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1, TargetDist );
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);

		CrosshairColor = H.bGreenCrosshair ? H.Default.LightGreenColor : Default.CrosshairColor;
		H.Canvas.DrawColor = (WorldInfo.TimeSeconds - LastHitEnemyTime < 0.3) ? H.RedColor : CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY, TargetDist);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);
	}
}

/**
 * Draw the locked on symbol
 */
simulated function DrawLockedOn( HUD H )
{
	local vector2d CrosshairSize;
	local float x, y, ScreenX, ScreenY, LockedOnTime, TargetDist;
	
	TargetDist = GetTargetDistance();

	if ( !bWasLocked )
	{
		LockedStartTime = WorldInfo.TimeSeconds;
		CurrentLockedScale = StartLockedScale;
		bWasLocked = true;
	}
	else
	{
		LockedOnTime = WorldInfo.TimeSeconds - LockedStartTime;
		CurrentLockedScale = (LockedOnTime > LockedScaleTime) ? FinalLockedScale : (StartLockedScale * (LockedScaleTime - LockedOnTime) + FinalLockedScale * LockedOnTime)/LockedScaleTime;
	}
 	CrosshairSize.Y = UTHUDBase(H).ConfiguredCrosshairScaling * CurrentLockedScale * CrosshairScaling * LockedCrossHairCoordinates.VL * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( LockedCrossHairCoordinates.UL / LockedCrossHairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = class'UTHUD'.default.BlackColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1, TargetDist );
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, LockedCrossHairCoordinates.U, LockedCrossHairCoordinates.V, LockedCrossHairCoordinates.UL,LockedCrossHairCoordinates.VL);

		H.Canvas.DrawColor = CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY, TargetDist);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, LockedCrossHairCoordinates.U, LockedCrossHairCoordinates.V, LockedCrossHairCoordinates.UL,LockedCrossHairCoordinates.VL);
	}
}

simulated function int GetAmmoCount()
{
	return AmmoCount;
}

/**
 * list important Weapon variables on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
 * the ShowDebug exec is used
 *
 * @param	HUD			- HUD with canvas to draw on
 * @input	out_YL		- Height of the current font
 * @input	out_YPos	- Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	Super.DisplayDebug(HUD, out_YL, out_YPos);

	if (UTPawn(Instigator) != None)
	{
		HUD.Canvas.DrawText("Eyeheight "$Instigator.EyeHeight$" base "$Instigator.BaseEyeheight$" landbob "$UTPawn(Instigator).Landbob$" just landed "$UTPawn(Instigator).bJustLanded$" land recover "$UTPawn(Instigator).bLandRecovery, false);
		out_YPos += out_YL;
	}

	HUD.Canvas.SetPos(4,out_YPos);
	HUD.Canvas.DrawText("Zoom State:"@GetZoomedState()@"ZoomedRate:"@ZoomedRate@"Target FOV:"@ZoomedTargetFOV);
	out_YPos+= out_YL;
}


/*********************************************************************************************
 * Attachments / Effects / etc
 *********************************************************************************************/
/**
 * Returns interval in seconds between each shot, for the firing state of FireModeNum firing mode.
 *
 * @param	FireModeNum	fire mode
 * @return	Period in seconds of firing mode
 */
simulated function float GetFireInterval( byte FireModeNum )
{
	return FireInterval[FireModeNum] * ((UTPawn(Owner)!= None) ? UTPawn(Owner).FireRateMultiplier : 1.0);
}

simulated function PlayArmAnimation( Name Sequence, float fDesiredDuration, optional bool OffHand, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	local UTPawn UTP;
	local SkeletalMeshComponent ArmMeshComp;
	local AnimNodeSequence WeapNode;

	// do not play on a dedicated server or if they aren't being seen
	if( WorldInfo.NetMode == NM_DedicatedServer || Instigator == None || !Instigator.IsFirstPerson())
	{
		return;
	}
	UTP = UTPawn(Instigator);
	if(UTP == none)
	{
		return;
	}
	if(UTP.bArmsAttached)
	{
		// Choose the right arm
		if(!OffHand)
		{
			ArmMeshComp = UTP.ArmsMesh[0];
		}
		else
		{
			ArmMeshComp = UTP.ArmsMesh[1];
		}

		// Check we have access to mesh and animations
		if( ArmMeshComp == None || ArmsAnimSet == none || GetArmAnimNodeSeq() == None )
		{
			return;
		}

		// If we are not specifying a duration, use the default play rate.
		if(fDesiredDuration > 0.0)
		{
			// @todo - this should call GetWeaponAnimNodeSeq, move 'duration' code into AnimNodeSequence and use that.
			ArmMeshComp.PlayAnim(Sequence, fDesiredDuration, bLoop);
		}
		else
		{
			WeapNode = AnimNodeSequence(ArmMeshComp.Animations);
			WeapNode.SetAnim(Sequence);
			WeapNode.PlayAnim(bLoop, DefaultAnimSpeed);
		}
	}
}

simulated function PlayWeaponAnimation(name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	if (Mesh != None && Mesh.bAttached)
	{
		Super.PlayWeaponAnimation(Sequence, fDesiredDuration, bLoop, SkelMesh);
	}
}

/**
 * PlayFireEffects Is the root function that handles all of the effects associated with
 * a weapon.  This function creates the 1st person effects.  It should only be called
 * on a locally controlled player.
 */
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	// Play Weapon fire animation

	if ( FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '' )
		PlayWeaponAnimation( WeaponFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	if ( FireModeNum < ArmFireAnim.Length && ArmFireAnim[FireModeNum] != '' && ArmsAnimSet != none)
		PlayArmAnimation( ArmFireAnim[FireModeNum], GetFireInterval(FireModeNum) );

	// Start muzzle flash effect
	CauseMuzzleFlash();

	ShakeView();
}

simulated function StopFireEffects(byte FireModeNum)
{
	StopMuzzleFlash();
}

/** plays view shake on the owning client only */
simulated function ShakeView()
{
	local UTPlayerController PC;

	PC = UTPlayerController(Instigator.Controller);
	if (PC != None && LocalPlayer(PC.Player) != None && CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
	{
		PC.PlayCameraAnim(FireCameraAnim[CurrentFireMode], (GetZoomedState() > ZST_ZoomingOut) ? PC.FOVAngle / PC.DefaultFOV : 1.0);
	}

	// Play controller vibration
	if( PC != None && LocalPlayer(PC.Player) != None )
	{
		// only do rumble if we are a player controller
		UTPlayerController(Instigator.Controller).ClientPlayForceFeedbackWaveform( WeaponFireWaveForm );
	}
}

/**
 * WeaponCalcCamera allows a weapon to adjust the pawn's controller's camera.  Should be subclassed
 */
simulated function WeaponCalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot);

simulated function WeaponPlaySound(SoundCue Sound, optional float NoiseLoudness)
{
	if (!bSuppressSounds)
	{
		Super.WeaponPlaySound(Sound, NoiseLoudness);
	}
}

/**
 * Tells the weapon to play a firing sound (uses CurrentFireMode)
 */
simulated function PlayFiringSound()
{
	if (CurrentFireMode<WeaponFireSnd.Length)
	{
		// play weapon fire sound
		if ( WeaponFireSnd[CurrentFireMode] != None )
		{
			MakeNoise(1.0);
			WeaponPlaySound( WeaponFireSnd[CurrentFireMode] );
		}
	}
}

/**
 * Turns the MuzzleFlashlight off
 */
simulated event MuzzleFlashTimer()
{
	if (MuzzleFlashPSC != none && (!bMuzzleFlashPSCLoops) )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

/**
 * Causes the muzzle flashlight to turn on
 */
simulated event CauseMuzzleFlashLight()
{
	// don't do muzzle flashes when running too slow, except on mobile, where we need it to show off dynamic lighting
	if ( WorldInfo.bDropDetail && !WorldInfo.IsConsoleBuild(CONSOLE_Mobile) )
	{
		return;
	}

	if ( MuzzleFlashLight != None )
	{
		MuzzleFlashLight.ResetLight();
	}
	else if ( MuzzleFlashLightClass != None )
	{
		MuzzleFlashLight = new(Outer) MuzzleFlashLightClass;
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(MuzzleFlashLight,MuzzleFlashSocket);
	}
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 */
simulated event CauseMuzzleFlash()
{
	local UTPawn P;
	local ParticleSystem MuzzleTemplate;

	if ( WorldInfo.NetMode != NM_Client )
	{
		P = UTPawn(Instigator);
		if ( (P == None) || !P.bUpdateEyeHeight )
		{
			return;
		}
	}

	CauseMuzzleFlashLight();

	if (GetHand() != HAND_Hidden || (bShowAltMuzzlePSCWhenWeaponHidden && Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None))
	{
		if ( !bMuzzleFlashAttached )
		{
			AttachMuzzleFlash();
		}
		if (MuzzleFlashPSC != None)
		{
			if (!bMuzzleFlashPSCLoops || (!MuzzleFlashPSC.bIsActive || MuzzleFlashPSC.bWasDeactivated))
			{
				if (Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None)
				{
					MuzzleTemplate = MuzzleFlashAltPSCTemplate;

					// Option to not hide alt muzzle
					MuzzleFlashPSC.SetIgnoreOwnerHidden(bShowAltMuzzlePSCWhenWeaponHidden);
				}
				else if (MuzzleFlashPSCTemplate != None)
				{
					MuzzleTemplate = MuzzleFlashPSCTemplate;
				}
				if (MuzzleTemplate != MuzzleFlashPSC.Template)
				{
					MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
				}
				SetMuzzleFlashParams(MuzzleFlashPSC);
				MuzzleFlashPSC.ActivateSystem();
			}
		}

		// Set when to turn it off.
		SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
	}
}

simulated event StopMuzzleFlash()
{
	ClearTimer('MuzzleFlashTimer');
	MuzzleFlashTimer();

	if ( MuzzleFlashPSC != none )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}


/**
 * Sets the timing for putting a weapon down.  The WeaponIsDown event is trigged when expired
*/
simulated function TimeWeaponPutDown()
{
	if( Instigator.IsFirstPerson() )
	{
		PlayWeaponPutDown();
	}

	super.TimeWeaponPutDown();
}

/**
 * Show the weapon being put away
 */
simulated function PlayWeaponPutDown()
{
	// Play the animation for the weapon being put down

	if ( WeaponPutDownAnim != '' )
		PlayWeaponAnimation( WeaponPutDownAnim, PutDownTime );
	if ( ArmsPutDownAnim != '' && ArmsAnimSet != none)
	{
		PlayArmAnimation( ArmsPutDownAnim, PutDownTime );
	}

	// play any associated sound
	if ( WeaponPutDownSnd != None )
		WeaponPlaySound( WeaponPutDownSnd );
}

/**
 * Sets the timing for equipping a weapon.
 * The WeaponEquipped event is trigged when expired
 */
simulated function TimeWeaponEquipping()
{
	// The weapon is equipped, attach it to the mesh.
	AttachWeaponTo( Instigator.Mesh );

	// Play the animation
	PlayWeaponEquip();

	SetTimer( GetEquipTime() , false, 'WeaponEquipped');
}

simulated function float GetEquipTime()
{
	local float ETime;

	ETime = EquipTime>0 ? EquipTime : 0.01;
	if ( PendingFire(0) || PendingFire(1) )
	{
		ETime += 0.25;
	}
	return ETime;
}

/**
 * Show the weapon begin equipped
 */
simulated function PlayWeaponEquip()
{
	// Play the animation for the weapon being put down

	if ( WeaponEquipAnim != '' )
		PlayWeaponAnimation( WeaponEquipAnim, EquipTime );
	if ( ArmsEquipAnim != '' && ArmsAnimSet != none)
	{
		PlayArmAnimation(ArmsEquipAnim, EquipTime);
	}

	// play any assoicated sound
	if ( WeaponEquipSnd != None )
		WeaponPlaySound( WeaponEquipSnd );
}

 /**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 *
 * @param	who is the pawn to attach to
 */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local UTPawn UTP;

	UTP = UTPawn(Instigator);
	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(True);
		bPendingShow = TRUE;
		Mesh.SetLightEnvironment(UTP.LightEnvironment);
		if (GetHand() == HAND_Hidden)
		{
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
			if (UTP.ArmsOverlay[0] != None)
			{
				UTP.ArmsOverlay[0].SetHidden(true);
				UTP.ArmsOverlay[1].SetHidden(true);
			}
		}
	}
	else
	{
		SetHidden(True);
		if (UTP != None)
		{
			Mesh.SetLightEnvironment(UTP.LightEnvironment);
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
			if (UTP.ArmsOverlay[0] != None)
			{
				UTP.ArmsOverlay[0].SetHidden(true);
				UTP.ArmsOverlay[1].SetHidden(true);
			}
		}
	}

	SetWeaponOverlayFlags(UTP);

	// Spawn the 3rd Person Attachment
	if (Role == ROLE_Authority && UTP != None)
	{
		UTP.CurrentWeaponAttachmentClass = AttachmentClass;
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			UTP.WeaponAttachmentChanged();
		}
	}

	SetSkin(UTPawn(Instigator).ReplicatedBodyMaterial);
}

/**
 * Allows a child to setup custom parameters on the muzzle flash
 */
simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	PSC.SetColorParameter('MuzzleFlashColor', MuzzleFlashColor);
	PSC.SetVectorParameter('MFlashScale',Vect(0.5,0.5,0.5));
}

/**
 * Called on a client, this function Attaches the WeaponAttachment
 * to the Mesh.
 */
simulated function AttachMuzzleFlash()
{
	local SkeletalMeshComponent SKMesh;

	// Attach the Muzzle Flash
	bMuzzleFlashAttached = true;
	SKMesh = SkeletalMeshComponent(Mesh);
	if (  SKMesh != none )
	{
		if ( (MuzzleFlashPSCTemplate != none) || (MuzzleFlashAltPSCTemplate != none) )
		{
			MuzzleFlashPSC = new(Outer) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
			MuzzleFlashPSC.SetFOV(UDKSkeletalMeshComponent(SKMesh).FOV);
			SKMesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}
}

/**
 * Detach weapon from skeletal mesh
 *
 * @param	SkeletalMeshComponent weapon is attached to.
 */
simulated function DetachWeapon()
{
	local UTPawn P;

	DetachComponent( Mesh );
	if (OverlayMesh != None)
	{
		DetachComponent(OverlayMesh);
	}

	SetSkin(None);

	P = UTPawn(Instigator);
	if (P != None)
	{
		if (Role == ROLE_Authority && P.CurrentWeaponAttachmentClass == AttachmentClass)
		{
			P.CurrentWeaponAttachmentClass = None;
			if (Instigator.IsLocallyControlled())
			{
				P.WeaponAttachmentChanged();
			}
		}
	}

	SetBase(None);
	SetHidden(True);
	DetachMuzzleFlash();
	Mesh.SetLightEnvironment(None);
}

/**
 * Remove/Detach the muzzle flash components
 */
simulated function DetachMuzzleFlash()
{
	local SkeletalMeshComponent SKMesh;

	bMuzzleFlashAttached = false;
	SKMesh = SkeletalMeshComponent(Mesh);
	if (  SKMesh != none )
	{
		if (MuzzleFlashPSC != none)
			SKMesh.DetachComponent( MuzzleFlashPSC );
	}
	MuzzleFlashPSC = None;
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	local UTPawn UTP;
	local SkeletalMeshComponent SkelMesh;
	local PrimitiveComponent Primitive;

	if (Mesh != None)
	{
		if (bIsVisible && !Mesh.bAttached)
		{
			AttachComponent(Mesh);
			EnsureWeaponOverlayComponentLast();
		}
		SetHidden(!bIsVisible);
		SkelMesh = SkeletalMeshComponent(Mesh);
		if (SkelMesh != None)
		{
			foreach SkelMesh.AttachedComponents(class'PrimitiveComponent', Primitive)
			{
				Primitive.SetHidden(!bIsVisible);
			}
		}
	}
	if (ArmsAnimSet != None && GetHand() != HAND_Hidden)
	{
		UTP = UTPawn(Instigator);
		if (UTP != None && UTP.ArmsMesh[0] != None)
		{
			UTP.ArmsMesh[0].SetHidden(!bIsVisible);
			if (UTP.ArmsOverlay[0] != None)
			{
				UTP.ArmsOverlay[0].SetHidden(!bIsVisible);
			}
		}
	}

	if ( OverlayMesh != none )
	{
		OverlayMesh.SetHidden(!bIsVisible || (GetHand() == HAND_Hidden));
	}
}

/**
* Called when the pawn is changing weapons
*/
simulated function PerformWeaponChange()
{
	if ( UTPawn(Instigator) != None )
	{
		if ( Instigator.IsLocallyControlled() )
		{
			UTPawn(Instigator).WeaponChanged(self);
		}

		// If the controller has not been replicated, try again later
		else if ( Instigator.Controller == None )
		{
			SetTimer(0.01, false, 'PerformWeaponChange');
		}
	}
}

/*********************************************************************************************
 * Pawn/Controller/View functions
 *********************************************************************************************/

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
	if ( UTVehicle(Owner) != none )
	{
		UTVehicle(Owner).GetWeaponViewAxes(self, xaxis, yaxis, zaxis);
	}
	else if ( Instigator.Controller == None )
	{
	GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    }
    else
    {
	GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
    }
}

/**
 * This function is called whenever you attempt to reselect the same weapon
 */
reliable server function ServerReselectWeapon();


/**
 * Returns true if this item can be thrown out.
 */
simulated function bool CanThrow()
{
	return bCanThrow && HasAnyAmmo();
}

/**
 * Returns the current Weapon Hand
 */
simulated function EWeaponHand GetHand()
{
	local UTPlayerController PC;

	// Get the Weapon Hand from the controller or default to HAND_Right
	if (Instigator != None)
	{
		PC = UTPlayerController(Instigator.Controller);
		if (PC != None)
		{
			return PC.WeaponHand;
		}
	}
	return HAND_Right;
}
/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder)
{
	local vector DrawOffset, ViewOffset, FinalSmallWeaponsOffset, FinalLocation;
	local EWeaponHand CurrentHand;
	local rotator NewRotation, FinalRotation, SpecRotation;
	local PlayerController PC;
	local vector2D ViewportSize;
	local bool bIsWideScreen;
	local vector SpecViewLoc;

	if ( !Holder.IsFirstPerson() )
		return;

	// Hide the weapon if hidden
	CurrentHand = GetHand();
	if ( bForceHidden || CurrentHand == HAND_Hidden)
	{
		Mesh.SetHidden(True);
		Holder.ArmsMesh[0].SetHidden(true);
		Holder.ArmsMesh[1].SetHidden(true);
		if (Holder.ArmsOverlay[0] != None)
		{
			Holder.ArmsOverlay[0].SetHidden(true);
			Holder.ArmsOverlay[1].SetHidden(true);
		}
		NewRotation = Holder.GetViewRotation();
		SetLocation(Instigator.GetPawnViewLocation() + (HiddenWeaponsOffset >> NewRotation));
		SetRotation(NewRotation);
		SetBase(Instigator);
		return;
	}

	if(bPendingShow)
	{
		SetHidden(False);
		bPendingShow = FALSE;
	}

	Mesh.SetHidden(False);

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
		break;
	}
	bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

	// Adjust for the current hand
	ViewOffset = PlayerViewOffset;
	FinalSmallWeaponsOffset = SmallWeaponsOffset;

	switch ( CurrentHand )
	{
		case HAND_Left:
			Mesh.SetScale3D(default.Mesh.Scale3D * vect(1,-1,1));
			Mesh.SetRotation(rot(0,0,0) - default.Mesh.Rotation);
			if (ArmsAnimSet != None)
			{
				Holder.ArmsMesh[0].SetScale3D(Holder.default.ArmsMesh[0].Scale3D * vect(1,-1,1));
				Holder.ArmsMesh[1].SetScale3D(Holder.default.ArmsMesh[1].Scale3D * vect(1,-1,1));
				if (Holder.ArmsOverlay[0] != None)
				{
					Holder.ArmsOverlay[0].SetScale3D(Holder.ArmsMesh[0].Scale3D);
					Holder.ArmsOverlay[1].SetScale3D(Holder.ArmsMesh[1].Scale3D);
				}
			}
			ViewOffset.Y *= -1.0;
			FinalSmallWeaponsOffset.Y *= -1.0;
			break;

		case HAND_Centered:
			ViewOffset.Y = 0.0;
			FinalSmallWeaponsOffset.Y = 0.0;
			break;

		case HAND_Right:
			Mesh.SetScale3D(default.Mesh.Scale3D);
			Mesh.SetRotation(default.Mesh.Rotation);
			if (ArmsAnimSet != None)
			{
				Holder.ArmsMesh[0].SetScale3D(Holder.default.ArmsMesh[0].Scale3D);
				Holder.ArmsMesh[1].SetScale3D(Holder.default.ArmsMesh[1].Scale3D);
				if (Holder.ArmsOverlay[0] != None)
				{
					Holder.ArmsOverlay[0].SetScale3D(Holder.ArmsMesh[0].Scale3D);
					Holder.ArmsOverlay[1].SetScale3D(Holder.ArmsMesh[1].Scale3D);
				}
			}
			break;
		default:
			break;
	}

	if ( bIsWideScreen )
	{
		ViewOffset += WideScreenOffsetScaling * FinalSmallWeaponsOffset;
		if ( bSmallWeapons )
		{
			ViewOffset += 0.7 * FinalSmallWeaponsOffset;
		}
	}
	else if ( bSmallWeapons )
	{
		ViewOffset += FinalSmallWeaponsOffset;
	}

	// Calculate the draw offset
	if ( Holder.Controller == None )
	{
		if ( DemoRecSpectator(PC) != None )
		{
			PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
			DrawOffset = ViewOffset >> SpecRotation;
			DrawOffset += UTPawn(Holder).WeaponBob(BobDamping, JumpDamping);
			FinalLocation = SpecViewLoc + DrawOffset;
			SetLocation(FinalLocation);
			SetBase(Holder);

			// Add some rotation leading
			SpecRotation.Yaw = LagRot(SpecRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
			SpecRotation.Pitch = LagRot(SpecRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
			LastRotUpdate = WorldInfo.TimeSeconds;
			LastRotation = SpecRotation;

			if ( bIsWideScreen )
			{
				SpecRotation += WidescreenRotationOffset;
			}
			SetRotation(SpecRotation);
			return;
		}
		else
		{
		DrawOffset = (ViewOffset >> Holder.GetBaseAimRotation()) + UTPawn(Holder).GetEyeHeight() * vect(0,0,1);
	}
	}
	else
	{
		DrawOffset.Z = UTPawn(Holder).GetEyeHeight();
		DrawOffset += UTPawn(Holder).WeaponBob(BobDamping, JumpDamping);

		if ( UTPlayerController(Holder.Controller) != None )
		{
			DrawOffset += UTPlayerController(Holder.Controller).ShakeOffset >> Holder.Controller.Rotation;
		}

		DrawOffset = DrawOffset + ( ViewOffset >> Holder.Controller.Rotation );
	}

	// Adjust it in the world
	FinalLocation = Holder.Location + DrawOffset;
	SetLocation(FinalLocation);
	SetBase(Holder);

	if (ArmsAnimSet != None)
	{
		Holder.ArmsMesh[0].SetTranslation(DrawOffset);
		Holder.ArmsMesh[1].SetTranslation(DrawOffset);
		if (Holder.ArmsOverlay[0] != None)
		{
			Holder.ArmsOverlay[0].SetTranslation(DrawOffset);
			Holder.ArmsOverlay[1].SetTranslation(DrawOffset);
		}
	}

	NewRotation = (Holder.Controller == None) ? Holder.GetBaseAimRotation() : Holder.Controller.Rotation;

	// Add some rotation leading
	if (Holder.Controller != None)
	{
		FinalRotation.Yaw = LagRot(NewRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
		FinalRotation.Pitch = LagRot(NewRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
		FinalRotation.Roll = NewRotation.Roll;
	}
	else
	{
		FinalRotation = NewRotation;
	}
	LastRotUpdate = WorldInfo.TimeSeconds;
	LastRotation = NewRotation;

	if ( bIsWideScreen )
	{
		FinalRotation += WidescreenRotationOffset;
	}
	SetRotation(FinalRotation);
	if (ArmsAnimSet != None)
	{
		Holder.ArmsMesh[0].SetRotation(FinalRotation);
		Holder.ArmsMesh[1].SetRotation(FinalRotation);
		if (Holder.ArmsOverlay[0] != None)
		{
			Holder.ArmsOverlay[0].SetRotation(FinalRotation);
			Holder.ArmsOverlay[1].SetRotation(FinalRotation);
		}
	}
}

/** @return whether the weapon's rotation is allowed to lag behind the holder's rotation */
simulated function bool ShouldLagRot()
{
	return false;
}

simulated function int LagRot(int NewValue, int LastValue, float MaxDiff, int Index)
{
	local int RotDiff;
	local float LeadMag, DeltaTime;

	if ( NewValue ClockWiseFrom LastValue )
	{
		if ( LastValue > NewValue )
		{
			LastValue -= 65536;
		}
	}
	else
	{
		if ( NewValue > LastValue )
		{
			NewValue -= 65536;
		}
	}

	DeltaTime = WorldInfo.TimeSeconds - LastRotUpdate;
	RotDiff = NewValue - LastValue;
	if ( (RotDiff == 0) || (OldRotDiff[Index] == 0) )
	{
		LeadMag = ShouldLagRot() ? OldLeadMag[Index] : 0.0;
		if ( (RotDiff == 0) && (OldRotDiff[Index] == 0) )
		{
			OldMaxDiff[Index] = 0;
		}
	}
	else if ( (RotDiff > 0) == (OldRotDiff[Index] > 0) )
	{
		if (ShouldLagRot())
		{
			MaxDiff = FMin(1, Abs(RotDiff)/(12000*DeltaTime)) * MaxDiff;
			if ( OldMaxDiff[Index] != 0 )
				MaxDiff = FMax(OldMaxDiff[Index], MaxDiff);

			OldMaxDiff[Index] = MaxDiff;
			LeadMag = (NewValue > LastValue) ? -1* MaxDiff : MaxDiff;
		}
		else
		{
			LeadMag = 0;
		}
		if ( DeltaTime < 1/RotChgSpeed )
		{
			LeadMag = (1.0 - RotChgSpeed*DeltaTime)*OldLeadMag[Index] + RotChgSpeed*DeltaTime*LeadMag;
		}
		else
		{
			LeadMag = 0;
		}
	}
	else
	{
		LeadMag = 0;
		OldMaxDiff[Index] = 0;
		if ( DeltaTime < 1/ReturnChgSpeed )
		{
			LeadMag = (1 - ReturnChgSpeed*DeltaTime)*OldLeadMag[Index] + ReturnChgSpeed*DeltaTime*LeadMag;
		}
	}
	OldLeadMag[Index] = LeadMag;
	OldRotDiff[Index] = RotDiff;

	return NewValue + LeadMag;
}

/**
 * called every time owner takes damage while holding this weapon - used by shield gun
 */
function AdjustPlayerDamage( out int Damage, Controller InstigatedBy, Vector HitLocation,
			     out Vector Momentum, class<DamageType> DamageType)
{
}

/*********************************************************************************************
 * AI interface
 *********************************************************************************************/

/** 
  *  How good weapon is at damaging Pawn P
  */
function float RelativeStrengthVersus(Pawn P, float Dist)
{
	return 0;
}

/**
 * Returns a weight reflecting the desire to use the
 * given weapon, used for AI and player best weapon
 * selection.
 *
 * @param	Weapon W
 * @return	Weapon rating (range -1.f to 1.f)
 */
simulated function float GetWeaponRating()
{
	if ( (Instigator == None) || (UTBot(Instigator.Controller) == None) || !HasAnyAmmo() )
		CurrentRating = Priority;
	else
		CurrentRating = UTBot(Instigator.Controller).RateWeapon(self);

	return CurrentRating;
}

/**
 * return false if out of range, can't see target, etc.
 */
function bool CanAttack(Actor Other)
{
	local float Dist, CheckDist, OtherHeight;
	local vector HitLocation, HitNormal, projStart, TargetLoc;
	local Actor HitActor, TestActor;
	local class<Projectile> ProjClass;
	local int i;
	local UTBot B;

	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}

	// check that target is within range
	Dist = VSize(Instigator.Location - Other.Location);
	if (Dist > MaxRange())
	{
		return false;
	}

	projStart = bInstantHit ? InstantFireStartTrace() : GetPhysicalFireStartLoc();

	// check that can see target
	B = UTBot(Instigator.Controller);
	if (Instigator.Controller.LineOfSightTo(Other, projStart))
	{
		if (B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = false;
		}
	}
	else
	{
		if (!Other.bHasAlternateTargetLocation || !Instigator.Controller.LineOfSightTo(Other, projStart, true))
		{
			return false;
		}

		if (B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = true;
		}
	}

	if ( !bInstantHit )
	{
		ProjClass = GetProjectileClass();
		if ( ProjClass == None )
		{
			for (i = 0; i < WeaponProjectiles.length; i++)
			{
				ProjClass = WeaponProjectiles[i];
				if (ProjClass != None)
				{
					break;
				}
			}
		}
		if (ProjClass == None)
		{
			`warn("No projectile class for "$self);
			CheckDist = 300;
		}
		else
		{
			CheckDist = FMax(CheckDist, 0.5 * ProjClass.default.Speed);
			CheckDist = FMax(CheckDist, 300);
			CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
		}
	}

	// check that would hit target, and not a friendly
	TargetLoc = Other.GetTargetLocation(Instigator);
	if ( Pawn(Other) != None )
	{
		OtherHeight = Pawn(Other).GetCollisionHeight();
		TargetLoc.Z += 0.9 * OtherHeight;
	}

	// perform the trace
	if ( bInstantHit )
	{
		HitActor = GetTraceOwner().Trace(HitLocation, HitNormal, TargetLoc, projStart, true,,, TRACEFLAG_Bullet);
	}
	else
	{
		// for non-instant hit, ignore actors beyond a small distance that may move out of the way
		foreach GetTraceOwner().TraceActors( class'Actor', TestActor, HitLocation, HitNormal,
							TargetLoc, projStart,,, TRACEFLAG_Bullet )
		{
			if ( (TestActor.bBlockActors || TestActor.bProjTarget) &&
				(VSize(HitLocation - projStart) <= CheckDist || TestActor.IsStationary()) )
			{
				HitActor = TestActor;
				break;
			}
		}
	}

	if ( HitActor == None || HitActor == Other || (!HitActor.IsA('Pawn') && !HitActor.IsA('UTGameObjective'))
		|| !WorldInfo.GRI.OnSameTeam(Instigator, HitActor) )
	{
		return true;
	}

	return false;
}

/**
 * tell the bot how much it wants this weapon pickup
 * called when the bot is trying to decide which inventory pickup to go after next
 */
static function float BotDesireability(Actor PickupHolder, Pawn P, Controller C)
{
	local UTWeapon AlreadyHas;
	local float desire;
	local UTBot Bot;

	Bot = UTBot(C);
	if ( Bot == None )
		return 0;

	if ( UTWeaponLocker(PickupHolder) != None )
		return UTWeaponLocker(PickupHolder).BotDesireability(P, C);

	// bots adjust their desire for their favorite weapons
	desire = Default.MaxDesireability;
	if (ClassIsChildOf(default.Class, Bot.FavoriteWeapon))
	{
		desire *= 1.5;
	}

	// see if bot already has a weapon of this type
	AlreadyHas = UTWeapon(P.FindInventoryType(default.class));
	if ( AlreadyHas != None )
	{
		if ( Bot.bHuntPlayer )
			return 0;

		// can't pick it up if weapon stay is on
		if ( (UTWeaponPickupFactory(PickupHolder) != None) && !UTWeaponPickupFactory(PickupHolder).AllowPickup(Bot) )
			return 0;

		if ( AlreadyHas.AmmoMaxed(0) )
			return 0.25 * desire;

		// bot wants this weapon for the ammo it holds
		if( AlreadyHas.AmmoCount > 0 )
		{
			if ( Default.AmmoPickupClass == None )
				return 0.05;
			else
				return FMax( 0.25 * desire,
						Default.AmmoPickupClass.Default.MaxDesireability
						* FMin(1, 0.15 * AlreadyHas.MaxAmmoCount/AlreadyHas.AmmoCount) );
		}
		else
			return 0.05;
	}
	if ( Bot.bHuntPlayer && (desire * 0.833 < P.Weapon.AIRating - 0.1) )
		return 0;

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (P.Weapon == None) || (P.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
}

/**
 * CanHeal()
 * used by bot AI should return true if this weapon is able to heal Other
 */
function bool CanHeal(Actor Other)
{
	return false;
}

/** used by bot AI to get the optimal range for shooting Target
 * can be called on friendly Targets if trying to heal it
 */
function float GetOptimalRangeFor(Actor Target)
{
	return MaxRange();
}

/**
 * tells AI that it needs to release the fire button for this weapon to do anything
 */
function bool FireOnRelease()
{
	return ( ShouldFireOnRelease[CurrentFireMode] != 0 );
}


function bool FocusOnLeader(bool bLeaderFiring)
{
	return false;
}

function bool RecommendRangedAttack()
{
	return false;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
	return 0.0;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
	return 0.0;
}

function float RangedAttackTime()
{
	return 0;
}

/**
 * return true if recommend jumping while firing to improve splash damage (by shooting at feet)
 * true for R.L., for example
 */
function bool SplashJump()
{
    return bSplashJump;
}

/**
 * called by AI when camping/defending
 * return true if it is useful to fire this weapon even though bot doesn't have a target
 * for example, a weapon that launches turrets or mines
 */
function bool ShouldFireWithoutTarget()
{
	return false;
}

/**
 * BestMode()
 * choose between regular or alt-fire
 */
function byte BestMode()
{
	local byte Best;
	if ( IsFiring() )
		return CurrentFireMode;

	if ( FRand() < 0.5 )
		Best = 1;

	if ( Best < bZoomedFireMode.Length && bZoomedFireMode[Best] != 0 )
		return 0;
	else
		return Best;
}

/** @return whether this is a charging weapon and is fully charged up */
function bool IsFullyCharged()
{
	return false;
}

/**
 * ReadyToFire()
 * called by NPC firing weapon.
 * bFinished should only be true if called from the Finished() function
 */
simulated function bool ReadyToFire(bool bFinished)
{
	return false;
}

simulated function bool StillFiring(byte FireMode)
{
	if ( UTBot(Instigator.Controller) != None )
	{
		ClearPendingFire(0);
		ClearPendingFire(1);
		UTBot(Instigator.Controller).WeaponFireAgain(true);
	}

	return super.StillFiring(FireMode);
}

/*********************************************************************************************
 * Ammunition / Inventory
 *********************************************************************************************/

/**
 * Consumes some of the ammo
 */
function ConsumeAmmo( byte FireModeNum )
{
	// Subtract the Ammo
	AddAmmo(-ShotCost[FireModeNum]);
}

/**
 * This function is used to add ammo back to a weapon.  It's called from the Inventory Manager
 */
function int AddAmmo( int Amount )
{
	AmmoCount = Clamp(AmmoCount + Amount,0,MaxAmmoCount);
	// check for infinite ammo
	if (AmmoCount <= 0 && (UTInventoryManager(InvManager) == None || UTInventoryManager(InvManager).bInfiniteAmmo))
	{
		AmmoCount = MaxAmmoCount;
	}

	return AmmoCount;
}

/**
 * Returns true if the ammo is maxed out
 */
simulated function bool AmmoMaxed(int mode)
{
	return (AmmoCount >= MaxAmmoCount);
}

/**
 * This function checks to see if the weapon has any ammo available for a given fire mode.
 *
 * @param	FireModeNum		- The Fire Mode to Test For
 * @param	Amount			- [Optional] Check to see if this amount is available.  If 0 it will default to checking
 *							  for the ShotCost
 */
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if (Amount==0)
		return (AmmoCount >= ShotCost[FireModeNum]);
	else
		return ( AmmoCount >= Amount );
}

/**
 * returns true if this weapon has any ammo
 */
simulated function bool HasAnyAmmo()
{
	return ( ( AmmoCount > 0 ) || (ShotCost[0]==0 && ShotCost[1]==0) );
}
/**
 * This function retuns how much of the clip is empty.
 */
simulated function float DesireAmmo(bool bDetour)
{
	return (1.f - float(AmmoCount)/MaxAmmoCount);
}

/**
 * Returns true if the current ammo count is less than the default ammo count
 */
simulated function bool NeedAmmo()
{
	return ( AmmoCount < Default.AmmoCount );
}

/**
 * Cheat Help function the loads out the weapon
 *
 * @param 	bUseWeaponMax 	- [Optional] If true, this function will load out the weapon
 *							  with the actual maximum, not 999
 */
simulated function Loaded(optional bool bUseWeaponMax)
{
	if (bUseWeaponMax)
		AmmoCount = MaxAmmoCount;
	else
		AmmoCount = 999;
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	local DroppedPickup DP;

	// By default, you can only carry a single item of a given class.
	if ( ItemClass == class )
	{
		DP = DroppedPickup(Pickup);
		if (DP != None)
		{
			if ( DP.Instigator == Instigator )
			{
				// weapon was dropped by this player - disallow pickup
				return true;
			}
			// take the ammo that the dropped weapon has
			AddAmmo(UTWeapon(DP.Inventory).AmmoCount);
			DP.PickedUpBy(Instigator);
			AnnouncePickup(Instigator);
		}
		else
		{
			// add the ammo that the pickup should give us, then tell it to respawn
			AddAmmo(default.AmmoCount);
			Pickup.PickedUpBy(Instigator);
			AnnouncePickup(Instigator);
		}
		return true;
	}

	return false;
}


/**
 * Called when the weapon runs out of ammo during firing
 */
simulated function WeaponEmpty()
{
	// If we were firing, stop
	if ( IsFiring() )
	{
		GotoState('Active');
	}

	if ( Instigator != none && Instigator.IsLocallyControlled() )
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}

/**
 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
 */
simulated function bool bReadyToFire()
{
	return true;
}

/*********************************************************************************************
 * Firing
 *********************************************************************************************/

/**
* @returns position of trace start for instantfire()
*/
simulated function vector InstantFireStartTrace()
{
	return Instigator.GetWeaponStartTraceLocation();
}

/**
* @returns end trace position for instantfire()
*/
simulated function vector InstantFireEndTrace(vector StartTrace)
{
	return StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange();
}

/**
 * Performs an 'Instant Hit' shot.
 * Also, sets up replication for remote clients,
 * and processes all the impacts to deal proper damage and play effects.
 *
 * Network: Local Player and Server
 */
simulated function InstantFire()
{
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact, NearImpact;
	local int i, FinalImpactIndex;

	// define range to use for CalcWeaponFire()
	StartTrace = InstantFireStartTrace();
	EndTrace = InstantFireEndTrace(StartTrace);
	bUsingAimingHelp = false;
	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	FinalImpactIndex = ImpactList.length - 1;

	if (FinalImpactIndex >= 0 && (ImpactList[FinalImpactIndex].HitActor == None || !ImpactList[FinalImpactIndex].HitActor.bProjTarget))
	{
		// console aiming help
		NearImpact = InstantAimHelp(StartTrace, EndTrace, RealImpact);
		if ( NearImpact.HitActor != None )
		{
			bUsingAimingHelp = true;
			ImpactList[FinalImpactIndex] = NearImpact;
		}
	}

	for (i = 0; i < ImpactList.length; i++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[i]);
	}

	if (Role == ROLE_Authority)
	{
		// Set flash location to trigger client side effects.
		// if HitActor == None, then HitLocation represents the end of the trace (maxrange)
		// Remote clients perform another trace to retrieve the remaining Hit Information (HitActor, HitNormal, HitInfo...)
		// Here, The final impact is replicated. More complex bullet physics (bounce, penetration...)
		// would probably have to run a full simulation on remote clients.
		if ( NearImpact.HitActor != None )
		{
			SetFlashLocation(NearImpact.HitLocation);
		}
		else
		{
			SetFlashLocation(RealImpact.HitLocation);
		}
	}
}

/**
  * Look for "near miss" of target within UTPC.AimHelpModifier() * AimingHelpRadius
  * Return that target as a hit if it was a near miss
  */
simulated function ImpactInfo InstantAimHelp(vector StartTrace, vector EndTrace, ImpactInfo RealImpact)
{
	local ImpactInfo NearImpact;
	local Pawn ShotTarget;
	local UTPlayerController UTPC;
	local float AimHelpDist;
	local vector ClosestPoint;

	NearImpact.HitActor = None;
	UTPC = (Instigator != None) ? UTPlayerController(Instigator.Controller) : None;
	if ( (UTPC != None) && (UTPC.ShotTarget != None) && UTPC.AimingHelp(true) && (AimingHelpRadius[Min(CurrentFireMode,1)] > 0.0) )
	{
		ShotTarget = UTPC.ShotTarget;
		if ( RealImpact.HitActor != None )
		{
			EndTrace = RealImpact.HitLocation;
		}
		if ( ((EndTrace - ShotTarget.Location) Dot (ShotTarget.Location - StartTrace)) > 0 )
		{
			PointDistToLine(ShotTarget.Location, EndTrace - StartTrace, StartTrace, ClosestPoint);
			AimHelpDist = UTPC.AimHelpModifier() * AimingHelpRadius[Min(CurrentFireMode,1)] * class'UTProjectile'.Default.GlobalCheckRadiusTweak;

			// reduce help if target isn't moving
			if ( ShotTarget.Velocity == vect(0,0,0) )
				AimHelpDist *= 0.5;

			// accept near miss if within AimHelpDist
			if ( (abs(ClosestPoint.Z - ShotTarget.Location.Z) < ShotTarget.CylinderComponent.CollisionHeight + AimHelpDist)
				&& (VSize2D(ClosestPoint - ShotTarget.Location) < ShotTarget.CylinderComponent.CollisionRadius + AimHelpDist) )
			{
				NearImpact.HitActor = ShotTarget;
				NearImpact.HitLocation = ClosestPoint;
				NearImpact.HitNormal = Normal(EndTrace - StartTrace);
			}
		}
	}
	return NearImpact;
}

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(),,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc )) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local bool bFixMomentum;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if ( Impact.HitActor != None )
	{
		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}
		if ( !Impact.HitActor.bStatic && (Impact.HitActor != Instigator) )
		{
			if ( Impact.HitActor.Role == ROLE_Authority && Impact.HitActor.bProjTarget
				&& !WorldInfo.GRI.OnSameTeam(Instigator, Impact.HitActor)
				&& Impact.HitActor.Instigator != Instigator
				&& PhysicsVolume(Impact.HitActor) == None )
			{
				HitEnemy++;
				LastHitEnemyTime = WorldInfo.TimeSeconds;
			}
			if ( (UTPawn(Impact.HitActor) == None) && (InstantHitMomentum[FiringMode] == 0) )
			{
				InstantHitMomentum[FiringMode] = 1;
				bFixMomentum = true;
			}
			Super.ProcessInstantHit(FiringMode, Impact, NumHits);
			if (bFixMomentum)
			{
				InstantHitMomentum[FiringMode] = 0;
			}
		}
	}
}

/*********************************************************************************************
 * Zooming Functions
 *********************************************************************************************/

/**
 * Returns true if we are currently zoomed
 */
simulated function EZoomState GetZoomedState()
{
	local PlayerController PC;
	PC = PlayerController(Instigator.Controller);
	if ( PC != none && PC.FOVAngle != PC.DefaultFOV )
	{
		if ( PC.FOVAngle == PC.DesiredFOV )
		{
			return ZST_Zoomed;
		}

		return ( PC.FOVAngle < PC.DesiredFOV ) ? ZST_ZoomingOut : ZST_ZoomingIn;
	}
	return ZST_NotZoomed;
}

/**
 * We Override beginfire to add support for zooming.  Should only be called from BeginFire()
 *
 * @param	FireModeNum 	The current Firing Mode
 *
 * @returns true we should abort the BeginFire call
 */
simulated function bool CheckZoom(byte FireModeNum)
{
	local UTPlayerController PC;
	PC = UTPlayerController(Instigator.Controller);
	if (PC != None && LocalPlayer(PC.Player) != none && FireModeNum < bZoomedFireMode.Length && bZoomedFireMode[FireModeNum] != 0)
	{
		if (GetZoomedState() == ZST_Zoomed)
		{
			EndZoom(PC);
			EndFire(FireModeNum);		// Kill this fire command
			return true;
		}
		else if ( GetZoomedState() == ZST_NotZoomed )
		{
			StartZoom(PC);
			ZoomedFireModeNum = FireModeNum;
		}
	}

	return false;
}

/** Called when zooming starts
 * @param PC - cast of Instigator.Controller for convenience
 */
simulated function StartZoom(UTPlayerController PC)
{
	PC.StartZoom(ZoomedTargetFOV, ZoomedRate);
	PlaySound(ZoomInSound, true);
}

/** Called when zooming ends
 * @param PC - cast of Instigator.Controller for convenience
 */
simulated function EndZoom(UTPlayerController PC)
{
	PC.EndZoom();
	PlaySound(ZoomOutSound, true);
}


client reliable simulated function ClientEndFire(byte FireModeNum)
{
	if (Role != ROLE_Authority)
	{
		ClearPendingFire(FireModeNum);
		EndFire(FireModeNum);
	}
}

/**
 * We Override endfire to add support for zooming
 */
simulated function EndFire(Byte FireModeNum)
{
	local UTPlayerController PC;

	// Don't bother performing if this is a dedicated server

	if (WorldInfo.NetMode != NM_DedicatedServer && Instigator != None)
	{
		PC = UTPlayerController(Instigator.Controller);
		if (PC != None && LocalPlayer(PC.Player) != none && FireModeNum < bZoomedFireMode.Length && bZoomedFireMode[FireModeNum] != 0 )
		{
			PC.StopZoom();
		}
	}
	super.EndFire(FireModeNum);
}

/**
 * Don't send a zoomed fire mode in to a firing state
 */
simulated function SendToFiringState( byte FireModeNum )
{
	// Don't send if it's a zoomed firemode

	if (FireModeNum < bZoomedFireMode.Length && bZoomedFireMode[FireModeNum] != 0 )
	{
		return;
	}

	super.SendToFiringState(FireModeNum);
}

reliable client function ClientWeaponSet( bool bOptionalSet, optional bool bDoNotActivate )
{
	local PlayerController PC;

	if (Instigator != None)
	{
		PC = PlayerController(Instigator.Controller);
		if ( PC != None && LocalPlayer(PC.Player) != none )
		{
			PC.FOVAngle = PC.DefaultFOV;
		}
	}
	Super.ClientWeaponSet(bOptionalSet, bDoNotActivate);
}

/**
 * Deactiveate Spawn Protection
 */
simulated function FireAmmunition()
{
	if (CurrentFireMode >= bZoomedFireMode.Length || bZoomedFireMode[CurrentFireMode] == 0)
	{
		// if this is the local player, play the firing effects
		PlayFiringSound();

		Super.FireAmmunition();

		if (UTPawn(Instigator) != None)
		{
			UTPawn(Instigator).DeactivateSpawnProtection();
		}

		UTInventoryManager(InvManager).OwnerEvent('FiredWeapon');
	}
}


/*********************************************************************************************
 * state Inactive
 * This state is the default state.  It needs to make sure Zooming is reset when entering/leaving
 *********************************************************************************************/

auto simulated state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		local PlayerController PC;

		if ( Instigator != None )
		{
		  PC = PlayerController(Instigator.Controller);
		  if ( PC != None && LocalPlayer(PC.Player)!= none )
		  {
			  PC.FOVAngle = PC.DefaultFOV;
		  }
		}

		Super.BeginState(PreviousStateName);
	}

	/**
	 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
	 */
	simulated function bool bReadyToFire()
	{
		return false;
	}
}


/*********************************************************************************************
 * State WeaponFiring
 * This is the default Firing State.  It's performed on both the client and the server.
 *********************************************************************************************/
simulated state WeaponFiring
{
	simulated event ReplicatedEvent(name VarName)
	{
		if ( VarName == 'AmmoCount' && !HasAnyAmmo() )
		{
			return;
		}

		Global.ReplicatedEvent(VarName);
	}

	/**
	 * We override BeginFire() so that we can check for zooming and/or empty weapons
	 */

	simulated function BeginFire( Byte FireModeNum )
	{
		if ( CheckZoom(FireModeNum) )
		{
			return;
		}

		Global.BeginFire(FireModeNum);

		// No Ammo, then do a quick exit.
		if( !HasAmmo(FireModeNum) )
		{
			WeaponEmpty();
			return;
		}
	}

	/**
	 * When we are in the firing state, don't allow for a pickup to switch the weapon
	 */

	simulated function bool DenyClientWeaponSet()
	{
		return true;
	}
}

/*********************************************************************************************
 * state WeaponEquipping
 * This state is entered when a weapon is becomeing active (ie: Being brought up)
 *********************************************************************************************/

simulated state WeaponEquipping
{
	/**
	 * We want to being this state by setting up the timing and then notifying the pawn
	 * that the weapon has changed.
	 */

	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		// Notify the pawn that it's weapon has changed.
		//SetupArmsAnim();

		PerformWeaponChange();
	}

	simulated function bool TryPutDown()
	{
		// We want the abort to be the same amount of time as
		// we have already spent equipping

		SwitchAbortTime = PutDownTime * GetTimerCount('WeaponEquipped') / GetTimerRate('WeaponEquipped');
		GotoState('WeaponAbortEquip');

		return true;
	}

	simulated function EndState(Name NextStateName)
	{
		if (SkeletalMeshComponent(Mesh) == none || WeaponEquipAnim == '')
		{
			Mesh.SetRotation(Default.Mesh.Rotation);
		}
		ClearTimer('WeaponEquipped');
	}
}

simulated state WeaponAbortEquip
{
	simulated function BeginState(name PrevStateName)
	{
		local AnimNodeSequence AnimNode;
		local float Rate;

		// Time the abort
		SetTimer(FMax(SwitchAbortTime, 0.01),, 'WeaponEquipAborted');

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			// play anim
			if (WeaponEquipAnim != '')
			{
				AnimNode = GetWeaponAnimNodeSeq();
				if (AnimNode != None && AnimNode.AnimSeq != None)
				{
					AnimNode.SetAnim(WeaponPutDownAnim);
					Rate = AnimNode.AnimSeq.SequenceLength / PutDownTime;
					AnimNode.PlayAnim(false, Rate, AnimNode.AnimSeq.SequenceLength - SwitchAbortTime * Rate);
				}

			}
			if(ArmsEquipAnim != '' && ArmsAnimSet != none && Instigator != none /* && Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() */)
			{
				AnimNode = GetArmAnimNodeSeq();
				if (AnimNode != None && AnimNode.AnimSeq != None)
				{
					AnimNode.SetAnim(ArmsPutDownAnim);
					Rate = AnimNode.AnimSeq.SequenceLength/PutDownTime;
					AnimNode.PlayAnim(false, Rate, AnimNode.AnimSeq.SequenceLength - SwitchAbortTime * Rate);
				}
			}
		}
	}

	simulated function WeaponEquipAborted()
	{
		// This weapon is down, remove it from the mesh
		DetachWeapon();

		// Put weapon to sleep
		//@warning: must be before ChangedWeapon() because that can reactivate this weapon in some cases
		GotoState('Inactive');

		// switch to pending weapon
		InvManager.ChangedWeapon();
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('WeaponEquipAborted');
		Super.EndState(NextStateName);
	}
}

/**
  * Force streamed textures to be loaded.  Used to get MIPS streamed in before weapon comes up
  * @PARAM bForcePreload if true causes streamed textures to be force loaded, if false, clears force loading
  */
simulated function PreloadTextures(bool bForcePreload)
{
	if ( UDKSkeletalMeshComponent(Mesh) != None )
	{
		UDKSkeletalMeshComponent(Mesh).PreloadTextures(bForcePreload, WorldInfo.TimeSeconds + 2);
	}
}

/** called on both Instigator's current weapon and its pending weapon (if they exist)
 * @return whether Instigator is allowed to switch to NewWeapon
 */
simulated function bool AllowSwitchTo(Weapon NewWeapon)
{
	return true;
}

/**
 * When attempting to put the weapon down, look to see if our MinReloadPct has been met.  If so just put it down
 */
simulated function bool TryPutDown()
{
	local float MinTimerTarget;
	local float TimerCount;

	bWeaponPutDown = true;

	if (!IsTimerActive('RefireCheckTimer'))
	{
		PutDownWeapon();
	}
	else
	{
		MinTimerTarget = GetTimerRate('RefireCheckTimer') * MinReloadPct[CurrentFireMode];
		TimerCount = GetTimerCount('RefireCheckTimer');

		if (TimerCount >= MinTimerTarget)
		{
			PutDownWeapon();
		}
		else
		{
			// Shorten the wait time
			SetTimer(MinTimerTarget - TimerCount, false, 'FiringPutDownWeapon');
		}
	}

	return true;
}

simulated function FiringPutDownWeapon()
{
	if (bWeaponPutDown)
	{
		PutDownWeapon();
	}
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local UTPlayerController PC;
	local vector FireStartLoc, HitLocation, HitNormal, FireDir, FireEnd, ProjBox;
	local Actor HitActor;
	local rotator FireRot;
	local class<Projectile> FiredProjectileClass;
	local int TraceFlags;

	if( Instigator != none )
	{
		PC = UTPlayerController(Instigator.Controller);

		FireRot = Instigator.GetViewRotation();
		FireDir = vector(FireRot);
		if (PC == none || PC.bCenteredWeaponFire || PC.WeaponHand == HAND_Centered || PC.WeaponHand == HAND_Hidden)
		{
			FireStartLoc = Instigator.GetPawnViewLocation() + (FireDir * FireOffset.X);
		}
		else if (PC.WeaponHand == HAND_Left)
		{
			FireStartLoc = Instigator.GetPawnViewLocation() + ((FireOffset * vect(1,-1,1)) >> FireRot);
		}
		else
		{
			FireStartLoc = Instigator.GetPawnViewLocation() + (FireOffset >> FireRot);
		}

		if ( (PC != None) || (CustomTimeDilation < 1.0) )
		{
			FiredProjectileClass = GetProjectileClass();
			if ( FiredProjectileClass != None )
			{
				FireEnd = FireStartLoc + FireDir * ProjectileSpawnOffset;
				TraceFlags = bCollideComplex ? TRACEFLAG_Bullet : 0;
				if ( FiredProjectileClass.default.CylinderComponent.CollisionRadius > 0 )
				{
					FireEnd += FireDir * FiredProjectileClass.default.CylinderComponent.Translation.X;
					ProjBox = FiredProjectileClass.default.CylinderComponent.CollisionRadius * vect(1,1,0);
					ProjBox.Z = FiredProjectileClass.default.CylinderComponent.CollisionHeight;
					HitActor = Trace(HitLocation, HitNormal, FireEnd, Instigator.Location, true, ProjBox,,TraceFlags);
					if ( HitActor == None )
					{
						HitActor = Trace(HitLocation, HitNormal, FireEnd, FireStartLoc, true, ProjBox,,TraceFlags);
					}
					else
					{
						FireStartLoc = Instigator.Location - FireDir*FiredProjectileClass.default.CylinderComponent.Translation.X;
						FireStartLoc.Z = FireStartLoc.Z + FMin(Instigator.EyeHeight, Instigator.CylinderComponent.CollisionHeight - FiredProjectileClass.default.CylinderComponent.CollisionHeight - 1.0);
						return FireStartLoc;
					}
				}
				else
				{
					HitActor = Trace(HitLocation, HitNormal, FireEnd, FireStartLoc, true, vect(0,0,0),,TraceFlags);
				}
				return (HitActor == None) ? FireEnd : HitLocation - 3*FireDir;
			}
		}
		return FireStartLoc;
	}

	return Location;
}

/** @return the location + offset from which to spawn effects (primarily tracers) */
simulated function vector GetEffectLocation()
{
	local vector SocketLocation;

	if (GetHand() == HAND_Hidden)
	{
		SocketLocation = Instigator.Location;
	}
	else if (SkeletalMeshComponent(Mesh) != None && EffectSockets[CurrentFireMode] != '')
	{
		if (!SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndrotation(EffectSockets[CurrentFireMode], SocketLocation))
		{
			SocketLocation = Location;
		}
	}
	else if (Mesh != None)
	{
		SocketLocation = Mesh.Bounds.Origin + (vect(45,0,0) >> Rotation);
	}
	else
	{
		SocketLocation = Location;
	}

 	return SocketLocation;
}


simulated function RefireCheckTimer();

simulated function SetupArmsAnim()
{
	local UTPawn UTP;
	UTP = UTPawn(Instigator);
	if (UTP != None)
	{
		UTP.ArmsMesh[0].StopAnim(); // let's stop anything already going.
		if (ArmsAnimSet != None)
		{
			UTP.ArmsMesh[0].AnimSets[1] = ArmsAnimSet;
			UTP.ArmsMesh[0].SetHidden(false);
			UTP.ArmsMesh[0].SetLightEnvironment(UTP.LightEnvironment);
			if (UTP.ArmsOverlay[0] != None)
			{
				UTP.ArmsOverlay[0].SetHidden(false);
			}
		}
		else
		{
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
			if (UTP.ArmsOverlay[0] != None)
			{
				UTP.ArmsOverlay[0].SetHidden(true);
				UTP.ArmsOverlay[1].SetHidden(true);
			}
		}
	}
}
simulated state WeaponPuttingDown
{
	simulated function BeginState( Name PreviousStateName )
	{
		local UTPlayerController PC;

		PC = UTPlayerController(Instigator.Controller);
		if (PC != None && LocalPlayer(PC.Player) != none )
		{
			PC.EndZoom();
		}

		TimeWeaponPutDown();
		bWeaponPutDown = false;
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		if (SkeletalMeshComponent(Mesh) == none || WeaponEquipAnim == '')
		{
			Mesh.SetRotation(Default.Mesh.Rotation);
		}
	}

	simulated function Activate();

	/**
	 * @returns false if the weapon isn't ready to be fired.  For example, if it's in the Inactive/WeaponPuttingDown states.
	 */
	simulated function bool bReadyToFire()
	{
		return false;
	}
}

simulated function AnimNodeSequence GetArmAnimNodeSeq()
{
	local UTPawn P;

	P = UTPawn(Instigator);
	if (P != None && P.ArmsMesh[0] != None)
	{
		return AnimNodeSequence(P.ArmsMesh[0].Animations);
	}

	return None;
}

simulated event Destroyed()
{
	if (Instigator != None && Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
	{
		PreloadTextures(false);
	}
	super.Destroyed();
}

simulated state Active
{
	/**
	 * We override BeginFire() so that we can check for zooming
	 */
	simulated function BeginFire( Byte FireModeNum )
	{
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			if ( CheckZoom(FireModeNum) )
			{
				return;
			}
		}
		Super.BeginFire(FireModeNum);
	}

	simulated event OnAnimEnd(optional AnimNodeSequence SeqNode, optional float PlayedTime, optional float ExcessTime)
	{
		local int IdleIndex;

		if ( WorldInfo.NetMode != NM_DedicatedServer && WeaponIdleAnims.Length > 0 )
		{
			IdleIndex = Rand(WeaponIdleAnims.Length);
			PlayWeaponAnimation(WeaponIdleAnims[IdleIndex], 0.0, true);
			if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
			{
				PlayArmAnimation(ArmIdleAnims[IdleIndex], 0.0,, true);
			}
		}
	}
	simulated function PlayWeaponAnimation( Name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
	{
		Global.PlayWeaponAnimation(Sequence,fDesiredDuration,bLoop,SkelMesh);
		ClearTimer('OnAnimEnd');
		if (!bLoop)
		{
			SetTimer(fDesiredDuration,false,'OnAnimEnd');
		}
	}

	simulated function ChangeVisibility(bool bIsVisible)
	{
		local bool bNeedToPlayAnim;

		// if the mesh isn't attached, we skipped playing the idle anim so play it now
		bNeedToPlayAnim = !Mesh.bAttached;
		Global.ChangeVisibility(bIsVisible);
		if (bNeedToPlayAnim)
		{
			OnAnimEnd(None, 0.f, 0.f);
		}
	}

	simulated function bool ShouldLagRot()
	{
		return true;
	}

	reliable server function ServerStartFire( byte FireModeNum )
	{
		// Check to see if the weapon is active, but not the current weapon.  If it is, force the
		// client to reset
		if (Instigator != none && Instigator.Weapon != self)
		{
			`Log("########## WARNING: Server Received ServerStartFire on "$self$" while in the active state but not current weapon.  Attempting Realignment");
			`log("##########        : "$Instigator.PlayerReplicationInfo.PlayerName);
			`log("##########        : "$Instigator.Weapon@Instigator.Weapon.GetStateName());
			InvManager.ClientSyncWeapon(Instigator.Weapon);
			Global.ServerStartFire(FireModeNum);
		}
		else
		{
			Global.ServerStartFire(FireModeNum);
		}
	}

	/** Initialize the weapon as being active and ready to go. */
	simulated function BeginState( Name PreviousStateName )
	{
		OnAnimEnd(none, 0.f, 0.f);

		if ( UTBot(Instigator.Controller) != None )
		{
			if ( PendingFire(0) )
			{
				StillFiring(0);
			}
			else if ( PendingFire(1) )
			{
				StillFiring(1);
			}
		}
		Super.BeginState(PreviousStateName);

		if (InvManager != none && InvManager.LastAttemptedSwitchToWeapon != none)
		{
			if (InvManager.LastAttemptedSwitchToWeapon != self)
			{
				InvManager.LastAttemptedSwitchToWeapon.ClientWeaponSet(true);
			}
			InvManager.LastAttemptedSwitchToWeapon = none;
		}
	}
}

simulated function SetWeaponOverlayFlags(UTPawn OwnerPawn)
{
	local MaterialInterface InstanceToUse;
	local byte Flags;
	local int i;
	local UTGameReplicationInfo GRI;

	if(OwnerPawn != none)
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);
		if (GRI != None)
		{
			Flags = OwnerPawn.WeaponOverlayFlags;
			for (i = 0; i < GRI.WeaponOverlays.length; i++)
			{
				if (GRI.WeaponOverlays[i] != None && bool(Flags & (1 << i)))
				{
					InstanceToUse = GRI.WeaponOverlays[i];
					break;
				}
			}
		}
		if (InstanceToUse != None)
		{
			CreateOverlayMesh();
		}
		if ( OverlayMesh != None )
		{
			if (InstanceToUse != none)
			{
				for (i=0;i<OverlayMesh.GetNumElements(); i++)
				{
					OverlayMesh.SetMaterial(i, InstanceToUse);
				}

				if (!OverlayMesh.bAttached)
				{
					OverlayMesh.SetHidden(Mesh.HiddenGame);
					AttachComponent(OverlayMesh);
				}
			}
			else if ( OverlayMesh.bAttached )
			{
				DetachComponent(OverlayMesh);
				OverlayMesh.SetHidden(true);
			}
		}
	}
}

static function float DetourWeight(Pawn Other, float PathWeight)
{
	local UTBot B;

	B = UTBot(Other.Controller);
	if ( B != None &&
		(B.NeedWeapon() || B.FavoriteWeapon == default.Class || (B.DefensePoint != None && B.DefensePoint.WeaponPreference == default.Class)) &&
		Other.FindInventoryType(default.Class) == None )
	{
		return (default.MaxDesireability / PathWeight);
	}
	else
	{
		return 0.0;
	}
}

/**
 * Allow the weapon to adjust the turning speed of the pawn
 * @FIXME: Add support for validation on a server
 *
 * @param	aTurn		The aTurn value from PlayerInput to throttle
 * @param	aLookup		The aLookup value from playerInput to throttle
 */
simulated function ThrottleLook(out float aTurn, out float aLookup);

simulated function Activate()
{
	SetupArmsAnim();
	super.Activate();
}

/**
 * This function is meant to be overridden in children.  It turns the current power percentage for
 * a weapon.  It's called mostly from the hud
 *
 * @returns	the percentage of power ( 1.0 - 0.0 )
 */
simulated event float GetPowerPerc()
{
	return 0.0;
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	if (Instigator != None && Instigator.IsHumanControlled() && Instigator.IsLocallyControlled())
	{
		PreloadTextures(false);
	}

	Super.DropFrom(StartLocation, StartVelocity);
}

reliable client function ClientWeaponThrown()
{
	if ( Instigator != none && UTPlayerController(Instigator.Controller) != none )
	{
		UTPlayerController(Instigator.Controller).EndZoom();
	}

	Super.ClientWeaponThrown();
}


/**
 * This determines whether or not the Weapon can have ViewAcceleration when Firing.
 **/
simulated function bool CanViewAccelerationWhenFiring()
{
	return FALSE;
}


/** called when Instigator enters a vehicle while we are its Weapon */
simulated function HolderEnteredVehicle();

simulated function bool CoversScreenSpace(vector ScreenLoc, Canvas Canvas)
{
	return ( (ScreenLoc.X > (1-WeaponCanvasXPct)*Canvas.ClipX)
		&& (ScreenLoc.Y > (1-WeaponCanvasYPct)*Canvas.ClipY) );
}

simulated static function DrawKillIcon(Canvas Canvas, float ScreenX, float ScreenY, float HUDScaleX, float HUDScaleY)
{
	local color CanvasColor;

	// save current canvas color
	CanvasColor = Canvas.DrawColor;

	// draw weapon shadow
	Canvas.DrawColor = class'UTHUD'.default.BlackColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX - 2, ScreenY - 2 );
	Canvas.DrawTile(class'UTHUD'.default.AltHudTexture, 4 + HUDScaleX * 96, 4 + HUDScaleY * 64, default.IconCoordinates.U, default.IconCoordinates.V, default.IconCoordinates.UL, default.IconCoordinates.VL);

	// draw the weapon icon
	Canvas.DrawColor =  class'UTHUD'.default.WhiteColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX, ScreenY );
	Canvas.DrawTile(class'UTHUD'.default.AltHudTexture, HUDScaleX * 96, HUDScaleY * 64, default.IconCoordinates.U, default.IconCoordinates.V, default.IconCoordinates.UL, default.IconCoordinates.VL);
	Canvas.DrawColor = CanvasColor;
}

simulated function bool EnableFriendlyWarningCrosshair()
{
	return true;
}

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		CastShadow=false
		bAllowAmbientOcclusion=false
	End Object
	Mesh=FirstPersonMesh

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh
		bOnlyOwnerSee=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		CollideActors=false
		BlockRigidBody=false
		MaxDrawDistance=6000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsStaticDecals=FALSE
		bAcceptsDynamicDecals=FALSE
		bAllowAmbientOcclusion=false
		MotionBlurScale=0.0
	End Object
	DroppedPickupMesh=PickupMesh
	PickupFactoryMesh=PickupMesh
	PivotTranslation=(Y=-25.0)

	MessageClass=class'UTPickupMessage'
	DroppedPickupClass=class'UTDroppedPickup'

	ShotCost(0)=1
	ShotCost(1)=1

	MaxAmmoCount=1

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	WeaponProjectiles(0)=none
	WeaponProjectiles(1)=none

	FireInterval(0)=+1.0
	FireInterval(1)=+1.0

	Spread(0)=0.0
	Spread(1)=0.0

	InstantHitDamage(0)=0.0
	InstantHitDamage(1)=0.0
	InstantHitMomentum(0)=0.0
	InstantHitMomentum(1)=0.0
	InstantHitDamageTypes(0)=class'DamageType'
	InstantHitDamageTypes(1)=class'DamageType'
	WeaponRange=22000

	EffectSockets(0)=MuzzleFlashSocket
	EffectSockets(1)=MuzzleFlashSocket
	MuzzleFlashDuration=0.33

	WeaponFireSnd(0)=none
	WeaponFireSnd(1)=none

	MinReloadPct(0)=0.6
	MinReloadPct(1)=0.6

	MuzzleFlashSocket=MuzzleFlashSocket

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	LockerRotation=(Pitch=16384)

	WeaponColor=(R=255,G=255,B=255,A=255)
	BobDamping=0.85000
	JumpDamping=1.0
	AimError=525
	CurrentRating=+0.5
	MaxDesireability=0.5

	WeaponFireAnim(0)=WeaponFire
	WeaponFireAnim(1)=WeaponFire
	ArmFireAnim(0)=WeaponFire
	ArmFireAnim(1)=WeaponFire

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown
	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip
	WeaponIdleAnims(0)=WeaponIdle
	ArmIdleAnims(0)=WeaponIdle
	DefaultAnimSpeed=0.9

	IconX=458
	IconY=83
	IconWidth=31
	IconHeight=45

	EquipTime=+0.45
	PutDownTime=+0.33

	MaxPitchLag=600
	MaxYawLag=800
	RotChgSpeed=3.0
	ReturnChgSpeed=3.0
	AimingHelpRadius[0]=20.0
	AimingHelpRadius[1]=20.0

	CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs'
	CrossHairCoordinates=(U=192,V=64,UL=64,VL=64)
	IconCoordinates=(U=600,V=341,UL=111,VL=58)
	CrosshairScaling=1.0

	LockedCrossHairCoordinates=(U=406,V=320,UL=76,VL=77)
	StartLockedScale=2.0
	FinalLockedScale=1.0
	LockedScaleTime=0.15
	CurrentLockedScale=1.0

 	ZoomInSound=SoundCue'A_Weapon_Sniper.Sniper.A_Weapon_Sniper_ZoomIn_Cue'
	ZoomOutSound=SoundCue'A_Weapon_Sniper.Sniper.A_Weapon_Sniper_ZoomOut_Cue'

	WeaponCanvasXPct=0.35
	WeaponCanvasYPct=0.35

	bExportMenuData=true
	LockerOffset=(X=0.0,Z=-15.0)

	bUsesOffhand=false

	WidescreenRotationOffset=(Pitch=900)
	HiddenWeaponsOffset=(Y=-50.0,Z=-50.0)
	ProjectileSpawnOffset=20.0
	LastHitEnemyTime=-1000.0

	SmallWeaponsOffset=(X=16.0,Y=6.0,Z=-6.0)
	WideScreenOffsetScaling=0.8
	SimpleCrossHairCoordinates=(U=276,V=84,UL=22,VL=25)

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=30,RightAmplitude=20,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.100)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}
