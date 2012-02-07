/**
 * Example of how to setup a scene in unrealscript.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIScriptConsoleScene extends UIScene
	transient
	notplaceable;

/** the console's buffer text */
var	UILabel				BufferText;

/** the background for the console */
var	UIImage				BufferBackground;

/** where the text that is currently being typed appears */
var	ScriptConsoleEntry	CommandRegion;

event PostInitialize()
{
	Super.PostInitialize();

	InsertChild(BufferBackground);
	InsertChild(BufferText);
	InsertChild(CommandRegion);

	BufferBackground.SetDockTarget(UIFACE_Left,		Self,			UIFACE_Left);
	BufferBackground.SetDockTarget(UIFACE_Top,		Self,			UIFACE_Top);
	BufferBackground.SetDockTarget(UIFACE_Right,	Self,			UIFACE_Right);
	BufferBackground.SetDockTarget(UIFACE_Bottom,	CommandRegion,	UIFACE_Top);
	BufferBackground.SetWidgetStyleByName('Image Style', 'ConsoleBufferImageStyle');

	BufferText.SetWidgetStyleByName('String Style', 'ConsoleBufferStyle');
	BufferText.SetDockTarget(UIFACE_Bottom, CommandRegion, UIFACE_Top);
	BufferText.StringRenderComponent.EnableAutoSizing(UIORIENT_Vertical);
	BufferText.StringRenderComponent.SetWrapMode(CLIP_Wrap);
}

// following function is legacy - it is no longer needed.
function OnCreateChild( UIObject CreatedWidget, UIScreenObject CreatorContainer )
{
	CreatedWidget.OnCreate = None;
}

DefaultProperties
{
	SceneTag=ConsoleScene

	Position={(
		Value[EUIWidgetFace.UIFACE_Right]=1.f,ScaleType[EUIWidgetFace.UIFACE_Right]=EVALPOS_PercentageViewport,
		Value[EUIWidgetFace.UIFACE_Bottom]=0.75,ScaleType[EUIWidgetFace.UIFACE_Bottom]=EVALPOS_PercentageViewport
			)}

	Begin Object Class=UIImage Name=BufferBackgroundTemplate
		WidgetTag=BufferBackground
	End Object
	BufferBackground=BufferBackgroundTemplate

	Begin Object Class=UILabel Name=BufferTextTemplate
		WidgetTag=BufferText
		Position=(Value[EUIWidgetFace.UIFACE_Right]=1.f,ScaleType[EUIWidgetFace.UIFACE_Right]=EVALPOS_PercentageOwner)
	End Object
	BufferText=BufferTextTemplate

	Begin Object Class=ScriptConsoleEntry Name=CommandRegionTemplate
	End Object
	CommandRegion=CommandRegionTemplate
}

