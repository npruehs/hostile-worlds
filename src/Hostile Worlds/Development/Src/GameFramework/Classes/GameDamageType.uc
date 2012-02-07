/**
 * This class is the base class for Game Damagetypes
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GameDamageType extends DamageType
	native
	config(Weapon)
	dependson(GameTypes)
	abstract;


/** This is the material that should be used for the damage overlay when hit by this damage type **/
var const MaterialInterface MI_DamageOverlay;

/** This is the sound to play when you are damaged by this DamageType **/
var const SoundCue ExtraSoundToPlayWhenDamaged;

/** TRUE if this damage type come from the 'environment' and not a weapon */
var const bool bEnvironmentalDamage;

/** If TRUE, play a high kick death animation. Suitable for explosives, or high kick weapons such as shotguns */
var const config bool bHighKickDeathAnimation;

/** When this is TRUE, it forces a straight rag doll death, without playing death animations, nor motorized physics. */
var const bool bForceRagdollDeath;

/** When bShouldGib is set, DistFromHitLocToGib creates a cylinder of influence around the HitLocation, along the HitDirection,
* And any constraints within that cylinder will be broken.	 Default value of -1.f breaks the whole body. */
var const config float DistFromHitLocToGib;


/** Killed by Icon **/
var const CanvasIcon KilledByIcon;
var const CanvasIcon HeadshotIcon;
var const float IconScale;


/**
 * This is the Damage Type's suppress impact effects bool
 * Some weapons such should not play impact effects.
 **/
var const bool bSuppressImpactFX;

/**
 * This is the Damage Type's suppress blood decals
 * Some weapons are so expensive that we don't want to have more costs associated with them per frame
 **/
var const bool bSuppressBloodDecals;

/**
 * Some explosion particle systems already have the blood and guts inside the Explosion so we do not want to play the additional
 * effect.
 **/
var const bool bSuppressPlayExplosiveRadialDamageEffects;

/** If this weapon does head shots, is it capable of knocking the head off entirely for the special death? */
var const config bool bAllowHeadShotGib;



/** Should the Pawn explode into chunky bits when killed with this damage type? */
static function bool ShouldGib( Pawn TestPawn, Pawn Instigator )
{
	return FALSE;
}


/** Called when a Pawn receives damage of this type, allows special case modifications (default implementation handles head shots) */
static function ModifyDamage( Pawn Victim, Controller InstigatedBy, out int out_Damage, out vector out_Momentum, vector HitLocation, TraceHitInfo HitInfo );


/**
 * Called when a Pawn is hurt with this damage type, after the damage has been applied.  Server side  only.
 */
static function HandleDamagedPawn( Pawn DamagedPawn, Pawn Instigator, int DamageAmt, vector Momentum );


/** Called when a Pawn is killed with this damage type */
static function HandleKilledPawn(Pawn KilledPawn, Pawn Instigator);


static function HandleDeadPlayer( GamePlayerController Player );


static function bool ShouldPlayForceFeedback( Pawn DamagedPawn )
{
	return TRUE;
}

static function bool IsScriptedDamageType()
{
	return FALSE;
}

/** Should the Pawn play the special head shot death? */
static function bool ShouldHeadShotGib(Pawn TestPawn, Pawn Instigator)
{
	local GamePawn GP;
	// if we are capable
	if (default.bAllowHeadShotGib)
	{
		// return TRUE if the last hit was a head shot
		GP = GamePawn(TestPawn);
		if (GP != None && GP.bLastHitWasHeadShot)
		{
			return TRUE;
		}
	}
	return FALSE;
}

/**
* Called on all clients when a pawn has taken damage, used to kick off damage type specific FX.
*/
static function HandleDamageFX(GamePawn DamagedPawn, const out TakeHitInfo HitInfo);





defaultproperties
{
	bCausesFracture=TRUE

	bSuppressImpactFX=FALSE
	bSuppressPlayExplosiveRadialDamageEffects=FALSE

}
