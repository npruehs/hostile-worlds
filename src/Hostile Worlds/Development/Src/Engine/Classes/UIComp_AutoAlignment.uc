/**
 * This component when present in a widget is supposed add ability to auto align its children widgets in a specified fashion
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_AutoAlignment extends UIComponent
	within UIObject
	native(UIPrivate)
	HideCategories(Object)
	editinlinenew;
//
/// ** vertical auto alignment orientation setting * /
//enum EUIAutoAlignVertical
//{
//	UIAUTOALIGNV_None,
//	UIAUTOALIGNV_Top,
//	UIAUTOALIGNV_Center,
//	UIAUTOALIGNV_Bottom
//};
//
/// ** auto alignment orientation setting * /
//enum EUIAutoAlignHorizontal
//{
//	UIAUTOALIGNH_None,
//	UIAUTOALIGNH_Left,
//	UIAUTOALIGNH_Center,
//	UIAUTOALIGNH_Right
//};

/**
 * The settings which determines how this component will be aligning children widgets
 */

var(Appearance)		EUIAlignment	HorzAlignment;
var(Appearance)		EUIAlignment	VertAlignment;

cpptext
{
	/**
	 * Adds the specified face to the owning scene's DockingStack for the owning widget.  Takes wrap behavior and
	 * autosizing into account, ensuring that all widget faces are added to the scene's docking stack in the appropriate
	 * order.
	 *
	 * @param	DockingStack	the docking stack to add this docking node to.  Generally the scene's DockingStack.
	 * @param	Face			the face that should be added
	 *
	 * @return	TRUE if a docking node was added to the scene's DockingStack for the specified face, or if a docking node already
	 *			existed in the stack for the specified face of this widget.
	 */
	virtual void AddDockingNode( TArray<FUIDockingNode>& DockingStack, EUIWidgetFace Face );

	/**
	 * Adjusts the child widget's positions according to the specified autoalignment setting
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

	/**
	 * Called when a property value has been changed in the editor.
	 */
	void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	 * Converts the value of the Vertical and Horizontal alignment
	 */
	virtual void Serialize( FArchive& Ar );

protected:
	/**
	 *	Updates the horizontal position of child widgets according to the specified alignment setting
	 *
	 * @param	ContainerWidget			The widget to whose bounds the widgets will be aligned
	 * @param	HorizontalAlignment		The horizontal alignment setting
	 */
	void AlignWidgetsHorizontally( UUIObject* ContainerWidget, EUIAlignment HorizontalAlignment );

	/**
	 *	Updates the vertical position of child widgets according to the specified alignment setting
	 *
	 * @param	ContainerWidget			The widget to whose bounds the widgets will be aligned
	 * @param	VerticalAlignment		The vertical alignment setting
	 */
	void AlignWidgetsVertically( UUIObject* ContainerWidget, EUIAlignment VerticalAlignment );
}


DefaultProperties
{
	HorzAlignment=UIALIGN_Default
	VertAlignment=UIALIGN_Default
}
