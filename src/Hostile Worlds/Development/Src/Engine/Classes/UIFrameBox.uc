/**
 * More configurable image widget that allows the user to specify 9 image components to have
 * a background box that scales properly while maintaining the aspect ratio of its corners.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIFrameBox extends UIContainer
	placeable
	native(UIPrivate);

/** Enum describing all of the image components used in this widget. */
enum EFrameBoxImage
{
	FBI_TopLeft,
	FBI_Top,
	FBI_TopRight,
	FBI_CenterLeft,
	FBI_Center,
	FBI_CenterRight,
	FBI_BottomLeft,
	FBI_Bottom,
	FBI_BottomRight
};

/** Sizes of the corners.  The corner image components will always render at these sizes. */
struct native CornerSizes
{
	var() float TopLeft[2];
	var() float TopRight[2];
	var() float BottomLeft[2];
	var() float BottomRight[2];
	var() float TopHeight;
	var() float BottomHeight;
	var() float CenterLeftWidth;
	var() float CenterRightWidth;
};


/** Component for rendering the background images */
var(Components)	editinline	const	noclear	UIComp_DrawImage	BackgroundImageComponent[9];
var(Appearance)  editinline  CornerSizes								BackgroundCornerSizes;

cpptext
{
	/* === UIPanel interface === */
	/**
	 * Changes the background image for one of the image components.
	 *
	 * @param	ImageToSet		The image component we are going to set the image for.
	 * @param	NewImage		the new surface to use for this UIImage
	 */
	virtual void SetBackgroundImage( EFrameBoxImage ImageToSet, class USurface* NewImage );

	/* === UIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the BackgroundImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/* === UUIScreenObject interface === */
	/**
	 * Render this button.
	 *
	 * @param	Canvas	the canvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value from a member struct or array has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);
}

/* === Unrealscript === */
/**
 * Changes the background image for this panel, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetBackgroundImage( EFrameBoxImage ImageToSet, Surface NewImage )
{
	if ( BackgroundImageComponent[ImageToSet] != None )
	{
		BackgroundImageComponent[ImageToSet].SetImage(NewImage);
	}
}

DefaultProperties
{
	PrimaryStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	BackgroundCornerSizes=(TopLeft[0]=16.0,TopLeft[1]=16.0,TopHeight=16.0,TopRight[0]=16.0,TopRight[1]=16.0,CenterLeftWidth=16.0,CenterRightWidth=16.0,BottomLeft[0]=16.0,BottomLeft[1]=16.0,BottomHeight=16.0,BottomRight[0]=16.0,BottomRight[1]=16.0)

	// Top Left
	Begin Object class=UIComp_DrawImage Name=TemplateTopLeft
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Top Left Style"
	End Object
	BackgroundImageComponent[0]=TemplateTopLeft

	// Top
	Begin Object class=UIComp_DrawImage Name=TemplateTop
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Top Style"
	End Object
	BackgroundImageComponent[1]=TemplateTop

	// Top Right
	Begin Object class=UIComp_DrawImage Name=TemplateTopRight
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Top Right Style"
	End Object
	BackgroundImageComponent[2]=TemplateTopRight

	// Center Left
	Begin Object class=UIComp_DrawImage Name=TemplateCenterLeft
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Center Left Style"
	End Object
	BackgroundImageComponent[3]=TemplateCenterLeft

	// Center
	Begin Object class=UIComp_DrawImage Name=TemplateCenter
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Center Style"
	End Object
	BackgroundImageComponent[4]=TemplateCenter

	// Center Right
	Begin Object class=UIComp_DrawImage Name=TemplateCenterRight
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Center Right Style"
	End Object
	BackgroundImageComponent[5]=TemplateCenterRight

	// Bottom Left
	Begin Object class=UIComp_DrawImage Name=TemplateBottomLeft
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Bottom Left Style"
	End Object
	BackgroundImageComponent[6]=TemplateBottomLeft

	// Bottom
	Begin Object class=UIComp_DrawImage Name=TemplateBottom
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Bottom Style"
	End Object
	BackgroundImageComponent[7]=TemplateBottom

	// Bottom Right
	Begin Object class=UIComp_DrawImage Name=TemplateBottomRight
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Bottom Right Style"
	End Object
	BackgroundImageComponent[8]=TemplateBottomRight
}
