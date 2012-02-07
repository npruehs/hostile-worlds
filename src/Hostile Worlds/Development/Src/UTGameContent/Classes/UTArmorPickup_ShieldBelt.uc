/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTArmorPickup_ShieldBelt extends UTArmorPickupFactory;

var class<UTDroppedItemPickup> DroppedPickupClass;

/**
* CanUseShield() returns how many shield units P could use
*
* @Returns returns how many shield units P could use
*/
function int CanUseShield(UTPawn P)
{
	return Max(0,ShieldAmount - P.ShieldBeltArmor);
}

/**
* AddShieldStrength() add shield to appropriate P armor type.
*
* @Param	P 	The UTPawn to give shields to
*/
function AddShieldStrength(UTPawn P)
{
	local MaterialInterface ShieldMat;

	// Get the proper shield material
	ShieldMat = P.GetShieldMaterialInstance(WorldInfo.Game.bTeamGame);

	// Assign it
	P.ShieldBeltArmor = Max(ShieldAmount, P.ShieldBeltArmor);
	if (P.GetOverlayMaterial() == None)
	{
		P.SetOverlayMaterial(ShieldMat);
	}
}



defaultproperties
{
	ShieldAmount=100
	bIsSuperItem=true
	RespawnTime=60.000000
	MaxDesireability=1.500000
	PickupStatName=PICKUPS_SHIELDBELT
	PickupSound=SoundCue'A_Pickups.Shieldbelt.Cue.A_Pickups_Shieldbelt_Activate_Cue'

	Begin Object Name=ArmorPickUpComp
	    StaticMesh=StaticMesh'Pickups.Armor_ShieldBelt.Mesh.S_UN_Pickups_Shield_Belt'
		Scale3D=(X=1.5,Y=1.5,Z=1.5)
	End Object

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheShieldBelt'

	DroppedPickupClass=class'UTDroppedShieldBelt'

	RespawnSound=SoundCue'A_Pickups.Armor.Cue.A_Pickups_Armor_Respawn_Cue'

	Begin Object Name=BaseMeshComp
		StaticMesh=StaticMesh'Pickups.Base_Armor.Mesh.S_Pickups_Base_Armor'
		Translation=(X=0.0,Y=0.0,Z=-44.0)
	End Object

	Begin Object Class=UTParticleSystemComponent Name=ArmorParticles
		Translation=(X=0.0,Y=0.0,Z=-25.0)
		Template=ParticleSystem'Pickups.Base_Armor.Effects.P_Pickups_Base_Armor_Glow'
		SecondsBeforeInactive=2.0f
	End Object
	SpinningParticleEffects=ArmorParticles
	Components.Add(ArmorParticles)
}
