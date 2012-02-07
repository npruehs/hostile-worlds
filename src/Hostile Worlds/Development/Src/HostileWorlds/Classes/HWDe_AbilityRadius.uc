// ============================================================================
// HWDe_AbilityRadius
// Uses Unreal's decals system to indicate the range of an ability a player
// wants to trigger.
//
// Author:  Nick Pruehs
// Date:    2011/03/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWDe_AbilityRadius extends HWDecal;

DefaultProperties
{
	Begin Object Name=NewDecalComponent
		DecalMaterial=DecalMaterial'FX_Decals.M_FX_AbilityRadius'
	End Object
}
