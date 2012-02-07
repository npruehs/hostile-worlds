/**
 * This widget class is a container for widget archetypes.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Known issues:
 *	- [FIXED?] copy/paste operations aren't propagated to UIPrefabInstances
 *	- need support for specifying "input alias => raw input key" mappings for widget archetypes (UIInputAliasStateMap/UIInputAliasClassMap/UIInputConfiguration)
 *	- [FIXED?] reformatting doesn't occur for instanced UIList widgets or widgets which have UIComp_DrawString components (either when placing or updating).
 *	- [FIXED] modifying docking relationships using the docking editor doesn't propagate changes to instances.
 *	- [FIXED] most changes made through kismet editor (adding new seq. objects, removing objects, etc.) aren't propagated to instances at all
 */
class UIPrefab extends UIObject
	native(UIPrivate)
	notplaceable
	HideDropDown;

/**
 * Version number for this prefab.  Each time a UIPrefab is saved, the PrefabVersion is incremented.  This number is used
 * to detect when UIPrefabInstances based on this prefab need to be updated.
 */
var					const int						PrefabVersion;

/**
 * Version number for this prefab when it was loaded from disk.  Used to determine whether a modification to a widget contained
 * in this prefab should increment the PrefabVersion (i.e. PrefabVersion should only be incremented if InternalPrefabVersion
 * matches PrefabVersion).
 */
var	private{private} const int						InternalPrefabVersion;

/** Snapshot of Prefab used for thumbnail in the browser. */
var		editoronly	const Texture2D					PrefabPreview;

/**
 * Used to track the number of calls to Pre/PostEditChange for widgets contained within this UIPrefab.  When PreEditChange
 * or PostEditChange is called on a widget contained within a UIPrefab, rather than calling the UObject version, it is
 * instead routed to the owning UIPrefab.
 *
 * When UIPrefab receives a call to PreEditChange, the UIPrefab calls SavePrefabInstances if ModificationCounter is 0, then
 * increments the counter.
 * When UIPrefab receives a call to PostEditChange, it decrements the counter and calls LoadPrefabInstances once it reaches 0.
 */
var		transient	const int						ModificationCounter;

/**
 * Stores the size of the bounding region for the prefab's widgets prior to becoming part of the prefab.  This value is used as the initial
 * size for PrefabInstances created from this prefab.
 *
 * These extent values should always be resolved using the scene as the "OwningWidget"
 */
var(Appearance)		const	UIScreenValue_Extent	OriginalWidth;
var(Appearance)		const	UIScreenValue_Extent	OriginalHeight;

cpptext
{
	/* === UUIPrefab interface === */
	/**
	 * Creates archetypes for the specified widgets and adds the archetypes to this UIPrefab.
	 *
	 * @param	WidgetPairs				[in]	the widgets to create archetypes for, along with their screen positions (in pixels)
	 *									[out]	receives the list of archetypes that were created from the WidgetInstances
	 *
	 * @return	TRUE if archetypes were created and added to this UI archetype successfully.  FALSE if this UIPrefab
	 *			is not an archetype, if the widgets specified are already archetypes, or couldn't other
	 *			be created.
	 */
	UBOOL CreateWidgetArchetypes( TArray<struct FArchetypeInstancePair>& WidgetPairs, const FBox& BoundingRegion );

	/**
	 * Generates a name for the widget specified in the format 'WidgetClass_Arc_##', where ## corresponds to the number of widgets of that
	 * class already contained by this wrapper (though not completely representative, since other widget of that class may have been previously
	 * removed).
	 *
	 * @param	WidgetTypeCounts	contains the number of widgets of each class contained by this wrapper
	 * @param	WidgetInstance		the widget class to generate a unique archetype name for
	 *
	 * @return	a widget archetype name guaranteed to be unique within the scope of this wrapper.
	 */
	FName GenerateUniqueArchetypeName( TMap<UClass*,INT>& WidgetTypeCounts, UClass* WidgetClass ) const;

	/**
	 * Creates an instance of this UIPrefab; does NOT add the new UIPrefabInstance to the specified DestinationOwner's
	 * Children array.
	 *
	 * @param	DestinationOwner	the widget to use as the parent for the new PrefabInstance
	 * @param	DestinationName		the name to use for the new PrefabInstance.
	 *
	 * @return	a pointer to a UIPrefabInstance created from this UIPrefab
	 */
	class UUIPrefabInstance* InstancePrefab( UUIScreenObject* DestinationOwner, FName DestinationName );

	/**
	 * Notifies all instances of this UIPrefab to serialize their current property values against this UIPrefab.
	 * Called just before something is modified in a widget contained in this UIPrefab.
	 */
	void SavePrefabInstances();

	/**
	 * Notifies all instances of this UIPrefab to re-initialize and reload their property data.  Called just after
	 * something is modified in a widget contained in this UIPrefab.
	 */
	void LoadPrefabInstances();

	/**
	 * Remaps object references within the specified set of objects.  Iterates through the specified map, applying an
	 * FReplaceObjectReferences archive to each value in the map, using the map itself as the replacement map.
	 *
	 * @param	ReplacementMap		map of archetype => instances or instances => archetypes to use for replacing object
	 *								references
	 * @param	bNullPrivateRefs	should we null references to any private objects
	 * @param	SourceObjects		if specified, applies the replacement archive on these objects instead of the values (objects)
	 *								in the ReplacementMap.
	 */
	static void ConvertObjectReferences( TMap<UObject*,UObject*>& ReplacementMap, UBOOL bNullPrivateRefs, TArray<UObject*>* SourceObjects=NULL );

	/**
	 * Determines whether the widget is allowed to be added to a UI prefab.
	 *
	 * @param	Widget	the widget to check
	 *
	 * @return	TRUE if this widget is allowed to be added to a UI prefab.
	 */
	static UBOOL SupportsWidgetType( UUIObject* Widget );

	/* === UIObject interface === */
	/**
	 * UIPrefabs don't render anything.
	 */
	virtual void Render_Widget(FCanvas*) {}

	/* === UUIScreenObject interface === */
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

	/**
	 * Determines whether to change the Outer of this widget if the widget's Owner doesn't match it's Outer.
	 */
	virtual UBOOL RequiresParentForOuter() const { return FALSE; }

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
	 * Called just before just object is saved to disk.  Updates the value of InternalPrefabVersion to match PrefabVersion,
	 * and prevents the sequence objects contained in this prefab from being marked RF_NotForServer|RF_NotForClient.
	 */
	virtual void PreSave();

	/**
	 * Note that the object has been modified.  If we are currently recording into the
	 * transaction buffer (undo/redo), save a copy of this object into the buffer and
	 * marks the package as needing to be saved.
	 *
	 * @param	bAlwaysMarkDirty	if TRUE, marks the package dirty even if we aren't
	 *								currently recording an active undo/redo transaction
	 */
	virtual void Modify( UBOOL bAlwaysMarkDirty=FALSE );

	/**
	 * Returns a one line description of an object for viewing in the thumbnail view of the generic browser.
	 *
	 * This version prints the number of widgets contained in this prefab.
	 */
	virtual FString GetDesc();

	/**
	 * Builds a list of UIPrefabInstances which have this UIPrefab as their SourcePrefab.
	 *
	 * @param	Instances	receives the list of UIPrefabInstances which have this UIPrefab as their SourcePrefab.
	 */
	virtual void GetArchetypeInstances( TArray<UObject*>& Instances );

	/**
	 * Increments the value of ModificationCounter.  If the previous value was 0, calls SavePrefabInstances.
	 * Called just before something is modified in a widget contained in this UIPrefab.
	 *
	 * @param	AffectedObjects		ignored
	 */
	virtual void SaveInstancesIntoPropagationArchive( TArray<UObject*>& AffectedObjects );

	/**
	 * Decrements the value of ModificationCounter.  If the new value is 0, calls LoadPrefabInstances.
	 * Called just after something is modified in a widget contained in this UIPrefab.
	 *
	 * @param	AffectedObjects		ignored
	 */
	virtual void LoadInstancesFromPropagationArchive( TArray<UObject*>& AffectedObjects );
}

/**
 * This struct is used for various purposes to track information about a widget instance and an associated archetype.
 */
struct native transient ArchetypeInstancePair
{
	/** Holds a reference to a widget archetype */
	var	transient	UIObject	WidgetArchetype;

	/**
	 * Holds a reference to the widget instance; depending on where this struct is used, could be an instance of WidgetArchetype
	 * or might be e.g. the widget instance used to create WidgetArchetype (when creating a completely new UIPrefab).
	 */
	var transient	UIObject	WidgetInstance;

	/**
	 * Used to stores the RenderBounds of WidgetArchetype in cases where WidgetArchetype is not in the scene's children array.
	 */
	var	transient	float		ArchetypeBounds[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Used to stores the RenderBounds of WidgetInstance in cases where WidgetInstance is not in the scene's children array.
	 */
	var	transient	float		InstanceBounds[EUIWidgetFace.UIFACE_MAX];

	structcpptext
	{
		/** Constructors */
		FArchetypeInstancePair()
		: WidgetArchetype(NULL), WidgetInstance(NULL)
		{
			appMemzero(ArchetypeBounds, sizeof(ArchetypeBounds));
			appMemzero(InstanceBounds, sizeof(InstanceBounds));
		}

		FArchetypeInstancePair( UUIObject* InArchetype, UUIObject* InInstance )
		: WidgetArchetype(InArchetype), WidgetInstance(InInstance)
		{
			appMemzero(ArchetypeBounds, sizeof(ArchetypeBounds));
			appMemzero(InstanceBounds, sizeof(InstanceBounds));
		}

		/** Comparison operators */
		inline UBOOL operator==( const FArchetypeInstancePair& Other ) const
		{
			return appMemcmp(this, &Other, sizeof(FArchetypeInstancePair)) == 0;
		}
		inline UBOOL operator!=( const FArchetypeInstancePair& Other ) const
		{
			return appMemcmp(this, &Other, sizeof(FArchetypeInstancePair)) != 0;
		}

		/** To allow this struct to be used as the key in a TMap */
		friend inline DWORD GetTypeHash( const FArchetypeInstancePair& Pair )
		{
			return PointerHash(Pair.WidgetArchetype, PointerHash(Pair.WidgetInstance));
		}
	}
};

DefaultProperties
{
	OriginalWidth=(Orientation=UIORIENT_Horizontal,ScaleType=UIEXTENTEVAL_PercentScene)
	OriginalHeight=(Orientation=UIORIENT_Vertical,ScaleType=UIEXTENTEVAL_PercentScene)
}
