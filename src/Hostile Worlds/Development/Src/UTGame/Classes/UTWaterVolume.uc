/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTWaterVolume extends WaterVolume
	placeable;

/** effects to play based on what type of Actor you are **/
var ParticleSystem PS_EnterWaterEffect_Pawn;
var ParticleSystem PS_EnterWaterEffect_Vehicle;

var ParticleSystem ProjectileEntryEffect;

/**
 * We override this so we can play some water splash effects when a pawn enters the water
 *
 * NOTE: we don't differentiate between GroundSpeed and FallSpeed / AirSpeed
 **/
simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ParticleSystem PS_WaterEffect;
	local ParticleSystemComponent PSC_WaterEffect;
	local float MaxSpeed;
	local float Vel;
	local float ParamValue;
	local EMoveDir MoveDir;
	local vector ParticleVect;
	local UTPawn UTP;

	Super.Touch( Other, OtherComp, HitLocation, HitNormal );

	if (WorldInfo.NetMode != NM_DedicatedServer && (WorldInfo.TimeSeconds - Other.LastRenderTime < 0.2) && Pawn(Other) != None)
	{
		//DrawDebugCoordinateSystem( HitLocation, Rotator(HitNormal), 64.f );

		UTP = UTPawn(Other);

		if( UTP != none )
		{
			if ( (UTP.Physics == PHYS_Walking) || (UTP.Physics == PHYS_Swimming) )
			{
				// no splash when walking or swimming
				return;
			}
			PS_WaterEffect = PS_EnterWaterEffect_Pawn;
			ParamValue = 1.0;
			MaxSpeed = UTP.GroundSpeed;
		}
		else if( UTVehicle(Other) != none )
		{
			PS_WaterEffect = PS_EnterWaterEffect_Vehicle;
			MaxSpeed = UTVehicle(Other).GroundSpeed;
		}
		else
		{
			PS_WaterEffect = PS_EnterWaterEffect_Vehicle;
			ParamValue = 1.0;
			MaxSpeed = class'Pawn'.default.GroundSpeed;
		}

		PSC_WaterEffect = WorldInfo.MyEmitterPool.SpawnEmitter( PS_WaterEffect, HitLocation, Rotator(HitNormal), self );

		if( PSC_WaterEffect != none )
		{
			MoveDir = Other.MovingWhichWay( Vel );
			if ( ParamValue == 0.0 )
			{
				ParamValue = 5.0 * Vel/MaxSpeed;
			}

			// this is the value between 0 and 5 which the PS desires
			//`log( "MoveDir: " $ MoveDir $ " Vel: " $ Vel $ " ParamValue: " $ ParamValue );
			switch( MoveDir )
			{
			case MD_Forward: ParticleVect = vect(1,0,0) * ParamValue; break;
			case MD_Backward: ParticleVect = vect(-1,0,0) * ParamValue; break;
			case MD_Left: ParticleVect = vect(0,-1,0) * ParamValue; break;
			case MD_Right: ParticleVect = vect(0,1,0) * ParamValue; break;
			case MD_Down: ParticleVect = vect(1,0,0) * ParamValue; break;
			case MD_Up: ParticleVect = vect(1,0,0) * ParamValue; break;
			default:  break;
			}

			PSC_WaterEffect.SetVectorParameter( 'Direction', ParticleVect );
		}
	}
}

simulated function PlayEntrySplash(Actor Other)
{
	if( EntrySound != None )
	{
		Other.PlaySound(EntrySound);
		if ( Other.Instigator != None )
			Other.MakeNoise(1.0);
	}
	if ( !WorldInfo.bDropDetail && WorldInfo.NetMode != NM_DedicatedServer && Other.IsA('Projectile')
		&& (Other.Instigator != None) && Other.Instigator.IsPlayerPawn() && Other.Instigator.IsLocallyControlled() )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(ProjectileEntryEffect, Other.Location, rotator(vect(0,0,1)));
	}
}

defaultproperties
{
	TerminalVelocity=+01500.000000
	EntrySound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue'
	ExitSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue'

	ProjectileEntryEffect=ParticleSystem'Envy_Effects.Particles.P_WP_Water_Splash_Small'

// 	2.Keep the X axis always facing forward
//
// 	3.Set Particle Params:   Name:  Direction
// MinInput:     X:-5
// Y:-5
// Z: 0
//
// MaxInput:   X:5
// Y:5
// Z:0
//
//
//   X will be how much the VH is moving forward or backward.  If the VH is moving full speed forward set X to 5 if it is moving full speed backwards set X to -5.   Y axis is Left and right, Positive will be right negative is left.  Dont have to worry about Z axis.

	PS_EnterWaterEffect_Pawn=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Player_Water_Impact'
	PS_EnterWaterEffect_Vehicle=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_General_VH_Water_Impact'
}
