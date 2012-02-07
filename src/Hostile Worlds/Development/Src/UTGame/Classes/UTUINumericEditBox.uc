/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Modified version of numeric edit box that has some styles replaced.
 */
class UTUINumericEditBox extends UINumericEditBox;

defaultproperties
{
	Begin Object class=UIComp_DrawImage Name=UTNumericEditboxBackgroundTemplate
		ImageStyle=(DefaultStyleTag="DefaultEditboxImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=UTNumericEditboxBackgroundTemplate

	// Increment and Decrement Button Styles
	IncrementStyle=(DefaultStyleTag="SpinnerIncrementButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	DecrementStyle=(DefaultStyleTag="SpinnerDecrementButtonBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
}
