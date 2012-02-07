/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTArmorPickup_BaseArmor extends UTArmorPickupFactory;

/** CanUseShield()
returns how many shield units P could use
*/
function int CanUseShield(UTPawn P)
{
	return Max(0,ShieldAmount - P.VestArmor);
}

/** AddShieldStrength()
add shield to appropriate P armor type.
*/
function AddShieldStrength(UTPawn P)
{
	P.VestArmor = Max(ShieldAmount, P.VestArmor);
}

defaultproperties
{
	ShieldAmount=50
	bIsSuperItem=false
	RespawnTime=30.000000
	MaxDesireability=1.000000
	PickupSound=SoundCue'A_Pickups.Armor.Cue.A_Pickups_Armor_Chest_Cue'

	Begin Object Name=ArmorPickUpComp
		StaticMesh=StaticMesh'Pickups.Armor.Mesh.S_Pickups_Armor'
		Translation=(X=0.0,Y=0.0,Z=-50.0)
	End Object

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