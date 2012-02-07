/**
 * This class manages the UI editor windows.  It's responsible for initializing scenes when they are loaded/created and
 * managing the root scene client for all ui editors.
 * Created by the UIScene generic browser type and stored in the BrowserManager.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UISceneManager extends Object
	native
	transient
	config(Editor)
	inherits(FGlobalDataStoreClientManager,FExec,FCallbackEventDevice);

struct native transient UIResourceInfo
{
	/** pointer to an archetype for a UI resource, such as a widget, style, or state */
	var Object UIResource;

	/** the text that will be displayed in all menus and dialogs for this resource */
	var string FriendlyName;

structcpptext
{
	/** Constructors */
	FUIResourceInfo( UObject* InResource )
	: UIResource(InResource)
	{
		checkSlow(UIResource);
		if ( !UIResource->HasAnyFlags(RF_ClassDefaultObject) )
		{
			FriendlyName = FString::Printf(TEXT("%s (%s)"), *UIResource->GetClass()->GetDescription(), *UIResource->GetName());
		}
		else
		{
			FriendlyName = UIResource->GetClass()->GetDescription();
		}
	}
	/** Copy Constructor */
	FUIResourceInfo( const FUIResourceInfo& Other )
	: UIResource(Other.UIResource), FriendlyName(Other.FriendlyName)
	{
	}

	/** Comparison operators */
	FORCEINLINE UBOOL operator==( const FUIResourceInfo& Other ) const
	{
		return UIResource == Other.UIResource;
	}
	FORCEINLINE UBOOL operator!=( const FUIResourceInfo& Other ) const
	{
		return UIResource != Other.UIResource;
	}
}
};

struct native transient UIObjectResourceInfo extends UIResourceInfo
{
structcpptext
{
	/** Constructors */
	FUIObjectResourceInfo( class UUIObject* InResource );
	/** Copy Constructor */
	FUIObjectResourceInfo( const FUIObjectResourceInfo& Other )
	: FUIResourceInfo(Other)
	{
	}

	/** Comparison operators */
	FORCEINLINE UBOOL operator==( const FUIObjectResourceInfo& Other ) const
	{
		return UIResource == Other.UIResource;
	}
	FORCEINLINE UBOOL operator!=( const FUIObjectResourceInfo& Other ) const
	{
		return UIResource != Other.UIResource;
	}
}
};

struct native transient UIStyleResourceInfo extends UIResourceInfo
{
structcpptext
{
	/** Constructors */
	FUIStyleResourceInfo( class UUIStyle_Data* InResource );
	/** Copy Constructor */
	FUIStyleResourceInfo( const FUIStyleResourceInfo& Other )
	: FUIResourceInfo(Other)
	{
	}

	/** Comparison operators */
	FORCEINLINE UBOOL operator==( const FUIStyleResourceInfo& Other ) const
	{
		return UIResource == Other.UIResource;
	}
	FORCEINLINE UBOOL operator!=( const FUIStyleResourceInfo& Other ) const
	{
		return UIResource != Other.UIResource;
	}
}
};

struct native transient UIStateResourceInfo extends UIResourceInfo
{
structcpptext
{
	/** Constructors */
	FUIStateResourceInfo( class UUIState* InResource );
	/** Copy Constructor */
	FUIStateResourceInfo( const FUIStateResourceInfo& Other )
	: FUIResourceInfo(Other)
	{
	}

	/** Comparison operators */
	FORCEINLINE UBOOL operator==( const FUIStateResourceInfo& Other ) const
	{
		return UIResource == Other.UIResource;
	}
	FORCEINLINE UBOOL operator!=( const FUIStateResourceInfo& Other ) const
	{
		return UIResource != Other.UIResource;
	}
}
};

struct native UIObjectToolbarMapping
{
	/** Name of the widget class to represent */
	var String WidgetClassName;

	/** Icon for the toolbar button */
	var String IconName;

	/** Tooltip for the toolbar button (Should be a localizable lookup) */
	var String Tooltip;

	/** Status bar text for the toolbar button (Should be a localizable lookup) */
	var String HelpText;
};

struct native UITitleRegions
{
	var float	RecommendedPercentage;
	var float	MaxPercentage;
};

/**
 * The UISkin currently providing styles to the scenes in the editor. Only one UISkin can be active at a time.
 */
var	transient 								UISkin								ActiveSkin;

/**
 * Manages all persistent global data stores.  Created when the UISceneManager is initialized.
 */
var	const transient							DataStoreClient						DataStoreManager;

/**
 * Holds an array of scene clients, which correspond to each scene that's been opened or created during this editing session.
 * Scene clients are not removed or deleted when their scene is closed
 */
var const transient 						array<EditorUISceneClient>			SceneClients;

/**
 * The list of placeable widgets types. Used to fill the various "add new widget" menus.  Built when the UISceneManager is initialized.
 */
var const transient							array<UIObjectResourceInfo>			UIWidgetResources;

/**
 * A list of mappings from widgets to information needed by the editor to display toolbar buttons corresponding to widgets. */
var const config							array<UIObjectToolbarMapping>		UIWidgetToolbarMaps;

/**
 * the list of useable UIStyle resources. Built when UISceneManager is initialized.
 */
var const transient							array<UIStyleResourceInfo>			UIStyleResources;

/**
 * the list of useable UIState resources.  Build when UISceneManager is initialized.
 */
var const transient	private{private}		array<UIStateResourceInfo>			UIStateResources;


/**
 * Quick lookup for friendly names for UIState resources.  Built when UISceneManager is initialized.
 */
var const transient							map{UClass*, FUIStateResourceInfo*}	UIStateResourceInfoMap;

/**
 * Variable that stores the max/recommended safe regions for the screen.
 */
var const config							UITitleRegions						TitleRegions;

/**
 * A pointer to the instance of WxDlgUIDataStoreBrowser
 */
var	transient	native	const private{private}	pointer							DlgUIDataStoreBrowser{class WxDlgUIDataStoreBrowser};

cpptext
{
	/**
	 * Performs all initialization for the UI editor system.
	 */
	void Initialize();

	/**
	 * Loads the initial UISkin to use for rendering scenes
	 *
	 * @return	a pointer to the UISkin object corresponding to the default UI Skin
	 */
	class UUISkin* LoadInitialSkin() const;

	/**
	 * Changes the active skin to the skin specified
	 *
	 * @param	NewActiveSkin	the skin that should now be active
	 *
	 * @return	TRUE if the active skin was successfully changed
	 */
	UBOOL SetActiveSkin( UUISkin* NewActiveSkin );

	/**
	 * Builds the list of available widget, style, and state resources.
	 *
	 * @param	bRefresh	if FALSE, only builds the list if the list of resources is currently empty.
	 *						if TRUE, clears the existing list of resources first
	 */
	void InitUIResources( UBOOL bRefresh = FALSE );

	/**
	 * Clears the various resources arrays.
	 */
	void ClearUIResources();

	/**
	 * Determines whether the specified UI resource should be included in the list of placeable widgets.
	 *
	 * @param	UIResource		a UIObject archetype
	 */
	UBOOL IsValidUIResource( UUIObject* UIResource ) const;

	/**
	 * Determines whether the specified style data should be included in the list of useable styles.
	 *
	 * @param	StyleResource	a UUIStyle_Data archetype
	 */
	UBOOL IsValidStyleResource( UUIStyle_Data* StyleResource ) const;

	/**
	 * Determines whether the specified state should be included in the list of available UI states.
	 *
	 * @param	StateResource	a UIState archetype
	 */
	UBOOL IsValidStateResource( UUIState* StateResource ) const;

	/**
	 * Checks to see if any widgets in any of the scenes are currently referencing the passed in style.  If so,
	 * it displays a message box asking the user if they still want to go through with the action.
	 *
	 * @param	StyleToDelete	Style that we want to delete/replace.
	 * @param	bIsReplace		Whether or not this is a replacement operation, if so, display a different message to the user.
	 *
	 * @return	TRUE if it is safe to delete/replace the specified style
	 */
	UBOOL ShouldDeleteStyle( UUIStyle* StyleToDelete, UBOOL bIsReplace) const;

	/**
	 * Creates a new UIScene in the package specified.
	 *
	 * @param	SceneTemplate	the template to use for the new scene
	 * @param	InOuter			the outer for the scene
	 * @param	SceneTag		if specified, the scene will be given this tag when created
	 *
	 * @return	a pointer to the new UIScene that was created.
	 */
	class UUIScene* CreateScene( UUIScene* SceneTemplate, UObject* InOuter, FName SceneTag = NAME_None );

	/**
	 * Create a new scene client and associates it with the specified scene.
	 *
	 * @param	Scene	the scene to be associated with the new scene client.
	 */
	class UEditorUISceneClient* CreateSceneClient( class UUIScene* Scene );

	/**
	 * Find the position for the scene client window containing the scene specified.
	 *
	 * @param	Scene	the scene to search for
	 *
	 * @return	the index into array of SceneClients arry for the scene client associated with the scene specified,
	 *			or INDEX_NONE if that scene has never been edited
	 */
	INT FindSceneIndex( UUIScene* Scene ) const;

	/**
	 * Retrieves the set of selected widgets for scene specified.
	 *
	 * @param	Scene					the scene to get the selected widgets for
	 * @param	out_SelectedWidgets		will be filled with the selected widgets from the specified scene
	 *
	 * @return	TRUE if out_SelectedWidgets was successfully filled with widgets from the specified scene, or
	 *			FALSE if the scene specified isn't currently being edited.
	 */
	UBOOL GetSelectedSceneWidgets( UUIScene* Scene, TArray<UUIObject*>& out_SelectedWidgets ) const;

	/**
	 * Sets the selected widgets for the scene editor associated with the scene specified
	 *
	 * @param	Scene				the scene to get the selected widgets for
	 * @param	SelectedWidgets		the list of widgets to mark as selected
	 *
	 * @return	TRUE if the selection set was accepted
	 */
	UBOOL SetSelectedSceneWidgets( class UUIScene* Scene, TArray<class UUIObject*>& SelectedWidgets );

	/**
	 * Called when the user requests to edit a UIScene.  Creates a new scene client (or finds an existing scene client, if
	 * this isn't the first time the scene has been edited during this session) to handle initialization and de-initialization
	 * of the scene, and passes the edit scene request to the scene client.
	 *
	 * @param	Scene	the scene to open
	 *
	 * @return	TRUE if the scene was successfully opened and initialized
	 */
	UBOOL OpenScene( class UUIScene* Scene );

	/**
	 * Called when the editor window for the specified scene is closed.  Passes the notification to the appropriate
	 * scene client for further processing.
	 *
	 * @param	Scene	the scene to deactivate
	 */
	void SceneClosed( class UUIScene* Scene );

	/**
	 * Called when the user selects to delete a scene in the generic browser.
	 */
	void NotifySceneDeletion( UUIScene* Scene );

	/** @return Returns the pointer to the datastore browser dialog. */
	WxDlgUIDataStoreBrowser* GetDataStoreBrowser();

	/**
	 * Determines whether the data store subsystem has been initialized
	 */
	UBOOL AreDataStoresInitialized() const
	{
		return DlgUIDataStoreBrowser != NULL;
	}


	/* ==============================================
		FGlobalDataStoreClientManager interface
	============================================== */
	/**
	 * Initializes the singleton data store client that will manage the global data stores.
	 */
	virtual void InitializeGlobalDataStore();

	/* ==============================================
		FExec interface
	============================================== */
	virtual UBOOL Exec(const TCHAR* Cmd,FOutputDevice& Ar);

	/* === FCallbackEventDevice interface === */
	/**
	 * Called when a package containing a UISKin is loaded.
	 *
	 * @param	LoadedSkin	the skin that was loaded.
	 */
	virtual void Send( ECallbackEventType InType, class UObject* LoadedSkin );
}

/**
 * Retrieves the list of UIStates which are supported by the specified widget.
 *
 * @param	out_SupportedStates		the list of UIStates supported by the specified widget class.
 * @param	WidgetClass				if specified, only those states supported by this class will be returned.  If not
 *									specified, all states will be returned.
 */
native final function GetSupportedUIStates( out array<UIStateResourceInfo> out_SupportedStates, optional class<UIScreenObject> WidgetClass ) const;

DefaultProperties
{

}
