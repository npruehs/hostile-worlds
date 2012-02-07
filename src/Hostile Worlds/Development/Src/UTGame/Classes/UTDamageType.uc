/**
 * UTDamageType
 *
 * NOTE:  we can not do:  HideDropDown on this class as we need to be able to use it in SeqEvent_TakeDamage for objects taking
 * damage from any UTDamageType!
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTDamageType extends DamageType
	abstract;

var	LinearColor		DamageBodyMatColor;
var float           DamageOverlayTime;
var float           DeathOverlayTime;
var float			XRayEffectTime;

var		bool			bDirectDamage;
var		bool            bSeversHead;
var		bool			bCauseConvulsions;
var		bool			bUseTearOffMomentum;	// For ragdoll death. Add entirety of killing hit's momentum to ragdoll's initial velocity.
var		bool			bThrowRagdoll;
var		bool			bLeaveBodyEffect;
var		bool            bBulletHit;
var		bool			bVehicleHit;		// caused by vehicle running over you
var		bool			bSelfDestructDamage;

var		float           GibPerterbation;				// When gibbing, the chunks will fly off in random directions.
var		int				GibThreshold;					// Health threshold at which this damagetype gibs
var		int				MinAccumulateDamageThreshold;	// Minimum damage in one tick to cause gibbing when health is below gib threshold
var		int				AlwaysGibDamageThreshold;		// Minimum damage in one tick to always cause gibbing
/** magnitude of momentum that must be caused by this damagetype for physics based takehit animations to be used on the target */
var float PhysicsTakeHitMomentumThreshold;

/** Information About the weapon that caused this if available */

var 	class<UTWeapon>			DamageWeaponClass;
var		int						DamageWeaponFireMode;

 /** This will delegate to the death effects to the damage type.  This allows us to have specific
 *  damage effects without polluting the Pawn / Weapon class with checking for the damage type
 *
 **/
var() bool                  bUseDamageBasedDeathEffects;
/** if set, UTPawn::Dying::CalcCamera() calls this DamageType's CalcDeathCamera() function to handle the camera */
var bool bSpecialDeathCamera;

/** Particle system trail to attach to gibs caused by this damage type 
    GibTrail would normally be blood, but we only have robots now. */
var ParticleSystem GibTrail;

/** This is the Camera Effect you get when you die from this Damage Type **/
var protected class<UDKEmitCameraEffect> DeathCameraEffectVictim;
/** This is the Camera Effect you get when you cause from this Damage Type **/
var protected class<UDKEmitCameraEffect> DeathCameraEffectInstigator;

/************** DEATH ANIM *********/

/** Name of animation to play upon death. */
var(DeathAnim)	name	DeathAnim;
/** How fast to play the death animation */
var(DeathAnim)	float	DeathAnimRate;
/** If true, char is stopped and root bone is animated using a bone spring for this type of death. */
var(DeathAnim)	bool	bAnimateHipsForDeathAnim;
/** If non-zero, motor strength is ramped down over this time (in seconds) */
var(DeathAnim)	float	MotorDecayTime;
/** If non-zero, stop death anim after this time (in seconds) after stopping taking damage of this type. */
var(DeathAnim)	float	StopAnimAfterDamageInterval;

/***********************************/


/** camera anim played instead of the default damage shake when taking this type of damage */
var CameraAnim DamageCameraAnim;

/** Damage scaling when hit warfare node/core */
var float NodeDamageScaling;

/** Name used for stats for kills with this damage type */
var name KillStatsName;

/** Name used for stats for deaths with this damage type */
var name DeathStatsName;

/** Name used for stats for suicides with this damage type */
var name SuicideStatsName;

/** If > 0, how many kills of this type get you a reward announcement */
var int RewardCount;

var class<UTLocalMessage> RewardAnnouncementClass;

/** Announcement switch for reward announcement. */
var int RewardAnnouncementSwitch;

/** Stats event associated with reward */
var name RewardEvent;

/** Custom taunt index for this damage type */
var int CustomTauntIndex;

/** Whether teammates should complain about friendly fire with this damage type */
var bool bComplainFriendlyFire;

/** if set, when taking this damage HUD hit effect is our HitEffectColor instead of the default */
var bool bOverrideHitEffectColor;
var LinearColor HitEffectColor;

/** whether getting gibbed with this damage type attaches the camera to the head gib */
var bool bHeadGibCamera;

/** Whether or not this damage type can cause a blood splatter **/
var bool bCausesBloodSplatterDecals;
/** if true, this damage type should never harm its instigator */
var bool bDontHurtInstigator;

var() localized string     	DeathString;	 			// string to describe death by this type of damage
var() localized string		FemaleSuicide, MaleSuicide;	// Strings to display when someone dies

/** 
  * @RETURN string for death caused by this damagetype.
  */
static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	return Default.DeathString;
}

/** 
  * @RETURN string for suicide caused by this damagetype.
  */
static function string SuicideMessage(PlayerReplicationInfo Victim)
{
	if ( (UTPlayerReplicationInfo(Victim) != None) && UTPlayerReplicationInfo(Victim).bIsFemale )
		return Default.FemaleSuicide;
	else
		return Default.MaleSuicide;
}

/**
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation);

/** @return duration of hit effect, primarily used for replication timeout to avoid replicating out of date hits to clients when pawns become relevant */
static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return 0.5;
}

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	local int KillCount;

	KillCount = KillerPRI.IncrementKillStat(static.GetStatsName('KILLS'));
	if ( (KillCount == Default.RewardCount)  && (UTPlayerController(KillerPRI.Owner) != None) )
	{
		UTPlayerController(KillerPRI.Owner).ReceiveLocalizedMessage( Default.RewardAnnouncementClass, Default.RewardAnnouncementSwitch );
		if ( default.RewardEvent == '' )
		{
			`warn("No reward event for "$default.class);
		}
		else
		{
			KillerPRI.IncrementEventStat(default.RewardEvent);
		}
	}
	return KillCount;
}

static function IncrementDeaths(UTPlayerReplicationInfo KilledPRI)
{
	KilledPRI.IncrementDeathStat(static.GetStatsName('DEATHS'));
}

static function IncrementSuicides(UTPlayerReplicationInfo KilledPRI)
{
	KilledPRI.IncrementSuicideStat(static.GetStatsName('SUICIDES'));
}

static function name GetStatsName(name StatType)
{
	switch(StatType)
	{
	case 'KILLS':
		if ( Default.KillStatsName != '' )
		{
			return Default.KillStatsName;
		}
		else
		{
			`log(Default.Name$" does not have a Killstat value");
			return 'KILLS_ENVIRONMENT';
		}
	case 'DEATHS':
		if ( Default.DeathStatsName != '' )
		{
			return Default.DeathStatsName;
		}
		else
		{
			`log(Default.Name$" does not have a Death stat value");
			return 'DEATHS_ENVIRONMENT';
		}
	case 'SUICIDES':
		if ( Default.SuicideStatsName != '' )
		{
			return Default.SuicideStatsName;
		}
		else
		{
			`log(Default.Name$" does not have a suicide stat value");
			return 'SUICIDES_ENVIRONMENT';
		}
	}

	`log(StatType$" was invalid");
	return 'BAD_STAT';
}

static function ScoreKill(UTPlayerReplicationInfo KillerPRI, UTPlayerReplicationInfo KilledPRI, Pawn KilledPawn)
{
	if ( KillerPRI == KilledPRI )
	{
		if ( KillerPRI != None )
		{
			IncrementSuicides(KillerPRI);
		}
	}
	else
	{
		if ( KillerPRI != None )
			IncrementKills(KillerPRI);
		if ( KilledPRI != None )
			IncrementDeaths(KilledPRI);
	}
}

static function PawnTornOff(UTPawn DeadPawn);

/** allows DamageType to spawn additional effects on gibs (such as flame trails) */
static function SpawnGibEffects(UTGib Gib)
{
	local ParticleSystemComponent Effect;

	if (default.GibTrail != None)
	{
		// we can't use the ParticleSystemComponentPool here as the trails are long lasting/infi so they will not call OnParticleSystemFinished
		Effect = new(Gib) class'UTParticleSystemComponent';
		Effect.SetTemplate(Default.GibTrail);
		Gib.AttachComponent(Effect);
	}
}

/**
* @param DeadPawn is pawn killed by this damagetype
* @return whether or not we should gib due to damage
*/
static function bool ShouldGib(UTPawn DeadPawn)
{
	if (DeadPawn.WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
	{
		return true;
	}
	return ( !Default.bNeverGibs && (Default.bAlwaysGibs || (DeadPawn.AccumulateDamage > Default.AlwaysGibDamageThreshold) || ((DeadPawn.Health < Default.GibThreshold) && (DeadPawn.AccumulateDamage > Default.MinAccumulateDamageThreshold))) );
}


static function DoCustomDamageEffects(UTPawn ThePawn, class<UTDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
	`log("UTDamageType base DoCustomDamageEffects should never be called");
	// ScriptTrace();
}


/**
* This will create a skeleton (white boney skeleton) on death.
*
* Currently it doesn't play any Player Death effects as we don't have them yet.
**/
static function CreateDeathSkeleton(UTPawn ThePawn, class<UTDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
	local Array<Attachment> PreviousAttachments;
	local int				Idx;
	local SkeletalMeshComponent PawnMesh;
	local vector Impulse;
	local vector ShotDir;
	local MaterialInstanceTimeVarying MITV_BurnOut;
	local class<UTFamilyInfo> FamilyInfo;


	FamilyInfo = ThePawn.GetFamilyInfo();

	// don't try to make a death skeleton if there is no skel mesh to use
	if( FamilyInfo.default.DeathMeshSkelMesh == None )
	{
		return;
	}

	PawnMesh = ThePawn.Mesh;
	ShotDir = Normal(ThePawn.TearOffMomentum);

	//Mesh.bIgnoreControllers = 1;
	PreviousAttachments = PawnMesh.Attachments;
	ThePawn.SetCollisionSize( 1.0f, 1.0f );
	ThePawn.CylinderComponent.SetTraceBlocking( FALSE, FALSE );

	PawnMesh.SetSkeletalMesh( FamilyInfo.default.DeathMeshSkelMesh, TRUE );
	if( FamilyInfo.default.DeathMeshPhysAsset != none )
	{
		PawnMesh.SetPhysicsAsset( ThePawn.GetFamilyInfo().default.DeathMeshPhysAsset );
	}

    // set the MITVs for this pawn based off its race
	for( Idx = 0; Idx < FamilyInfo.default.SkeletonBurnOutMaterials.Length; ++Idx )
	{
		MITV_BurnOut = new(PawnMesh.outer) class'MaterialInstanceTimeVarying';
		MITV_BurnOut.SetParent( FamilyInfo.default.SkeletonBurnOutMaterials[Idx] );
		// this can have a max of 6 before it wraps and become visible again
		PawnMesh.SetMaterial( Idx, MITV_BurnOut );
		MITV_BurnOut.SetScalarStartTime( 'BurnAmount', 1.0f );
	}


	PawnMesh.MotionBlurScale = 0.0f;

	// Make sure all bodies are unfixed
	if( PawnMesh.PhysicsAssetInstance != none )
	{
		PawnMesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);

		// Turn off motors
		PawnMesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(FALSE, FALSE);
	}
	else
	{
		`log( "PawnMesh.PhysicsAssetInstance is NONE!!" );
	}

	for( Idx = 0; Idx < PreviousAttachments.length; ++Idx )
	{
		PawnMesh.AttachComponent( PreviousAttachments[Idx].Component, PreviousAttachments[Idx].BoneName,
					PreviousAttachments[Idx].RelativeLocation, PreviousAttachments[Idx].RelativeRotation,
					PreviousAttachments[Idx].RelativeScale );
	}

	// set all of the materials on the death mesh to be resident
	for( Idx = 0; Idx < FamilyInfo.default.DeathMeshNumMaterialsToSetResident; ++Idx )
	{
		FamilyInfo.default.DeathMeshSkelMesh.Materials[Idx].SetForceMipLevelsToBeResident( false, false, 10.0f );
	}


	Impulse = ShotDir * Min( TheDamageType.default.KDamageImpulse, 10 );
	BoneBreaker( ThePawn, PawnMesh, Impulse, HitLocation, HitInfo.BoneName );
}


/**
 * This will look in the NumBonesToPossiblyBreak and choose a bone to break from that list.
 *
 **/
static function BoneBreaker(UTPawn ThePawn, SkeletalMeshComponent TheMesh, vector Impulse, vector HitLocation, name BoneName)
{
	local int NumBonesToPossiblyBreak;
	local int ConstraintIndex;

	NumBonesToPossiblyBreak = ThePawn.GetFamilyInfo().default.DeathMeshBreakableJoints.length;
	if( NumBonesToPossiblyBreak > 0 )
	{
		// the issue is that for some weapon hits there is no bone name hit
		// for UT we just always do this as the only time we are currently having broken bones is for the human death skeleton
		BoneName = ThePawn.GetFamilyInfo().default.DeathMeshBreakableJoints[ Rand( NumBonesToPossiblyBreak ) ];

		ConstraintIndex = TheMesh.FindConstraintIndex( BoneName );

		if (ConstraintIndex != INDEX_NONE)
		{
			TheMesh.PhysicsAssetInstance.Constraints[ConstraintIndex].TermConstraint();

			// @see PlayDying:  we also do this in the steps after init ragdoll to the full body
			TheMesh.AddImpulse( Impulse, HitLocation, BoneName );
		}
		else
		{
			`log( "was unable to find the Constraint!!!" );
		}
	}
}


/**
* This will create the gore chunks from a special death
*
* Note: temp here until we get real chunks and know the set of death types we are going to have
**/
static function CreateDeathGoreChunks(UTPawn ThePawn, class<UTDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
	local int i;
	local bool bSpawnHighDetail;
	local UTGib TheGib;
	local GibInfo GibInfo;

	// gib particles
	if( ThePawn.GetFamilyInfo().default.GibExplosionTemplate != None && ThePawn.EffectIsRelevant(ThePawn.Location, false, 7000) )
	{
		ThePawn.WorldInfo.MyEmitterPool.SpawnEmitter(ThePawn.GetFamilyInfo().default.GibExplosionTemplate, ThePawn.Location, ThePawn.Rotation);
	}

	// spawn all other gibs
	bSpawnHighDetail = !ThePawn.WorldInfo.bDropDetail && (ThePawn.Worldinfo.TimeSeconds - ThePawn.LastRenderTime < 1);
	for( i = 0; i < ThePawn.CurrCharClassInfo.default.Gibs.length; ++i )
	{
		GibInfo = ThePawn.CurrCharClassInfo.default.Gibs[i];

		if( bSpawnHighDetail || !GibInfo.bHighDetailOnly )
		{
			TheGib = ThePawn.SpawnGib(GibInfo.GibClass, GibInfo.BoneName, TheDamageType, HitLocation, true);
			// gib could not spawn due to being inside of something
			if( TheGib != None )
			{
				SpawnExtraGibEffects( TheGib );
			}
		}
	}

	ThePawn.bGibbed = true;
}

/** allows special effects when gibs are spawned via DoCustomDamageEffects() instead of the normal way */
simulated static function SpawnExtraGibEffects( UTGib TheGib );

simulated static function DrawKillIcon(Canvas Canvas, float ScreenX, float ScreenY, float HUDScaleX, float HUDScaleY)
{
	if ( default.DamageWeaponClass != None )
	{
		default.DamageWeaponClass.static.DrawKillIcon(Canvas, ScreenX, ScreenY, HUDScaleX, HUDScaleY);
	}
}

/** called when a dead pawn viewed by a player was killed by a DamageType with bSpecialDeathCamera set to true */
simulated static function CalcDeathCamera(UTPawn P, float DeltaTime, out vector CameraLocation, out rotator CameraRotation, out float CameraFOV);


/** Return the DeathCameraEffect that will be played on the instigator that was caused by this damagetype and the Pawn type (e.g. robot) */
simulated static function class<UDKEmitCameraEffect> GetDeathCameraEffectInstigator( UTPawn UTP )
{
	return default.DeathCameraEffectInstigator;
}

/** Return the DeathCameraEffect that will be played on the victim that was caused by this damagetype and the Pawn type (e.g. robot) */
simulated static function class<UDKEmitCameraEffect> GetDeathCameraEffectVictim( UTPawn UTP )
{
	return default.DeathCameraEffectVictim;
}


defaultproperties
{
	KillStatsName=KILLS_ENVIRONMENT //catchall for stats
	DeathStatsName=DEATHS_ENVIRONMENT //catchall for stats
	SuicideStatsName=SUICIDES_ENVIRONMENT //catchall for stats

	RewardAnnouncementClass=class'UTWeaponRewardMessage'

	DamageBodyMatColor=(R=10)
	DamageOverlayTime=0.1
	DeathOverlayTime=0.1
	bDirectDamage=true
	GibPerterbation=0.06
	GibThreshold=-50
	GibTrail=ParticleSystem'Envy_Effects.Tests.Effects.P_Vehicle_Damage_1'
	MinAccumulateDamageThreshold=50
	AlwaysGibDamageThreshold=150
	PhysicsTakeHitMomentumThreshold=250.0
	RadialDamageImpulse=750

	bAnimateHipsForDeathAnim=true
	DeathAnimRate=1.0

	NodeDamageScaling=1.0
	CustomTauntIndex=-1
	bComplainFriendlyFire=true
	bHeadGibCamera=true

	bCausesFracture=true

	// Short "pop" of damage
	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform0
		Samples(0)=(LeftAmplitude=64,RightAmplitude=96,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.25)
	End Object
	DamagedFFWaveform=ForceFeedbackWaveform0
	// Pretty violent rumble
	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform1
		Samples(0)=(LeftAmplitude=100,RightAmplitude=100,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.75)
	End Object
	KilledFFWaveform=ForceFeedbackWaveform1
}


