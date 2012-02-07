/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTPickupFactory extends UDKPickupFactory
	abstract;

var		Controller		TeamOwner[4];		// AI controller currently going after this pickup (for team coordination)


/** sound played when the pickup becomes available */
var SoundCue RespawnSound;

/** Sound played on base while available to pickup*/
var AudioComponent PickupReadySound;

/** The pickup's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/** Name used for the stats system */
var name PickupStatName;


var bool bHasLocationSpeech;

var Array<SoundNodeWave> LocationSpeech;

var float LastSeekNotificationTime;

var	ForceFeedbackWaveform	PickUpWaveForm;

simulated function PostBeginPlay()
{
	if ( bIsDisabled )
	{
		return;
	}

	Super.PostBeginPlay();

	bUpdatingPickup = (WorldInfo.NetMode != NM_DedicatedServer) && (bRotatingPickup || bFloatingPickup);
	if(Glow != none)
	{
		Glow.SetFloatParameter('LightStrength',0.0f);
		Glow.SetActive(true);
	}

	// Grab a reference to the material so we can adjust the parameter.  This adjustment occurs natively
	// in TickSpecial()
	if ( WorldInfo.NetMode != NM_DedicatedServer && BaseMesh != none && BaseMaterialParamName != '' )
	{
		BaseMaterialInstance = BaseMesh.CreateAndSetMaterialInstanceConstant(0);

		BaseTargetEmissive = bPickupHidden ? BaseDimEmissive : BaseBrightEmissive;
		BaseEmissive = BaseTargetEmissive;

		BaseMaterialInstance.SetVectorParameterValue( BaseMaterialParamName, BaseEmissive );
	}

	if(!bIsSuperItem && PickupReadySound != none)
	{
		PickupReadySound.Play();
	}

	// increase pickup radius on console
	if ( WorldInfo.bUseConsoleInput )
	{
		SetCollisionSize(1.5*CylinderComponent.CollisionRadius, CylinderComponent.CollisionHeight);
	}
}

simulated function SetResOut()
{
	if (bDoVisibilityFadeIn && MIC_Visibility != None)
	{
		MIC_Visibility.SetScalarParameterValue(VisibilityParamName, 1.f);
	}
}

simulated function DisablePickup()
{
	bIsDisabled = true;
	GotoState('Disabled');
}

simulated function ShutDown()
{
	DisablePickup();
}

/**
  * Look for changes in bPulseBase or bPickupHidden and set the TargetEmissive accordingly
  */
simulated function ReplicatedEvent(name VarName)
{
	if ( VarName == 'bIsDisabled' )
	{
		Global.SetInitialState();
	}
	else
	{
		if(VarName == 'bPickupHidden' && bPickupHidden)
		{
			setResOut();
		}
		if ( VarName == 'bPulseBase' || VarName == 'bPickupHidden' )
		{
			StartPulse((bPickupHidden && !bPulseBase) ? BaseDimEmissive : BaseBrightEmissive);
		}
		if(VarName == 'bIsRespawning' )
		{
			if(bIsRespawning)
			{
				RespawnEffect();
			}
		}
		Super.ReplicatedEvent(VarName);
	}
}

/**
  * Returns true if Bot should wait for me
  */
function bool ShouldCamp(UTBot B, float MaxWait)
{
	return ( ReadyToPickup(MaxWait) && (B.RatePickup(self, InventoryType) > 0) && !ReadyToPickup(0) );
}

/* UpdateHUD()
Called for the HUD of the player that picked it up
*/
simulated static function UpdateHUD(UTHUD H);

simulated function RespawnEffect()
{
	bIsRespawning = true;
	PlaySound(RespawnSound, true);
	if (PickupMesh != None)
	{
		PickupMesh.SetHidden(false);
	}
}

/* epic ===============================================
* ::StopsProjectile()
*
* returns true if Projectiles should call ProcessTouch() when they touch this actor
*/
simulated function bool StopsProjectile(Projectile P)
{
	local Actor HitActor;
	local vector HitNormal, HitLocation;

	if ( (P.CylinderComponent.CollisionRadius > 0) || (P.CylinderComponent.CollisionHeight > 0) )
	{
		// only collide if zero extent trace would also collide
		HitActor = Trace(HitLocation, HitNormal, P.Location, P.Location - 100*Normal(P.Velocity), true, vect(0, 0, 0));
		if ( HitActor != self )
			return false;
	}

	return bProjTarget || bBlockActors;
}


/**
 * Pulse to the Brightest point
 */
simulated function StartPulse(LinearColor TargetEmissive)
{
	if ( WorldInfo.NetMode != NM_DedicatedServer && BaseMesh != none && BaseMaterialParamName != '' )
	{
		BaseTargetEmissive = TargetEmissive;
		if ( BasePulseTime <= 0.0 )
		{
			BasePulseTime = BasePulseRate;
		}
		else
		{
			BasePulseTime = BasePulseRate - BasePulseTime;
		}
	}
}

auto state Pickup
{
	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		bPulseBase = false;
		StartPulse( BaseBrightEmissive );
    }
	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		bIsRespawning = false;
		SetResOut();
	}

}

State Sleeping
{
	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		bPulseBase = false;
		StartPulse( BaseDimEmissive );
		SetTimer( GetReSpawnTime() - PulseThreshold, false, 'PulseThresholdMet');
	}

	function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		ClearTimer('PulseThresholdMet');
	}

	function PulseThresholdMet()
	{
		bPulseBase = true;
		StartPulse(BaseBrightEmissive);
	}
}

simulated function SetPickupMesh()
{
	Super.SetPickupMesh();

	InitPickupMeshEffects();
}

/**
 * Stats
 */
function name GetPickupStatName()
{
	return (Default.PickupStatName != '') ? Default.PickupStatName : 'INVALID_PICKUPSTAT';
}

/** split out from SetPickupMesh() for subclasses that don't want to do the base PickupFactory implementation */
simulated event InitPickupMeshEffects()
{
	if ( PickupMesh != none )
	{
		PickupMesh.SetLightEnvironment(LightEnvironment);

		// Create a material instance for the pickup
		if (bDoVisibilityFadeIn && MeshComponent(PickupMesh) != None)
		{
			MIC_Visibility = MeshComponent(PickupMesh).CreateAndSetMaterialInstanceConstant(0);
			MIC_Visibility.SetScalarParameterValue(VisibilityParamName, bIsSuperItem ? 1.f : 0.f);
		}

		BobBaseOffset = PickupMesh.Translation.Y;
		if ( bRandomStart )
		{
			BobTimer = 1000 * frand();
		}
	}
}

simulated function SetPickupVisible()
{
	if(PickupReadySound != none)
	{
		PickupReadySound.Play();
	}

	if(Glow != none)
	{
		Glow.SetFloatParameter('LightStrength', 1.0f);
	}

	Super.SetPickupVisible();
}

simulated function SetPickupHidden()
{
	if(PickupReadySound != none)
	{
		PickupReadySound.Stop();
	}

	if(Glow != none)
	{
		Glow.SetFloatParameter('LightStrength',0.0f);
	}

	// need to hide also for low end video cards
	Super.SetPickupHidden();
}

simulated event SetInitialState()
{
	bScriptInitialized = true;

	if ( bIsDisabled )
	{
		GotoState('Disabled');
	}
	else
	{
		super.SetInitialState();
	}
}

function PickedUpBy(Pawn P)
{
	local UTBot B;
	local PlayerController PC;

	Super.PickedUpBy(P);

	// clear bot NoVehicleGoal so if it got out of vehicle to get a pickup it will consider getting back in now
	B = UTBot(P.Controller);
	if (B != None && B.NoVehicleGoal == self)
	{
		B.NoVehicleGoal = None;
	}

	PC = PlayerController(P.Controller);
	if(PC != None)
	{
		PC.ClientPlayForceFeedbackWaveform(PickUpWaveForm);
	}
}

State Disabled
{
	function float BotDesireability(Pawn P, Controller C)
	{
		return 0;
	}
}

defaultproperties
{
	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	Components.Remove(Arrow)
	GoodSprite=None
	BadSprite=None

	// setting bMovable=FALSE will break pickups and powerups that are on movers.
	// I guess once we get the LightEnvironment brightness issues worked out and if this is needed maybe turn this on?
	// will need to look at all maps and change the defaults for the pickups that move tho.
	bMovable=FALSE
    bStatic=FALSE

	RespawnSound=SoundCue'A_Pickups.Generic.Cue.A_Pickups_Generic_ItemRespawn_Cue'

	YawRotationRate=32768

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00040.000000
		CollisionHeight=+00044.000000
		CollideActors=true
	End Object

	// define here as lot of sub classes which have moving parts will utilize this
 	Begin Object Class=DynamicLightEnvironmentComponent Name=PickupLightEnvironment
 	    bDynamic=FALSE
 	    bCastShadows=FALSE
 	End Object
  	LightEnvironment=PickupLightEnvironment
  	Components.Add(PickupLightEnvironment)

	BasePulseRate=0.5
	PulseThreshold=5.0
	BaseMaterialParamName=BaseEmissiveControl

	Begin Object Class=StaticMeshComponent Name=BaseMeshComp
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightEnvironment=PickupLightEnvironment

		CollideActors=false
		MaxDrawDistance=7000
	End Object
	BaseMesh=BaseMeshComp
	Components.Add(BaseMeshComp)

	GlowEmissiveParam=LightStrength
	bDoVisibilityFadeIn=TRUE
	VisibilityParamName=ResIn

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformPickUp
		Samples(0)=(LeftAmplitude=80,RightAmplitude=30,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearIncreasing,Duration=0.20)
	End Object
	PickUpWaveForm=ForceFeedbackWaveformPickUp
}
