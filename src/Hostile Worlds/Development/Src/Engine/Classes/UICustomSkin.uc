/**
 * A UISkin that contains purely cosmetic style changes.  In addition to replacing styles inherited from base styles, this
 * class can also remap the styles for individual widgets to point to an entirely different style.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UICustomSkin extends UISkin
	native(inherit);

/**
 * Contains custom mappings for overriding widget styles.
 * @todo - should it be marked transient as well?
 */
var		const	native						Map{FWIDGET_ID,FSTYLE_ID}	WidgetStyleMap;

cpptext
{

	/**
	 * Deletes the specified style and replaces its entry in the lookup table with this skin's archetype style.
	 * This only works if the provided style's outer is this skin.
	 *
	 * This version of DeleteStyle goes through the WidgetStyleMap and changes any widgets bound to the style being deleted,
	 * to be bound to the archetype's style instead.
	 *
	 * @return	TRUE if the style was successfully removed.
	 */
	virtual UBOOL DeleteStyle( class UUIStyle* InStyle );

	/**
	 * Assigns the style specified to the widget and stores that mapping in the skin's persistent style list.
	 *
	 * @param	Widget		the widget to apply the style to.
	 * @param	StyleID		the STYLEID for the style that should be assigned to the widget
	 */
	void StoreWidgetStyleMapping( class UUIObject* Widget, const struct FSTYLE_ID& StyleID );
}

DefaultProperties
{

}
