/**
 * Contains a mapping of UIStyle_Data to the UIState each style is associated with.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIStyle extends UIRoot
	within UISkin
	native(UserInterface)
	PerObjectConfig;

/** Unique identifier for this style. */
var								STYLE_ID									StyleID;

/** Unique non-localized name for this style which is used to reference the style without needing to know its GUID */
var								name										StyleTag;

/** Friendly name for this style. */
var()	localized				string										StyleName;

/**
 * Group this style is assigned to.
 */
var const						string										StyleGroupName;

/** the style data class associated with this UIStyle */
var const						class<UIStyle_Data>							StyleDataClass;

/**
 * map of UIStates to style data associated with that state.
 */
var	const	native	transient	Map{class UUIState*,class UUIStyle_Data*}	StateDataMap;

cpptext
{
	/**
	 *	Obtain style data for the specified state from the archetype style
	 *
	 *	@param StateObject	State for which the data will be extracted
	 *	@return returns the corresponding state data or NULL archetype doesn't contain this state or
	 *			if this style's archetype is the class default object
	 */
	UUIStyle_Data* GetArchetypeStyleForState(class UUIState* StateObject) const;

	/**
	 * Called when this style is loaded by its owner skin.
	 *
	 * @param	OwnerSkin	the skin that contains this style.
	 */
	void InitializeStyle( class UUISkin* OwnerSkin );

	/**
	 * Get the name for this style.
	 *
	 * @return	If the value for StyleName is identical to the value for this style's template, returns this style's
	 *			StyleTag....otherwise, returns this style's StyleName
	 */
	FString	GetStyleName() const;

	/**
	 * Creates and initializes a new style data object for the UIState specified.
	 *
	 * @param	StateToAdd		the state to add style data for.  If StateToAdd does not have either the RF_ArchetypeObject
	 * 							or RF_ClassDefaultObject flags set, the new style data will be associated with StateToAdd's
	 *							ObjectArchetype instead.
	 * @param	DataArchetype	if specified, uses this object as the template for the new style data object
	 */
	UUIStyle_Data* AddNewState( class UUIState* StateToAdd, class UUIStyle_Data* DataArchetype=NULL );

	/**
	 * Returns whether this style's data has been modified, requiring the style to be reapplied.
	 *
	 * @param	DataToCheck		if specified, returns whether the values have been modified for that style data only.  If not
	 *							specified, checks all style data contained by this style.
	 *
	 * @return	TRUE if the style data contained by this style needs to be reapplied to any widgets using this style.
	 */
	UBOOL IsDirty( UUIStyle_Data* DataToCheck=NULL ) const;

	/**
	 * Returns whether this style's data has been modified, requiring the style to be reapplied.
	 *
	 * @param	StateToCheck	if specified, returns whether the values have been modified for that menu state's style data only.
	 *							If not specified, checks all style data contained by this style.
	 *
	 * @return	TRUE if the style data contained by this style needs to be reapplied to any widgets using this style.
	 */
	UBOOL IsDirty( UUIState* StateToCheck=NULL ) const;

	/**
	 * Sets or clears the dirty flag for this style, which indicates whether this style's data should be reapplied.
	 *
	 * @param	bIsDirty	TRUE to mark the style dirty, FALSE to clear the dirty flag
	 * @param	Target		if specified, only sets the dirty flag for this style data object.  Otherwise, sets the dirty
	 *						flag for all style data contained by this style.
	 */
	void SetDirtiness( UBOOL bIsDirty, UUIStyle_Data* Target=NULL );

	/**
	 * Creates a newly constructed copy of the receiver with a hard copy of its StateDataMap.
	 * New style will be transient and cannot be saved out.
	 *
	 * @return	Pointer to a newly constructed transient copy of the passed style
	 */
	UUIStyle* CreateTransientCopy();

	/**
	 * Returns TRUE if this style indirectly references specified style through its DataMap
	 */
	UBOOL ReferencesStyle(const UUIStyle* Style) const;

	/**
     * Returns TRUE if this style is one of the designated default styles
     */
    UBOOL IsDefaultStyle() const;

    /**
     * Restores the archetype for the specified style and reinitializes the style data object against the new archetype,
	 * preserving the values serialized into StyleData
     *
     * @param	StyleData			the style data object that has the wrong archetype
     * @param	StyleDataArchetype	the style data object that should be the archetype
     */
	void RestoreStyleArchetype( class UUIStyle_Data* StyleData, class UUIStyle_Data* StyleDataArchetype );

	/* === UObject interface === */
	/**
	 * Callback used to allow object register its direct object references that are not already covered by
	 * the token stream.
	 *
	 * @param ObjectArray	array to add referenced objects to via AddReferencedObject
	 */
	virtual void AddReferencedObjects( TArray<UObject*>& Objects );

	/** File I/O */
	virtual void Serialize( FArchive& Ar );

	/**
	 * Fixes the archetypes for any style data objects which have lost their archetypes.
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

/**
 * Returns the style data associated with the archetype for the UIState specified by StateObject.  If this style does not contain
 * any style data for the specified state, this style's archetype is searched, recursively.
 *
 * @param	StateObject	the UIState to search for style data for.  StateData is stored by archetype, so the StateDataMap
 *						is searched for each object in StateObject's archetype chain until a match is found or we arrive
 *						at the class default object for the state.
 *
 *
 * @return	a pointer to style data associated with the UIState specified, or NULL if there is no style data for the specified
 *			state in this style or this style's archetypes
 */
native final function UIStyle_Data GetStyleForState( UIState StateObject ) const;

/**
 * Returns the first style data object associated with an object of the class specified.  This function is not reliable
 * in that it can return different style data objects if there are multiple states of the same class in the map (i.e.
 * two archetypes of the same class)
 *
 * @param	StateClass	the class to search for style data for
 *
 * @return	a pointer to style data associated with the UIState specified, or NULL if there is no style data for the specified
 *			state in this style or this style's archetypes
 */
native final function UIStyle_Data GetStyleForStateByClass( class<UIState> StateClass ) const;

final event UIStyle_Data GetDefaultStyle()
{
	return GetStyleForStateByClass(class'UIState_Enabled');
}

DefaultProperties
{

}
