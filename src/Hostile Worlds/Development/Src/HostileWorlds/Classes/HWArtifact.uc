// ============================================================================
// HWArtifact
// A collectable artifact of Hostile Worlds.
//
// Author:  Marcel Koehler, Nick Pruehs
// Date:    2010/10/13
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWArtifact extends HWGameObject
	placeable;

/** Whether this artifact can (still) be collected this round. */
var repnotify bool bAvailable;

/** ArtifactManager controlling this artifact. This reference is required to raise an event on the ArtifactManager if the artifact is acquired. */
var HWArtifactManager ArtifactManager;

/** The effects that are displayed as long as this artifact is available. */
var array<HWEffect_ArtifactAvailable> EffectsAvailable;

/** The area around this artifact where Commanders can't respawn. */
var HWDe_SpawnProtectionArea SpawnProtectionArea;

/** 
 *  The rounds this artifact shall be active in the cycle.
 *  Caution: the highest number can't be higher than HWMapInfoActor.ArtifactCycleRoundsTotal. 
 *  Example: 1, 3 (of 5 total cycle rounds).
 */
var() Array<int> CycleRoundsActive;

/** The light emitted by the artifact if active. */
var() PointLightComponent Light;

/** 
 *  The name of the artifact head tag. Required to find all artifact head mesh components in the prefab from code. 
 *  This can only be a substring of the actual tag name (e.g. kopf in kopf1).
 */
var() name TagHead;

/** 
 *  The name of the particle emitter tag. Required to find all emitters in the prefab from code. 
 *  This can only be a substring of the actual tag name (e.g. pollen in pollen1).
 */
var() name TagEmitter;

/** The mesh components of all artifact heads in the prefab. */
var array<StaticMeshComponent> Heads;

/** The number of victory points a team gets for harvesting this artifact. */
var int VictoryPoints;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnProtectionArea = Spawn(class'HWDe_SpawnProtectionArea');
}

/**
 * Checks if this artifact can be activated in the given CurrentCycleRound.
 */
function bool CanBeActivated(int CurrentCycleRound)
{
	local int CycleRoundActive;

	foreach CycleRoundsActive(CycleRoundActive)
	{
		if(CurrentCycleRound == CycleRoundActive)
		{
			return true;
		}
	}

	return false;
}

/** Sets the Artifacts availability to true and shows the effect. */
simulated function Activate()
{
	local StaticMeshComponent SMC;
	local HWEffect_ArtifactAvailable hwEffect;

	bAvailable = true;

	Light.SetEnabled(true);

	foreach Heads(SMC)
	{
		SMC.SetHidden(false);
	}

	foreach EffectsAvailable(hwEffect)
	{
		hwEffect.Show();
	}
}

/** Sets the Artifacts availability to false and hides the effect. */
simulated function Deactivate()
{
	local StaticMeshComponent SMC;
	local HWEffect_ArtifactAvailable hwEffect;

	bAvailable = false;

	Light.SetEnabled(false);

	foreach Heads(SMC)
	{
		SMC.SetHidden(true);
	}

	foreach EffectsAvailable(hwEffect)
	{
		hwEffect.Hide();
	}
}

/**
 * Deactivates the acquired artifact and notifies the ArtifactManager that an artifact has been acquired.
 * 
 * @param SquadMember
 *      the squad member that succeeded in acquiring an artifact
 */
function AcquiredBy(HWSquadMember SquadMember)
{
	Deactivate();

	ArtifactManager.ArtifactAcquiredBy(self, SquadMember);
}

/** Artifacts shall only be shown on the mini map if they are available. */
simulated function bool ShowOnMiniMap()
{
	return bAvailable;
}

simulated function string GetAdditionalInfo()
{
	if (bAvailable)
	{
		return "Victory Points: "$VictoryPoints;
	}
	else
	{
		return "This artifact is not available.";
	}
}

simulated function Destroyed()
{
	local HWEffect_ArtifactAvailable hwEffect;

	super.Destroyed();

	// destroy all effects if this artifact is destroyed
	foreach EffectsAvailable(hwEffect)
	{
		hwEffect.Destroy();
	}
}

/** 
 *  Overriding the base implementation in order
 *  to prevent the default destruction of this artifact.
 */
function Reset()
{
}

/**
 * Extending LoadPrefab in order to add the particle emitters included in the artifact prefab.
 */
simulated function LoadPrefab(Prefab LocalPrefab, bool bPhysicsEnabled, optional Vector Translation)
{
	local int a, b;
	local Emitter e;
	local string Index;
	local StaticMeshActor ArtifactHead;
	local HWEffect_ArtifactAvailable Effect;

	// Deactivate collision of all meshes for HWArtifact
	super.LoadPrefab(LocalPrefab, false, Translation);

	// find all particle emitters
	for (a = 0; a < LocalPrefab.PrefabArchetypes.Length; a++)
	{
		e = Emitter(LocalPrefab.PrefabArchetypes[a]);

		if (e != none)
		{
			// parse the emitter tag index
			Index = Split(e.Tag, TagEmitter, true);

			// find the matching artifact head
			for (b = 0; b < LocalPrefab.PrefabArchetypes.Length; b++)
			{
				ArtifactHead = StaticMeshActor(LocalPrefab.PrefabArchetypes[b]);

				if (ArtifactHead != none)
				{
					if (InStr(ArtifactHead.Tag, Index,, true ) != -1)
					{
						// spawn new effect
						Effect = Spawn
							(class'HWEffect_ArtifactAvailable',
							 self,,
							 Location + e.Location + PrefabTranslation,
							 Rotation + e.Rotation);

						EffectsAvailable.AddItem(Effect);
						break;
					}
				}
			}
		}
	}
}

/** Extends the base functionality by adding any Head mesh components of the artifact to the Heads array. */
simulated function StaticMeshComponent AddStaticMesh(StaticMeshActor TMesh, bool bPhysicsEnabled, optional Vector Translation)
{
	local StaticMeshComponent SMC;

	if(TMesh != none)
	{
		SMC = super.AddStaticMesh(TMesh, bPhysicsEnabled, Translation);

		if(InStr(TMesh.Tag, TagHead, , true) != -1)		
		{
			// initially hide all heads
			SMC.SetHidden(true);

			Heads.AddItem(SMC);
		}
	}

	return SMC;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bAvailable')
	{
		if(bAvailable)
		{
			Activate();
		}
		else
		{
			Deactivate();
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

replication
{
	// Replicate if server
	if(Role == ROLE_Authority && (bNetInitial || bNetDirty))
		bAvailable, VictoryPoints;
}


DefaultProperties
{
	SoundSelected=SoundCue'A_Test_Voice_Units.ArtifactSelected_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_Artifact_Test'

	RemoteRole = ROLE_SimulatedProxy;

	PrefabToLoad = Prefab'DEMO_GeneralAssets.Prefabs.artefact_prefab'
	// TODO Quickfix to position Artifact prefabs on ground. Remove if prefab origin is adjusted...
	PrefabTranslation = (X=0,Y=0,Z=-80)

	TagHead=kopf
	TagEmitter=pollen

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.S_Inventory'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=PointLightComponent Name=PointLightComponent0
		bAffectCompositeShadowDirection=TRUE
		Brightness = 15.0
		bCastCompositeShadow=FALSE
		CastDynamicShadows=FALSE
		CastShadows=FALSE
		CastStaticShadows=FALSE
		bEnabled=false
		bForceDynamicLight=FALSE
		LightAffectsClassification=LAC_STATIC_AFFECTING
	    LightColor=(R=60,G=83,B=238)
	    UseDirectLightMap=FALSE
	    LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
		FalloffExponent=0.8
		Radius=500
		ShadowFalloffExponent=2.0
	End Object
	Components.Add(PointLightComponent0)
	Light=PointLightComponent0	

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0100.000000
		CollisionHeight=+050.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
}
