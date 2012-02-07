/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTEditorUISceneClient extends EditorUISceneClient
	native;

cpptext
{
	/**
	 * Render all the active scenes
	 */
	virtual void RenderScenes( FCanvas* Canvas );

	virtual void Render_Scene( FCanvas* Canvas, UUIScene* Scene, EUIPostProcessGroup UIPostProcessGroup );
}


defaultproperties
{
}
