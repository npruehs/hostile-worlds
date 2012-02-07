/**
 * Contains information about how to present and format an image's appearance
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIStyle_Image extends UIStyle_Data
	native(inherit);

/** The material to use if the image material cannot be loaded or this style is not applied to an image. */
var()			Surface					DefaultImage;

/** if DefaultImage points to a texture atlas, represents the coordinates to use for rendering this image */
var()			TextureCoordinates		Coordinates;

/** Information about how to modify the way the image is rendered. */
var()			UIImageAdjustmentData	AdjustmentType[EUIOrientation.UIORIENT_MAX];

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

}

DefaultProperties
{
	UIEditorControlClass="WxStyleImagePropertiesGroup"
	DefaultImage=Texture'EngineResources.DefaultTexture'
}
