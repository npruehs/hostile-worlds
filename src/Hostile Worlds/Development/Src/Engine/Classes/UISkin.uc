/**
 * Represents a collection of UIStyles.
 * <p>
 * When a style is created, it is assigned a persistent STYLE_ID.  All styles for a particular widget are stored in a single
 * unreal package file.  The root object for this package is a UISkin object.  The resources required by the style
 * may also be stored in the skin file, or they might be located in another package.
 * <p>
 * A game UI is required to have at least one UISkin package that will serve as the default skin.  Only one
 * UISkin can be active at a time, and all custom UISkins are based on the default UISkin.  Custom UISkins may decide to
 * override a style completely by creating a new style that has the same STYLE_ID as the skin to be replaced, and placing
 * that skin into the StyleLookupTable under that STYLE_ID.  Any styles which aren't specifically overridden in the custom
 * UISkin are inherited from the default skin.
 *
 * By default, widgets will automatically be mapped to the customized version of the UIStyle contained in the custom
 * UISkin, but the user may choose to assign a completely different style to a particular widget.  This only changes
 * the style of that widget for that skin set and any UISkin that is based on the custom UISkin.  Custom UISkins can be
 * hierarchical, in that custom UISkins can be based on other custom UISkins.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UISkin extends UIDataStore
	native(inherit)
	nontransient;

/**
 * Associates an arbitrary
 */
struct native UISoundCue
{
	/**
	 * the name for this UISoundCue.  this name is used by widgets to reference this sound, and must match
	 * one of the values from the GameUISceneCient's list of available sound cue names
	 */
	var		name		SoundName;

	/** the actual sound that should be played */
	var		SoundCue	SoundToPlay;

structcpptext
{
	/** Constructors */
	FUISoundCue() {}
	FUISoundCue(EEventParm)
	{
		appMemzero(this,sizeof(FUISoundCue));
	}
}
};

//@todo - need a localized friendly name here

/** the styles stored in this UISkin */
var		const 	instanced	protected{protected}	array<UIStyle>					Styles;

/**
 * The group names used by the styles in the skin package
 */
var		const 				protected{protected}	array<string>					StyleGroups;

/** the UI sound cues contained in this UISkin */
var		const				protected{protected}	array<UISoundCue>				SoundCues;

/**
 * maps STYLE_ID to the UIStyle that corresonds to that STYLE_ID.  Used for quickly finding a UIStyle
 * based on a STYLE_ID.  Built at runtime as the UISkin serializes its list of styles
 */
var		const	native	transient			Map{struct FSTYLE_ID,class UUIStyle*}	StyleLookupTable;

/**
 * Maps StyleTag to the UIStyle that has that tag.  Used for quickly finding a UIStyle based on a style tag.
 * Built at runtime as the UISkin serializes its list of styles.
 */
var		const	native	transient			Map{FName,class UUIStyle*}				StyleNameMap;

/**
 * Contains the style group names for this style and all parent styles.
 */
var		const	transient			array<string>						StyleGroupMap;

/**
 * The cursors contained by this skin.  Maps a unique tag (i.e. Arrow) to a cursor resource.
 */
var		const	native	duplicatetransient	Map{FName,struct FUIMouseCursor}		CursorMap;

/**
 * Maps UI sound cue names to their corresponding sound cues.  Used for quick lookup of USoundCues based on the UI sound cue name.
 * Built at runtime from the SoundCues array.
 */
var		const	native	transient			Map{FName,class USoundCue*}				SoundCueMap;

cpptext
{
	/* === UUISkin interface === */
	/**
	 * Called when this skin is set to be the UI's active skin.  Initializes all styles and builds the lookup tables.
	 */
	void Initialize();

	/**
	 * Fills the values of the specified maps with the styles contained by this skin and all this skin's archetypes.
	 */
	virtual void InitializeLookupTables( TMap<struct FSTYLE_ID,class UUIStyle*>& out_StyleIdMap, TMap<FName,class UUIStyle*>& out_StyleNameMap, TMap<FName,class USoundCue*>& out_SoundCueMap, TArray<FString>& out_GroupNameMap );

	/**
	 * Creates a new style within this skin.
	 *
	 * @param	StyleClass		the class to use for the new style
	 * @param	StyleTag		the unique tag to use for creating the new style
	 * @param	StyleTemplate	the template to use for the new style
	 * @param	bAddToSkin		TRUE to automatically add this new style to this skin's list of styles
	 */
	virtual UUIStyle* CreateStyle( UClass* StyleClass, FName StyleTag, class UUIStyle* StyleTemplate=NULL, UBOOL bAddToSkin=TRUE );

	/**
	 * Creates a new style using the template provided and replaces its entry in the style lookup tables.
	 * This only works if the outer of the style template is a archetype of the this skin.
	 *
	 * @param	StyleTemplate	the template to use for the new style
	 * @return	Pointer to the style that was created to replace the archetype's style.
	 */
	virtual UUIStyle* ReplaceStyle( class UUIStyle* StyleTemplate );

	/**
	 * Deletes the specified style and replaces its entry in the lookup table with this skin's archetype style.
	 * This only works if the provided style's outer is this skin.
	 *
	 * @return	TRUE if the style was successfully removed.
	 */
	virtual UBOOL DeleteStyle( class UUIStyle* InStyle );

	/**that
	 * Adds the specified style to this skin's list of styles.
	 *
	 * @return	TRUE if the style was successfully added to this skin.
	 */
	virtual UBOOL AddStyle( class UUIStyle* NewStyle );

	/**
	 * Retrieve the style ID associated with a particular style name
	 */
	FSTYLE_ID FindStyleID( FName StyleName ) const;

	/**
	 * Retrieve the style associated with a particular style name
	 */
	UUIStyle* FindStyle( FName StyleName ) const;

	/**
	 * Determines whether the specified style is contained in this skin
	 *
	 * @param	bIncludeInheritedStyles		if FALSE, only returns true if the specified style is in this skin's Styles
	 *										array; otherwise, also returns TRUE if the specified style is contained by
	 *										any base skins of this one.
	 *
	 * @return	TRUE if the specified style is contained by this skin, or one of its base skins
	 */
	UBOOL ContainsStyle( UUIStyle* StyleToSearchFor, UBOOL bIncludeInheritedStyles=FALSE ) const;

	/**
	 * Adds a new mouse cursor resource to this skin.
	 *
	 * @param	CursorTag			the name to use for the mouse cursor.  this will be the name that must be used to retrieve
	 *								this mouse cursor via GetCursorResource()
	 * @param	CursorResource		the mouse cursor to add
	 *
	 * @return	TRUE if the cursor was successfully added to the skin.  FALSE if the resource was invalid or there is already
	 *			another cursor using the specified tag.
	 */
	UBOOL AddCursorResource( FName CursorTag, const FUIMouseCursor& CursorResource );

	/**
	 * Makes any necessary internal changes when this style has been modified
	 *
	 * @param	Style	style in this skin which data has been modified
	 */
	void NotifyStyleModified( class UUIStyle* Style );

	enum EDerivedType
	{
		DERIVETYPE_DirectOnly,
		DERIVETYPE_All,
	};

	enum EStyleSearchType
	{
		SEARCH_SameSkinOnly,
		SEARCH_AnySkin,
	};

	/**
	 * Generate a list of UISkin objects in memory that are derived from the specified skin.
	 */
	static void GetDerivedSkins( const UUISkin* ParentSkin, TArray<UUISkin*>& out_DerivedSkins, EDerivedType DeriveFilter=DERIVETYPE_All );

	/**
	 * Obtains a list of styles that derive from the ParentStyle (i.e. have ParentStyle in their archetype chain)
	 *
	 * @param	ParentStyle		the style to search for archetype references to
	 * @param	DerivedStyles	[out] An array that will be filled with pointers to the derived styles
	 * @param	DeriveType		if DERIVETYPE_DirectOnly, only styles that have ParentStyle as the value for ObjectArchetype will added
	 *							out_DerivedStyles. if DERIVETYPE_All, any style that has ParentStyle anywhere in its archetype chain
	 *							will be added to the list.
	 * @param	SearchType		if SEARCH_SameSkinOnly, only styles contained by this skin will be considered.  if SEARCH_AnySkin, all loaded styles will be considered.
	 */
	void GetDerivedStyles( const UUIStyle* ParentStyle, TArray<UUIStyle*>& out_DerivedStyles, EDerivedType DeriveType, EStyleSearchType SearchType=SEARCH_AnySkin );

	/**
     * Checks if this Tag name is currently used in this Skin
     *
     * @param	Tag		checks if this tag exists in the skin
     */
    UBOOL IsUniqueTag( const FName & Tag);

	/* === UIDataStore interface === */

	/**
	 * Retrieves the tag used for referencing this data store.  Normally corresponds to Tag, but may be different for some special
	 * data stores.
	 *
	 * Always returns "Scenes" in case the skin's Tag is changed.
	 */
	virtual FName GetDataStoreID() const { return TEXT("Styles"); }

	/* === UIDataProvider interface === */
	/**
	 * This data store cannot generate string nodes.
	 */
	virtual UBOOL GetDataStoreValue( const FString& MarkupString, struct FUIProviderFieldValue& out_FieldValue ) { return FALSE; }

	/**
	 * Searches for the Style specified and if found changes the node modifier's
	 *
	 * @param	StyleName	the name of the style to apply - must match the StyleTag of a style in this skin (or a base skin).
	 * @param	StyleData	the style data to apply the changes to.
	 *
	 * @return	TRUE if a style was found with the specified StyleName, FALSE otherwise.
	 */
	virtual UBOOL ParseStringModifier( const FString& StyleName, struct FUIStringNodeModifier& StyleData );

	/**
	 * Generates filler data for a given tag.  This is used by the editor to generate a preview that gives the
	 * user an idea as to what a bound datastore will look like in-game.
	 *
 	 * @param		DataTag		the tag corresponding to the data field that we want filler data for
 	 *
	 * @return		this data provider cannot generate string nodes, so the return value is always an empty string.
	 */
	virtual FString GenerateFillerData( const FString& DataTag ) { return TEXT(""); }

	/* === UObject interface === */
	/**
	 * I/O function
	 */
	virtual void Serialize( FArchive& Ar );

	/**
	 * Callback used to allow object register its direct object references that are not already covered by
	 * the token stream.
	 *
	 * @param ObjectArray	array to add referenced objects to via AddReferencedObject
	 */
	virtual void AddReferencedObjects( TArray<UObject*>& Objects );

	/**
	 * Called when this object is loaded from an archive.  Fires a callback which notifies the UI editor that this skin
	 * should be re-initialized if it's the active skin.
	 */
	virtual void PostLoad();

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

/* == Natives == */

/**
 * Retrieve the list of styles available from this skin.
 *
 * @param	out_Styles					filled with the styles available from this UISkin, including styles contained by parent skins.
 * @param	bIncludeInheritedStyles		if TRUE, out_Styles will also contain styles inherited from parent styles which
 *										aren't explicitely overridden in this skin
 */
native final function GetAvailableStyles( out array<UIStyle> out_Styles, optional bool bIncludeInheritedStyles=true );

/**
 * Looks up the cursor resource associated with the specified name in this skin's CursorMap.
 *
 * @param	CursorName	the name of the cursor to retrieve.
 *
 * @return	a pointer to an instance of the resource associated with the cursor name specified, or NULL if no cursors
 *			exist that are using that name
 */
native final function UITexture	GetCursorResource( name CursorName );

/**
 * Adds a new sound cue mapping to this skin's list of UI sound cues.
 *
 * @param	SoundCueName	the name to use for this UISoundCue.  should correspond to one of the values of the UIInteraction.SoundCueNames array.
 * @param	SoundToPlay		the sound cue that should be associated with this name; NULL values are OK.
 *
 * @return	TRUE if the sound mapping was successfully added to this skin; FALSE if the specified name was invalid or wasn't found in the UIInteraction's
 *			array of available sound cue names.
 */
native final function bool AddUISoundCue( name SoundCueName, SoundCue SoundToPlay );

/**
 * Removes the specified sound cue name from this skin's list of UISoundCues
 *
 * @param	SoundCueName	the name of the UISoundCue to remove.  should correspond to one of the values of the UIInteraction.SoundCueNames array.
 *
 * @return	TRUE if the sound mapping was successfully removed from this skin or this skin didn't contain any sound cues using that name;
 */
native final function bool RemoveUISoundCue( name SoundCueName );

/**
 * Retrieves the SoundCue associated with the specified UISoundCue name.
 *
 * @param	SoundCueName	the name of the sound cue to find.  should correspond to the SoundName for a UISoundCue contained by this skin
 * @param	out_UISoundCue	will receive the value for the sound cue associated with the sound cue name specified; might be NULL if there
 *							is no actual sound cue associated with the sound cue name specified, or if this skin doesn't contain a sound cue
 *							using that name (use the return value to determine which of these is the case)
 *
 * @return	TRUE if this skin contains a UISoundCue that is using the sound cue name specified, even if that sound cue name is not assigned to
 *			a sound cue object; FALSE if this skin doesn't contain a UISoundCue using the specified name.
 */
native final function bool GetUISoundCue( name SoundCueName, out SoundCue out_UISoundCue );

/**
 * Retrieves the list of UISoundCues contained by this UISkin.
 */
native final function GetSkinSoundCues( out array<UISoundCue> out_SoundCues );

/**
 * @return	TRUE if the specified group name exists and was inherited from this skin's base skin; FALSE if the group name
 *			doesn't exist or belongs to this skin.
 */
native final function bool IsInheritedGroupName( string StyleGroupName ) const;

/**
 * Adds a new style group to this skin.
 *
 * @param	StyleGroupName	the style group name to add
 *
 * @return	TRUE if the group name was successfully added.
 */
native final function bool AddStyleGroupName( string StyleGroupName );

/**
 * Removes a style group name from this skin.
 *
 * @param	StyleGroupName	the group name to remove
 *
 * @return	TRUE if this style group was successfully removed from this skin.
 */
native final function bool RemoveStyleGroupName( string StyleGroupName );

/**
 * Renames a style group in this skin.
 *
 * @param	OldStyleGroupName	the style group to rename
 * @param	NewStyleGroupName	the new name to use for the style group
 *
 * @return	TRUE if the style group was successfully renamed; FALSE if it wasn't found or couldn't be renamed.
 */
native final function bool RenameStyleGroup( string OldStyleGroupName, string NewStyleGroupName );

/**
 * Finds the index for the specified group name.
 *
 * @param	StyleGroupName	the group name to find
 *
 * @return	the index [into the skin's StyleGroupMap] for the specified style group, or INDEX_NONE if it wasn't found.
 */
native final function int FindStyleGroupIndex( string StyleGroupName ) const;

/**
 * Retrieves the full list of style group names.
 *
 * @param	StyleGroupArray	recieves the array of group names
 * @param	bIncludeInheritedGroupNames		specify FALSE to exclude group names inherited from base skins.
 */
native final function GetStyleGroups( out array<string> StyleGroupArray, optional bool bIncludeInheritedGroups=true ) const;

/**
 * Don't let anything subscribe itself to this datastore.
 */
event SubscriberAttached( UIDataStoreSubscriber Subscriber );

/**
 * Don't let anything subscribe itself to this datastore.
 */
event SubscriberDetached( UIDataStoreSubscriber Subscriber );

DefaultProperties
{
	Tag=Styles
}
