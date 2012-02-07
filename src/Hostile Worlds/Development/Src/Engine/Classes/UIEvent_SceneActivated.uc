/**
 * This event is activated when a scene is opened.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEvent_SceneActivated extends UIEvent_Scene;

/**
 * True if the scene has just been activated; FALSE if the scene is becoming active as a result of closing another scene.
 */
var		bool			bInitialActivation;

/**
 * Called when this event is deactivated.
 *
 * This version disables all output links if the container scene is invalid or is no
 * longer in the scene client's active scenes array.
 */
event DeActivated()
{
	local int i;
	local UIScene OwnerScene;

	Super.DeActivated();

	// find the scene that contains this event
	OwnerScene = GetOwnerScene();
	if ( OwnerScene == None || !OwnerScene.IsSceneActive() )
	{
		// if we don't have an owner scene, or it is no longer part of the scene client's active scenes, disable this
		// event's output links as any action linked to a "Scene Opened" event will probably need to perform work that is dangerous
		// if the scene is no longer active
		for ( i = 0; i < OutputLinks.Length; i++ )
		{
			OutputLinks[i].bHasImpulse = false;
		}

`if(`notdefined(ShippingPC))
		if ( OwnerScene == None )
		{
			ScriptLog("Disabling" @ Class.Name @ PathName(Self) @ "because containing scene is None");
			`log("Disabling" @ Class.Name @ PathName(Self) @ "because containing scene is None",,'DevUI');
		}
		else
		{
			ScriptLog("Disabling" @ Class.Name @ PathName(Self) @ "because containing scene" @ OwnerScene.SceneTag @ "is no longer active");
			`log("Disabling" @ Class.Name @ PathName(Self) @ "because containing scene" @ OwnerScene.SceneTag @ "is no longer active",,'DevUI');
		}
`endif
	}
}

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}


DefaultProperties
{
	ObjName="Scene Opened"

	ObjPosX=48
	ObjPosY=216

	VariableLinks.Add((ExpectedType=class'SeqVar_Bool',LinkDesc="Initial Activation",PropertyName=bInitialActivation,bWriteable=true,bHidden=true))
}
