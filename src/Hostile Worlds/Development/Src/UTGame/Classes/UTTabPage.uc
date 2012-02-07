/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTTabPage extends UDKTabPage;


/** Callback allowing the tabpage to setup the button bar for the current scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	// Do nothing by default.
}

/**
 * Wrapper for getting a reference to the scene's button bar.
 */
function UTUIButtonBar GetButtonBar()
{
	local UTUIFrontEnd UTOwnerScene;

	UTOwnerScene = UTUIFrontEnd(GetScene());
	return UTOwnerScene != None ? UTOwnerScene.ButtonBar : None;
}

defaultproperties
{
}
