/**
 * Generic message box scene.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIMessageBox extends UIMessageBoxBase;

/* == Delegates == */

/* == Natives == */

/* == Events == */

/* == UnrealScript == */
/**
 * Sets up the docking links for the message box's controls
 */
function SetupDockingRelationships()
{
	Super.SetupDockingRelationships();

	lblTitle.SetDockTarget(UIFACE_Left, Self, UIFACE_Left);
	lblTitle.SetDockTarget(UIFACE_Top, Self, UIFACE_Top);
	lblTitle.SetDockTarget(UIFACE_Right, Self, UIFACE_Right);

	lblMessage.SetDockTarget(UIFACE_Left, Self, UIFACE_Left);
	lblMessage.SetDockTarget(UIFACE_Top, lblTitle, UIFACE_Bottom);
	lblMessage.SetDockTarget(UIFACE_Right, Self, UIFACE_Right);

	btnbarChoices.SetDockTarget(UIFACE_Left, Self, UIFACE_Left);
	btnbarChoices.SetDockTarget(UIFACE_Bottom, Self, UIFACE_Bottom);
	btnbarChoices.SetDockTarget(UIFACE_Right, Self, UIFACE_Right);
}

/* == SequenceAction handlers == */

/* == Delegate handlers == */

DefaultProperties
{
	/* == UIMessageBox defaults == */
	// Controls
	Begin Object Class=UILabel Name=TitleLabelTemplate
		PrivateFlags=PRIVATE_Protected
	End Object
	Begin Object Class=UILabel Name=MessageLabelTemplate
		PrivateFlags=PRIVATE_Protected
	End Object
	Begin Object Class=UICalloutButtonPanel Name=ButtonBarTemplate
		PrivateFlags=PRIVATE_Protected
	End Object

	lblTitle=TitleLabelTemplate
	lblMessage=MessageLabelTemplate
	btnbarChoices=ButtonBarTemplate

	Children.Add(TitleLabelTemplate)
	Children.Add(MessageLabelTemplate)
	Children.Add(ButtonBarTemplate)
}
