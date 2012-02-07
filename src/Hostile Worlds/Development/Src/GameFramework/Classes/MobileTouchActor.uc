/**
 * MobileTouchActor
 *
 * A placeable actor that can be touched by a player using a touch-screen device.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MobileTouchActor extends Actor
	native
	placeable
	hidecategories(Actor,Collision,Physics);

/** Base cylinder component for collision */
var() editconst const CylinderComponent	CylinderComponent;

/** Whether or not to start enabled */
var() bool bStartEnabled;

/** Animated sprite */
var() DynamicSpriteComponent AnimatedSprite;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	Toggle(bStartEnabled);
}

simulated function Toggle(bool bTurnOn)
{
	if (bTurnOn)
	{
		SetCollision(true);
		SetHidden(false);
	}
	else
	{
		SetCollision(false);
		SetHidden(true);
	}
}

// Allow kismet to toggle on/off
simulated function OnToggle(SeqAct_Toggle action)
{
	if (action.InputLinks[0].bHasImpulse)
	{
		// turn on
		Toggle(true);
	}
	else if (action.InputLinks[1].bHasImpulse)
	{
		// turn off
		Toggle(false);
	}
	else if (action.InputLinks[2].bHasImpulse)
	{
		// toggle
		Toggle(!bCollideActors);
	}
}

delegate OnTapDelegate(Vector2D TouchLocation, MobileTouchActor InputActor);

/**
 * You must assign a MobileInputZone's OnTapDelegate to MobilePlayerInput.ProcessWorldTouch to catch this event.
 * 
 * @param InPC              The PlayerController that caused this event
 * @param TouchLocation     The screen-space location of the touch event
 *
 * @Return true if event was handled, false to pass through to actors that may be occluded by this one
 */
event bool OnMobileTouch(PlayerController InPC, Vector2D TouchLocation)
{
	OnTapDelegate(TouchLocation, self);

	return super.OnMobileTouch(InPC, TouchLocation);
}

DefaultProperties
{
	Begin Object Class=DynamicSpriteComponent Name=AnimSprite
		Sprite=Texture2D'EditorResources.S_Trigger'
		HiddenGame=False
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=False
		AnimatedColor=(Points=((InVal=0,OutVal=(R=1.000000,G=0.971934,B=0.934607,A=0.000000)),(InVal=0.3,OutVal=(R=0.166588,G=0.679308,B=0.766304,A=1.000000)),(InVal=1,OutVal=(R=0.253195,G=0.575787,B=0.913043,A=0.000000))),InterpMethod=IMT_UseFixedTangentEvalAndNewAutoTangents)
		AnimatedScale=(Points=((InVal=0,OutVal=0.2),(InVal=1.0,OutVal=0.5)),InterpMethod=IMT_UseFixedTangentEvalAndNewAutoTangents)
	End Object
	Components.Add(AnimSprite)
	AnimatedSprite=AnimSprite

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollideActors=true
		CollisionRadius=+0040.000000
		CollisionHeight=+0040.000000
		bAlwaysRenderIfSelected=true
		bDrawBoundingBox=false
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bHidden=true
	bCollideActors=true
	bStatic=false
	bNoDelete=true

	SupportedEvents.Empty
	SupportedEvents(0)=class'SeqEvent_MobileTouch'
}
