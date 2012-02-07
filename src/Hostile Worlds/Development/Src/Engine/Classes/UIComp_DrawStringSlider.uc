/**
 * This specialized version of UIComp_DrawString handles rendering the value caption for UISliders.  The responsibilities specific
 * to rendering slider captions are:
 * @todo
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_DrawStringSlider extends UIComp_DrawString
	native(inherit);

DefaultProperties
{
	StringStyle=(DefaultStyleTag="DefaultSliderCaptionStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
}
