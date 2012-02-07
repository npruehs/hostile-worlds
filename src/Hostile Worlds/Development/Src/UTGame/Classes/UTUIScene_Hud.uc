/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTUIScene_Hud extends UTUIScene;

defaultproperties
{
	bDisplayCursor=false
	bPauseGameWhileActive=false
	SceneInputMode=INPUTMODE_None
	bRenderParentScenes=true
	bCloseOnLevelChange=true
	bExemptFromAutoClose=true
`if(`notdefined(MOBILE))
	SceneSkin=UISkin'UI_InGameHud.UTHUDSkin'
`endif
}

