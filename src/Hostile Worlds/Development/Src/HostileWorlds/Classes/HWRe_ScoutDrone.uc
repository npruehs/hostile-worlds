// ============================================================================
// HWRe_ScoutDrone
// A scout drone reinforcements unit of Hostile Worlds.
//
// Author:  Marcel Koehler 
// Date:    2011/04/15
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWRe_ScoutDrone extends HWReinforcement;

///** The particle system to be shown while this unit is active. */
//var ParticleSystemComponent PscActive;

//function Initialize(HWMapInfoActor TheMap, optional Actor A)
//{
//	super.Initialize(TheMap, A);
	
//	Activate();
//}

//simulated function OnOwningPlayerRIChanged()
//{
//	if(OwningPlayerRI != none)
//	{
//		Activate();
//	}
//}

///** Activates the particle system corresponding to the team. */
//simulated function Activate()
//{
//	PscActive = new(self) class'ParticleSystemComponent';  // move this to the object pool once it can support attached to bone/socket and relative translation/rotation

//	if (OwningPlayerRI.Team.GetTeamNum() == 0)
//	{
//		PscActive.SetTemplate(ActivatedTemplateTeam1);
//	}
//	else
//	{
//		PscActive.SetTemplate(ActivatedTemplateTeam2);
//	}

//	PscActive.ActivateSystem(true);

//	AttachComponent(PscActive);
//}

//simulated function Destroyed()
//{
//	super.Destroyed();

//	PscActive.DeactivateSystem();
//	PscActive.SetHidden(true);

//	if (OwningPlayerRI.Team.GetTeamNum() == 0)
//	{
//		WorldInfo.MyEmitterPool.SpawnEmitter(DestroyedTemplateTeam1, Location);
//	}
//	else
//	{
//		WorldInfo.MyEmitterPool.SpawnEmitter(DestroyedTemplateTeam2, Location);
//	}
//}

DefaultProperties
{
	//AnimDurationDeath=0.1f

	//ActivatedTemplateTeam1=ParticleSystem'VH_Scorpion.Effects.P_Scorpion_Bounce_Projectile';
	//ActivatedTemplateTeam2=ParticleSystem'VH_Scorpion.Effects.P_Scorpion_Bounce_Projectile_Red'

	//DestroyedTemplateTeam1=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_Impact'
	//DestroyedTemplateTeam2=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_Impact_Red'

	bImmuneToKnockbacks=false
	bBlinded=true

	SoundSelected=SoundCue'A_Test_Voice_Units.ScoutDroneSelected_Cue'
	SoundOrderConfirmed=SoundCue'A_Test_Voice_Units.ScoutDroneOrderConfirmed_Cue'
	SoundDied=SoundCue'A_Test_Voice_Units.ScoutDroneDied_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_ScoutDrone_Test'

	//PrefabToLoad=Prefab'scout_drone.Prefab_scout_drone'

	Begin Object Class=StaticMeshComponent Name=Mesh
	    CastShadow=true
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		CollideActors=false
		BlockActors=true
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		Scale=1.0
		MaxDrawDistance=4000
		StaticMesh=StaticMesh'scout_drone.drone'
		Translation=(X=0,Y=0,Z=0)
	End Object
	Components.Add(Mesh)

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

	bPlayGibSounds=false
}
