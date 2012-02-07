/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

/** version of Teleporter that has a custom mesh/material */
class UTTeleporterCustomMesh extends Teleporter;

var() StaticMeshComponent Mesh;

/** Sound to be played when someone teleports in*/
var SoundCue TeleportingSound;

var UTPawn LastPawn;
var float LastTime;

simulated event bool Accept( actor Incoming, Actor Source )
{
	local UTPlayerReplicationInfo PRI;

	PRI = (Pawn(Incoming) != None) ? UTPlayerReplicationInfo(Pawn(Incoming).PlayerReplicationInfo) : None;
	if ( (PRI != None) && (PRI.GetFlag() != None) )
	{
		PRI.GetFlag().Drop();
	}

	if (Super.Accept(Incoming,Source))
	{
		PlaySound(TeleportingSound);
		if ( UTPawn(Incoming) != None )
		{
			LastPawn = UTPawn(Incoming);
			LastTime = WorldInfo.TimeSeconds;
		}
		return true;
	}
	else
	{
		return false;
	}
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if ( (Other == LastPawn) && (WorldInfo.TimeSeconds - LastTime < 0.2) )
	{
		return;
	}
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

defaultproperties
{

	Begin Object Class=StaticMeshComponent Name=PortalMesh
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
		StaticMesh=StaticMesh'EditorMeshes.TexPropPlane'
		Materials[0]=MaterialInterface'EngineMaterials.ScreenMaterial'
		Translation=(Z=125.0)
	End Object
	Mesh=PortalMesh
	CollisionComponent=PortalMesh
	Components.Add(PortalMesh)

	Begin Object Name=CollisionCylinder
		CollideActors=false
		CollisionRadius=50.0
		CollisionHeight=30.0
	End Object

	TeleportingSound=SoundCue'A_Gameplay.Portal.Portal_WalkThrough01Cue'
}
