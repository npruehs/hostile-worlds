/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPawn extends UDKPawn
	config(Game)
	notplaceable;

var		bool	bFixedView;
var		bool	bSpawnDone;				// true when spawn protection has been deactivated
var		bool	bSpawnIn;
var		bool	bShieldAbsorb;			// set true when shield absorbs damage
var		bool	bDodging;				// true while in air after dodging
var		bool	bStopOnDoubleLanding;
var		bool	bIsInvulnerable;
var		bool	bJustDroppedOrb;		// if orb dropped because knocked off hoverboard

/** Holds the class type of the current weapon attachment.  Replicated to all clients. */
var	repnotify	class<UTWeaponAttachment>	CurrentWeaponAttachmentClass;

/** count of failed unfeign attempts - kill pawn if too many */
var int UnfeignFailedCount;

/** true when feign death activation forced (e.g. knocked off hoverboard) */
var bool bForcedFeignDeath;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/** anim node used for feign death recovery animations */
var AnimNodeBlend FeignDeathBlend;

/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;

var(DeathAnim)	float	DeathHipLinSpring;
var(DeathAnim)	float	DeathHipLinDamp;
var(DeathAnim)	float	DeathHipAngSpring;
var(DeathAnim)	float	DeathHipAngDamp;

/** World time that we started the death animation */
var				float	StartDeathAnimTime;
/** Type of damage that started the death anim */
var				class<UTDamageType> DeathAnimDamageType;
/** Time that we took damage of type DeathAnimDamageType. */
var				float	TimeLastTookDeathAnimDamage;

var	globalconfig bool bWeaponBob;
var bool		bJustLanded;			/** used by eyeheight adjustment.  True if pawn recently landed from a fall */
var bool		bLandRecovery;			/** used by eyeheight adjustment. True if pawn recovering (eyeheight increasing) after lowering from a landing */

var		bool			bHasHoverboard;

/*********************************************************************************************
 Camera related properties
********************************************************************************************* */
var vector 	FixedViewLoc;
var rotator FixedViewRot;
var float CameraScale, CurrentCameraScale; /** multiplier to default camera distance */
var float CameraScaleMin, CameraScaleMax;

/** Stop death camera using OldCameraPosition if true */
var bool bStopDeathCamera;

/** OldCameraPosition saved when dead for use if fall below killz */
var vector OldCameraPosition;

/** used to smoothly adjust camera z offset in third person */
var float CameraZOffset;

/** If true, use end of match "Hero" camera */
var bool bWinnerCam;

/** Used for end of match "Hero" camera */
var(HeroCamera) float HeroCameraScale;

/** Used for end of match "Hero" camera */
var(HeroCamera) int HeroCameraPitch;

var		float	DodgeSpeed;
var		float	DodgeSpeedZ;
var		eDoubleClickDir CurrentDir;
var()	float	DoubleJumpEyeHeight;
var		float	DoubleJumpThreshold;
var		float	DefaultAirControl;

/** view bob properties */
var	globalconfig	float	Bob;
var					float	LandBob;
var					float	JumpBob;
var					float	AppliedBob;
var					float	bobtime;
var					vector	WalkBob;

/** when a body in feign death's velocity is less than this, it is considered to be at rest (allowing the player to get up) */
var float FeignDeathBodyAtRestSpeed;

/** when we entered feign death; used to increase FeignDeathBodyAtRestSpeed over time so we get up in a reasonable amount of time */
var float FeignDeathStartTime;

/** When feign death recovery started.  Used to pull feign death camera into body during recovery */
var float FeignDeathRecoveryStartTime;

var int  SuperHealthMax;					/** Maximum allowable boosted health */

var class<UTPawnSoundGroup> SoundGroupClass;

/** This pawn's current family/class info **/
var class<UTFamilyInfo> CurrCharClassInfo;

/** bones to set fixed when doing the physics take hit effects */
var array<name> TakeHitPhysicsFixedBones;

/** Array of bodies that should not have joint drive applied. */
var array<name> NoDriveBodies;

/** Controller vibration for taking falling damage. */
var ForceFeedbackWaveform FallingDamageWaveForm;


/*********************************************************************************************
  Gibs
********************************************************************************************* */

/** Track damage accumulated during a tick - used for gibbing determination */
var float AccumulateDamage;

/** Tick time for which damage is being accumulated */
var float AccumulationTime;

/** whether or not we have been gibbed already */
var bool bGibbed;

/** whether or not we have been decapitated already */
var bool bHeadGibbed;

/*********************************************************************************************
 Hoverboard
********************************************************************************************* */
var		float			LastHoverboardTime;
var		float			MinHoverboardInterval;

/** Node used for blending between driving and non-driving state. */
var		UTAnimBlendByDriving DrivingNode;

/** Node used for blending between different types of vehicle. */
var		UTAnimBlendByVehicle VehicleNode;

/** Node used for various hoverboarding actions. */
var		UTAnimBlendByHoverboarding HoverboardingNode;

/*********************************************************************************************
 Armor
********************************************************************************************* */
var float ShieldBeltArmor;
var float VestArmor;
var float ThighpadArmor;

/*********************************************************************************************
 Weapon / Firing
********************************************************************************************* */

var bool bArmsAttached;

/** This holds the local copy of the current attachment.  This "attachment" actor will exist independantly on all clients */
var				UTWeaponAttachment			CurrentWeaponAttachment;
/** client side flag indicating whether attachment should be visible - primarily used when spawning the initial weapon attachment
 * as events that change its visibility might have happened before we received a CurrentWeaponAttachmentClass
 * to spawn and call the visibility functions on
 */
var bool bWeaponAttachmentVisible;

/** WeaponSocket contains the name of the socket used for attaching weapons to this pawn. */
var name WeaponSocket, WeaponSocket2;

/** Socket to find the feet */
var name PawnEffectSockets[2];

/** These values are used for determining headshots */
var float			HeadOffset;
var float           HeadRadius;
var float           HeadHeight;
var name			HeadBone;
/** We need to save a reference to the headshot neck attachment for the case of:  Headshot then gibbed  so we can hide this **/
var protected StaticMeshComponent HeadshotNeckAttachment;

var class<Actor> TransInEffects[2];
var	LinearColor  TranslocateColor[2];
/** camera anim played when spawned/teleported */
var CameraAnim TransCameraAnim[3];

var SoundCue ArmorHitSound;
/** sound played when initially spawning in */
var SoundCue SpawnSound;
/** sound played when we teleport */
var SoundCue TeleportSound;

/** Set when pawn died on listen server, but was hidden rather than ragdolling (for replication purposes) */
var bool bHideOnListenServer;

/*********************************************************************************************
  Overlay system

  UTPawns support 2 separate overlay systems.   The first is a simple colorizer that can be used to
  apply a color to the pawn's skin.  This is accessed via the
********************************************************************************************* */

/** This is the color that will be applied when a pawn is first spawned in and is covered by protection */
var	LinearColor SpawnProtectionColor;

/*********************************************************************************************
* Team beacons
********************************************************************************************* */
var(TeamBeacon) float      TeamBeaconPlayerInfoMaxDist;
var(TeamBeacon) Texture    SpeakingBeaconTexture;

/** true is last trace test check for drawing postrender beacon succeeded */
var bool bPostRenderTraceSucceeded;

/*********************************************************************************************
* HUD Icon
********************************************************************************************* */
var float MapSize;
var TextureCoordinates IconCoords;	/** Coordiates of the icon associated with this object */
/*********************************************************************************************
* Pain
********************************************************************************************* */
const MINTIMEBETWEENPAINSOUNDS=0.35;
var			float		LastPainSound;
var float RagdollLifespan;
var UTProjectile AttachedProj;

/** Max distance from listener to play footstep sounds */
var float MaxFootstepDistSq;

/** Max distance from listener to play jump/land sounds */
var float MaxJumpSoundDistSq;

/*********************************************************************************************
* Skin swapping support
********************************************************************************************* */
/** type of vehicle spawned when activating the hoverboard */
var class<UTVehicle> HoverboardClass;

var DrivenWeaponPawnInfo LastDrivenWeaponPawn;
/** reference WeaponPawn spawned on non-owning clients for code that checks for DrivenVehicle */
var UTClientSideWeaponPawn ClientSideWeaponPawn;

/** set on client when valid team info is received; future changes are then ignored unless this gets reset first
 * this is used to prevent the problem where someone changes teams and their old dying pawn changes color
 * because the team change was received before the pawn's dying
 */
var bool bReceivedValidTeam;

/*********************************************************************************************
 * Hud Widgets
********************************************************************************************* */

/** The default overlay to use when not in a team game */
var MaterialInterface ShieldBeltMaterialInstance;
/** A collection of overlays to use in team games */
var MaterialInterface ShieldBeltTeamMaterialInstances[4];

/** If true, head size will change based on ratio of kills to deaths */
var bool bKillsAffectHead;

/** Mirrors the # of charges available to jump boots */
var int JumpBootCharge;

/** Mesh scaling default */
var float DefaultMeshScale;

var name TauntNames[6];

/** currently desired scale of the hero (switches between crouched and default) */
var float DesiredMeshScale;

/** Third person camera offset */
var vector CamOffset;

/** information on what gibs to spawn and where */
struct GibInfo
{
	/** the bone to spawn the gib at */
	var name BoneName;
	/** the gib class to spawn */
	var class<UTGib> GibClass;
	var bool bHighDetailOnly;
};

/** bio death effect - updates BioEffectName parameter in the mesh's materials from 0 to 10 over BioBurnAwayTime
 * activated BioBurnAway particle system on death, deactivates it when BioBurnAwayTime expires
 * could easily be overridden by a custom death effect to use other effects/materials, @see UTDmgType_BioGoo
 */
var bool bKilledByBio;
var ParticleSystemComponent BioBurnAway;
var float BioBurnAwayTime;
var name BioEffectName;

/** Time at which this pawn entered the dying state */
var float DeathTime;

enum EWeapAnimType
{
	EWAT_Default,
	EWAT_Pistol,
	EWAT_DualPistols,
	EWAT_ShoulderRocket,
	EWAT_Stinger
};

replication
{
	if ( bNetOwner && bNetDirty )
		bHasHoverboard, ShieldBeltArmor, VestArmor, ThighpadArmor;
	if ( bNetDirty )
		CurrentWeaponAttachmentClass;
}

simulated function AdjustPPEffects(UTPlayerController PC, bool bRemove);

/*************************************************************/

/** Accessor to make sure we always get a valid UTPRI */
simulated function UTPlayerReplicationInfo GetUTPlayerReplicationInfo()
{
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if (UTPRI == None)
	{
		if (DrivenVehicle != None)
		{
			UTPRI = UTPlayerReplicationInfo(DrivenVehicle.PlayerReplicationInfo);
		}
	}

	return UTPRI;
}

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
    super.FellOutOfWorld(DmgType);
    bStopDeathCamera = true;
}

event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	if ( (WorldInfo.NetMode == NM_Client) || (Controller == None) )
		return;
	if (HeadVolume != None && HeadVolume.bWaterVolume)
	{
		if ( !newHeadVolume.bWaterVolume || (UTSpaceVolume(newHeadVolume) != None) )
		{
			if ( Controller.bIsPlayer && (BreathTime > 0) && (BreathTime < 8) )
				Gasp();
			BreathTime = -1.0;
		}
	}
	else if ( newHeadVolume != None && newHeadVolume.bWaterVolume && (UTSpaceVolume(newHeadVolume) == None) )
	{
		BreathTime = UnderWaterTime;
	}
}

/** PoweredUp()
returns true if pawn has game play advantages, as defined by specific game implementation
*/
function bool PoweredUp()
{
	return ( (DamageScaling > 1) || (FireRateMultiplier < 1) || bIsInvulnerable );
}

/** InCombat()
returns true if pawn is currently in combat, as defined by specific game implementation.
*/
function bool InCombat()
{
	return (WorldInfo.TimeSeconds - LastPainSound < 1) && !PhysicsVolume.bPainCausing;
}

simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, LinearColor FinalColor)
{
	MP.DrawRotatedTile(Canvas, class'UTHUD'.default.IconHudTexture, HUDLocation, Rotation.Yaw, MapSize, IconCoords, FinalColor);
}

/**
 * UTPawns not allowed to set bIsWalking true
 */
event SetWalking( bool bNewIsWalking )
{
}

simulated function ClearBodyMatColor()
{
	RemainingBodyMatDuration = 0;
	ClientBodyMatDuration = 0;
	BodyMatFadeDuration = 0;
}

simulated function SetBodyMatColor(LinearColor NewBodyMatColor, float NewOverlayDuration)
{
	// set if you want to be able to test in a level and not be tossed around nor have damage effects on screen making it impossible to see what is going on
	if( !AffectedByHitEffects() )
	{
		return;
	}

	RemainingBodyMatDuration = NewOverlayDuration;
	ClientBodyMatDuration = RemainingBodyMatDuration;
	BodyMatFadeDuration = 0.5 * RemainingBodyMatDuration;
	BodyMatColor = NewBodyMatColor;
	CompressedBodyMatColor.Pitch = 256.0 * BodyMatColor.R;
	CompressedBodyMatColor.Yaw = 256.0 * BodyMatColor.G;
	CompressedBodyMatColor.Roll = 256.0 * BodyMatColor.B;

	CurrentBodyMatColor = BodyMatColor;
	CurrentBodyMatColor.R += 1;				// make sure CurrentBodyMatColor differs from BodyMatColor to force update
	VerifyBodyMaterialInstance();
}

simulated function SetInvisible(bool bNowInvisible)
{
	bIsInvisible = bNowInvisible;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bIsInvisible)
		{
			Mesh.CastShadow = false;
			Mesh.bCastDynamicShadow = false;
			ReattachMesh();
		}
		else
		{
			UpdateShadowSettings(!class'Engine'.static.IsSplitScreen() && class'UTPlayerController'.default.PawnShadowMode == SHADOW_All);
		}
	}
}

/**
 * SetSkin is used to apply a single material to the entire model, including any applicable attachments.
 * NOTE: Attachments (ie: the weapons) need to handle resetting their default skin if NewMaterinal = NONE
 *
 * @Param	NewMaterial		The material to apply
 */

simulated function SetSkin(Material NewMaterial)
{
	local int i;

	// Replicate the Material to remote clients
	ReplicatedBodyMaterial = NewMaterial;

	if (VerifyBodyMaterialInstance())		// Make sure we have setup the BodyMaterialInstances array
	{
		// Propagate it to the 3rd person weapon attachment
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.SetSkin(NewMaterial);
		}

		// Propagate it to the 1st person weapon
		if (UTWeapon(Weapon) != None)
		{
			UTWeapon(Weapon).SetSkin(NewMaterial);
		}

		// Set the skin
		if (NewMaterial == None)
		{
			for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++)
			{
				Mesh.SetMaterial(i, BodyMaterialInstances[i]);
			}
		}
		else
		{
			for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++)
			{
				Mesh.SetMaterial(i, NewMaterial);
			}
		}

		SetArmsSkin(NewMaterial);
	}
}

simulated protected function SetArmsSkin(MaterialInterface NewMaterial)
{
	local int i,Cnt;

	// if no material specified, grab default from PRI (if that's None too, use mesh default)
	if (NewMaterial == None)
	{
		NewMaterial = CurrCharClassInfo.static.GetFirstPersonArmsMaterial(GetTeamNum());
	}

	if ( NewMaterial == None )	// Clear the materials
	{
		if(default.ArmsMesh[0] != none && ArmsMesh[0] != none)
		{
			if( default.ArmsMesh[0].Materials.Length > 0)
			{
				Cnt = Default.ArmsMesh[0].Materials.Length;
				for(i=0;i<Cnt;i++)
				{
					ArmsMesh[0].SetMaterial(i,Default.ArmsMesh[0].GetMaterial(i) );
				}
			}
			else if(ArmsMesh[0].Materials.Length > 0)
			{
				Cnt = ArmsMesh[0].Materials.Length;
				for(i=0;i<Cnt;i++)
				{
					ArmsMesh[0].SetMaterial(i,none);
				}
			}
		}

		if(default.ArmsMesh[1] != none && ArmsMesh[1] != none)
		{
			if( default.ArmsMesh[1].Materials.Length > 0)
			{
				Cnt = Default.ArmsMesh[1].Materials.Length;
				for(i=0;i<Cnt;i++)
				{
					ArmsMesh[1].SetMaterial(i,Default.ArmsMesh[1].GetMaterial(i) );
				}
			}
			else if(ArmsMesh[1].Materials.Length > 0)
			{
				Cnt = ArmsMesh[1].Materials.Length;
				for(i=0;i<Cnt;i++)
				{
					ArmsMesh[1].SetMaterial(i,none);
				}
			}
		}
	}
	else
	{
		if ((default.ArmsMesh[0] != none && ArmsMesh[0] != none) && (default.ArmsMesh[0].Materials.Length > 0 || ArmsMesh[0].GetNumElements() > 0))
		{
			Cnt = default.ArmsMesh[0].Materials.Length > 0 ? default.ArmsMesh[0].Materials.Length : ArmsMesh[0].GetNumElements();
			for(i=0; i<Cnt;i++)
			{
				ArmsMesh[0].SetMaterial(i,NewMaterial);
			}
		}
		if ((default.ArmsMesh[1] != none && ArmsMesh[1] != none) && (default.ArmsMesh[1].Materials.Length > 0 || ArmsMesh[1].GetNumElements() > 0))
		{
			Cnt = default.ArmsMesh[1].Materials.Length > 0 ? default.ArmsMesh[1].Materials.Length : ArmsMesh[1].GetNumElements();
			for(i=0; i<Cnt;i++)
			{
				ArmsMesh[1].SetMaterial(i,NewMaterial);
			}
		}
	}
}
/**
 * This function will verify that the BodyMaterialInstance variable is setup and ready to go.  This is a key
 * component for the BodyMat overlay system
 */
simulated function bool VerifyBodyMaterialInstance()
{
	local int i;

	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None && BodyMaterialInstances.length < Mesh.GetNumElements())
	{
		// set up material instances (for overlay effects)
		BodyMaterialInstances.length = Mesh.GetNumElements();
		for (i = 0; i < BodyMaterialInstances.length; i++)
		{
			if (BodyMaterialInstances[i] == None)
			{
				BodyMaterialInstances[i] = Mesh.CreateAndSetMaterialInstanceConstant(i);
			}
		}
	}
	return (BodyMaterialInstances.length > 0);
}

/** Set various basic properties for this UTPawn based on the character class metadata */
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	local UTPlayerReplicationInfo PRI;
	local int i;
	local int TeamNum;
	local MaterialInterface TeamMaterialHead, TeamMaterialBody, TeamMaterialArms;

	PRI = GetUTPlayerReplicationInfo();

	if (Info != CurrCharClassInfo)
	{
		// Set Family Info
		CurrCharClassInfo = Info;

		// get the team number (0 red, 1 blue, 255 no team)
		TeamNum = GetTeamNum();

		// AnimSets
		Mesh.AnimSets = Info.default.AnimSets;

		//Apply the team skins if necessary
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			Info.static.GetTeamMaterials(TeamNum, TeamMaterialHead, TeamMaterialBody);
		}

		// 3P Mesh and materials
		SetCharacterMeshInfo(Info.default.CharacterMesh, TeamMaterialHead, TeamMaterialBody);

		// First person arms mesh/material (if necessary)
		if (WorldInfo.NetMode != NM_DedicatedServer && IsHumanControlled() && IsLocallyControlled())
		{
			TeamMaterialArms = Info.static.GetFirstPersonArmsMaterial(TeamNum);
			SetFirstPersonArmsInfo(Info.static.GetFirstPersonArms(), TeamMaterialArms);
		}

		// PhysicsAsset
		// Force it to re-initialise if the skeletal mesh has changed (might be flappy bones etc).
		Mesh.SetPhysicsAsset(Info.default.PhysAsset, true);

		// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
		Mesh.bEnableFullAnimWeightBodies = FALSE;
		for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
		{
			// See if a bone has bAlwaysFullAnimWeight set and also
			if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
				Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
			{
				Mesh.bEnableFullAnimWeightBodies = TRUE;
			}
		}

		//Overlay mesh for effects
		if (OverlayMesh != None)
		{
			OverlayMesh.SetSkeletalMesh(Info.default.CharacterMesh);
		}

		//Set some properties on the PRI
		if (PRI != None)
		{
			PRI.bIsFemale = Info.default.bIsFemale;
			PRI.VoiceClass = Info.static.GetVoiceClass();

			// Assign fallback portrait.
			PRI.CharPortrait = Info.static.GetCharPortrait(TeamNum);

			// a little hacky, relies on presumption that enum vals 0-3 are male, 4-8 are female
			if ( PRI.bIsFemale )
			{
				PRI.TTSSpeaker = ETTSSpeaker(Rand(4));
			}
			else
			{
				PRI. TTSSpeaker = ETTSSpeaker(Rand(5) + 4);
			}
		}

		// Bone names
		LeftFootBone = Info.default.LeftFootBone;
		RightFootBone = Info.default.RightFootBone;
		TakeHitPhysicsFixedBones = Info.default.TakeHitPhysicsFixedBones;

		// sounds
		SoundGroupClass = Info.default.SoundGroupClass;

		DefaultMeshScale = Info.Default.DefaultMeshScale;
		Mesh.SetScale(DefaultMeshScale);
		BaseTranslationOffset = CurrCharClassInfo.Default.BaseTranslationOffset;
		CrouchTranslationOffset = BaseTranslationOffset + CylinderComponent.Default.CollisionHeight - CrouchHeight;
	}
}

/** Accessor that sets the character mesh to use for this pawn, and updates instance of player in map if there is one. */
simulated function SetCharacterMeshInfo(SkeletalMesh SkelMesh, MaterialInterface HeadMaterial, MaterialInterface BodyMaterial)
{
    Mesh.SetSkeletalMesh(SkelMesh);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (VerifyBodyMaterialInstance())
		{
			BodyMaterialInstances[0].SetParent(HeadMaterial);
			if (BodyMaterialInstances.length > 1)
			{
			   BodyMaterialInstances[1].SetParent(BodyMaterial);
			}
		}
		else
		{
			`log("VerifyBodyMaterialInstance failed on pawn"@self);
		}
	}
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
	if(bRagdollMode)
	{
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
	}
	else
	{
		Mesh.SetRBChannel(RBCC_Untitled3);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
	}
}

simulated function ResetCharPhysState()
{
	local UTVehicle UTV;

	if(Mesh.PhysicsAssetInstance != None)
	{
		// Now set up the physics based on what we are currently doing.
		if(Physics == PHYS_RigidBody)
		{
			// Ragdoll case
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
			SetPawnRBChannels(TRUE);
			SetHandIKEnabled(FALSE);
		}
		else
		{
			// Normal case
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
			Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, Mesh);
			SetPawnRBChannels(FALSE);
			SetHandIKEnabled(TRUE);

			// Allow vehicles to do any specific modifications to driver
			if(DrivenVehicle != None)
			{
				UTV = UTVehicle(DrivenVehicle);
				if(UTV != None)
				{
					UTV.OnDriverPhysicsAssetChanged(self);
				}
			}
		}
	}
}

simulated function NotifyTeamChanged()
{
	local UTPlayerReplicationInfo PRI;
	local int i;

	// set mesh to the one in the PRI, or default for this team if not found
	PRI = GetUTPlayerReplicationInfo();

	if (PRI != None)
	{
		if ( (PRI.Team != None) && !IsHumanControlled() || !IsLocallyControlled()  )
		{
			LightEnvironment.LightDesaturation = 1.0;
		}

		SetCharacterClassFromInfo(GetFamilyInfo());

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			// refresh weapon attachment
			if (CurrentWeaponAttachmentClass != None)
			{
				// recreate weapon attachment in case the socket on the new mesh is in a different place
				if (CurrentWeaponAttachment != None)
				{
					CurrentWeaponAttachment.DetachFrom(Mesh);
					CurrentWeaponAttachment.Destroy();
					CurrentWeaponAttachment = None;
				}
				WeaponAttachmentChanged();
			}
			// refresh overlay
			if (OverlayMaterialInstance != None)
			{
				SetOverlayMaterial(OverlayMaterialInstance);
			}
		}

		// Make sure physics is in the correct state.
		// Rebuild array of bodies to not apply joint drive to.
		NoDriveBodies.length = 0;
		for( i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
		{
			if(Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight)
			{
				NoDriveBodies.AddItem(Mesh.PhysicsAsset.BodySetup[i].BoneName);
			}
		}

		// Reset physics state.
		bIsHoverboardAnimPawn = FALSE;
		ResetCharPhysState();
	}

	if (!bReceivedValidTeam)
	{
		SetTeamColor();
		bReceivedValidTeam = (GetTeam() != None);
	}
}

/** Assign an arm mesh and material to this pawn */
simulated function SetFirstPersonArmsInfo(SkeletalMesh FirstPersonArmMesh, MaterialInterface ArmMaterial)
{
	// Arms
	ArmsMesh[0].SetSkeletalMesh(FirstPersonArmMesh);
	ArmsMesh[1].SetSkeletalMesh(FirstPersonArmMesh);

	if (ArmsOverlay[0] != None)
	{
		ArmsOverlay[0].SetSkeletalMesh(FirstPersonArmMesh);
	}

	if (ArmsOverlay[1] != None)
	{
		ArmsOverlay[1].SetSkeletalMesh(FirstPersonArmMesh);
	}

	SetArmsSkin(ArmMaterial);
}

/**
 * When a pawn's team is set or replicated, SetTeamColor is called.  By default, this will setup
 * any required material parameters.
 */
simulated function SetTeamColor()
{
	local int i;
	local UTPlayerReplicationInfo PRI;
	local LinearColor LinColor;

	if ( PlayerReplicationInfo != None )
	{
		PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	}
	else if ( DrivenVehicle != None )
	{
		PRI = UTPlayerReplicationInfo(DrivenVehicle.PlayerReplicationInfo);
	}
	if ( PRI == None )
		return;

	LinColor.A = 1.0;

	if ( PRI.Team == None )
	{
		if ( VerifyBodyMaterialInstance() )
		{
			LinColor.R = 2.0;
			LinColor.G = 2.0;

			for (i = 0; i < BodyMaterialInstances.length; i++)
			{
				BodyMaterialInstances[i].SetVectorParameterValue('Char_TeamColor', LinColor);
				BodyMaterialInstances[i].SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
			}
		}
	}
	else if (VerifyBodyMaterialInstance())
	{
		if ( PRI.Team.TeamIndex == 0 )
		{
			LinColor.R = 2.0;
			for (i = 0; i < BodyMaterialInstances.length; i++)
			{
				BodyMaterialInstances[i].SetVectorParameterValue('Char_TeamColor', LinColor);
				BodyMaterialInstances[i].SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
			}
		}
		else
		{
			LinColor.B = 2.0;
			for (i = 0; i < BodyMaterialInstances.length; i++)
			{
				BodyMaterialInstances[i].SetVectorParameterValue('Char_TeamColor', LinColor);
				BodyMaterialInstances[i].SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
			}
		}
	}
}

simulated function PostBeginPlay()
{
	local rotator R;
	local PlayerController PC;

	StartedFallingTime = WorldInfo.TimeSeconds;

	Super.PostBeginPlay();

	if (!bDeleteMe)
	{
		if (Mesh != None)
		{
			BaseTranslationOffset = Mesh.Translation.Z;
			CrouchTranslationOffset = Mesh.Translation.Z + CylinderComponent.CollisionHeight - CrouchHeight;
			OverlayMesh.SetParentAnimComponent(Mesh);
		}
		if (WorldInfo.NetMode != NM_DedicatedServer && ArmsMesh[0] != none)
		{
			CreateOverlayArmsMesh();
		}

		bCanDoubleJump = CanMultiJump();

		// Zero out Pitch and Roll
		R.Yaw = Rotation.Yaw;
		SetRotation(R);

		// add to local HUD's post-rendered list
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( PC.MyHUD != None )
			{
				PC.MyHUD.AddPostRenderedActor(self);
			}
		}

		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			UpdateShadowSettings(class'UTPlayerController'.default.PawnShadowMode == SHADOW_All);
		}

		// create a blob shadow on mobile platforms that don't support real shadows
		if (WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
		{
			BlobShadow = new(self) class'StaticMeshComponent';
			BlobShadow.SetStaticMesh(StaticMesh'BlobShadow.ShadowMesh');
			BlobShadow.SetActorCollision(FALSE, FALSE);
			BlobShadow.SetScale(0.2);
			BlobShadow.SetRotation(rot(16384, 0, 0));
			BlobShadow.SetTranslation(vect(0.0, 0.0, -44.0));
			AttachComponent(BlobShadow);
		}
	}
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
			// if there is a pending Attach then this will set the shadow immediately as the flags have changed an a reattached has occurred
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
	EnsureOverlayComponentLast();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	if (SkelComp == Mesh)
	{
		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		FeignDeathBlend = AnimNodeBlend(Mesh.FindAnimNode('FeignDeathBlend'));
		FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );

		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		DrivingNode = UTAnimBlendByDriving( mesh.FindAnimNode('DrivingNode') );
		VehicleNode = UTAnimBlendByVehicle( mesh.FindAnimNode('VehicleNode') );
		HoverboardingNode = UTAnimBlendByHoverboarding( mesh.FindAnimNode('Hoverboarding') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
	}
}

/** Enable or disable IK that keeps hands on IK bones. */
simulated function SetHandIKEnabled(bool bEnabled)
{
	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh.Animations != None)
	{
		if (bEnabled)
		{
			LeftHandIK.SetSkelControlStrength(1.0, 0.0);
			RightHandIK.SetSkelControlStrength(1.0, 0.0);
		}
		else
		{
			LeftHandIK.SetSkelControlStrength(0.0, 0.0);
			RightHandIK.SetSkelControlStrength(0.0, 0.0);
		}
	}
}

/** Util for scaling running anims etc. */
simulated function SetAnimRateScale(float RateScale)
{
	Mesh.GlobalAnimRateScale = RateScale;
}

/** Change the type of weapon animation we are playing. */
simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
	if (AimNode != None)
	{
		switch(AnimType)
		{
			case EWAT_Default:
				AimNode.SetActiveProfileByName('Default');
				break;
			case EWAT_Pistol:
				AimNode.SetActiveProfileByName('SinglePistol');
				break;
			case EWAT_DualPistols:
				AimNode.SetActiveProfileByName('DualPistols');
				break;
			case EWAT_ShoulderRocket:
				AimNode.SetActiveProfileByName('ShoulderRocket');
				break;
			case EWAT_Stinger:
				AimNode.SetActiveProfileByName('Stinger');
				break;
		}
	}
}

/**
 * This will trace against the world and leave a blood splatter decal.
 *
 * This is used for having a back spray / exit wound blood effect on the wall behind us.
 **/
simulated function LeaveABloodSplatterDecal( vector HitLoc, vector HitNorm )
{
	local Actor TraceActor;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local vector TraceDest;
	local vector TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;
	local MaterialInstanceTimeVarying MITV_Decal;

	TraceStart = HitLoc;
	HitNorm.Z = 0;
	TraceDest =  HitLoc  + ( HitNorm * 105 );

	TraceActor = Trace( out_HitLocation, out_HitNormal, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );

	if (TraceActor != None && Pawn(TraceActor) == None)
	{
		// we might want to move this to the UTFamilyInfo
		MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
		MITV_Decal.SetParent( GetFamilyInfo().default.BloodSplatterDecalMaterial );

		WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, out_HitLocation, rotator(-out_HitNormal), 100, 100, 50, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);

		MITV_Decal.SetScalarStartTime( class'UTGib'.default.DecalDissolveParamName, class'UTGib'.default.DecalWaitTimeBeforeDissolve );
	}
}


/**
 * Performs an Emote command.  This is typically an action that
 * tells the bots to do something.  It is server-side only
 *
 * @Param EInfo 		The emote we are working with
 * @Param PlayerID		The ID of the player this emote is directed at.  255 = All Players
 */
function PerformEmoteCommand(EmoteInfo EInfo, int PlayerID)
{
	local array<UTPlayerReplicationInfo> PRIs;
	local UTBot Bot;
	local int i;
	local bool bShouldAck;
	local Controller Sender;

	Sender = Controller;
	if (Sender == None && DrivenVehicle != None)
	{
		Sender = DrivenVehicle.Controller;
	}
	if (Sender != None)
	{
		// If we require a player for this command, look it up
		if ( EInfo.bRequiresPlayer || EInfo.CategoryName == 'Order' )
		{
			// Itterate over the PRI array
			for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
			{
				// If we are looking for all players or just this player and it matches
				if (PlayerID == 255 || WorldInfo.GRI.PRIArray[i].PlayerID == PlayerID)
				{
					// Only send to bots
					if ( UTBot(WorldInfo.GRI.PRIArray[i].Owner) != none )
					{
						// If we are on the same team
						if ( WorldInfo.GRI.OnSameTeam(WorldInfo.GRI.PRIArray[i], Sender) )
						{
							PRIs[PRIs.Length] = UTPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]);
						}
					}
				}
			}

			// Quick out if we didn't find targets

			if ( PRIs.Length == 0 )
			{
				return;
			}
		}
		else	// See with our own just to have the loop work
		{
			PRIs[0] = UTPlayerReplicationInfo(PlayerReplicationInfo);
		}

		// Give the command to the bot...
		if ( EInfo.Command != '' )
		{
			bShouldAck = true;
			for (i=0;i<PRIs.Length;i++)
			{
				if ( (PlayerID == 255) || (PRIs[i].PlayerID == PlayerID) )
				{
					Bot = UTBot(PRIs[i].Owner);
					if ( Bot != none )
					{
						//`log("### Command:"@EInfo.Command@"to"@PRIs[i].PlayerName);
						Bot.SetBotOrders(EInfo.Command, Sender, bShouldAck);
						bShouldAck = false;
						if ( PlayerID != 255 )
						{
							break;
						}
					}
				}
			}
		}
	}
}


/** Play an emote given a category and index within that category. */
simulated function DoPlayEmote(name InEmoteTag, int InPlayerID)
{
	local UTPlayerReplicationInfo UTPRI;
	local class<UTFamilyInfo> FamilyInfo;
	local int EmoteIndex;
	local EmoteInfo EInfo;

	UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if (UTPRI == None && DrivenVehicle != None)
	{
		UTPRI = UTPlayerReplicationInfo(DrivenVehicle.PlayerReplicationInfo);
	}
	if(UTPRI != None)
	{
		// Find the family we belong to (if we need to)
		FamilyInfo = GetFamilyInfo();

		EmoteIndex = FamilyInfo.static.GetEmoteIndex(InEmoteTag);

		if (EmoteIndex != INDEX_None)
		{

			EInfo = FamilyInfo.default.FamilyEmotes[EmoteIndex];

			// If on server..
			if (Role == ROLE_Authority)
			{
				// Perform any commands associated with this Emote if authoratitive
				if(EInfo.Command != '')
				{
					PerformEmoteCommand(EInfo, InPlayerID);
				}
			}

			// If this isn't a dedicated server, perform the emote
			if(Health > 0 && WorldInfo.NetMode != NM_DedicatedServer && UTPRI != None && !IsInState('FeigningDeath'))
			{
				// Play the anim in correct slot
				if(EInfo.EmoteAnim != '')
				{
					if(EInfo.bTopHalfEmote || DrivenVehicle != None)
					{
						if(TopHalfAnimSlot != None)
						{
							TopHalfAnimSlot.PlayCustomAnim(EInfo.EmoteAnim, 1.0, 0.2, 0.2, FALSE, TRUE);
						}
					}
					else
					{
						if(FullBodyAnimSlot != None)
						{
							FullBodyAnimSlot.PlayCustomAnim(EInfo.EmoteAnim, 1.0, 0.2, 0.2, FALSE, TRUE);
						}
					}
				}
			}
		}
	}
}

reliable server function ServerPlayEmote(name InEmoteTag, int InPlayerID)
{
	EmoteRepInfo.EmoteTag = InEmoteTag;
	EmoteRepInfo.bNewData = !EmoteRepInfo.bNewData;
	DoPlayEmote(InEmoteTag, InPlayerID);
	LastEmoteTime = WorldInfo.TimeSeconds;
}

exec simulated function PlayEmote(name InEmoteTag, int InPlayerID)
{
	// If it has been long enough since the last emote, play one now
	if(WorldInfo.TimeSeconds - LastEmoteTime > MinTimeBetweenEmotes)
	{
		ServerPlayEmote(InEmoteTag, InPlayerID);
		LastEmoteTime = WorldInfo.TimeSeconds;
	}
}

function OnPlayAnim( UTSeqAct_PlayAnim InAction )
{
	if( FullBodyAnimSlot != None )
	{
		FullBodyAnimSlot.PlayCustomAnim(InAction.AnimName, 1.0, 0.2, 0.2, InAction.bLooping, true);
	}
}

function SpawnDefaultController()
{
	local UTGame Game;
	local UTBot Bot;
	local CharacterInfo EmptyBotInfo;

	Super.SpawnDefaultController();

	Game = UTGame(WorldInfo.Game);
	Bot = UTBot(Controller);
	if (Game != None && Bot != None)
	{
		Game.InitializeBot(Bot, Game.GetBotTeam(), EmptyBotInfo);
	}
}

simulated function vector WeaponBob(float BobDamping, float JumpDamping)
{
	Local Vector WBob;

	WBob = BobDamping * WalkBob;
	WBob.Z = (0.45 + 0.55 * BobDamping)*WalkBob.Z;
	if ( !bWeaponBob )
	{
		WBob *= 2.5;
	}
	WBob.Z += JumpDamping *(LandBob - JumpBob);
	return WBob;
}

/** TurnOff()
Freeze pawn - stop sounds, animations, physics, weapon firing
*/
simulated function TurnOff()
{
	super.TurnOff();
	PawnAmbientSound.Stop();
	ClearTimer('FeignDeathDelayTimer');
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( (Vehicle(Other) != None) && (Weapon != None) && Weapon.IsA('UTTranslauncher') )
		return true;

	return Super.EncroachingOn(Other);
}

event EncroachedBy(Actor Other)
{
	local UTPawn P;

	// don't get telefragged by non-vehicle ragdolls and pawns feigning death
	P = UTPawn(Other);
	if (P == None || (!P.IsInState('FeigningDeath') && P.Physics != PHYS_RigidBody))
	{
		Super.EncroachedBy(Other);
	}
}

function gibbedBy(actor Other)
{
	local Pawn P;

	if ( Role < ROLE_Authority )
		return;

	P = Pawn(Other);
	if ( P != None )
	{
		Died(Pawn(Other).Controller, class'UTDmgType_Encroached', Location);
	}
	else
	{
		Died(None, class'UTDmgType_Encroached', Location);
	}
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Super.JumpOffPawn();
	bNoJumpAdjust = true;
	if ( UTBot(Controller) != None )
		UTBot(Controller).SetFall();
}

/** Called when pawn cylinder embedded in another pawn.  (Collision bug that needs to be fixed).
*/
event StuckOnPawn(Pawn OtherPawn)
{
	if( UTPawn(OtherPawn) != None )
	{
		TakeDamage( 10, None,Location, vect(0,0,0) , class'DmgType_Crushed');
		ForceRagdoll();
	}
}

event Falling()
{
	if ( UTBot(Controller) != None )
		UTBot(Controller).SetFall();
}

function AddVelocity( vector NewVelocity, vector HitLocation, class<DamageType> DamageType, optional TraceHitInfo HitInfo )
{
	local bool bRagdoll;

	if (!bIgnoreForces && !IsZero(NewVelocity))
	{
		if (Physics == PHYS_Falling && UTBot(Controller) != None)
		{
			UTBot(Controller).ImpactVelocity += NewVelocity;
		}

		if ( Role == ROLE_Authority && Physics == PHYS_Walking && DrivenVehicle == None && Vehicle(Base) != None
			&& VSize(Base.Velocity) > GroundSpeed )
		{
			bRagdoll = true;
		}

		Super.AddVelocity(NewVelocity, HitLocation, DamageType, HitInfo);

		// wait until velocity is applied before sending to ragdoll so that new velocity is used to start the physics
		if (bRagdoll)
		{
			ForceRagdoll();
		}
	}
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		StartFallImpactTime = WorldInfo.TimeSeconds;
		bCanPlayFallingImpacts=true;
		if(ArmsMesh[0] != none)
		{
			ArmsMesh[0].SetHidden(true);
			if(ArmsOverlay[0] != none)
			{
				ArmsOverlay[0].SetHidden(true);
			}
		}
		if(ArmsMesh[1] != none)
		{
			ArmsMesh[1].SetHidden(true);
			if(ArmsOverlay[1] != none)
			{
				ArmsOverlay[1].SetHidden(true);
			}
		}
		SetPawnAmbientSound(None);
		SetWeaponAmbientSound(None);
		return true;
	}
	return false;
}

simulated function StartFire(byte FireModeNum)
{
	// firing cancels feign death
	if (bFeigningDeath)
	{
		FeignDeath();
	}
	else
	{
		Super.StartFire(FireModeNum);
	}
}

function bool StopFiring()
{
	return StopWeaponFiring();
}

function bool BotFire(bool bFinished)
{
	local UTWeapon Weap;
	local UTBot Bot;

	Weap = UTWeapon(Weapon);
	if (Weap == None || (!Weap.ReadyToFire(bFinished) && !Weap.IsFiring()))
	{
		return false;
	}

	Bot = UTBot(Controller);
	if (Bot != None && Bot.ScriptedFireMode != 255)
	{
		StartFire(Bot.ScriptedFireMode);
	}
	else
	{
		StartFire(ChooseFireMode());
	}
	return true;
}

function bool StopWeaponFiring()
{
	local int i;
	local bool bResult;
	local UTWeapon UTWeap;

	UTWeap = UTWeapon(Weapon);
	if (UTWeap != None)
	{
		UTWeap.ClientEndFire(0);
		UTWeap.ClientEndFire(1);
		UTWeap.ServerStopFire(0);
		UTWeap.ServerStopFire(1);
		bResult = true;
	}

	if (InvManager != None)
	{
		for (i = 0; i < InvManager.GetPendingFireLength(Weapon); i++)
		{
			if( InvManager.IsPendingFire(Weapon, i) )
			{
				bResult = true;
				InvManager.ClearPendingFire(Weapon, i);
			}
		}
	}

	return bResult;
}

function byte ChooseFireMode()
{
	if ( UTWeapon(Weapon) != None )
	{
		return UTWeapon(Weapon).BestMode();
	}
	return 0;
}

function bool RecommendLongRangedAttack()
{
	if ( UTWeapon(Weapon) != None )
		return UTWeapon(Weapon).RecommendLongRangedAttack();
	return false;
}


function float RangedAttackTime()
{
	if ( UTWeapon(Weapon) != None )
		return UTWeapon(Weapon).RangedAttackTime();
	return 0;
}

simulated function float GetEyeHeight()
{
	if ( !IsLocallyControlled() )
		return BaseEyeHeight;
	else
		return EyeHeight;
}

function PlayVictoryAnimation()
{
	ServerPlayEmote(TauntNames[Rand(6)], -1);
}

simulated function OnModifyHealth(SeqAct_ModifyHealth Action)
{
	if( Action.bHeal )
	{
		GiveHealth(Action.Amount, HealthMax);
	}
	else
	{
		Super.OnModifyHealth(Action);
	}
}

simulated function string GetScreenName()
{
	return PlayerReplicationInfo.PlayerName;
}

/**
PostRenderFor()
Hook to allow pawns to render HUD overlays for themselves.
Called only if pawn was rendered this tick.
Assumes that appropriate font has already been set
@todo FIXMESTEVE - special beacon when speaking (SpeakingBeaconTexture)
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local float TextXL, XL, YL, Dist;
	local vector ScreenLoc;
	local LinearColor TeamColor;
	local Color	TextColor;
	local string ScreenName;
	local UTWeapon Weap;
	local UTPlayerReplicationInfo PRI;
	local UTHUDBase HUD;

	screenLoc = Canvas.Project(Location + GetCollisionHeight()*vect(0,0,1));
	// make sure not clipped out
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		return;
	}

	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if ( !WorldInfo.GRI.OnSameTeam(self, PC) )
	{
		// maybe change to action music if close enough
		if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
		{
			if ( !UTPlayerController(PC).AlreadyInActionMusic() && (VSize(CameraPosition - Location) < VSize(PC.ViewTarget.Location - Location)) && !IsInvisible() )
			{
				// check whether close enough to crosshair
				if ( (Abs(screenLoc.X - 0.5*Canvas.ClipX) < 0.1 * Canvas.ClipX)
					&& (Abs(screenLoc.Y - 0.5*Canvas.ClipY) < 0.1 * Canvas.ClipY) )
				{
					// periodically make sure really visible using traces
					if ( FastTrace(Location, CameraPosition,, true)
									|| FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition,, true) )
					{
						UTPlayerController(PC).ClientMusicEvent(0);;
					}
				}
			}
			LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
		}
		return;
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
		bPostRenderTraceSucceeded = FastTrace(Location, CameraPosition)
									|| FastTrace(Location+GetCollisionHeight()*vect(0,0,1), CameraPosition);
	}
	if ( !bPostRenderTraceSucceeded )
	{
		return;
	}

	class'UTHUD'.Static.GetTeamColor( GetTeamNum(), TeamColor, TextColor);

	Dist = VSize(CameraPosition - Location);
	if ( Dist < TeamBeaconPlayerInfoMaxDist )
	{
		ScreenName = GetScreenName();
		Canvas.StrLen(ScreenName, TextXL, YL);
		XL = Max( TextXL, 24 * Canvas.ClipX/1024 * (1 + 2*Square((TeamBeaconPlayerInfoMaxDist-Dist)/TeamBeaconPlayerInfoMaxDist)));
	}
	else
	{
		XL = Canvas.ClipX * 16 * TeamBeaconPlayerInfoMaxDist/(Dist * 1024);
		YL = 0;
	}

	Class'UTHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-1.8*YL,1.4*XL,1.9*YL, TeamColor, Canvas);

	if ( (PRI != None) && (Dist < TeamBeaconPlayerInfoMaxDist) )
	{
		Canvas.DrawColor = TextColor;
		Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.2*YL);
		Canvas.DrawText( ScreenName, true, , , class'UTHUD'.default.TextRenderInfo );
	}

	HUD = UTHUDBase(PC.MyHUD);
	if ( (HUD != None) && !HUD.bCrosshairOnFriendly
		&& (Abs(screenLoc.X - 0.5*Canvas.ClipX) < 0.1 * Canvas.ClipX)
		&& (screenLoc.Y <= 0.5*Canvas.ClipY) )
	{
		// check if top to bottom crosses center of screen
		screenLoc = Canvas.Project(Location - GetCollisionHeight()*vect(0,0,1));
		if ( screenLoc.Y >= 0.5*Canvas.ClipY )
		{
			HUD.bCrosshairOnFriendly = true;
		}
	}
}


simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	if ( Physics == PHYS_Ladder )
	{
		NewRotation = OnLadder.Walldir;
	}
	else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
	{
		NewRotation.Pitch = 0;
	}
	NewRotation.Roll = Rotation.Roll;
	SetRotation(NewRotation);
}

/* UpdateEyeHeight()
* Update player eye position, based on smoothing view while moving up and down stairs, and adding view bobs for landing and taking steps.
* Called every tick only if bUpdateEyeHeight==true.
*/
event UpdateEyeHeight( float DeltaTime )
{
	local float smooth, MaxEyeHeight, OldEyeHeight, Speed2D, OldBobTime;
	local Actor HitActor;
	local vector HitLocation,HitNormal, X, Y, Z;
	local int m,n;

	if ( bTearOff )
	{
		// no eyeheight updates if dead
		EyeHeight = Default.BaseEyeheight;
		bUpdateEyeHeight = false;
		return;
	}

	if ( abs(Location.Z - OldZ) > 15 )
	{
		// if position difference too great, don't do smooth land recovery
		bJustLanded = false;
		bLandRecovery = false;
	}

	if ( !bJustLanded )
	{
		// normal walking around
		// smooth eye position changes while going up/down stairs
		smooth = FMin(0.9, 10.0 * DeltaTime/CustomTimeDilation);
		LandBob *= (1 - smooth);
		if( Physics == PHYS_Walking || Physics==PHYS_Spider || Controller.IsInState('PlayerSwimming') )
		{
			OldEyeHeight = EyeHeight;
			EyeHeight = FMax((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
								-0.5 * CylinderComponent.CollisionHeight);
		}
		else
		{
			EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
		}
	}
	else if ( bLandRecovery )
	{
		// return eyeheight back up to full height
		smooth = FMin(0.9, 9.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		LandBob *= (1 - smooth);
		// linear interpolation at end
		if ( Eyeheight > 0.9 * BaseEyeHeight )
		{
			Eyeheight = Eyeheight + 0.15*BaseEyeheight*Smooth;  // 0.15 = (1-0.75)*0.6
		}
		else
			EyeHeight = EyeHeight * (1 - 0.6*smooth) + BaseEyeHeight*0.6*smooth;
		if ( Eyeheight >= BaseEyeheight)
		{
			bJustLanded = false;
			bLandRecovery = false;
			Eyeheight = BaseEyeheight;
		}
	}
	else
	{
		// drop eyeheight a bit on landing
		smooth = FMin(0.65, 8.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		EyeHeight = EyeHeight * (1 - 1.5*smooth);
		LandBob += 0.08 * (OldEyeHeight - Eyeheight);
		if ( (Eyeheight < 0.25 * BaseEyeheight + 1) || (LandBob > 2.4)  )
		{
			bLandRecovery = true;
			Eyeheight = 0.25 * BaseEyeheight + 1;
		}
	}

	// don't bob if disabled, or just landed
	if( bJustLanded || !bUpdateEyeheight )
	{
		BobTime = 0;
		WalkBob = Vect(0,0,0);
	}
	else
	{
		// add some weapon bob based on jumping
		if ( Velocity.Z > 0 )
		{
		  JumpBob = FMax(-1.5, JumpBob - 0.03 * DeltaTime * FMin(Velocity.Z,300));
		}
		else
		{
		  JumpBob *= (1 -  FMin(1.0, 8.0 * DeltaTime));
		}

		// Add walk bob to movement
		OldBobTime = BobTime;
		Bob = FClamp(Bob, -0.05, 0.05);

		if (Physics == PHYS_Walking )
		{
		  GetAxes(Rotation,X,Y,Z);
		  Speed2D = VSize(Velocity);
		  if ( Speed2D < 10 )
			  BobTime += 0.2 * DeltaTime;
		  else
			  BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
		  WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
		  AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		  WalkBob.Z = AppliedBob;
		  if ( Speed2D > 10 )
			  WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
		}
		else if ( Physics == PHYS_Swimming )
		{
		  GetAxes(Rotation,X,Y,Z);
		  BobTime += DeltaTime;
		  Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		  WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * BobTime);
		  WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * BobTime);
		}
		else
		{
		  BobTime = 0;
		  WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		if ( (Physics == PHYS_Walking) && (VSizeSq(Velocity) > 100) && IsFirstPerson() )
		{
			m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
			n = int(0.5 * Pi + 9.0 * BobTime/Pi);

			if ( (m != n) && !bIsWalking && !bIsCrouched )
			{
			  ActuallyPlayFootStepSound(0);
			}
		}
		if ( !bWeaponBob )
		{
			WalkBob *= 0.1;
		}
	}
	if ( (CylinderComponent.CollisionHeight - Eyeheight < 12) && IsFirstPerson() )
	{
	  // desired eye position is above collision box
	  // check to make sure that viewpoint doesn't penetrate another actor
		// min clip distance 12
		if (bCollideWorld)
		{
			HitActor = trace(HitLocation,HitNormal, Location + WalkBob + (MaxStepHeight + CylinderComponent.CollisionHeight) * vect(0,0,1),
						  Location + WalkBob, true, vect(12,12,12),, TRACEFLAG_Blocking);
			MaxEyeHeight = (HitActor == None) ? CylinderComponent.CollisionHeight + MaxStepHeight : HitLocation.Z - Location.Z;
			Eyeheight = FMin(Eyeheight, MaxEyeHeight);
		}
	}
}

/* GetPawnViewLocation()
Called by PlayerController to determine camera position in first person view.  Returns
the location at which to place the camera
*/
simulated function Vector GetPawnViewLocation()
{
	if ( bUpdateEyeHeight )
		return Location + EyeHeight * vect(0,0,1) + WalkBob;
	else
		return Location + BaseEyeHeight * vect(0,0,1);
}

/* BecomeViewTarget
	Called by Camera when this actor becomes its ViewTarget */
simulated event BecomeViewTarget( PlayerController PC )
{
	local UTPlayerController UTPC;
	local UTWeapon UTWeap;

	Super.BecomeViewTarget(PC);

	if (LocalPlayer(PC.Player) != None)
	{
		PawnAmbientSound.bAllowSpatialization = false;
		WeaponAmbientSound.bAllowSpatialization = false;

		bArmsAttached = true;
		AttachComponent(ArmsMesh[0]);
		UTWeap = UTWeapon(Weapon);
		if (UTWeap != None)
		{
			if (UTWeap.bUsesOffhand)
			{
				AttachComponent(ArmsMesh[1]);
			}
		}

		UTPC = UTPlayerController(PC);
		if (UTPC != None)
		{
			SetMeshVisibility(UTPC.bBehindView);
		}
		else
		{
			SetMeshVisibility(true);
		}
		bUpdateEyeHeight = true;
	}
}

/* EndViewTarget
	Called by Camera when this actor becomes its ViewTarget */
simulated event EndViewTarget( PlayerController PC )
{
	PawnAmbientSound.bAllowSpatialization = true;
	WeaponAmbientSound.bAllowSpatialization = true;

	if (LocalPlayer(PC.Player) != None)
	{
		SetMeshVisibility(true);
		bArmsAttached=false;
		DetachComponent(ArmsMesh[0]);
		DetachComponent(ArmsMesh[1]);
	}
}

simulated function SetWeaponVisibility(bool bWeaponVisible)
{
	local UTWeapon Weap;
	local AnimNodeSequence WeaponAnimNode, ArmAnimNode;
	local int i;

	Weap = UTWeapon(Weapon);
	if (Weap != None)
	{
		Weap.ChangeVisibility(bWeaponVisible);

		// make the arm animations copy the current weapon anim
		WeaponAnimNode = Weap.GetWeaponAnimNodeSeq();
		if (WeaponAnimNode != None)
		{
			for (i = 0; i < ArrayCount(ArmsMesh); i++)
			{
				if (ArmsMesh[i].bAttached)
				{
					ArmAnimNode = AnimNodeSequence(ArmsMesh[i].Animations);
					if (ArmAnimNode != None)
					{
						ArmAnimNode.SetAnim(WeaponAnimNode.AnimSeqName);
						ArmAnimNode.PlayAnim(WeaponAnimNode.bLooping, WeaponAnimNode.Rate, WeaponAnimNode.CurrentTime);
					}
				}
			}
		}
	}
}

simulated function SetWeaponAttachmentVisibility(bool bAttachmentVisible)
{
	bWeaponAttachmentVisible = bAttachmentVisible;
	if (CurrentWeaponAttachment != None )
	{
		CurrentWeaponAttachment.ChangeVisibility(bAttachmentVisible);
	}
}

/** sets whether or not the owner of this pawn can see it */
simulated function SetMeshVisibility(bool bVisible)
{
	local UTCarriedObject Flag;

	// Handle the main player mesh
	if (Mesh != None)
	{
		Mesh.SetOwnerNoSee(!bVisible);
	}

	SetOverlayVisibility(bVisible);

	// Handle any weapons they might have
	SetWeaponVisibility(!bVisible);

	// realign any attached flags
	foreach BasedActors(class'UTCarriedObject', Flag)
	{
		HoldGameObject(Flag);
	}
}

exec function FixedView(string VisibleMeshes)
{
	local bool bVisibleMeshes;
	local float fov;

	if (WorldInfo.NetMode == NM_Standalone)
	{
		if (VisibleMeshes != "")
		{
			bVisibleMeshes = ( VisibleMeshes ~= "yes" || VisibleMeshes~="true" || VisibleMeshes~="1" );

			if (VisibleMeshes ~= "default")
				bVisibleMeshes = !IsFirstPerson();

			SetMeshVisibility(bVisibleMeshes);
		}

		if (!bFixedView)
			CalcCamera( 0.0f, FixedViewLoc, FixedViewRot, fov );

		bFixedView = !bFixedView;
		`Log("FixedView:" @ bFixedView);
	}
}

function DeactivateSpawnProtection()
{
	if ( Role < ROLE_Authority )
		return;
	if ( !bSpawnDone )
	{
		bSpawnDone = true;
		if (WorldInfo.TimeSeconds - SpawnTime < UTGame(WorldInfo.Game).SpawnProtectionTime)
		{
			bSpawnIn = true;
			if (BodyMatColor == SpawnProtectionColor)
			{
				ClearBodyMatColor();
			}
			SpawnTime = WorldInfo.TimeSeconds - UTGame(WorldInfo.Game).SpawnProtectionTime - 1;
		}
		SpawnTime = -100000;
	}
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	local int TeamNum, TransCamIndx;
	local UTPlayerController PC;

	if ( (PlayerReplicationInfo != None) && (PlayerReplicationInfo.Team != None) )
	{
		TeamNum = PlayerReplicationInfo.Team.TeamIndex;
	}
	if ( !bSpawnIn && (WorldInfo.TimeSeconds - SpawnTime < UTGame(WorldInfo.Game).SpawnProtectionTime) )
	{
		bSpawnIn = true;
		SetBodyMatColor( SpawnProtectionColor, UTGame(WorldInfo.Game).SpawnProtectionTime );
		SpawnTransEffect(TeamNum);
		if (bSound)
		{
			PlaySound(SpawnSound);
		}
	}
	else
	{
		SetBodyMatColor( TranslocateColor[TeamNum], 1.0 );
		SpawnTransEffect(TeamNum);
		if (bSound)
		{
			PlaySound(TeleportSound);
		}
	}

	if (bOut)
	{
		PC = UTPlayerController(Controller);
		if (PC != None)
		{
			if ( !WorldInfo.Game.bTeamGame || PlayerReplicationInfo == None || PlayerReplicationInfo.Team == None
				|| PlayerReplicationInfo.Team.TeamIndex > 1 )
			{
				TransCamIndx = 2;
			}
			else
			{
				TransCamIndx = TeamNum;
			}
			PC.ClientPlayCameraAnim(TransCameraAnim[TransCamIndx], 1.0f);
		}
	}
	Super.PlayTeleportEffect( bOut, bSound );
}

function SpawnTransEffect(int TeamNum)
{
	if (TransInEffects[0] != None)
	{
		Spawn(TransInEffects[TeamNum],self,,Location + GetCollisionHeight() * vect(0,0,0.75));
	}
}

simulated event StartDriving(Vehicle V)
{
	local UTWeaponPawn WeaponPawn;
	local UTWeapon UTWeap;
	local UDKVehicleBase VBase;

	Super.StartDriving(V);

	DeactivateSpawnProtection();

	UTWeap = UTWeapon(Weapon);
	if (UTWeap != None)
	{
		StopWeaponFiring();
		UTWeap.HolderEnteredVehicle();
	}

	SetWeaponVisibility(false);
	SetWeaponAmbientSound(None);

	SetTeamColor();

	if (Role == ROLE_Authority)
	{
		// if we're driving a UTWeaponPawn, fill in the DrivenWeaponPawn info for remote clients
		WeaponPawn = UTWeaponPawn(V);
		if (WeaponPawn != None && WeaponPawn.MyVehicle != None && WeaponPawn.MySeatIndex != INDEX_NONE)
		{
			DrivenWeaponPawn.BaseVehicle = WeaponPawn.MyVehicle;
			DrivenWeaponPawn.SeatIndex = WeaponPawn.MySeatIndex;
			DrivenWeaponPawn.PRI = PlayerReplicationInfo;
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && WeaponOverlayFlags > 0)
	{
		VBase = UDKVehicleBase(V);
		if (VBase != None)
		{
			VBase.ApplyWeaponEffects(WeaponOverlayFlags);
		}
	}

	if (CurrCharClassInfo != None)
	{
		Mesh.SetScale(CurrCharClassInfo.default.DrivingDrawScale);
	}
}

/**
 * StartDriving() and StopDriving() also called on clients
 * on transitions of DrivenVehicle variable.
 * Network: ALL
 */
simulated event StopDriving(Vehicle V)
{
	local DrivenWeaponPawnInfo EmptyWeaponPawnInfo;
	local UDKVehicleBase VBase;

	Mesh.SetLightEnvironment(LightEnvironment);
	Mesh.SetScale(DefaultMeshScale);

	// ignore on non-owning client if we still have valid DrivenWeaponPawn
	if (Role < ROLE_Authority && DrivenWeaponPawn.BaseVehicle != None && !IsLocallyControlled())
	{
		// restore DrivenVehicle reference
		DrivenVehicle = ClientSideWeaponPawn;
	}
	else
	{
		if ( (Role == ROLE_Authority) && (PlayerController(Controller) != None) && (UTVehicle(V) != None) )
			UTVehicle(V).PlayerStartTime = WorldInfo.TimeSeconds + 12;
		Super.StopDriving(V);

		// don't allow pawn to double jump on exit (if was jumping when entered)
		MultiJumpRemaining = 0;

		SetWeaponVisibility(IsFirstPerson());
		bIgnoreForces = ( (UTGame(WorldInfo.Game) != None) && UTGame(WorldInfo.Game).bDemoMode && (PlayerController(Controller) != None) );

		if (Role == ROLE_Authority)
		{
			DrivenWeaponPawn = EmptyWeaponPawnInfo;
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		VBase = UDKVehicleBase(V);
		if (VBase != None)
		{
			VBase.ApplyWeaponEffects(0);
		}
	}
}

simulated function ClientReStart()
{
	local rotator AdjustedRotation;

	Super.ClientRestart();

	if (Controller != None)
	{
		AdjustedRotation = Controller.Rotation;
		AdjustedRotation.Roll = 0;
		Controller.SetRotation(AdjustedRotation);
	}
}

//=============================================================================
// Armor interface.

/** GetShieldStrength()
returns total armor value currently held by this pawn (not including helmet).
*/
function int GetShieldStrength()
{
	return ShieldBeltArmor + VestArmor + ThighpadArmor;
}

/** AbsorbDamage()
reduce damage and remove shields based on the absorption rate.
returns the remaining armor strength.
*/
function int AbsorbDamage(out int Damage, int CurrentShieldStrength, float AbsorptionRate)
{
	local int MaxAbsorbedDamage;

	MaxAbsorbedDamage = Min(Damage * AbsorptionRate, CurrentShieldStrength);
	Damage -= MaxAbsorbedDamage;
	return CurrentShieldStrength - MaxAbsorbedDamage;
}


/** ShieldAbsorb()
returns the resultant amount of damage after shields have absorbed what they can
*/
function int ShieldAbsorb( int Damage )
{
	if ( Health <= 0 )
	{
		return damage;
	}

	// shield belt absorbs 100% of damage
	if ( ShieldBeltArmor > 0 )
	{
		bShieldAbsorb = true;
		ShieldBeltArmor = AbsorbDamage(Damage, ShieldBeltArmor, 1.0);
		if (ShieldBeltArmor == 0)
		{
			SetOverlayMaterial(None);
		}
		if ( Damage == 0 )
		{
			SetBodyMatColor(SpawnProtectionColor, 1.0);
			PlaySound(ArmorHitSound);
			return 0;
		}
	}

	// vest absorbs 75% of damage
	if ( VestArmor > 0 )
	{
		bShieldAbsorb = true;
		VestArmor = AbsorbDamage(Damage, VestArmor, 0.75);
		if ( Damage == 0 )
		{
			return 0;
		}
	}

	// thighpads absorb 50% of damage
	if ( ThighpadArmor > 0 )
	{
		bShieldAbsorb = true;
		ThighpadArmor = AbsorbDamage(Damage, ThighpadArmor, 0.5);
		if ( Damage == 0 )
		{
			return 0;
		}
	}

	return Damage;
}

/* AdjustDamage()
adjust damage based on inventory, other attributes
*/
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	local int PreDamage;

	if ( bIsInvulnerable )
		inDamage = 0;

	if ( UTWeapon(Weapon) != None )
	{
		UTWeapon(Weapon).AdjustPlayerDamage( inDamage, InstigatedBy, HitLocation, Momentum, DamageType );
	}

	if( DamageType.default.bArmorStops && (inDamage > 0) )
	{
		PreDamage = inDamage;
		inDamage = ShieldAbsorb(inDamage);

		// still show damage effect on HUD if damage completely absorbed
		if ( (inDamage == 0) && (Controller != None) )
		{
			Controller.NotifyTakeHit(InstigatedBy, HitLocation, Min(PreDamage,10), DamageType, Momentum);
		}
	}
}

//=============================================================================

function DropFlag()
{
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if ( UTPRI==None || !UTPRI.bHasFlag )
		return;

	UTPRI.GetFlag().Drop();
	bJustDroppedOrb = true;
}

/**
 * EnableInventoryPickup()
 * Set bCanPickupInventory to true
 */
function EnableInventoryPickup()
{
	bCanPickupInventory = true;
}

/**
* Attach GameObject to mesh.
* @param GameObj : Game object to hold
*/
simulated event HoldGameObject(UDKCarriedObject GameObj)
{
	local UTCarriedObject UTGameObj;

	UTGameObj = UTCarriedObject(GameObj);
	UTGameObj.SetHardAttach(UTGameObj.default.bHardAttach);
	UTGameObj.bIgnoreBaseRotation = UTGameObj.default.bIgnoreBaseRotation;

	if ( class'Engine'.static.IsSplitScreen() )
	{
		if ( UTGameObj.GameObjBone3P != '' )
		{
			UTGameObj.SetBase(self,,Mesh,UTGameObj.GameObjBone3P);
		}
		else
		{
			UTGameObj.SetBase(self);
		}
		UTGameObj.SetRelativeRotation(UTGameObj.GameObjRot3P);
		UTGameObj.SetRelativeLocation(UTGameObj.GameObjOffset3P);
	}
	else if (IsFirstPerson())
	{
		UTGameObj.SetBase(self);
		UTGameObj.SetRelativeRotation(UTGameObj.GameObjRot1P);
		UTGameObj.SetRelativeLocation(UTGameObj.GameObjOffset1P);
	}
	else
	{
		if ( UTGameObj.GameObjBone3P != '' )
		{
			UTGameObj.SetBase(self,,Mesh,UTGameObj.GameObjBone3P);
		}
		else
		{
			UTGameObj.SetBase(self);
		}
		UTGameObj.SetRelativeRotation(UTGameObj.GameObjRot3P);
		UTGameObj.SetRelativeLocation(UTGameObj.GameObjOffset3P);
	}
}

function bool GiveHealth(int HealAmount, int HealMax)
{
	if (Health < HealMax)
	{
		Health = Min(HealMax, Health + HealAmount);
		return true;
	}
	return false;
}

/**
 * Overridden to return the actual player name from this Pawn's
 * PlayerReplicationInfo (PRI) if available.
 */
function String GetDebugName()
{
	// return the actual player name from the PRI if available
	if (PlayerReplicationInfo != None)
	{
		return "";
	}
	// otherwise return the formatted object name
	return GetItemName(string(self));
}

simulated event PlayFootStepSound(int FootDown)
{
	local PlayerController PC;

	if ( !IsFirstPerson() )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxFootstepDistSq) )
			{
				ActuallyPlayFootstepSound(FootDown);
				return;
			}
		}
	}
}

/**
 * Handles actual playing of sound.  Separated from PlayFootstepSound so we can
 * ignore footstep sound notifies in first person.
 */
simulated function ActuallyPlayFootstepSound(int FootDown)
{
	local SoundCue FootSound;

	FootSound = SoundGroupClass.static.GetFootstepSound(FootDown, GetMaterialBelowFeet());
	if (FootSound != None)
	{
		PlaySound(FootSound, false, true,,, true);
	}
}

simulated function name GetMaterialBelowFeet()
{
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local UTPhysicalMaterialProperty PhysicalProperty;
	local actor HitActor;
	local float TraceDist;

	TraceDist = 1.5 * GetCollisionHeight();

	HitActor = Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	if ( WaterVolume(HitActor) != None )
	{
		return (Location.Z - HitLocation.Z < 0.33*TraceDist) ? 'Water' : 'ShallowWater';
	}
	if (HitInfo.PhysMaterial != None)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
		if (PhysicalProperty != None)
		{
			return PhysicalProperty.MaterialType;
		}
	}
	return '';

}

function PlayLandingSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq) )
		{
			PlaySound(SoundGroupClass.static.GetLandSound(GetMaterialBelowFeet()));
			return;
		}
	}
}

function PlayJumpingSound()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxJumpSoundDistSq) )
		{
			PlaySound(SoundGroupClass.static.GetJumpSound(GetMaterialBelowFeet()));
			return;
		}
	}
}

/** @return whether or not we should gib due to damage from the passed in damagetype */
simulated function bool ShouldGib(class<UTDamageType> UTDamageType)
{
	return ( (Mesh != None) && (bTearOffGibs || UTDamageType.Static.ShouldGib(self)) );
}

/** spawn a special gib for this pawn's head and sets it as the ViewTarget for any players that were viewing this pawn */
simulated function SpawnHeadGib(class<UTDamageType> UTDamageType, vector HitLocation)
{
	local UTGib Gib;
	local UTPlayerController PC;
	local class<UDKEmitCameraEffect> CameraEffect;
	local vector ViewLocation;
	local rotator ViewRotation;
	local PlayerReplicationInfo OldRealViewTarget;
	local class<UTFamilyInfo> FamilyInfo;

	if ( class'GameInfo'.Static.UseLowGore(WorldInfo) )
	{
		bHeadGibbed = true;
		return;
	}

	if (!bHeadGibbed)
	{
		// create separate actor for the head so it can bounce around independently
		if ( HitLocation == Location )
		{
			HitLocation = Location + vector(Rotation);
		}

		FamilyInfo = CurrCharClassInfo;
		Gib = SpawnGib(CurrCharClassInfo.default.HeadGib.GibClass, FamilyInfo.default.HeadGib.BoneName, UTDamageType, HitLocation, false);

		if (Gib != None)
		{
			Gib.SetRotation(Rotation);
			Gib.SetTexturesToBeResident( Gib.LifeSpan );
			SetHeadScale(0.f);
			WorldInfo.MyEmitterPool.SpawnEmitter(FamilyInfo.default.HeadShotEffect, Gib.Location, rotator(vect(0,0,1)), Gib);

			foreach LocalPlayerControllers(class'UTPlayerController', PC)
			{
				if (PC.ViewTarget == self)
				{
					// save RealViewTarget for spectating so that this transition doesn't affect it
					OldRealViewTarget = PC.RealViewTarget;
					if (UTDamageType.default.bHeadGibCamera && (PC.UsingFirstPersonCamera() || !PC.IsInState('BaseSpectating')))
					{
						PC.SetViewTarget(Gib);

						CameraEffect = UTDamageType.static.GetDeathCameraEffectVictim(self);
						if (CameraEffect != None)
						{
							PC.ClientSpawnCameraEffect(CameraEffect);
						}
					}
					else
					{
						PC.GetPlayerViewPoint(ViewLocation, ViewRotation);
						PC.SetViewTarget(PC);
						PC.SetLocation(ViewLocation);
						PC.SetRotation(ViewRotation);
					}
					PC.RealViewTarget = OldRealViewTarget;
				}
			}

			bHeadGibbed = true;
		}
	}
}

simulated function UTGib SpawnGib(class<UTGib> GibClass, name BoneName, class<UTDamageType> UTDamageType, vector HitLocation, bool bSpinGib)
{
	local UTGib Gib;
	local rotator SpawnRot;
	local int SavedPitch;
	local float GibPerterbation;
	local rotator VelRotation;
	local vector X, Y, Z;

	SpawnRot = QuatToRotator(Mesh.GetBoneQuaternion(BoneName));

	// @todo fixmesteve temp workaround for gib orientation problem
	SavedPitch = SpawnRot.Pitch;
	SpawnRot.Pitch = SpawnRot.Yaw;
	SpawnRot.Yaw = SavedPitch;
	Gib = Spawn(GibClass, self,, Mesh.GetBoneLocation(BoneName), SpawnRot);

	if ( Gib != None )
	{
		// add initial impulse
		GibPerterbation = UTDamageType.default.GibPerterbation * 32768.0;
		VelRotation = rotator(Gib.Location - HitLocation);
		VelRotation.Pitch += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		VelRotation.Yaw += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		VelRotation.Roll += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
		GetAxes(VelRotation, X, Y, Z);

		if (Gib.bUseUnrealPhysics)
		{
			Gib.Velocity = Velocity + Z * (FRand() * 200.0 + 50.0);
			Gib.SetPhysics(PHYS_Falling);
		}
		else
		{
			Gib.Velocity = Velocity + Z * (FRand() * 50.0);
			Gib.GibMeshComp.WakeRigidBody();
			Gib.GibMeshComp.SetRBLinearVelocity(Gib.Velocity, false);
			if ( bSpinGib )
			{
				Gib.GibMeshComp.SetRBAngularVelocity(VRand() * 50, false);
			}
		}

		// let damagetype spawn any additional effects
		UTDamageType.static.SpawnGibEffects(Gib);
		Gib.LifeSpan = Gib.LifeSpan + (2.0 * FRand());
	}

	return Gib;
}

/** spawns gibs and hides the pawn's mesh */
simulated function SpawnGibs(class<UTDamageType> UTDamageType, vector HitLocation)
{
	local int i;
	local bool bSpawnHighDetail;
	local GibInfo MyGibInfo;

	// make sure client gibs me too
	bTearOffGibs = true;

	if ( !bGibbed )
	{
		if ( WorldInfo.NetMode == NM_DedicatedServer )
		{
			bGibbed = true;
			return;
		}

		// play sound
		if(WorldInfo.TimeSeconds - DeathTime < 0.35) // had to have just died to do a death scream.
		{
			SoundGroupClass.static.PlayGibSound(self);
		}
		SoundGroupClass.static.PlayBodyExplosion(self); // the body sounds can go off any time

		SpawnHeadGib(UTDamageType, HitLocation);

		// if we had one of these attached we need to hide it (e.g. headshotted and then gibbed)
		if( HeadshotNeckAttachment != none )
		{
			HeadshotNeckAttachment.SetHidden(true);
		}

		// gib particles
		if (GetFamilyInfo().default.GibExplosionTemplate != None && EffectIsRelevant(Location, false, 7000))
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(GetFamilyInfo().default.GibExplosionTemplate, Location, Rotation);
			// spawn all other gibs
			bSpawnHighDetail = !WorldInfo.bDropDetail && (Worldinfo.TimeSeconds - LastRenderTime < 1);
			for (i = 0; i < CurrCharClassInfo.default.Gibs.length; i++)
			{
				MyGibInfo = CurrCharClassInfo.default.Gibs[i];

				if ( bSpawnHighDetail || !MyGibInfo.bHighDetailOnly )
				{
					SpawnGib(MyGibInfo.GibClass, MyGibInfo.BoneName, UTDamageType, HitLocation, true);
				}
			}
		}

		// if standalone or client, destroy here
		if ( WorldInfo.NetMode != NM_DedicatedServer && !WorldInfo.IsRecordingDemo() &&
			((WorldInfo.NetMode != NM_ListenServer) || (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumSpectators < 2)) )
		{
			Destroy();
		}
		else
		{
			TurnOffPawn();
		}

		bGibbed = true;
	}
}

simulated function TurnOffPawn()
{
	// hide everything, turn off collision
	if (Physics == PHYS_RigidBody)
	{
		Mesh.SetHasPhysicsAssetInstance(FALSE);
		Mesh.PhysicsWeight = 0.f;
		SetPhysics(PHYS_None);
	}
	if (!IsInState('Dying')) // so we don't restart Begin label and possibly play dying sound again
	{
		GotoState('Dying');
	}
	SetPhysics(PHYS_None);
	SetCollision(false, false);
	//@warning: can't set bHidden - that will make us lose net relevancy to everyone
	Mesh.SetHidden(true);
	if (OverlayMesh != None)
	{
		OverlayMesh.SetHidden(true);
	}
}

/**
 * Responsible for playing any death effects, animations, etc.
 *
 * @param 	DamageType - type of damage responsible for this pawn's death
 *
 * @param	HitLoc - location of the final shot
 */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector ApplyImpulse, ShotDir;
	local TraceHitInfo HitInfo;
	local PlayerController PC;
	local bool bPlayersRagdoll, bUseHipSpring;
	local class<UTDamageType> UTDamageType;
	local RB_BodyInstance HipBodyInst;
	local int HipBoneIndex;
	local matrix HipMatrix;
	local class<UDKEmitCameraEffect> CameraEffect;
	local name HeadShotSocketName;
	local SkeletalMeshSocket SMS;

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	bForcedFeignDeath = false;
	bPlayingFeignDeathRecovery = false;

	HitDamageType = DamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

	// make sure I don't have an active weaponattachment
	CurrentWeaponAttachmentClass = None;
	WeaponAttachmentChanged();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
 		UTDamageType = class<UTDamageType>(DamageType);
		// tell clients whether to gib
		bTearOffGibs = (UTDamageType != None && ShouldGib(UTDamageType));
		bGibbed = bGibbed || bTearOffGibs;
		GotoState('Dying');
		return;
	}

	// Is this the local player's ragdoll?
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if( pc.ViewTarget == self )
		{
			if ( UTHud(pc.MyHud)!=none )
				UTHud(pc.MyHud).DisplayHit(HitLoc, 100, DamageType);
			bPlayersRagdoll = true;
			break;
		}
	}
	if ( (WorldInfo.TimeSeconds - LastRenderTime > 3) && !bPlayersRagdoll )
	{
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.IsRecordingDemo())
		{
			if (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumSpectators < 2 && !WorldInfo.IsRecordingDemo())
			{
				Destroy();
				return;
			}
			bHideOnListenServer = true;

			// check if should gib (for clients)
			UTDamageType = class<UTDamageType>(DamageType);
			if (UTDamageType != None && ShouldGib(UTDamageType))
			{
				bTearOffGibs = true;
				bGibbed = true;
			}
			TurnOffPawn();
			return;
		}
		else
		{
			// if we were not just controlling this pawn,
			// and it has not been rendered in 3 seconds, just destroy it.
			Destroy();
			return;
		}
	}

	UTDamageType = class<UTDamageType>(DamageType);
	if (UTDamageType != None && !class'GameInfo'.static.UseLowGore(WorldInfo) && ShouldGib(UTDamageType))
	{
		SpawnGibs(UTDamageType, HitLoc);
	}
	else
	{
		CheckHitInfo( HitInfo, Mesh, Normal(TearOffMomentum), TakeHitLocation );

		// check to see if we should do a CustomDamage Effect
		if( UTDamageType != None )
		{
			if( UTDamageType.default.bUseDamageBasedDeathEffects )
			{
				UTDamageType.static.DoCustomDamageEffects(self, UTDamageType, HitInfo, TakeHitLocation);
			}

			if( UTPlayerController(PC) != none )
			{
				CameraEffect = UTDamageType.static.GetDeathCameraEffectVictim(self);
				if (CameraEffect != None)
				{
					UTPlayerController(PC).ClientSpawnCameraEffect(CameraEffect);
				}
			}
		}

		bBlendOutTakeHitPhysics = false;

		// Turn off hand IK when dead.
		SetHandIKEnabled(false);

		// if we had some other rigid body thing going on, cancel it
		if (Physics == PHYS_RigidBody)
		{
			//@note: Falling instead of None so Velocity/Acceleration don't get cleared
			setPhysics(PHYS_Falling);
		}

		PreRagdollCollisionComponent = CollisionComponent;
		CollisionComponent = Mesh;

		Mesh.MinDistFactorForKinematicUpdate = 0.f;

		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		if( Mesh.bNotUpdatingKinematicDueToDistance )
		{
			Mesh.ForceSkelUpdate();
			Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
		}

		Mesh.PhysicsWeight = 1.0;

		if(UTDamageType != None && UTDamageType.default.DeathAnim != '' && (FRand() > 0.5) )
		{
			// Don't want to use stop player and use hip-spring if in the air (eg PHYS_Falling)
			if(Physics == PHYS_Walking && UTDamageType.default.bAnimateHipsForDeathAnim)
			{
				SetPhysics(PHYS_None);
				bUseHipSpring=true;
			}
			else
			{
				SetPhysics(PHYS_RigidBody);
				// We only want to turn on 'ragdoll' collision when we are not using a hip spring, otherwise we could push stuff around.
				SetPawnRBChannels(TRUE);
			}

			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);

			// Turn on angular motors on skeleton.
			Mesh.bUpdateJointsFromAnimation = TRUE;
			Mesh.PhysicsAssetInstance.SetNamedMotorsAngularPositionDrive(false, false, NoDriveBodies, Mesh, true);
			Mesh.PhysicsAssetInstance.SetAngularDriveScale(1.0f, 1.0f, 0.0f);

			// If desired, turn on hip spring to keep physics character upright
			if(bUseHipSpring)
			{
				HipBodyInst = Mesh.PhysicsAssetInstance.FindBodyInstance('b_Hips', Mesh.PhysicsAsset);
				HipBoneIndex = Mesh.MatchRefBone('b_Hips');
				HipMatrix = Mesh.GetBoneMatrix(HipBoneIndex);
				HipBodyInst.SetBoneSpringParams(DeathHipLinSpring, DeathHipLinDamp, DeathHipAngSpring, DeathHipAngDamp);
				HipBodyInst.bMakeSpringToBaseCollisionComponent = FALSE;
				HipBodyInst.EnableBoneSpring(TRUE, TRUE, HipMatrix);
				HipBodyInst.bDisableOnOverextension = TRUE;
				HipBodyInst.OverextensionThreshold = 100.f;
			}

			FullBodyAnimSlot.PlayCustomAnim(UTDamageType.default.DeathAnim, UTDamageType.default.DeathAnimRate, 0.05, -1.0, false, false);
			SetTimer(0.1, true, 'DoingDeathAnim');
			StartDeathAnimTime = WorldInfo.TimeSeconds;
			TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
			DeathAnimDamageType = UTDamageType;
		}
		else
		{
			SetPhysics(PHYS_RigidBody);
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
			SetPawnRBChannels(TRUE);

			if( TearOffMomentum != vect(0,0,0) )
			{
				ShotDir = normal(TearOffMomentum);
				ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;

				// If not moving downwards - give extra upward kick
				if ( Velocity.Z > -10 )
				{
					ApplyImpulse += Vect(0,0,1)*DamageType.default.KDeathUpKick;
				}
				Mesh.AddImpulse(ApplyImpulse, TakeHitLocation, HitInfo.BoneName, true);
			}
		}
		GotoState('Dying');

		if (WorldInfo.NetMode != NM_DedicatedServer && UTDamageType != None && UTDamageType.default.bSeversHead && !bDeleteMe)
		{
			SpawnHeadGib(UTDamageType, HitLoc);

			if ( !class'GameInfo'.Static.UseLowGore(WorldInfo) )
			{
				HeadShotSocketName = GetFamilyInfo().default.HeadShotGoreSocketName;
				SMS = Mesh.GetSocketByName( HeadShotSocketName );
				if( SMS != none )
				{
					HeadshotNeckAttachment = new(self) class'StaticMeshComponent';
					HeadshotNeckAttachment.SetActorCollision( FALSE, FALSE );
					HeadshotNeckAttachment.SetBlockRigidBody( FALSE );

					Mesh.AttachComponentToSocket( HeadshotNeckAttachment, HeadShotSocketName );
					HeadshotNeckAttachment.SetStaticMesh( GetFamilyInfo().default.HeadShotNeckGoreAttachment );
					HeadshotNeckAttachment.SetLightEnvironment( LightEnvironment );
				}
			}
		}
	}
}

simulated function DoingDeathAnim()
{
	local RB_BodyInstance HipBodyInst;
	local matrix DummyMatrix;
	local AnimNodeSequence SlotSeqNode;
	local float TimeSinceDeathAnimStart, MotorScale;
	local bool bStopAnim;


	if(DeathAnimDamageType.default.MotorDecayTime != 0.0)
	{
		TimeSinceDeathAnimStart = WorldInfo.TimeSeconds - StartDeathAnimTime;
		MotorScale = 1.0 - (TimeSinceDeathAnimStart/DeathAnimDamageType.default.MotorDecayTime);

		// If motors are scaled to zero, stop death anim
		if(MotorScale <= 0.0)
		{
			bStopAnim = TRUE;
		}
		// If non-zero, scale motor strengths
		else
		{
			Mesh.PhysicsAssetInstance.SetAngularDriveScale(MotorScale, MotorScale, 0.0f);
		}
	}

	// If we want to stop animation after a certain
	if( DeathAnimDamageType != None &&
		DeathAnimDamageType.default.StopAnimAfterDamageInterval != 0.0 &&
		(WorldInfo.TimeSeconds - TimeLastTookDeathAnimDamage) > DeathAnimDamageType.default.StopAnimAfterDamageInterval )
	{
		bStopAnim = TRUE;
	}


	// If done playing custom death anim - turn off bone motors.
	SlotSeqNode = AnimNodeSequence(FullBodyAnimSlot.Children[1].Anim);
	if(!SlotSeqNode.bPlaying || bStopAnim)
	{
		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(false, false);
		HipBodyInst = Mesh.PhysicsAssetInstance.FindBodyInstance('b_Hips', Mesh.PhysicsAsset);
		HipBodyInst.EnableBoneSpring(FALSE, FALSE, DummyMatrix);

		// Ensure we have ragdoll collision on at this point
		SetPawnRBChannels(TRUE);

		ClearTimer('DoingDeathAnim');
		DeathAnimDamageType = None;
	}
}

simulated event Destroyed()
{
	local PlayerController PC;
	local Actor A;

	Super.Destroyed();

	foreach BasedActors(class'Actor', A)
	{
		A.PawnBaseDied();
	}

	// remove from local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( PC.MyHUD != None )
		{
			PC.MyHUD.RemovePostRenderedActor(self);
		}
	}

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}
}


function AddDefaultInventory()
{
	Controller.ClientSwitchToBestWeapon();
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
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	// Handle the fixed camera

	if (bFixedView)
	{
		out_CamLoc = FixedViewLoc;
		out_CamRot = FixedViewRot;
	}
	else
	{
		if ( !IsFirstPerson() )	// Handle BehindView
		{
			CalcThirdPersonCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
		}
		else
		{
			// By default, we view through the Pawn's eyes..
			GetActorEyesViewPoint( out_CamLoc, out_CamRot );
		}

		if ( UTWeapon(Weapon) != none)
		{
			UTWeapon(Weapon).WeaponCalcCamera(fDeltaTime, out_CamLoc, out_CamRot);
		}
	}

	return true;
}

simulated function SetThirdPersonCamera(bool bNewBehindView)
{
	if ( bNewBehindView )
	{
		CurrentCameraScale = 1.0;
		CameraZOffset = GetCollisionHeight() + Mesh.Translation.Z;
	}
	SetMeshVisibility(bNewBehindView);
}


/** Used by PlayerController.FindGoodView() in RoundEnded State */
simulated function FindGoodEndView(PlayerController InPC, out Rotator GoodRotation)
{
	local rotator ViewRotation;
	local int tries;
	local float bestdist, newdist;
	local UTPlayerController PC;

	PC = UTPlayerController(InPC);

	bWinnerCam = true;
	SetHeroCam(GoodRotation);
	GoodRotation.Pitch = HeroCameraPitch;
	ViewRotation = GoodRotation;
	ViewRotation.Yaw = Rotation.Yaw + 32768 + 8192;
	if ( TryNewCamRot(PC, ViewRotation, newdist) )
	{
		GoodRotation = ViewRotation;
		return;
	}

	ViewRotation = GoodRotation;
	ViewRotation.Yaw = Rotation.Yaw + 32768 - 8192;
	if ( TryNewCamRot(PC, ViewRotation, newdist) )
	{
		GoodRotation = ViewRotation;
		return;
	}

	// failed with Hero cam
	ViewRotation.Pitch = 56000;
	tries = 0;
	bestdist = 0.0;
	CameraScale = Default.CameraScale;
	CurrentCameraScale = Default.CameraScale;
	for (tries=0; tries<16; tries++)
	{
		if ( TryNewCamRot(PC, ViewRotation, newdist) )
		{
			GoodRotation = ViewRotation;
			return;
		}

		if (newdist > bestdist)
		{
			bestdist = newdist;
			GoodRotation = ViewRotation;
		}
		ViewRotation.Yaw += 4096;
	}
}

simulated function bool TryNewCamRot(UTPlayerController PC, rotator ViewRotation, out float CamDist)
{
	local vector cameraLoc;
	local rotator cameraRot;
	local float FOVAngle;

	cameraLoc = Location;
	cameraRot = ViewRotation;
	if ( CalcThirdPersonCam(0, cameraLoc, cameraRot, FOVAngle) )
	{
		CamDist = VSize(cameraLoc - Location - vect(0,0,1)*CameraZOffset);
		return true;
	}
	CamDist = VSize(cameraLoc - Location - vect(0,0,1)*CameraZOffset);
	return false;
}

simulated function SetHeroCam(out rotator out_CamRot)
{
	CameraZOffset = 0.0;
	CameraScale = HeroCameraScale;
	CurrentCameraScale = HeroCameraScale;
}

simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
	local float DesiredCameraZOffset;

	ModifyRotForDebugFreeCam(out_CamRot);

	CamStart = Location;
	CurrentCamOffset = CamOffset;

	if ( bWinnerCam )
	{
		// use "hero" cam
		SetHeroCam(out_CamRot);
		CurrentCamOffset = vect(0,0,0);
		CurrentCamOffset.X = GetCollisionRadius();
	}
	else
	{
		DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
		CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
		if ( Health <= 0 )
		{
			CurrentCamOffset = vect(0,0,0);
			CurrentCamOffset.X = GetCollisionRadius();
		}
	}
	CamStart.Z += CameraZOffset;
	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// adjust camera position to make sure it's not clipping into world
		// @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	if (CamDirX.Z > GetCollisionHeight())
	{
		CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}
	out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;
	if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
	{
		out_CamLoc = HitLocation;
		return false;
	}
	return true;
}

/**
 * Return world location to start a weapon fire trace from.
 *
 * @return	World location where to start weapon fire traces from
 */
simulated function Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	return GetPawnViewLocation();
}

//=============================================
// Jumping functionality

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z, TraceStart, TraceEnd, Dir, Cross, HitLocation, HitNormal;
	local Actor HitActor;
	local rotator TurnRot;

	if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking && Physics != PHYS_Falling) )
		return false;

	TurnRot.Yaw = Rotation.Yaw;
	GetAxes(TurnRot,X,Y,Z);

	if ( Physics == PHYS_Falling )
	{
		if (DoubleClickMove == DCLICK_Forward)
			TraceEnd = -X;
		else if (DoubleClickMove == DCLICK_Back)
			TraceEnd = X;
		else if (DoubleClickMove == DCLICK_Left)
			TraceEnd = Y;
		else if (DoubleClickMove == DCLICK_Right)
			TraceEnd = -Y;
		TraceStart = Location - (CylinderComponent.CollisionHeight - 16)*Vect(0,0,1) + TraceEnd*(CylinderComponent.CollisionRadius-16);
		TraceEnd = TraceStart + TraceEnd*40.0;
		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(16,16,16));

		if ( (HitActor == None) || (HitNormal.Z < -0.1) )
			 return false;
		if (  !HitActor.bWorldGeometry )
		{
			if ( !HitActor.bBlockActors )
				return false;
			if ( (Pawn(HitActor) != None) && (Vehicle(HitActor) == None) )
				return false;
		}
	}
	if (DoubleClickMove == DCLICK_Forward)
	{
		Dir = X;
		Cross = Y;
	}
	else if (DoubleClickMove == DCLICK_Back)
	{
		Dir = -1 * X;
		Cross = Y;
	}
	else if (DoubleClickMove == DCLICK_Left)
	{
		Dir = -1 * Y;
		Cross = X;
	}
	else if (DoubleClickMove == DCLICK_Right)
	{
		Dir = Y;
		Cross = X;
	}
	if ( AIController(Controller) != None )
		Cross = vect(0,0,0);
	return PerformDodge(DoubleClickMove, Dir,Cross);
}

/* BotDodge()
returns appropriate vector for dodge in direction Dir (which should be normalized)
*/
function vector BotDodge(Vector Dir)
{
	local vector Vel;

	Vel = DodgeSpeed*Dir;
	Vel.Z = DodgeSpeedZ;
	return Vel;
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	local float VelocityZ;

	if ( Physics == PHYS_Falling )
	{
		TakeFallingDamage();
	}

	bDodging = true;
	bReadyToDoubleJump = (JumpBootCharge > 0);
	VelocityZ = Velocity.Z;
	Velocity = DodgeSpeed*Dir + (Velocity Dot Cross)*Cross;

	if ( VelocityZ < -200 )
		Velocity.Z = VelocityZ + DodgeSpeedZ;
	else
		Velocity.Z = DodgeSpeedZ;

	CurrentDir = DoubleClickMove;
	SetPhysics(PHYS_Falling);
	SoundGroupClass.Static.PlayDodgeSound(self);
	return true;
}

function DoDoubleJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch )
	{
		if ( !IsLocallyControlled() || AIController(Controller) != None )
		{
			MultiJumpRemaining -= 1;
		}
		Velocity.Z = JumpZ + MultiJumpBoost;
		UTInventoryManager(InvManager).OwnerEvent('MultiJump');
		SetPhysics(PHYS_Falling);
		BaseEyeHeight = DoubleJumpEyeHeight;
		if (!bUpdating)
		{
			SoundGroupClass.Static.PlayDoubleJumpSound(self);
		}
	}
}

function Gasp()
{
	SoundGroupClass.Static.PlayGaspSound(self);
}


/** Flying support */
simulated function StartFlying();
simulated function StopFlying();

function bool DoJump( bool bUpdating )
{
	// This extra jump allows a jumping or dodging pawn to jump again mid-air
	// (via thrusters). The pawn must be within +/- DoubleJumpThreshold velocity units of the
	// apex of the jump to do this special move.
	if ( !bUpdating && CanDoubleJump()&& (Abs(Velocity.Z) < DoubleJumpThreshold) && IsLocallyControlled() )
	{
		if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
		DoDoubleJump(bUpdating);
		MultiJumpRemaining -= 1;
		return true;
	}

	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
	{
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			if ( (WorldInfo.WorldGravityZ != WorldInfo.DefaultGravityZ) && (GetGravityZ() == WorldInfo.WorldGravityZ) )
			{
				Velocity.Z += Base.Velocity.Z * sqrt(GetGravityZ()/WorldInfo.DefaultGravityZ);
			}
			else
			{
				Velocity.Z += Base.Velocity.Z;
			}
		}
		SetPhysics(PHYS_Falling);
		bReadyToDoubleJump = true;
		bDodging = false;
		if ( !bUpdating )
		    PlayJumpingSound();
		return true;
	}
	return false;
}

event Landed(vector HitNormal, actor FloorActor)
{
	local vector Impulse;

	Super.Landed(HitNormal, FloorActor);

	// adds impulses to vehicles and dynamicSMActors (e.g. KActors)
	Impulse.Z = Velocity.Z * 4.0f; // 4.0f works well for landing on a Scorpion
	if (UTVehicle(FloorActor) != None)
	{
		UTVehicle(FloorActor).Mesh.AddImpulse(Impulse, Location);
	}
	else if (DynamicSMActor(FloorActor) != None)
	{
		DynamicSMActor(FloorActor).StaticMeshComponent.AddImpulse(Impulse, Location);
	}

	if ( Velocity.Z < -200 )
	{
		OldZ = Location.Z;
		bJustLanded = bUpdateEyeHeight && (Controller != None) && Controller.LandingShake();
	}

	if (UTInventoryManager(InvManager) != None)
	{
		UTInventoryManager(InvManager).OwnerEvent('Landed');
	}
	if ((MultiJumpRemaining < MaxMultiJump && bStopOnDoubleLanding) || bDodging || Velocity.Z < -2 * JumpZ)
	{
		// slow player down if double jump landing
		Velocity.X *= 0.1;
		Velocity.Y *= 0.1;
	}

	AirControl = DefaultAirControl;
	MultiJumpRemaining = MaxMultiJump;
	bDodging = false;
	bReadyToDoubleJump = false;
	if (UTBot(Controller) != None)
	{
		UTBot(Controller).ImpactVelocity = vect(0,0,0);
	}

	if(!bHidden)
	{
		PlayLandingSound();
	}
	if (Velocity.Z < -MaxFallSpeed)
	{
		SoundGroupClass.Static.PlayFallingDamageLandSound(self);
	}
	else if (Velocity.Z < MaxFallSpeed * -0.5)
	{
		SoundGroupClass.Static.PlayLandSound(self);
	}

	SetBaseEyeheight();
}

function JumpOutOfWater(vector jumpDir)
{
	bReadyToDoubleJump = true;
	bDodging = false;
	Super.JumpOutOfWater(jumpDir);
}

function bool CanDoubleJump()
{
	return ( (MultiJumpRemaining > 0) && (Physics == PHYS_Falling) && (bReadyToDoubleJump || (UTBot(Controller) != None)) );
}

function bool CanMultiJump()
{
	return ( MaxMultiJump > 0 );
}

function PlayDyingSound()
{
	SoundGroupClass.Static.PlayDyingSound(self);
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local int i,j;
	local PrimitiveComponent P;
	local string s;
	local float xl,yl;

	Super.DisplayDebug(HUD, out_YL, out_YPos);

	if (HUD.ShouldDisplayDebug('twist'))
	{
		Hud.Canvas.SetDrawColor(255,255,200);
		Hud.Canvas.SetPos(4,out_YPos);
		Hud.Canvas.DrawText(""$Self$" - "@Rotation@" RootYaw:"@RootYaw@" CurrentSkelAim"@CurrentSkelAim.X@CurrentSkelAim.Y);
		out_YPos += out_YL;
	}

	if ( !HUD.ShouldDisplayDebug('component') )
		return;

	Hud.Canvas.SetDrawColor(255,255,128,255);

	for (i=0;i<Mesh.Attachments.Length;i++)
	{
	    HUD.Canvas.SetPos(4,out_YPos);

	    s = ""$Mesh.Attachments[i].Component;
		Hud.Canvas.Strlen(s,xl,yl);
		j = len(s);
		while ( xl > (Hud.Canvas.ClipX*0.5) && j>10)
		{
			j--;
			s = Right(S,j);
			Hud.Canvas.StrLen(s,xl,yl);
		}

		HUD.Canvas.DrawText("Attachment"@i@" = "@Mesh.Attachments[i].BoneName@s);
	    out_YPos += out_YL;

	    P = PrimitiveComponent(Mesh.Attachments[i].Component);
	    if (P!=None)
	    {
			HUD.Canvas.SetPos(24,out_YPos);
			HUD.Canvas.DrawText("Component = "@P.Owner@P.HiddenGame@P.bOnlyOwnerSee@P.bOwnerNoSee);
			out_YPos += out_YL;

			s = ""$P;
			Hud.Canvas.Strlen(s,xl,yl);
			j = len(s);
			while ( xl > (Hud.Canvas.ClipX*0.5) && j>10)
			{
				j--;
				s = Right(S,j);
				Hud.Canvas.StrLen(s,xl,yl);
			}

			HUD.Canvas.SetPos(24,out_YPos);
			HUD.Canvas.DrawText("Component = "@s);
			out_YPos += out_YL;
		}
	}

	out_YPos += out_YL*2;
	HUD.Canvas.SetPos(24,out_YPos);
	HUD.Canvas.DrawText("Driven Vehicle = "@DrivenVehicle);
	out_YPos += out_YL;
}

/** starts playing the given sound via the PawnAmbientSound AudioComponent and sets PawnAmbientSoundCue for replicating to clients
 *  @param NewAmbientSound the new sound to play, or None to stop any ambient that was playing
 */
simulated function SetPawnAmbientSound(SoundCue NewAmbientSound)
{
	// if the component is already playing this sound, don't restart it
	if (NewAmbientSound != PawnAmbientSound.SoundCue)
	{
		PawnAmbientSoundCue = NewAmbientSound;
		PawnAmbientSound.Stop();
		PawnAmbientSound.SoundCue = NewAmbientSound;
		if (NewAmbientSound != None)
		{
			PawnAmbientSound.Play();
		}
	}
}

simulated function SoundCue GetPawnAmbientSound()
{
	return PawnAmbientSoundCue;
}

/** starts playing the given sound via the WeaponAmbientSound AudioComponent and sets WeaponAmbientSoundCue for replicating to clients
 *  @param NewAmbientSound the new sound to play, or None to stop any ambient that was playing
 */
simulated function SetWeaponAmbientSound(SoundCue NewAmbientSound)
{
	// if the component is already playing this sound, don't restart it
	if (NewAmbientSound != WeaponAmbientSound.SoundCue)
	{
		WeaponAmbientSoundCue = NewAmbientSound;
		WeaponAmbientSound.Stop();
		WeaponAmbientSound.SoundCue = NewAmbientSound;
		if (NewAmbientSound != None)
		{
			WeaponAmbientSound.Play();
		}
	}
}

simulated function SoundCue GetWeaponAmbientSound()
{
	return WeaponAmbientSoundCue;
}

simulated function CreateOverlayArmsMesh()
{
	local int i;

	for (i = 0; i < ArrayCount(ArmsMesh); i++)
	{
		if (ArmsMesh[i] != None)
		{
			ArmsOverlay[i] = new(outer) ArmsMesh[i].Class(ArmsMesh[i]);
			if (ArmsOverlay[i] != None)
			{
				ArmsOverlay[i].bTransformFromAnimParent = 0;
				ArmsOverlay[i].CastShadow = false;
				ArmsOverlay[i].SetParentAnimComponent(ArmsMesh[i]);
				ArmsOverlay[i].SetHidden(ArmsMesh[i].HiddenGame);
			}
		}
	}
}
/**
 * Apply a given overlay material to the overlay mesh.
 *
 * @Param	NewOverlay		The material to overlay
 */
simulated function SetOverlayMaterial(MaterialInterface NewOverlay)
{
	local int i;

	// If we are authoratative, then setup replication of the new overlay
	if (Role == ROLE_Authority)
	{
		OverlayMaterialInstance = NewOverlay;
	}

	if (Mesh.SkeletalMesh != None)
	{
		if (NewOverlay != None)
		{
			for (i = 0; i < OverlayMesh.SkeletalMesh.Materials.Length; i++)
			{
				OverlayMesh.SetMaterial(i, OverlayMaterialInstance);
			}

			// attach the overlay mesh
			if (!OverlayMesh.bAttached)
			{
				AttachComponent(OverlayMesh);
			}

			if (ArmsOverlay[0] != None)
			{
				if( ArmsOverlay[0].SkeletalMesh != None )
				{
					for (i = 0; i < ArmsOverlay[0].SkeletalMesh.Materials.length; i++)
					{
						ArmsOverlay[0].SetMaterial(i, OverlayMaterialInstance);
					}
				}

				if( ArmsOverlay[1].SkeletalMesh != None )
				{
					for (i = 0; i < ArmsOverlay[1].SkeletalMesh.Materials.length; i++)
					{
						ArmsOverlay[1].SetMaterial(i, OverlayMaterialInstance);
					}
				}

				if (!ArmsOverlay[0].bAttached)
				{
					AttachComponent(ArmsOverlay[0]);
					if(UTWeapon(Weapon) != none && UTWeapon(Weapon).bUsesOffhand)
					{
						AttachComponent(ArmsOverlay[1]);
					}
				}
				ArmsOverlay[0].SetHidden(ArmsMesh[0].HiddenGame);
			}
		}
		else if (OverlayMesh.bAttached)
		{
			if (ShieldBeltArmor > 0)
			{
				// reapply shield belt overlay
				SetOverlayMaterial(GetShieldMaterialInstance(WorldInfo.Game.bTeamGame));
			}
			else
			{
				DetachComponent(OverlayMesh);
				if (ArmsOverlay[0] != None && ArmsOverlay[0].bAttached)
				{
					DetachComponent(ArmsOverlay[0]);
					DetachComponent(ArmsOverlay[1]);
				}
			}
		}
	}
}

/**
* @Returns the material to use for an overlay
*/
simulated function MaterialInterface GetShieldMaterialInstance(bool bTeamGame)
{
	return (bTeamGame ? default.ShieldBeltTeamMaterialInstances[GetTeamNum()] : default.ShieldBeltMaterialInstance);
}


/**
 * This function allows you to access the overlay material stack.
 *
 * @returns the requested material instance
 */
simulated function MaterialInterface GetOverlayMaterial()
{
	return OverlayMaterialInstance;
}

function SetWeaponOverlayFlag(byte FlagToSet)
{
	ApplyWeaponOverlayFlags(WeaponOverlayFlags | (1 << FlagToSet));
}

function ClearWeaponOverlayFlag(byte FlagToClear)
{
	ApplyWeaponOverlayFlags(WeaponOverlayFlags & ( 0xFF ^ (1 << FlagToClear)) );
}

/**
 * This function is a pass-through to the weapon/weapon attachment that is used to set the various overlays
 */

simulated function ApplyWeaponOverlayFlags(byte NewFlags)
{
	local UTWeapon Weap;
	local UDKVehicleBase VBase;

	if (Role == ROLE_Authority)
	{
		WeaponOverlayFlags = NewFlags;
	}

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		Weap = UTWeapon(Weapon);
		if ( Weap != none)
		{
			Weap.SetWeaponOverlayFlags(self);
		}

		if ( CurrentWeaponAttachment != none )
		{
			CurrentWeaponAttachment.SetWeaponOverlayFlags(self);
		}

		VBase = UDKVehicleBase(DrivenVehicle);
		if (VBase != None)
		{
			VBase.ApplyWeaponEffects(WeaponOverlayFlags);
		}
	}
}


/** called when bPlayingFeignDeathRecovery and interpolating our Mesh's PhysicsWeight to 0 has completed
 *	starts the recovery anim playing
 */
simulated event StartFeignDeathRecoveryAnim()
{
	local UTWeapon UTWeap;

	`log(Self @ GetFuncName() );
	ScriptTrace();

	// we're done with the ragdoll, so get rid of it
	RestorePreRagdollCollisionComponent();
	Mesh.PhysicsWeight = 0.f;
	Mesh.MinDistFactorForKinematicUpdate = default.Mesh.MinDistFactorForKinematicUpdate;
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
	Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, Mesh);
	SetPawnRBChannels(FALSE);
	Mesh.bUpdateKinematicBonesFromAnimation=TRUE;

	// Turn collision on for cylinder and off for skelmeshcomp
	CylinderComponent.SetActorCollision(true, true);
	Mesh.SetActorCollision(false, false);
	Mesh.SetTraceBlocking(false, false);

	Mesh.SetTickGroup(TG_PreAsyncWork);

	if (Physics == PHYS_RigidBody)
	{
		setPhysics(PHYS_Falling);
	}

	UTWeap = UTWeapon(Weapon);
	if (UTWeap != None)
	{
		UTWeap.PlayWeaponEquip();
	}

	if (FeignDeathBlend != None && FeignDeathBlend.Children[1].Anim != None)
	{
		FeignDeathBlend.Children[1].Anim.PlayAnim(false, 1.1);
	}
	else
	{
		// failed to find recovery node, so just pop out of ragdoll
		bNoWeaponFiring = default.bNoWeaponFiring;
		GotoState('Auto');
	}
}

/** prevents player from getting out of feign death until the body has come to rest */
function FeignDeathDelayTimer()
{
	if ( (WorldInfo.TimeSeconds - FeignDeathStartTime > 1.0)
		&& (PhysicsVolume.bWaterVolume || (VSize(Velocity) < 4.0 * FeignDeathBodyAtRestSpeed * (WorldInfo.TimeSeconds - FeignDeathStartTime))) )
	{
		// clear timer, so we can come out of feign death
		ClearTimer('FeignDeathDelayTimer');
		// automatically get up if we were forced into it
		if (bFeigningDeath && bForcedFeignDeath)
		{
			bFeigningDeath = false;
			PlayFeignDeath();
		}
	}
}

simulated function PlayFeignDeath()
{
	local vector FeignLocation, HitLocation, HitNormal, TraceEnd, Impulse;
	local rotator NewRotation;
	local UTWeapon UTWeap;
	local UTVehicle V;
	local Controller Killer;
	local float UnFeignZAdjust;

	if (bFeigningDeath)
	{
		StartFallImpactTime = WorldInfo.TimeSeconds;
		bCanPlayFallingImpacts=true;
		GotoState('FeigningDeath');

		// if we had some other rigid body thing going on, cancel it
		if (Physics == PHYS_RigidBody)
		{
			//@note: Falling instead of None so Velocity/Acceleration don't get cleared
			setPhysics(PHYS_Falling);
		}

		// Ensure we are always updating kinematic
		Mesh.MinDistFactorForKinematicUpdate = 0.0;

		SetPawnRBChannels(TRUE);
		Mesh.ForceSkelUpdate();

		// Move into post so that we are hitting physics from last frame, rather than animated from this
		Mesh.SetTickGroup(TG_PostAsyncWork);

		bBlendOutTakeHitPhysics = false;

		PreRagdollCollisionComponent = CollisionComponent;
		CollisionComponent = Mesh;

		// Turn collision on for skelmeshcomp and off for cylinder
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, true);
		Mesh.SetTraceBlocking(true, true);

		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsWeight = 1.0;

		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		if( Mesh.bNotUpdatingKinematicDueToDistance )
		{
			Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
		}

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		Mesh.bUpdateKinematicBonesFromAnimation=FALSE;

		// Set all kinematic bodies to the current root velocity, since they may not have been updated during normal animation
		// and therefore have zero derived velocity (this happens in 1st person camera mode).
		Mesh.SetRBLinearVelocity(Velocity, false);

		FeignDeathStartTime = WorldInfo.TimeSeconds;
		// reset mesh translation since adjustment code isn't executed on the server
		// but the ragdoll code uses the translation so we need them to match up for the
		// most accurate simulation
		Mesh.SetTranslation(vect(0,0,1) * BaseTranslationOffset);
		// we'll use the rigid body collision to check for falling damage
		Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
		Mesh.SetNotifyRigidBodyCollision(true);
		Mesh.WakeRigidBody();

		if (Role == ROLE_Authority)
		{
			SetTimer(0.15, true, 'FeignDeathDelayTimer');
		}
	}
	else
	{
		// fit cylinder collision into location, crouching if necessary
		FeignLocation = Location;
		CollisionComponent = PreRagdollCollisionComponent;
		TraceEnd = Location + vect(0,0,1) * GetCollisionHeight();
		if (Trace(HitLocation, HitNormal, TraceEnd, Location, true, GetCollisionExtent()) == None )
		{
			HitLocation = TraceEnd;
		}
		if ( !SetFeignEndLocation(HitLocation, FeignLocation) )
		{
			CollisionComponent = Mesh;
			SetLocation(FeignLocation);
			bFeigningDeath = true;
			Impulse = VRand();
			Impulse.Z = 0.5;
			Mesh.AddImpulse(800.0*Impulse, Location);
			UnfeignFailedCount++;
			if ( UnFeignfailedCount > 4 )
			{
				Suicide();
			}
			return;
		}

		// Calculate how far we just moved the actor up.
		UnFeignZAdjust = Location.Z - FeignLocation.Z;
		// If its positive, move back down by that amount until it hits the floor
		if(UnFeignZAdjust > 0.0)
		{
			moveSmooth(vect(0,0,-1) * UnFeignZAdjust);
		}

		UnfeignFailedCount = 0;

		CollisionComponent = Mesh;

		bPlayingFeignDeathRecovery = true;
		FeignDeathRecoveryStartTime = WorldInfo.TimeSeconds;

		// don't need collision events anymore
		Mesh.SetNotifyRigidBodyCollision(false);
		// don't allow player to move while animation is in progress
		SetPhysics(PHYS_None);

		if (Role == ROLE_Authority)
		{
			// if cylinder is penetrating a vehicle, kill the pawn to prevent exploits
			CollisionComponent = PreRagdollCollisionComponent;
			foreach CollidingActors(class'UTVehicle', V, GetCollisionRadius(),, true)
			{
				if (IsOverlapping(V))
				{
					if (V.Class == HoverboardClass)
					{
						// don't want to kill pawn in this case, so push vehicle away instead
						Impulse = VRand() * V.GroundSpeed;
						Impulse.Z = 500.0;
						V.Mesh.AddImpulse(Impulse,,, true);
					}
					else
					{
						CollisionComponent = Mesh;
						if (V.Controller != None)
						{
							Killer = V.Controller;
						}
						else if (V.Instigator != None)
						{
							Killer = V.Instigator.Controller;
						}
						Died(Killer, V.RanOverDamageType, Location);
						return;
					}
				}
			}
			CollisionComponent = Mesh;
		}

		// find getup animation, and freeze it at the first frame
		if ( (FeignDeathBlend != None) && !bIsCrouched )
		{
			// physics weight interpolated to 0 in C++, then StartFeignDeathRecoveryAnim() is called
			Mesh.PhysicsWeight = 1.0;
			FeignDeathBlend.SetBlendTarget(1.0, 0.0);
			// force rotation to match the body's direction so the blend to the getup animation looks more natural
			NewRotation = Rotation;
			NewRotation.Yaw = rotator(Mesh.GetBoneAxis('b_Hips', AXIS_X)).Yaw;
			// flip it around if the head is facing upwards, since the animation for that makes the character
			// end up facing in the opposite direction that its body is pointing on the ground
			// FIXME: generalize this somehow (stick it in the AnimNode, I guess...)
			if (Mesh.GetBoneAxis(HeadBone, AXIS_Y).Z < 0.0)
			{
				NewRotation.Yaw += 32768;
			}
			SetRotation(NewRotation);
		}
		else
		{
			// failed to find recovery node, so just pop out of ragdoll
			RestorePreRagdollCollisionComponent();
			Mesh.PhysicsWeight = 0.f;
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
			Mesh.bUpdateKinematicBonesFromAnimation=TRUE;
			Mesh.MinDistFactorForKinematicUpdate = default.Mesh.MinDistFactorForKinematicUpdate;
			SetPawnRBChannels(FALSE);

			if (Physics == PHYS_RigidBody)
			{
				setPhysics(PHYS_Falling);
			}

			UTWeap = UTWeapon(Weapon);
			if (UTWeap != None)
			{
				UTWeap.PlayWeaponEquip();
			}
			GotoState('Auto');
		}
	}
}

simulated function bool SetFeignEndLocation(vector HitLocation, vector FeignLocation)
{
	local vector NewDest;

	if ( SetLocation(HitLocation) && CheckValidLocation(FeignLocation) )
	{
		return true;
	}

	// try crouching
	ForceCrouch();
	if ( SetLocation(HitLocation) && CheckValidLocation(FeignLocation) )
	{
		return true;
	}

	newdest = HitLocation + GetCollisionRadius() * vect(1,1,0);
	if ( SetLocation(newdest) && CheckValidLocation(FeignLocation) )
		return true;
	newdest = HitLocation + GetCollisionRadius() * vect(1,-1,0);
	if ( SetLocation(newdest) && CheckValidLocation(FeignLocation) )
		return true;
	newdest = HitLocation + GetCollisionRadius() * vect(-1,1,0);
	if ( SetLocation(newdest) && CheckValidLocation(FeignLocation) )
		return true;
	newdest = HitLocation + GetCollisionRadius() * vect(-1,-1,0);
	if ( SetLocation(newdest) && CheckValidLocation(FeignLocation) )
		return true;

	return false;
}

/**
  * Make sure location pawn ended up at out of feign death is valid (not through a wall)
  */
simulated function bool CheckValidLocation(vector FeignLocation)
{
	local vector HitLocation, HitNormal, DestFinalZ;

	// try trace down to dest
	if (Trace(HitLocation, HitNormal, Location, FeignLocation, false, vect(10,10,10),, TRACEFLAG_Bullet) == None)
	{
		return true;
	}

	// try trace straight up, then sideways to final location
	DestFinalZ = FeignLocation;
	FeignLocation.Z = Location.Z;
	if ( Trace(HitLocation, HitNormal, DestFinalZ, FeignLocation, false, vect(10,10,10)) == None &&
		Trace(HitLocation, HitNormal, Location, DestFinalZ, false, vect(10,10,10),, TRACEFLAG_Bullet) == None )
	{
		return true;
	}
	return false;
}


reliable server function ServerFeignDeath()
{
	if (Role == ROLE_Authority && !WorldInfo.Game.IsInState('MatchOver') && DrivenVehicle == None && Controller != None && !bFeigningDeath)
	{
		bFeigningDeath = true;
		PlayFeignDeath();
	}
}

exec simulated function FeignDeath()
{
	ServerFeignDeath();
}

/** force the player to ragdoll, automatically getting up when the body comes to rest
 * (basically, force activate the feign death code)
 */
function ForceRagdoll()
{
	bFeigningDeath = true;
	bForcedFeignDeath = true;
	PlayFeignDeath();
}

simulated function FiringModeUpdated(Weapon InWeapon, byte InFiringMode, bool bViaReplication)
{
	super.FiringModeUpdated(InWeapon, InFiringMode, bViaReplication);
	if(CurrentWeaponAttachment != none)
	{
		CurrentWeaponAttachment.FireModeUpdated(InFiringMode, bViaReplication);
	}
}

/**
  * Called by Bighead mutator when spawned, and also if bKillsAffectHead when kill someone
  */
function SetBigHead()
{
	bKillsAffectHead = true;
	if ( PlayerReplicationInfo != None )
	{
		SetHeadScale(FClamp((5+PlayerReplicationInfo.Kills)/(5+PlayerReplicationInfo.Deaths), 0.75, 2.0));
	}
}

/** called when FireRateMultiplier is changed to update weapon timers */
simulated function FireRateChanged()
{
	if (Weapon != None && Weapon.IsTimerActive('RefireCheckTimer'))
	{
		// make currently firing weapon slow down firing rate
		Weapon.ClearTimer('RefireCheckTimer');
		Weapon.TimeWeaponFiring(Weapon.CurrentFireMode);
	}
	if (DrivenVehicle != None && DrivenVehicle.Weapon != None && DrivenVehicle.Weapon.IsTimerActive('RefireCheckTimer'))
	{
		// make currently firing vehicle weapon slow down firing rate
		DrivenVehicle.Weapon.ClearTimer('RefireCheckTimer');
		DrivenVehicle.Weapon.TimeWeaponFiring(DrivenVehicle.Weapon.CurrentFireMode);
	}
}

/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'Controller' && Controller != None )
	{
		// Reset the weapon when you get the controller and
		// make sure it has ammo.
		if (UTWeapon(Weapon) != None)
		{
			UTWeapon(Weapon).ClientEndFire(0);
			UTWeapon(Weapon).ClientEndFire(1);
			if ( !Weapon.HasAnyAmmo() )
			{
				Weapon.WeaponEmpty();
			}
		}
	}
	// If CurrentWeaponAttachmentClass has changed, the player has switched weapons and
	// will need to update itself accordingly.
	else if ( VarName == 'CurrentWeaponAttachmentClass' )
	{
		WeaponAttachmentChanged();
		return;
	}
	else if ( VarName == 'CompressedBodyMatColor' )
	{
		BodyMatColor.R = CompressedBodyMatColor.Pitch/256.0;
		BodyMatColor.G = CompressedBodyMatColor.Yaw/256.0;
		BodyMatColor.B = CompressedBodyMatColor.Roll/256.0;
	}
	else if ( VarName == 'ClientBodyMatDuration' )
	{
		SetBodyMatColor(BodyMatColor,ClientBodyMatDuration);
	}
	else if ( VarName == 'HeadScale' )
	{
		SetHeadScale(HeadScale);
	}
	else if (VarName == 'PawnAmbientSoundCue')
	{
		SetPawnAmbientSound(PawnAmbientSoundCue);
	}
	else if (VarName == 'WeaponAmbientSoundCue')
	{
		SetWeaponAmbientSound(WeaponAmbientSoundCue);
	}
	else if (VarName == 'ReplicatedBodyMaterial')
	{
		SetSkin(ReplicatedBodyMaterial);
	}
	else if (VarName == 'OverlayMaterialInstance')
	{
		SetOverlayMaterial(OverlayMaterialInstance);
	}
	else if (VarName == 'bFeigningDeath')
	{
		PlayFeignDeath();
	}
	else if (VarName == 'WeaponOverlayFlags')
	{
		ApplyWeaponOverlayFlags(WeaponOverlayFlags);
	}
	else if (VarName == 'LastTakeHitInfo')
	{
		PlayTakeHitEffects();
	}
	else if (VarName == 'DrivenWeaponPawn')
	{
		if (DrivenWeaponPawn.BaseVehicle != LastDrivenWeaponPawn.BaseVehicle || DrivenWeaponPawn.SeatIndex != LastDrivenWeaponPawn.SeatIndex)
		{
			if (DrivenWeaponPawn.BaseVehicle != None)
			{
				// create a client side pawn to drive
				if (ClientSideWeaponPawn == None || ClientSideWeaponPawn.bDeleteMe)
				{
					ClientSideWeaponPawn = Spawn(class'UTClientSideWeaponPawn', DrivenWeaponPawn.BaseVehicle);
				}
				ClientSideWeaponPawn.MyVehicle =UTVehicle(DrivenWeaponPawn.BaseVehicle);
				ClientSideWeaponPawn.MySeatIndex = DrivenWeaponPawn.SeatIndex;
				StartDriving(ClientSideWeaponPawn);
			}
			else if (ClientSideWeaponPawn != None && ClientSideWeaponPawn == DrivenVehicle)
			{
				StopDriving(ClientSideWeaponPawn);
			}
		}
		if (ClientSideWeaponPawn != None && ClientSideWeaponPawn == DrivenVehicle && ClientSideWeaponPawn.PlayerReplicationInfo != DrivenWeaponPawn.PRI)
		{
			ClientSideWeaponPawn.PlayerReplicationInfo = DrivenWeaponPawn.PRI;
			ClientSideWeaponPawn.NotifyTeamChanged();
		}
		LastDrivenWeaponPawn = DrivenWeaponPawn;
	}
	else if (VarName == 'bPuttingDownWeapon')
	{
		SetPuttingDownWeapon(bPuttingDownWeapon);
	}
	else if (VarName == 'EmoteRepInfo')
	{
		DoPlayEmote(EmoteRepInfo.EmoteTag, EmoteRepInfo.EmoteID);
	}
	else if (VarName == 'bIsInvisible')
	{
		SetInvisible(bIsInvisible);
	}
	else if (VarName == 'BigTeleportCount')
	{
		PostBigTeleport();
	}
	else if (VarName == 'FireRateMultiplier')
	{
		FireRateChanged();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function SetHeadScale(float NewScale)
{
	local SkelControlBase SkelControl;

	HeadScale = NewScale;
	SkelControl = Mesh.FindSkelControl('HeadControl');
	if (SkelControl != None)
	{
		SkelControl.BoneScale = NewScale;
		SkelControl.IgnoreAtOrAboveLOD = 1000;
	}

	// we need to scale the neck bone also as otherwise the head piece leaves a point and doesn't show the neck cavity
	SkelControl = Mesh.FindSkelControl('NeckControl');
	if (SkelControl != None)
	{
		// NeckScale should only ever between 0 or 1
		SkelControl.BoneScale = FClamp( NewScale, 0.f, 1.0f );
		SkelControl.IgnoreAtOrAboveLOD = 1000;
	}
}

/** sets the value of bPuttingDownWeapon and plays any appropriate animations for the change */
simulated function SetPuttingDownWeapon(bool bNowPuttingDownWeapon)
{
	if (bPuttingDownWeapon != bNowPuttingDownWeapon || Role < ROLE_Authority)
	{
		bPuttingDownWeapon = bNowPuttingDownWeapon;
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.SetPuttingDownWeapon(bPuttingDownWeapon);
		}
	}
}

/** @return the value of bPuttingDownWeapon */
simulated function bool GetPuttingDownWeapon()
{
	return bPuttingDownWeapon;
}

/**
 * We override TakeDamage and allow the weapon to modify it
 * @See Pawn.TakeDamage
 */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int OldHealth;

	// Attached Bio glob instigator always gets kill credit
	if (AttachedProj != None && !AttachedProj.bDeleteMe && AttachedProj.InstigatorController != None)
	{
		EventInstigator = AttachedProj.InstigatorController;
	}

	// reduce rocket jumping
	if (EventInstigator == Controller)
	{
		momentum *= 0.6;
	}

	// accumulate damage taken in a single tick
	if ( AccumulationTime != WorldInfo.TimeSeconds )
	{
		AccumulateDamage = 0;
		AccumulationTime = WorldInfo.TimeSeconds;
	}
    OldHealth = Health;
	AccumulateDamage += Damage;
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	AccumulateDamage = AccumulateDamage + OldHealth - Health - Damage;

}

/**
 * Called when a pawn's weapon has fired and is responsibile for
 * delegating the creation off all of the different effects.
 *
 * bViaReplication denotes if this call in as the result of the
 * flashcount/flashlocation being replicated.  It's used filter out
 * when to make the effects.
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	if (CurrentWeaponAttachment != None)
	{
		if ( !IsFirstPerson() )
		{
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
		}
		else
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
	                if ( class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location,false,CurrentWeaponAttachment.MaxFireEffectDistance) )
	                {
		                // third person muzzle flash
		                CurrentWeaponAttachment.CauseMuzzleFlash();
	                }
		}

		if ( HitLocation != Vect(0,0,0) && (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || bViaReplication) )
		{
			CurrentWeaponAttachment.PlayImpactEffects(HitLocation);
		}
	}
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	if (CurrentWeaponAttachment != None)
	{
		// always call function for both viewpoints, as during the delay between calling EndFire() on the weapon
		// and it actually stopping, we might have switched viewpoints (e.g. this commonly happens when entering a vehicle)
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
	}
}

/**
 * Called when a weapon is changed and is responsible for making sure
 * the new weapon respects the current pawn's states/etc.
 */

simulated function WeaponChanged(UTWeapon NewWeapon)
{
	local UDKSkeletalMeshComponent UTSkel;

	// Make sure the new weapon respects behindview
	if (NewWeapon.Mesh != None)
	{
		NewWeapon.Mesh.SetHidden(!IsFirstPerson());
		UTSkel = UDKSkeletalMeshComponent(NewWeapon.Mesh);
		if (UTSkel != none)
		{
			ArmsMesh[0].SetFOV(UTSkel.FOV);
			ArmsMesh[1].SetFOV(UTSkel.FOV);
			ArmsMesh[0].SetScale(UTSkel.Scale);
			ArmsMesh[1].SetScale(UTSkel.Scale);
			if (ArmsOverlay[0] != None)
			{
				ArmsOverlay[0].SetScale(UTSkel.Scale);
				ArmsOverlay[1].SetScale(UTSkel.Scale);
				ArmsOverlay[0].SetFOV(UTSkel.FOV);
				ArmsOverlay[1].SetFOV(UTSkel.FOV);
			}
			NewWeapon.PlayWeaponEquip();
		}
	}
}

/**
 * Called when there is a need to change the weapon attachment (either via
 * replication or locally if controlled.
 */
simulated function WeaponAttachmentChanged()
{
	if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
	{
		// Detach/Destroy the current attachment if we have one
		if (CurrentWeaponAttachment!=None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
		}

		// Create the new Attachment.
		if (CurrentWeaponAttachmentClass!=None)
		{
			CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass,self);
			CurrentWeaponAttachment.Instigator = self;
		}
		else
			CurrentWeaponAttachment = none;

		// If all is good, attach it to the Pawn's Mesh.
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.AttachTo(self);
			CurrentWeaponAttachment.SetSkin(ReplicatedBodyMaterial);
			CurrentWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
		}
	}
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	local UTPlayerController Hearer;
	local class<UTDamageType> UTDamage;

	if ( InstigatedBy != None && (class<UTDamageType>(DamageType) != None) && class<UTDamageType>(DamageType).default.bDirectDamage )
	{
		Hearer = UTPlayerController(InstigatedBy);
		if (Hearer != None)
		{
			Hearer.bAcuteHearing = true;
		}
	}

	if (WorldInfo.TimeSeconds - LastPainSound >= MinTimeBetweenPainSounds)
	{
		LastPainSound = WorldInfo.TimeSeconds;

		if (Damage > 0 && Health > 0)
		{

			if ( DamageType == class'UTDmgType_Drowned' )
			{
				SoundGroupClass.static.PlayDrownSound(self);
			}
			else
			{
				SoundGroupClass.static.PlayTakeHitSound(self, Damage);
			}
		}
	}

	if ( Health <= 0 && PhysicsVolume.bDestructive && (WaterVolume(PhysicsVolume) != None) && (WaterVolume(PhysicsVolume).ExitActor != None) )
	{
		Spawn(WaterVolume(PhysicsVolume).ExitActor);
	}

	Super.PlayHit(Damage, InstigatedBy, HitLocation, DamageType, Momentum, HitInfo);

	if (Hearer != None)
	{
		Hearer.bAcuteHearing = false;
	}

	UTDamage = class<UTDamageType>(DamageType);

	if (Damage > 0 || (Controller != None && Controller.bGodMode))
	{
		CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );

		// play serverside effects
		if (bShieldAbsorb)
		{
			SetBodyMatColor(SpawnProtectionColor, 1.0);
			PlaySound(ArmorHitSound);
			bShieldAbsorb = false;
			return;
		}
		else if (UTDamage != None && UTDamage.default.DamageOverlayTime > 0.0 && UTDamage.default.XRayEffectTime <= 0.0)
		{
			SetBodyMatColor(UTDamage.default.DamageBodyMatColor, UTDamage.default.DamageOverlayTime);
		}

		LastTakeHitInfo.Damage = Damage;
		LastTakeHitInfo.HitLocation = HitLocation;
		LastTakeHitInfo.Momentum = Momentum;
		LastTakeHitInfo.DamageType = DamageType;
		LastTakeHitInfo.HitBone = HitInfo.BoneName;
		LastTakeHitTimeout = WorldInfo.TimeSeconds + ( (UTDamage != None) ? UTDamage.static.GetHitEffectDuration(self, Damage)
									: class'UTDamageType'.static.GetHitEffectDuration(self, Damage) );

		// play clientside effects
		PlayTakeHitEffects();
	}
}

/** plays clientside hit effects using the data in LastTakeHitInfo */
simulated function PlayTakeHitEffects()
{
	local class<UTDamageType> UTDamage;
	local vector BloodMomentum;
	local UTEmit_HitEffect HitEffect;
	local ParticleSystem BloodTemplate;

	// set if you want to be able to test in a level and not be tossed around nor have damage effects on screen making it impossible to see what is going on
	if( !AffectedByHitEffects() )
	{
		return;
	}

	if (EffectIsRelevant(Location, false))
	{
		UTDamage = class<UTDamageType>(LastTakeHitInfo.DamageType);
		if (UTDamage != None && UTDamage.default.bCausesBloodSplatterDecals && !IsZero(LastTakeHitInfo.Momentum) && !class'GameInfo'.Static.UseLowGore(WorldInfo))
		{
			LeaveABloodSplatterDecal(LastTakeHitInfo.HitLocation, LastTakeHitInfo.Momentum);
		}

		if (!IsFirstPerson() || class'Engine'.static.IsSplitScreen())
		{
			if ( LastTakeHitInfo.DamageType.default.bCausesBlood && !class'GameInfo'.Static.UseLowGore(WorldInfo) )
			{
				BloodTemplate = class'UTEmitter'.static.GetTemplateForDistance(GetFamilyInfo().default.BloodEffects, LastTakeHitInfo.HitLocation, WorldInfo);
				if (BloodTemplate != None)
				{
					BloodMomentum = Normal(-1.0 * LastTakeHitInfo.Momentum) + (0.5 * VRand());
					HitEffect = Spawn(GetFamilyInfo().default.BloodEmitterClass, self,, LastTakeHitInfo.HitLocation, rotator(BloodMomentum));
					HitEffect.SetTemplate(BloodTemplate, true);
					HitEffect.AttachTo(self, LastTakeHitInfo.HitBone);
				}
			}

			if ( !Mesh.bNotUpdatingKinematicDueToDistance )
			{
				// physics based takehit animations
				if (UTDamage != None)
				{
					//@todo: apply impulse when in full ragdoll too (that also needs to happen on the server)
					if ( !class'Engine'.static.IsSplitScreen() && Health > 0 && DrivenVehicle == None && Physics != PHYS_RigidBody &&
						VSize(LastTakeHitInfo.Momentum) > UTDamage.default.PhysicsTakeHitMomentumThreshold )
					{
						if (Mesh.PhysicsAssetInstance != None)
						{
							// just add an impulse to the asset that's already there
							Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
							// if we were already playing a take hit effect, restart it
							if (bBlendOutTakeHitPhysics)
							{
								Mesh.PhysicsWeight = 0.5;
							}
						}
						else if (Mesh.PhysicsAsset != None)
						{
							Mesh.PhysicsWeight = 0.5;
							Mesh.PhysicsAssetInstance.SetNamedBodiesFixed(true, TakeHitPhysicsFixedBones, Mesh, true);
							Mesh.AddImpulse(LastTakeHitInfo.Momentum, LastTakeHitInfo.HitLocation);
							bBlendOutTakeHitPhysics = true;
						}
					}
					UTDamage.static.SpawnHitEffect(self, LastTakeHitInfo.Damage, LastTakeHitInfo.Momentum, LastTakeHitInfo.HitBone, LastTakeHitInfo.HitLocation);
				}
			}
		}
	}
}

/** called when bBlendOutTakeHitPhysics is true and our Mesh's PhysicsWeight has reached 0.0 */
simulated event TakeHitBlendedOut()
{
	Mesh.PhysicsWeight = 0.0;
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
}

reliable server function ServerHoverboard()
{
	local UTVehicle Board;
	local vector Start, End, HitLoc, HitNorm;
	local actor HitActor;
	local TraceHitInfo HitInfo;
	local bool bInDeepWater;

	// Do a line check to see if we are too deep in water
	Start = Location;
	End = Location - vect(0,0,15);
	HitActor = Trace(HitLoc, HitNorm, End, Start, false, vect(0,0,0), HitInfo, TRACEFLAG_PhysicsVolumes);
	if(HitActor != None && WaterVolume(HitActor) != None)
	{
		bInDeepWater = TRUE;
	}

	if ( bHasHoverboard && !bIsCrouched && (DrivenVehicle == None) && !PhysicsVolume.bWaterVolume && (WorldInfo.TimeSeconds - LastHoverboardTime > MinHoverboardInterval) && (Physics != PHYS_Swimming) &&  !bInDeepWater)
	{
		LastHoverboardTime = WorldInfo.TimeSeconds;
		//Temp turn off collision
		SetCollision(false, false);
		Board = Spawn(HoverboardClass);
		if (Board != None && !Board.bDeleteMe)
		{
			// make sure it didn't get spawned on the other side of a wall
			if (!FastTrace(Board.Location, Location) || !Board.TryToDrive(self))
			{
				Board.Destroy();
				SetCollision(true, true);
			}
		}
		else
		{
			SetCollision(true, true);
		}
	}
}

function OnUseHoverboard(UTSeqAct_UseHoverboard Action)
{
	bHasHoverboard = true;
	ServerHoverboard();
	Action.Hoverboard = UTVehicle(DrivenVehicle);
}

simulated function SwitchWeapon(byte NewGroup)
{
	if (NewGroup == 0 && bHasHoverboard && DrivenVehicle == None)
	{
		if ( WorldInfo.TimeSeconds - LastHoverboardTime > MinHoverboardInterval )
		{
			ServerHoverboard();
			LastHoverboardTime = WorldInfo.TimeSeconds;
		}
		return;
	}

	if (UTInventoryManager(InvManager) != None)
	{
		UTInventoryManager(InvManager).SwitchWeapon(NewGroup);
	}
}

function TakeDrowningDamage()
{
	TakeDamage(5, None, Location + GetCollisionHeight() * vect(0,0,0.5)+ 0.7 * GetCollisionRadius() * vector(Controller.Rotation), vect(0,0,0), class'UTDmgType_Drowned');
}

function bool IsLocationOnHead(const out ImpactInfo Impact, float AdditionalScale)
{
	local vector HeadLocation;
	local float Distance;

	if (HeadBone == '')
	{
		return False;
	}

	Mesh.ForceSkelUpdate();
	HeadLocation = Mesh.GetBoneLocation(HeadBone) + vect(0,0,1) * HeadHeight;

	// Find distance from head location to bullet vector
	Distance = PointDistToLine(HeadLocation, Impact.RayDir, Impact.HitLocation);

	return ( Distance < (HeadRadius * HeadScale * AdditionalScale) );
}

simulated function ModifyRotForDebugFreeCam(out rotator out_CamRot)
{
	local UTPlayerController UPC;

	UPC = UTPlayerController(Controller);
	//`log(GetFuncName()@self@UPC@Controller@UPC.bDebugFreeCam@DrivenVehicle);

	if ( (UPC == None) && (DrivenVehicle != None) )
	{
		UPC = UTPlayerController(DrivenVehicle.Controller);
	}

	if (UPC != None)
	{
		if (UPC.bDebugFreeCam)
		{
	//		`log(GetFuncName()@"setting rot");
			out_CamRot = UPC.DebugFreeCamRot;
		}
	}
}

simulated function bool IsFirstPerson()
{
	local PlayerController PC;

	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget == self) && PC.UsingFirstPersonCamera() )
			return true;
	}
	return false;
}

/** moves the camera in or out one */
simulated function AdjustCameraScale(bool bMoveCameraIn)
{
	if ( !IsFirstPerson() )
	{
		CameraScale = FClamp(CameraScale + (bMoveCameraIn ? -1.0 : 1.0), CameraScaleMin, CameraScaleMax);
	}
}

simulated event rotator GetViewRotation()
{
	local rotator Result;

	//@FIXME: eventually bot Rotation.Pitch will be nonzero?
	if (UTBot(Controller) != None)
	{
		Result = Controller.Rotation;
		Result.Pitch = rotator(Controller.GetFocalPoint() - Location).Pitch;
		return Result;
	}
	else
	{
		return Super.GetViewRotation();
	}
}

simulated event TornOff()
{
	local class<UTDamageType> UTDamage;

   	Super.TornOff();

	SetPawnAmbientSound(None);
	SetWeaponAmbientSound(None);

	UTDamage = class<UTDamageType>(HitDamageType);

	if ( UTDamage != None)
	{
		if ( UTDamage.default.DamageOverlayTime > 0 )
		{
			SetBodyMatColor(UTDamage.default.DamageBodyMatColor, UTDamage.default.DamageOverlayTime);
		}
		UTDamage.Static.PawnTornOff(self);
	}
}

simulated function SetOverlayVisibility(bool bVisible)
{
	OverlayMesh.SetOwnerNoSee(!bVisible);
}

simulated function TakeFallingDamage()
{
	local UTPlayerController UTPC;

	Super.TakeFallingDamage();

	if (Velocity.Z < -0.5 * MaxFallSpeed)
	{
		UTPC = UTPlayerController(Controller);
		if(UTPC != None && LocalPlayer(UTPC.Player) != None)
		{
			UTPC.ClientPlayForceFeedbackWaveform(FallingDamageWaveForm);
		}
	}
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	// only check fall damage for Z axis collisions
	if (Abs(RigidCollisionData.ContactInfos[0].ContactNormal.Z) > 0.5)
	{
		Velocity = Mesh.GetRootBodyInstance().PreviousVelocity;
		TakeFallingDamage();
		// zero out the z velocity on the body now so that we don't get stacked collisions
		Velocity.Z = 0.0;
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.GetRootBodyInstance().PreviousVelocity = Velocity;
		Mesh.GetRootBodyInstance().Velocity = Velocity;
	}
}

/** Called when an SVehicle wheel physically contacts this Pawn. We kill it! */
event OnRanOver(SVehicle Vehicle, PrimitiveComponent RunOverComponent, int WheelIndex)
{
	local UTVehicle UTV;

	if(Role == ROLE_Authority)
	{
		UTV = UTVehicle(Vehicle);
		if(UTV != None)
		{
			TakeDamage( 10000, UTV.Controller, Location, vect(0,0,0), UTV.RanOverDamageType, , Vehicle);
		}
	}
}

/** called when we have been stuck falling for a long time with zero velocity
 * and couldn't find a place to move to get out of it
 */
event StuckFalling()
{
	if (AIController(Controller) != None)
	{
		Suicide();
	}
	else
	{
		StartedFallingTime = WorldInfo.TimeSeconds;
	}
}

/** Kismet hook for kicking a Pawn out of a vehicle */
function OnExitVehicle(UTSeqAct_ExitVehicle Action)
{
	if (DrivenVehicle != None)
	{
		DrivenVehicle.DriverLeave(true);
	}
}

/** Kismet hook for enabling/disabling infinite ammo for this Pawn */
function OnInfiniteAmmo(UTSeqAct_InfiniteAmmo Action)
{
	local UTInventoryManager UTInvManager;

	UTInvManager = UTInventoryManager(InvManager);
	if (UTInvManager != None)
	{
		UTInvManager.bInfiniteAmmo = Action.bInfiniteAmmo;
	}
}

/**
 * Toss active weapon using default settings (location+velocity).
 */
function ThrowActiveWeapon()
{
	if (Weapon != None)
	{
		TossInventory(Weapon);
	}
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);
	NotifyTeamChanged();
}

function bool NeedToTurn(vector targ)
{
	local vector LookDir, AimDir;
	local UTBot B;
	local float RequiredAim;

	LookDir = Vector(Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);

	RequiredAim = 0.93;
	B = UTBot(Controller);
	if (B != None)
	{
		RequiredAim += 0.0085 * FClamp(B.Skill, 0.0, 7.0);
	}
	return ((LookDir Dot AimDir) < RequiredAim);
}

state FeigningDeath
{
	ignores ServerHoverboard, SwitchWeapon, FaceRotation, ForceRagdoll, AdjustCameraScale, SetMovementPhysics;

	exec simulated function FeignDeath()
	{
		if (bFeigningDeath)
		{
			Global.FeignDeath();
		}
	}

	reliable server function ServerFeignDeath()
	{
		if (Role == ROLE_Authority && !WorldInfo.GRI.bMatchIsOver && !IsTimerActive('FeignDeathDelayTimer') && bFeigningDeath)
		{
			bFeigningDeath = false;
			PlayFeignDeath();
		}
	}

	event bool EncroachingOn(Actor Other)
	{
		if ( ForcedDirVolume(Other) != None )
		{
			if ( ForcedDirVolume(Other).bBlockPawns && Other.ContainsPoint(Location) )
			{
				TakeDamage(10000, Controller, Location, vect(0,0,0), class'DmgType_Crushed');
			}
		}
		// don't abort moves in ragdoll
		return false;
	}

	simulated function bool CanThrowWeapon()
	{
		return false;
	}

	simulated function Tick(float DeltaTime)
	{
		local rotator NewRotation;

		if (bPlayingFeignDeathRecovery && PlayerController(Controller) != None)
		{
			// interpolate Controller yaw to our yaw so that we don't get our rotation snapped around when we get out of feign death
			NewRotation = Controller.Rotation;
			NewRotation.Yaw = RInterpTo(NewRotation, Rotation, DeltaTime, 2.0).Yaw;
			Controller.SetRotation(NewRotation);

			if ( WorldInfo.TimeSeconds - FeignDeathRecoveryStartTime > 0.8 )
			{
				CameraScale = 1.0;
			}
		}
	}

	simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
	{
		local vector CamStart, HitLocation, HitNormal, CamDir;
		local RB_BodyInstance RootBodyInst;
		local matrix RootBodyTM;

		if (CurrentCameraScale < CameraScale)
		{
			CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
		}
		else if (CurrentCameraScale > CameraScale)
		{
			CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
		}

		CamStart = Mesh.GetPosition();
		if(Mesh.PhysicsAssetInstance != None)
		{
			RootBodyInst = Mesh.PhysicsAssetInstance.Bodies[Mesh.PhysicsAssetInstance.RootBodyIndex];
			if(RootBodyInst.IsValidBodyInstance())
			{
				RootBodyTM = RootBodyInst.GetUnrealWorldTM();
				CamStart.X = RootBodyTM.WPlane.X;
				CamStart.Y = RootBodyTM.WPlane.Y;
				CamStart.Z = RootBodyTM.WPlane.Z;
			}
		}
		CamStart += vect(0,0,1) * BaseEyeHeight;

		CamDir = vector(out_CamRot) * GetCollisionRadius() * CurrentCameraScale;
//		`log("Mesh"@Mesh.Bounds.Origin@" --- Base Eye Height "@BaseEyeHeight);

		if (CamDir.Z > GetCollisionHeight())
		{
			CamDir *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
		}
		out_CamLoc = CamStart - CamDir;
		if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
		{
			out_CamLoc = HitLocation;
		}
		return true;
	}

	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		if (Physics != PHYS_RigidBody && !bPlayingFeignDeathRecovery)
		{
			// blend out of feign death animation
			if (FeignDeathBlend != None)
			{
				FeignDeathBlend.SetBlendTarget(0.0, 0.5);
			}
			GotoState('Auto');
		}
	}

	simulated event BeginState(name PreviousStateName)
	{
		local UTPlayerController PC;
		local UTWeapon UTWeap;

		PC = UTPlayerController(Controller);

		bCanPickupInventory = false;
		StopFiring();
		bNoWeaponFiring = true;

		UTWeap = UTWeapon(Weapon);
		if (UTWeap != None)
		{
			UTWeap.PlayWeaponPutDown();
		}
		if(UTWeap != none && PC != none)
		{
			PC.EndZoom();
		}

		if (PC != None)
		{
			PC.SetBehindView(true);
			CurrentCameraScale = 1.5;
			CameraScale = 2.25;
		}

		DropFlag();
	}

	simulated function EndState(name NextStateName)
	{
		local UTPlayerController PC;
		local UTPawn P;
		local Actor A;

		if (NextStateName != 'Dying')
		{
			bNoWeaponFiring = default.bNoWeaponFiring;
			bCanPickupInventory = default.bCanPickupInventory;

			ForEach TouchingActors(class'Actor', A)
			{
				if ( (DroppedPickup(A) != None)
					|| (PickupFactory(A) != None)
					|| (UTCarriedObject(A) != None) )
				{
					A.Touch(self, CylinderComponent, A.Location, Normal(Location - A.Location));
				}
			}
			Global.SetMovementPhysics();
			PC = UTPlayerController(Controller);
			if (PC != None)
			{
				PC.SetBehindView(PC.default.bBehindView);
			}

			CurrentCameraScale = default.CurrentCameraScale;
			CameraScale = default.CameraScale;
			bForcedFeignDeath = false;
			bPlayingFeignDeathRecovery = false;

			// jump away from other feigning death pawns to make sure we don't get stuck
			foreach TouchingActors(class'UTPawn', P)
			{
				if (P.IsInState('FeigningDeath'))
				{
					JumpOffPawn();
				}
			}
		}
	}
}

simulated State Dying
{
ignores OnAnimEnd, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, StartFeignDeathRecoveryAnim, ForceRagdoll, FellOutOfWorld;

	exec simulated function FeignDeath();
	reliable server function ServerFeignDeath();

	event bool EncroachingOn(Actor Other)
	{
		// don't abort moves in ragdoll
		return false;
	}

	event Timer()
	{
		local PlayerController PC;
		local bool bBehindAllPlayers;
		local vector ViewLocation;
		local rotator ViewRotation;

		// let the dead bodies stay if the game is over
		if (WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver)
		{
			LifeSpan = 0.0;
			return;
		}

		if ( !PlayerCanSeeMe() )
		{
			Destroy();
			return;
		}
		// go away if not viewtarget
		//@todo FIXMESTEVE - use drop detail, get rid of backup visibility check
		bBehindAllPlayers = true;
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( (PC.ViewTarget == self) || (PC.ViewTarget == Base) )
			{
				if ( LifeSpan < 3.5 )
					LifeSpan = 3.5;
				SetTimer(2.0, false);
				return;
			}

			PC.GetPlayerViewPoint( ViewLocation, ViewRotation );
			if ( ((Location - ViewLocation) dot vector(ViewRotation) > 0) )
			{
				bBehindAllPlayers = false;
				break;
			}
		}
		if ( bBehindAllPlayers )
		{
			Destroy();
			return;
		}
		SetTimer(2.0, false);
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
	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
	{
		local vector LookAt;
		local class<UTDamageType> UTDamage;

		UTDamage = class<UTDamageType>(HitDamageType);
		if (UTDamage == None || !UTDamage.default.bSpecialDeathCamera)
		{

 			CalcThirdPersonCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
			bStopDeathCamera = bStopDeathCamera || (out_CamLoc.Z < WorldInfo.KillZ);
			if ( bStopDeathCamera && (OldCameraPosition != vect(0,0,0)) )
			{
					// Don't allow camera to go below killz, by re-using old camera position once dead pawn falls below killz
				out_CamLoc = OldCameraPosition;
				LookAt = Location;
					CameraZOffset = (fDeltaTime < 0.2) ? (1 - 5*fDeltaTime) * CameraZOffset : 0.0;
					LookAt.Z += CameraZOffset;
				out_CamRot = rotator(LookAt - out_CamLoc);
			}
			OldCameraPosition = out_CamLoc;
			return true;
		}
		else
		{
			UTDamage.static.CalcDeathCamera(self, fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
			return true;
		}
	}

	simulated event Landed(vector HitNormal, Actor FloorActor)
	{
		local vector BounceDir;

		if( Velocity.Z < -500 )
		{
			BounceDir = 0.5 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
			TakeDamage( (1-Velocity.Z/30), Controller, Location, BounceDir, class'DmgType_Crushed');
		}
	}

	simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		local Vector shotDir, ApplyImpulse,BloodMomentum;
		local class<UTDamageType> UTDamage;
		local UTEmit_HitEffect HitEffect;

		if ( class'GameInfo'.Static.UseLowGore(WorldInfo) )
		{
			if ( !bGibbed )
			{
				UTDamage = class<UTDamageType>(DamageType);
				if (UTDamage != None && ShouldGib(UTDamage))
				{
					bTearOffGibs = true;
					bGibbed = true;
				}
			}
			return;
		}

		// When playing death anim, we keep track of how long since we took that kind of damage.
		if(DeathAnimDamageType != None)
		{
			if(DamageType == DeathAnimDamageType)
			{
				TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
			}
		}

		if (!bGibbed && (InstigatedBy != None || EffectIsRelevant(Location, true, 0)))
		{
			UTDamage = class<UTDamageType>(DamageType);

			// accumulate damage taken in a single tick
			if ( AccumulationTime != WorldInfo.TimeSeconds )
			{
				AccumulateDamage = 0;
				AccumulationTime = WorldInfo.TimeSeconds;
			}
			AccumulateDamage += Damage;

			Health -= Damage;
			if (UTDamage != None && ShouldGib(UTDamage))
			{
				if ( bHideOnListenServer || (WorldInfo.NetMode == NM_DedicatedServer) )
				{
					bTearOffGibs = true;
					bGibbed = true;
					return;
				}
				SpawnGibs(UTDamage, HitLocation);
			}
			else if ( !bHideOnListenServer && (WorldInfo.NetMode != NM_DedicatedServer) )
			{
				CheckHitInfo( HitInfo, Mesh, Normal(Momentum), HitLocation );
				if ( UTDamage != None )
				{
					UTDamage.Static.SpawnHitEffect(self, Damage, Momentum, HitInfo.BoneName, HitLocation);
				}
				if ( DamageType.default.bCausesBlood && !class'GameInfo'.Static.UseLowGore(WorldInfo)
					&& ((PlayerController(Controller) == None) || (WorldInfo.NetMode != NM_Standalone)) )
				{
					BloodMomentum = Momentum;
					if ( BloodMomentum.Z > 0 )
						BloodMomentum.Z *= 0.5;
					HitEffect = Spawn(GetFamilyInfo().default.BloodEmitterClass,self,, HitLocation, rotator(BloodMomentum));
					HitEffect.AttachTo(Self,HitInfo.BoneName);
				}

				if ( (UTDamage != None) && (UTDamage.default.DamageOverlayTime > 0) && (UTDamage.default.DamageBodyMatColor != class'UTDamageType'.default.DamageBodyMatColor) )
				{
					SetBodyMatColor(UTDamage.default.DamageBodyMatColor, UTDamage.default.DamageOverlayTime);
				}

				if( (Physics != PHYS_RigidBody) || (Momentum == vect(0,0,0)) || (HitInfo.BoneName == '') )
					return;

				shotDir = Normal(Momentum);
				ApplyImpulse = (DamageType.Default.KDamageImpulse * shotDir);

				if( (UTDamage != None) && UTDamage.Default.bThrowRagdoll && (Velocity.Z > -10) )
				{
					ApplyImpulse += Vect(0,0,1)*DamageType.default.KDeathUpKick;
				}
				// AddImpulse() will only wake up the body for the bone we hit, so force the others to wake up
				Mesh.WakeRigidBody();
				Mesh.AddImpulse(ApplyImpulse, HitLocation, HitInfo.BoneName, true);
			}
		}
	}

	/** Tick only if bio death effect */
	simulated event Tick(FLOAT DeltaSeconds)
	{
		local float BurnLevel;
		local int i;
		local MaterialInstanceConstant MyMIC;

		// tick only if bio death effect
		if ( !bKilledByBio || (Mesh == None) )
		{
			Disable('Tick');
		}
		else
		{
			// first, how far into the burn are we: (scale of 0-9.9)
			BurnLevel = FMin(((WorldInfo.TimeSeconds-DeathTime)/BioBurnAwayTime*10.0),9.9);
			for ( i=0; i<Mesh.Materials.Length; i++ )
			{
				MyMIC = MaterialInstanceConstant(Mesh.Materials[i]);
				if (MyMIC != None)
				{
					MyMIC.SetScalarParameterValue(BioEffectName, BurnLevel);
				}
			}
			if (BurnLevel >= 9.9)
			{
				BioBurnAway.DeactivateSystem();
				bKilledByBio = FALSE; // no need to loop this in anymore.
				Disable('Tick');
			}
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		CustomGravityScaling = 1.0;
		DeathTime = WorldInfo.TimeSeconds;
		CylinderComponent.SetActorCollision(false, false);

		if ( bTearOff && (bHideOnListenServer || (WorldInfo.NetMode == NM_DedicatedServer)) )
			LifeSpan = 1.0;
		else
		{
			if ( Mesh != None )
			{
				Mesh.SetTraceBlocking(true, true);
				Mesh.SetActorCollision(true, false);

				// Move into post so that we are hitting physics from last frame, rather than animated from this
				Mesh.SetTickGroup(TG_PostAsyncWork);
			}
			SetTimer(2.0, false);
			LifeSpan = RagDollLifeSpan;
		}
	}
}

/** This will determine and then return the FamilyInfo for this pawn **/
simulated function class<UTFamilyInfo> GetFamilyInfo()
{
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = GetUTPlayerReplicationInfo();
	if (UTPRI != None)
	{
		return UTPRI.CharClassInfo;
	}

	return CurrCharClassInfo;
}

simulated function PostTeleport(Teleporter OutTeleporter)
{
	Super.PostTeleport(OutTeleporter);

	BigTeleportCount++;
	PostBigTeleport();
}

/** Called when teleporting */
simulated function PostBigTeleport()
{
	ForceUpdateComponents();
	Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
}

exec function BackSpring(float LinSpring)
{
	local RB_BodyInstance BodyInst;
	local RB_BodySetup BodySetup;
	local int i;

	for(i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
	{
		BodyInst = Mesh.PhysicsAssetInstance.Bodies[i];
		BodySetup = Mesh.PhysicsAsset.BodySetup[i];

		if (BodySetup.BoneName == 'b_Spine2')
		{
			BodyInst.SetBoneSpringParams(LinSpring, BodyInst.BoneLinearDamping, 0.1*LinSpring, BodyInst.BoneAngularDamping);
		}
	}

	//`log("Hip Spring set to "$LinSpring);
}

exec function BackDamp(float LinDamp)
{
	local RB_BodyInstance BodyInst;
	local RB_BodySetup BodySetup;
	local int i;

	for(i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
	{
		BodyInst = Mesh.PhysicsAssetInstance.Bodies[i];
		BodySetup = Mesh.PhysicsAsset.BodySetup[i];

		if (BodySetup.BoneName == 'b_Spine2')
		{
			BodyInst.SetBoneSpringParams(BodyInst.BoneLinearSpring, LinDamp, BodyInst.BoneAngularDamping, LinDamp);
		}
	}

	//`log("Hip Damp set to "$LinDamp);
}

exec function HandSpring(float LinSpring)
{
	local RB_BodyInstance BodyInst;
	local RB_BodySetup BodySetup;
	local int i;

	for(i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
	{
		BodyInst = Mesh.PhysicsAssetInstance.Bodies[i];
		BodySetup = Mesh.PhysicsAsset.BodySetup[i];

		if (BodySetup.BoneName == 'b_RightHand' || BodySetup.BoneName == 'b_LeftHand')
		{
			BodyInst.SetBoneSpringParams(LinSpring, BodyInst.BoneLinearDamping, 0.1*LinSpring, BodyInst.BoneAngularDamping);
		}
	}

	//`log("Hip Spring set to "$LinSpring);
}

exec function HandDamp(float LinDamp)
{
	local RB_BodyInstance BodyInst;
	local RB_BodySetup BodySetup;
	local int i;

	for(i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
	{
		BodyInst = Mesh.PhysicsAssetInstance.Bodies[i];
		BodySetup = Mesh.PhysicsAsset.BodySetup[i];

		if (BodySetup.BoneName == 'b_RightHand' || BodySetup.BoneName == 'b_LeftHand')
		{
			BodyInst.SetBoneSpringParams(BodyInst.BoneLinearSpring, LinDamp, BodyInst.BoneAngularDamping, LinDamp);
		}
	}

	//`log("Hip Damp set to "$LinDamp);
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=1.075
		MotionBlurScale=0.0
		bAllowAmbientOcclusion=false
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	DefaultMeshScale=1.075
	BaseTranslationOffset=6.0

	Begin Object Name=OverlayMeshComponent0 Class=SkeletalMeshComponent
		Scale=1.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bAllowAmbientOcclusion=false
	End Object
	OverlayMesh=OverlayMeshComponent0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object class=AnimNodeSequence Name=MeshSequenceB
	End Object

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms
		PhysicsAsset=None
		FOV=55
		Animations=MeshSequenceA
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_DuringASyncWork
		bAllowAmbientOcclusion=false
	End Object
	ArmsMesh[0]=FirstPersonArms

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms2
		PhysicsAsset=None
		FOV=55
		Scale3D=(Y=-1.0)
		Animations=MeshSequenceB
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		HiddenGame=true
		bAcceptsDynamicDecals=FALSE
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_DuringASyncWork
		bAllowAmbientOcclusion=false
	End Object
	ArmsMesh[1]=FirstPersonArms2

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=UTAmbientSoundComponent name=AmbientSoundComponent
	End Object
	PawnAmbientSound=AmbientSoundComponent
	Components.Add(AmbientSoundComponent)

	Begin Object Class=UTAmbientSoundComponent name=AmbientSoundComponent2
	End Object
	WeaponAmbientSound=AmbientSoundComponent2
	Components.Add(AmbientSoundComponent2)

	ViewPitchMin=-18000
	ViewPitchMax=18000

	WalkingPct=+0.4
	CrouchedPct=+0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=440.0
	AirSpeed=440.0
	WaterSpeed=220.0
	DodgeSpeed=600.0
	DodgeSpeedZ=295.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78

	AlwaysRelevantDistanceSquared=+1960000.0
	InventoryManagerClass=class'UTInventoryManager'

	MeleeRange=+20.0
	bMuffledHearing=true

	Buoyancy=+000.99000000
	UnderWaterTime=+00020.000000
	bCanStrafe=True
	bCanSwim=true
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxLeanRoll=2048
	AirControl=+0.35
	DefaultAirControl=+0.35
	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=True
	bCanDoubleJump=true
	SightRadius=+12000.0

	MaxMultiJump=1
	MultiJumpRemaining=1
	MultiJumpBoost=-45.0

	SoundGroupClass=class'UTGame.UTPawnSoundGroup'

	TransInEffects(0)=class'UTEmit_TransLocateOutRed'
	TransInEffects(1)=class'UTEmit_TransLocateOut'

	MaxStepHeight=26.0
	MaxJumpHeight=49.0
	MaxDoubleJumpHeight=87.0
	DoubleJumpEyeHeight=43.0

	HeadRadius=+9.0
	HeadHeight=5.0
	HeadScale=+1.0
	HeadOffset=32

	SpawnProtectionColor=(R=40,G=40)
	TranslocateColor[0]=(R=20)
	TranslocateColor[1]=(B=20)
	DamageParameterName=DamageOverlay
	SaturationParameterName=Char_DistSatRangeMultiplier

	TeamBeaconMaxDist=3000.f
	TeamBeaconPlayerInfoMaxDist=3000.f
	RagdollLifespan=18.0

	bPhysRigidBodyOutOfWorldCheck=TRUE
	bRunPhysicsWithNoController=true

	ControllerClass=class'UTGame.UTBot'

	CurrentCameraScale=1.0
	CameraScale=9.0
	CameraScaleMin=3.0
	CameraScaleMax=40.0

	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=true
	MaxFootPlacementDistSquared=56250000.0 // 7500 squared

	SlopeBoostFriction=0.2
	bStopOnDoubleLanding=true
	DoubleJumpThreshold=160.0
	FireRateMultiplier=1.0

	ArmorHitSound=SoundCue'A_Gameplay.Gameplay.A_Gameplay_ArmorHitCue'
	SpawnSound=SoundCue'A_Gameplay.A_Gameplay_PlayerSpawn01Cue'
	TeleportSound=SoundCue'A_Weapon_Translocator.Translocator.A_Weapon_Translocator_Teleport_Cue'

	MaxFallSpeed=+1250.0
	AIMaxFallSpeedFactor=1.1 // so bots will accept a little falling damage for shorter routes
	LastPainSound=-1000.0

	FeignDeathBodyAtRestSpeed=12.0
	bReplicateRigidBodyLocation=true

	MinHoverboardInterval=0.7
	HoverboardClass=class'UTVehicle_Hoverboard'

	FeignDeathPhysicsBlendOutSpeed=2.0
	TakeHitPhysicsBlendOutSpeed=0.5

	TorsoBoneName=b_Spine2
	FallImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_BodyFall_Cue'
	FallSpeedThreshold=125.0

	SuperHealthMax=199

	// moving here for now until we can fix up the code to have it pass in the armor object
	ShieldBeltMaterialInstance=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Overlay'
	ShieldBeltTeamMaterialInstances(0)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
	ShieldBeltTeamMaterialInstances(1)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'
	ShieldBeltTeamMaterialInstances(2)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
	ShieldBeltTeamMaterialInstances(3)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'

	HeroCameraPitch=6000
	HeroCameraScale=6.0

	//@TEXTURECHANGEFIXME - Needs actual UV's for the Player Icon
	IconCoords=(U=657,V=129,UL=68,VL=58)
	MapSize=1.0

	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	HeadBone=b_Head
	PawnEffectSockets[0]=L_JB
	PawnEffectSockets[1]=R_JB


	MinTimeBetweenEmotes=1.0

	DeathHipLinSpring=10000.0
	DeathHipLinDamp=500.0
	DeathHipAngSpring=10000.0
	DeathHipAngDamp=500.0

	bWeaponAttachmentVisible=true

	TransCameraAnim[0]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN_Red'
	TransCameraAnim[1]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN_Blue'
	TransCameraAnim[2]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN'

	MaxFootstepDistSq=9000000.0
	MaxJumpSoundDistSq=16000000.0

	SwimmingZOffset=-30.0
	SwimmingZOffsetSpeed=45.0

	TauntNames(0)=TauntA
	TauntNames(1)=TauntB
	TauntNames(2)=TauntC
	TauntNames(3)=TauntD
	TauntNames(4)=TauntE
	TauntNames(5)=TauntF

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformFall
		Samples(0)=(LeftAmplitude=50,RightAmplitude=40,LeftFunction=WF_Sin90to180,RightFunction=WF_Sin90to180,Duration=0.200)
	End Object
	FallingDamageWaveForm=ForceFeedbackWaveformFall

	CamOffset=(X=4.0,Y=16.0,Z=-13.0)
}

