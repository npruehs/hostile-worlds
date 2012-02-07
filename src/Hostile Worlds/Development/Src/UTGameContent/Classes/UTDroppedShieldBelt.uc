/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDroppedShieldBelt extends UTDroppedItemPickup;

var int ShieldAmount;

function DroppedFrom(Pawn P)
{
	local UTPawn UTP;

	UTP = UTPawn(P);
	if (UTP != None)
	{
		ShieldAmount = UTP.ShieldBeltArmor;
		UTP.ShieldBeltArmor = 0;
		UTP.SetOverlayMaterial(None);
	}
}

function GiveTo(Pawn P)
{
	local UTPawn UTP;

	UTP = UTPawn(P);
	UTP.ShieldBeltArmor = Max(ShieldAmount, UTP.ShieldBeltArmor);
	if (UTP.GetOverlayMaterial() == None)
	{
		UTP.SetOverlayMaterial(UTP.GetShieldMaterialInstance(WorldInfo.Game.bTeamGame));
	}

	PickedUpBy(P);
}

function int CanUseShield(UTPawn P)
{
	return Max(0, ShieldAmount - P.ShieldBeltArmor);
}

function float BotDesireability(Pawn Bot, Controller C)
{
	if ( UTPawn(Bot) == None )
		return 0;

	return (0.013 * MaxDesireability * CanUseShield(UTPawn(Bot)));
}

auto state Pickup
{
	/*
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch(Pawn Other)
	{
		return (UTPawn(Other) != None && CanUseShield(UTPawn(Other)) > 0 && Super.ValidTouch(Other));
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=ArmorPickUpComp
		StaticMesh=StaticMesh'Pickups.Armor_ShieldBelt.Mesh.S_UN_Pickups_Shield_Belt'
		Scale3D=(X=1.5,Y=1.5,Z=1.5)
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE

		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=DroppedPickupLightEnvironment

		CollideActors=FALSE
		MaxDrawDistance=7000
	End Object
	PickupMesh=ArmorPickUpComp
	Components.Add(ArmorPickUpComp)

	ShieldAmount=100
	MaxDesireability=1.500000
	PickupSound=SoundCue'A_Pickups.Shieldbelt.Cue.A_Pickups_Shieldbelt_Activate_Cue'
}
