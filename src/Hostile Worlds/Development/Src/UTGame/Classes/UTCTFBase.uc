/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTCTFBase extends UTGameObjective
	hidecategories(Objective,VoiceMessage,Announcements)
	abstract;

/** audio component that should play when the flag has been taken */
var() AudioComponent TakenSound;

var		UTCTFFlag			myFlag;
var		class<UTCTFFlag>	FlagType;
var()	float				MidFieldHighZOffset;
var()	float				MidFieldLowZOffset;
var()	float				NearBaseRadius;
var()	float				BaseExitTime;		// how long it takes to get entirely away from the base

/** Particles to play while the flag is gone */
var		ParticleSystemComponent	FlagEmptyParticles;

/**
 * The MICs for the flag base.  We need to store the MIC we are referencing and then the one we
 * spawn at runtime.
 **/
var MaterialInstanceConstant FlagBaseMaterial;
var MaterialInstanceConstant MIC_FlagBaseColor;

/** Reference to the actual mesh base so we can modify it with a different material **/
var StaticMeshComponent FlagBaseMesh;

var class<UTLocalMessage> CTFAnnouncerMessagesClass;

var Array<SoundNodeWave> NearLocationSpeech;
var Array<SoundNodeWave> MidfieldHighSpeech;
var Array<SoundNodeWave> MidfieldLowSpeech;

simulated function PostBeginPlay()
{
//	local UTDefensePoint W;

	Super.PostBeginPlay();

	if ( Role < ROLE_Authority )
		return;

	if ( UTCTFGame(WorldInfo.Game) != None )
	{
		myFlag = Spawn(FlagType, self);

		if (myFlag==None)
		{
			`warn(Self$" could not spawn flag of type '"$FlagType$"' at "$location);
			return;
		}
		else
		{
			UTCTFGame(WorldInfo.Game).RegisterFlag(myFlag, DefenderTeamIndex);
			myFlag.HomeBase = self;
		}
	}

	//calculate distance from this base to all nodes - store in BaseDist[DefenderTeamIndex] for each node
	/* //@todo FIXMESTEVE
	SetBaseDistance(DefenderTeamIndex);

	// calculate visibility to base and defensepoints, for all paths
	SetBaseVisibility(DefenderTeamIndex);
	for ( W=DefensePoints; W!=None; W=W.NextDefensePoint )
		if ( W.myMarker != None )
			W.myMarker.SetBaseVisibility(DefenderTeamIndex);
	*/

	MIC_FlagBaseColor = new(Outer) class'MaterialInstanceConstant';
	MIC_FlagBaseColor.SetParent( FlagBaseMaterial );
	FlagBaseMesh.SetMaterial( 0, MIC_FlagBaseColor );
}

event actor GetBestViewTarget()
{
	if (myFlag.Holder != none)
	{
		return myFlag.Holder;
	}
	else if (!myFlag.bHome)
	{
		return MyFlag;
	}
	else
	{
		return super.GetBestViewTarget();
	}
}

simulated function int GetLocationMessageIndex(UTBot B, Pawn StatusPawn)
{
	local float Dist, ZDiff;

	Dist = VSize(StatusPawn.Location - Location);
	if ( Dist < BaseRadius )
	{
		return 0;
	}
	if ( Dist < NearBaseRadius )
	{
		return 1;
	}

	// Midfield high or low?
	ZDiff = StatusPawn.Location.Z - Location.Z;
	if ( ZDiff > MidFieldHighZOffset )
	{
		return 2;
	}
	if ( ZDiff < MidFieldLowZOffset )
	{
		return 3;
	}

	return 10;
}

simulated function SoundNodeWave GetLocationSpeechFor(PlayerController PC, int LocationSpeechOffset, int MessageIndex)
{
	if ( MessageIndex == 0 )
	{
		// inside the base
		return (LocationSpeechOffset < LocationSpeech.Length) ? LocationSpeech[LocationSpeechOffset] : None;
	}
	else if ( MessageIndex == 1 )
	{
		// near the base
		return (LocationSpeechOffset < NearLocationSpeech.Length) ? NearLocationSpeech[LocationSpeechOffset] : None;
	}
	else if ( MessageIndex == 2 )
	{
		// Midfield High
		return (LocationSpeechOffset < MidFieldHighSpeech.Length) ? MidFieldHighSpeech[LocationSpeechOffset] : None;
	}
	else if ( MessageIndex == 3 )
	{
		// Midfield Low
		return (LocationSpeechOffset < MidFieldLowSpeech.Length) ? MidFieldLowSpeech[LocationSpeechOffset] : None;
	}

	return None;
}

/**
 * Handle flag events.
 */
function ObjectiveChanged()
{
	local PlayerController PC;

	if (myFlag != None)
	{
		// Look to change the spectator
		foreach WorldInfo.AllControllers(class'PlayerController', PC)
		{
			if ( (PC.ViewTarget == self) || (PC.ViewTarget == myFlag) || ((PC.ViewTarget != None) && (PC.ViewTarget == myFlag.Holder)) )
				PC.SetViewTarget(GetBestViewTarget());
		}
	}
}

function UTCarriedObject GetFlag()
{
	return myFlag;
}

simulated function SetAlarm(bool bNowOn)
{
	bUnderAttack = bNowOn;
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bNowOn)
		{
			if (TakenSound != none)
			{
				TakenSound.Play();
			}
			if(FlagEmptyParticles != none)
			{
				FlagEmptyParticles.SetActive(true);
			}
		}
		else
		{
			if (TakenSound != none)
			{
				TakenSound.Stop();
			}
			if(FlagEmptyParticles != none)
			{
				FlagEmptyParticles.DeactivateSystem();
			}
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bUnderAttack')
	{
		SetAlarm(bUnderAttack);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event bool IsActive()
{
	return true;
}


defaultproperties
{
	NearBaseRadius=+4000.0
	MidFieldHighZOffset=250.0
	MidFieldLowZOffset=-250.0
	MinimapIconScale=7.0
}



