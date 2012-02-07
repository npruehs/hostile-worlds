// ============================================================================
// HWAlien_Weak
// A weak alien of Hostile Worlds.
//
// Author:  Nick Pruehs
// Date:    2010/10/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWAlien_Weak extends HWAlien;

/** The time between two roam orders. */
const ROAM_INTERVAL = 5.f;

/** The radius around the camp the aliens roam, in UU. */
const ROAM_RADIUS = 500.f;

/** The alien camp this alien belongs to. */
var HWAlienCamp AlienCamp;


function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	super.Initialize(TheMap, A);

	AlienCamp = HWAlienCamp(A);

	//SetTimer(ROAM_INTERVAL, true, 'Roam');
}

/** Finds a location next to this alien's camp and makes this alien attack-move there. */
function Roam()
{
	local Vector RoamLocation;
	local Vector RoamOffset;
	local Vector TraceStart;
	local Vector TraceEnd;
	local Vector TraceHitNormal;

	// compute random roam offset within ROAM_RADIUS
	RoamOffset.X = rand(ROAM_RADIUS) - ROAM_RADIUS / 2;
	RoamOffset.Y = rand(ROAM_RADIUS) - ROAM_RADIUS / 2;
	
	// compute the probable roam location
	RoamLocation.X = AlienCamp.Location.X + RoamOffset.X;
	RoamLocation.Y = AlienCamp.Location.Y + RoamOffset.Y;
	RoamLocation.Z = AlienCamp.Location.Z;

	// trace the z-coordinate in world space
	TraceStart = RoamLocation;
	TraceStart.Z = 1000;

	TraceEnd = RoamLocation;
	TraceEnd.Z = -1000;

	Trace(RoamLocation, TraceHitNormal, TraceEnd, TraceStart, false);

	// issue attack-move order
	HWAIController(Controller).IssueAttackMoveOrder(RoamLocation);
}

function Attack(HWPawn Target)
{
	local HWPlayerController AttackedPlayer;
	local float DefaultAttackDamage;

	DefaultAttackDamage = AttackDamage;

	// scale damage dealt by alien range
	AttackedPlayer = Target.OwningPlayer;

	if (AttackedPlayer != none)
	{
		AttackDamage *= (1.0f + AttackedPlayer.AlienRage);
		`log(self$" is scaling its attack damage by alien rage, dealing "$AttackDamage$" damage instead of "$DefaultAttackDamage$".");
	}

	super.Attack(Target);

	// restore default attack damage
	AttackDamage = DefaultAttackDamage;
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local bool DyingAllowed;
	local HWPlayerController KillingPlayer;

	DyingAllowed = super.Died(Killer, DamageType, HitLocation);

	if (DyingAllowed)
	{
		// prepare respawn
		AlienCamp.NotifyAlienDied(ALIEN_RESPAWN_TIME);

		if (Killer != none)
		{
			KillingPlayer = HWPlayerController(Killer);

			if (KillingPlayer != none)
			{
				// increase alien rage
				KillingPlayer.AlienRageIncrease();

				// remember shards farmed and aliens killed for score screen
				KillingPlayer.TotalShardsFarmed += GetShardsAwarded();
				KillingPlayer.TotalAliensKilled++;
			}
		}
	}

	return DyingAllowed;
}


DefaultProperties
{
	AnimNameDeath=Die
	AnimDurationDeath=1.3333f

	AnimNameMeleeAttack=Kill

	SoundBattleCry=SoundCue'A_Test_Voice_Units.LizardDogBattleCry_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.LizardDogDied_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_Alien_Test'

	// Workaround to show the pawn's visual assets
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		//PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_creep_Lizarddog.AS_creep_Lizzarddog'
		AnimTreeTemplate=AnimTree'CH_creep_Lizarddog.AT_creep_Lizarddog'
		SkeletalMesh=SkeletalMesh'CH_creep_Lizarddog.SM_C_Lizzardd'
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	// Floating fix
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0048.000000
	End Object
	CylinderComponent=CollisionCylinder	
}
