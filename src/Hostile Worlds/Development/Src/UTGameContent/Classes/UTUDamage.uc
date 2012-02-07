/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTUDamage extends UTTimedPowerup;

/** sound played when our owner fires */
var SoundCue UDamageFireSound;
/** sound played when the UDamage is running out */
var SoundCue UDamageFadingSound;
/** last time we played that sound, so it isn't too often */
var float LastUDamageSoundTime;
/** overlay material applied to owner */
var MaterialInterface OverlayMaterialInstance;
/** particle effect played on vehicle weapons */
var MeshEffect VehicleWeaponEffect;
/** ambient sound played while active*/
var SoundCue DamageAmbientSound;

simulated static function AddWeaponOverlay(UTGameReplicationInfo GRI)
{
	GRI.WeaponOverlays[0] = default.OverlayMaterialInstance;
	GRI.VehicleWeaponEffects[0] = default.VehicleWeaponEffect;
}

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	local UTPawn P;

	Super.GivenTo(NewOwner, bDoNotActivate);

	// boost damage
	NewOwner.DamageScaling *= 2.0;
	P = UTPawn(NewOwner);
	if (P != None)
	{
		// apply UDamage overlay
		P.SetWeaponOverlayFlag(0);
		P.SetPawnAmbientSound(DamageAmbientSound);

		// juggernaut if already has berserk or invulnerability
		if ( ((P.FireRateMultiplier < 1.0) || P.bIsInvulnerable) && (PlayerController(P.Controller) != None) )
		{
			PlayerController(P.Controller).ReceiveLocalizedMessage( class'UTPowerupRewardMessage', 0 );
		}
	}
	// set timer for ending sounds
	SetTimer(TimeRemaining - 3.0, false, 'PlayUDamageFadingSound');
}

function ItemRemovedFromInvManager()
{
	local UTPlayerReplicationInfo UTPRI;
	local UTPawn P;

	Pawn(Owner).DamageScaling *= 0.5;
	P = UTPawn(Owner);
	if (P != None)
	{
		P.ClearWeaponOverlayFlag( 0 );
		P.SetPawnAmbientSound(none);
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
	SetTimer(0.0, false, 'PlayUDamageFadingSound');
}

simulated function OwnerEvent(name EventName)
{
	if (EventName == 'FiredWeapon' && Instigator != None && WorldInfo.TimeSeconds - LastUDamageSoundTime > 0.25)
	{
		LastUDamageSoundTime = WorldInfo.TimeSeconds;
		Instigator.PlaySound(UDamageFireSound, false, true);
	}
}

/** called on a timer to play UDamage ending sound */
function PlayUDamageFadingSound()
{
	// reset timer if time got added
	if (TimeRemaining > 3.0)
	{
		SetTimer(TimeRemaining - 3.0, false, 'PlayUDamageFadingSound');
	}
	else
	{
		Instigator.PlaySound(UDamageFadingSound);
		SetTimer(0.75, false, 'PlayUDamageFadingSound');
	}
}


defaultproperties
{
	PowerupStatName=POWERUPTIME_UDAMAGE

	Begin Object Class=StaticMeshComponent Name=MeshComponentA
		StaticMesh=StaticMesh'Pickups.Udamage.Mesh.S_Pickups_UDamage'
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		bAcceptsLights=true
		CollideActors=false
		BlockRigidBody=false
		Scale3D=(X=0.6,Y=0.6,Z=0.6)
		MaxDrawDistance=8000
		Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	DroppedPickupMesh=MeshComponentA
	PickupFactoryMesh=MeshComponentA

	Begin Object Class=UTParticleSystemComponent Name=PickupParticles
		Template=ParticleSystem'Pickups.UDamage.Effects.P_Pickups_UDamage_Idle'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
		Translation=(X=0.0,Y=0.0,Z=+5.0)
	End Object
	DroppedPickupParticles=PickupParticles

	bReceiveOwnerEvents=true
	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_PickupCue'
	UDamageFireSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_FireCue'
	UDamageFadingSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_WarningCue'
	PowerupOverSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_EndCue'
	OverlayMaterialInstance=Material'Pickups.UDamage.M_UDamage_Overlay'
	DamageAmbientSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_PowerLoopCue'
	HudIndex=0
	IconCoords=(U=792,UL=43,V=41,VL=58)

	VehicleWeaponEffect=(Mesh=StaticMesh'Envy_Effects.Mesh.S_VH_Powerups',Material=MaterialInterface'Envy_Effects.Energy.Materials.M_VH_UDamage')
	PP_Scene_Highlights=(X=-0.1,Y=0.04,Z=-0.2)
}
