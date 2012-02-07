/**
 * Base class for all containers which need a background image.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIPanel extends UIContainer
	placeable
	native(UIPrivate);

/** Component for rendering the background image */
var(Components)	editinline	const	UIComp_DrawImage		BackgroundImageComponent;

/** If ture, this panel will clip anything that attempts to render outside of it's bounds */
var(Appearance) bool bEnforceClipping;

cpptext
{
	/* === UIPanel interface === */
	/**
	 * Changes the background image for this button, creating the wrapper UITexture if necessary.
	 *
	 * @param	NewImage		the new surface to use for this UIImage
	 */
	virtual void SetBackgroundImage( class USurface* NewImage );

	/* === UIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the BackgroundImageComponent (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/* === UUIScreenObject interface === */

	/**
	 * Routes rendering calls to children of this screen object.
	 *
	 * This version sets a clip mask on the canvas while the children are being rendered.
	 *
	 * @param	Canvas	the canvas to use for rendering
	 * @param	UIPostProcessGroup	Group determines current pp pass that is being rendered
	 */
	virtual void Render_Children( FCanvas* Canvas, EUIPostProcessGroup UIPostProcessGroup );


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

	/**
	 * Called after this object has been completely de-serialized.  This version migrates values for the deprecated PanelBackground,
	 * Coordinates, and PrimaryStyle properties over to the BackgroundImageComponent.
	 */
	virtual void PostLoad();
}

/* === Unrealscript === */
/**
 * Changes the background image for this panel, creating the wrapper UITexture if necessary.
 *
 * @param	NewImage		the new surface to use for this UIImage
 */
final function SetBackgroundImage( Surface NewImage )
{
	if ( BackgroundImageComponent != None )
	{
		BackgroundImageComponent.SetImage(NewImage);
	}
}

DefaultProperties
{
	PrimaryStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
	bSupportsPrimaryStyle=false

	Begin Object class=UIComp_DrawImage Name=PanelBackgroundTemplate
		ImageStyle=(DefaultStyleTag="PanelBackground",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Panel Background Style"
	End Object
	BackgroundImageComponent=PanelBackgroundTemplate
}
