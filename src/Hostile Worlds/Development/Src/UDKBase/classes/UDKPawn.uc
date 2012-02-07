/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKPawn extends GamePawn
	nativereplication
	native;

var		bool	bReadyToDoubleJump;
var		bool	bRequiresDoubleJump;		/** set by suggestjumpvelocity() */
var		bool	bCanDoubleJump;
var		bool	bNoJumpAdjust;			// set to tell controller not to modify velocity of a jump/fall
var		float	MaxDoubleJumpHeight;
var		int		MultiJumpRemaining;
var		int		MaxMultiJump;
var		int		MultiJumpBoost;

var		bool			bIsHoverboardAnimPawn;

/** true when in ragdoll due to feign death */
var repnotify bool bFeigningDeath;

/*********************************************************************************************
* Custom gravity support
********************************************************************************************* */
var float CustomGravityScaling;		// scaling factor for this pawn's gravity - reset when pawn lands/changes physics modes
var bool bNotifyStopFalling;		// if true, StoppedFalling() is called when the physics mode changes from falling

/** whether this Pawn is invisible. Affects AI and also causes shadows to be disabled */
var repnotify bool bIsInvisible;

/** struct for list to map material types supported by an actor to impact sounds and effects */
struct native MaterialImpactEffect
{
	var name MaterialType;
	var SoundCue Sound;
	var array<MaterialInterface> DecalMaterials;
	/** How long the decal should last before fading out **/
	var float DurationOfDecal;
	/** MaterialInstance param name for dissolving the decal **/
	var name DecalDissolveParamName;
	var float DecalWidth;
	var float DecalHeight;
	var ParticleSystem ParticleTemplate;

	StructDefaultProperties
	{
		DurationOfDecal=24.0
		DecalDissolveParamName="DissolveAmount"
	}
};

/** Struct for list to map materials to sounds, for sound only applications (e.g. tires) */
struct native MaterialSoundEffect
{
	var name MaterialType;
	var SoundCue Sound;
};

/** Struct for list to map materials to a particle effect */
struct native MaterialParticleEffect
{
	var name MaterialType;
	var ParticleSystem ParticleTemplate;
};

/** this is used for a few special cases where we wanted a completely new particle system at certain distances
 * instead of just turning off an emitter or two inside a single one
 */
struct native DistanceBasedParticleTemplate
{
	/** the template to use */
	var ParticleSystem Template;
	/** the minimum distance all local players must be from the spawn location for this template to be used */
	var float MinDistance;
};

/** Struct used for communicating info to play an emote from server to clients. */
struct native PlayEmoteInfo
{
	var	name	EmoteTag;
	var int		EmoteID;
	var bool	bNewData;
};

/** replicated information on a hit we've taken */
struct native UTTakeHitInfo
{
	/** the amount of damage */
	var int Damage;
	/** the location of the hit */
	var vector HitLocation;
	/** how much momentum was imparted */
	var vector Momentum;
	/** the damage type we were hit with */
	var class<DamageType> DamageType;
	/** the bone that was hit on our Mesh (if any) */
	var name HitBone;
};


/** Structure containing information about a specific emote */
struct native EmoteInfo
{
	/** Category to which this emote belongs. */
	var name		CategoryName;
	/** This is a unique tag used to look up this emote */
	var name		EmoteTag;
	/** Friendly name of this emote (eg for menu) */
	var localized string		EmoteName;
	/** Name of animation to play. Should be in AnimSets above. */
	var name		EmoteAnim;
	/** Indicates that this is a whole body 'victory' emote which should only be offered at the end of the game. */
	var bool		bVictoryEmote;
	/** Emote should only be played on top half of body. */
	var bool		bTopHalfEmote;
	/** The command that goes with this emote */
	var name  		Command;
	/** if true, the command requires a PRI */
	var bool		bRequiresPlayer;
};


/** Used to replicate on emote to play. */
var repnotify PlayEmoteInfo EmoteRepInfo;

/** Last time emote was played. */
var	float	LastEmoteTime;

/** Controls how often you can send an emote. */
var float	MinTimeBetweenEmotes;

/** Use to replicate to clients when someone goes through a big teleportation. */
var repnotify byte BigTeleportCount;

var repnotify UTTakeHitInfo LastTakeHitInfo;

/** stop considering LastTakeHitInfo for replication when world time passes this (so we don't replicate out-of-date hits when pawns become relevant) */
var float LastTakeHitTimeout;

var repnotify float FireRateMultiplier; /** affects firing rate of all weapons held by this pawn. */
var repnotify float HeadScale;

/** Whether to smoothly interpolate pawn position corrections on clients based on received location updates */
var bool bSmoothNetUpdates;

/** Maximum location correction distance for which other pawn positions on a client will be smoothly updated */
var float MaxSmoothNetUpdateDist;

/** If the updated location is more than NoSmoothNetUpdateDist from the current pawn position on the client, pop it to the updated location.
If it is between MaxSmoothNetUpdateDist and NoSmoothNetUpdateDist, pop to MaxSmoothNetUpdateDist away from the updated location */
var float NoSmoothNetUpdateDist;

/** How long to take to smoothly interpolate from the old pawn position on the client to the corrected one sent by the server.  Must be > 0.0 */
var float SmoothNetUpdateTime;

/** Used for position smoothing in net games */
var vector MeshTranslationOffset;

var float			OldZ;			// Old Z Location - used for eyeheight smoothing

/** The weapon overlay meshes need to be controlled by the pawn due to replication.  We use */
/** a bitmask to describe what effect needs to be overlay.  								*/
/**																							*/
/** 0x00 = No Overlays																		*/
/** bit 0 (0x01) = Damage Amp																*/
/** bit 1 (0x02) = Berserk																	*/
/**																							*/
/** Use SetWeaponOverlayFlag() / ClearWeaponOverlayFlag to adjust							*/
var repnotify byte WeaponOverlayFlags;

/** set when pawn is putting away its current weapon, for playing 3p animations - access with Set/GetPuttingDownWeapon() */
var protected repnotify bool bPuttingDownWeapon;

/** pawn ambient sound (for powerups and such) */
var protected AudioComponent PawnAmbientSound;

/** ambient cue played on PawnAmbientSound component; automatically replicated and played on clients. Access via SetPawnAmbientSound() / GetPawnAmbientSound() */
var protected repnotify SoundCue PawnAmbientSoundCue;

/** base vehicle pawn is in, used when the pawn is driving a UTWeaponPawn as those don't get replicated to non-owning clients */
struct native DrivenWeaponPawnInfo
{
	/** base vehicle we're in */
	var UDKVehicle BaseVehicle;
	/** seat of that vehicle */
	var byte SeatIndex;
	/** ref to PRI since our PlayerReplicationInfo variable will be None while in a vehicle */
	var PlayerReplicationInfo PRI;
};
var repnotify DrivenWeaponPawnInfo DrivenWeaponPawn;

/** separate replicated ambient sound for weapon firing - access via SetWeaponAmbientSound() / GetWeaponAmbientSound() */
var protected AudioComponent WeaponAmbientSound;
var protected repnotify SoundCue WeaponAmbientSoundCue;

var repnotify Material ReplicatedBodyMaterial;

/** This is the actual Material Instance that is used to affect the colors */
var protected array<MaterialInstanceConstant> BodyMaterialInstances;

/** material that is overlayed on the pawn via a separate slightly larger scaled version of the pawn's mesh
 * Use SetOverlayMaterial()  / GetOverlayMaterial() to access. */
var protected repnotify MaterialInterface OverlayMaterialInstance;

var SkelControlSingleBone	RootRotControl;
var	AnimNodeAimOffset		AimNode;
var GameSkelCtrl_Recoil		GunRecoilNode;
var GameSkelCtrl_Recoil		LeftRecoilNode;
var GameSkelCtrl_Recoil		RightRecoilNode;

/** Bots which are currently tracking this pawn, and need their target position history (SavedPositions array) updated */
var array<UDKBot> Trackers;

/** How long will it take for the current Body Material to fade out */
var float BodyMatFadeDuration;

/** This is the current Body Material Color with any fading applied in */
var LinearColor CurrentBodyMatColor;

/** how much time is left on this material */
var float RemainingBodyMatDuration;

/** This variable is used for replication of the value to remove clients */
var repnotify float ClientBodyMatDuration;

/** This is the color that will be applied */
var LinearColor BodyMatColor;

/** Replicate BodyMatColor as rotator to save bandwidth */
var repnotify rotator CompressedBodyMatColor;

/** true while playing feign death recovery animation */
var bool bPlayingFeignDeathRecovery;

/** Whether this pawn can play a falling impact. Set to false upon the fall, but getting up should reset it */
var bool bCanPlayFallingImpacts;

/** time above bool was set to true (for time out)*/
var float StartFallImpactTime;

/** name of the torso bone for playing impacts*/
var name TorsoBoneName;

/** sound to be played by Falling Impact*/
var SoundCue FallImpactSound;

/** Speed change that must be realized to trigger a fall sound*/
var float FallSpeedThreshold;

/** Temp blob shadow */
var StaticMeshComponent BlobShadow;

/** mesh for overlay - should not be added to Components array in defaultproperties */
var protected SkeletalMeshComponent OverlayMesh;

/*********************************************************************************************
* Foot placement IK system
********************************************************************************************* */
var name			LeftFootBone, RightFootBone;
var name			LeftFootControlName, RightFootControlName;
var float			BaseTranslationOffset;
var float			CrouchTranslationOffset;
var float			OldLocationZ;
var	bool			bEnableFootPlacement;
var const float		ZSmoothingRate;

/** if the pawn is farther than this away from the viewer, foot placement is skipped */
var float MaxFootPlacementDistSquared;

/** cached references to skeletal controllers for foot placement */
var SkelControlFootPlacement LeftLegControl, RightLegControl;

/** cached references to skeletal control for hand IK */
var SkelControlLimb			LeftHandIK;
var SkelControlLimb			RightHandIK;

/** material parameter containing damage overlay color */
var name DamageParameterName;

/** material parameter containing color saturation multiplier (for reducing to account for zoom) */
var name SaturationParameterName;

/** If true, call postrenderfor() even if on different team */
var bool bPostRenderOtherTeam;

/** Last time trace test check for drawing postrender beacon was performed */
var float LastPostRenderTraceTime;

/** Maximum distance from camera position for this pawn to have its beacon displayed on the HUD */
var(TeamBeacon) float      TeamBeaconMaxDist;

/** last time Pawn was falling and had non-zero velocity
 * used to detect a rare bug where pawns get just barely embedded in a mesh and fall forever
 */
var float StartedFallingTime;

/** Slope boosting is allowed on surfaces with a physical material whose friction is lower than this value. 
    Slope boosting is the ability to slide up steep slopes that the pawn jumps into. */
var		float	SlopeBoostFriction;			

/*********************************************************************************************
Animation
 ********************************************************************************************* */

/** Used by UDKAnimBlendByFlying */
var AnimNodeAimOffset	FlyingDirOffset;

/** how much pawn should lean into turns */
var		int		MaxLeanRoll;		

/** speed at which physics is blended out when bPlayingFeignDeathRecovery is true (amount subtracted from PhysicsWeight per second) */
var float FeignDeathPhysicsBlendOutSpeed;

/** Translation applied to skeletalmesh when swimming */
var(Swimming) float SwimmingZOffset;

/** Speed to apply swimming z translation. */
var(Swimming) float SwimmingZOffsetSpeed;

var float CrouchMeshZOffset;

/** if set, blend Mesh PhysicsWeight to 0.0 in C++ and call TakeHitBlendedOut() event when finished */
var bool bBlendOutTakeHitPhysics;

/** speed at which physics is blended out when bBlendOutTakeHitPhysics is true (amount subtracted from PhysicsWeight per second) */
var float TakeHitPhysicsBlendOutSpeed;

/*********************************************************************************************
First person view
 ********************************************************************************************* */

/** First person view left and right arm meshes */
var UDKSkeletalMeshComponent ArmsMesh[2]; 

/** First person view left and right arm mesh overlays */
var UDKSkeletalMeshComponent ArmsOverlay[2];

/*********************************************************************************************
 Aiming
 ********************************************************************************************* */

/** Current yaw of the mesh root. This essentially lags behind the actual Pawn rotation yaw. */
var int	RootYaw;

/** Output - how quickly RootYaw is changing (unreal rot units per second). */
var float RootYawSpeed;

/** How far RootYaw differs from Rotation.Yaw before it is rotated to catch up. */
var() int	MaxYawAim;

/** 2D vector indicating aim direction relative to Pawn rotation. +/-1.0 indicating 180 degrees. */
var vector2D CurrentSkelAim;

/** if true, UpdateEyeheight() will get called every tick */
var	bool		bUpdateEyeheight;		

/* Replicated when torn off body should gib */
var bool bTearOffGibs;

/** HUD Rendering (for minimap) - updated in SetHUDLocation() */
var vector HUDLocation;

cpptext
{
	virtual UBOOL TryJumpUp(FVector Dir, FVector Destination, DWORD TraceFlags, UBOOL bNoVisibility);
	virtual ETestMoveResult FindJumpUp(FVector Direction, FVector &CurrentPosition);
	virtual INT calcMoveFlags();
 
 	virtual FLOAT DampenNoise(AActor* NoiseMaker, FLOAT Loudness, FName NoiseType=NAME_None );
	void RequestTrackingFor(AUDKBot *Bot);
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual void TickSimulated( FLOAT DeltaSeconds );

	virtual UBOOL SetHighJumpFlag();
	UBOOL UseFootPlacementThisTick();
	void EnableFootPlacement(UBOOL bEnabled);
	void DoFootPlacement(FLOAT DeltaSeconds);
	FLOAT GetGravityZ();
	void setPhysics(BYTE NewPhysics, AActor *NewFloor, FVector NewFloorV);
	virtual FVector CalculateSlopeSlide(const FVector& Adjusted, const FCheckResult& Hit);
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive, AActor* SourceActor, DWORD TraceFlags);
	virtual UBOOL IgnoreBlockingBy(const AActor* Other) const;
	virtual void performPhysics(FLOAT DeltaSeconds);
	virtual void physFalling(FLOAT deltaTime, INT Iterations);

	virtual UBOOL HasAudibleAmbientSound(const FVector& SrcLocation);
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );

	// camera
	virtual void UpdateEyeHeight(FLOAT DeltaSeconds);
	virtual void physicsRotation(FLOAT deltaTime, FVector OldVelocity);
	virtual void SmoothCorrection(const FVector& OldLocation);

protected:
	virtual void CalcVelocity(FVector &AccelDir, FLOAT DeltaTime, FLOAT MaxSpeed, FLOAT Friction, INT bFluid, INT bBrake, INT bBuoyant);
}

replication
{
	// replicated properties
	if ( bNetOwner && bNetDirty )
		FireRateMultiplier;
	if ( bNetDirty )
		bFeigningDeath,
		HeadScale, WeaponAmbientSoundCue, ReplicatedBodyMaterial,
		WeaponOverlayFlags,BigTeleportCount,
		CustomGravityScaling, bIsInvisible, ClientBodyMatDuration, CompressedBodyMatColor, PawnAmbientSoundCue, OverlayMaterialInstance;
	if(bNetDirty && WorldInfo.TimeSeconds - LastEmoteTime <= MinTimeBetweenEmotes)
		EmoteRepInfo;
	if (bNetDirty && WorldInfo.TimeSeconds < LastTakeHitTimeout)
		LastTakeHitInfo;
	if (bNetDirty && !bNetOwner)
		DrivenWeaponPawn, bPuttingDownWeapon;
	// variable sent to all clients when Pawn has been torn off. (bTearOff)
	if( bTearOff && bNetDirty )
		bTearOffGibs;
}

/** 
  * Get height/radius of big cylinder around this actors colliding components.
  * UDKPawn version returns its CylinderComponent's CollisionRadius and Collision Height, rather than calling GetComponentsBoundingBox().
  */  
native function GetBoundingCylinder(out float CollisionRadius, out float CollisionHeight) const;

/** 
  * Go back to using CollisionComponent in use before ragdolling.  Uses saved PreRagdollCollisionComponent property
  */
native function RestorePreRagdollCollisionComponent();

/** Util that makes sure the overlay component is last in the AllComponents array. */
native function EnsureOverlayComponentLast();

/**
 * @param RequestedBy - the Actor requesting the target location
 * @param bRequestAlternateLoc (optional) - return a secondary target location if there are multiple
 * @return the optimal location to fire weapons at this actor
 */
native simulated function vector GetTargetLocation(optional actor RequestedBy, optional bool bRequestAlternateLoc) const;

/**
@RETURN true if pawn is invisible to AI
*/
native function bool IsInvisible();

/** 
* Attach GameObject to mesh.
* @param GameObj : Game object to hold
*/
simulated event HoldGameObject(UDKCarriedObject UDKGameObj);

event StoppedFalling()
{
	CustomGravityScaling = 1.0;
	bNotifyStopFalling = false;
}

/**
 * Event called from native code when Pawn stops crouching.
 * Called on non owned Pawns through bIsCrouched replication.
 * Network: ALL
 *
 * @param	HeightAdjust	height difference in unreal units between default collision height, and actual crouched cylinder height.
 */
simulated event EndCrouch(float HeightAdjust)
{
	OldZ += HeightAdjust;
	Super.EndCrouch(HeightAdjust);

	// offset mesh by height adjustment
	CrouchMeshZOffset = 0.0;
}

/**
 * Event called from native code when Pawn starts crouching.
 * Called on non owned Pawns through bIsCrouched replication.
 * Network: ALL
 *
 * @param	HeightAdjust	height difference in unreal units between default collision height, and actual crouched cylinder height.
 */
simulated event StartCrouch(float HeightAdjust)
{
	OldZ -= HeightAdjust;
	Super.StartCrouch(HeightAdjust);

	// offset mesh by height adjustment
	CrouchMeshZOffset = HeightAdjust;
}

/**
SuggestJumpVelocity()
returns true if succesful jump from start to destination is possible
returns a suggested initial falling velocity in JumpVelocity
Uses GroundSpeed and JumpZ as limits
*/
native function bool SuggestJumpVelocity(out vector JumpVelocity, vector Destination, vector Start, optional bool bRequireFallLanding);

/** function used to update where icon for this actor should be rendered on the HUD
 *  @param NewHUDLocation is a vector whose X and Y components are the X and Y components of this actor's icon's 2D position on the HUD
 */
simulated native function SetHUDLocation(vector NewHUDLocation);

/**
  * Hook to allow actors to render HUD overlays for themselves.
  * Assumes that appropriate font has already been set
  */
simulated native function NativePostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);

/** 
  * Stub to allow changing the visibility of the third person weapon attachment
  */
simulated function SetWeaponAttachmentVisibility(bool bAttachmentVisible);

/** Stub: implement functionality to enable or disable IK that keeps hands on IK bones. */
simulated function SetHandIKEnabled(bool bEnabled);

/** called when bPlayingFeignDeathRecovery and interpolating our Mesh's PhysicsWeight to 0 has completed
 *	starts the recovery anim playing
 */
simulated event StartFeignDeathRecoveryAnim();

/** called when bBlendOutTakeHitPhysics is true and our Mesh's PhysicsWeight has reached 0.0 */
simulated event TakeHitBlendedOut();

/* UpdateEyeHeight()
* Update player eye position, based on smoothing view while moving up and down stairs, and adding view bobs for landing and taking steps.
* Called every tick only if bUpdateEyeHeight==true.
*/
event UpdateEyeHeight( float DeltaTime );

/** called when we have been stuck falling for a long time with zero velocity
 * and couldn't find a place to move to get out of it
 */
event StuckFalling();

defaultproperties
{
	CustomGravityScaling=1.0
	MaxYawAim=7000

	bSmoothNetUpdates=true
	MaxSmoothNetUpdateDist=84.0
	NoSmoothNetUpdateDist=128.0
	SmoothNetUpdateTime=0.125
}
