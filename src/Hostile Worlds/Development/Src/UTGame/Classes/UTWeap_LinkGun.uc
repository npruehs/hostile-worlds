/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_LinkGun extends UTBeamWeapon;

/** Holds the actor that this weapon is linked to. */
var Actor LinkedTo;
/** Holds the component we hit on the linked actor, for determining the linked beam endpoint on multi-component actors (such as Onslaught powernodes) */
var PrimitiveComponent LinkedComponent;

/** players holding link guns within this distance of each other automatically link up */
var float WeaponLinkDistance;

/** Holds the list of link guns linked to this weapon */
var array<UTWeap_LinkGun> LinkedList;	// I made a funny Hahahahah :)

/** Holds the Actor currently being hit by the beam */
var Actor	Victim;

/** Holds the current strength (in #s) of the link */
var repnotify int LinkStrength;

/** Holds the amount of flexibility of the link beam */
var float 	LinkFlexibility;

/** Holds the amount of time to maintain the link before breaking it.  This is important so that you can pass through
    small objects without having to worry about regaining the link */
var float 	LinkBreakDelay;

/** Momentum transfer for link beam (per second) */
var float	MomentumTransfer;

/** beam ammo consumption (per second) */
var float BeamAmmoUsePerSecond;

/** This is a time used with LinkBrekaDelay above */
var float	ReaccquireTimer;

/** true if beam currently hitting target */
var bool	bBeamHit;

/** whether link gun should auto-recharge */
var bool	bAutoCharge;

/** recharge rate in ammo per second */
var float RechargeRate;

/** saved partial damage (in case of high frame rate */
var float	SavedDamage;

/** saved partial ammo use */
var float SavedAmmoUse;

/** minimum SavedDamage before we actually apply it
 * (needs to be large enough to counter any scaling factors that might reduce to below 1)
 */
var float MinimumDamage;

/** Saved partial ammo consumption */
var float	PartialAmmo;

var MaterialInstanceConstant WeaponMaterialInstance;

var UTLinkBeamLight BeamLight;

var SoundCue StartAltFireSound;
var SoundCue EndAltFireSound;

var UTEmitter BeamEndpointEffect;

/** activated whenever we're linked to other players (LinkStrength > 1) */
var ParticleSystemComponent PoweredUpEffect;

/** socket to attach PoweredUpEffect to on our mesh */
var name PoweredUpEffectSocket;

/** Where beam that isn't hitting a target is currently attached */
var vector BeamAttachLocation;

/** Last time new beam attachment location was calculated */
var float  LastBeamAttachTime;

/** Normal for beam attachment */
var vector BeamAttachNormal;

/** Actor to which beam is being attached */
var actor  BeamAttachActor;

/** cached cast of attachment class for calling coloring functions */
var class<UTAttachment_LinkGun> LinkAttachmentClass;

var ParticleSystem TeamMuzzleFlashTemplates[3];
var ParticleSystem HighPowerMuzzleFlashTemplate;

/** True if have picked up link booster */
var repnotify bool bFullPower;

replication
{
	if (bNetDirty)
		LinkedTo, LinkStrength, bBeamHit, bFullPower;
}

simulated function PostBeginPlay()
{
	local color DefaultBeamColor, DefaultColor;
	local LinearColor LinColor;	

	Super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		SetTimer(0.25, true, 'FindLinkedWeapons');
	}

	LinkAttachmentClass = class<UTAttachment_LinkGun>(AttachmentClass);

	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
	{
		LinkAttachmentClass.static.GetTeamBeamInfo(255, DefaultBeamColor);
		WeaponMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(0);
		LinColor = ColorToLinearColor(DefaultBeamColor);
		WeaponMaterialInstance.SetVectorParameterValue('TeamColor', LinColor);
		LinColor = ColorToLinearColor(DefaultColor);
		WeaponMaterialInstance.SetVectorParameterValue('Paint_Color', LinColor);
	}
}

simulated function ParticleSystem GetTeamMuzzleFlashTemplate(byte TeamNum)
{
	if (TeamNum >= ArrayCount(default.TeamMuzzleFlashTemplates))
	{
		TeamNum = ArrayCount(default.TeamMuzzleFlashTemplates) - 1;
	}
	return default.TeamMuzzleFlashTemplates[TeamNum];
}

/**
 * Draw the Crosshairs
 */
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y,PickupScale, ScreenX, ScreenY, TargetDist;
	local UTHUDBase	H;

	H = UTHUDBase(HUD);
	if ( H == None )
		return;

	TargetDist = GetTargetDistance();
	// Apply pickup scaling
	if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.3 )
	{
		if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.15 )
		{
			PickupScale = (1 + 5 * (WorldInfo.TimeSeconds - H.LastPickupTime));
		}
		else
		{
			PickupScale = (1 + 5 * (H.LastPickupTime + 0.3 - WorldInfo.TimeSeconds));
		}
	}
	else
	{
		PickupScale = 1.0;
	}

 	CrosshairSize.Y = H.ConfiguredCrosshairScaling * CrosshairScaling * CrossHairCoordinates.VL * PickupScale * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( CrossHairCoordinates.UL / CrossHairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = H.BlackColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1, TargetDist);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);

		CrosshairColor = (LinkStrength > 1) ? H.Default.LightGoldColor : default.CrosshairColor;
		CrosshairColor = H.bGreenCrosshair ? H.Default.LightGreenColor : CrosshairColor;
		H.Canvas.DrawColor = (WorldInfo.TimeSeconds - LastHitEnemyTime < 0.3) ? H.RedColor : CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY, TargetDist);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);
	}
}

simulated function SetSkin(Material NewMaterial)
{
	Super.SetSkin(NewMaterial);

	if (NewMaterial == None && Mesh != None)
	{
		Mesh.SetMaterial(0, WeaponMaterialInstance);
	}
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	Super.AttachWeaponTo(MeshCpnt, SocketName);

	if (PoweredUpEffect != None && !PoweredUpEffect.bAttached && SkeletalMeshComponent(Mesh) != None)
	{
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(PoweredUpEffect, PoweredUpEffectSocket);
	}
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	local color BeamColor;
	local ParticleSystem BeamSystem, BeamEndpointTemplate, MuzzleFlashTemplate;
	local byte TeamNum;
	local LinearColor LinColor;

	if (LinkedTo != None)
	{
		FlashLocation = GetLinkedToLocation();
	}

	Super.UpdateBeamEmitter(FlashLocation, HitNormal, HitActor);

	if (LinkedTo != None && WorldInfo.GRI.GameClass.Default.bTeamGame)
	{
		TeamNum = Instigator.GetTeamNum();
		LinkAttachmentClass.static.GetTeamBeamInfo(TeamNum, BeamColor, BeamSystem, BeamEndpointTemplate);
		MuzzleFlashTemplate = GetTeamMuzzleFlashTemplate(TeamNum);
	}
	else if ( (LinkStrength > 1) || (Instigator.DamageScaling >= 2.0) )
	{
		BeamColor = LinkAttachmentClass.default.HighPowerBeamColor;
		BeamSystem = LinkAttachmentClass.default.HighPowerSystem;
		BeamEndpointTemplate = LinkAttachmentClass.default.HighPowerBeamEndpointTemplate;
		MuzzleFlashTemplate = HighPowerMuzzleFlashTemplate;
	}
	else
	{
		LinkAttachmentClass.static.GetTeamBeamInfo(255, BeamColor, BeamSystem, BeamEndpointTemplate);

		MuzzleFlashTemplate = GetTeamMuzzleFlashTemplate(255);
	}

	if ( BeamLight != None )
	{
		if ( HitNormal == vect(0,0,0) )
		{
			BeamLight.Beamlight.Radius = 48;
			if ( FastTrace(FlashLocation, FlashLocation-vect(0,0,32)) )
				BeamLight.SetLocation(FlashLocation - vect(0,0,32));
			else
				BeamLight.SetLocation(FlashLocation);
		}
		else
		{
			BeamLight.Beamlight.Radius = 32;
			BeamLight.SetLocation(FlashLocation + 16*HitNormal);
		}
		BeamLight.BeamLight.SetLightProperties(, BeamColor);
	}

	if (BeamEmitter[CurrentFireMode] != None)
	{
		BeamEmitter[CurrentFireMode].SetColorParameter('Link_Beam_Color', BeamColor);
		if (BeamEmitter[CurrentFireMode].Template != BeamSystem)
		{
			BeamEmitter[CurrentFireMode].SetTemplate(BeamSystem);
		}
	}

	if (MuzzleFlashPSC != None)
	{
		MuzzleFlashPSC.SetColorParameter('Link_Beam_Color', BeamColor);
		if (MuzzleFlashTemplate != MuzzleFlashPSC.Template)
		{
			MuzzleFlashPSC.SetTemplate(MuzzleFlashTemplate);
		}
	}
	if (UTLinkGunMuzzleFlashLight(MuzzleFlashLight) != None)
	{
		UTLinkGunMuzzleFlashLight(MuzzleFlashLight).SetTeam((LinkedTo != None && WorldInfo.GRI.GameClass.Default.bTeamGame) ? Instigator.GetTeamNum() : byte(255));
	}

	if (WeaponMaterialInstance != None)
	{
		LinColor = ColorToLinearColor(BeamColor);
		WeaponMaterialInstance.SetVectorParameterValue('TeamColor', LinColor);
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && Instigator != None && Instigator.IsFirstPerson())
	{
		if (BeamEndpointEffect != None && !BeamEndpointEffect.bDeleteMe)
		{
			BeamEndpointEffect.SetLocation(FlashLocation);
			BeamEndpointEffect.SetRotation(rotator(HitNormal));
			if (BeamEndpointEffect.ParticleSystemComponent.Template != BeamEndpointTemplate)
			{
				BeamEndpointEffect.SetTemplate(BeamEndpointTemplate, true);
			}
		}
		else
		{
			BeamEndpointEffect = Spawn(class'UTEmitter', self,, FlashLocation, rotator(HitNormal));
			BeamEndpointEffect.SetTemplate(BeamEndpointTemplate, true);
			BeamEndpointEFfect.LifeSpan = 0.0;
		}
		if(BeamEndpointEffect != none)
		{
			if(HitActor != none && UTPawn(HitActor) == none)
			{
				BeamEndpointEffect.SetFloatParameter('Touch',1);
			}
			else
			{
				BeamEndpointEffect.SetFloatParameter('Touch',0);
			}
		}
	}
}

function class<Projectile> GetProjectileClass()
{
	return (LinkStrength > 1) ? class'UTProj_LinkPowerPlasma' : Super.GetProjectileClass();
}

/**
 * When destroyed, make sure we clean ourselves from any chains
 */
simulated event Destroyed()
{
	super.Destroyed();
	Unlink();
	LinkedComponent = None;
	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}

	KillEndpointEffect();
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	if (BeamEmitter[CurrentFireMode] != None && bHide)
	{
		KillEndpointEffect();
	}
	Super.SetBeamEmitterHidden(bHide);
}

simulated function KillBeamEmitter()
{
	Super.KillBeamEmitter();

	KillEndpointEffect();
}

/** deactivates the beam endpoint effect, if present */
simulated function KillEndpointEffect()
{
	if (BeamEndpointEffect != None)
	{
		BeamEndpointEffect.ParticleSystemComponent.DeactivateSystem();
		BeamEndpointEffect.LifeSpan = 2.0;
		BeamEndpointEffect = None;
	}
}

function ConsumeAmmo( byte FireModeNum )
{
	if ( bAutoCharge && (Role == ROLE_Authority) )
	{
		SetTimer(RechargeRate+1.0, false, 'RechargeAmmo');
	}
	super.ConsumeAmmo(FireModeNum);
}

/** ConsumeBeamAmmo()
consume beam ammo per tick.
*/
function ConsumeBeamAmmo(float Amount)
{
	if ( bAutoCharge && (Role == ROLE_Authority) )
	{
		SetTimer(RechargeRate+1.0, false, 'RechargeAmmo');
	}
	PartialAmmo += Amount;
	if (PartialAmmo >= 1.0)
	{
		AddAmmo(-int(PartialAmmo));
		PartialAmmo -= int(PartialAmmo);
	}
}

function RechargeAmmo()
{
	if ( AmmoCount < MaxAmmoCount )
	{
		AmmoCount += 1;
		if ( AmmoCount < MaxAmmoCount )
		{
			SetTimer(RechargeRate, false, 'RechargeAmmo');
		}	
	}
}

/**
 * Process the hit info
 */
simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime)
{
	local float DamageAmount;
	local vector PushForce, ShotDir, SideDir; //, HitLocation, HitNormal, AttachDir;
	local UTPawn UTP;

	Victim = TestImpact.HitActor;

	// If we are on the server, attempt to setup the link
	if (Role == ROLE_Authority)
	{
		// Try linking
		AttemptLinkTo(Victim, TestImpact.HitInfo.HitComponent);

		// set the correct firemode on the pawn, since it will change when linked
		SetCurrentFireMode(CurrentFireMode);

		// if we do not have a link, set the flash location to whatever we hit
		// (if we do have one, AttemptLinkTo() will set the correct flash location for the Actor we're linked to)
		if (LinkedTo == None)
		{
			SetFlashLocation(TestImpact.HitLocation);
		}

		// cause damage or add health/power/etc.
		bBeamHit = false;

		// compute damage amount
		CalcLinkStrength();
		DamageAmount = InstantHitDamage[1];
		UTP = UTPawn(Instigator);
		if ( UTP != None )
		{
			DamageAmount = DamageAmount/UTP.FireRateMultiplier;
		}
		if ( LinkStrength > 1 )
		{
			DamageAmount *= FClamp(0.75*LinkStrength, 1.5, 2.0);
		}
		SavedDamage += DamageAmount * DeltaTime;
		DamageAmount = int(SavedDamage);
		SavedAmmoUse += BeamAmmoUsePerSecond * DeltaTime;
		if (DamageAmount >= MinimumDamage)
		{
			SavedDamage -= DamageAmount;
			if (LinkedTo != None)
			{
				// heal them if linked
				// linked players will use ammo when they fire
				if (!LinkedTo.IsA('UTPawn'))
				{
					if (LinkedTo.IsA('UTVehicle') || LinkedTo.IsA('UTGameObjective'))
					{
						// use ammo only if we actually healed some damage
						if ( LinkedTo.HealDamage(DamageAmount * Instigator.GetDamageScaling(), Instigator.Controller, InstantHitDamageTypes[1]) )
							ConsumeBeamAmmo(SavedAmmoUse);
					}
					else
					{
						// otherwise always use ammo
						ConsumeBeamAmmo(SavedAmmoUse);
					}
				}
			}
			else
			{
				// If not on the same team, hurt them
				ConsumeBeamAmmo(SavedAmmoUse);
				if (Victim != None && !WorldInfo.Game.GameReplicationInfo.OnSameTeam(Victim, Instigator))
				{
					bBeamHit = !Victim.bWorldGeometry;
					if ( DamageAmount > 0 )
					{
						ShotDir = Normal(TestImpact.HitLocation - Location);
						SideDir = Normal(ShotDir Cross vect(0,0,1));
						PushForce =  vect(0,0,1) + Normal(SideDir * (SideDir dot (TestImpact.HitLocation - Victim.Location)));
						PushForce *= (Victim.Physics == PHYS_Walking) ? 0.1*MomentumTransfer : DeltaTime*MomentumTransfer;
						Victim.TakeDamage(DamageAmount, Instigator.Controller, TestImpact.HitLocation, PushForce, InstantHitDamageTypes[1], TestImpact.HitInfo, self);
					}
				}
			}
			SavedAmmoUse = 0.0;
		}
	}
	else
	{
		// if we do not have a link, set the flash location to whatever we hit
		// (otherwise beam update will override with link location)
		if (LinkedTo == None)
		{
			SetFlashLocation(TestImpact.HitLocation);
		}
		else if (TestImpact.HitActor == LinkedTo && TestImpact.HitInfo.HitComponent != None)
		{
			// the linked component can't be replicated to the client, so set it here
			LinkedComponent = TestImpact.HitInfo.HitComponent;
		}
		if (Victim != None && (Victim.Role == ROLE_Authority) )
		{
			bBeamHit = !Victim.bWorldGeometry;
			if ( DamageAmount > 0 )
			{
				ShotDir = Normal(TestImpact.HitLocation - Location);
				SideDir = Normal(ShotDir Cross vect(0,0,1));
				PushForce =  vect(0,0,1) + Normal(SideDir * (SideDir dot (TestImpact.HitLocation - Victim.Location)));
				PushForce *= (Victim.Physics == PHYS_Walking) ? 0.1*MomentumTransfer : DeltaTime*MomentumTransfer;
				Victim.TakeDamage(DamageAmount, Instigator.Controller, TestImpact.HitLocation, PushForce, InstantHitDamageTypes[1], TestImpact.HitInfo, self);
			}
		}
	}
}

/**
 * Returns a vector that specifics the point of linking.
 */
simulated function vector GetLinkedToLocation()
{
	local vector BestLoc;
	local vector Loc,ToTarget;
	local bool bHitVehicleAimingAt;
	local vector HitLocation, HitNormal;

	if (LinkedTo == None)
	{
		return vect(0,0,0);
	}
	else if( UTVehicle(LinkedTo) != none )
	{
		if (Mesh.bAttached)
		{
			// so we trace from gun tip to the vehicle's GetTargetLocation() and then at hit set that to be BestLoc
			UDKSkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( 'MuzzleFlashSocket', Loc );
		}
		else
		{
			Loc = Instigator.GetPawnViewLocation();
		}
		ToTarget = UTVehicle(LinkedTo).GetTargetLocation();

		// if we didn't it the legs so maybe we hit the body or it wasn't a Walker at all!
		if( !bHitVehicleAimingAt )
		{
			bHitVehicleAimingAt = TraceComponent( HitLocation, HitNormal, UTVehicle(LinkedTo).Mesh, ToTarget, Loc,, );
		}

		// check here to make certain we hit what we were tracing
		if( bHitVehicleAimingAt )
		{
			BestLoc = HitLocation;
		}
		// else something terrible occurred so we will just have the effect be on the MuzzleFlashSocket otherwise it will bend around and look bad
		else
		{
			BestLoc = Loc;
		}

		return BestLoc;
	}
	else if (Pawn(LinkedTo) != None)
	{
		return LinkedTo.Location + Pawn(LinkedTo).BaseEyeHeight * vect(0,0,0.5);
	}
	else if (LinkedComponent != None)
	{
		return LinkedComponent.GetPosition();
	}
	else
	{
		return LinkedTo.Location;
	}
}

/**
 * This function looks at how the beam is hitting and determines if this person is linkable
 */
function AttemptLinkTo(Actor Who, PrimitiveComponent HitComponent)
{
	local UTVehicle UTV;
	local Vector 		StartTrace, EndTrace, V, HitLocation, HitNormal;
	local Actor			HitActor;

	// redirect to vehicle if owned by a vehicle and the vehicle allows it
	if( Who != none )
	{
		UTV = UTVehicle(Who.Owner);
		if (UTV != None && UTV.AllowLinkThroughOwnedActor(Who))
		{
			Who = UTV;
		}
	}

	// Check for linking to pawns
	UTV = UTVehicle(Who);
	if (UTV != None && UTV.bValidLinkTarget)
	{
		// Check teams to make sure they are on the same side or empty
		if ( WorldInfo.Game.GameReplicationInfo.OnSameTeam(UTV,Instigator) || (!UTV.bTeamLocked && UTV.CanEnterVehicle(Instigator)) )
		{
			if ( !WorldInfo.Game.GameReplicationInfo.OnSameTeam(UTV,Instigator)
				&& (Instigator.GetTeamNum() != 255) )
			{
				UTV.SetTeamNum( Instigator.GetTeamNum() );
			}
			LinkedComponent = HitComponent;
			if ( LinkedTo != UTV )
			{
				UnLink();
				LinkedTo = UTV;
				UTV.IncrementLinkedToCount();
			}
		}
		else
		{
			// Enemy got in the way, break any links
			UnLink();
		}
	}

	if (LinkedTo != None)
	{
		// Determine if the link has been broken for another reason
		if (LinkedTo.bDeleteMe || (Pawn(LinkedTo) != None && Pawn(LinkedTo).Health <= 0))
		{
			UnLink();
			return;
		}

		// if we were passed in LinkedTo, we know we hit it straight on already, so skip the rest
		if (LinkedTo != Who)
		{
			StartTrace = Instigator.GetWeaponStartTraceLocation();
			EndTrace = GetLinkedtoLocation();

			// First, check to see if we have skewed too much, or if the LinkedTo pawn has died and
			// we didn't get cleaned up.
			V = Normal(EndTrace - StartTrace);
			if ( V dot vector(Instigator.GetViewRotation()) < LinkFlexibility || VSize(EndTrace - StartTrace) > 1.5 * WeaponRange )
			{
				UnLink();
				return;
			}

			//  If something is blocking us and the actor, drop the link
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			if (HitActor != none && HitActor != LinkedTo)
			{
				UnLink(true);		// In this case, use a delayed UnLink
			}
		}
	}

	// if we are linked, make sure the proper flash location is set
	if (LinkedTo != None)
	{
		SetFlashLocation(GetLinkedtoLocation());
	}
}

/**
 * Unlink this weapon from it's parent.  If bDelayed is true, it will give a
 * short delay before unlinking to allow the player to re-establish the link
 */
function UnLink(optional bool bDelayed)
{
	local UTVehicle V;

	if (!bDelayed)
	{
		V = UTVehicle(LinkedTo);
		if(V != none)
		{
			V.DecrementLinkedToCount();
		}
		LinkedTo = None;
		LinkedComponent = None;
	}
	else if (ReaccquireTimer <= 0)
	{
		// Set the Delay timer
		ReaccquireTimer = LinkBreakDelay;
	}
}

/** checks for nearby friendly link gun users and links to them */
function FindLinkedWeapons()
{
	local UTPawn P;
	local UTWeap_LinkGun Link;

	LinkedList.length = 0;
	if (Instigator != None && (bReadyToFire() || IsFiring()))
	{
		foreach WorldInfo.AllPawns(class'UTPawn', P, Instigator.Location, WeaponLinkDistance)
		{
			if (P != Instigator && !P.bNoWeaponFiring && P.DrivenVehicle == None)
			{
				Link = UTWeap_LinkGun(P.Weapon);
				if (Link != None && WorldInfo.GRI.OnSameTeam(Instigator, P) && FastTrace(P.Location, Instigator.Location))
				{
					LinkedList[LinkedList.length] = Link;
				}
			}
		}
	}
	CalcLinkStrength();

	if (WorldInfo.NetMode != NM_DedicatedServer && PoweredUpEffect != None)
	{
		if (LinkStrength > 1)
		{
			if (!PoweredUpEffect.bIsActive)
			{
				PoweredUpEffect.ActivateSystem();
			}
		}
		else if (PoweredUpEffect.bIsActive)
		{
			PoweredUpEffect.DeactivateSystem();
		}
	}
}

/** gets a list of the entire link chain */
function GetLinkedWeapons(out array<UTWeap_LinkGun> LinkedWeapons)
{
	local int i;

	LinkedWeapons[LinkedWeapons.length] = self;
	for (i = 0; i < LinkedList.length; i++)
	{
		if (LinkedWeapons.Find(LinkedList[i]) == INDEX_NONE)
		{
			LinkedList[i].GetLinkedWeapons(LinkedWeapons);
		}
	}
}

/** this function figures out the strength of this link */
function CalcLinkStrength()
{
	local array<UTWeap_LinkGun> LinkedWeapons;

	GetLinkedWeapons(LinkedWeapons);
	LinkStrength = LinkedWeapons.length;
}

simulated function ChangeVisibility(bool bIsVisible)
{
	Super.ChangeVisibility(bIsVisible);

	if (PoweredUpEffect != None)
	{
		PoweredUpEffect.SetHidden(!bIsVisible);
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'LinkStrength')
	{
		if (LinkStrength > 1)
		{
			if (!PoweredUpEffect.bIsActive)
			{
				PoweredUpEffect.ActivateSystem();
			}
		}
		else if (PoweredUpEffect.bIsActive)
		{
			PoweredUpEffect.DeactivateSystem();
		}
	}
	else if ( VarName == 'bFullPower' )
	{
		if ( bFullPower )
			BoostPower();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/*********************************************************************************************
 * State WeaponFiring
 * See UTWeapon.WeaponFiring
 *********************************************************************************************/

simulated state WeaponBeamFiring
{
	/**
	 * When done firing, we have to make sure we unlink the weapon.
	 */
	simulated function EndFire(byte FireModeNum)
	{
		UnLink();
		super.EndFire(FireModeNum);
	}

	simulated function SetCurrentFireMode(byte FiringModeNum)
	{
		local byte InstigatorFireMode;

		CurrentFireMode = FiringModeNum;

		// on the pawn, set a value of 2 if we're linked so the weapon attachment knows the difference
		// and a value of 3 if we're not linked to anyone but others are linked to us
		if (Instigator != None)
		{
			if (CurrentFireMode == 1)
			{
				if (LinkedTo != None)
				{
					InstigatorFireMode = 2;
				}
				else
				{
					CalcLinkStrength();
					if ( (LinkStrength > 1) || (Instigator.DamageScaling >= 2.0) )
					{
						if ( bBeamHit )
							InstigatorFireMode = 4;
						else
							InstigatorFireMode = 3;
					}
					else
					{
						if ( bBeamHit )
							InstigatorFireMode = 5;
						else
							InstigatorFireMode = CurrentFireMode;
					}
				}
			}
			else
			{
				InstigatorFireMode = CurrentFireMode;
			}

			Instigator.SetFiringMode(Self, InstigatorFireMode);
		}
	}

	function SetFlashLocation(vector HitLocation)
	{
		Global.SetFlashLocation(HitLocation);
		// SetFlashLocation() resets Instigator's FiringMode so we need to make sure our overridden value stays applied
		SetCurrentFireMode(CurrentFireMode);
	}

	/**
	 * Update the beam and handle the effects
	 * FIXMESTEVE MOVE TO TICKSPECIAL
	 */
	simulated function Tick(float DeltaTime)
	{
		// If we are in danger of losing the link, check to see if
		// time has run out.
		if ( ReaccquireTimer > 0 )
		{
	    		ReaccquireTimer -= DeltaTime;
	    		if (ReaccquireTimer <= 0)
	    		{
		    		ReaccquireTimer = 0.0;
		    		UnLink();
		    	}
		}

		// Retrace everything and see if there is a new LinkedTo or if something has changed.
		UpdateBeam(DeltaTime);
	}

	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if ( (PlayerController(Instigator.Controller) != None) && Instigator.IsLocallyControlled() && ((BeamLight == None) || BeamLight.bDeleteMe) )
		{
			BeamLight = spawn(class'UTLinkBeamLight');
		}

		WeaponPlaySound(StartAltFireSound);
	}

	simulated function EndState(Name NextStateName)
	{
		local color EffectColor;
		local LinearColor LinEffectColor;

		WeaponPlaySound(EndAltFireSound);

		Super.EndState(NextStateName);

		if ( BeamLight != None )
			BeamLight.Destroy();

		ReaccquireTimer = 0.0;
		UnLink();
		Victim = None;

		// reset material and muzzle flash to default color
		LinkAttachmentClass.static.GetTeamBeamInfo(255, EffectColor);
		if (WeaponMaterialInstance != None)
		{
			LinEffectColor = ColorToLinearColor(EffectColor);
			WeaponMaterialInstance.SetVectorParameterValue('TeamColor', LinEffectColor);
		}
		if (MuzzleFlashPSC != None)
		{
			MuzzleFlashPSC.ClearParameter('Link_Beam_Color');
		}
	}


	/** You can run around spamming the beam and needing to look around all speed **/
	simulated function bool CanViewAccelerationWhenFiring()
	{
		return TRUE;
	}
}

simulated state WeaponPuttingDown
{
	simulated function WeaponIsDown()
	{
		// make sure we're completely unlinked before we change weapons
		Unlink();
		LinkedList.length = 0;

		Super.WeaponIsDown();
	}
}


//-----------------------------------------------------------------
// AI Interface

function float GetAIRating()
{
	local UTBot B;
	local UTVehicle V;
	local UTGameObjective O;
	local float Dist;

	B = UTBot(Instigator.Controller);
	if (B == None || B.Squad == None)
	{
		return AIRating;
	}

	V = UTSquadAI(B.Squad).GetLinkVehicle(B);
	if ( (V != None)
		&& (VSize(Instigator.Location - V.Location) < 1.5 * WeaponRange)
		&& (V.Health < V.HealthMax) && (V.LinkHealMult > 0) )
	{
		return 1.2;
	}

	V = UTVehicle(B.RouteGoal);
	if ( (V != None) && (B.Enemy == None) && (VSize(Instigator.Location - B.RouteGoal.Location) < 1.5 * WeaponRange)
	     && V.TeamLink(B.GetTeamNum()) )
	{
		return 1.2;
	}

	O = UTGameObjective(B.Squad.SquadObjective);
	if (O != None && O.TeamLink(B.GetTeamNum()) && O.NeedsHealing()
	     && VSize(Instigator.Location - O.Location) < 1.1 * GetTraceRange() && B.LineOfSightTo(O))
	{
		return 1.2;
	}

	if ( B.Enemy != None )
	{
		Dist = VSize(B.Enemy.Location - Instigator.Location);
		if ( Dist > 3500 )
		{
			return AIRating * 3500/Dist;
		}
	}

	return AIRating * FMin(Pawn(Owner).GetDamageScaling(), 1.5);
}

function bool FocusOnLeader(bool bLeaderFiring)
{
	local UTBot B;
	local UTVehicle LinkVehicle;
	local Actor Other;
	local vector HitLocation, HitNormal, StartTrace;
	local Controller SquadLeader;
	
	B = UTBot(Instigator.Controller);
	if ( B == None || B.Squad == None )
	{
		return false;
	}
	SquadLeader = UTSquadAI(B.Squad).SquadLeader;
	if ( SquadLeader == None )
	{
		return false;
	}
	if ( PlayerController(SquadLeader) != None )
	{
		LinkVehicle = UTVehicle(SquadLeader.Pawn);
	}
	else
	{
		LinkVehicle = UTSquadAI(B.Squad).GetLinkVehicle(B);
	}
	if ( LinkVehicle == None )
	{
		LinkVehicle = UTVehicle(SquadLeader.Pawn);
		if ( LinkVehicle == None )
		{
			return false;
		}
	}
	if ( ((B.Enemy != None) && !LinkVehicle.bKeyVehicle) || (LinkVehicle.Health >= LinkVehicle.HealthMax) || (LinkVehicle.LinkHealMult <= 0) )
	{
		return false;
	}
	StartTrace = Instigator.GetPawnViewLocation();
	if (VSize(LinkVehicle.Location - StartTrace) < GetTraceRange())
	{
		Other = Trace(HitLocation, HitNormal, LinkVehicle.GetTargetLocation(), StartTrace, true);
		if ( Other == LinkVehicle )
		{
			B.Focus = Other;
			return true;
		}
	}
	return false;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float EnemyDist;
	local UTBot B;
	local UTVehicle V;
	local UTGameObjective ObjTarget;

	// currently no beams on mobile devices, so disallow the alt-fire
	if (WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
	{
		return 0;
	}

	B = UTBot(Instigator.Controller);
	if ( B == None )
	{
		return 0;
	}

	ObjTarget = UTGameObjective(B.Focus);
	if ( (ObjTarget != None) && ObjTarget.TeamLink(B.GetTeamNum()) )
	{
		return 1;
	}
	if ( FocusOnLeader(B.Focus == UTSquadAI(B.Squad).SquadLeader.Pawn) )
	{
		return 1;
	}

	V = UTVehicle(B.Focus);
	if ( (V != None) && WorldInfo.GRI.OnSameTeam(B,V) )
	{
		return 1;
	}
	if ( B.Enemy == None )
	{
		return 0;
	}
	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( EnemyDist > WeaponRange )
	{
		return 0;
	}
	return 1;
}

function bool CanHeal(Actor Other)
{
	if (!HasAmmo(1))
	{
		return false;
	}
	else if (UTGameObjective(Other) != None)
	{
		return UTGameObjective(Other).TeamLink(Instigator.GetTeamNum());
	}
	else
	{
		return (UTVehicle(Other) != None && UTVehicle(Other).LinkHealMult > 0.f);
	}
}

function float GetOptimalRangeFor(Actor Target)
{
	// return alt beam range if shooting at teammate (healing/linking)
	return (WorldInfo.GRI.OnSameTeam(Target, Instigator) ? WeaponRange : Super.GetOptimalRangeFor(Target));
}

function float SuggestAttackStyle()
{
	return 0.8;
}

function float SuggestDefenseStyle()
{
	return -0.4;
}

/**
 * Detect that we are trying to pickup another link gun and switch to full power
 */
function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	if ( ItemClass==Class )
	{
		BoostPower();
	}
	return super.DenyPickupQuery(ItemClass, Pickup);
}

/** 
  * Increase weapon power (after picking up Link Booster) 
  */
simulated function BoostPower()
{
	AIRating = 0.71;
	CurrentRating = 0.71;
	FireInterval[0] = 0.16;
	WeaponRange = 900;
	bFullPower = true;
	if ( WeaponMaterialInstance != None )
	{
		WeaponMaterialInstance.SetVectorParameterValue('Paint_Color', class'UTHUD'.default.WhiteLinearColor);
	}
}

simulated state WeaponEquipping
{
	simulated event BeginState(Name PreviousStateName)
	{
		local LinearColor TeamColor;

		super.BeginState(PreviousStateName);

		// if not full power, and team game, team color the linkgun
		if ( !bFullPower && (WorldInfo.GRI != None) && WorldInfo.GRI.GameClass.default.bTeamGame 
			&& (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
		{
			if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
			{
				TeamColor.R = 0.2;
			}
			else
			{
				TeamColor.B = 0.4;
			}
			WeaponMaterialInstance.SetVectorParameterValue('Paint_Color', TeamColor);
		}
	}
}

defaultproperties
{
	WeaponColor=(R=255,G=255,B=0,A=255)
	FireInterval(0)=+0.24
	FireInterval(1)=+0.35
	PlayerViewOffset=(X=16.0,Y=-18,Z=-18.0)

	FiringStatesArray(1)=WeaponBeamFiring

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
		AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
		Animations=MeshSequenceA
		Scale=0.9
		FOV=60.0
	End Object

	AttachmentClass=class'UTAttachment_Linkgun'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
	End Object

	Begin Object Class=ParticleSystemComponent Name=PoweredUpComponent
		Template=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_PoweredUp'
		bAutoActivate=false
		DepthPriorityGroup=SDPG_Foreground
		SecondsBeforeInactive=1.0f
	End Object
	PoweredUpEffect=PoweredUpComponent
	PoweredUpEffectSocket=PowerEffectSocket

	FireOffset=(X=12,Y=10,Z=-10)

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_LinkPlasma' // UTProj_LinkPowerPlasma if linked (see GetProjectileClass() )

	WeaponEquipSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_LowerCue'
	WeaponFireSnd(0)=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue'
	WeaponFireSnd(1)=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireCue'

	MaxDesireability=0.7
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=true
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	InventoryGroup=1
	GroupWeight=0.5
	bAutoCharge=true
	RechargeRate=1.0

	WeaponRange=500
	LinkStrength=1
	LinkFlexibility=0.64	// determines how easy it is to maintain a link.
							// 1=must aim directly at linkee, 0=linkee can be 90 degrees to either side of you

	LinkBreakDelay=0.5		// link will stay established for this long extra when blocked (so you don't have to worry about every last tree getting in the way)
	WeaponLinkDistance=160.0

	InstantHitDamage(1)=100
	InstantHitDamageTypes(1)=class'UTDmgType_LinkBeam'

	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Link_Cue'

	AmmoCount=100
	LockerAmmoCount=100
	MaxAmmoCount=100
	MomentumTransfer=50000.0
	BeamAmmoUsePerSecond=8.5
	MinimumDamage=5.0

	EffectSockets(0)=MuzzleFlashSocket
	EffectSockets(1)=MuzzleFlashSocket

	BeamPreFireAnim(1)=WeaponAltFireStart
	BeamFireAnim(1)=WeaponAltFire
	BeamPostFireAnim(1)=WeaponAltFireEnd

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	MuzzleFlashAltPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam'
	bMuzzleFlashPSCLoops=true
	MuzzleFlashLightClass=class'UTGame.UTLinkGunMuzzleFlashLight'

	bShowAltMuzzlePSCWhenWeaponHidden=TRUE

	TeamMuzzleFlashTemplates[0]=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Red'
	TeamMuzzleFlashTemplates[1]=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Blue'
	TeamMuzzleFlashTemplates[2]=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam'
	HighPowerMuzzleFlashTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Gold'

	MuzzleFlashColor=(R=120,G=255,B=120,A=255)
	MuzzleFlashDuration=0.33;

	BeamTemplate[1]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'
	BeamSockets[1]=MuzzleFlashSocket02
	EndPointParamName=LinkBeamEnd

	IconX=412
	IconY=82
	IconWidth=40
	IconHeight=36

	StartAltFireSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireStartCue'
	EndAltFireSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireStopCue'
	CrossHairCoordinates=(U=384,V=0,UL=64,VL=64)

	LockerRotation=(pitch=0,yaw=0,roll=-16384)
	IconCoordinates=(U=453,V=467,UL=147,VL=41)

	Begin Object Class=ForceFeedbackWaveform Name=BeamForceFeedbackWaveform1
		Samples(0)=(LeftAmplitude=20,RightAmplitude=10,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.100)
		bIsLooping=TRUE
	End Object
	BeamWeaponFireWaveForm=BeamForceFeedbackWaveform1
}
