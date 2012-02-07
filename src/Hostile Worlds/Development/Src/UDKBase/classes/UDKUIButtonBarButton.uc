/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Modified version of label button that doesn't accept focus on console.
 */
class UDKUIButtonBarButton extends UILabelButton
	native;

cpptext
{
	/**
	 * Perform all initialization for this widget. Called on all widgets when a scene is opened,
	 * once the scene has been completely initialized.
	 * For widgets added at runtime, called after the widget has been inserted into its parent's
	 * list of children.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );
}

/** === Focus Handling === */
/**
 * Determines whether this widget can become the focused control.
 *
 * @param	PlayerIndex					the index [into the Engine.GamePlayers array] for the player to check focus availability
 * @param	bIncludeParentVisibility	indicates whether the widget should consider the visibility of its parent widgets when determining
 *										whether it is eligible to receive focus.  Only needed when building navigation networks, where the
 *										widget might start out hidden (such as UITabPanel).
 *
 * @return	TRUE if this widget (or any of its children) is capable of becoming the focused control.
 */
native function bool CanAcceptFocus( optional int PlayerIndex=0, optional bool bIncludeParentVisibility=true ) const;

defaultproperties
{
	Begin Object Class=UIComp_DrawString Name=ButtonBarStringRenderer
		StringStyle=(DefaultStyleTag="UTButtonBarButtonCaption",RequiredStyleClass=class'Engine.UIStyle_Combo')
		StyleResolverTag="Caption Style"
		AutoSizeParameters[0]=(bAutoSizeEnabled=true)
	End Object
	StringRenderComponent=ButtonBarStringRenderer


	Begin Object class=UIComp_DrawImage Name=ButtonBarBackgroundImageTemplate
		ImageStyle=(DefaultStyleTag="UTButtonBarButtonBG",RequiredStyleClass=class'Engine.UIStyle_Image')
		StyleResolverTag="Background Image Style"
	End Object
	BackgroundImageComponent=ButtonBarBackgroundImageTemplate
}
