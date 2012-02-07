/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPawnSoundGroup extends Object
	abstract
	dependson(UTPhysicalMaterialProperty);

var SoundCue DodgeSound;
var SoundCue DoubleJumpSound;
var SoundCue DefaultJumpingSound;
var SoundCue LandSound;
var SoundCue FallingDamageLandSound;
var SoundCue DyingSound;
var SoundCue HitSounds[3];
var SoundCue GibSound;
var SoundCue DrownSound;
var SoundCue GaspSound;

struct FootstepSoundInfo
{
	var name MaterialType;
	var SoundCue Sound;
};
/** footstep sound effect to play per material type */
var array<FootstepSoundInfo> FootstepSounds;
/** default footstep sound used when a given material type is not found in the list */
var SoundCue DefaultFootstepSound;

var array<FootstepSoundInfo> JumpingSounds;

var array<FootstepSoundInfo> LandingSounds;
var SoundCue DefaultLandingSound;

// The following are /body/ sounds, not vocals:
/* sound for regular bullet hits on the body */
var SoundCue BulletImpactSound;
/* sound from being crushed, such as by a vehicle */
var SoundCue CrushedSound;
/* sound when the body is gibbed*/
var SoundCue BodyExplosionSound;
var SoundCue InstagibSound;

static function PlayInstagibSound(Pawn P)
{
	P.Playsound(Default.InstagibSound, false, true);
}

static function PlayBulletImpact(Pawn P)
{
	P.PlaySound(Default.BulletImpactSound, false, true);
}

static function PlayCrushedSound(Pawn P)
{
	P.PlaySound(Default.CrushedSound,false,true);
}

static function PlayBodyExplosion(Pawn P)
{
	P.PlaySound(Default.CrushedSound,false,true);
}

static function PlayDodgeSound(Pawn P)
{
	P.PlaySound(Default.DodgeSound, false, true);
}

static function PlayDoubleJumpSound(Pawn P)
{
	P.PlaySound(Default.DoubleJumpSound, false, true);
}

static function PlayJumpSound(Pawn P)
{
	P.PlaySound(Default.DefaultJumpingSound, false, true);
}

static function PlayLandSound(Pawn P)
{
    //    PlayOwnedSound(GetSound(EST_Land), SLOT_Interact, FMin(1,-0.3 * P.Velocity.Z/P.JumpZ));
	P.PlaySound(Default.LandSound, false, true);
}

static function PlayFallingDamageLandSound(Pawn P)
{
	P.PlaySound(Default.FallingDamageLandSound, false, true);
}

static function SoundCue GetFootstepSound(int FootDown, name MaterialType)
{
	local int i;

	i = default.FootstepSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? default.DefaultFootstepSound : default.FootstepSounds[i].Sound; // checking for a '' material in case of empty array elements
}

static function SoundCue GetJumpSound(name MaterialType)
{
	local int i;
	i = default.JumpingSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? default.DefaultJumpingSound : default.JumpingSounds[i].Sound; // checking for a '' material in case of empty array elements
}

static function SoundCue GetLandSound(name MaterialType)
{
	local int i;
	i = default.LandingSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? default.DefaultLandingSound : default.LandingSounds[i].Sound; // checking for a '' material in case of empty array elements
}

static function PlayDyingSound(Pawn P)
{
	P.PlaySound(Default.DyingSound);
}

/** play sound when taking a hit
 * this sound should be played replicated
 */
static function PlayTakeHitSound(Pawn P, int Damage)
{
	local int HitSoundIndex;

	if ( P.Health > 0.5 * P.HealthMax )
	{
		HitSoundIndex = (Damage < 20) ? 0 : 1;
	}
	else
	{
		HitSoundIndex = (Damage < 20) ? 1 : 2;
	}
	P.PlaySound(default.HitSounds[HitSoundIndex]);
}

static function PlayGibSound(Pawn P)
{
	P.PlaySound(default.GibSound, true);
}

static function PlayGaspSound(Pawn P)
{
	P.PlaySound(default.GaspSound, true);
}

static function PlayDrownSound(Pawn P)
{
	P.PlaySound(default.DrownSound, true);
}

defaultproperties
{
	DrownSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_MaleDrowning_Cue'
	GaspSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_MGasp_Cue'

	DefaultJumpingSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtJumpCue'

	FootstepSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
	FootstepSounds[2]=(MaterialType=Energy,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyCue')
	FootstepSounds[3]=(MaterialType=Flesh_Human,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshCue')
	FootstepSounds[4]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageCue')
	FootstepSounds[5]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateCue')
	FootstepSounds[6]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue')
	FootstepSounds[7]=(MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowCue')
	FootstepSounds[8]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalCue')
	FootstepSounds[9]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowCue')
	FootstepSounds[10]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodCue')


	JumpingSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue')
	JumpingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtJumpCue')
	JumpingSounds[2]=(MaterialType=Energy,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyJumpCue')
	JumpingSounds[3]=(MaterialType=Flesh_Human,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshJumpCue')
	JumpingSounds[4]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageJumpCue')
	JumpingSounds[5]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue')
	JumpingSounds[6]=(MaterialType=GlassBroken,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassBrokenJumpCue')
	JumpingSounds[7]=(MaterialType=Grass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassJumpCue')
	JumpingSounds[8]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalJumpCue')
	JumpingSounds[9]=(MaterialType=Mud,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudJumpCue')
	JumpingSounds[10]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalJumpCue')
	JumpingSounds[11]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowJumpCue')
	JumpingSounds[12]=(MaterialType=Tile,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_TileJumpCue')
	JumpingSounds[13]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepJumpCue')
	JumpingSounds[14]=(MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowJumpCue')
	JumpingSounds[15]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodJumpCue')

	DefaultLandingSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue'
	LandingSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue')
	LandingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue')
	LandingSounds[2]=(MaterialType=Energy,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_EnergyLandCue')
	LandingSounds[3]=(MaterialType=Flesh_Human,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FleshLandCue')
	LandingSounds[4]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageLandCue')
	LandingSounds[5]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')
	LandingSounds[6]=(MaterialType=GlassBroken,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassBrokenLandCue')
	LandingSounds[7]=(MaterialType=Grass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassLandCue')
	LandingSounds[8]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue')
	LandingSounds[9]=(MaterialType=Mud,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudLandCue')
	LandingSounds[10]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue')
	LandingSounds[11]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowLandCue')
	LandingSounds[12]=(MaterialType=Tile,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_TileLandCue')
	LandingSounds[13]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue')
	LandingSounds[14]=(MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowLandCue')
	LandingSounds[15]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodLandCue')

	BulletImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_Bullet_Cue'
}

