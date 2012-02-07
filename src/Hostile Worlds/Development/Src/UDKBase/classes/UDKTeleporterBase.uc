/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKTeleporterBase extends Teleporter
	native
	abstract
	config(Game);

/** the component that captures the portal scene */
var(SceneCapture) editconst SceneCaptureComponent PortalCaptureComponent;

/** the texture that the component renders to */
var TextureRenderTarget2D TextureTarget;

/** resolution parameters */
var(SceneCapture) int TextureResolutionX, TextureResolutionY;

/** actor that the portal view is based on (used for updating Controllers' VisiblePortals array) */
var Actor PortalViewTarget;

/** materials for the portal effect */
var MaterialInterface PortalMaterial;
var MaterialInstanceConstant PortalMaterialInstance;

/** material parameter that we assign the rendered texture to */
var name PortalTextureParameter;

/** Sound to be played when someone teleports in*/
var SoundCue TeleportingSound;

cpptext
{
	virtual void TickSpecial(FLOAT DeltaTime);
}

simulated event PostBeginPlay()
{
	local Teleporter Dest;

	Super.PostBeginPlay();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// try to find a teleporter to view
		foreach WorldInfo.AllNavigationPoints(class'Teleporter', Dest)
		{
			if (string(Dest.Tag) ~= URL && Dest != Self)
			{
				break;
			}
		}
		if (WorldInfo.IsConsoleBuild(CONSOLE_PS3))
		{
			SetHidden(Dest == None);
		}
		else
		{
			InitializePortalEffect(Dest);
		}
	}
}

simulated function InitializePortalEffect(Actor Dest)
{
	local bool bStaticCapture;

	if (PortalCaptureComponent != None)
	{
		if (Dest != None)
		{
			// only get realtime capture in high detail mode
			bStaticCapture = (WorldInfo.GetDetailMode() < DM_High);

			PortalViewTarget = Dest;
			// set up the portal effect
			PortalMaterialInstance = new(self) class'MaterialInstanceConstant';
			PortalMaterialInstance.SetParent(PortalMaterial);

			TextureTarget = class'TextureRenderTarget2D'.static.Create( TextureResolutionX, TextureResolutionY,,
									MakeLinearColor(0.0, 0.0, 0.0, 1.0), bStaticCapture );

			if (bStaticCapture)
			{
				PortalCaptureComponent.SetFrameRate(0);
			}
			PortalMaterialInstance.SetTextureParameterValue(PortalTextureParameter, TextureTarget);

			AttachComponent(PortalCaptureComponent);
		}
		else
		{
			SetHidden(true);
		}
	}
}

simulated event bool Accept( actor Incoming, Actor Source )
{
	if (Super.Accept(Incoming,Source))
	{
		PlaySound(TeleportingSound);
		return true;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=50.0
		CollisionHeight=30.0
	End Object

	bStatic=false
	bMovable=false
	PortalTextureParameter=RenderToTextureMap
	TextureResolutionX=256
	TextureResolutionY=256
}
