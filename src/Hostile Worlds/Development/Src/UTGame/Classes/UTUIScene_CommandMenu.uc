/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_CommandMenu extends UTUIScene_Hud;

event PostInitialize()
{
	Super.PostInitialize();
	bDisplayCursor = false;
	OnInitialSceneUpdate = PreRenderCallback;
}

function PreRenderCallback()
{
	bDisplayCursor = false;
}


defaultproperties
{
	SceneInputMode=INPUTMODE_MatchingOnly
	SceneRenderMode=SPLITRENDER_PlayerOwner
	bDisplayCursor=true
	bRenderParentScenes=false
	bAlwaysRenderScene=true
	bCloseOnLevelChange=true
	bIgnoreAxisInput=true
	bFlushPlayerInput=false

	Begin Object Name=SceneEventComponent
		DisabledEventAliases.Add(Clicked)
	End Object


}
