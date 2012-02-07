/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Option widget that works similar to a read only combobox.
 */
class UTUIOptionButton extends UDKUIOptionButton;

defaultproperties
{
	DecrementStyle=(DefaultStyleTag="DefaultOptionButtonLeftArrowStyle",RequiredStyleClass=class'UIStyle_Image')
	IncrementStyle=(DefaultStyleTag="DefaultOptionButtonRightArrowStyle",RequiredStyleClass=class'UIStyle_Image')

	Begin Object class=UIComp_DrawImage Name=BackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="OptionButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=BackgroundImageTemplate

	Begin Object Class=UIComp_DrawString Name=LabelStringRenderer
		StringStyle=(DefaultStyleTag="DefaultOptionButtonStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="Caption Style"
	End Object
	StringRenderComponent=LabelStringRenderer

	// Sounds
	IncrementCue=SliderIncrement
	DecrementCue=SliderDecrement
}
