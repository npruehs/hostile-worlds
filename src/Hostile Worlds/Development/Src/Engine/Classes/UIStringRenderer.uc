/**
 * Provides an interface for working with widgets that render strings in some way.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
interface UIStringRenderer
	native(UIPrivate);

/**
 * Sets the text alignment for the string that the widget is rendering.
 *
 * @param	Horizontal		Horizontal alignment to use for text, UIALIGN_MAX means no change.
 * @param	Vertical		Vertical alignment to use for text, UIALIGN_MAX means no change.
 */
native virtual function SetTextAlignment(EUIAlignment Horizontal, EUIAlignment Vertical);
