// ============================================================================
// HWSquadMember
// An abstract squad member of Hostile Worlds.
//
// Author:  Nick Pruehs, Marcel Koehler
// Date:    2010/10/13
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWSquadMember extends HWPawn
	config(HostileWorldsUnitData)
	abstract;

/** The maximum number of squad members a player may control. */
const SQUAD_MEMBERS_MAXIMUM = 8;

/** The maximum level of a squad member. */
const SQUAD_MEMBER_LEVEL_MAXIMUM = 6;

/** The number of shards required for calling a new squad member if a player already has half his or her squad. See GDD, chapter Core Gameplay. */
const SQUAD_MEMBER_COST = 450;

/** The maximum offset squad members spawn around their commander. */
const MAX_SPAWN_OFFSET = 200;

/** The amount of shields regenerated each tick, multiplied with the maximum shields. */
const SHIELD_REGENERATION_RATE = 0.01;

/** The time that has to pass before shield regeneration starts after a hit, in seconds. */
const TIME_UNTIL_REGENERATING_SHIELDS = 5;

/** The time that has to pass before shields are regenerated again, in seconds. */
const SHIELD_REGENERATION_TICK_TIME = 1;

/** The number of victory points awarded for killing an enemy squad member. */
const VICTORY_POINTS_PER_SQUAD_MEMBER = 50;

/** The time before a squad member is dismissed after having received the order, in seconds. */
const DISMISS_TIME = 4.f;

/** The time delta between two dismiss timer updates. */
const DISMISS_TICK_TIME = 0.1f;

/** The description of this squad member class. */
var localized string Description;

/** The current amount of shields of this squad member. */
var int ShieldsCurrent;

/** The maximum amount of shields of this squad member. */
var config int ShieldsMax;

/** The current level of this squad member. */
var repnotify int Level;

/** The amount of structure points awarded on promotion. */
var config int StructurePerLevelUp;

/** The amount of shield points awarded on promotion. */
var config int ShieldsPerLevelUp;

/** The amount of attack damage awarded on promotion. */
var config int DamagePerLevelUp;

/** The number of abilities a squad member can have. */
const AbilityNumber = 5;

/** The remaining time before this squad member is dismissed, in seconds. */
var float DismissTimeRemaining;

/** The race this squad member belongs to. */
var class<HWRace> Race;

/** The abilities of this squad member. */
var HWAbility Abilities[AbilityNumber];

/** The ability that is automatically triggered if this squad member is idle. Must not cost shards. */
var HWAbilityTargetingUnit AutoCastAbility;

/** A decal indicating the range of the ability the player wants to trigger. */
var HWDe_AbilityRadius AbilityRadius;

/** The material to be shown whenever the shields of this squad member are hit. */
var MaterialInterface ShieldMaterial;

/** 
 *  The overlay mesh that is attached to this squad member whenever the shields
 *  of this squad member are hit, showing the shield material.
 */
var SkeletalMeshComponent ShieldOverlayMesh;

/** Whether the shields of this squad member are currently shown, or not. */
var repnotify bool bShowingShieldEffect;

/** WeaponSocket contains the name of the socket used for attaching weapons to this pawn. */
var name WeaponSocket, WeaponSocket2;

/** This holds the local copy of the current attachment.  This "attachment" actor will exist independantly on all clients */
var	HWWeaponAttachment WeaponAttachment;

/** Holds the class type of the current weapon attachment. */
var	class<HWWeaponAttachment> WeaponAttachmentClass;

/** The recoil node used to move this squad member's weapon when he or she fires. */
var GameSkelCtrl_Recoil	GunRecoilNode;

/** The icon of this squad member to be shown in the ability window of the UI while it is not selected. */
var Texture2D UnitPortraitNotSelected;

/** The icon of this squad member to be shown in the Call Squad Member submenu of the UI. */
var Texture2D UnitPortraitSubmenu;

/** The audio component used for playing the Promote sounds of this squad member. */
var AudioComponent AudioComponentPromoted;

/** The sound to be played whenever the player promotes one of his or her squad members. */
var SoundCue SoundPromoted;

simulated event PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	// initialize shields
	ShieldsCurrent = ShieldsMax;

	// initialize shield overlay mesh that is shown every time the shields are hit
	ShieldOverlayMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
	ShieldOverlayMesh.SetParentAnimComponent(Mesh);

	for (i = 0; i < ShieldOverlayMesh.SkeletalMesh.Materials.Length; i++)
	{
		ShieldOverlayMesh.SetMaterial(i, ShieldMaterial);
	}

	// Create and attach the WeaponAttachment
	if (WeaponAttachmentClass != None)
	{
		WeaponAttachment = Spawn(WeaponAttachmentClass,self);
	}

	if (WeaponAttachment != None)
	{
		WeaponAttachment.AttachTo(self);
	}

	// spawn ability range decal
	AbilityRadius = Spawn(class'HWDe_AbilityRadius', OwningPlayer);
}

/** Taken from UTPawn. */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);

	GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
}

function Initialize(HWMapInfoActor TheMap, optional Actor A)
{
	super.Initialize(TheMap, A);

	HWPlayerController(A).SquadMembers++;

	AddAbilities();

	// set initial team color on server
	ChangeColor(TeamIndex);

	// update HUD
	HWHud(OwningPlayer.myHUD).Update();

	// HACK MK Enable bIsHoldingPosition as default 
	HWAIController(Controller).bIsHoldingPosition = true;
}

/** Allows subclasses to add and initialize their default abilities. */
function AddAbilities();

/** Returns the number of shards that is required for promoting this squad member. */
simulated function int ShardsRequiredForPromotion()
{
	// see GDD, chapter Core Gameplay
	return 50 * Level * (Level + 1);
}

/** Returns the number of shards that is earned when this squad member is dismissed. */
simulated function int ShardsEarnedWhenDismissed()
{
	local int ShardsEarned;

	// see GDD, chapter Core Gameplay
	ShardsEarned = 50 * Level * (Level - 1);

	// add more shards if the player's squad has more than half the possible members
	if (OwningPlayer.ExtraShardsSpent > 0)
	{
		ShardsEarned += class'HWSquadMember'.const.SQUAD_MEMBER_COST;
	}

	// scale down by health
	ShardsEarned *= (float(Health) / float(HealthMax));

	return 0.8 * ShardsEarned;
}

function int GetShardsAwarded()
{
	// see GDD, chapter Core Gameplay
	return 20 * Level + 80;
}

/** Promotes this squad member, improving its statistics and awarding a new ability point. */
function Promote()
{
	// improve statistics
	HealthMax += StructurePerLevelUp;
	Health += StructurePerLevelUp;

	AttackDamage += DamagePerLevelUp;

	ShieldsMax += ShieldsPerLevelUp;
	ShieldsCurrent += ShieldsPerLevelUp;

	Level++;

	`Log(self$" has been promoted to level "$Level$".");
}

function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	// apply squad member shields
	if (ShieldsCurrent >= InDamage)
	{
		// all damage is absorbed by the shields
		ShieldsCurrent -= InDamage;
		InDamage = 0;

		// show shield effect
		ShowShieldEffect();
	}
	else
	{
		// shields are depleted
		InDamage -= ShieldsCurrent;
		ShieldsCurrent = 0;

		super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);
	}

	// restart shield regeneration timer
	SetTimer(TIME_UNTIL_REGENERATING_SHIELDS, false, 'RegenerateShields');
}

/** Regenerates a bit of this squad member's shields. */
function RegenerateShields()
{
	// Only regenerate if less shields than max
	if(ShieldsCurrent < ShieldsMax)
	{
		ShieldsCurrent += ShieldsMax * SHIELD_REGENERATION_RATE;
		// If higher or equal than max reset to max
		if(ShieldsCurrent >= ShieldsMax)
		{
			ShieldsCurrent = ShieldsMax;
		}
		// else set another timer 
		else
		{
			SetTimer(SHIELD_REGENERATION_TICK_TIME, false, 'RegenerateShields');
		}
	}
}

/** Shows an energy shield effect around this squad member for a short time. */
simulated function ShowShieldEffect()
{
	// attach the overlay mesh
	if (!ShieldOverlayMesh.bAttached)
	{
		AttachComponent(ShieldOverlayMesh);
	}

	bShowingShieldEffect = true;
	SetTimer(0.5f, false, 'HideShieldEffect');
}

/** Hides the energy shield effect around this squad member. */
simulated function HideShieldEffect()
{
	if (ShieldOverlayMesh.bAttached) 
	{
		DetachComponent(ShieldOverlayMesh);
	}

	bShowingShieldEffect = false;
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local bool DyingAllowed;
	local HWPlayerController KillingPlayer;

	DyingAllowed = super.Died(Killer, DamageType, HitLocation);

	if (DyingAllowed)
	{	
		if (Killer != none)
		{
			KillingPlayer = HWPlayerController(Killer);

			if (KillingPlayer != none)
			{
				// award victory points to the killer
				KillingPlayer.PlayerReplicationInfo.Team.Score += VICTORY_POINTS_PER_SQUAD_MEMBER;
				`log("Team "$KillingPlayer.PlayerReplicationInfo.Team$" scored "$VICTORY_POINTS_PER_SQUAD_MEMBER$" points!");

				WorldInfo.Game.CheckScore(KillingPlayer.PlayerReplicationInfo);

				// remember squad members killed for score screen
				KillingPlayer.TotalSquadMembersKilled++;
			}
		}
		
		// remember squad members lost and dismissed score screen
		if (DamageType == class'HWDT_Dismiss')
		{
			OwningPlayer.TotalSquadMembersDismissed++;
		}
		else
		{
			OwningPlayer.TotalSquadMembersLost++;

			// decrease alien rage
			OwningPlayer.AlienRageDecrease();
		}

		// update HUD
		HWHud(OwningPlayer.myHUD).Update();
	}

	return DyingAllowed;
}

/** Starts the replicated dismiss timer of this squad member. */
function Dismiss()
{
	`log(self$" is being dismissed by "$OwningPlayer$".");

	HWAIController(Controller).IssueDismissOrder();

	SetTimer(DISMISS_TICK_TIME, true, 'UpdateDismissTimer');
	DismissTimeRemaining = DISMISS_TIME;
}

/** Ticks the replicated dismiss timer of this squad member, dismissing it if the time's up. */
function UpdateDismissTimer()
{
	DismissTimeRemaining -= DISMISS_TICK_TIME;

	if (DismissTimeRemaining <= 0)
	{
		`log(self$" has been dismissed by "$OwningPlayer$".");

		Kill(class'HWDT_Dismiss');

		ClearTimer('UpdateDismissTimer');
	}
}

/** Returns true, if this squad member is currently being dismissed, and false otherwise. */
function bool BeingDismissed()
{
	return (DismissTimeRemaining > 0);
}

simulated function vector GetEffectLocation()
{
	return WeaponAttachment.GetEffectLocation();
}

simulated function Destroyed()
{
	super.Destroyed();

	// Only remove Squadmembers from the Squad array on the server
	if(WorldInfo.NetMode < NM_Client)
	{
		OwningPlayer.SquadMembers--;
	}

	if (WeaponAttachment != None)
	{
		WeaponAttachment.Destroy();
	}

	if (AbilityRadius != none)
	{
		AbilityRadius.Destroy();
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bShowingShieldEffect')
	{
		if (bShowingShieldEffect)
		{
			ShowShieldEffect();
		}
	}
	else if (VarName == 'Level')
	{
		HealthMax = StructureMax + (Level - 1) * StructurePerLevelUp;
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	if (WeaponAttachment != None)
	{
		WeaponAttachment.CauseMuzzleFlash();

		if (GunRecoilNode != None)
		{
			// Use recoil node to move arms when we fire
			GunRecoilNode.bPlayRecoil = true;
		}
	}
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
    if (WeaponAttachment != None)
	{
		WeaponAttachment.StopMuzzleFlash();
	}
}

/**
 * Checks whether this squad member has (learned) an ability of the specified
 * class, returning the ability in that case, and returning None otherwise.
 * 
 * @param AbilityClass
 *      the class of the ability to look for
 */
simulated function HWAbility HasAbility(class<HWAbility> AbilityClass)
{
	local int i;
	local HWAbility Ability;

	for (i = 0; i < AbilityNumber; i++)
	{
		Ability = Abilities[i];

		if (Ability != none && Ability.Class == AbilityClass && Ability.bLearned)
		{
			return Ability;
		}
	}

	return none;
}

/**
 * Forces a cooldown of the given time on all the squadmembers' abilities.
 * Abilities that are already on cooldown maintain their original cooldown if bigger,
 * otherwise use the given time as new cooldown.
 */
function ForceAbilityCooldown(int time)
{
	local int i;
	local HWAbility Ability;

	for (i = 0; i < 4; i++)
	{
		Ability = Abilities[i];

		if(Ability != none)
		{	
			Ability.ForceCooldown(time);
		}
	}
}

/** Plays the Promote sound of this squad member at its location. */
simulated function PlaySoundPromoted()
{
	if (SoundPromoted != none)
	{
		if(AudioComponentPromoted.IsPlaying())
		{
			AudioComponentPromoted.Stop();	
		}

		AudioComponentPromoted.Location = Location;
		AudioComponentPromoted.SoundCue = SoundPromoted;
		AudioComponentPromoted.Play();
	}
}

replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		Abilities, bShowingShieldEffect, DismissTimeRemaining,
		
		// required for level-ups
		ShieldsMax, ShieldsCurrent, Level;
}


DefaultProperties
{
	Level=1

	AnimNameDeath=Death_Stinger
	AnimDurationDeath=1.0667f

	ShieldMaterial=Material'FX_Misc.M_SquadMemberShields_Test'

	bUsesTeamColors=true

	Begin Object Name=OverlayMeshComponentShield Class=SkeletalMeshComponent
		Scale=1.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bAllowAmbientOcclusion=false
	End Object
	ShieldOverlayMesh=OverlayMeshComponentShield

	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	
	GibExplosionTemplate=ParticleSystem'T_FX.Effects.P_FX_GibExplode_Corrupt'

	Gibs[0]=(BoneName=b_LeftForeArm,GibClass=class'UTGib_RobotArm',bHighDetailOnly=false)
	Gibs[1]=(BoneName=b_RightForeArm,GibClass=class'UTGib_RobotHand',bHighDetailOnly=true)
	Gibs[2]=(BoneName=b_LeftLeg,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
	Gibs[3]=(BoneName=b_RightLeg,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
	Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_RobotTorso',bHighDetailOnly=false)
	Gibs[5]=(BoneName=b_Spine1,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[6]=(BoneName=b_Spine2,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[7]=(BoneName=b_LeftClav,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[8]=(BoneName=b_RightClav,GibClass=class'UTGib_RobotArm',bHighDetailOnly=true)

	SoundPromoted=SoundCue'A_Sounds_General.A_General_SquadMemberPromotedCue_Test'

	Begin Object Class=AudioComponent name=NewAudioComponentPromoted
	End Object
	AudioComponentPromoted=NewAudioComponentPromoted
	Components.Add(NewAudioComponentPromoted)
}
