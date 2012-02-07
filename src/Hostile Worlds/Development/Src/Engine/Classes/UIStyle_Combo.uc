/**
 * Contains a reference to style data from either existing style, or custom defined UIStyle_Data.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UIStyle_Combo extends UIStyle_Data
	native(inherit);

struct native StyleDataReference
{
	/** Style which owns this reference */
	var private{private}				UIStyle			OwnerStyle;

	/** the style id for the style that this StyleDataReference is linked to */
	var	private{private}				STYLE_ID		SourceStyleID;

	/**
	 * the style that this refers to
	 */
	var	private{private}	transient	UIStyle			SourceStyle;

	/** the state corresponding to the style data that this refers to */
	var	private{private}				UIState			SourceState;

	/** the optional custom style data to be used instead of existing style reference */
	var private{private}				UIStyle_Data	CustomStyleData;

structcpptext
{
	friend class UUIStyle_Combo;

	/** Constructors */
	FStyleDataReference();
	FStyleDataReference( class UUIStyle* InSourceStyle, class UUIState* InSourceState );

	/** Comparison */
	UBOOL operator ==( const FStyleDataReference& Other ) const;
	UBOOL operator !=( const FStyleDataReference& Other ) const;

	/**
	 * Resolves SourceStyleID from the specified skin and assigns the result to SourceStyle.
	 *
	 * @param	ActiveSkin	the currently active skin.
	 */
	void ResolveSourceStyle( class UUISkin* ActiveSkin );

	/**
	 *	Returns the value of OnwerStyle
	 */
	class UUIStyle* GetOwnerStyle() const { return OwnerStyle; }

	/**
	 * Returns the style data object linked to this reference, if SourceStyle or SourceState are NULL then CustomStyleData will be returned instead
	 */
	class UUIStyle_Data* GetStyleData() const;

	/**
	 * Returns the value of SourceStyle
	 */
	class UUIStyle* GetSourceStyle() const { return SourceStyle; }

	/**
	 * Returns the value of SourceState
	 */
	class UUIState* GetSourceState() const { return SourceState; }

	/**
	 * Returns the value of CustomStyleData
	 */
	class UUIStyle_Data* GetCustomStyleData() const { return CustomStyleData; }

	/**
	 * Changes OwnerStyle to be the style specified
	 */
	void SetOwnerStyle( class UUIStyle* NewStyle ){ OwnerStyle = NewStyle; }

	/**
	 *	Sets The SourceStyle reference, makes sure that SourceState is valid for this style
	 */
	void SafeSetStyle(UUIStyle* Style);

	/**
	 * 	Sets The SourceState reference, makes sure that SourceStyle contains this state
	 */
	void SafeSetState(UUIState* State);

	/**
	 * Changes SourceStyle to the style specified, without checking whether it is valid.
	 */
	void SetSourceStyle( class UUIStyle* NewStyle );

	/**
	 * Changes SourceState to the state specified, without checking whether it is valid.
	 */
	void SetSourceState( class UUIState* NewState );

	/**
	 * Sets CustomStyleData reference
	 */
	void SetCustomStyleData( UUIStyle_Data* CustomData ){ CustomStyleData = CustomData; }

	/**
	 * Enables or disables the custom style data if the OwnerStyle is the outer of the custom data
	 */
	void EnableCustomStyleData( UBOOL BoolFlag );

	/**
	 *	Determines if referenced custom style data is valid.
	 */
	UBOOL IsCustomStyleDataValid() const;

	/**
	 *	Determines if the custom style data is valid and enabled
	 */
	UBOOL IsCustomStyleDataEnabled() const;

	/**
	 * Returns whether the styles referenced are marked as dirty
	 */
	UBOOL IsDirty() const;
}
};

var		StyleDataReference			ImageStyle;
var		StyleDataReference			TextStyle;

/* !!!!  IF YOU ADD MORE PROPERTIES TO THIS CLASS, MAKE SURE TO UPDATE MatchesStyleData !!!! */


cpptext
{
	/**
	 * Called when this style data object is added to a style.
	 *
	 * @param	the menu state that this style data has been created for.
	 */
	virtual void Created( class UUIState* AssociatedState );

	/**
	 * Resolves any references to other styles contained in this style data object.
	 *
	 * @param	OwnerSkin	the skin that is currently active.
	 */
	virtual void ResolveExternalReferences( class UUISkin* ActiveSkin );

	/**
	 * Allows the style to verify that it contains valid data for all required fields.  Called when the owning style is being initialized, after
	 * external references have been resolved.
	 */
	virtual void ValidateStyleData();

	/**
	 * Returns whether this style's data has been modified, requiring the style to be reapplied.
	 *
	 * @return	TRUE if this style's data has been modified, indicating that it should be reapplied to any subscribed widgets.
	 */
	virtual UBOOL IsDirty() const;

	/**
	 * Sets or clears the dirty flag for this style data.
	 *
	 * @param	bIsDirty	TRUE to mark the style dirty, FALSE to clear the dirty flag
	 */
	virtual void SetDirtiness( UBOOL bIsDirty );

	/**
	 * Returns whether the values for this style data match the values from the style specified.
	 *
	 * @param	OtherStyle	the style to compare this style's values against
	 *
	 * @return	TRUE if all style property values are the same as the other style's or if the other style is same as this one
	 */
	virtual UBOOL MatchesStyleData( class UUIStyle_Data* StyleToCompare ) const;

	/** Returns TRUE if this style data references specified style */
	virtual UBOOL IsReferencingStyle(const UUIStyle* Style) const;

	/* === UObject interface === */
	/**
	 * Assigns the SourceStyleID property for the style references contained by this combo style, if this style was saved
	 * prior to adding SourceStyleID to UIStyleDataReference
	 */
	virtual void PostLoad();
}

/**
 * Accessor for retrieving a reference to the active text & image styles, taking into account whether the combo style is using custom style data.
 */
native final function UIStyle_Text GetComboTextStyle() const;
native final function UIStyle_Image GetComboImageStyle() const;

DefaultProperties
{
	UIEditorControlClass="WxStyleComboPropertiesGroup"
}
