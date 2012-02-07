/**
 * This is a special type of scene used for allowing UIPrefabs to be opened for edit in the UI editor.  It is created
 * on demand and is never saved into a package.  It only allows a single child widget to be added which must be a
 * UIPrefab object.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIPrefabScene extends UIScene
	native(UIPrivate)
	transient
	inherits(FCallbackEventDevice)
	notplaceable;

cpptext
{
	/* === UUIScene interface === */
	/* === FCallbackEventDevice interface === */
	/**
	 * Handles validating that this scene's UIPrefab is still a valid widget after each undo is performed.
	 */
	virtual void Send( ECallbackEventType InType );

	/* === UUIScreenObject interface === */
	/**
	 * Notification that this scene becomes the active scene.  Called after other activation methods have been called
	 * and after focus has been set on the scene.
	 *
	 * This version registers this UIPrefabScene as an observer for CALLBACK_Undo events.
	 *
	 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
	 *									as a result of closing another scene or manually moving this scene in the stack.
	 */
	virtual void OnSceneActivated( UBOOL bInitialActivation );

	/**
	 * Called just after this scene is removed from the active scenes array; unregisters this scene as an observer for undo callbacks.
	 */
	virtual void Deactivate();

	/**
	 * Insert a widget at the specified location
	 *
	 * @param	NewChild		the widget to insert; it must be a UIPrefab.
	 * @param	InsertIndex		unused
	 * @param	bRenameExisting	unused
	 *
	 * @return	the position that that the child was inserted in, or INDEX_NONE if the widget was not inserted
	 */
	virtual INT InsertChild(class UUIObject* NewChild,INT InsertIndex=INDEX_NONE,UBOOL bRenameExisting=TRUE);

	/**
	 * Returns the default parent to use when placing widgets using the UI editor.  This widget is used when placing
	 * widgets by dragging their outline using the mouse, for example.
	 *
	 * @return	a pointer to the widget that will contain newly placed widgets when a specific parent widget has not been
	 *			selected by the user.
	 */
	virtual UUIScreenObject* GetEditorDefaultParentWidget();

	/* === UObject interface === */

	/**
	 * Presave function. Gets called once before an object gets serialized for saving. This function is necessary
	 * for save time computation as Serialize gets called three times per object from within UObject::SavePackage.
	 *
	 * @warning: Objects created from within PreSave will NOT have PreSave called on them!!!
	 *
	 * This version overrides the UIScene version to NOT call CalculateSequenceLoadFlags (that's handled by each UIPrefab).
	 */
	virtual void PreSave();
}


