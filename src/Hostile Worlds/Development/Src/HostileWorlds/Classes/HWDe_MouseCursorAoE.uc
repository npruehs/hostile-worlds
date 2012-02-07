// ============================================================================
// HWDe_MouseCursorAoE
// A mouse cursor using Unreal's decals system for indicating areas of effect.
//
// Author:  Nick Pruehs
// Date:    2011/02/17
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWDe_MouseCursorAoE extends HWDecal;

DefaultProperties
{
	Begin Object Name=NewDecalComponent
		DecalMaterial=DecalMaterial'FX_Decals.M_FX_AreaOfEffect'
	End Object
}
