/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTBeamWeaponAttachment extends UTWeaponAttachment;

/** The Particle System Template for the Beam */
var particleSystem BeamTemplate[2];

/** Holds the Emitter for the Beam */
var ParticleSystemComponent BeamEmitter[2];

/** Where to attach the Beam */
var name BeamSockets[2];

/** Quick access to the pawn owner */
var UTPawn PawnOwner;

/** The name of the EndPoint parameter */
var name EndPointParamName;

simulated function AddBeamEmitter()
{
	local int i;

	for (i=0;i<2;i++)
	{
		if ( BeamTemplate[i] != none )
		{
			BeamEmitter[i] = new(self) class'UTParticleSystemComponent';
			BeamEmitter[i].SetTemplate(BeamTemplate[i]);
			BeamEmitter[i].SetHidden(true);
			BeamEmitter[i].SetTickGroup(TG_PostUpdateWork);
			BeamEmitter[i].bUpdateComponentInTick = true;
			Mesh.AttachComponentToSocket(BeamEmitter[i], BeamSockets[i]);
		}
	}
}

simulated function HideEmitter(int Index, bool bHide)
{
	if (BeamEmitter[Index] != None)
	{
		BeamEmitter[Index].SetHidden(bHide);
	}
}

simulated function UpdateBeam(byte FireModeNum)
{
	// Make sure the Emitter is visible
	if (BeamEmitter[FireModeNum] != None)
	{
		BeamEmitter[FireModeNum].SetVectorParameter(EndPointParamName , PawnOwner.FlashLocation);
	}

	HideEmitter(FireModeNum, false);
	HideEmitter(Abs(FireModeNum - 1), true);
}

state CurrentlyAttached
{
	simulated function BeginState(Name PreviousStateName)
	{
		PawnOwner = UTPawn(Owner);
		if (PawnOwner==none)
		{
			`log("ERROR:"@self@"found without a valid UTPawn Owner");
			return;
		}

		AddBeamEmitter();

	}

	simulated function Tick(float DeltaTime)
	{
		if  ( (PawnOwner == None) || PawnOwner.IsFirstPerson() || PawnOwner.FlashLocation==vect(0,0,0) )
		{
			HideEmitter(0,true);
			HideEmitter(1,true);
			return;
		}

		UpdateBeam(PawnOwner.FiringMode);
	}
}


defaultproperties
{
}
