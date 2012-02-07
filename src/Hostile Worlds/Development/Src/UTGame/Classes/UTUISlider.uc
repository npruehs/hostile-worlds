/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Extended version of the slider for UT3.
 */
class UTUISlider extends UDKUISlider;

defaultproperties
{
	Begin Object Class=UIComp_DrawStringSlider Name=CaptionStringRenderer
		StringStyle=(DefaultStyleTag="UTButtonBarButtonCaption",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="UTSliderText"
	End Object
	CaptionRenderComponent=CaptionStringRenderer
}
