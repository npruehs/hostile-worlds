/**
 * Provides an interface for dealing with non-widgets that have UIStyleReferences which need to be resolved when the widget's
 * style is resolved.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
interface UIStyleResolver
	native(UIPrivate);

/**
 * Returns the tag assigned to this UIStyleResolver by whichever object manages its lifetime.
 */
native function name GetStyleResolverTag();

/**
 * Changes the tag assigned to the UIStyleResolver to the specified value.
 */
native function bool SetStyleResolverTag( name NewResolverTag );

/**
 * Notifies this style resolver to resolve its style references.
 *
 * @param	ActiveSkin			the skin the use for resolving the style reference.
 * @param	bClearExistingValue	if TRUE, style references will be invalidated first.
 * @param	CurrentMenuState	the menu state to use for resolving the style data; if not specified, uses the current
 *								menu state of the owning widget.
 * @param	StyleProperty		if specified, only the style reference corresponding to the specified property
 *								will be resolved; otherwise, all style references will be resolved.
 */
native function bool NotifyResolveStyle( UISkin ActiveSkin, bool bClearExistingValue, optional UIState CurrentMenuState, const optional name StylePropertyName );

DefaultProperties
{

}
