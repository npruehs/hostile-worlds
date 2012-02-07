/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTBerserk extends UTTimedPowerup;

/** ambient sound on the pawn when Berserk is active */
var SoundCue BerserkAmbientSound;
/** sound played when the Berserk is running out */
var SoundCue BerserkFadingSound;
/** overlay material applied to owner */
var MaterialInterface OverlayMaterialInstance;
/** particle effect played on vehicle weapons */
var MeshEffect VehicleWeaponEffect;

simulated static function AddWeaponOverlay(UTGameReplicationInfo GRI)
{
	GRI.WeaponOverlays[1] = default.OverlayMaterialInstance;
	GRI.VehicleWeaponEffects[1] = default.VehicleWeaponEffect;
}

/** adds or removes our bonus from the given pawn */
simulated function AdjustPawn(UTPawn P, bool bRemoveBonus)
{
	if (P != None && Role == ROLE_Authority)
	{
		if (bRemoveBonus)
		{
			P.FireRateMultiplier *= 2.0;
		}
		else
		{
			// halve firing time
			P.FireRateMultiplier *= 0.5;
		}
		P.FireRateChanged();
	}
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	local UTPawn P;

	Super.GivenTo(NewOwner, bDoNotActivate);

	P = UTPawn(NewOwner);
	if (P != None)
	{
		// apply Berserk overlay
		P.SetWeaponOverlayFlag(1);

		P.SetPawnAmbientSound(BerserkAmbientSound);

		AdjustPawn(P, false);

		// max ammo on all weapons
		if ( UTInventoryManager(P.InvManager) != None )
		{
			UTInventoryManager(P.InvManager).AllAmmo();
		}
		// juggernaut if already has udamage or invulnerability
		if ( ((P.DamageScaling > 1.0) || P.bIsInvulnerable) && (PlayerController(P.Controller) != None) )
		{
			PlayerController(P.Controller).ReceiveLocalizedMessage( class'UTPowerupRewardMessage', 0 );
		}
	}
	// set timer for ending sounds
	SetTimer(TimeRemaining - 3.0, false, 'PlayBerserkFadingSound');
}

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super.ClientGivenTo(NewOwner, bDoNotActivate);

	if (Role < ROLE_Authority)
	{
		AdjustPawn(UTPawn(NewOwner), false);
	}
}

function ItemRemovedFromInvManager()
{
	local UTPlayerReplicationInfo UTPRI;
	local UTPawn P;

	P = UTPawn(Owner);
	if ( P != None )
	{
		P.ClearWeaponOverlayFlag(1);
		P.SetPawnAmbientSound(None);
		AdjustPawn(P, true);
		//Stop the timer on the powerup stat
		if (P.DrivenVehicle != None)
		{
			UTPRI = UTPlayerReplicationInfo(P.DrivenVehicle.PlayerReplicationInfo);
		}
		else
		{
			UTPRI = UTPlayerReplicationInfo(P.PlayerReplicationInfo);
		}
		if (UTPRI != None)
		{
			UTPRI.StopPowerupTimeStat(GetPowerupStatName());
		}
	}
	SetTimer(0.0, false, 'PlayBerserkFadingSound');
}

simulated event Destroyed()
{
	if (Role < ROLE_Authority)
	{
		AdjustPawn(UTPawn(Owner), true);
	}

	Super.Destroyed();
}

/** called on a timer to play Berserk ending sound */
function PlayBerserkFadingSound()
{
	// reset timer if time got added
	if (TimeRemaining > 3.0)
	{
		SetTimer(TimeRemaining - 3.0, false, 'PlayBerserkFadingSound');
	}
	else
	{
		Instigator.PlaySound(BerserkFadingSound);
		SetTimer(0.75, false, 'PlayBerserkFadingSound');
	}
}


defaultproperties
{
	PowerupStatName=POWERUPTIME_BERSERK
	Begin Object Class=StaticMeshComponent Name=MeshComponentA
		StaticMesh=StaticMesh'Pickups.Berserk.Mesh.S_Pickups_Berserk'
		Materials(0)=Material'Pickups.Berserk.Materials.M_Pickups_Berserk'
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		bAcceptsLights=true
		CollideActors=false
		BlockRigidBody=false
		Scale3D=(X=0.7,Y=0.7,Z=0.7)
		MaxDrawDistance=8000
		Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	DroppedPickupMesh=MeshComponentA
	PickupFactoryMesh=MeshComponentA

	Begin Object Class=UTParticleSystemComponent Name=BerserkParticles
		Template=ParticleSystem'Pickups.Berserk.Effects.P_Pickups_Berserk_Idle'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	DroppedPickupParticles=BerserkParticles

	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Berzerk_PickupCue'

	BerserkAmbientSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Berzerk_PowerLoopCue'
	BerserkFadingSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Berzerk_WarningCue'
	OverlayMaterialInstance=Material'Pickups.Berserk.M_Berserk_Overlay'
	HudIndex=1
	PowerupOverSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Berzerk_EndCue'

	IconCoords=(U=744,UL=35,V=0,VL=55)

	VehicleWeaponEffect=(Mesh=StaticMesh'Envy_Effects.Mesh.S_VH_Powerups',Material=MaterialInterface'Envy_Effects.Energy.Materials.M_VH_Beserk')
	PP_Scene_Highlights=(X=-0.15,Y=-0.08,Z=0.05)
}
