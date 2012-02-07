// ============================================================================
// HWTower
// A tower that be captured by a player to extends his or her vision.
//
// Author:  Nick Pruehs
// Date:    2011/01/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWTower extends HWGameObject;

/** Whether owner updates are propagated to enemy teams, or not. */
var bool bHiddenByFogOfWar;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// change the initial red color of the tower to the one of the neutral player
	ChangeColor(TeamIndex);
}

simulated function string GetAdditionalInfo()
{
	return "Controlled by team: "$TeamIndex;
}

simulated function Show()
{
	if (bHiddenByFogOfWar)
	{
		bHiddenByFogOfWar = false;
		ChangeColor(TeamIndex);
	}
}

simulated function Hide()
{
	if (!bHiddenByFogOfWar)
	{
		Deselect();
		bHiddenByFogOfWar = true;
	}
}

simulated function ChangeColor(int NewTeamIndex)
{
	if (!bHiddenByFogOfWar)
	{
		super.ChangeColor(NewTeamIndex);
	}
}


DefaultProperties
{
	SoundSelected=SoundCue'A_Test_Voice_Units.TowerSelected_Cue'

	UnitPortrait=Texture2D'UI_HWPortraits.T_UI_Portrait_Tower_Test'

	ControllerClass=class'HWTowerController'

	PrefabToLoad=Prefab'DEMO_GeneralAssets.Prefabs.Pref_Tower';
	// TODO Quickfix to position prefab on ground. Remove if prefab origin is adjusted...
	PrefabTranslation=(X=0,Y=0,Z=50);

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.SwchLite'
	End Object

	bApplyFogOfWar=true
	bUsesTeamColors=true

	TeamMaterialNames(0)=M_Tower_red
	TeamColorParameterName=colorGlow
}