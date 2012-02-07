/**
 * Contains information about how to present and format text
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIStyle_Text extends UIStyle_Data
	native(inherit);

/** the font associated with this text style */
var						Font				StyleFont;

/** attributes to apply to this style's font */
var						UITextAttributes	Attributes;

/** text alignment within the bounding region */
var						EUIAlignment		Alignment[EUIOrientation.UIORIENT_MAX];

/**
 * Determines what happens when the text doesn't fit into the bounding region.
 */
var 					ETextClipMode		ClipMode;

/** Determines how the nodes of this string are ordered when the string is being clipped */
var						EUIAlignment		ClipAlignment;

/** Allows text to be scaled to fit within the bounding region */
var						TextAutoScaleValue	AutoScaling;

/** the scale to use for rendering text */
var						Vector2D			Scale;

/** Horizontal spacing adjustment between characters and vertical spacing adjustment between lines of wrapped text */
var						Vector2D			SpacingAdjust;

/* !!!!  IF YOU ADD MORE PROPERTIES TO THIS CLASS, MAKE SURE TO UPDATE MatchesStyleData !!!! */

cpptext
{
	/**
	 * Returns whether the values for this style data match the values from the style specified.
	 *
	 * @param	OtherStyle	the style to compare this style's values against
	 *
	 * @return	TRUE if all style property values are the same as the other style's or if the other style is same as this one
	 */
	virtual UBOOL MatchesStyleData( class UUIStyle_Data* StyleToCompare ) const;

	/**
	 * Allows the style to verify that it contains valid data for all required fields.  Called when the owning style is being initialized, after
	 * external references have been resolved.
	 *
	 * This version verifies that this style has a valid font and if not sets the font reference to the default font.
	 */
	virtual void ValidateStyleData();

	/* === UObject interface. === */
	/**
	 * Called after this object has been de-serialized from disk.
	 *
	 * This version propagates CLIP_Scaled and CLIP_ScaledBestFit ClipMode values to the new AutoScaling property
	 */
	virtual void PostLoad();
}

DefaultProperties
{
	UIEditorControlClass="WxStyleTextPropertiesGroup"

	StyleFont=Font'EngineFonts.SmallFont'

	Alignment(UIORIENT_Horizontal)=UIALIGN_Left
	Alignment(UIORIENT_Vertical)=UIALIGN_Center
	ClipMode=CLIP_None
	Scale=(X=1.0,Y=1.0)
}
