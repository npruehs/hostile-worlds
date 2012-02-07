/**
 * Generic browser type for editing UIScenes
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GenericBrowserType_UIScene extends GenericBrowserType
	native;

/**
 * Points to the UISceneManager singleton stored in the BrowserManager.
 */
var	const transient	UISceneManager				SceneManager;

cpptext
{
	/* === GenericBrowserType interface === */
	/**
	 * Initialize the supported classes for this browser type.
	 */
	virtual void Init();

	/**
	 * Display the editor for the object specified.
	 *
	 * @param	InObject	the object to edit.  this should always be a UIScene object.
	 */
	virtual UBOOL ShowObjectEditor( UObject* InObject );

	/**
	 * Returns a list of commands that this object supports (or the object type supports, if InObject is NULL)
	 *
	 * @param	InObjects		The objects to query commands for (if NULL, query commands for all objects of this type.)
	 * @param	OutCommands		The list of custom commands to support
	 */
	virtual void QuerySupportedCommands( class USelection* InObjects, TArray< FObjectSupportedCommandType >& OutCommands ) const;

	/**
	 * Called when the user chooses to delete objects from the generic browser.  Gives the resource type the opportunity
	 * to perform any special logic prior to the delete.
	 *
	 * @param	ObjectToDelete	the object about to be deleted.
	 *
	 * @return	TRUE to allow the object to be deleted, FALSE to prevent the object from being deleted.
	 */
	virtual UBOOL NotifyPreDeleteObject( UObject* ObjectToDelete );

protected:
	/**
	 * Determines whether the specified package is allowed to be saved.
	 *
	 * @param	PackageToSave		the package that is about to be saved
	 * @param	StandaloneObjects	a list of objects from PackageToSave which were marked RF_Standalone
	 */
	virtual UBOOL IsSavePackageAllowed( UPackage* PackageToSave, TArray<UObject*>& StandaloneObjects );

public:
}

DefaultProperties
{
	Description="UI Scenes"
}
