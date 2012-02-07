/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UIComp_UDKDrawStateImage extends UIComp_DrawImage
	native;

cpptext
{
 	/**
	 * Applies the current style data (including any style data customization which might be enabled) to the component's image.
	 */
	void RefreshAppliedStyleData();
}

/** State for the image component, used when resolving styles. */
var			transient		class<UIState>							ImageState;

