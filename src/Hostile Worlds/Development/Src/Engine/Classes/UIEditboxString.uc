/**
 * This specialized version of UIString is used in editboxes.  UIEditboxString is different from UIString in that it is
 * aware of the first character that should be visible in the editbox, and ensures that the string's nodes only contain
 * text that falls within the editboxes bounding region, without affecting the data store binding associated with each
 * individual node.
 *
 * @todo UIString is supposed to support persistence, so that designers can override the extents for individual nodes
 *	in the string, so this class should not be marked transient
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIEditboxString extends UIString
	within UIEditBox
	native(UIPrivate)
	transient;

cpptext
{
	/* === UUIString interface === */
protected:
	/**
	 * Hook for adjusting the extents and render text of any nodes prior to applyig formatting data.
	 *
	 * @param	FormatData	contains the precalculated formatting data (available bounding region size, etc.)
	 *
	 * @return	TRUE to indicate that the string has been preclipping (forces UUIString::ApplyFormatting to use UIALIGN_Left
	 *			instead of the configured text clip mode, if the string must be clipped further).
	 */
	virtual UBOOL AdjustNodeExtents( struct FNodeFormattingData& FormatData );

public:
	/**
	 * Parses a string containing optional markup (such as tokens and inline images) and stores the result in Nodes.
	 *
	 * This version replaces the RenderText in all nodes with asterisks if the editbox's bPasswordMode is enabled.
	 *
	 * @param	InputString		A string containing optional markup.
	 * @param	bIgnoreMarkup	if TRUE, does not attempt to process any markup and only one UITextNode is created
	 *
	 * @return	TRUE if the string was successfully parsed into the Nodes array.
	 */
	virtual UBOOL SetValue( const FString& InputString, UBOOL bIgnoreMarkup );
}

DefaultProperties
{

}
