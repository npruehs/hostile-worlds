/**
 * This widget class is a container for widgets which are instances of a UIPrefab.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIPrefabInstance extends UIObject
	native(UIPrivate)
	notplaceable
	HideDropDown;

cpptext
{
	/* === UIPrefabInstance interface === */
	/**
	 * Convert this prefab instance to look like the Prefab archetype version of it (by changing object refs to archetype refs and
	 * converting positions to local space). Then serialise it, so we only get things that are unique to this instance. We store this
	 * archive in the PrefabInstance.
	 */
	void SavePrefabDifferences();

private:
	/**
	 * Generates a list of all widget and sequence archetypes contained in the specified parent which have never been instanced into this
	 * UIPrefabInstance (and thus, have been newly added since this UIPrefabInstance was last saved), recursively.
	 *
	 * @param	ParentArchetype			a pointer to a widget archetype; must be contained within this UIPrefabInstance's SourcePrefab.
	 * @param	NewWidgetArchetypes		receives the list of archetype widgets contained within ParentArchetype which have never been instanced into this
	 *									UIPrefabInstance.
	 * @param	NewSequenceArchetypes	receives the list of sequence object archetypes contained within ParentArchetype which do not exist in this UIPrefabInstance;
	 *									will not include sequence objects contained in widgets that are also newly added.
	 */
	void FindNewArchetypes( class UUIObject* ParentArchetype, TArray<class UUIObject*>& NewWidgetArchetypes, TArray<class USequenceObject*>& NewSequenceArchetypes );

	/**
	 * Helper method for recursively finding sequence archetype objects which have been added since this UIPrefabInstance was last updated.
	 *
	 * @param	ParentArchetype			a pointer to a widget archetype; must be contained within this UIPrefabInstance's SourcePrefab.
	 * @param	SequenceToCheck			the sequence to search for new archetypes in
	 * @param	NewSequenceArchetypes	receives the list of sequence object archetypes which do not exist in this UIPrefabInstance
	 */
	void FindNewSequenceArchetypes( class UUIObject* ParentArchetype, class USequence* SequenceToCheck, TArray<class USequenceObject*>& NewSequenceArchetypes );

public:

	/**
	 * Reinitializes this UIPrefabInstance against its SourcePrefab.  The main purpose of this function (over standard archetype propagation)
	 * is to convert all inter-object references within the PrefabInstance into references to their archetypes.  This is the only way that
	 * changes to object references in a UIPrefab can be propagated to UIPrefabInstances, since otherwise the UIPrefabInstance would serialize
	 * those object references.
	 *
	 * This will destroy/create objects as necessary.
	 */
	void UpdateUIPrefabInstance();

	/**
	 * Iterates through the ArchetypeToInstanceMap and verifies that the archetypes for each of this PrefabInstance's actors exist.
	 * For any actors contained by this PrefabInstance that do not have a corresponding archetype, removes the actor from the
	 * ArchetypeToInstanceMap.  This is normally caused by adding a new actor to a PrefabInstance, updating the source Prefab, then loading
	 * a new map without first saving the package containing the updated Prefab.  When the original map is reloaded, though it contains
	 * an entry for the newly added actor, the source Prefab's linker does not contain an entry for the corresponding archetype.
	 *
	 * @return	TRUE if one or more archetypes were NULL; FALSE if each pair in the ArchetypeToInstanceMap was a valid 'Key'
	 */
	UBOOL HasMissingArchetypes();

	/** Copy information to a FUIPrefabUpdateArc from this PrefabInstance for updating a PrefabInstance with. */
	void CopyToArchive(FUIPrefabUpdateArc* InArc);

	/** Copy information from a FUIPrefabUpdateArc into this PrefabInstance for saving etc. */
	void CopyFromArchive( const FUIPrefabUpdateArc* InArc );

	/* === UIObject interface === */
	/**
	 * UIArchetype wrappers don't render anything.
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
	 * Called immediately after a child has been removed from this screen object.
	 *
	 * @param	WidgetOwner		the screen object that the widget was removed from.
	 * @param	OldChild		the widget that was removed
	 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
	 *							between the widgets being removed from being severed.
	 */
	virtual void NotifyRemovedChild( UUIScreenObject* WidgetOwner, UUIObject* OldChild, TArray<UUIObject*>* ExclusionSet=NULL );

	/* === UObject interface === */
	virtual void			Serialize(FArchive& Ar);
	virtual void			PreSave();

#if REQUIRES_SAMECLASS_ARCHETYPE
	/**
	 * Provides PrefabInstance & UIPrefabInstanc objects with a way to override incorrect behavior in ConditionalPostLoad()
	 * until different-class archetypes are supported.
	 *
	 * @fixme - temporary hack; correct fix would be to support archetypes of a different class
	 *
	 * @return	pointer to an object instancing graph to use for logic in ConditionalPostLoad().
	 */
	virtual struct FObjectInstancingGraph* GetCustomPostLoadInstanceGraph();
#endif

	/**
	 * Serializes the unrealscript property data located at Data.  When saving, only saves those properties which differ from the corresponding
	 * value in the specified 'DiffObject' (usually the object's archetype).
	 *
	 * @param	Ar				the archive to use for serialization
	 * @param	DiffObject		the object to use for determining which properties need to be saved (delta serialization);
	 *							if not specified, the ObjectArchetype is used
	 * @param	DefaultsCount	maximum number of bytes to consider for delta serialization; any properties which have an Offset+ElementSize greater
	 *							that this value will NOT use delta serialization when serializing data;
	 *							if not specified, the result of DiffObject->GetClass()->GetPropertiesSize() will be used.
	 */
	virtual void SerializeScriptProperties( FArchive& Ar, UObject* DiffObject=NULL, INT DiffCount=0 ) const;

	/**
	 * Callback used to allow object register its direct object references that are not already covered by
	 * the token stream.
	 *
	 * @param ObjectArray	array to add referenced objects to via AddReferencedObject
	 */
	void AddReferencedObjects( TArray<UObject*>& ObjectArray );

	/**
	 * Callback for retrieving a textual representation of natively serialized properties.  Child classes should implement this method if they wish
	 * to have natively serialized property values included in things like diffcommandlet output.
	 *
	 * @param	out_PropertyValues	receives the property names and values which should be reported for this object.  The map's key should be the name of
	 *								the property and the map's value should be the textual representation of the property's value.  The property value should
	 *								be formatted the same way that UProperty::ExportText formats property values (i.e. for arrays, wrap in quotes and use a comma
	 *								as the delimiter between elements, etc.)
	 * @param	ExportFlags			bitmask of EPropertyPortFlags used for modifying the format of the property values
	 *
	 * @return	return TRUE if property values were added to the map.
	 */
	virtual UBOOL GetNativePropertyValues( TMap<FString,FString>& out_PropertyValues, DWORD ExportFlags=0 ) const;
}

/** The prefab that this is an instance of. */
var		const	archetype		UIPrefab	SourcePrefab;

/**
 * The version for this UIPrefabInstance.  When the value of PrefabInstanceVersion does not match the value of SourcePrefab's
 * PrefabVersion, it indicates that SourcePrefab has been updated since the last time this UIPrefabInstance was updated.
 */
var		const		int						PrefabInstanceVersion;

/**
 * Mapping from archetypes in the SourcePrefab to instances of those archetypes in this UIPrefabInstance.
 * Used by UpdatePrefabInstance to determine the archetypes which were added to SourcePrefab since the last time this
 * UIPrefabInstance was updated, as well as tracking which widgets have been removed from this UIPrefabInstance by the user.
 *
 * This map holds references to all objects in the UIPrefab and UIPrefabInstance, including any components and subobjects.
 * A NULL key indicates that the widget was removed from the UIPrefab; the instance associated with the NULL key will be removed
 * from the UIPrefabInstance's list of children the next time that UpdateUIPrefabInstance is called.
 * A NULL value indicates that the user manually removed an instanced widget from the UIPrefabInstance.  When this UIPrefabInstance
 * is updated, that widget archetype will not be re-instanced.
 */
var		const native Map{UObject*,UObject*}	ArchetypeToInstanceMap;

/** Contains the epic+licensee version that this PrefabInstance's package was saved with. */
var	editoronly	const			int			PI_PackageVersion;
var	editoronly	const			int			PI_LicenseePackageVersion;

var	editoronly	const			int			PI_DataOffset;	// the offset into PI_Bytes for this UIPrefabInstance's property data
var	editoronly	const	array<byte>			PI_Bytes;
var	editoronly	const	array<object>		PI_CompleteObjects;
var	editoronly	const	array<object>		PI_ReferencedObjects;
var	editoronly	const	array<string>		PI_SavedNames;
var	const native	Map{UObject*,INT}		PI_ObjectMap;

/**
 * Converts all widgets in this UIPrefabInstance into normal widgets and removes the UIPrefabInstance from the scene.
 */
native final function DetachFromSourcePrefab();

defaultproperties
{
	// the defaults for the PrefabInstance file versions MUST be -1 (@see UUIPrefabInstance::Copy*Archive)
	PI_PackageVersion=INDEX_NONE
	PI_LicenseePackageVersion=INDEX_NONE
}

