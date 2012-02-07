/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */


class UTLinkBeamLight extends Actor;

var PointLightComponent BeamLight;

defaultproperties
{
	RemoteRole=ROLE_None
	bGameRelevant=true

    Begin Object Class=PointLightComponent Name=LightComponentB
		bEnabled=true
		Brightness=3
		CastShadows=false
        LightColor=(R=173,G=211,B=200,A=255)
        Radius=130
    End Object
    BeamLight=LightComponentB
	Components.Add(LightComponentB)
}
