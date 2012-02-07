/**
 * Contains information about how to present and format a widget's appearance.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIStyle_Data extends UIRoot
	native(UIPrivate)
	abstract;

/** name of custom wxStaticBox class used to edit this style type */
var	const	editoronly		string			UIEditorControlClass;

/** Color for this style */
var							LinearColor		StyleColor;

/** The amount of padding to apply; values will be scaled based on the value of the DEFAULT_SIZE_Y const */
var							float			StylePadding[EUIOrientation.UIORIENT_MAX];

/** Controls whether this style data is enabled in the owning style for its associated state */
var							bool			bEnabled;

/** True if the style's data need to be reapplied to the widgets using this style */
var	transient				bool			bDirty;

cpptext
{
	/**
	 * Called when this style data object is added to a style.
	 *
	 * @param	the menu state that this style data has been created for.
	 */
	virtual void Created( class UUIState* AssociatedState ) {}

	/**
	 * Resolves any references to other styles contained in this style data object.
	 *
	 * @param	OwnerSkin	the skin that is currently active.
	 */
	virtual void ResolveExternalReferences( class UUISkin* ActiveSkin ) {}

	/**
	 * Allows the style to verify that it contains valid data for all required fields.  Called when the owning style is being initialized, after
	 * external references have been resolved.
	 */
	virtual void ValidateStyleData() {}

	/** Returns the UIStyle object that contains this style data */
	class UUIStyle* GetOwnerStyle() const;

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
	virtual UBOOL IsReferencingStyle(const UUIStyle* Style) const { return FALSE; }
}

/**
 * Allows script-only child classes to include properties when comparing two styles.  OtherStyle is guaranteed to be valid and of the right
 * type.  This delegate is only called if it's assigned a value (i.e. assigned to a function).
 *
 * @param	OtherStyle	the style to compare this style's values against
 *
 * @return	TRUE if all style property values are the same as the other style's or if the other style is same as this one
 */
delegate bool MatchesStyleData( const UIStyle_Data OtherStyle );

DefaultProperties
{
	StyleColor=(R=1.f,G=1.f,B=1.f,A=1.f)
}
