/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicle extends UDKVehicle
	abstract
	notplaceable
	dependson(UTPlayerController);

/** value for Team property that indicates the vehicle's team hasn't been set */
const UTVEHICLE_UNSET_TEAM = 128;

/** If true the driver will have the flag attached to its model */
var bool bDriverHoldsFlag;

/** Determines if a driver/passenger in this vehicle can carry the flag */
var bool bCanCarryFlag;

/** if true, can be healing target for link gun */
var bool bValidLinkTarget;

/** Sound played if tries to enter a locked vehicle */
var SoundCue VehicleLockedSound;

/** Vehicle is unlocked when a player enters it.. */
var	bool bEnteringUnlocks;

/** Vehicle has special entry radius rules */
var bool bHasCustomEntryRadius;

/** hint for AI and show this vehicle on minimap */
var	repnotify bool bKeyVehicle;

/** what kind of tasks the AI should use this vehicle for */
enum EAIVehiclePurpose
{
	/** use only for offense */
	AIP_Offensive,
	/** use only for defense */
	AIP_Defensive,
	/** suitable for anything */
	AIP_Any,
};
var EAIVehiclePurpose AIPurpose;
/** bots will not try to be a passenger in this vehicle while their objective is this
 * (used for key vehicles that we want to have one bot stay in if possible)
 */
var Actor NoPassengerObjective;

/** true if vehicle must be upright to be entered */
var				bool		bMustBeUpright;

/** Whether can override AVRiL target locks */
var	bool	bOverrideAVRiLLocks;

/** Use stick deflection to determine throttle magnitude (used for console controllers) */
var	bool bStickDeflectionThrottle;

/** When using bStickDeflectionThrottle, how far along Y do you pull stick before you actually reverse. */
var float DeflectionReverseThresh;

/** Whether or not the vehicle can auto center its view pitch.  Some vehicles (e.g. darkwalker) do not want this **/
var bool bShouldAutoCenterViewPitch;

/** HUD should draw weapon bar for this vehicle */
var bool bHasWeaponBar;

/** PhysicalMaterial to use while driving */
var transient PhysicalMaterial DrivingPhysicalMaterial;

/** PhysicalMaterial to use while not driving */
var transient PhysicalMaterial DefaultPhysicalMaterial;

/** The variable can be used to restrict this vehicle from being reset. */
var bool bNeverReset;

/** whether or not bots should leave this vehicle if they encounter enemies */
var bool bShouldLeaveForCombat;

/** whether or not to draw this vehicle's health on the HUD in addition to the driver's health */
var bool bDrawHealthOnHUD;

/** whether or not driver pawn should always cast shadow */
var bool bDriverCastsShadow;

/** whether this vehicle has been driven at any time */
var bool bHasBeenDriven;

/** if set, drop detail when the local player is driving this vehicle (unless in super high detail mode) */
var bool bDropDetailWhenDriving;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/** Track different milestones (in terms of time) for this vehicle */
var float VehicleLostTime, PlayerStartTime;

/** How long vehicle takes to respawn */
var		float           RespawnTime;

/** How long to wait before spawning this vehicle when its factory becomes active */
var		float			InitialSpawnDelay;

/** If > 0, Link Gun secondary heals an amount equal to its damage times this */
var	float LinkHealMult;

var audiocomponent	LinkedToAudio;
var soundcue		LinkedToCue;
var soundcue		LinkedEndSound;

/** How many linkguns are linking to this vehicle */
var protected repnotify byte LinkedToCount;

/** hint for AI */
var float MaxDesireability;

/** The sounds to play when the horn is played */
var array<SoundCue>	HornSounds;
/** radius in which friendly bots respond to the horn by trying to get into any unoccupied seats */
var float HornAIRadius;
/** The time at which the horn was last played */
var float LastHornTime;
/** Horn to play for this vehicle. */
var int HornIndex;

/*********************************************************************************************
 Look Steering
********************************************************************************************* */

/** If true, use 'look to steer' on 'Normal' vehicle control settings.  */
var(LookSteer) bool bLookSteerOnNormalControls;

/** If true, use 'look to steer' on 'Simple' vehicle control settings.  */
var(LookSteer) bool bLookSteerOnSimpleControls;

/** Cached value indicating what style of control we are currently using. */
var	transient bool bUsingLookSteer;

/** When using 'steer to left stick dir', this is a straight ahead dead zone which makes steering directly forwards easier. */
var(LookSteer) float LeftStickDirDeadZone;

/** When bLookToSteer is enabled, relates angle between 'looking' and 'facing' and steering angle. */
var(LookSteer) float LookSteerSensitivity;

var(LookSteer) float LookSteerDamping;

/** When error is more than this, turn on the handbrake. */
var(LookSteer) float LookSteerDeadZone;

/** Increases sensitivity of steering around middle region of controller. */
var(LookSteer) float ConsoleSteerScale;

/** Whether to make sure exit position is near solid ground */
var		bool				bFindGroundExit;

/*********************************************************************************************
 Missile Warnings
********************************************************************************************* */

/** Sound to play when something locks on */
var SoundCue LockedOnSound;

/*********************************************************************************************
 Vehicular Manslaughter / Hijacking
********************************************************************************************* */

/** The Damage type to use when something get's run over */
var class<UTDamageType> RanOverDamageType;

/** Sound to play when someone is run over */
var SoundCue RanOverSound;

/** The Message index for the "Hijack" announcement */
var int StolenAnnouncementIndex;

/** SoundCue to play when someone steals this vehicle */
var SoundCue StolenSound;

/** Quick link to the next vehicle in the chain */
var	UTVehicle NextVehicle;

/** Quick link to the factory that spawned this vehicle */
var	UTVehicleFactory ParentFactory;

/** bot that's about to get in this vehicle */
var	UTBot Reservation;

/** String that describes "In a vehicle name"*/
var localized string VehiclePositionString;

/** The human readable name of this vehicle */
var localized string VehicleNameString;

var ObjectiveAnnouncementInfo NeedToPickUpAnnouncement;

/*********************************************************************************************
 Team beacons
********************************************************************************************* */

/** The maximum distance out that the player info will be displayed */
var float TeamBeaconPlayerInfoMaxDist;

/** Scaling factor used to determine if crosshair might be over this vehicle */
var float HUDExtent;

/** true if pressed use while holding flag for vehicle you can't enter with flag */
var bool bRequestedEntryWithFlag;

/** Damage type it takes when submerged in the water */
var  class<DamageType> VehicleDrowningDamType;

/** Class of ExplosionLight */
var class<UDKExplosionLight> ExplosionLightClass;

/** Max distance to create ExplosionLight */
var float	MaxExplosionLightDistance;


/** set after attaching vehicle effects, as this is delayed slightly to allow time for team info to be set */
var bool bInitializedVehicleEffects;

/**
 * This is a reference to the Emitter we spawn on death.  We need to keep a ref to it (briefly) so we can
 * turn off the particle system when the vehicle decided to burnout.
 **/
var Emitter DeathExplosion;

/**
 * How long to wait after the InitialVehicleExplosion before doing the Secondary VehicleExplosion (if it already has not happened)
 * (e.g. due to the vehicle falling from the air and hitting the ground and doing it's secondary explosion that way).
 **/
var float TimeTilSecondaryVehicleExplosion;

/** client-side health for morph targets. Used to adjust everything to the replicated Health whenever we receive it */
var int ClientHealth;

/** The Team Skins (0 = red/unknown, 1 = blue)*/
var array<MaterialInterface> TeamMaterials;

/** class to spawn for blown off vehicle pieces */
var class<UTGib_Vehicle> VehiclePieceClass;

/*********************************************************************************************
 Smoke and Fire
********************************************************************************************* */

/** The health ratio threshold at which the vehicle will begin smoking */
var float DamageSmokeThreshold;

/** If true, driver is thrown from vehicle as ragdoll by darkwalker horn. */
var() bool bRagdollDriverOnDarkwalkerHorn;

/*********************************************************************************************
 Misc
********************************************************************************************* */

/** The Damage Type of the explosion when the vehicle is upside down */
var class<DamageType> ExplosionDamageType;

/** The maximum distance out where an impact effect will be spawned */
var float MaxImpactEffectDistance;

/** The maximum distance out where a fire effect will be spawned */
var float MaxFireEffectDistance;

/** Templates used for explosions */
var ParticleSystem ExplosionTemplate;
var array<DistanceBasedParticleTemplate> BigExplosionTemplates;
/** Secondary explosions from vehicles.  (usually just dust when they are impacting something) **/
var ParticleSystem SecondaryExplosion;

/** socket to attach big explosion to (if 'None' it won't be attached at all) */
var name BigExplosionSocket;

/** How long does it take to burn out */
var float BurnOutTime;

/** How long should the vehicle should last after being destroyed */
var float DeadVehicleLifeSpan;

/** How many times burnout has been delayed */
var int DelayedBurnoutCount;

/** Damage/Radius/Momentum parameters for dying explosions */
var float ExplosionDamage, ExplosionRadius, ExplosionMomentum;
/** If vehicle dies in the air, this is how much spin is given to it. */
var float ExplosionInAirAngVel;
/** camera shake for players near the vehicle when it explodes */
var CameraAnim DeathExplosionShake;
/** radius at which the death camera shake is full intensity */
var float InnerExplosionShakeRadius;
/** radius at which the death camera shake reaches zero intensity */
var float OuterExplosionShakeRadius;

/** Whether or not there is a turret explosion sequence on death */
var bool bHasTurretExplosion;
/** Name of the turret skel control to scale the turret to nothing*/
var name TurretScaleControlName;
/** Name of the socket location to spawn the explosion effect for the turret blowing up*/
var name TurretSocketName;
/** Explosion of the turret*/
var array<DistanceBasedParticleTemplate> DistanceTurretExplosionTemplates;

/** The offset from the TurretSocketName to spawn the turret*/
var vector TurretOffset;
/** Reference to destroyed turret for death effects */
var UTVehicleDeathPiece DestroyedTurret;
/** Class to spawn when turret destroyed */
var StaticMesh DestroyedTurretTemplate;
/** Force applied to the turret explosion */
var float TurretExplosiveForce;

/** sound for dying explosion */
var SoundCue ExplosionSound;


/** names of material parameters for burnout material effect */
var name BurnTimeParameterName;

/** This is used to determine a safe zone around the spawn point of the vehicle.  It won't spawn until this zone is clear of pawns */
var float	SpawnRadius;

/** Sound to play when spawning in */
var SoundCue SpawnInSound;

/** Sound to play when despawning */
var SoundCue SpawnOutSound;

/** Sound to play when going over a boost pad. */
var SoundCue BoostPadSound;

/*********************************************************************************************
 Flag carrying
********************************************************************************************* */
var(Flag) vector	FlagOffset;
var(Flag) rotator	FlagRotation;
var(Flag) name		FlagBone;

/*********************************************************************************************
 HUD Beacon
********************************************************************************************* */

var float MapSize;

/** Coordiates of the icon associated with this object */
var TextureCoordinates IconCoords;
var TextureCoordinates FlipToolTipIconCoords;
var TextureCoordinates EnterToolTipIconCoords;
var TextureCoordinates DropFlagIconCoords;
var TextureCoordinates DropOrbIconCoords;

/** true is last trace test check for drawing postrender hud icons succeeded */
var bool bPostRenderTraceSucceeded;

var int LastHealth;
var float HealthPulseTime;

/** offset for team beacon */
var vector TeamBeaconOffset;

/** PRI of player in passenger turret */
var PlayerReplicationInfo PassengerPRI;

/** offset for passenger team beacon */
var vector PassengerTeamBeaconOffset;


/*********************************************************************************************
 HUD
********************************************************************************************* */

var Texture2D HudIcons;
var TextureCoordinates HudCoords;

/** Team specific effect played when the vehicle is spawned */
var array<ParticleSystem> SpawnInTemplates;

/** team specific materials to apply when spawning in */
struct native MaterialList
{
	var array<MaterialInterface> Materials;
};
var array<MaterialList> SpawnMaterialLists;
/** parameter for the spawn material */
var name SpawnMaterialParameterName;
var InterpCurveFloat SpawnMaterialParameterCurve;
/** list of Mesh's original materials when playing spawn effect so we can restore them afterwards */
var array<MaterialInterface> OriginalMaterials;
/** How long is the SpawnIn effect */
var float SpawnInTime;
/** whether we're currently playing the spawn effect */
var repnotify bool bPlayingSpawnEffect;

/** Burn out material (per team) */
var MaterialInterface BurnOutMaterial[2];

/** multiplier to damage from colliding with other rigid bodies */
var float CollisionDamageMult;

/** last time we took collision damage, so we don't take collision damage multiple times in the same tick */
var float LastCollisionDamageTime;

/** if true, collision damage is reduced when the vehicle collided with something below it */
var bool bReducedFallingCollisionDamage;

/*********************************************************************************************
 Camera
********************************************************************************************* */

var(Seats)	float	SeatCameraScale;

/** If true, this will allow the camera to rotate under the vehicle which may obscure the view */
var(Camera)	bool bRotateCameraUnderVehicle;

/** If true, don't Z smooth lagged camera (for bumpier looking ride */
var bool bNoZSmoothing;

/** If true, make sure camera z stays above vehicle when looking up (to avoid clipping when flying vehicle going up) */
var bool bLimitCameraZLookingUp;

/** If true, don't change Z while jumping, for more dramatic looking jumps */
var bool bNoFollowJumpZ;

/** Used only if bNoFollowJumpZ=true.  True when Camera Z is being fixed. */
var bool bFixedCamZ;

/** Used only if bNoFollowJumpZ=true.  saves the Camera Z position from the previous tick. */
var float OldCamPosZ;

/** Smoothing scale for lagged camera - higher values = shorter smoothing time. */
var float CameraSmoothingFactor;

/** FOV to use when driving this vehicle */
var float DefaultFOV;

/** Saved Camera positions (for lagging camera) */
struct native TimePosition
{
	var vector Position;
	var float Time;
};
var array<TimePosition> OldPositions;

/** Amount of camera lag for this vehicle (in seconds */
var float CameraLag;

/** Smoothed Camera Offset */
var vector CameraOffset;

/** How far forward to bring camera if looking over nose of vehicle */
var(Camera) float LookForwardDist;

/** hide vehicle if camera is too close */
var	float	MinCameraDistSq;

var bool bCameraNeverHidesVehicle;

/** Stop death camera using OldCameraPosition if true */
var bool bStopDeathCamera;

/** OldCameraPosition saved when dead for use if fall below killz */
var vector OldCameraPosition;

/** for player controlled !bSeparateTurretFocus vehicles on console, this is updated to indicate whether the controller is currently turning
 * (server and owning client only)
 */
var bool bIsConsoleTurning;

/** Whether to accept jump from UTWeaponPawns */
var bool bAcceptTurretJump;

/*********************************************************************************************/

var bool bShowDamageDebug;

/** This vehicle should display the <Locked> cusrsor */
var bool bStealthVehicle;

// how long it takes to restart this vehicle when disabled.
var() float DisabledTime;

// The time at which the last EMP grenade hit this vehicle.
var float TimeLastDisabled;

/** effect played when disabled */
var ParticleSystem DisabledTemplate;
/** component that holds the disabled effect (created dynamically) */
var ParticleSystemComponent DisabledEffectComponent;

/*********************************************************************************************/

/** Reference Mesh for the movement effect on seats*/
var StaticMesh ReferenceMovementMesh;

/** bot voice message support */
var bool bHasEnemyVehicleSound;
var float LastEnemyWarningTime;
var array<SoundNodeWave> EnemyVehicleSound;
var array<SoundNodeWave> VehicleDestroyedSound;

/** True if is Necris vehicle (used by single player campaign) */
var bool bIsNecrisVehicle;

/** true if being spectated (set temporarily in UTPlayerController.GetPlayerViewPoint() */
var bool bSpectatedView;

replication
{
	if (bNetDirty)
		bPlayingSpawnEffect, PassengerPRI, LinkedToCount, bKeyVehicle;
}

/**
 * Initialization
 */
simulated function PostBeginPlay()
{
	local PlayerController PC;

	super.PostBeginPlay();

	ClientHealth = Health;
	LastHealth = Health;

	if (Role==ROLE_Authority)
	{
		if ( !bDeleteMe && UTGame(WorldInfo.Game) != None )
		{
			UTGame(WorldInfo.Game).RegisterVehicle(self);
		}

		// Setup the Seats array
		InitializeSeats();
	}
	else if (Seats.length > 0)
	{
		// Insure our reference to self is always setup
		Seats[0].SeatPawn = self;
	}

	PreCacheSeatNames();

	InitializeTurrets();		// Setup the turrets
	SetTimer(0.01, false, 'InitializeEffects');		// Setup any effects for this vehicle
	InitializeMorphs();			// Setup the damage morph targets

	// add to local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( PC.MyHUD != None )
		{
			PC.MyHUD.AddPostRenderedActor(self);
		}
	}
	if ( bKeyVehicle )
		UTMapInfo(WorldInfo.GetMapInfo()).AddKeyVehicle(self);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		UpdateShadowSettings(!class'Engine'.static.IsSplitScreen() && class'UTPlayerController'.Default.PawnShadowMode == SHADOW_All);
		CreateDamageMaterialInstance();
	}

	VehicleEvent('Created');
}

simulated function UpdateShadowSettings(bool bWantShadow)
{
	local bool bNewCastShadow, bNewCastDynamicShadow;

	if (Mesh != None)
	{
		bNewCastShadow = default.Mesh.CastShadow && bWantShadow;
		bNewCastDynamicShadow = default.Mesh.bCastDynamicShadow && bWantShadow;
		if (bNewCastShadow != Mesh.CastShadow || bNewCastDynamicShadow != Mesh.bCastDynamicShadow)
		{
			Mesh.CastShadow = bNewCastShadow;
			Mesh.bCastDynamicShadow = bNewCastDynamicShadow;
			// defer if we can do so without it being noticeable
			if (LastRenderTime < WorldInfo.TimeSeconds - 1.0)
			{
				SetTimer(0.1 + FRand() * 0.5, false, 'ReattachMesh');
			}
			else
			{
				ReattachMesh();
			}
		}
	}
}

/** reattaches the mesh component, because settings were updated */
simulated function ReattachMesh()
{
	DetachComponent(Mesh);
	AttachComponent(Mesh);
}

simulated function CreateDamageMaterialInstance()
{
	DamageMaterialInstance[0] = Mesh.CreateAndSetMaterialInstanceConstant(0);
}

simulated function UpdateLookSteerStatus()
{
	local UTPlayerController UTPC;

	UTPC = UTPlayerController(Controller);
	// If no player, or not a human player
	if( UTPC == None ||
		UTPC.VehicleControlType == UTVC_Advanced ||
		(UTPC.VehicleControlType == UTVC_Normal && !bLookSteerOnNormalControls) ||
		(UTPC.VehicleControlType == UTVC_Simple && !bLookSteerOnSimpleControls) )
	{
		bUsingLookSteer = FALSE;
	}
	else
	{
		bUsingLookSteer = TRUE;
	}
}

/**
 * Console specific input modification
 */
simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
	local bool bReverseThrottle;
	local UTConsolePlayerController ConsolePC;
	local rotator SteerRot, VehicleRot;
	local vector SteerDir, VehicleDir, AngVel;
	local float VehicleHeading, SteerHeading, DeltaTargetHeading, Deflection;

	Throttle = InForward;
	Steering = InStrafe;
	Rise = InUp;

	ConsolePC = UTConsolePlayerController(Controller);
	if (ConsolePC != None)
	{
		Steering = FClamp(Steering * ConsoleSteerScale, -1.0, 1.0);

		UpdateLookSteerStatus();

		// tank, wheeled / heavy vehicles will use this

		// If we desire 'look steering' on this vehicle, do it here.
		if (bUsingLookSteer && IsHumanControlled())
		{
			// If there is a deflection, look at the angle that its point in.
			Deflection = Sqrt(Throttle*Throttle + Steering*Steering);

			if(bStickDeflectionThrottle)
			{
				// The region we consider 'reverse' is anything below DeflectionReverseThresh, or anything withing the triangle below the center position.
				bReverseThrottle = ((Throttle < DeflectionReverseThresh) || (Throttle < 0.0 && Abs(Steering) < -Throttle));
				Throttle = Deflection;

				if (bReverseThrottle)
				{
					Throttle *= -1;
				}
			}

			VehicleRot.Yaw = Rotation.Yaw;
			VehicleDir = vector(VehicleRot);

			SteerRot.Yaw = DriverViewYaw;
			SteerDir = vector(SteerRot);

			VehicleHeading = GetHeadingAngle(VehicleDir);
			SteerHeading = GetHeadingAngle(SteerDir);
			DeltaTargetHeading = FindDeltaAngle(SteerHeading, VehicleHeading);

			if (DeltaTargetHeading > LookSteerDeadZone)
			{
				Steering = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
			}
			else if (DeltaTargetHeading < -LookSteerDeadZone)
			{
				Steering = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
			}
			else
			{
				Steering = 0.0;
			}

			AngVel = Mesh.BodyInstance.GetUnrealWorldAngularVelocity();

			Steering = FClamp(Steering + (AngVel.Z * LookSteerDamping), -1.0, 1.0);

			// Reverse steering when reversing
			if (Throttle < 0.0 && ForwardVel < 0.0)
			{
				Steering = -1.0 * Steering;
			}
		}
		// flying hovering vehicles will use this
		else
		{
			//`log( " flying hovering vehicle" );
			if (bStickDeflectionThrottle)
			{
				// The region we consider 'reverse' is anything below DeflectionReverseThresh, or anything withing the triangle below the center position.
				bReverseThrottle = ((Throttle < DeflectionReverseThresh) || (Throttle < 0.0 && Abs(Steering) < -Throttle));

				Deflection = Sqrt(Throttle*Throttle + Steering*Steering);
				Throttle = Deflection;

				if (bReverseThrottle)
				{
					Throttle *= -1;
				}
			}
		}

		//`log( "Throttle: " $ Throttle $ " Steering: " $ Steering );
	}
}

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
    super.FellOutOfWorld(DmgType);
    bStopDeathCamera = true;
}

simulated function float GetChargePower();

simulated function PlaySpawnEffect()
{
	local MaterialInstanceTimeVarying SpawnMaterialInstance;
	local int i;

	if (!IsTimerActive('StopSpawnEffect')) //@note: don't check bPlayingSpawnEffect here because that's already true on the client
	{
		bPlayingSpawnEffect = true;
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			// spawn emitter
			if (Team < SpawnInTemplates.length)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(SpawnInTemplates[Team], Location, Rotation);
			}
			else if (SpawnInTemplates.length > 0)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(SpawnInTemplates[0], Location, Rotation);
			}
			// set spawn materials
			if (Team < SpawnMaterialLists.length)
			{
				for (i = 0; i < Mesh.GetNumElements() && i < SpawnMaterialLists[Team].Materials.length; i++)
				{
					OriginalMaterials[i] = Mesh.GetMaterial(i);
					SpawnMaterialInstance = new(self) class'MaterialInstanceTimeVarying';
					SpawnMaterialInstance.SetParent(SpawnMaterialLists[Team].Materials[i]);
					SpawnMaterialInstance.SetScalarCurveParameterValue(SpawnMaterialParameterName, SpawnMaterialParameterCurve);
					Mesh.SetMaterial(i, SpawnMaterialInstance);
					SpawnMaterialInstance.SetScalarStartTime(SpawnMaterialParameterName, 0.0);
					//`log( "SpawnMaterialInstance: " $ SpawnMaterialInstance $ " P: " $ SpawnMaterialLists[Team].Materials[i] $ " PP: " $ MaterialInstance(SpawnMaterialLists[Team].Materials[i]).Parent );
				}
			}

			if (SpawnInSound != None)
			{
				PlaySound(SpawnInSound, true);
			}
		}
		SetTimer(SpawnInTime, false, 'StopSpawnEffect');
	}
}

simulated function StopSpawnEffect()
{
	local int i;

	bPlayingSpawnEffect = false;
	for (i = 0; i < OriginalMaterials.length; i++)
	{
		Mesh.SetMaterial(i, OriginalMaterials[i]);
	}
	ClearTimer('StopSpawnEffect');
}

function EjectSeat(int SeatIdx)
{
	local UDKVehicleBase VB;
	
	bShouldEject=true;
	if(SeatIdx == 0)
	{
		DriverLeave(true);
	}
	else
	{
		VB = UDKVehicleBase(Seats[SeatIdx].SeatPawn);
		if(VB != none)
		{
			VB.bShouldEject = true;
			VB.DriverLeave(true);
		}
	}
}

/**
  * Returns damagetype to use for deaths caused by being run over by this vehicle
  */
function class<DamageType> GetRanOverDamageType()
{
	return RanOverDamageType;
}

function DisplayWeaponBar(Canvas canvas, UTHUD HUD);


simulated static function DrawKillIcon(Canvas Canvas, float ScreenX, float ScreenY, float HUDScaleX, float HUDScaleY)
{
	local color CanvasColor;

	`log("### DrawKillIcon");

	// save current canvas color
	CanvasColor = Canvas.DrawColor;

	// draw vehicle shadow
	Canvas.DrawColor = class'UTHUD'.default.BlackColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX - 2, ScreenY - 2 );
	Canvas.DrawTile(class'UTHUD'.default.IconHudTexture, 4 + HUDScaleX * 96, 4 + HUDScaleY * 64, default.IconCoords.U, default.IconCoords.V, default.IconCoords.UL, default.IconCoords.VL);

	// draw the vehicle icon
	Canvas.DrawColor =  class'UTHUD'.default.WhiteColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX, ScreenY );
   	Canvas.DrawTile(class'UTHUD'.default.IconHudTexture, HUDScaleX * 96, HUDScaleY * 64, default.IconCoords.U, default.IconCoords.V, default.IconCoords.UL, default.IconCoords.VL);
	Canvas.DrawColor = CanvasColor;
}

/**
 * When an icon for this vehicle is needed on the hud, this function is called
 */
simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, LinearColor FinalColor)
{
	local LinearColor DrawColor;
	DrawColor = MakeLinearColor(0,0,0,0.6);
	MP.DrawRotatedTile(Canvas,class'UTHUD'.default.IconHudTexture, HUDLocation, Rotation.Yaw + 16384, MapSize * 1.05, IconCoords, DrawColor);
	FinalColor.A = 0.6;
	MP.DrawRotatedTile(Canvas,class'UTHUD'.default.IconHudTexture, HUDLocation, Rotation.Yaw + 16384, MapSize, IconCoords, FinalColor);
}

/**
 * ContinueOnFoot() - used by AI Called from route finding if route can only be continued on foot.
 * @Returns true if driver left vehicle
 */
event bool ContinueOnFoot()
{
	local UTBot B;

	B = UTBot(Controller);
	if (B == None)
	{
		return Super.ContinueOnFoot();
	}
	else if (B.Squad == None || UTSquadAI(B.Squad).AllowContinueOnFoot(B, self))
	{
		B.NoVehicleGoal = B.RouteGoal;
		if (B.RouteCache.Length > 0 && B.RouteCache[0] != None)
		{
			B.DirectionHint = Normal(B.RouteCache[0].Location - Location);
		}

		B.LeaveVehicle(false);
		return true;
	}
	else
	{
		return false;
	}
}

/** @return whether the given vehicle pawn is in this vehicle's driver seat
 * (usually seat 0, but some vehicles may give driver control of a different seat when deployed)
 */
function bool IsDriverSeat(Vehicle TestSeatPawn)
{
	return (Seats[0].SeatPawn == TestSeatPawn);
}

function bool RecommendCharge(UTBot B, Pawn Enemy)
{
	return false;
}

/** Recommend high priority charge at enemy */
function bool CriticalChargeAttack(UTBot B)
{
	return false;
}

/************************************************************************************
 * Effects
 ***********************************************************************************/

simulated function CreateVehicleEffect(int EffectIndex)
{
	VehicleEffects[EffectIndex].EffectRef = new(self) class'UTParticleSystemComponent';
	if (VehicleEffects[EffectIndex].EffectStartTag != 'BeginPlay')
	{
		VehicleEffects[EffectIndex].EffectRef.bAutoActivate = false;
	}

	// if we have a blue particle system and we are on the blue team
	if (VehicleEffects[EffectIndex].EffectTemplate_Blue != None && GetTeamNum() == 1)
	{
		VehicleEffects[EffectIndex].EffectRef.SetTemplate(VehicleEffects[EffectIndex].EffectTemplate_Blue);
	}
	// use the default template which will be red or some neutral color
	else
	{
		VehicleEffects[EffectIndex].EffectRef.SetTemplate(VehicleEffects[EffectIndex].EffectTemplate);
	}

	Mesh.AttachComponentToSocket(VehicleEffects[EffectIndex].EffectRef, VehicleEffects[EffectIndex].EffectSocket);
}

/**
 * Initialize the effects system.  Create all the needed PSCs and set their templates
 */
simulated function InitializeEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && !bInitializedVehicleEffects)
	{
		bInitializedVehicleEffects = true;
		TriggerVehicleEffect('BeginPlay');
	}
}

/**
 * Whenever a vehicle effect is triggered, this function is called (after activation) to allow for the
 * setting of any parameters associated with the effect.
 *
 * @param	TriggerName		The effect tag that describes the effect that was activated
 * @param	PSC				The Particle System component associated with the effect
 */
simulated function SetVehicleEffectParms(name TriggerName, ParticleSystemComponent PSC)
{
	local float Pct;

	if (TriggerName == 'DamageSmoke')
	{
		Pct = float(Health) / float(HealthMax);
		PSC.SetFloatParameter('smokeamount', (Pct < DamageSmokeThreshold) ? (1.0 - Pct) : 0.0);
		PSC.SetFloatParameter('fireamount', (Pct < FireDamageThreshold) ? (1.0 - Pct) : 0.0);
	}
}

/**
 * Trigger or untrigger a vehicle effect
 *
 * @param	EventTag	The tag that describes the effect
 *
 */
simulated function TriggerVehicleEffect(name EventTag)
{
	local int i;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < VehicleEffects.length; i++)
		{
			if (VehicleEffects[i].EffectStartTag == EventTag)
			{
				if ( !VehicleEffects[i].bHighDetailOnly || (WorldInfo.GetDetailMode() == DM_High) )
				{
					if (VehicleEffects[i].EffectRef == None)
					{
						CreateVehicleEffect(i);
					}
					if (VehicleEffects[i].bRestartRunning)
					{
						VehicleEffects[i].EffectRef.KillParticlesForced();
						VehicleEffects[i].EffectRef.ActivateSystem();
					}
					else if (!VehicleEffects[i].EffectRef.bIsActive)
					{
						VehicleEffects[i].EffectRef.ActivateSystem();
					}

					SetVehicleEffectParms(EventTag, VehicleEffects[i].EffectRef);
				}
			}
			else if (VehicleEffects[i].EffectRef != None && VehicleEffects[i].EffectEndTag == EventTag)
			{
				VehicleEffects[i].EffectRef.DeActivateSystem();
			}
		}
	}
}

/**
 * Trigger or untrigger a vehicle sound
 *
 * @param	EventTag	The tag that describes the effect
 *
 */
simulated function PlayVehicleSound(name SoundTag)
{
	local int i;
	for(i=0;i<VehicleSounds.Length;++i)
	{
		if(VehicleSounds[i].SoundEndTag == SoundTag)
		{
			if(VehicleSounds[i].SoundRef != none)
			{
				VehicleSounds[i].SoundRef.Stop();
				VehicleSounds[i].SoundRef = none;
			}
		}
		if(VehicleSounds[i].SoundStartTag == SoundTag)
		{
			if(VehicleSounds[i].SoundRef == none)
			{
				VehicleSounds[i].SoundRef = CreateAudioComponent(VehicleSounds[i].SoundTemplate, false, true);
			}
			if(VehicleSounds[i].SoundRef != none && (!VehicleSounds[i].SoundRef.bWasPlaying || VehicleSounds[i].SoundRef.bFinished))
			{
				VehicleSounds[i].SoundRef.Play();
			}
		}
	}
}
/**
 * Plays a Vehicle Animation
 */
simulated function PlayVehicleAnimation(name EventTag)
{
	local int i;
	local UTAnimNodeSequence Player;

	if ( Mesh != none && mesh.Animations != none && VehicleAnims.Length > 0 )
	{
		for (i=0;i<VehicleAnims.Length;i++)
		{
			if (VehicleAnims[i].AnimTag == EventTag)
			{
				Player = UTAnimNodeSequence(Mesh.Animations.FindAnimNode(VehicleAnims[i].AnimPlayerName));
				if ( Player != none )
				{
					Player.PlayAnimationSet( VehicleAnims[i].AnimSeqs,
												VehicleAnims[i].AnimRate,
												VehicleAnims[i].bAnimLoopLastSeq );
				}
			}
		}
	}
}

/**
 * An interface for causing various events on the vehicle.
 */
simulated function VehicleEvent(name EventTag)
{
	// Cause/kill any effects
	TriggerVehicleEffect(EventTag);

	// Play any animations
	PlayVehicleAnimation(EventTag);

	PlayVehicleSound(EventTag);
}


/**
 * EntryAnnouncement() - Called when Controller possesses vehicle, for any visual/audio effects
 *
 * @param	C		The controller of that possessed the vehicle
 */
simulated function EntryAnnouncement(Controller C)
{
	Super.EntryAnnouncement(C);

	if ( Role < ROLE_Authority )
		return;

	// If Stole another team's vehicle, set Team to new owner's team
	if( (C != none) && WorldInfo.Game.bTeamGame )
	{
		if ( Team != C.GetTeamNum() )
		{
			//add stat tracking event/variable here?
			if ( Team != 255 && PlayerController(C) != None )
			{
				PlayerController(C).ReceiveLocalizedMessage( class'UTVehicleMessage', StolenAnnouncementIndex);
				UTPlayerReplicationInfo(C.PlayerReplicationInfo).IncrementEventStat('EVENT_HIJACKED');
				if( StolenSound != None )
					PlaySound(StolenSound);
			}
			if ( C.GetTeamNum() != 255 )
				SetTeamNum( C.GetTeamNum() );
		}
	}
}

/**
  * Returns rotation used for determining valid exit positions
  */
function Rotator ExitRotation()
{
	return Rotation;
}

/**
 * FindAutoExit() Tries to find exit position on either side of vehicle, in back, or in front
 * returns true if driver successfully exited.
 *
 * @param	ExitingDriver	The Pawn that is leaving the vehicle
 */
function bool FindAutoExit(Pawn ExitingDriver)
{
	local vector X, Y, Z, DirectionHint;
	local float PlaceDist;

	GetAxes(ExitRotation(), X,Y,Z);
	Y *= -1;

	if ( ExitRadius == 0 )
	{
		ExitRadius = CylinderComponent.CollisionRadius + 2*ExitingDriver.GetCollisionRadius();
	}
	PlaceDist = ExitRadius + ExitingDriver.GetCollisionRadius();

	if ( Controller != None )
	{
		if ( UTBot(ExitingDriver.Controller) != None )
		{
			// bot picks which side he'd prefer to get out on (since bots are bad at running around vehicles)
			DirectionHint = UTBot(ExitingDriver.Controller).GetDirectionHint();
			if (IsZero(DirectionHint))
			{
				// try to guess based on AI's current path
				if (ExitingDriver.Controller.MoveTarget != Anchor)
				{
					DirectionHint = Normal(ExitingDriver.Controller.MoveTarget.Location - Location);
				}
				else if (ExitingDriver.Controller.RouteCache.length > 1 && ExitingDriver.Controller.RouteCache[1] != None)
				{
					DirectionHint = Normal(ExitingDriver.Controller.RouteCache[1].Location - Location);
				}
				else if (ExitingDriver.Controller.RouteGoal != None)
				{
					DirectionHint = Normal(ExitingDriver.Controller.RouteGoal.Location - Location);
				}
			}
			if (DirectionHint Dot Y < 0.0)
			{
				Y *= -1;
			}
			if (DirectionHint Dot X < 0.0)
			{
				X *= -1;
			}
		}
		else
		{
			// use the controller's rotation as a hint
			if ( (Y dot vector(Controller.Rotation)) < 0 )
			{
				Y *= -1;
			}
		}
	}

	if ( VSize(Velocity) > MinCrushSpeed )
	{
		//avoid running driver over by placing in direction away from velocity
		if ( (Velocity Dot X) < 0 )
			X *= -1;
		// check if going sideways fast enough
		if ( (Velocity Dot Y) > MinCrushSpeed )
			Y *= -1;
	}

	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * Y), bFindGroundExit) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) - (PlaceDist * Y), bFindGroundExit) )
		return true;

	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) - (PlaceDist * X), false) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * X), false) )
		return true;
	if ( !bFindGroundExit )
		return false;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * Y), false) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) - (PlaceDist * Y), false) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * Z), false) )
		return true;

	return false;
}

/**
 * RanInto() called for encroaching actors which successfully moved the other actor out of the way
 *
 * @param	Other 		The pawn that was hit
 */
event RanInto(Actor Other)
{
	local vector Momentum;
	local float Speed;
	local class<UDKEmitCameraEffect> CameraEffect;

	if ( Pawn(Other) == None || (Vehicle(Other) != None && !Other.IsA('UTVehicle_Hoverboard')) || Other == Instigator || Other.Role != ROLE_Authority )
		return;

	Speed = VSize(Velocity);
	if (Speed > MinRunOverSpeed)
	{
		Momentum = Velocity * 0.25 * Pawn(Other).Mass;
		if ( RanOverSound != None )
			PlaySound(RanOverSound);

		if ( WorldInfo.GRI.OnSameTeam(self,Other) )
		{
			Momentum += Speed * 0.25 * Pawn(Other).Mass * Normal(Velocity cross vect(0,0,1));
		}
		else
		{
			Other.TakeDamage(int(Speed * 0.075), GetCollisionDamageInstigator(), Other.Location, Momentum, RanOverDamageType);

			if (Pawn(Other).Health <= 0 && UTPlayerController(Controller) != none)
			{
				CameraEffect = RanOverDamageType.static.GetDeathCameraEffectInstigator(UTPawn(Other));
				if (CameraEffect != None)
				{
					UTPlayerController(Controller).ClientSpawnCameraEffect(CameraEffect);
				}
			}
		}
	}
}

function PancakeOther(Pawn Other)
{
	Other.TakeDamage(10000, GetCollisionDamageInstigator(), Other.Location, Velocity * Other.Mass, CrushedDamageType);
}

/**
 * TakeWaterDamage() called every tick when AccumulatedWaterDamage>0 and PhysicsVolume.bWaterVolume=true
 *
 * @param	DeltaTime		The amount of time passed since it was last called
 */
event TakeWaterDamage()
{
	local int ImpartedWaterDamage;

	ImpartedWaterDamage = AccumulatedWaterDamage;
	AccumulatedWaterDamage -= ImpartedWaterDamage;
	TakeDamage(ImpartedWaterDamage, Controller, Location, vect(0,0,0), VehicleDrowningDamType);
}

/**
 * This function is called to see if radius damage should be applied to the driver.  It is called
 * from SVehicle::TakeRadiusDamage().
 *
 * @param	DamageAmount		The amount of damage taken
 * @param	DamageRadius		The radius that the damage covered
 * @param	EventInstigator		Who caused the damage
 * @param	DamageType			What type of damage
 * @param	Momentum			How much force should be imparted
 * @param	HitLocation			Where
 */
function DriverRadiusDamage( float DamageAmount, float DamageRadius, Controller EventInstigator,
				class<DamageType> DamageType, float Momentum, vector HitLocation, Actor DamageCauser, optional float DamageFalloffExponent=1.f)
{
	local int i;
	local Vehicle V;

	if ( bDriverIsVisible )
	{
		Super.DriverRadiusDamage(DamageAmount, DamageRadius, EventInstigator, DamageType, Momentum, HitLocation, DamageCauser, DamageFalloffExponent);
	}

	// pass damage to seats as well but skip seats[0] since that is us and was already handled by the Super

	for (i = 1; i < Seats.length; i++)
	{
		V = Seats[i].SeatPawn;
		if( ( V != none ) && ( V.bDriverIsVisible ) )
		{
			V.DriverRadiusDamage(DamageAmount, DamageRadius, EventInstigator, DamageType, Momentum, HitLocation, DamageCauser, DamageFalloffExponent);
		}
	}

}

/**
 * Called when the vehicle is destroyed.  Clean up the seats/effects/etc
 */
simulated function Destroyed()
{
	local UTVehicle	V, Prev;
	local int i;
	local PlayerController PC;

	for(i=1;i<Seats.Length;i++)
	{
   		if ( Seats[i].SeatPawn != None )
   		{
   			if (Seats[i].SeatPawn.Controller != None)
   			{
   				`Warn(self @ "destroying seat" @ i @ "still controlled by" @ Seats[i].SeatPawn.Controller @ Seats[i].SeatPawn.Controller.GetHumanReadableName());
   			}
			Seats[i].SeatPawn.Destroy();
		}
		if (Seats[i].SeatMovementEffect != None)
		{
			SetMovementEffect(i, false);
		}
	}
	if ( ParentFactory != None )
		ParentFactory.VehicleDestroyed( Self );		// Notify parent factory of death

	if ( UTGame(WorldInfo.Game) != None )
	{
		if ( UTGame(WorldInfo.Game).VehicleList == Self )
			UTGame(WorldInfo.Game).VehicleList = NextVehicle;
		else
		{
			Prev = UTGame(WorldInfo.Game).VehicleList;
			if ( Prev != None )
				for ( V=UTGame(WorldInfo.Game).VehicleList.NextVehicle; V!=None; V=V.NextVehicle )
				{
					if ( V == self )
					{
						Prev.NextVehicle = NextVehicle;
						break;
					}
					else
						Prev = V;
				}
		}
	}

	SetTexturesToBeResident( FALSE );

	super.Destroyed();

	// remove from local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
		if ( PC.MyHUD != None )
			PC.MyHUD.RemovePostRenderedActor(self);
}


/** This will set the textures to be resident or not **/
simulated function SetTexturesToBeResident( bool bActive )
{
	local int i;
	local int NumElems;
	local MaterialInterface Material;

	// reset all of the textures to not be resident
	NumElems = Mesh.GetNumElements();
	for (i = 0; i < NumElems; i++)
	{
		Material = Mesh.GetMaterial(i);
		if (Material != None)
		{
			Material.SetForceMipLevelsToBeResident(true, bActive, -1.0f);
		}
	}
}


simulated function bool DisableVehicle()
{
	local int seatIdx;

	if ( Occupied() )
	{
		bIsDisabled = true;

		if (Role == ROLE_Authority)
		{
			SetTimer(DisabledTime, false, 'EnableVehicle');

			// everybody out!
			if (bDriving)
			{
				DriverLeave(true);
			}
			for (seatIdx = 0; seatIdx < seats.Length; ++seatIdx)
			{
				if (Seats[seatIdx].SeatPawn != None && Seats[SeatIdx].SeatPawn.bDriving)
				{
					Seats[seatIdx].SeatPawn.DriverLeave(true); // and all the passengers
				}
			}
		}

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			if (DisabledEffectComponent == None)
			{
				DisabledEffectComponent = new(self) class'ParticleSystemComponent';
				DisabledEffectComponent.SetTemplate(DisabledTemplate);
				AttachComponent(DisabledEffectComponent);
			}
			DisabledEffectComponent.ActivateSystem();
		}
		return true;
	}
	return false;
}

simulated function EnableVehicle()
{
	bIsDisabled = false;
	if (WorldInfo.NetMode != NM_DedicatedServer && DisabledEffectComponent != None)
	{
		DetachComponent(DisabledEffectComponent);
		DisabledEffectComponent = None;
	}
}

/**
 * This event occurs when the physics determines the vehicle is upside down or empty and on fire.  Called from AUTVehicle::TickSpecial()
 */
event TakeFireDamage()
{
	local int CurrentDamage;

	CurrentDamage = int(AccruedFireDamage);
	AccruedFireDamage -= CurrentDamage;
	TakeDamage(CurrentDamage, Controller, Location, vect(0,0,0), ExplosionDamageType);
}

/**
 * Given the variable prefix, find the seat index that is associated with it
 *
 * @returns the index if found or -1 if not found
 */

simulated function int GetSeatIndexFromPrefix(string Prefix)
{
	local int i;

	for (i=0; i < Seats.Length; i++)
	{
		if (Seats[i].TurretVarPrefix ~= Prefix)
		{
			return i;
		}
	}
	return -1;
}

/** used on console builds to set the value of bIsConsoleTurning on the server */
reliable server function ServerSetConsoleTurning(bool bNewConsoleTurning)
{
	bIsConsoleTurning = bNewConsoleTurning;
}

simulated function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, out rotator out_DeltaRot)
{
	local int i, MaxDelta;
	local float MaxDeltaDegrees;

	if (WorldInfo.bUseConsoleInput)
	{
		if (!bSeparateTurretFocus && ShouldClamp())
		{
			if (out_DeltaRot.Yaw == 0)
			{
				if (bIsConsoleTurning)
				{
					// if controller stops rotating on a vehicle whose view rotation yaw gets clamped,
					// set the controller's yaw to where we got so that there's no control lag
					out_ViewRotation.Yaw = GetClampedViewRotation().Yaw;
					bIsConsoleTurning = false;
					ServerSetConsoleTurning(false);
				}
			}

			else if (!bIsConsoleTurning)
			{
				// don't allow starting a new turn if the view would already be clamped
				// because that causes nasty jerking
				if (GetClampedViewRotation().Yaw == Controller.Rotation.Yaw)
				{
					bIsConsoleTurning = true;
					ServerSetConsoleTurning(true);
				}
				else
				{
					// @fixme:  this should be setting to max turn rate so we actually do something when outside of the cone
					out_DeltaRot.Yaw = 0;
				}
			}

			// clamp player rotation to turret rotation speed
			for (i = 0; i < Seats[0].TurretControllers.length; i++)
			{
				MaxDeltaDegrees = FMax(MaxDeltaDegrees, Seats[0].TurretControllers[i].LagDegreesPerSecond);
			}

			if (MaxDeltaDegrees > 0.0)
			{
				MaxDelta = int(MaxDeltaDegrees * 182.0444 * DeltaTime);
				out_DeltaRot.Pitch = (out_DeltaRot.Pitch >= 0) ? Min(out_DeltaRot.Pitch, MaxDelta) : Max(out_DeltaRot.Pitch, -MaxDelta);
				out_DeltaRot.Yaw = (out_DeltaRot.Yaw >= 0) ? Min(out_DeltaRot.Yaw, MaxDelta) : Max(out_DeltaRot.Yaw, -MaxDelta);
				out_DeltaRot.Roll = (out_DeltaRot.Roll >= 0) ? Min(out_DeltaRot.Roll, MaxDelta) : Max(out_DeltaRot.Roll, -MaxDelta);
			}
		}
	}
	Super.ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);
}

simulated function rotator GetClampedViewRotation()
{
	local rotator ViewRotation, ControlRotation, MaxDelta;
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(Weapon);
	if (VWeap != None && ShouldClamp())
	{
		// clamp view yaw so that it doesn't exceed how far the vehicle can aim on console
		ViewRotation.Yaw = Controller.Rotation.Yaw;
		MaxDelta.Yaw = ACos(VWeap.GetMaxFinalAimAdjustment()) * 180.0 / Pi * 182.0444;
		if (!ClampRotation(ViewRotation, Rotation, MaxDelta, MaxDelta))
		{
			// prevent the controller's rotation from diverging too much from the actual view rotation
			ControlRotation.Yaw = Controller.Rotation.Yaw;
			if (!ClampRotation(ControlRotation, ViewRotation, rot(0,16384,0), rot(0,16384,0)))
			{
				ControlRotation.Pitch = Controller.Rotation.Pitch;
				ControlRotation.Roll = Controller.Rotation.Roll;
				Controller.SetRotation(ControlRotation);
			}
		}

		ViewRotation.Pitch = Controller.Rotation.Pitch;
		ViewRotation.Roll = Controller.Rotation.Roll;
		return ViewRotation;
	}
	else
	{
		return super.GetViewRotation();
	}
}

simulated function bool ShouldClamp()
{
	return true;
}

simulated event rotator GetViewRotation()
{
	if (bIsConsoleTurning && !bSeparateTurretFocus && PlayerController(Controller) != None)
	{
		return GetClampedViewRotation();
	}
	else
	{
		return Super.GetViewRotation();
	}
}

/**
 * this function is called when a weapon rotation value has changed.  It sets the DesiredboneRotations for each controller
 * associated with the turret.
 *
 * Network: Remote clients.  All other cases are handled natively
 * FIXME: Look at handling remote clients natively as well
 *
 * @param	SeatIndex		The seat at which the rotation changed
 */

simulated function WeaponRotationChanged(int SeatIndex)
{
	local int i;

	if ( SeatIndex>=0 )
	{
		for (i=0;i<Seats[SeatIndex].TurretControllers.Length;i++)
		{
			Seats[SeatIndex].TurretControllers[i].DesiredBoneRotation = SeatWeaponRotation(SeatIndex,,true);
		}
	}
}

/**
 * This event is triggered when a repnotify variable is received
 *
 * @param	VarName		The name of the variable replicated
 */

simulated event ReplicatedEvent(name VarName)
{
	local string VarString;
	local int SeatIndex;

	if (VarName == 'bPlayingSpawnEffect')
	{
		if (bPlayingSpawnEffect)
		{
			if (Team != UTVEHICLE_UNSET_TEAM)
			{
				PlaySpawnEffect();
			}
		}
		else
		{
			StopSpawnEffect();
		}
	}
	else if ( VarName == 'Team' )
	{
		TeamChanged();
		if (bPlayingSpawnEffect)
		{
			PlaySpawnEffect();
		}
	}
	else if (VarName == 'bDeadVehicle')
	{
		BlowupVehicle();
	}
	else if (VarName == 'bIsDisabled')
	{
		if (bIsDisabled)
		{
			DisableVehicle();
		}
		else
		{
			EnableVehicle();
		}
	}
	else if (VarName == 'LinkedToCount')
	{
		if (LinkedToCount > 0)
		{
			StartLinkedEffect();
		}
		else
		{
			StopLinkedEffect();
		}
	}
	else if ( VarName == 'bKeyVehicle' )
	{
	  if ( bKeyVehicle )
		UTMapInfo(WorldInfo.GetMapInfo()).AddKeyVehicle(self);
	}
	else
	{
		// Ok, some magic occurs here.  The turrets/seat use a prefix system to determine
		// which values to adjust. Here we decode those values and call the appropriate functions

		// First check for <xxxxx>weaponrotation

		VarString = ""$VarName;
		if ( Right(VarString, 14) ~= "weaponrotation" )
		{
			SeatIndex = GetSeatIndexFromPrefix( Left(VarString, Len(VarString)-14) );
			if (SeatIndex >= 0)
			{
				WeaponRotationChanged(SeatIndex);
			}
		}

		// Next, check for <xxxxx>flashcount

		else if ( Right(VarString, 10) ~= "flashcount" )
		{
			SeatIndex = GetSeatIndexFromPrefix( Left(VarString, Len(VarString)-10) );
			if ( SeatIndex>=0 )
			{
				Seats[SeatIndex].BarrelIndex++;

				if ( SeatFlashCount(SeatIndex,,true) > 0 )
				{
					VehicleWeaponFired(true, vect(0,0,0), SeatIndex);
				}
				else
				{
					VehicleWeaponStoppedFiring(true,SeatIndex);
				}
			}
		}
		// finally <xxxxxx>flashlocation
		else if ( Right(VarString, 13) ~= "flashlocation" )
		{
			SeatIndex = GetSeatIndexFromPrefix( Left(VarString, Len(VarString)-13) );
			if ( SeatIndex>=0 )
			{
				Seats[SeatIndex].BarrelIndex++;

				if ( !IsZero(SeatFlashLocation(SeatIndex,,true)) )
				{
					VehicleWeaponFired(true, SeatFlashLocation(SeatIndex,,true), SeatIndex);
				}
				else
				{
					VehicleWeaponStoppedFiring(true,SeatIndex);
				}
			}
		}
		else
		{
			super.ReplicatedEvent(VarName);
		}
	}
}

event SetKeyVehicle()
{
	bKeyVehicle = true;
	UTMapInfo(WorldInfo.GetMapInfo()).AddKeyVehicle(self);
}

/**
 * AI Hint
 * @returns true if there is an occupied turret
 */

function bool HasOccupiedTurret()
{
	local int i;

	for (i = 1; i < Seats.length; i++)
	{
		if( ( Seats[i].SeatPawn != none )
			&& ( Seats[i].SeatPawn.Controller != None )
			)
		{
			return true;
		}
	}

	return false;
}

/**
 * This function is called when the driver's status has changed.
 */
simulated function DrivingStatusChanged()
{
	// turn parking friction on or off
	bUpdateWheelShapes = true;

	// possibly use different physical material while being driven (to allow properties like friction to change).
	if ( bDriving )
	{
		if ( DrivingPhysicalMaterial != None )
		{
			Mesh.SetPhysMaterialOverride(DrivingPhysicalMaterial);
		}
	}
	else if ( DefaultPhysicalMaterial != None )
	{
		Mesh.SetPhysMaterialOverride(DefaultPhysicalMaterial);
	}

	if ( bDriving && !bIsDisabled )
	{
		VehiclePlayEnterSound();
	}
	else if ( Health > 0 )
	{
		VehiclePlayExitSound();
	}

	bBlocksNavigation = !bDriving;

	if (!bDriving)
	{
		StopFiringWeapon();

		SetMovementEffect(0, false);
		SetTexturesToBeResident(false);
	}

	VehicleEvent(bDriving ? 'EngineStart' : 'EngineStop');
}

event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	super.OnAnimEnd(SeqNode,PlayedTime,ExcessTime);
	if(bDriving)
	{
		VehicleEvent('Idle');
	}
}

/**
 * @Returns true if a seat is not occupied
 */
function bool SeatAvailable(int SeatIndex)
{
	return Seats[SeatIndex].SeatPawn == none || Seats[SeatIndex].SeatPawn.Controller == none;
}

/**
 * @return true if there is a seat
 */
function bool AnySeatAvailable()
{
	local int i;
	for (i=0;i<Seats.Length;i++)
	{
		if( ( Seats[i].SeatPawn != none )
			&& ( Seats[i].SeatPawn.Controller==none )
			)
		{
			return true;
		}
	}
	return false;
}

/**
 * @returns the Index for this Controller's current seat or -1 if there isn't one
 */
simulated function int GetSeatIndexForController(controller ControllerToMove)
{
	local int i;
	for (i=0;i<Seats.Length;i++)
	{
		if (Seats[i].SeatPawn.Controller != none && Seats[i].SeatPawn.Controller == ControllerToMove )
		{
			return i;
		}
	}
	return -1;
}

/**
 * @returns the controller of a given seat.  Can be none if the seat is empty
 */
function controller GetControllerForSeatIndex(int SeatIndex)
{
	return Seats[SeatIndex].SeatPawn.Controller;
}

/**
request change to adjacent vehicle seat
*/
reliable server function ServerAdjacentSeat(int Direction, Controller C)
{
	local int CurrentSeat, NewSeat;

	CurrentSeat = GetSeatIndexForController(C);
	if (CurrentSeat != INDEX_NONE)
	{
		NewSeat = CurrentSeat;
		do
		{
			NewSeat += Direction;
			if (NewSeat < 0)
			{
				NewSeat = Seats.Length - 1;
			}
			else if (NewSeat == Seats.Length)
			{
				NewSeat = 0;
			}
			if (NewSeat == CurrentSeat)
			{
				// no available seat
				if ( PlayerController(C) != None )
				{
					PlayerController(C).ClientPlaySound(VehicleLockedSound);
				}
				return;
			}
		} until (SeatAvailable(NewSeat) || (Seats[NewSeat].SeatPawn != None && UTBot(Seats[NewSeat].SeatPawn.Controller) != None));

		// change to the seat we found
		ChangeSeat(C, NewSeat);
	}
}

/**
 * Called when a client is requesting a seat change
 *
 * @network	Server-Side
 */
reliable server function ServerChangeSeat(int RequestedSeat)
{
	if ( RequestedSeat == -1 )
		DriverLeave(false);
	else
		ChangeSeat(Controller, RequestedSeat);
}

/**
 * This function looks at 2 controllers and decides if one as priority over the other.  Right now
 * it looks to see if a human is against a bot but it could be extended to use rank/etc.
 *
 * @returns	ture if First has priority over second
 */
function bool HasPriority(controller First, controller Second)
{
	if ( First != Second && PlayerController(First) != none && PlayerController(Second) == none)
		return true;
	else
		return false;
}

/**
 * ChangeSeat, this controller to change from it's current seat to a new one if (A) the new
 * set is empty or (B) the controller looking to move has Priority over the controller already
 * there.
 *
 * If the seat is filled but the new controller has priority, the current seat holder will be
 * bumped and swapped in to the seat left vacant.
 *
 * @param	ControllerToMove		The Controller we are trying to move
 * @param	RequestedSeat			Where are we trying to move him to
 *
 * @returns true if successful
 */
function bool ChangeSeat(Controller ControllerToMove, int RequestedSeat)
{
	local int OldSeatIndex;
	local Pawn OldPawn, BumpPawn;
	local Controller BumpController;

	// Make sure we are looking to switch to a valid seat
	if ( (RequestedSeat >= Seats.Length) || (RequestedSeat < 0) )
	{
		return false;
	}

	// get the seat index of the pawn looking to move.
	OldSeatIndex = GetSeatIndexForController(ControllerToMove);
	if (OldSeatIndex == -1)
	{
		// Couldn't Find the controller, should never happen
		`Warn("[Vehicles] Attempted to switch" @ ControllerToMove @ "to a seat in" @ self @ " when he is not already in the vehicle");
		return false;
	}

	// If someone is in the seat, see if we can bump him
	if (!SeatAvailable(RequestedSeat))
	{
		// Get the Seat holder's controller and check it for Priority
		BumpController = GetControllerForSeatIndex(RequestedSeat);
		if (BumpController == none)
		{
			`warn("[Vehicles]" @ ControllertoMove @ "Attempted to bump a phantom Controller in seat in" @ RequestedSeat @ " (" $ Seats[RequestedSeat].SeatPawn $ ")");
			return false;
		}

		if ( !HasPriority(ControllerToMove,BumpController) )
		{
			// Nope, same or great priority on the seat holder, deny the move
			if ( PlayerController(ControllerToMove) != None )
			{
				PlayerController(ControllerToMove).ClientPlaySound(VehicleLockedSound);
			}
			return false;
		}

		// If we are bumping someone, free their seat.
		if (BumpController != None)
		{
			BumpPawn = Seats[RequestedSeat].StoragePawn;
			Seats[RequestedSeat].SeatPawn.DriverLeave(true);

			// Handle if we bump the driver
			if (RequestedSeat == 0)
			{
				// Reset the controller's AI if needed
				if (BumpController.RouteGoal == self)
				{
					BumpController.RouteGoal = None;
				}
				if (BumpController.MoveTarget == self)
				{
					BumpController.MoveTarget = None;
				}
			}
		}
	}

	OldPawn = Seats[OldSeatIndex].StoragePawn;

	// Leave the current seat and take over the new one
	Seats[OldSeatIndex].SeatPawn.DriverLeave(true);
	if (OldSeatIndex == 0)
	{
		// Reset the controller's AI if needed
		if (ControllerToMove.RouteGoal == self)
		{
			ControllerToMove.RouteGoal = None;
		}
		if (ControllerToMove.MoveTarget == self)
		{
			ControllerToMove.MoveTarget = None;
		}
	}

	if (RequestedSeat == 0)
	{
		DriverEnter(OldPawn);
	}
	else
	{
		PassengerEnter(OldPawn, RequestedSeat);
	}


	// If we had to bump a pawn, seat them in this controller's old seat.
	if (BumpPawn != None)
	{
		if (OldSeatIndex == 0)
		{
			DriverEnter(BumpPawn);
		}
		else
		{
			PassengerEnter(BumpPawn, OldSeatIndex);
		}
	}
	return true;
}

/**
 * This event is called when the pawn is torn off
 */
simulated event TornOff()
{
	`warn(self @ "Torn off");
}

function Controller GetCollisionDamageInstigator()
{
	// give vehicle killer credit if possible
	return (KillerController != None) ? KillerController : Super.GetCollisionDamageInstigator();
}

/**
 * See Pawn::Died()
 */
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local UTCarriedObject Flag;
	local UTPawn UTP;
	local UTPlayerReplicationInfo UTPRI;
	local int i;

	// before we kill the vehicle and everyone inside, eject anyone who has a shieldbelt
	for (i=0;i<Seats.Length;i++)
	{
		if (Seats[i].SeatPawn != None || Seats[i].StoragePawn != None)
		{
			UTP = UTPawn(Seats[i].StoragePawn);
			if((UTP != none) && UTP.ShieldBeltArmor > 0)
			{
				UTP.ShieldBeltArmor = 0;
				UTP.SetOverlayMaterial(none);
				EjectSeat(i);
			}
		}
	}
	if ( Super(Vehicle).Died(Killer, DamageType, HitLocation) )
	{
		if ( (VehicleDestroyedSound.Length > 0) && (UTBot(Killer) != None) )
		{
			UTBot(Killer).KilledVehicleClass = Class;
			Killer.SendMessage(None, 'VEHICLEKILL', 10);
		}
		KillerController = Killer;
		HitDamageType = DamageType; // these are replicated to other clients
		TakeHitLocation = HitLocation;
		UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
		if ( UTPRI != None )
		{
			UTPRI.StopDrivingStat(GetVehicleDrivingStatName());
		}
		BlowupVehicle();

		HandleDeadVehicleDriver();

		for (i = 1; i < Seats.Length; i++)
		{
			if (Seats[i].SeatPawn != None)
			{
				UTPRI = UTPlayerReplicationInfo(Seats[i].SeatPawn.PlayerReplicationInfo);
				if ( UTPRI != None )
				{
					UTPRI.StopDrivingStat(UDKVehicleBase(Seats[i].SeatPawn).GetVehicleDrivingStatName());
				}
				// kill the WeaponPawn with the appropriate killer, etc for kill credit and death messages
				Seats[i].SeatPawn.Died(Killer, DamageType, HitLocation);
			}
		}

		// drop flag
		ForEach BasedActors(class'UTCarriedObject' , Flag)
		{
			Flag.SetBase(None);
		}

		// notify vehicle factory
		if (ParentFactory != None)
		{
			ParentFactory.VehicleDestroyed(self);
			ParentFactory = None;
		}
		return true;
	}
	return false;
}

/**
 * Call this function to blow up the vehicle
 */
simulated function BlowupVehicle()
{
	local int i;

	if(bDriving)
	{
		VehicleEvent('EngineStop');
	}

	bCanBeBaseForPawns = false;
	LinkHealMult = 0.0;
	GotoState('DyingVehicle');
	AddVelocity(TearOffMomentum, TakeHitLocation, HitDamageType);
	bDeadVehicle = true;
	bStayUpright = false;

	if ( StayUprightConstraintInstance != None )
	{
		StayUprightConstraintInstance.TermConstraint();
	}

	// Iterate over wheels, turning off those we want
	for(i=0; i<Wheels.length; i++)
	{
		if(UDKVehicleWheel(Wheels[i]) != None && UDKVehicleWheel(Wheels[i]).bDisableWheelOnDeath)
		{
			SetWheelCollision(i, FALSE);
		}
	}

	CustomGravityScaling = 1.0;
	if ( UDKVehicleSimHover(SimObj) != None )
	{
		UDKVehicleSimHover(SimObj).bDisableWheelsWhenOff = true;
	}
}

/**
  * if bHasCustomEntryRadius, this is called to see if Pawn P is in it.
  */
function bool InCustomEntryRadius(Pawn P)
{
	return false;
}

simulated function PlayerReplicationInfo GetSeatPRI(int SeatNum)
{
	if ( Role == ROLE_Authority )
	{
		return Seats[SeatNum].SeatPawn.PlayerReplicationInfo;
	}
	else
	{
		return (SeatNum==0) ? PlayerReplicationInfo : PassengerPRI;
	}
}

/**
 * CanEnterVehicle()
 * @return true if Pawn P is allowed to enter this vehicle
 */
simulated function bool CanEnterVehicle(Pawn P)
{
	local int i;
	local bool bSeatAvailable, bIsHuman;
	local PlayerReplicationInfo SeatPRI;

	if ( P.bIsCrouched || (P.DrivenVehicle != None) || (P.Controller == None) || !P.Controller.bIsPlayer
	     || Health <= 0 || bDeleteMe )
	{
		return false;
	}

	// check for available seat, and no enemies in vehicle
	// allow humans to enter if full but with bots (TryToDrive() will kick one out if possible)
	bIsHuman = P.IsHumanControlled();
	bSeatAvailable = false;
	for (i=0;i<Seats.Length;i++)
	{
		SeatPRI = GetSeatPRI(i);
		if (SeatPRI == None)
		{
			bSeatAvailable = true;
		}
		else if (!WorldInfo.GRI.OnSameTeam(P, SeatPRI))
		{
			return false;
		}
		else if (bIsHuman && SeatPRI.bBot)
		{
			bSeatAvailable = true;
		}
	}

	return bSeatAvailable;
}

/**
 * The pawn Driver has tried to take control of this vehicle
 *
 * @param	P		The pawn who wants to drive this vehicle
 */
function bool TryToDrive(Pawn P)
{
	local vector X,Y,Z;
	local bool bFreedSeat;
	local bool bEnteredVehicle;

	// don't allow while playing spawn effect
	if (bPlayingSpawnEffect)
	{
		return false;
	}

	// Does the vehicle need to be uprighted?
	if ( bIsInverted && bMustBeUpright && !bVehicleOnGround && VSize(Velocity) <= 5.0f )
	{
		if ( bCanFlip )
		{
			bIsUprighting = true;
			UprightStartTime = WorldInfo.TimeSeconds;
			GetAxes(Rotation,X,Y,Z);
			bFlipRight = ((P.Location - Location) dot Y) > 0;
		}
		return false;
	}

	if ( !CanEnterVehicle(P) || (Vehicle(P) != None) )
	{
		return false;
	}

	// Check vehicle Locking....
	// Must be a non-disabled same team (or no team game) vehicle
	if (!bIsDisabled && (Team == UTVEHICLE_UNSET_TEAM || !bTeamLocked || !WorldInfo.Game.bTeamGame || WorldInfo.GRI.OnSameTeam(self,P)))
	{
		if (bEnteringUnlocks)
		{
			bTeamLocked = false;
			if (ParentFactory != None)
			{
				ParentFactory.VehicleTaken();
			}
		}

		if (!AnySeatAvailable())
		{
			if (WorldInfo.GRI.OnSameTeam(self, P))
			{
				// kick out the first bot in the vehicle to make way for this driver
				bFreedSeat = KickOutBot();
			}

			if (!bFreedSeat)
			{
				// we were unable to kick a bot out
				return false;
			}
		}

		// Look to see if the driver seat is open
		bEnteredVehicle = (Driver == None) ? DriverEnter(P) : PassengerEnter(P, GetFirstAvailableSeat());

		if( bEnteredVehicle )
		{
			SetTexturesToBeResident( TRUE );
		}

		return bEnteredVehicle;
	}

	VehicleLocked( P );
	return false;
}

/**
  * kick out the first bot in the vehicle to make way for human driver
  */
function bool KickOutBot()
{
	local int i;
	local UTBot B;

	for (i = 0; i < Seats.length; i++)
	{
		B = UTBot(Seats[i].SeatPawn.Controller);
		if (B != None && Seats[i].SeatPawn.DriverLeave(false))
		{
			// we can't tell the bot to re-evaluate right away, because it will often get right back in this vehicle
			B.SetTimer(0.01, false, 'WhatToDoNext');
			return true;
		}
	}
	return false;
}

/**
 * Pawn tried to enter vehicle, but it's locked!!
 *
 * @param	P	The pawn that tried
 */
function VehicleLocked( Pawn P )
{
	local PlayerController PC;

	PC = PlayerController(P.Controller);

	if ( PC != None )
	{
		PC.ClientPlaySound(VehicleLockedSound);
		PC.ReceiveLocalizedMessage(class'UTVehicleMessage', 1);
	}
}

/**
  * returns TRUE if vehicle is useable (can be entered)
  */
simulated function bool ShouldShowUseable(PlayerController PC, float Dist)
{
	local UTPlayerController UTPC;

	UTPC = UTPlayerController(PC);
	return ( InUseableRange(UTPC, Dist) && CanEnterVehicle(PC.Pawn)
				&& ((UTPC.CheckVehicleToDrive(false) == self)
					|| (bRequestedEntryWithFlag && UTPC.bJustFoundVehicle && UTPlayerReplicationInfo(PC.PlayerReplicationInfo).bHasFlag)) );
}

/**
 * PostRenderFor() Hook to allow pawns to render HUD overlays for themselves.
 * Assumes that appropriate font has already been set
 *
 * @param	PC		The Player Controller who is rendering this pawn
 * @param	Canvas	The canvas to draw on
 */
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local float TextXL, XL, YL, Dist, HealthX, HealthY, xscale, MaxOffset;
	local vector ScreenLoc, HitNormal, HitLocation, CrossDir;
	local actor HitActor;
	local LinearColor TeamColor;
	local Color	TextColor;
	local string ScreenName;
	local bool bShowUseable;
	local UTWeapon Weap;
	local UTHUDBase HUD;

	// NOTE bShowlocked is set in NativePostRenderFor().
	HUD = UTHUDBase(PC.MyHUD);

	Dist = VSize(CameraPosition - Location);

	if ( WorldInfo.GRI.GameClass.default.bTeamGame && !WorldInfo.GRI.OnSameTeam(self, PC) )
	{
		if ( IsInvisible() )
		{
			LastPostRenderTraceTime = WorldInfo.TimeSeconds;
			return;
		}
		if ( !bShowLocked && !PC.PlayerReplicationInfo.bOnlySpectator )
		{
			// if not on same team, then only draw icon if locked
			// maybe change to action music if close enough
			if ( (PlayerReplicationInfo != None) && (WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5) )
			{
				if ( !UTPlayerController(PC).AlreadyInActionMusic() && (Dist*Dist < VSizeSq(PC.ViewTarget.Location - Location)) && !IsInvisible() )
				{
					// check whether close enough to crosshair
					screenLoc = Canvas.Project(Location);
					if ( (Abs(screenLoc.X - 0.5*Canvas.ClipX) < 0.1 * Canvas.ClipX)
						&& (Abs(screenLoc.Y - 0.5*Canvas.ClipY) < 0.1 * Canvas.ClipY) )
					{
						// make sure really visible using traces
						if ( FastTrace(Location, CameraPosition,, true)
										|| FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition,, true) )
						{
							UTPlayerController(PC).ClientMusicEvent(0);;
						}
					}
				}
				LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
			}
			bShowUseable = ShouldShowUseable(PC, Dist);
			if ( !bShowUseable )
			{
				return;
			}
		}
	}

	ScreenLoc = bShowLocked ? Canvas.Project(Location) : Canvas.Project(Location + TeamBeaconOffset);

	// make sure not clipped out
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		// what if should draw "E to enter"
		if ( !bShowLocked && !bShowUseable && !bPlayingSpawnEffect && ((UTPawn(PC.Pawn) != None) || (UTVehicle_Hoverboard(PC.Pawn) != None)) )
		{
			bShowUseable = ShouldShowUseable(PC, Dist);
		}
		if ( !bShowUseable )
		{
			return;
		}
	}

	// make sure not behind weapon
	if ( UTPawn(PC.Pawn) != None )
	{
		Weap = UTWeapon(UTPawn(PC.Pawn).Weapon);
		if ( (Weap != None) && Weap.CoversScreenSpace(screenLoc, Canvas) )
		{
			return;
		}
	}
	else if ( (UTVehicle_Hoverboard(PC.Pawn) != None) && UTVehicle_Hoverboard(PC.Pawn).CoversScreenSpace(screenLoc, Canvas) )
	{
		return;
	}

	// periodically make sure really visible using traces
	if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
	{
		LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
		bPostRenderTraceSucceeded = FastTrace(Location, CameraPosition);

		if ( !bPostRenderTraceSucceeded )
		{
			if ( bShowLocked )
			{
				return;
			}
			bPostRenderTraceSucceeded = FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition);
			if ( !bPostRenderTraceSucceeded )
			{
				// now try top corners of vehicle, before giving up
				CrossDir = Normal(Vect(0,0,1) cross (Location - CameraPosition));
				bPostRenderTraceSucceeded = FastTrace(Location+GetCollisionHeight()*vect(0,0,1)+CylinderComponent.CollisionRadius*CrossDir, CameraPosition)
										|| FastTrace(Location+GetCollisionHeight()*vect(0,0,1)-CylinderComponent.CollisionRadius*CrossDir, CameraPosition);
			}
		}
	}
	if ( !bPostRenderTraceSucceeded )
	{
		return;
	}

	if ( bShowLocked )
	{
		// draw no entry indicator
		// don't draw it if there's another vehicle in front of the vehicle
		HitActor = Trace(HitLocation, HitNormal, Location, CameraPosition, true,,,TRACEFLAG_Blocking);
		if ( UTVehicle(HitActor) != None )
		{
			return;
		}

		// draw locked symbol
		xscale = FClamp( (2*TeamBeaconPlayerInfoMaxDist - Dist)/(2*TeamBeaconPlayerInfoMaxDist), 0.55f, 1.f);
		xscale = xscale * xscale;
		Canvas.SetPos(ScreenLoc.X-16*xscale,ScreenLoc.Y-16*xscale);
		Canvas.DrawColor = class'UTHUD'.Default.WhiteColor;

		Canvas.DrawTile(class'UTHUD'.Default.AltHudTexture,30*xscale, 30*xscale,599,208,15,21, MakeLinearColor( 4.0, 2.0, 0.5, 1.0) );
		return;
	}

	if ( Dist > TeamBeaconPlayerInfoMaxDist )
	{
		HealthY = 8 * Canvas.ClipX/1024;
	}
	else if ( PlayerReplicationInfo == None )
	{
		HealthY = 8 * Canvas.ClipX/1024 * (1 + 2*Square((TeamBeaconPlayerInfoMaxDist-Dist)/TeamBeaconPlayerInfoMaxDist));
	}
	else
	{
		HealthY = 16 * Canvas.ClipX/1024 * (1 + 2*Square((TeamBeaconPlayerInfoMaxDist-Dist)/TeamBeaconPlayerInfoMaxDist));
	}

	class'UTHUD'.Static.GetTeamColor( GetTeamNum(), TeamColor, TextColor);

	if ( Dist > TeamBeaconPlayerInfoMaxDist )
	{
		XL = 2 * HealthY;
	}
	else if ( PlayerReplicationInfo != None )
	{
		ScreenName = PlayerReplicationInfo.PlayerName;
		Canvas.StrLen(ScreenName, TextXL, YL);
		XL = Max( TextXL, 2*HealthY );
		HealthY *= 0.5;
	}
	else
	{
		XL = 2 * HealthY;
	}

	// customize beacon if this vehicle could be entered
	if ( !bPlayingSpawnEffect && ((UTPawn(PC.Pawn) != None) || (UTVehicle_Hoverboard(PC.Pawn) != None)) )
	{
		if ( bShowUseable || ShouldShowUseable(PC, Dist) )
		{
			// programmer art - just color it greenish
			bShowUseable = true;
			if ( bRequestedEntryWithFlag && UTPlayerReplicationInfo(PC.PlayerReplicationInfo).bHasFlag )
			{
				HUD.DrawToolTip(Canvas, PC, "GBA_Use", Canvas.ClipX * 0.5, Canvas.ClipY * 0.6, DropFlagIconCoords.U, DropFlagIconCoords.V, DropFlagIconCoords.UL, DropFlagIconCoords.VL, Canvas.ClipY/720);
			}
			else
			{
				if (bIsInverted && bCanFlip)
				{
					HUD.DrawToolTip(Canvas, PC, "GBA_Use", Canvas.ClipX * 0.5, Canvas.ClipY * 0.6, FlipToolTipIconCoords.U, FlipToolTipIconCoords.V, FlipToolTipIconCoords.UL, FlipToolTipIconCoords.VL, Canvas.ClipY/720);
				}
				else
				{
					HUD.DrawToolTip(Canvas, PC, "GBA_Use", Canvas.ClipX * 0.5, Canvas.ClipY * 0.6, EnterToolTipIconCoords.U, EnterToolTipIconCoords.V, EnterToolTipIconCoords.UL, EnterToolTipIconCoords.VL, Canvas.ClipY/720);
				}
			}
		}
		else
		{
			if ( !WorldInfo.GRI.GameClass.default.bTeamGame )
			{
				return;
			}
			if ( bRequestedEntryWithFlag )
			{
				UTPlayerController(PC).bJustFoundVehicle = false;
			}
			bRequestedEntryWithFlag = false;
		}
	}
	else
	{
		if ( !WorldInfo.GRI.GameClass.default.bTeamGame )
		{
			return;
		}
		if ( bRequestedEntryWithFlag )
		{
			UTPlayerController(PC).bJustFoundVehicle = false;
		}
		bRequestedEntryWithFlag = false;
	}
	Class'UTHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-1.8*YL-1.8*HealthY,1.4*XL,1.8*YL+1.9*HealthY, TeamColor, Canvas);

	if ( ScreenName != "" )
	{
		Canvas.DrawColor = TextColor;
		Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.2*YL-1.4*HealthY);
		Canvas.DrawText(ScreenName, true,,, class'UTHUD'.default.TextRenderInfo);
	}

	HealthX = XL * FMin(1.0, GetDisplayedHealth()/float(HealthMax));

	if ( (PlayerReplicationInfo != None) && (Dist < TeamBeaconPlayerInfoMaxDist) )
	{
		Class'UTHUD'.static.DrawHealth(ScreenLoc.X-0.5*XL,ScreenLoc.Y-0.2*YL-1.8*HealthY, HealthX, XL, HealthY, Canvas);
	}
	else
	{
		Class'UTHUD'.static.DrawHealth(ScreenLoc.X-0.5*XL,ScreenLoc.Y-0.1*YL-1.4*HealthY, HealthX, XL, HealthY, Canvas);
	}
	if ( Dist < TeamBeaconPlayerInfoMaxDist )
	{
		RenderPassengerBeacons(PC, Canvas, TeamColor, TextColor, Weap);
	}

	// should I register as friendly for crosshair?
	if ( (HUD != None) && !HUD.bCrosshairOnFriendly )
	{
		ScreenLoc = Canvas.Project(Location);
		MaxOffset = HUDExtent/Dist;
		if ( (Abs(screenLoc.X - 0.5*Canvas.ClipX) < MaxOffset * Canvas.ClipX)
		&& (Abs(screenLoc.Y - 0.5*Canvas.ClipY) < MaxOffset * Canvas.ClipY) )
		{
			HUD.bCrosshairOnFriendly = true;
		}
	}
}

simulated function float GetDisplayedHealth()
{
	return Health;
}

simulated function RenderPassengerBeacons(PlayerController PC, Canvas Canvas, LinearColor TeamColor, Color TextColor, UTWeapon Weap)
{
	if ( PassengerPRI != None )
	{
		PostRenderPassengerBeacon(PC, Canvas, TeamColor, TextColor, Weap, PassengerPRI, PassengerTeamBeaconOffset);
	}
}

/**
 * PostRenderPassengerBeacon() renders
 * Assumes that appropriate font has already been set
 *
 * @param	PC		The Player Controller who is rendering this pawn
 * @param	Canvas	The canvas to draw on
 */
simulated function PostRenderPassengerBeacon(PlayerController PC, Canvas Canvas, LinearColor TeamColor, Color TextColor, UTWeapon Weap, PlayerReplicationInfo InPassengerPRI, vector InPassengerTeamBeaconOffset)
{
	local float TextXL, XL, YL;
	local vector ScreenLoc, X, Y,Z;

	GetAxes(Rotation, X, Y, Z);
	ScreenLoc = Canvas.Project(Location + InPassengerTeamBeaconOffset.X * X + InPassengerTeamBeaconOffset.Y * Y + InPassengerTeamBeaconOffset.Z * Z);

	// make sure not clipped out
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		return;
	}

	// make sure not behind weapon
	if ( (Weap != None) && Weap.CoversScreenSpace(ScreenLoc, Canvas) )
	{
		return;
	}
	else if ( (UTVehicle_Hoverboard(PC.Pawn) != None) && UTVehicle_Hoverboard(PC.Pawn).CoversScreenSpace(ScreenLoc, Canvas) )
	{
		return;
	}

	Canvas.StrLen(InPassengerPRI.PlayerName, TextXL, YL);
	XL = FMax( TextXL, 64.0 * Canvas.ClipX/1024);

	Class'UTHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-1.8*YL,1.4*XL,1.8*YL, TeamColor, Canvas);

	Canvas.DrawColor = TextColor;
	Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.4*YL);
	Canvas.DrawText(InPassengerPRI.PlayerName, true,,, class'UTHUD'.default.TextRenderInfo);
}

/**
 * Team is changed when vehicle is possessed
 */
event SetTeamNum(byte T)
{
	if ( T != Team )
	{
		Team = T;
		TeamChanged();
	}
}

/**
 * This function is called when the team has changed.  Use it to setup team specific overlays/etc
 *
 * NOTE: the UTVehicle_Scavenger is doing all kinds of crazy special case stuff and does NOT call super.  Make certain that you check
 * UTVehicle_Scavenger.TeamChanged() when making changes here.
 */
simulated function TeamChanged()
{
	local MaterialInterface NewMaterial;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (Team < TeamMaterials.length && TeamMaterials[Team] != None)
		{
			NewMaterial = TeamMaterials[Team];
		}
		else if (TeamMaterials.length > 0 && TeamMaterials[0] != None)
		{
			NewMaterial = TeamMaterials[0];
		}

		if (NewMaterial != None)
		{
			if (DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetParent(NewMaterial);
		}
			else
			{
				Mesh.SetMaterial(0, NewMaterial);
			}
		}

		TeamChanged_VehicleEffects();

		UpdateDamageMaterial();
	}
}

/**
 * This function is called when we need to change Vehicle Effects.
 *
 * To get blue effects add this to the VehicleEffects list entry:  EffectTemplate_Blue=ParticleSystem'',
 **/
simulated function TeamChanged_VehicleEffects()
{
	local int Len;
	local int TeamNum;
	local int VehicleEffectIndex;
	local ParticleSystem NewTemplate;

	InitializeEffects();

	TeamNum = GetTeamNum();
	Len = VehicleEffects.length;

	for( VehicleEffectIndex = 0; VehicleEffectIndex < Len; ++VehicleEffectIndex )
	{
		// if we have a blue particle system then we will need to change the system based on team otherwise this vehicle effect doesn't need to be changed
		if (VehicleEffects[VehicleEffectIndex].EffectTemplate_Blue != None && VehicleEffects[VehicleEffectIndex].EffectRef != None)
		{
			NewTemplate = (TeamNum == 1) ? VehicleEffects[VehicleEffectIndex].EffectTemplate_Blue : VehicleEffects[VehicleEffectIndex].EffectTemplate;
			if (VehicleEffects[VehicleEffectIndex].EffectRef.Template != NewTemplate)
			{
				VehicleEffects[VehicleEffectIndex].EffectRef.SetTemplate(NewTemplate);
			}
		}
	}
}



/**
 * Stub out the Dodge event.  Override if the vehicle needs a dodge
 *
 * See Pawn::Dodge()
 */
function bool Dodge(eDoubleClickDir DoubleClickMove);

/**
 * This function is called from an incoming missile that is targetting this vehicle
 *
 * @param P		The incoming projectile
 */
event IncomingMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if (C != None && C.Skill >= 5.0 && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)))
	{
		ShootMissile(P);
	}
}

/**
 * AI hint - Shoot at the missle
 *
 * @param P		The incoming projectile
 */

function ShootMissile(Projectile P)
{
	Controller.Focus = P;
	Controller.FireWeaponAt(P);
}

/**
 * sends the LockOn message to all seats in this vehicle with the specified switch
 *
 * @param Switch 	The message switch
 */
simulated function SendLockOnMessage(int Switch)
{
	local int i;
	local Pawn P;

	for (i = 0; i < Seats.length; i++)
	{
		P = Seats[i].SeatPawn;

		if( ( P != none )
			&& ( PlayerController(P.Controller) != None)
			&& P.IsLocallyControlled()
			&& (P.Controller.Pawn == P) // for client side lock warnings
			)
		{
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'UTLockWarningMessage', Switch);
			PlayerController(P.Controller).ClientPlaySound(LockedOnSound);
		}
	}
}

/**
 *  LockOnWarning() called by seeking missiles to warn vehicle they are incoming
 */
simulated event LockOnWarning(UDKProjectile IncomingMissile)
{
	SendLockOnMessage(1);
}

/**
 * Check to see if Other is too close to attack
 *
 * @param	Other		Actor to check against
 * @returns true if he's too close
 */

function bool TooCloseToAttack(Actor Other)
{
	local int NeededPitch, i;
	local bool bControlledWeaponPawn;

	if (VSize(Location - Other.Location) > 2500.0)
	{
		return false;
	}

	if (Weapon == None)
	{
		if (Seats.length < 2)
		{
			return false;
		}
		for (i = 0; i < Seats.length; i++)
		{
			if (Seats[i].SeatPawn != None && Seats[i].SeatPawn.Controller != None)
			{
				bControlledWeaponPawn = true;
				if (!Seats[i].SeatPawn.TooCloseToAttack(Other))
				{
					return false;
				}
			}
		}

		return bControlledWeaponPawn;
	}

	NeededPitch = rotator(Other.GetTargetLocation(self) - Weapon.GetPhysicalFireStartLoc()).Pitch & 65535;
	return CheckTurretPitchLimit(NeededPitch, 0);
}

/** checks if the given pitch would be limited by the turret controllers, i.e. we cannot possibly fire in that direction
 * @return whether the pitch would be constrained
 */
function bool CheckTurretPitchLimit(int NeededPitch, int SeatIndex)
{
	local int i;

	if (SeatIndex >= 0)
	{
		if (Seats[SeatIndex].TurretControllers.length > 0)
		{
			for (i = 0; i < Seats[SeatIndex].TurretControllers.Length; i++ )
			{
				if (!Seats[SeatIndex].TurretControllers[i].WouldConstrainPitch(NeededPitch, Mesh))
				{
					return false;
				}
			}

			return true;
		}
		else if (Seats[SeatIndex].Gun != None)
		{
			return (Cos(Abs(NeededPitch - (Rotation.Pitch & 65535)) / 182.0444) > UTVehicleWeapon(Seats[SeatIndex].Gun).GetMaxFinalAimAdjustment());
		}
	}

	return false;
}

/**
 * Play the horn for this vehicle
 */

function PlayHorn()
{
	local int i, NumPositions;
	local Pawn P;
	local UTPawn UTP;
	local UTVehicle V;

	if (WorldInfo.TimeSeconds - LastHornTime > 1.0 && HornIndex >= 0 && HornIndex < HornSounds.Length)
	{
		PlaySound(HornSounds[HornIndex]);
		LastHornTime = WorldInfo.TimeSeconds;
	}

	if (PlayerController(Controller) != None)
	{
		// if a seat is available, nearby friendly bots respond to horn and try to get in
		for (i = 0; i < Seats.length; i++)
		{
			if (Seats[i].SeatPawn.Controller == None)
			{
				NumPositions++;
			}
		}
		if (NumPositions > 0)
		{
			foreach VisibleCollidingActors(class'Pawn', P, HornAIRadius)
			{
				if (UTBot(P.Controller) != None && WorldInfo.GRI.OnSameTeam(P, self))
				{
					V = UTVehicle(P);
					if (V != None)
					{
						// if bot is on a hoverboard, get off it to respond to horn
						UTP = UTPawn(V.Driver);
						if (UTP != None && UTP.HoverboardClass == V.Class && V.DriverLeave(false))
						{
							P = UTP;
						}
					}
					if (Vehicle(P) == None)
					{
						UTBot(P.Controller).SetTemporaryOrders('Follow', Controller);
						if (--NumPositions == 0)
						{
							break;
						}
					}
				}
			}
		}
	}
}

/**
 * UpdateControllerOnPossess() override Pawn.UpdateControllerOnPossess() to keep from changing controller's rotation
 *
 * @param	bVehicleTransition	Will be true if this the pawn is entering/leaving a vehicle
 */
function UpdateControllerOnPossess(bool bVehicleTransition);

/**
 * @returns the number of passengers in this vehicle
 */
simulated function int NumPassengers()
{
	local int i, Num;

	for (i = 0; i < Seats.length; i++)
	{
		if( (Seats[i].SeatPawn != None)
			&& (Seats[i].SeatPawn.Controller != None)
			)
		{
			Num++;
		}
	}

	return Num;
}

/**
 * AI Hint
 */
function UTVehicle GetMoveTargetFor(Pawn P)
{
	return self;
}

/** handles dealing with any flag the given driver/passenger may be holding */
function HandleEnteringFlag(UTPlayerReplicationInfo EnteringPRI)
{
	if (EnteringPRI.bHasFlag)
	{
		if (!bCanCarryFlag)
		{
			EnteringPRI.GetFlag().Drop();
		}
		else if (!bDriverHoldsFlag)
		{
			AttachFlag(EnteringPRI.GetFlag(), Driver);
		}
	}
}

/**
 * Called when a pawn enters the vehicle
 *
 * @Param P		The Pawn entering the vehicle
 */
function bool DriverEnter(Pawn P)
{
	local UTPlayerController PC;

	P.StopFiring();

	if (Seats[0].Gun != none)
	{
		InvManager.SetCurrentWeapon(Seats[0].Gun);
	}

	Instigator = self;

	if ( !Super.DriverEnter(P) )
		return false;

	HandleEnteringFlag(UTPlayerReplicationInfo(PlayerReplicationInfo));

	SetSeatStoragePawn(0,P);

	if (ParentFactory != None)
	{
		ParentFactory.TriggerEventClass(class'UTSeqEvent_VehicleFactory', None, 3);
	}

	if ( PlayerController(Controller) != None )
	{
		VehicleLostTime = 0;
	}
	StuckCount = 0;
	ResetTime = WorldInfo.TimeSeconds - 1;
	bHasBeenDriven = true;

	if ( bKeyVehicle )
	{
		// notify any players that have this as their objective
		ForEach WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			if (PC.LastAutoObjective == self)
			{
				PC.CheckAutoObjective(true);
			}
		}
	}
	return true;
}

/**
 * HoldGameObject() Attach GameObject to mesh.
 * @param 	GameObj 	Game object to hold
 */
simulated event HoldGameObject(UDKCarriedObject GameObj)
{
	local UTPawn P;
	local UTCarriedObject UTGameObj;

	UTGameObj = UTCarriedObject(GameObj);
	UTGameObj.SetHardAttach(UTGameObj.default.bHardAttach);
	UTGameObj.bIgnoreBaseRotation = UTGameObj.default.bIgnoreBaseRotation;

	if (bDriverHoldsFlag)
	{
		P = UTPawn(Driver);
		if (P != None)
		{
			P.HoldGameObject(UTGameObj);
		}
	}
	else
	{
		AttachFlag(UTGameObj, Driver);
	}
}

/**
 * If the driver enters the vehicle with a UTCarriedObject, this event
 * is triggered.
 *
 * @param	FlagActor		The object being carried
 * @param	NewDriver		The driver (may not yet have been set)
 */
simulated function AttachFlag(UTCarriedObject FlagActor, Pawn NewDriver)
{
	if ( FlagActor != None )
	{
		if ( FlagBone == '' )
		{
			FlagActor.BaseBoneName = '';
			FlagActor.BaseSkelComponent = None;
			FlagActor.SetBase(self);
		}
		else
		{
			FlagActor.SetBase(self,,Mesh,FlagBone);
		}
		FlagActor.SetRelativeRotation(FlagRotation);
		FlagActor.SetRelativeLocation(FlagOffset);
	}
}

`if(`notdefined(ShippingPC))
exec function FixedView(string VisibleMeshes)
{
	local int SeatIdx;
	local UTPawn P;

	// find a local player in one of the seats and pass call onto him
	for (SeatIdx=0; SeatIdx<Seats.length; ++SeatIdx)
	{
		P = UTPawn(Seats[SeatIdx].SeatPawn.Driver);
		if (P != None)
		{
			P.FixedView(VisibleMeshes);
		}
	}
}
`endif

/**
 * DriverLeft() called by DriverLeave() after the drive has been taken out of the vehicle
 */
function DriverLeft()
{
	local float Dist;
	local UTPlayerReplicationInfo DriverPRI;

	DriverPRI = UTPlayerReplicationInfo(Driver.PlayerReplicationInfo);
	if (DriverPRI != None && DriverPRI.bHasFlag && UDKPawn(Driver) != None)
	{
		UDKPawn(Driver).HoldGameObject(DriverPRI.GetFlag());
	}

	Super.DriverLeft();

	if (bNeverReset || ParentFactory == None || Occupied())
	{
		return;
	}

	Dist = VSize(Location - ParentFactory.Location);
	if (Dist >= 2000 && (Dist > 5000 || !FastTrace(ParentFactory.Location, Location)))
	{
		ResetTime = WorldInfo.TimeSeconds + (bKeyVehicle ? 15.0 : 30.0);
	}
}

/**
 * @returns the first available passenger seat, or -1 if there are none available
 */
function int GetFirstAvailableSeat()
{
	local int i;

	for (i = 1; i < Seats.Length; i++)
	{
		if (SeatAvailable(i))
		{
			return i;
		}
	}

	return -1;
}

/**
 * Called when a passenger enters the vehicle
 *
 * @param P				The Pawn entering the vehicle
 * @param SeatIndex		The seat where he is to sit
 */

function bool PassengerEnter(Pawn P, int SeatIndex)
{
	// Restrict someone not on the same team
	if ( WorldInfo.Game.bTeamGame && !WorldInfo.GRI.OnSameTeam(P,self) )
	{
		return false;
	}

	if (SeatIndex <= 0 || SeatIndex >= Seats.Length)
	{
		`warn("Attempted to add a passenger to unavailable passenger seat" @ SeatIndex);
		return false;
	}

	if ( !Seats[SeatIndex].SeatPawn.DriverEnter(p) )
	{
		return false;
	}

	HandleEnteringFlag(UTPlayerReplicationInfo(Seats[SeatIndex].SeatPawn.PlayerReplicationInfo));

	SetSeatStoragePawn(SeatIndex,P);

	bHasBeenDriven = true;
	return true;
}

/**
 * Called when the driver leaves the vehicle
 *
 * @param	bForceLeave		Is true if the driver was forced out
 */

event bool DriverLeave(bool bForceLeave)
{
	local bool bResult;
	local Pawn OldDriver;

	if (!bForceLeave && !bAllowedExit)
	{
		return false;
	}

	OldDriver = Driver;
	bResult = Super.DriverLeave(bForceLeave);
	if (bResult)
	{
		SetSeatStoragePawn(0,None);
//		Seats[0].StoragePawn = None;
		// set Instigator to old driver so if vehicle continues on and runs someone over, the appropriate credit is given
		Instigator = OldDriver;
		if (ParentFactory != None)
		{
			ParentFactory.TriggerEventClass(class'UTSeqEvent_VehicleFactory', None, 4);
		}
	}

	return bResult;
}

/**
 * Called when a passenger leaves the vehicle
 *
 * @param	SeatIndex		Leaving from which seat
 */

function PassengerLeave(int SeatIndex)
{
	SetSeatStoragePawn(SeatIndex, None);
}

/**
 *  Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it
 */
event CheckReset()
{
	local Pawn P;
	local Controller C;

	if ( Occupied() )
	{
		ResetTime = WorldInfo.TimeSeconds - 1;
		return;
	}

	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		P = C.Pawn;
		if ( P != None && WorldInfo.GRI.OnSameTeam(P, self) && (VSize(Location - P.Location) < 2500.0) )
		{
			if ( (PlayerController(C) != None) || (Instigator == C.Pawn) )
			{
				if ( FastTrace(P.Location + P.GetCollisionHeight() * vect(0,0,1), Location + GetCollisionHeight() * vect(0,0,1)) )
				{
					ResetTime = WorldInfo.TimeSeconds + 10;
					return;
				}
			}
			else if ( C.RouteGoal == self )
		{
			ResetTime = WorldInfo.TimeSeconds + 10;
			return;
		}
	}
	}

	if (bKeyVehicle && Health < HealthMax / 2)
	{
		Died(None, class'DamageType', Location);
	}
	else
	{
		//if factory is active, we want it to spawn new vehicle NOW
		if ( ParentFactory != None )
		{
			ParentFactory.ChildVehicle = None;
			ParentFactory.SpawnVehicle();
			ParentFactory = None; //so doesn't call ParentFactory.VehicleDestroyed() again in Destroyed()
		}

		Destroy();
	}
}

/**
 *  AI code
 */
function bool Occupied()
{
	local int i;

	if ( Controller != None )
		return true;

	for ( i=0; i<Seats.Length; i++ )
		if ( !SeatAvailable(i) )
			return true;

	return false;
}

/**
 * OpenPositionFor() returns true if there is a seat available for P
 *
 * @param P		The Pawn to test for
 * @returns true if open
 */
function bool OpenPositionFor(Pawn P)
{
	local int i;

	if ( UTGame(WorldInfo.Game).JustStarted(20) && (Reservation != None) && (Reservation != P.Controller) && (Reservation.RouteGoal == Self)
		&& (Reservation.Pawn != None) && (VSize(Reservation.Pawn.Location - Location) <= VSize(P.Location - Location)) )
	{
		for ( i=0; i<Seats.Length; i++ )
			if ( SeatAvailable(i) )
				return true;
		return false;
	}

	if ( Controller == None )
		return true;

	if ( !WorldInfo.GRI.OnSameTeam(Controller,P) )
		return false;

	for ( i=0; i<Seats.Length; i++ )
		if ( SeatAvailable(i) )
			return true;

	return false;
}

/**
 * return a value indicating how useful this vehicle is to bots
 *
 * @param S				The Actor who desires this vehicle
 * @param TeamIndex		The Team index of S
 * @param Objective		The objective
 */

function float BotDesireability(UTSquadAI S, int TeamIndex, Actor Objective)
{
	local bool bSameTeam;
	local PlayerController P;

	bSameTeam = (Team == TeamIndex || Team == UTVEHICLE_UNSET_TEAM);
	if ( bSameTeam )
	{
		if ( !bKeyVehicle && (WorldInfo.TimeSeconds < PlayerStartTime) )
		{
			ForEach LocalPlayerControllers(class'PlayerController', P)
				break;
			if ( (P == None) || ((P.Pawn != None) && (Vehicle(P.Pawn) == None)) )
				return 0;
		}
	}
	if ( !bKeyVehicle && !bStationary && (WorldInfo.TimeSeconds < VehicleLostTime) )
		return 0;
	else if (Health <= 0 || bIsDisabled || (bTeamLocked && !bSameTeam) || Occupied())
	{
		return 0;
	}

	if (bKeyVehicle)
		return 100;

	return ((MaxDesireability * 0.5) + (MaxDesireability * 0.5 * (float(Health) / HealthMax)));
}

/**
 * AT Hint
 */
function float ReservationCostMultiplier(Pawn P)
{
	if ( Reservation == P.Controller )
		return 1.0;
	if ( UTGame(WorldInfo.Game).JustStarted(20) && (Reservation != None) && (Reservation.Pawn != None)
		&& (VSize(Reservation.Pawn.Location - Location) <= VSize(P.Location - Location)) )
	{
		return 0;
	}
	if ( (Reservation == None) || (Reservation.Pawn == None) )
		return 1.0;
	if ( (Reservation.MoveTarget == self) && Reservation.InLatentExecution(Reservation.LATENT_MOVETOWARD) )
		return 0;
	return 0.25;
}

/**
 * AI Hint
 */
function bool SpokenFor(Controller C)
{
	local UTBot B;

	if ( Reservation == None )
		return false;
	if ( (Reservation.Pawn == None) || (Vehicle(Reservation.Pawn) != None) )
	{
		Reservation = None;
		return false;
	}
	if ( ((Reservation.RouteGoal != self && (Reservation.RouteGoal != LastAnchor || LastAnchor == None)) && Reservation.MoveTarget != self)
		|| !Reservation.InLatentExecution(Reservation.LATENT_MOVETOWARD) )
	{
		Reservation = None;
		return false;
	}

	if ( !WorldInfo.GRI.OnSameTeam(Reservation,C) )
		return false;

	B = UTBot(C);
	if ( B == None )
		return true;
	if ( Seats.Length > 0 )
		return ( B.Squad != Reservation.Squad );
	if( UTGame(WorldInfo.Game).JustStarted(20) )
	{
		if ( VSize(Reservation.Pawn.Location - Location) > VSize(C.Pawn.Location - Location) )
			return false;
	}

	return true;
}

/* epic ===============================================
* ::StopsProjectile()
*
* returns true if Projectiles should call ProcessTouch() when they touch this actor
*/
simulated function bool StopsProjectile(Projectile P)
{
	// Don't block projectiles fired from this vehicle
	if ( P.Instigator == self )
		return false;

	// Don't block projectiles fired from turret on this vehicle
	return ( (P.Instigator == None) || (P.Instigator.Base != self) || !P.Instigator.IsA('UTWeaponPawn') );
}

/**
 * AI Hint
 */
function SetReservation(controller C)
{
	if ( !SpokenFor(C) )
		Reservation = UTBot(C);
}

/**
 * AI Hint
 */

function bool TeamLink(int TeamNum)
{
	return (LinkHealMult > 0 && Team == TeamNum && Health > 0);
}


/** called when the link gun hits an Actor that has this vehicle as its Owner
 * @param OwnedActor - the Actor owned by this vehicle that was hit
 * @return whether attempting to link to OwnedActor should be treated as linking to this vehicle
 */
simulated function bool AllowLinkThroughOwnedActor(Actor OwnedActor);

/**
 * This function is called to heal the vehicle
 * @See Actor.HealDamage()
 */

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if ( PlayerController(Healer) != None )
		PlayerStartTime = WorldInfo.TimeSeconds + 3;
	if (Health <= 0 || Health >= HealthMax || Amount <= 0 || Healer == None || !TeamLink(Healer.GetTeamNum()))
		return false;

	Amount = Min(Amount * LinkHealMult, HealthMax - Health);
	Health += Amount;

	if ( (Health >= HealthMax) && (SpawnInSound != None) )
	{
		PlaySound(SpawnInSound);
	}
	bForceNetUpdate = TRUE;

	ApplyMorphHeal(Amount);

	//  Add time to the reset timer if you are healing it.
	if ( ResetTime - WorldInfo.TimeSeconds < 10.0 )
		ResetTime = WorldInfo.TimeSeconds+10.0;

	CheckDamageSmoke();

	return true;
}

function IncrementLinkedToCount()
{
	if (LinkedToCount++ == 0)
	{
		StartLinkedEffect();
	}
}

function DecrementLinkedToCount()
{
	if (--LinkedToCount <= 0)
	{
		LinkedToCount = 0;
		StopLinkedEffect();
	}
}

/** function to call whenever a link gun links to this vehicle (e.g. to heal the Vehicle)*/
protected simulated function StartLinkedEffect()
{
	local MaterialInstanceConstant MIC;
	local LinearColor Red, Blue;
	local int i;

	Red = MakeLinearColor(4.0, 0.1, 0.0, 1.0);
	Blue = MakeLinearColor(0.0, 1.0, 4.0, 1.0);
	for (i = 0; i < Mesh.Materials.Length || i < Mesh.SkeletalMesh.Materials.Length; i++)
	{
		if (i < Mesh.Materials.Length)
		{
			MIC = MaterialInstanceConstant(Mesh.Materials[i]);
		}
		if (MIC == None)
		{
			if (i >= Mesh.Materials.Length || Mesh.Materials[i] == None)
			{
				Mesh.SetMaterial(i, Mesh.SkeletalMesh.Materials[i]);
			}
			MIC = Mesh.CreateAndSetMaterialInstanceConstant(i);
		}
		if (MIC != None)
		{
			MIC.SetVectorParameterValue('Veh_OverlayColor', (Team == 1) ? Blue : Red);
		}
	}
	if (LinkedToAudio == None)
	{
		LinkedToAudio = CreateAudioComponent(LinkedToCue, false, true);
	}
	if (LinkedToAudio != None)
	{
		LinkedToAudio.FadeIn(0.2f, 1.0f);
	}
}

/** function to call when a link gun unlinks */
protected simulated function StopLinkedEffect()
{
	local MaterialInstanceConstant mic;
	local LinearColor Black;
	local int i;

	for (i = 0; i < Mesh.Materials.Length; i++)
	{
		MIC = MaterialInstanceConstant(Mesh.Materials[i]);
		if (MIC != None)
		{
			MIC.SetVectorParameterValue('Veh_OverlayColor',Black);
		}
	}
	PlaySound(LinkedEndSound, true);
	if (LinkedToAudio != None)
	{
		LinkedToAudio.FadeOut(0.1f, 0.0f);
		LinkedToAudio = none;
	}
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	local UTPlayerController Hearer;
	local class<UTDamageType> UTDamage;

	if (InstigatedBy != None && class<UTDamageType>(DamageType) != None && class<UTDamageType>(DamageType).default.bDirectDamage)
	{
		Hearer = UTPlayerController(InstigatedBy);
		if (Hearer != None)
		{
			Hearer.bAcuteHearing = true;
		}
	}
	//@todo FIXME: play vehicle hit sound here?
	Super.PlayHit(Damage, InstigatedBy, HitLocation, DamageType, Momentum, HitInfo);
	if (Hearer != None)
	{
		Hearer.bAcuteHearing = false;
	}

	if (Damage > 0 || ((Controller != None) && Controller.bGodMode))
	{
		CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );

		LastTakeHitInfo.Damage = Damage;
		LastTakeHitInfo.HitLocation = HitLocation;
		LastTakeHitInfo.Momentum = Momentum;
		LastTakeHitInfo.DamageType = DamageType;
		LastTakeHitInfo.HitBone = HitInfo.BoneName;
		UTDamage = class<UTDamageType>(DamageType);
		LastTakeHitTimeout = WorldInfo.TimeSeconds + ( (UTDamage != None) ? UTDamage.static.GetHitEffectDuration(self, Damage)
									: class'UTDamageType'.static.GetHitEffectDuration(self, Damage) );

		PlayTakeHitEffects();
	}
}

/** plays take hit effects; called from PlayHit() on server and whenever LastTakeHitInfo is received on the client */
simulated event PlayTakeHitEffects()
{
	local class<UTDamageType> UTDamage;

	if (EffectIsRelevant(Location, false))
	{
		UTDamage = class<UTDamageType>(LastTakeHitInfo.DamageType);
		if (UTDamage != None)
		{
			UTDamage.static.SpawnHitEffect(self, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum, LastTakeHitInfo.HitBone, LastTakeHitInfo.HitLocation);
		}
	}

	ApplyMorphDamage(LastTakeHitInfo.HitLocation, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum);
	ClientHealth -= LastTakeHitInfo.Damage;
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int i;

	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);

	// notify anyone in turrets
	for (i = 1; i < Seats.length; i++)
	{
		if (Seats[i].SeatPawn != None)
		{
			Seats[i].SeatPawn.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
		}
	}
}

/**
 * @See Actor.TakeDamage()
 */
simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (Role == ROLE_Authority)
	{
		if ( (UTPawn(Driver) != None) && UTPawn(Driver).bIsInvulnerable )
			Damage = 0;
		else if ( DamageType == class'UTDmgType_ScorpionSelfDestruct' )
			Damage = class'UTDmgType_ScorpionSelfDestruct'.default.DamageGivenForSelfDestruct;
	}

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	if (Role == ROLE_Authority)
	{
		CheckDamageSmoke();
	}
}

/**
 * GetHomingTarget is called from projectiles looking to seek to this vehicle.  It returns the actor the projectile should target
 *
 * @param	Seeker			The projectile that seeking this vehcile
 * @param	InstigatedBy	Who is controlling that projectile
 * @returns the target to see
 */
event Actor GetHomingTarget(UTProjectile Seeker, Controller InstigatedBy)
{
	return self;
}

function bool ImportantVehicle()
{
	return false;
}

/*********************************************************************************************
 * Vehicle Weapons, Drivers and Passengers
 *********************************************************************************************/

/**
 * Create all of the vehicle weapons
 */
function InitializeSeats()
{
	local int i;
	if (Seats.Length==0)
	{
		`log("WARNING: Vehicle ("$self$") **MUST** have at least one seat defined");
		destroy();
		return;
	}

	for(i=0;i<Seats.Length;i++)
	{
		// Seat 0 = Driver Seat.  It doesn't get a WeaponPawn

		if (i>0)
		{
	   		Seats[i].SeatPawn = Spawn(class'UTWeaponPawn');
	   		Seats[i].SeatPawn.SetBase(self);
			Seats[i].Gun = UTVehicleWeapon(Seats[i].SeatPawn.InvManager.CreateInventory(Seats[i].GunClass));
			Seats[i].Gun.SetBase(self);
			Seats[i].SeatPawn.EyeHeight = Seats[i].SeatPawn.BaseEyeheight;
			UTWeaponPawn(Seats[i].SeatPawn).MyVehicleWeapon = UTVehicleWeapon(Seats[i].Gun);
			UTWeaponPawn(Seats[i].SeatPawn).MyVehicle = self;
	   		UTWeaponPawn(Seats[i].SeatPawn).MySeatIndex = i;

	   		if ( Seats[i].ViewPitchMin != 0.0f )
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMin = Seats[i].ViewPitchMin;
			}
			else
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMin = ViewPitchMin;
			}


	   		if ( Seats[i].ViewPitchMax != 0.0f )
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMax = Seats[i].ViewPitchMax;
			}
			else
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMax = ViewPitchMax;
			}
		}
		else
		{
			Seats[i].SeatPawn = self;
			Seats[i].Gun = UTVehicleWeapon(InvManager.CreateInventory(Seats[i].GunClass));
			Seats[i].Gun.SetBase(self);
		}

		Seats[i].SeatPawn.DriverDamageMult = Seats[i].DriverDamageMult;
		Seats[i].SeatPawn.bDriverIsVisible = Seats[i].bSeatVisible;

		if (Seats[i].Gun!=none)
		{
			UTVehicleWeapon(Seats[i].Gun).SeatIndex = i;
			UTVehicleWeapon(Seats[i].Gun).MyVehicle = self;
		}

		// Cache the names used to access various variables
   	}
}

simulated function PreCacheSeatNames()
{
	local int i;
	for (i=0;i<Seats.Length;i++)
	{
		Seats[i].WeaponRotationName	= NAME( Seats[i].TurretVarPrefix$"WeaponRotation" );
		Seats[i].FlashLocationName	= NAME( Seats[i].TurretVarPrefix$"FlashLocation" );
		Seats[i].FlashCountName		= NAME( Seats[i].TurretVarPrefix$"FlashCount" );
		Seats[i].FiringModeName		= NAME( Seats[i].TurretVarPrefix$"FiringMode" );
	}
}

simulated function InitializeTurrets()
{
	local int Seat, i;
	local UTSkelControl_TurretConstrained Turret;
	local vector PivotLoc, MuzzleLoc;

	if (Mesh == None)
	{
		`warn("No Mesh for" @ self);
	}
	else
	{
		for (Seat = 0; Seat < Seats.Length; Seat++)
		{
			for (i = 0; i < Seats[Seat].TurretControls.Length; i++)
			{
				Turret = UTSkelControl_TurretConstrained( Mesh.FindSkelControl(Seats[Seat].TurretControls[i]) );
				if ( Turret != none )
				{
					Turret.AssociatedSeatIndex = Seat;
					Seats[Seat].TurretControllers[i] = Turret;

					// Initialize turrets to vehicle rotation.
					Turret.InitTurret(Rotation, Mesh);
				}
				else
				{
					`warn("Failed to find skeletal controller named" @ Seats[Seat].TurretControls[i] @ "(Seat "$Seat$") for" @ self @ "in AnimTree" @ Mesh.AnimTreeTemplate);
				}
			}

			if(Role == ROLE_Authority)
			{
				SeatWeaponRotation(Seat, Rotation, FALSE);
			}

			// Calculate Z distance between weapon pivot and muzzle
			PivotLoc = GetSeatPivotPoint(Seat);
			GetBarrelLocationAndRotation(Seat, MuzzleLoc);

			Seats[Seat].PivotFireOffsetZ = MuzzleLoc.Z - PivotLoc.Z;
		}
	}
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C,bVehicleTransition);

	if (Seats[0].Gun!=none)
		Seats[0].Gun.ClientWeaponSet(false);
}

simulated function SetFiringMode(Weapon Weap, byte FiringModeNum)
{
	SeatFiringMode(0, FiringModeNum, false);
}

simulated function ClearFlashCount(Weapon Who)
{
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(Who);
	if (VWeap != none)
	{
		VehicleAdjustFlashCount(VWeap.SeatIndex, SeatFiringMode(VWeap.SeatIndex,,true), true);
	}

}

simulated function IncrementFlashCount(Weapon Who, byte FireModeNum)
{
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(Who);
	if (VWeap != none)
	{
		VehicleAdjustFlashCount(VWeap.SeatIndex, FireModeNum, false);
	}
}

simulated function SetFlashLocation( Weapon Who, byte FireModeNum, vector NewLoc )
{
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(Who);
	if (VWeap != none)
	{
		VehicleAdjustFlashLocation(VWeap.SeatIndex, FireModeNum, NewLoc,  false);
	}
}

/**
 * Reset flash location variable. and call stop firing.
 * Network: Server only
 */
function ClearFlashLocation( Weapon Who )
{
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(Who);
	if (VWeap != none)
	{
		VehicleAdjustFlashLocation(VWeap.SeatIndex, SeatFiringMode(VWeap.SeatIndex,,true), Vect(0,0,0),  true);
	}
}

simulated event GetBarrelLocationAndRotation(int SeatIndex, out vector SocketLocation, optional out rotator SocketRotation)
{
	if (Seats[SeatIndex].GunSocket.Length>0)
	{
		Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)], SocketLocation, SocketRotation);
	}
	else
	{
		SocketLocation = Location;
		SocketRotation = Rotation;
	}
}

simulated function vector GetEffectLocation(int SeatIndex)
{
	local vector SocketLocation;

	if ( Seats[SeatIndex].GunSocket.Length == 0 )
		return Location;

	GetBarrelLocationAndRotation(SeatIndex,SocketLocation);
	return SocketLocation;
}

simulated function Vector GetPhysicalFireStartLoc(UTWeapon ForWeapon)
{
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(ForWeapon);
	if ( VWeap != none )
	{
		return GetEffectLocation(VWeap.SeatIndex);
	}
	else
		return location;
}




/**
 * This function returns the aim for the weapon
 */
function rotator GetWeaponAim(UTVehicleWeapon VWeapon)
{
	local vector SocketLocation, CameraLocation, RealAimPoint, DesiredAimPoint, HitLocation, HitRotation, DirA, DirB;
	local rotator CameraRotation, SocketRotation, ControllerAim, AdjustedAim;
	local float DiffAngle, MaxAdjust;
	local Controller C;
	local PlayerController PC;
	local Quat Q;

	if ( VWeapon != none )
	{
		C = Seats[VWeapon.SeatIndex].SeatPawn.Controller;

		PC = PlayerController(C);
		if (PC != None)
		{
			PC.GetPlayerViewPoint(CameraLocation, CameraRotation);
			DesiredAimPoint = CameraLocation + Vector(CameraRotation) * VWeapon.GetTraceRange();
			if (Trace(HitLocation, HitRotation, DesiredAimPoint, CameraLocation) != None)
			{
				DesiredAimPoint = HitLocation;
			}
		}
		else if (C != None)
		{
			DesiredAimPoint = C.GetFocalPoint();
		}

		if ( Seats[VWeapon.SeatIndex].GunSocket.Length>0 )
		{
			GetBarrelLocationAndRotation(VWeapon.SeatIndex, SocketLocation, SocketRotation);
			if(VWeapon.bIgnoreSocketPitchRotation || ((DesiredAimPoint.Z - Location.Z)<0 && VWeapon.bIgnoreDownwardPitch))
			{
				SocketRotation.Pitch = Rotator(DesiredAimPoint - Location).Pitch;
			}
		}
		else
		{
			SocketLocation = Location;
			SocketRotation = Rotator(DesiredAimPoint - Location);
		}

		RealAimPoint = SocketLocation + Vector(SocketRotation) * VWeapon.GetTraceRange();
		DirA = normal(DesiredAimPoint - SocketLocation);
		DirB = normal(RealAimPoint - SocketLocation);
		DiffAngle = ( DirA dot DirB );
		MaxAdjust = VWeapon.GetMaxFinalAimAdjustment();
		if ( DiffAngle >= MaxAdjust )
		{
			// bit of a hack here to make bot aiming and single player autoaim work
			ControllerAim = (C != None) ? C.Rotation : Rotation;
			AdjustedAim = VWeapon.GetAdjustedAim(SocketLocation);
			if (AdjustedAim == VWeapon.Instigator.GetBaseAimRotation() || AdjustedAim == ControllerAim)
			{
				// no adjustment
				return rotator(DesiredAimPoint - SocketLocation);
			}
			else
			{
				// FIXME: AdjustedAim.Pitch = Instigator.LimitPitch(AdjustedAim.Pitch);
				return AdjustedAim;
			}
		}
		else
		{
			Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), ACos(MaxAdjust));
			return Rotator( QuatRotateVector(Q,DirB));
		}
	}
	else
	{
		return Rotation;
	}
}

/** Gives the vehicle an opportunity to override the functionality of the given fire mode, called on both the owning client and the server
	@return false to allow the vehicle weapon to use its behavior, true to override it */
simulated function bool OverrideBeginFire(byte FireModeNum);
simulated function bool OverrideEndFire(byte FireModeNum);

/**
 * GetWeaponViewAxes should be subclassed to support returningthe rotator of the various weapon points.
 */
simulated function GetWeaponViewAxes( UTWeapon WhichWeapon, out vector xaxis, out vector yaxis, out vector zaxis )
{
	GetAxes( Controller.Rotation, xaxis, yaxis, zaxis );
}

/**
 * Causes the muzzle flashlight to turn on and setup a time to
 * turn it back off again.
 */
simulated function CauseMuzzleFlashLight(int SeatIndex)
{
	// must have valid gunsocket
	if (Seats[SeatIndex].GunSocket.Length == 0 || bDeadVehicle)
		return;

	// only enable muzzleflash light if performance is high enough
	if ( !WorldInfo.bDropDetail || (Seats[SeatIndex].SeatPawn != None && PlayerController(Seats[SeatIndex].SeatPawn.Controller) != None && Seats[SeatIndex].SeatPawn.IsLocallyControlled()) )
	{
		if ( Seats[SeatIndex].MuzzleFlashLight == None )
		{
			if ( Seats[SeatIndex].MuzzleFlashLightClass != None )
			{
				Seats[SeatIndex].MuzzleFlashLight = new(Outer) Seats[SeatIndex].MuzzleFlashLightClass;
			}
		}
		else
		{
			Seats[SeatIndex].MuzzleFlashLight.ResetLight();
		}

		// FIXMESTEVE: OFFSET!

		if ( Seats[SeatIndex].MuzzleFlashLight != none )
		{
			Mesh.DetachComponent(Seats[SeatIndex].MuzzleFlashLight);
			Mesh.AttachComponentToSocket(Seats[SeatIndex].MuzzleFlashLight, Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)]);
		}
	}
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	VehicleWeaponFired(bViaReplication, HitLocation, 0);
}

/**
 * Vehicle will want to override WeaponFired and pass off the effects to the proper Seat
 */
simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	// Trigger any vehicle Firing Effects
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		VehicleWeaponFireEffects(HitLocation, SeatIndex);

		if (Role == ROLE_Authority || bViaReplication)
		{
			VehicleWeaponImpactEffects(HitLocation, SeatIndex);
		}

		if (SeatIndex == 0)
		{
			Seats[SeatIndex].Gun = UTVehicleWeapon(Weapon);
		}
		if (Seats[SeatIndex].Gun != None)
		{
			UTVehicleWeapon(Seats[SeatIndex].Gun).ShakeView();
		}
		if ( EffectIsRelevant(Location,false,MaxFireEffectDistance) )
		{
			CauseMuzzleFlashLight(SeatIndex);
		}
	}
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	VehicleWeaponStoppedFiring(bViaReplication, 0);
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	local name StopName;

	// Trigger any vehicle Firing Effects
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if (Role == ROLE_Authority || bViaReplication)
		{
			StopName = Name( "STOP_"$class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).static.GetFireTriggerTag( GetBarrelIndex(SeatIndex) , SeatFiringMode(SeatIndex,,true) ) );
			VehicleEvent( StopName );
		}
	}
}

/**
 * This function should be subclassed and manage the different effects
 */
simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
	VehicleEvent( class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).static.GetFireTriggerTag( GetBarrelIndex(SeatIndex), SeatFiringMode(SeatIndex,,true) ) );
}

/**
 * This function is here so that children vehicles can get access to the retrace to get the hitnormal.  See the Dark Walker
 */

simulated function actor FindWeaponHitNormal(out vector HitLocation, out Vector HitNormal, vector End, vector Start, out TraceHitInfo HitInfo)
{
	return Trace(HitLocation, HitNormal, End, Start, true,, HitInfo, TRACEFLAG_Bullet);
}

/**
 * Spawn any effects that occur at the impact point.  It's called from the pawn.
 */
simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local vector NewHitLoc, HitNormal, LightLoc;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	local Vehicle V;
	local Pawn EffectInstigator;
	local UTPlayerController PC;

	HitNormal = Normal(Location - HitLocation);
	HitActor = FindWeaponHitNormal(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32),HitInfo);

	if ( (HitActor == None) && (VSize(Location - HitLocation) > 10000) )
	{
		return;
	}

	if (Pawn(HitActor) != None)
	{
		CheckHitInfo(HitInfo, Pawn(HitActor).Mesh, -HitNormal, NewHitLoc);
	}
	// figure out the impact effect to use
	ImpactEffect = class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).static.GetImpactEffect(HitActor, HitInfo.PhysMaterial, SeatFiringMode(SeatIndex,, true));
	if (ImpactEffect.Sound != None)
	{
		// if hit a vehicle controlled by the local player, always play it full volume
		V = Vehicle(HitActor);
		if (V != None && V.IsLocallyControlled() && V.IsHumanControlled())
		{
			PlayerController(V.Controller).ClientPlaySound(ImpactEffect.Sound);
		}
		else
		{
			if ( (class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).default.BulletWhip != None) && (WorldInfo.GRI != None) )
			{
				ForEach LocalPlayerControllers(class'UTPlayerController', PC)
				{
					if (!WorldInfo.GRI.OnSameTeam(self, PC))
					{
						PC.CheckBulletWhip(class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).default.BulletWhip, Location, Normal(HitLocation - Location), HitLocation);
					}
				}
			}
			PlaySound(ImpactEffect.Sound, true,,, HitLocation);
		}
	}

	EffectInstigator = Seats[SeatIndex].SeatPawn;
	if (EffectInstigator == None)
	{
		EffectInstigator = self;
	}
	if (EffectInstigator.EffectIsRelevant(HitLocation, false, MaxImpactEffectDistance))
	{
		// Pawns handle their own hit effects
		if (HitActor != None && (Pawn(HitActor) == None || Vehicle(HitActor) != None))
		{
			// this code is mostly duplicated in:  UTGib, UTProjectile, UTVehicle, UTWeaponAttachment be aware when updating
			if ( !WorldInfo.bDropDetail && (Pawn(HitActor) == None) )
			{
				// if we have a decal to spawn on impact
				DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
				if( DecalMaterialsLength > 0 )
				{
					MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
					if( MI != None )
					{
						if( MaterialInstanceTimeVarying(MI) != none )
						{
							MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
							MITV_Decal.SetParent( MI );

							WorldInfo.MyDecalManager.SpawnDecal( MITV_Decal, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
							//here we need to see if we are an MITV and then set the burn out times to occur
							MITV_Decal.SetScalarStartTime( ImpactEffect.DecalDissolveParamName, ImpactEffect.DurationOfDecal );
						}
						else
						{
							WorldInfo.MyDecalManager.SpawnDecal( MI, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
						}
					}
				}
			}

			if (ImpactEffect.ParticleTemplate != None)
			{
				SpawnImpactEmitter(HitLocation, HitNormal, ImpactEffect, SeatIndex );
				if ( (Seats[SeatIndex].ImpactFlashLightClass != None) && (WorldInfo.GetDetailMode() != DM_Low) && !class'Engine'.static.IsSplitScreen()
					&& (!WorldInfo.bDropDetail || (Seats[SeatIndex].SeatPawn != None && PlayerController(Seats[SeatIndex].SeatPawn.Controller) != None && Seats[SeatIndex].SeatPawn.IsLocallyControlled())) )
				{
					LightLoc = HitLocation + ((0.5 * Seats[SeatIndex].ImpactFlashLightClass.default.TimeShift[0].Radius * vect(1,0,0)) >> rotator(HitNormal));
					UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(Seats[SeatIndex].ImpactFlashLightClass, LightLoc);
				}
			}
		}
	}
}

simulated function SpawnImpactEmitter(vector HitLocation, vector HitNormal, const out MaterialImpactEffect ImpactEffect, int SeatIndex)
{
	WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal));
}

/**
 * These two functions needs to be subclassed in each weapon
 */
simulated function VehicleAdjustFlashCount(int SeatIndex, byte FireModeNum, optional bool bClear)
{
	if (bClear)
	{
		SeatFlashCount( SeatIndex, 0 );
		VehicleWeaponStoppedFiring( false, SeatIndex );
	}
	else
	{
		SeatFiringMode(SeatIndex,FireModeNum);
		SeatFlashCount( SeatIndex, SeatFlashCount(SeatIndex,,true)+1 );
		VehicleWeaponFired( false, vect(0,0,0), SeatIndex );
		Seats[SeatIndex].BarrelIndex++;
	}

	bForceNetUpdate = TRUE;	// Force replication
}

simulated function VehicleAdjustFlashLocation(int SeatIndex, byte FireModeNum, vector NewLocation, optional bool bClear)
{
	if (bClear)
	{
		SeatFlashLocation( SeatIndex, Vect(0,0,0) );
		VehicleWeaponStoppedFiring( false, SeatIndex );
	}
	else
	{
		// Make sure 2 consecutive flash locations are different, for replication
		if( NewLocation == SeatFlashLocation(SeatIndex,,true) )
		{
			NewLocation += vect(0,0,1);
		}

		// If we are aiming at the origin, aim slightly up since we use 0,0,0 to denote
		// not firing.
		if( NewLocation == vect(0,0,0) )
		{
			NewLocation = vect(0,0,1);
		}

		SeatFiringMode(SeatIndex,FireModeNum);
		SeatFlashLocation( SeatIndex, NewLocation );
		VehicleWeaponFired( false, NewLocation, SeatIndex );
		Seats[SeatIndex].BarrelIndex++;
	}


	bForceNetUpdate = TRUE;	// Force replication
}

/** Used by PlayerController.FindGoodView() in RoundEnded State */
simulated function FindGoodEndView(PlayerController PC, out Rotator GoodRotation)
{
	local vector cameraLoc;
	local rotator cameraRot, ViewRotation;
	local int tries;
	local float bestdist, newdist, FOVAngle;

	ViewRotation = GoodRotation;
	ViewRotation.Pitch = 56000;
	tries = 0;
	bestdist = 0.0;
	for (tries=0; tries<16; tries++)
	{
		cameraLoc = Location;
		cameraRot = ViewRotation;
		CalcCamera( 0, cameraLoc, cameraRot, FOVAngle );
		newdist = VSize(cameraLoc - Location);
		if (newdist > bestdist)
		{
			bestdist = newdist;
			GoodRotation = cameraRot;
		}
		ViewRotation.Yaw += 4096;
	}
}

/**
 * We override CalcCamera so as to use the Camera Distance of the seat
 */
simulated function bool CalcCamera(float DeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV)
{
    local vector out_CamStart;

	VehicleCalcCamera(DeltaTime, 0, out_CamLoc, out_CamRot, out_CamStart);
	return true;
}

/**
  * returns the camera focus position (without camera lag)
  */
simulated function vector GetCameraFocus(int SeatIndex)
{
	local vector CamStart, HitLocation, HitNormal;
	local actor HitActor;

	//  calculate camera focus
	if ( !bDeadVehicle && Seats[SeatIndex].CameraTag != '' )
	{
		Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].CameraTag, CamStart);

		// Do a line check from actor location to this socket. If we hit the world, use that location instead.
		HitActor = Trace(HitLocation, HitNormal, CamStart, Location, FALSE, vect(12,12,12));
		if( HitActor != None )
		{
			CamStart = HitLocation;
		}
	}
	else
	{
		CamStart = Location;
	}
	CamStart += (Seats[SeatIndex].CameraBaseOffset >> Rotation);
	//DrawDebugSphere(CamStart, 8, 10, 0, 255, 0, FALSE);
	//DrawDebugSphere(Location, 8, 10, 255, 255, 0, FALSE);
	return CamStart;
}

/**
  * returns the camera focus position (adjusted for camera lag)
  */
simulated function vector GetCameraStart(int SeatIndex)
{
	local int i, len, obsolete;
	local vector CamStart;
	local float OriginalCamZ;
	local TimePosition NewPos, PrevPos;
	local float DeltaTime;

	// If we've already updated the cameraoffset, just return it
	len = OldPositions.Length;
	if (len > 0 && SeatIndex == 0 && OldPositions[len-1].Time == WorldInfo.TimeSeconds)
	{
		return CameraOffset + Location;
	}

	CamStart = GetCameraFocus(SeatIndex);
	OriginalCamZ = CamStart.Z;
	if (CameraLag == 0 || SeatIndex != 0 || !IsHumanControlled())
	{
		return CamStart;
	}

	// cache our current location
	NewPos.Time = WorldInfo.TimeSeconds;
	NewPos.Position = CamStart;
	OldPositions[len] = NewPos;

	// if no old locations saved, return offset
	if ( len == 0 )
	{
		CameraOffset = CamStart - Location;
		return CamStart;
	}
	DeltaTime = (len > 1) ? (WorldInfo.TimeSeconds - OldPositions[len-2].Time) : 0.0;

	len = OldPositions.Length;
	obsolete = 0;
	for ( i=0; i<len; i++ )
	{
		if ( OldPositions[i].Time < WorldInfo.TimeSeconds - CameraLag )
		{
			PrevPos = OldPositions[i];
			obsolete++;
		}
		else
		{
			if ( Obsolete > 0 )
			{
				// linear interpolation to maintain same distance in past
				if ( (i == 0) || (OldPositions[i].Time - PrevPos.Time > 0.2) )
				{
					CamStart = OldPositions[i].Position;
				}
				else
				{
					CamStart = PrevPos.Position + (OldPositions[i].Position - PrevPos.Position)*(WorldInfo.TimeSeconds - CameraLag - PrevPos.Time)/(OldPositions[i].Time - PrevPos.Time);
				}
				if ( Obsolete > 1)
					OldPositions.Remove(0, obsolete-1);
			}
			else
			{
				CamStart = OldPositions[i].Position;
			}
			// need to smooth camera to vehicle distance, since vehicle update rate not synched with frame rate
			if ( DeltaTime > 0 )
			{
				DeltaTime *= CameraSmoothingFactor;
				CameraOffset = (CamStart - Location)*DeltaTime + CameraOffset*(1-DeltaTime);
				if ( bNoZSmoothing )
				{
					// don't smooth z - want it bouncy
					CameraOffset.Z = CamStart.Z - Location.Z;
				}
			}
			else
			{
				CameraOffset = CamStart - Location;
			}
			CamStart = CameraOffset + Location;
			if ( bLimitCameraZLookingUp )
			{
				CamStart.Z = LimitCameraZ(CamStart.Z, OriginalCamZ, SeatIndex);
			}
			return CamStart;
		}
	}
	CamStart = OldPositions[len-1].Position;
	if ( bLimitCameraZLookingUp )
	{
		CamStart.Z = LimitCameraZ(CamStart.Z, OriginalCamZ, SeatIndex);
	}
	return CamStart;
}


/**
  * returns the camera focus position (adjusted for camera lag)
  */
simulated function float LimitCameraZ(float CurrentCamZ, float OriginalCamZ, int SeatIndex)
{
	local rotator CamRot;
	local float Pct;

	CamRot = Seats[SeatIndex].SeatPawn.GetViewRotation();
	CamRot.Pitch = CamRot.Pitch & 65535;
	if ( (CamRot.Pitch < 32768) )
	{
		Pct = FClamp(float(CamRot.Pitch)*0.00025, 0.0, 1.0);
		CurrentCamZ = OriginalCamZ*Pct + CurrentCamZ*(1.0-Pct);
	}
	return CurrentCamZ;
}

simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	local vector CamPos, CamDir, HitLocation, FirstHitLocation, HitNormal, CamRotX, CamRotY, CamRotZ, SafeLocation, X, Y, Z;
	local actor HitActor;
	local float NewCamStartZ;
	local UTPawn P;
	local bool bObstructed, bInsideVehicle;

	Mesh.SetOwnerNoSee(false);
	if ( (UTPawn(Driver) != None) && !Driver.bHidden && Driver.Mesh.bOwnerNoSee )
		UTPawn(Driver).SetMeshVisibility(true);

	// Handle the fixed view
	P = UTPawn(Seats[SeatIndex].SeatPawn.Driver);
	if (P != None && P.bFixedView)
	{
		out_CamLoc = P.FixedViewLoc;
		out_CamRot = P.FixedViewRot;
		return;
	}

	CamStart = GetCameraStart(SeatIndex);

	// Get the rotation
	if ( (Seats[SeatIndex].SeatPawn.Controller != None) && !bSpectatedView  )
	{
		out_CamRot = Seats[SeatIndex].SeatPawn.GetViewRotation();
	}

	// support debug 3rd person cam
	if (P != None)
	{
		P.ModifyRotForDebugFreeCam(out_CamRot);
	}

	GetAxes(out_CamRot, CamRotX, CamRotY, CamRotZ);
	CamStart += (Seats[SeatIndex].SeatPawn.EyeHeight + LookForwardDist * FMax(0,(1.0 - CamRotZ.Z)))* CamRotZ;

	/* if bNoFollowJumpZ, Z component of Camera position is fixed during a jump */
	if ( bNoFollowJumpZ )
	{
		NewCamStartZ = CamStart.Z;
		if ( (Velocity.Z > 0) && !HasWheelsOnGround() && (OldCamPosZ != 0) )
		{
			// upward part of jump. Fix camera Z position.
			bFixedCamZ = true;
			if ( OldPositions.Length > 0 )
				OldPositions[OldPositions.Length-1].Position.Z += (OldCamPosZ - CamStart.Z);
			CamStart.Z = OldCamPosZ;
			if ( NewCamStartZ - CamStart.Z > 64 )
				CamStart.Z = NewCamStartZ - 64;
		}
		else if ( bFixedCamZ )
		{
			// Camera z position is being fixed, now descending
			if ( HasWheelsOnGround() || (CamStart.Z <= OldCamPosZ) )
			{
				// jump has ended
				if ( DeltaTime >= 0.1 )
				{
					// all done
					bFixedCamZ = false;
				}
				else
				{
					// Smoothly return to normal camera mode.
					CamStart.Z = 10*DeltaTime*CamStart.Z + (1 - 10*DeltaTime)*OldCamPosZ;
					if ( abs(NewCamStartZ - CamStart.Z) < 1.f )
						bFixedCamZ = false;
				}
			}
			else
			{
				// descending from jump, still in the air, so fix camera Z position
				if ( OldPositions.Length > 0 )
					OldPositions[OldPositions.Length-1].Position.Z += (OldCamPosZ - CamStart.Z);
				CamStart.Z = OldCamPosZ;
			}
		}
	}

	// Trace up to the view point to make sure it's not obstructed.
	if ( Seats[SeatIndex].CameraSafeOffset == vect(0,0,0) )
	{
		SafeLocation = Location;
	}
	else
	{
	    GetAxes(Rotation, X, Y, Z);
	    SafeLocation = Location + Seats[SeatIndex].CameraSafeOffset.X * X + Seats[SeatIndex].CameraSafeOffset.Y * Y + Seats[SeatIndex].CameraSafeOffset.Z * Z;
	}
	// DrawDebugSphere(SafeLocation, 16, 10, 255, 0, 255, FALSE);
	// DrawDebugSphere(CamStart, 16, 10, 255, 255, 0, FALSE);

	HitActor = Trace(HitLocation, HitNormal, CamStart, SafeLocation, false, vect(12, 12, 12));
	if ( HitActor != None)
	{
			bObstructed = true;
			CamStart = HitLocation;
			//`log("obstructed 0");
	}

	OldCamPosZ = CamStart.Z;
	if (bPivotOnly)
	{
		out_CamLoc = CamStart;
		return;
	}

	// Calculate the optimal camera position
	CamDir = CamRotX * Seats[SeatIndex].CameraOffset * SeatCameraScale;

	// keep camera from going below vehicle
	if ( !bRotateCameraUnderVehicle && (CamDir.Z < 0) )
	{
		CamDir *= (VSize(CamDir) - abs(CamDir.Z))/(VSize(CamDir) + abs(CamDir.Z));
	}

	CamPos = CamStart + CamDir;

	// Adjust for obstructions
	HitActor = Trace(HitLocation, HitNormal, CamPos, CamStart, false, vect(12, 12, 12));

	if ( HitActor != None )
	{
		out_CamLoc = HitLocation;
		bObstructed = true;
		//`log("obstructed 2");
	}
	else
	{
		out_CamLoc = CamPos;
	}
	if ( !bRotateCameraUnderVehicle && (CamDir.Z < 0) && TraceComponent( FirstHitLocation, HitNormal, CollisionComponent, out_CamLoc, CamStart, vect(0,0,0)) )
	{
		// going through vehicle - it's ok if outside collision on other side
		if ( !TraceComponent( HitLocation, HitNormal, CollisionComponent, CamStart, out_CamLoc, vect(0,0,0)) )
		{
			// end point is inside collision - that's bad
			out_CamLoc = FirstHitLocation;
			bObstructed = true;
			bInsideVehicle = true;
			//`log("obstructed 1");
		}
	}

	// if trace doesn't hit collisioncomponent going back in, it means we are inside the collision box
	// in which case we want to hide the vehicle
	if ( !bCameraNeverHidesVehicle && bObstructed )
	{
		bInsideVehicle = bInsideVehicle
						|| !TraceComponent( HitLocation, HitNormal, CollisionComponent, SafeLocation, out_CamLoc, vect(0,0,0))
						|| (VSizeSq(HitLocation - out_CamLoc) < MinCameraDistSq);
		Mesh.SetOwnerNoSee(bInsideVehicle);
		if ( (UTPawn(Driver) != None) && !Driver.bHidden && (Driver.Mesh.bOwnerNoSee != Mesh.bOwnerNoSee) )
		{
			// Handle the main player mesh
			Driver.Mesh.SetOwnerNoSee(Mesh.bOwnerNoSee);
		}
	}
}

/** moves the camera in or out */
simulated function AdjustCameraScale(bool bMoveCameraIn)
{
	//SeatCameraScale = FMax(0.0, SeatCameraScale + (bMoveCameraIn ? -0.1 : 0.1));
	//`log("New camera scale "$SeatCameraScale);
}


simulated function StartBurnOut()
{
	local int i;
	local int NumBurnOutMaterials;

	// here we need to check to see if we are a vehicle which is falling down from the sky!
	// if we are then we want to push the actual burn out til after we have hit the ground (and possibly do a secondary explosion)
	if( Velocity.Z < -100.0f )
	{
		DelayedBurnoutCount++;
		if ( DelayedBurnoutCount < 6 )
		{
		SetTimer( 1.0f, false, 'StartBurnOut' );
		LifeSpan += 1.0f;
		return;
	}
	}

	if (SpawnOutSound != none)
	{
		PlaySound( SpawnOutSound, TRUE );
	}

	bIsBurning = TRUE;
	SetTimer( 0.500, FALSE, 'DisableCollision' ); // turn off collision quicker rather than slower for when vehicles are burning out
	DisableDamageSmoke();
	StopVehicleSounds();

	NumBurnOutMaterials = BurnOutMaterialInstances.length;
	for( i = 0; i < NumBurnOutMaterials; ++i )
	{
		if( BurnOutMaterialInstances[i].MITV != None )
		{
			//`log( NumBurnOutMaterials $ " starting burnout on: " $ BurnOutMaterialInstances[i].MITV $ " " $ self );
			 BurnOutMaterialInstances[i].MITV.SetScalarStartTime( 'BurnTime', 0.0f );
		}
	}

	// these will turn off the damage Particle Effects (smoke/fire/sparks)
	VehicleEvent( 'NoDamageSmoke' );
	if( DeathExplosion != none )
	{
		DeathExplosion.ParticleSystemComponent.DeactivateSystem();
	}

	// wait a few before turning off shadows (this reduces the jarring pop that you see if everything happens all at once)
	SetTimer( 0.5f, FALSE, 'TurnOffShadows' );
}

/** This will turn off the shadow casting of the vehicle **/
simulated function TurnOffShadows()
{
	// turn off any shadows we have
	UpdateShadowSettings( FALSE );
	//Mesh.CastShadow = FALSE;
	//DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = FALSE;
}


/** deactivates smoke/fire emitter when vehicle is mostly burned out */
simulated function DisableDamageSmoke()
{
	VehicleEvent('NoDamageSmoke');
}

/** turns off collision on the vehicle when it's almost fully burned out */
simulated function DisableCollision()
{
	SetCollision(false);
	Mesh.SetBlockRigidBody(false);
}

simulated function SetBurnOut()
{
	local int i, NumElements;
	local int TeamNum;
	local BurnOutDatum BOD;
	local UTCarriedObject Flag;

	if ( LifeSpan != 0 )
		return;

	TeamNum = GetTeamNum();

	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	// burn out immediately if parked on flag
	ForEach TouchingActors(class'UTCarriedObject', Flag)
	{
		DeadVehicleLifeSpan = BurnOutTime + 0.01;
		break;
	}
	LifeSpan = DeadVehicleLifeSpan;

	// set up material instance (for burnout effects)
	if (BurnOutMaterial[TeamNum] != None)
	{
		Mesh.SetMaterial(0,BurnOutMaterial[TeamNum]);
		if(DestroyedTurret != none)
		{
			DestroyedTurret.GibMeshComp.SetMaterial(0,BurnOutMaterial[TeamNum]);
		}
	}

	NumElements = Mesh.GetNumElements();
	for (i = 0; i < NumElements; i++)
	{
		BOD.MITV = Mesh.CreateAndSetMaterialInstanceTimeVarying(i);
		BurnOutMaterialInstances[BurnOutMaterialInstances.length] = BOD;

		if(DestroyedTurret != none)
		{
			DestroyedTurret.GibMeshComp.SetMaterial(i,BurnOutMaterialInstances[i].MITV);
		}

	//Set the time here to arbitrary amount to stall effect until StartBurnOut is called
		BOD.MITV.SetScalarStartTime('BurnTime', LifeSpan - BurnOutTime);
	}
	RemainingBurn = BurnOutTime;
	SetTimer(LifeSpan - BurnOutTime, false, 'StartBurnOut');
}

/** ShouldSpawnExplosionLight()
Decide whether or not to create an explosion light for this explosion
*/
simulated function bool ShouldSpawnExplosionLight(vector HitLocation, vector HitNormal)
{
	local PlayerController P;
	local float Dist;

	// decide whether to spawn explosion light
	ForEach LocalPlayerControllers(class'PlayerController', P)
	{
		Dist = VSize(P.ViewTarget.Location - Location);
		if ( (P.Pawn == Instigator) || (Dist < ExplosionLightClass.Default.Radius) || ((Dist < MaxExplosionLightDistance) && ((vector(P.Rotation) dot (Location - P.ViewTarget.Location)) > 0)) )
		{
			return true;
		}
	}
	return false;
}

/** Called when a contact with a large penetration occurs. */
event RBPenetrationDestroy()
{
	if (Health > 0)
	{
		//`log("Penetration Death:"@self@Penetration);
		TakeDamage(10000, GetCollisionDamageInstigator(), Location, vect(0,0,0), class'UTDmgType_VehicleCollision');
	}
}

simulated state DyingVehicle
{
	ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon) {}
	simulated function PlayNextAnimation() {}
	singular event BaseChange() {}
	event Landed(vector HitNormal, Actor FloorActor) {}

	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);

	simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir) {}

	simulated function BlowupVehicle() {}

	simulated function CheckDamageSmoke();

	/** spawn an explosion effect and damage nearby actors */
	simulated function DoVehicleExplosion(bool bDoingSecondaryExplosion)
	{
		local UTPlayerController UTPC;
		local float Dist, ShakeScale, MinViewDist;
		local ParticleSystem Template;
		local SkelControlListHead LH;
		local SkelControlBase NextSkelControl;
		local UTSkelControl_Damage DamSkelControl;
		local vector BoneLocation;
		local bool bIsVisible;

		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			if ( bDoingSecondaryExplosion )
			{
				// already checked visibility
				bIsVisible = true;
			}
			else
			{
				// viewshakes and visibility check
				MinViewDist = 10000.0;
				foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
				{
					Dist = VSize(Location - UTPC.ViewTarget.Location);
					if (UTPC == KillerController)
					{
						bIsVisible = true;
						Dist *= 0.25;
					}
					MinViewDist = FMin(Dist, MinViewDist);
					if (Dist < OuterExplosionShakeRadius)
					{
						bIsVisible = true;
						if (DeathExplosionShake != None)
						{
							ShakeScale = 1.0;
							if (Dist > InnerExplosionShakeRadius)
							{
								ShakeScale -= (Dist - InnerExplosionShakeRadius) / (OuterExplosionShakeRadius - InnerExplosionShakeRadius);
							}
							UTPC.PlayCameraAnim(DeathExplosionShake, ShakeScale);
						}
					}
				}
				bIsVisible = bIsVisible || (WorldInfo.TimeSeconds - LastRenderTime < 3.0);
			}

			// determine which explosion to use
			if ( bIsVisible )
			{
				if( !bDoingSecondaryExplosion )
				{
					if( BigExplosionTemplates.length > 0 )
					{
						Template = class'UTEmitter'.static.GetTemplateForDistance(BigExplosionTemplates, Location, WorldInfo);
					}
				}
				else
				{
					Template = SecondaryExplosion;
				}

				PlayVehicleExplosionEffect( Template, !bDoingSecondaryExplosion );
			}

			if (ExplosionSound != None)
			{
				PlaySound(ExplosionSound, true);
			}

			// this will break only pieces that are marked for OnDeath
			if( MinViewDist < 6000.0 && Mesh != none && AnimTree(Mesh.Animations) != none)
			{
				// look at the first SkelControler for each bone
				foreach AnimTree(Mesh.Animations).SkelControlLists(LH)
				{
					// then look down the list of the nodes that may exist
					NextSkelControl = LH.ControlHead;
					while (NextSkelControl != None)
					{
						DamSkelControl = UTSkelControl_Damage(NextSkelControl);
						if( DamSkelControl != none)
						{
							if( DamSkelControl.bOnDeathUseForSecondaryExplosion == bDoingSecondaryExplosion )
							{
								BoneLocation = Mesh.GetBoneLocation(LH.BoneName);
								DamSkelControl.BreakApartOnDeath(BoneLocation, bIsVisible);
							}
						}

						NextSkelControl = NextSkelControl.NextControl;
					}
				}
			}
		}
		HurtRadius(ExplosionDamage, ExplosionRadius, class'UTDmgType_VehicleExplosion', ExplosionMomentum, Location,, GetCollisionDamageInstigator());
		AddVelocity((ExplosionMomentum / Mass) * vect(0,0,1), Location, class'UTDmgType_VehicleExplosion');

		// If in air, add some anglar spin.
		if(Role == ROLE_Authority && !bVehicleOnGround)
		{
			Mesh.SetRBAngularVelocity(VRand() * ExplosionInAirAngVel, TRUE);
		}
	}

	/** This will spawn the actual explosion particle system.  It could be a fiery death or just dust when the vehicle hits the ground **/
	simulated function PlayVehicleExplosionEffect( ParticleSystem TheExplosionTemplate, bool bSpawnLight )
	{
		local UDKExplosionLight L;

		if (TheExplosionTemplate != None)
		{
			DeathExplosion = Spawn(class'UTEmitter', self);
			if (BigExplosionSocket != 'None')
			{
				DeathExplosion.SetBase(self,, Mesh, BigExplosionSocket);
			}
			DeathExplosion.SetTemplate(TheExplosionTemplate, true);
			DeathExplosion.ParticleSystemComponent.SetFloatParameter('Velocity', VSize(Velocity) / GroundSpeed);

			if (bSpawnLight && ExplosionLightClass != None && !WorldInfo.bDropDetail && ShouldSpawnExplosionLight(Location, vect(0,0,1)))
			{
				L = new(DeathExplosion) ExplosionLightClass;
				DeathExplosion.AttachComponent(L);
			}
		}
	}

	/** This does the secondary explosion of the vehicle (e.g. from reserve fuel tanks finally blowing / ammo blowing up )**/
	simulated function SecondaryVehicleExplosion()
	{
		// here we need to check to see if we are a vehicle which is falling down from the sky!
		// if we are then we want to push the actual burn out til after we have hit the ground (and don secondary explosion)
		if( Velocity.Z < -100.0f )
		{
			SetTimer( 1.0f, false, 'SecondaryVehicleExplosion' );
			LifeSpan += 1.0f;

			return;
		}
		// we are just going to have vehicles do a "secondary explosion" of dust and rock based on RigidBodyCollision
		//PerformSecondaryVehicleExplosion();
	}

	simulated function PerformSecondaryVehicleExplosion()
	{
		local UTPlayerController UTPC;
		local bool bIsVisible;

		Mesh.SetNotifyRigidBodyCollision( FALSE );

		// only actually do secondary explosion if being rendered
		foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
		{
			if ( (LocalPlayer(UTPC.Player) != None) && LocalPlayer(UTPC.Player).GetActorVisibility(self)
				&& (UTPC.ViewTarget != None) )
			{
				bIsVisible = (UTPC == KillerController) || (VSizeSq(UTPC.ViewTarget.Location - Location) < 25000000.0);
				break;
			}
		}
		if ( bIsVisible )
		{
			DoVehicleExplosion(true);
		}
	}

	simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData Collision, int ContactIndex )
	{
		Super.RigidBodyCollision(HitComponent, OtherComponent, Collision, ContactIndex);

		if( IsTimerActive( 'SecondaryVehicleExplosion' ) )
		{
			ClearTimer( 'SecondaryVehicleExplosion' );
			PerformSecondaryVehicleExplosion();
		}
	}


	simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		if (DamageType != None)
		{
			Damage *= DamageType.static.VehicleDamageScalingFor(self);

			Health -= Damage;
			AddVelocity(Momentum, HitLocation, DamageType, HitInfo);

			if (DamageType == class'UTDmgType_VehicleCollision')
			{
				if ( EffectIsRelevant(Location, false) )
				{
					WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, HitLocation, rotator(vect(0,0,1)));
				}
				if (ExplosionSound != None)
				{
					PlaySound(ExplosionSound, true);
				}
			}
		}
	}

	/**
	*	Calculate camera view point, when viewing this pawn.
	*
	* @param	fDeltaTime	delta time seconds since last update
	* @param	out_CamLoc	Camera Location
	* @param	out_CamRot	Camera Rotation
	* @param	out_FOV		Field of View
	*
	* @return	true if Pawn should provide the camera point of view.
	*/
	simulated function VehicleCalcCamera(float fDeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
	{
 		Global.VehicleCalcCamera(fDeltaTime, SeatIndex, out_CamLoc, out_CamRot, CamStart, bPivotOnly);
		bStopDeathCamera = bStopDeathCamera || (out_CamLoc.Z < WorldInfo.KillZ);
		if ( bStopDeathCamera && (OldCameraPosition != vect(0,0,0)) )
		{
			// Don't allow camera to go below killz, by re-using old camera position once dead vehicle falls below killz
		   	out_CamLoc = OldCameraPosition;
			out_CamRot = rotator(CamStart - out_CamLoc);
		}
		OldCameraPosition = out_CamLoc;
	}

	simulated function BeginState(name PreviousStateName)
	{
		local int i;

		StopVehicleSounds();

		// make sure smoke/fire are on
		DamageSmokeThreshold = 0.0; //VehicleEvent('DamageSmoke');
		CheckDamageSmoke();
		// fully destroy all morph targets
		for (i = 0; i < DamageMorphTargets.length; i++)
		{
			DamageMorphTargets[i].Health = 0;
			if(DamageMorphTargets[i].MorphNode != none)
			{
				DamageMorphTargets[i].MorphNode.SetNodeWeight(1.0);
			}
		}

		UpdateDamageMaterial();
		ClientHealth = Min(ClientHealth, 0);

		LastCollisionSoundTime = WorldInfo.TimeSeconds;
		DoVehicleExplosion(false);

		if( TimeTilSecondaryVehicleExplosion > 0.0f )
		{
			SetTimer( TimeTilSecondaryVehicleExplosion, FALSE, 'SecondaryVehicleExplosion' );
		}

		for(i=0; i<DamageSkelControls.length; i++)
		{
			DamageSkelControls[i].HealthPerc = 0.f;
		}

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			PerformDeathEffects();
		}
		SetBurnOut();

		if (Controller != None)
		{
			if (Controller.bIsPlayer)
			{
				DetachFromController();
			}
			else
			{
				Controller.Destroy();
			}
		}

		for (i = 0; i < Attached.length; i++)
		{
			if (Attached[i] != None)
			{
				Attached[i].PawnBaseDied();
			}
		}
	}

	simulated function PerformDeathEffects()
	{
		if (bHasTurretExplosion)
		{
			TurretExplosion();
		}
	}


}

simulated function TurretExplosion()
{
	local vector SpawnLoc;
	local rotator SpawnRot;
	local SkelControlBase SK;
	local vector Force;

	Mesh.GetSocketWorldLocationAndRotation(TurretSocketName,SpawnLoc,SpawnRot);

	WorldInfo.MyEmitterPool.SpawnEmitter( class'UTEmitter'.static.GetTemplateForDistance(DistanceTurretExplosionTemplates, SpawnLoc, WorldInfo),Location, Rotation );

	DestroyedTurret = Spawn(class'UTVehicleDeathPiece',self,,SpawnLoc+TurretOffset,SpawnRot,,true);
	if(DestroyedTurret != none)
	{
		StaticMeshComponent(DestroyedTurret.GibMeshComp).SetStaticMesh(DestroyedTurretTemplate);
		//DestroyedTurret.SetCollision( FALSE, FALSE, TRUE );
		DestroyedTurret.GibMeshComp.SetBlockRigidBody( FALSE );
	// @todo make a RBChannelContainer function to do all this
		DestroyedTurret.GibMeshComp.SetRBChannel( RBCC_Nothing ); // nothing will request to collide with us
		DestroyedTurret.GibMeshComp.SetRBCollidesWithChannel( RBCC_Default, FALSE );
		DestroyedTurret.GibMeshComp.SetRBCollidesWithChannel( RBCC_Pawn, FALSE );
		DestroyedTurret.GibMeshComp.SetRBCollidesWithChannel( RBCC_Vehicle, FALSE );
		DestroyedTurret.GibMeshComp.SetRBCollidesWithChannel( RBCC_GameplayPhysics, FALSE );
		DestroyedTurret.GibMeshComp.SetRBCollidesWithChannel( RBCC_EffectPhysics, FALSE );

		DestroyedTurret.SetTimer( 0.100f, FALSE, 'TurnOnCollision' );

		SK = Mesh.FindSkelControl(TurretScaleControlName);
		if(SK != none)
		{
			SK.boneScale = 0.0f;
		}
		Force = Vect(0,0,1);
		Force *= TurretExplosiveForce;
		// Let's at least try and go off in some direction
		Force.X = FRand()*1000.0f + 400.0f;
		Force.Y = FRand()*1000.0f + 400.0f;
		DestroyedTurret.GibMeshComp.AddImpulse(Force);
		DestroyedTurret.GibMeshComp.SetRBAngularVelocity(VRand()*500.0f);
	}
}

simulated function StopVehicleSounds()
{
	local int seatIdx;
	Super.StopVehicleSounds();
	for(seatIdx=0;seatIdx < Seats.Length; ++seatIdx)
	{
		if(Seats[seatIdx].SeatMotionAudio != none)
		{
			Seats[seatIdx].SeatMotionAudio.Stop();
		}
	}
}

simulated function CheckDamageSmoke()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		VehicleEvent((float(Health) / float(HealthMax) < DamageSmokeThreshold) ? 'DamageSmoke' : 'NoDamageSmoke');
	}
}

simulated function AttachDriver( Pawn P )
{
	local UTPawn UTP;

	// reset vehicle camera
	OldPositions.remove(0,OldPositions.Length);
	Eyeheight = BaseEyeheight;

	UTP = UTPawn(P);
	if (UTP != None)
	{
		UTP.SetWeaponAttachmentVisibility(false);
		UTP.SetHandIKEnabled(false);
		if (bAttachDriver)
		{
			UTP.SetCollision( false, false);
			UTP.bCollideWorld = false;
			UTP.SetBase(none);
			UTP.SetHardAttach(true);
			UTP.SetLocation( Location );
			UTP.SetPhysics( PHYS_None );

			SitDriver( UTP, 0);
		}
	}
}

simulated function SitDriver( UTPawn UTP, int SeatIndex)
{
	if (Seats[SeatIndex].SeatBone != '')
	{
		UTP.SetBase( Self, , Mesh, Seats[SeatIndex].SeatBone);
	}
	else
	{
		UTP.SetBase( Self );
	}
	SetMovementEffect(SeatIndex,true, UTP);

	// Shut down physics when getting in vehicle.
	if(UTP.Mesh.PhysicsAssetInstance != None)
	{
		UTP.Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
	}
	UTP.Mesh.bUpdateKinematicBonesFromAnimation = FALSE;
	UTP.Mesh.PhysicsWeight = 0.0;

	if ( Seats[SeatIndex].bSeatVisible )
	{
		if ( (UTP.Mesh != None) && (Mesh != None) )
		{
			UTP.Mesh.SetShadowParent(Mesh);
			UTP.Mesh.SetLightEnvironment(LightEnvironment);
		}
		UTP.SetMeshVisibility(true);
		UTP.SetRelativeLocation( Seats[SeatIndex].SeatOffset );
		UTP.SetRelativeRotation( Seats[SeatIndex].SeatRotation );
		UTP.Mesh.SetCullDistance(5000);
		UTP.Mesh.SetTranslation(vect(0,0,1) * UTP.BaseTranslationOffset);
		UTP.SetHidden(false);
	}
	else
	{
		UTP.SetHidden(True);
	}
}

/** Allows a vehicle to do specific physics setup on a driver when physics asset changes. */
simulated function OnDriverPhysicsAssetChanged(UTPawn UTP);

simulated function String GetHumanReadableName()
{
	if (VehicleNameString == "")
	{
		return ""$Class;
	}
	else
	{
		return VehicleNameString;
	}
}


event OnPropertyChange(name PropName)
{
	local int i;

	for (i=0;i<Seats.Length;i++)
	{
		if ( Seats[i].bSeatVisible )
		{
			Seats[i].StoragePawn.SetRelativeLocation( Seats[i].SeatOffset );
			Seats[i].StoragePawn.SetRelativeRotation( Seats[i].SeatRotation );
		}
	}
}

simulated function int GetHealth(int SeatIndex)
{
	return Health;
}

function float GetCollisionDamageModifier(const out array<RigidBodyContactInfo> ContactInfos)
{
	local float Angle;
	local vector X, Y, Z;

	if (bReducedFallingCollisionDamage)
	{
		GetAxes(Rotation, X, Y, Z);
		Angle = ContactInfos[0].ContactNormal Dot Z;
		return (Angle < 0.f) ? Square(CollisionDamageMult * (1.0+Angle)) : Square(CollisionDamageMult);
	}
	else
	{
		return Square(CollisionDamageMult);
	}
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
								   const out CollisionImpactData Collision, int ContactIndex )
{
	local int Damage;
	local UTVehicle V;
	local Controller InstigatorController;

	if (LastCollisionDamageTime != WorldInfo.TimeSeconds)
	{
		Super.RigidBodyCollision(HitComponent, OtherComponent, Collision, ContactIndex);

		if (OtherComponent != None && UTPawn(OtherComponent.Owner) != None && OtherComponent.Owner.Physics == PHYS_RigidBody)
		{
			RanInto(OtherComponent.Owner);
		}
		else if(Mesh != None)
		{
			// take impact damage
			Damage = int(VSizeSq(Mesh.GetRootBodyInstance().PreviousVelocity) * GetCollisionDamageModifier(Collision.ContactInfos));
			if (Damage > 1)
			{
				// if rammed other vehicle, give that vehicle's Instigator credit for the damage
				if (OtherComponent != None)
				{
					V = UTVehicle(OtherComponent.Owner);
					if (V != None)
					{
						InstigatorController = V.GetCollisionDamageInstigator();
					}
				}
				if (InstigatorController == None)
				{
					InstigatorController = GetCollisionDamageInstigator();
				}
				TakeDamage(Damage, InstigatorController, Collision.ContactInfos[0].ContactPosition, vect(0,0,0), class'UTDmgType_VehicleCollision');
				LastCollisionDamageTime = WorldInfo.TimeSeconds;
			}
		}
	}
}

/************************************************************************************
 * Morphs
 ***********************************************************************************/

/**
 * Initialize the damage modeling system
 */
simulated function InitializeMorphs()
{
	local int i,j;

	for (i=0;i<DamageMorphTargets.Length;i++)
	{
		// Find this node

		if(DamageMorphTargets[i].MorphNodeName != 'None')
		{
			DamageMorphTargets[i].MorphNode 	  = MorphNodeWeight( Mesh.FindMorphNode(DamageMorphTargets[i].MorphNodeName) );
			if (DamageMorphTargets[i].MorphNode == None)
			{
				`Warn("Failed to find Morph node named" @ DamageMorphTargets[i].MorphNodeName @ "in" @ Mesh.SkeletalMesh);
			}
		}

		// Fix up all linked references to this node.

		for (j=0;j<DamageMorphTargets.Length;j++)
		{
			if ( DamageMorphTargets[j].LinkedMorphNodeName == DamageMorphTargets[i].MorphNodeName )
			{
				DamageMorphTargets[j].LinkedMorphNodeIndex = i;
			}
		}
	}
	InitDamageSkel();

}

/** called when the client receives a change to Health
 * if LastTakeHitInfo changed in the same received bunch, always called *after* PlayTakeHitEffects()
 * (this is so we can use the damage info first for more accurate modelling and only use the direct health change for corrections)
 */
simulated event ReceivedHealthChange()
{
	local int Diff;

	Diff = Health - ClientHealth;
	if (Diff > 0)
	{
		ApplyMorphHeal(Diff);
	}
	else
	{
		ApplyRandomMorphDamage(Diff);
	}
	ClientHealth = Health;

	CheckDamageSmoke();
}

/**
 * Since vehicles can be healed, we need to apply the healing to each MorphTarget.  Since damage modeling is
 * client-side and healing is server-side, we evenly apply healing to all nodes
 *
 * @param	Amount		How much health to heal
 */
simulated event ApplyMorphHeal(int Amount)
{
	local int Individual, Total, Remaining;
	local int i;
	local float Weight;

	if (Health >= HealthMax)
	{
		// fully heal everything
		for (i = 0; i < DamageMorphTargets.length; i++)
		{
			DamageMorphTargets[i].Health = default.DamageMorphTargets[i].Health;
			if(DamageMorphTargets[i].MorphNode != none)
			{
				DamageMorphTargets[i].MorphNode.SetNodeWeight(0.0);
			}
		}
		for(i=0; i< DamageSkelControls.length; i++)
		{
			DamageSkelControls[i].RestorePart();
		}
	}
	else
	{
		// Find out the total amount of health needed for all nodes that have been "hurt"
		for ( i = 0; i < DamageMorphTargets.Length; i++)
		{
			if ( DamageMorphTargets[i].Health < Default.DamageMorphTargets[i].Health )
			{
				Total += Default.DamageMorphTargets[i].Health;
			}
		}

		// Deal out health evenly
		if (Amount > 0 && Total > 0)
		{
			Remaining = Amount;
			for (i = 0; i < DamageMorphTargets.length; i++)
			{
				Individual = Min( default.DamageMorphTargets[i].Health - DamageMorphTargets[i].Health,
						int(float(Amount) * float(Default.DamageMorphTargets[i].Health) / float(Total)) );
				DamageMorphTargets[i].Health += Individual;
				Remaining -= Individual;
			}

			// deal out any leftovers and update node weights
			for (i = 0; i < DamageMorphTargets.length; i++)
			{
				if (Remaining > 0)
				{
					Individual = Min(Remaining, default.DamageMorphTargets[i].Health - DamageMorphTargets[i].Health);
					DamageMorphTargets[i].Health += Individual;
					Remaining -= Individual;
				}
				Weight = 1.0 - (float(DamageMorphTargets[i].Health) / float(Default.DamageMorphTargets[i].Health));
				if(DamageMorphTargets[i].MorphNode != none)
				{
					DamageMorphTargets[i].MorphNode.SetNodeWeight(Weight);
				}
			}
		}

		// heal skel controls up one at a time.
		Total = 0;
		for( i = 0; i < DamageSkelControls.length; i++ )
		{
			if( Total < Amount)
			{
				Total += (1-DamageSkelControls[i].HealthPerc)*DamageSkelControls[i].DamageMax;
				// either we can cover the whole heal, or we fix the percentage left on this loop:
				DamageSkelControls[i].HealthPerc = Total<Amount?DamageSkelControls[i].RestorePart() : DamageSkelControls[i].HealthPerc + (float(Amount)-float(Total))/float(DamageSkelControls[i].DamageMax);
			}
			else
			{
				break;
			}
		}
	}

	UpdateDamageMaterial();
}

/** called to apply morph damage where we don't know what was actually hit
 * (i.e. because the client detected it by receiving a new Health value from the server)
 */
simulated function ApplyRandomMorphDamage(int Amount)
{
	local int min, minindex;
	local int i;
	local float MinAmt;
	local float Weight;

	// Search for the skel control to damage (if any)
	for(i=0;i<DamageSkelControls.Length;i++)
	{
		if(DamageSkelControls[i].HealthPerc > 0 && minindex < 0)
		{
			MinAmt = FMin(Amount/(DamageSkelControls[i].DamageMax*DamageSkelControls.Length),DamageSkelControls[i].HealthPerc);
			DamageSkelControls[i].HealthPerc -= MinAmt;
		}
	}
	while (Amount > 0)
	{
		minindex = -1;

		// Search for the node with the least amount of health
		minindex=-1;
		for (i=0;i<DamageMorphTargets.Length;i++)
		{
			if ((DamageMorphTargets[i].Health > 0) && (minindex < 0 || DamageMorphTargets[i].Health < min))
			{
				min = DamageMorphTargets[i].Health;
				minindex = i;
			}
		}

		// Deal out damage to that node
		if (minindex>=0)
		{
			if (min < Amount)
			{
				DamageMorphTargets[minindex].Health = 0;
				Amount -= min;
			}
			else
			{
				DamageMorphTargets[minindex].Health -= Amount;
				Amount = 0;
			}

			// Adjust the target
			Weight = 1.0 - ( FLOAT(DamageMorphTargets[minindex].Health) / FLOAT(Default.DamageMorphTargets[minindex].Health) );
			if(DamageMorphTargets[minindex].MorphNode != none)
			{
				DamageMorphTargets[minindex].MorphNode.SetNodeWeight(Weight);
			}
		}
		else
		{
			break;
		}

	}

	UpdateDamageMaterial();
}

/**
 * We use this function as the UTPawn's spawngib as for our vehicles we are spawning the gibs at specific locations based on the
 * skelcontrollers and the placement of meshes on the exterior of the vehicle
 **/
simulated function UTGib SpawnGibVehicle(vector SpawnLocation, rotator SpawnRotation, StaticMesh TheMesh, vector HitLocation, bool bSpinGib, vector ImpulseDirection, ParticleSystem PS_OnBreak, ParticleSystem PS_Trail)
{
	local UTGib_Vehicle Gib;
	local float GibPerterbation;
	local rotator VelRotation;
	local vector X, Y, Z;

	//`log("SpawnGibVehicle "$TheMesh);
	Gib = Spawn(VehiclePieceClass, self,, SpawnLocation, SpawnRotation,, TRUE );

	if ( Gib != None )
	{
		Gib.SetGibStaticMesh( TheMesh );
		//Gib.SetCollision( FALSE, FALSE, TRUE );
		Gib.GibMeshComp.SetBlockRigidBody( FALSE );
		Gib.GibMeshComp.SetRBChannel( RBCC_Nothing ); // nothing will request to collide with us
	// @todo make a RBChannelContainer function to do all this
		Gib.GibMeshComp.SetRBCollidesWithChannel( RBCC_Default, FALSE );
		Gib.GibMeshComp.SetRBCollidesWithChannel( RBCC_Pawn, FALSE );
		Gib.GibMeshComp.SetRBCollidesWithChannel( RBCC_Vehicle, FALSE );
		Gib.GibMeshComp.SetRBCollidesWithChannel( RBCC_GameplayPhysics, FALSE );
		Gib.GibMeshComp.SetRBCollidesWithChannel( RBCC_EffectPhysics, FALSE );

		Gib.SetTimer( 0.100f, FALSE, 'TurnOnCollision' );

		// add initial impulse
		GibPerterbation = 30000;
		VelRotation = rotator(Gib.Location - HitLocation);
		VelRotation.Pitch += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		VelRotation.Yaw += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		VelRotation.Roll += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		GetAxes(VelRotation, X, Y, Z);

		// use the passed in impulse dir if it is decently big enough
		if( VSize(ImpulseDirection) > 100.0f )
		{
			Gib.Velocity = Velocity + ImpulseDirection;
		}
		else
		{
			if( VSize(Velocity) > 10.0f )
			{
				Gib.Velocity = Velocity + (Z * ( FRand() * 100 )) + vect(0,0,1000);
			}
			else
			{
				Gib.Velocity = (vect(1,0,0) * ( (FRand() * 400) ) )
					+ (vect(0,1,0) * ( (FRand() * 400) ) )
					+ (Z * ( FRand() * 300 )) + vect(0,0,1000);
			}
		}


		Gib.GibMeshComp.WakeRigidBody();
		Gib.GibMeshComp.SetRBLinearVelocity( Gib.Velocity, FALSE );

		if( bSpinGib )
		{
			Gib.GibMeshComp.SetRBAngularVelocity( VRand() * 500, FALSE );
		}

		Gib.LifeSpan = Gib.LifeSpan + (2.0 * FRand());

		Gib.OwningClass = Class;


		if( PS_OnBreak != none )
		{
			Gib.PS_GibExplosionEffect = PS_OnBreak;
		}

		if( PS_Trail != none )
		{
			Gib.PS_GibTrailEffect = PS_Trail;
		}

		Gib.SetTimer( class'UTGib_Vehicle'.default.TimeBeforeGibExplosionEffect, FALSE, 'ActivateGibExplosionEffect' );
	}

	return Gib;
}


/**
 * We extend GetSVehicleDebug to include information about the seats array
 *
 * @param	DebugInfo		We return the text to display here
 */

simulated function GetSVehicleDebug( out Array<String> DebugInfo )
{
	local int i;

	Super.GetSVehicleDebug(DebugInfo);

	DebugInfo[DebugInfo.Length] = "";
	DebugInfo[DebugInfo.Length] = "----Seats----: ";
	for (i=0;i<Seats.Length;i++)
	{
		DebugInfo[DebugInfo.Length] = "Seat"@i$":"@Seats[i].Gun @ "Rotation" @ SeatWeaponRotation(i,,true) @ "FiringMode" @ SeatFiringMode(i,,true) @ "Barrel" @ Seats[i].BarrelIndex;
		if (Seats[i].Gun != None)
		{
			DebugInfo[DebugInfo.length - 1] @= "IsAimCorrect" @ Seats[i].Gun.IsAimCorrect();
		}
	}
}

/** Kismet hook for kicking a pawn out of a vehicle */
function OnExitVehicle(UTSeqAct_ExitVehicle Action)
{
	local int i;

	for (i = 0; i < Seats.length; i++)
	{
		if (Seats[i].SeatPawn != None && Seats[i].SeatPawn.Driver != None)
		{
			Seats[i].SeatPawn.DriverLeave(true);
		}
	}
}

/** stub for vehicles with shield firemodes */
function SetShieldActive(int SeatIndex, bool bActive);

function SetSeatStoragePawn(int SeatIndex, Pawn PawnToSit)
{
	local int Mask;

	Seats[SeatIndex].StoragePawn = PawnToSit;
	if ( (SeatIndex == 1) && (Role == ROLE_Authority) )
	{
		PassengerPRI = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
	}

	Mask = 1 << SeatIndex;

	if ( PawnToSit != none )
	{
		SeatMask = SeatMask | Mask;
	}
	else
	{
		if ( (SeatMask & Mask) > 0)
		{
			SeatMask = SeatMask ^ Mask;
		}
	}

}

simulated function SetMovementEffect(int SeatIndex, bool bSetActive, optional UTPawn UTP)
{
	local bool bIsLocal;

	if (bSetActive && ReferenceMovementMesh != None)
	{
		bIsLocal = UTP==none? IsLocallyControlled():UTP.IsLocallyControlled();
		if(bIsLocal && WorldInfo.Netmode != NM_DEDICATEDSERVER)
		{
			// Should never happen, but just in case:
			if(Seats[SeatIndex].SeatMovementEffect != none)
			{
				Seats[SeatIndex].SeatMovementEffect.Destroy();
			}
			Seats[SeatIndex].SeatMovementEffect = Spawn(class'VehicleMovementEffect',Seats[SeatIndex].SeatPawn,,Location,Rotation);
			if(Seats[SeatIndex].SeatMovementEffect != none)
			{
				Seats[SeatIndex].SeatMovementEffect.SetBase(self);
				Seats[SeatIndex].SeatMovementEffect.AirEffect.SetStaticMesh(ReferenceMovementMesh);
			}
		}
	}
	else if (Seats[SeatIndex].SeatMovementEffect != None)
	{
		Seats[SeatIndex].SeatMovementEffect.Destroy();
	}
}

simulated function DetachDriver(Pawn P)
{
	Super.DetachDriver(P);

	SetMovementEffect(0, false);
}

function bool CanAttack(Actor Other)
{
	local float MaxRange;
	local Weapon W;

	if ( bShouldLeaveForCombat && Driver != None && Driver.InvManager != None && Controller != None &&
		!WorldInfo.GRI.OnSameTeam(self, Other) && !IsHumanControlled() )
	{
		// return whether can attack with handheld weapons (assume bot will leave if it actually decides to attack)
		foreach Driver.InvManager.InventoryActors(class'Weapon', W)
		{
			MaxRange = FMax(MaxRange, W.MaxRange());
		}
		return (VSize(Location - Other.Location) <= MaxRange && Controller.LineOfSightTo(Other));
	}
	else
	{
		return Super.CanAttack(Other);
	}
}

function name GetVehicleKillStatName()
{
	local name VehicleKillStatName;
	VehicleKillStatName = name('VEHICLEKILL_'$Class.Name);
	return VehicleKillStatName;
}

simulated function DisplayHud(UTHud Hud, Canvas Canvas, vector2D HudPOS, optional int SeatIndex)
{
	local vector2D POS;
	local float W,H, PercValue, PosX, PosY, BarWidth, BarHeight;
	local int VHealth;
	local linearcolor MissingHealthColor;

	// Figure out dims and resolve the hud position
	W = Abs(HudCoords.UL) * HUD.ResolutionScale;
	H = Abs(HudCoords.VL) * HUD.ResolutionScale;
	PosX = Canvas.ClipX - W;
	PosY = Canvas.ClipY - H - 3*HUD.ResolutionScale;

	// Draw the Vehicle icon, showing health pct
	VHealth = Max(0, Health);
	PercValue = FClamp(float(VHealth)/float(HealthMax), 0.0, 1.0);
	Canvas.SetPos(PosX, PosY);
	if ( PercValue < 1.0 )
	{
		MissingHealthColor = Hud.WhiteLinearColor;
		MissingHealthColor.A = 0.3;
		Canvas.DrawTile(HudIcons, W, H*(1.0-PercValue), HudCoords.U, HudCoords.V, HudCoords.UL, HudCoords.VL*(1.0-PercValue), MissingHealthColor);
		Canvas.SetPos(PosX, PosY+H*(1.0-PercValue));
	}
	Canvas.DrawTile(HudIcons, W, H*PercValue, HudCoords.U, HudCoords.V+HudCoords.VL*(1.0-PercValue), HudCoords.UL, HudCoords.VL*PercValue, Hud.TeamHudColor);

	// Draw the Seats.
	DisplaySeats(HUD, Canvas, PosX, PosY, W,H, SeatIndex);

	if ( HUD.bShowVehicleArmorCount )
	{
		// Recalc the Positions given the health bar
		PosX = PosX - 140 * HUD.ResolutionScale;
		PosY = Canvas.ClipY - 47 * HUD.ResolutionScale;
		Canvas.SetPos(PosX,PosY);
		Canvas.DrawTile(HUD.AltHudTexture, (140 * HUD.ResolutionScale), 44 * HUD.ResolutionScale, 4,346,112,35, HUD.TeamHUDColor);

		// Pulse if health is being added
		if ( Health > LastHealth )
		{
			HealthPulseTime = WorldInfo.TimeSeconds;
		}
		LastHealth = Health;

		// Draw the health Text
		Hud.DrawGlowText( string(VHealth), PosX + (130 * HUD.ResolutionScale), PosY + (-9 * HUD.ResolutionScale), 53 * Hud.ResolutionScale, HealthPulseTime,true);

		// Draw any extra data.  We pass in the full bounds of the widget as well as the full X/Y
		W += 140 * HUD.ResolutionScale;
		POS.X = PosX;
		POS.Y = PosY;
		DisplayExtraHud(Hud, Canvas, POS, W, H, SeatIndex);
	}
	else
	{
		PosY = Canvas.ClipY - 5*HUD.ResolutionScale;
	}

	// If we have a bar graph display, do it here
	if ( (Seats[SeatIndex].Gun != None) && (UTVehicleWeapon(Seats[SeatIndex].Gun).AmmoDisplayType != EAWDS_Numeric) )
	{
		PercValue = UTVehicleWeapon(Seats[SeatIndex].Gun).GetPowerPerc();
		BarHeight = 70 * HUD.ResolutionScale;
		BarWidth = 16 * HUD.ResolutionScale;
		PosX = Canvas.ClipX - Abs(HudCoords.UL) * HUD.ResolutionScale - BarWidth;
		PosY = PosY - BarHeight;
		DrawBarGraph(PosX, PosY, BarHeight * PercValue,  BarHeight, BarWidth, Canvas);
	}
}

simulated function DrawBarGraph(float X, float Y, float Width, float MaxWidth, float Height, Canvas DrawCanvas)
{
	// draw background
	DrawCanvas.DrawColor = class'UTHUD'.default.WhiteColor;
	DrawCanvas.SetPos(X, Y);
	DrawCanvas.DrawTile(class'UTHUD'.default.AltHudTexture, Height, MaxWidth, 376,458, 88, 14);

	DrawCanvas.DrawColor = class'UTHUD'.default.WhiteColor;
	DrawCanvas.DrawColor.B = 16;
	DrawCanvas.SetPos(X, Y + MaxWidth - Width);
	DrawCanvas.DrawTile(class'UTHUD'.default.AltHudTexture,Height,Width,202,238,37,9);
}


simulated function DisplayExtraHud(UTHud Hud, Canvas Canvas, vector2D POS, float Width, float Height, int SIndex);

simulated function DisplaySeats(UTHud Hud, Canvas Canvas, float PosX, float PosY, float Width, float Height, int SIndex)
{
	local int i;
	local float X,Y;

	for (i=0;i<Seats.Length;i++)
	{
		X = PosX + (Width * (Seats[i].SeatIconPOS.X + Hud.TX));
		Y = PosY + (Height * (Seats[i].SeatIconPOS.Y + Hud.TY));
		Canvas.SetPos(X,Y);
		Hud.DrawTileCentered(Hud.AltHudTexture, 18 * Hud.ResolutionScale, 18 * Hud.ResolutionScale, 267,1,20,20, GetSeatColor(i, i == SIndex) );
	}
}

simulated function LinearColor GetSeatColor(int SeatIndex, bool bIsPlayersSeat)
{
	local byte TestMask;
	if (!bIsPlayersSeat)
	{
		TestMask = 1 << SeatIndex;
		if ( (SeatMask & TestMask) > 0)
		{
			return class'UTHUD'.Default.WhiteLinearColor;
		}
		else
		{
			return MakeLinearColor(0.5,0.5,0.5,1.0);
		}
	}
	else
	{
		return class'UTHUD'.Default.GoldLinearColor;
	}
}

simulated function ApplyWeaponEffects(int OverlayFlags, optional int SeatIndex)
{
	local int i, OverlayIndex;
	local UTGameReplicationInfo GRI;

	OverlayIndex = INDEX_NONE;
	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	if (GRI != None)
	{
		for (i = 0; i < GRI.VehicleWeaponEffects.length; i++)
		{
			if (GRI.VehicleWeaponEffects[i].Mesh != None && bool(OverlayFlags & (1 << i)))
			{
				OverlayIndex = i;
				break;
			}
		}
	}

	if (OverlayIndex == INDEX_NONE)
	{
		for (i = 0; i < Seats[SeatIndex].WeaponEffects.length; i++)
		{
			if (Seats[SeatIndex].WeaponEffects[i].Effect != None && Seats[SeatIndex].WeaponEffects[i].Effect.bAttached)
			{
				Mesh.DetachComponent(Seats[SeatIndex].WeaponEffects[i].Effect);
			}
		}
	}
	else
	{
		for (i = 0; i < Seats[SeatIndex].WeaponEffects.length; i++)
		{
			if (Seats[SeatIndex].WeaponEffects[i].Effect == None)
			{
				// unique name is for use with 'editudmgfx' console command
				Seats[SeatIndex].WeaponEffects[i].Effect = new(self, string(self) $ "_WeaponEffect_" $ i) class'StaticMeshComponent';
				Seats[SeatIndex].WeaponEffects[i].Effect.SetTranslation(Seats[SeatIndex].WeaponEffects[i].Offset);
				Seats[SeatIndex].WeaponEffects[i].Effect.SetScale3D(Seats[SeatIndex].WeaponEffects[i].Scale3D);
			}
			Seats[SeatIndex].WeaponEffects[i].Effect.SetStaticMesh(GRI.VehicleWeaponEffects[OverlayIndex].Mesh);
			Seats[SeatIndex].WeaponEffects[i].Effect.SetMaterial(0, GRI.VehicleWeaponEffects[OverlayIndex].Material);
			if (!Seats[SeatIndex].WeaponEffects[i].Effect.bAttached)
			{
				Mesh.AttachComponentToSocket(Seats[SeatIndex].WeaponEffects[i].Effect, Seats[SeatIndex].WeaponEffects[i].SocketName);
			}
		}
	}
}

/** @return whether bot should leave this vehicle if it encounters combat */
function bool ShouldLeaveForCombat(UTBot B)
{
	return bShouldLeaveForCombat;
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	Begin Object Name=SVehicleMesh
		CastShadow=true
		bCastDynamicShadow=true
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		bAllowAmbientOcclusion=false
	End Object

	Begin Object Name=CollisionCylinder
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false
	End Object

	InventoryManagerClass=class'UTInventoryManager'
	bCanCarryFlag=false
	bDriverHoldsFlag=false
	bEjectKilledBodies=false
	LinkHealMult=0.35
	VehicleLostTime=0.0
	TeamBeaconPlayerInfoMaxDist=3000.f
	MaxDesireability=0.5
	bTeamLocked=true
	bEnteringUnlocks=true
	StolenAnnouncementIndex=4
	bEjectPassengersWhenFlipped=true
	MinRunOverSpeed=250.0
	MinCrushSpeed=100.0
	LookForwardDist=0.0
	MomentumMult=2.0

	LookSteerSensitivity=2.0
	ConsoleSteerScale=1.5

	bCanFlip=false
	RanOverDamageType=class'UTGame.UTDmgType_RanOver'
	CrushedDamageType=class'UTGame.UTDmgType_Pancake'
	MinRunOverWarningAim=0.88
	ExplosionTemplate=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
	BigExplosionTemplates[0]=(Template=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_VehicleDeathExplosion')
	SecondaryExplosion=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_Dust_Secondary'

	SeatCameraScale=1.0

	DamageSmokeThreshold=0.65
	FireDamageThreshold=0.40
	MaxImpactEffectDistance=6000.0
	MaxFireEffectDistance=7000.0

	Team=UTVEHICLE_UNSET_TEAM // impossible value so that we know if it hasn't replicated yet
	TeamBeaconOffset=(z=100.0)
	PassengerTeamBeaconOffset=(z=100.0)
	SpawnRadius=320.0
	BurnOutTime=2.5
	DeadVehicleLifeSpan=9.0
	BurnTimeParameterName=BurnTime
	VehicleDrowningDamType=class'UTGame.UTDmgType_Drowned'

	SpawnInTemplates[0]=ParticleSystem'VH_All.Effects.P_VH_All_Spawn_Red'
	SpawnInTemplates[1]=ParticleSystem'VH_All.Effects.P_VH_All_Spawn_Blue'
	SpawnMaterialParameterName=ResInAmount
	SpawnMaterialParameterCurve=(Points=((InVal=0.0,OutVal=0.0),(InVal=4.0,OutVal=2.5)))
	SpawnInTime=4.0

	MapSize=0.75
	IconCoords=(U=831,V=21,UL=38,VL=30)
	FlipToolTipIconCoords=(U=2,UL=79,V=766,VL=71)
	EnterToolTipIconCoords=(U=96,UL=77,V=249,VL=64)
	DropFlagIconCoords=(U=85,UL=66,V=767,VL=48)
	DropOrbIconCoords=(U=109,UL=55,V=815,VL=38)

	BaseEyeheight=30
	Eyeheight=30

	DrivingAnim=Manta_Idle_Sitting
	bShouldAutoCenterViewPitch=TRUE

	bDrawHealthOnHUD=true

	LockedOnSound=Soundcue'A_Weapon_Avril.WAV.A_Weapon_AVRiL_Lock01Cue'

	CollisionDamageMult=0.002
	CameraLag=0.12
	ViewPitchMin=-15000
	MinCameraDistSq=1.0

	DefaultFOV=75
	bNoZSmoothing=true
	CameraSmoothingFactor=2.0

	RespawnTime=30.0
	InitialSpawnDelay=+0.0

	ExplosionDamage=100.0
	ExplosionRadius=300.0
	ExplosionMomentum=60000
	ExplosionInAirAngVel=1.5
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'
	MaxExplosionLightDistance=+4000.0
	DeathExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=400.0
	OuterExplosionShakeRadius=1000.0
	ExplosionDamageType=class'UTDmgType_VehicleExplosion'
	VehiclePieceClass=class'UTGib_VehiclePiece'

	WaterDamage=20.0
	bTakeWaterDamageWhileDriving=true
	FireDamagePerSec=2.0
	UpsideDownDamagePerSec=500.0
	OccupiedUpsideDownDamagePerSec=200.0
	bValidLinkTarget=true

	bMustBeUpright=true
	FlagOffset=(Z=120.0)
	FlagRotation=(Yaw=32768)

`if(`notdefined(MOBILE))
	HudIcons=Texture2D'UI_HUD.HUD.UI_HUD_BaseB'
`endif

	SpawnInSound = SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeIn01Cue'
	SpawnOutSound = SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeOut01Cue'
	LinkedEndSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleChargeCompleteCue'
	LinkedToCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleChargeLoopCue'

	DisabledTime=20.0
	VehicleLockedSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleNoEntry01Cue'
	LargeChunkImpactSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleImpact_MetalLargeCue'
	MediumChunkImpactSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleImpact_MetalMediumCue'
	SmallChunkImpactSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleImpact_MetalSmallCue'

	HornSounds[0]=SoundCue'A_Vehicle_Hellbender.Soundcues.A_Vehicle_Hellbender_Horn' // Small axon

	HornAIRadius=800.0

	bPushedByEncroachers=false
	bAlwaysRelevant=true
	DisabledTemplate=ParticleSystem'Pickups.Deployables.Effects.P_Deployables_EMP_Mine_VehicleDisabled'
	TurretScaleControlName=TurretScale
	TurretSocketName=VH_Death
	TurretOffset=(X=0.0,Y=0.0,Z=200.0);
	DistanceTurretExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SpecialCase_1_Base_Near',MinDistance=1500.0)
	DistanceTurretExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SpecialCase_1_Base_Far',MinDistance=0.0)
	TurretExplosiveForce=10000.0f

	HUDExtent=100.0

	VehicleSounds(0)=(SoundStartTag=DamageSmoke,SoundEndTag=NoDamageSmoke,SoundTemplate=SoundCue'A_Vehicle_Generic.Vehicle.Vehicle_Damage_FireLoop_Cue')

	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0

	bFindGroundExit=true

	LastEnemyWarningTime=-100.0
	WaterEffectType=Water

	TimeTilSecondaryVehicleExplosion=2.0f
}
