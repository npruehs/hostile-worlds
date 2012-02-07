/**
 * Base class for all classes that handle interacting with the user.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIRoot extends Object
	native(UserInterface)
	HideCategories(Object,UIRoot)
	DependsOn(SequenceOp,WorldInfo)
	abstract;

const TEMP_SPLITSCREEN_INDEX=0;

/** the default priority for all UIScenes */
const DEFAULT_SCENE_PRIORITY=10;

/**
 * Controls what types of interactions are allowed for a widget.  Ideally this would be an enum, but the values are used as a bitmask
 * (for UIObject.PrivateFlags) and unrealscript enums cannot be assigned values.
 */
const PRIVATE_NotEditorSelectable	= 0x001;	/** Not selectable in the scene editor.																									*/
const PRIVATE_TreeHidden			= 0x002;	/** Not viewable in the scene tree or layer tree, but children are.																						*/
const PRIVATE_NotFocusable			= 0x004;	/** Not eligible to receive focus; affects both editor and game																			*/
const PRIVATE_NotDockable			= 0x008;	/** Not able to be docked to another widget.																							*/
const PRIVATE_NotRotatable			= 0x010;	/** Not able to be rotated. @todo - not yet implemented.																				*/
const PRIVATE_ManagedStyle			= 0x020;	/** Indicates that this widget's styles are managed by its owner widgets - any style references set for this widget will not be saved.	*/
const PRIVATE_TreeHiddenRecursive	= 0x042;	/** Not visible in the scene tree or layer tree, including children																		*/
const PRIVATE_EditorNoDelete		= 0x080;	/** This widget is not deletable in the editor																							*/
const PRIVATE_EditorNoRename		= 0x100;	/** This widget is not renamable in the editor																							*/
const PRIVATE_EditorNoReparent		= 0x200;	/** This widget can not be reparented in the editor																						*/
const PRIVATE_PropagateState		= 0x400;	/** This widget will propagate certain states to its children, such as enabled and disabled												*/
const PRIVATE_KeepFocusedState		= 0x800;	/** only relevant if NotFocusable is set as well - don't remove the focused state from this widget's list of available states			*/

/** Combination flags */
const PRIVATE_Protected				= 0x380;	/** Combination of EditorNoDelete + EditorNoRename + EditorNoReparent																	*/

/** The type of adjustment to apply to a material. */
enum EMaterialAdjustmentType
{
	/** no modification to material - if material is larger than target dimension, material is clipped */
	ADJUST_None<DisplayName=Clipped>,

	/** material will be scaled to fit the target dimension */
	ADJUST_Normal<DisplayName=Scaled>,

	/** material will be scaled to fit the target dimension, maintaining aspect ratio */
	ADJUST_Justified<DisplayName=Uniformly Scaled>,

	/** target's dimensions will be adjusted to match material dimension */
	ADJUST_Bound<DisplayName=Bound>,

	/** material will be stretched to fit target dimension */
	ADJUST_Stretch<DisplayName=Stretched>,
};

/** method to use for resolving a UIScreenValue */
enum EPositionEvalType
{
	/** no conversion */
	EVALPOS_None,

	/** the value should be evaluated as an actual pixel value */
	EVALPOS_PixelViewport,

	/** the value should be evaluated as a pixel offset from the owning widget's scene's position */
	EVALPOS_PixelScene,

	/** the value should be evaluated as a pixel offset from the owning widget's position */
	EVALPOS_PixelOwner,

	/** the value should be evaluated as a percentage of the viewport */
	EVALPOS_PercentageViewport,

	/** the value should be evaluated as a percentage of the owning widget's position */
	EVALPOS_PercentageOwner,

	/** the value should be evaluated as a percentage of the owning widget's scene */
	EVALPOS_PercentageScene,
};

/** method to use for resolving a UIAutoSizeRegion's values */
enum EUIExtentEvalType
{
	/** the value should be interpreted as an actual pixel value */
	UIEXTENTEVAL_Pixels<DisplayName=Pixels>,

	/** the value should be interpreted as a percentage of the owner's size */
	UIEXTENTEVAL_PercentSelf<DisplayName=Percentage of owning widget size>,

	/** the value should be interpreted as a percentage of the size of the owning widget's parent */
	UIEXTENTEVAL_PercentOwner<DisplayName=Percentage of widget parent size>,

	/** the value should be interpreted as a percentage of the scene's size */
	UIEXTENTEVAL_PercentScene<DisplayName=Percentage of scene>,

	/** the value should be interpreted as a percentage of the viewport's size */
	UIEXTENTEVAL_PercentViewport<DisplayName=Percentage of viewport>,
};

/** method to use for resolving dock padding values */
enum EUIDockPaddingEvalType
{
	/** the value should be interpreted as an actual pixel value */
	UIPADDINGEVAL_Pixels<DisplayName=Pixels>,

	/** the value should be interpreted as a percentage of the dock target's size */
	UIPADDINGEVAL_PercentTarget<DisplayName=Percentage of dock target size>,

	/** the value should be interpreted as a percentage of the owner's size */
	UIPADDINGEVAL_PercentOwner<DisplayName=Percentage of owning widget size>,

	/** the value should be interpreted as a percentage of the scene's size */
	UIPADDINGEVAL_PercentScene<DisplayName=Percentage of scene>,

	/** the value should be interpreted as a percentage of the viewport's size */
	UIPADDINGEVAL_PercentViewport<DisplayName=Percentage of viewport>,
};

/** the different types of auto-size extent values */
enum EUIAutoSizeConstraintType
{
	/** the minimum size that the region can be auto-sized to */
	UIAUTOSIZEREGION_Minimum<DisplayName=Minimum>,

	/** the maximum size that the region can be auto-sized to */
	UIAUTOSIZEREGION_Maximum<DisplayName=Maximum>,
};

/** Determines how text should be handled when the text overflows its bounds */
enum ETextClipMode
{
	/** all text is drawn, even if it is outside the bounding region */
	CLIP_None<DisplayName=Overdraw>,

	/** text outside the region should be clipped */
	CLIP_Normal<DisplayName=Clipped>,

	/** replace the last few visible characters with ellipsis to indicate that more text follows */
	CLIP_Ellipsis<DisplayName=Ellipsis>,

	/** wrap the text to the next line */
	CLIP_Wrap<DisplayName=Wrapped>,
};

/** Different types of autoscaling supported */
enum ETextAutoScaleMode
{
	/** No autoscaling */
	UIAUTOSCALE_None<DisplayName=Disabled>,

	/** scale the text to fit into the bounding region */
	UIAUTOSCALE_Normal<DisplayName=Standard>,

	/** same as UIAUTOSCALE_Normal, but maintains the same aspect ratio */
	UIAUTOSCALE_Justified<DisplayName=Justified (maintain aspect ratio)>,

	/** scaled based on the ratio between the resolution the content was authored at and the current resolution */
	UIAUTOSCALE_ResolutionBased<DisplayName=Resolution Scaled>,
};

/** used for specifying alignment for UIObjects and operations */
enum EUIAlignment
{
	/** left or top alignment */
	UIALIGN_Left<DisplayName=Left/Top>,

	/** center alignment */
	UIALIGN_Center<DisplayName=Center>,

	/** right or bottom alignment */
	UIALIGN_Right<DisplayName=Right/Bottom>,

	/** default alignment value */
	UIALIGN_Default<DisplayName=Inherit/Other>,
};

/** Represents the state of an item in a UIList. */
enum EUIListElementState
{
	/** normal element in the list */
	ELEMENT_Normal<DisplayName=Normal>,

	/** element corresponds to the list's index */
	ELEMENT_Active<DisplayName=Active>,

	/** element is current selected */
	ELEMENT_Selected<DisplayName=Selected>,

	/** the cursor is currently over the element */
	ELEMENT_UnderCursor<DisplayName=Under Cursor>,
};

/** The different states for a list column header */
enum EColumnHeaderState
{
	/** this column is not being used to sort list elements */
	COLUMNHEADER_Normal<DisplayName=Normal>,

	/** this column is used as the primary sort key for the list elements */
	COLUMNHEADER_PrimarySort<DislayName=Primary Sort>,

	/** this column is used as the secondary sort key for the list elements */
	COLUMNHEADER_SecondarySort<DipslayName=Secondary Sort>,
};

/** general orientation for UIObjects */
enum EUIOrientation
{
	UIORIENT_Horizontal<DisplayName=Horizontal>,
	UIORIENT_Vertical<DisplayName=Vertical>,
};

/** The faces a widget may contain. */
enum EUIWidgetFace
{
	UIFACE_Left<DisplayName=Left>,
	UIFACE_Top<DisplayName=Top>,
	UIFACE_Right<DisplayName=Right>,
	UIFACE_Bottom<DisplayName=Bottom>,
};

/** The types of aspect ratio constraint adjustments supported */
enum EUIAspectRatioConstraint
{
	/** Indicates that no aspect ratio constraint adjustment is active */
	UIASPECTRATIO_AdjustNone<DisplayName=None>,

	/** Indicates that the width will be adjusted to be a product of the height (most common) */
	UIASPECTRATIO_AdjustWidth<DisplayName=Adjust Width>,

	/** Indicates that the height should be adjusted as a product of the width (rarely used) */
	//@todo ronp - not yet implemented
	UIASPECTRATIO_AdjustHeight<DisplayName=Adjust Height>,
};

/** The types of default textures the UI can use */
enum EUIDefaultPenColor
{
	UIPEN_White,
	UIPEN_Black,
	UIPEN_Grey,
};

/** Types of navigation targets */
enum ENavigationLinkType
{
	/** navigation link that was set programmatically by RebuildNavigationLinks */
	NAVLINK_Automatic,

	/** navigation link that was set by the designer in the UI Editor */
	NAVLINK_Manual,
};

/**
 * The types of split-screen input modes that are supported for UI scenes.  These control what a UIScene does when it
 * receives input from multiple gamepads at once.
 *
 * @note: the order of the values in this enum should not be changed.
 */
enum EScreenInputMode
{
	/**
	 * This scene doesn't process input at all.  Useful for optimizing input processing for scenes which don't process any input,
	 * such as HUD scenes.
	 */
	INPUTMODE_None,

	/**
	 * Simultaneous inputs are not supported in this scene.  Only input from the gamepad that is associated with
	 * this scene will be processed.  Input from other gamepads will be ignored and swallowed.
	 * This is the most common input mode.
	 */
	INPUTMODE_Locked,		// MIM_Bound

	/**
	 * Simultaneous inputs are not supported on this scene.  By default, only input from the gamepad that is associated with
	 * this scene will be processed.  Input from other gamepads will only be processed if the PlayerInputMask for any widgets
	 * in the scene has been set manually, and only for those widgets.
	 */
	INPUTMODE_Selective,

	/**
	 * Similar to INPUTMODE_Locked, except that input from gamepads not associated with this scene is passed to the
	 * next scene in the stack.
	 * Used for e.g. profile selection scenes where each player can open their own profile selection menu.
	 */
	INPUTMODE_MatchingOnly,	// MIM_NonBlocking

	/**
	 * Similar to INPUTMODE_Free, except that input is only accepted from active gamepads which are associated with a
	 * player.
	 * All input and focus is treated as though it came from the same gamepad, regardless of where it came from.
	 * Allows any active player to interact with this screen.
	 */
	INPUTMODE_ActiveOnly,	// MIM_Cooperative

	/**
	 * Any active gamepad can interact with this menu, even if it isn't associated with a player.
	 * Used for menus which allow additional players to become active, such as the character selection menu.
	 */
	INPUTMODE_Free,			// MIM_Unbound

	/**
	 * Input from any active gamepad will be processed by this scene.  The scene contains a unique set of controls
	 * for each active gamepad, and those controls only respond to input from the gamepad they're associated with.
	 * Used for scenes where all players should be able to interact with the same controls in the scene (such as a
	 * character selection menu in most fighting games)
	 */
	INPUTMODE_Simultaneous,	// MIM_Simultaneous
};

/**
 * Types of split-screen rendering layouts that scenes can use.
 */
enum ESplitscreenRenderMode
{
	/**
	 * The scene is always rendered using the full screen; it will span across the viewport regions for the splitscreen players.
	 */
	SPLITRENDER_Fullscreen<DisplayName=Fullscreen>,

	/**
	 * The scene is rendered according to the player associated with the scene.  If no player is associated with the scene, the scene
	 * will be rendered fullscreen.  If a player is associated with the scene (by specifying a PlayerOwner when opening the scene),
	 * the scene will be rendered within that player's viewport region.
	 */
	SPLITRENDER_PlayerOwner<DisplayName=Player Viewport>,
};

/**
 * Data field categorizations.
 */
enum EUIDataProviderFieldType
{
	/**
	 * this tag represents a bindable data field that corresponds to a simple data type
	 */
	DATATYPE_Property<DisplayName=Property>,

	/**
	 * this tag represents an internal data provider; cannot be bound to a widget
	 */
	DATATYPE_Provider<DisplayName=Internal Provider>,

	/**
	 * this tag represents a field that can only be represented by widgets that can display range values, such as
	 * sliders, progress bars, and spinners.
	 */
	DATATYPE_RangeProperty<DisplayName=Range Property>,

	/**
	 * Holds a UniqueNetId value - cannot be represented by a normal property because it's internal members are natively serialized.
	 */
	DATATYPE_NetIdProperty<DisplayName=Unique NetId Property>,

	/**
	 * this tag represents a bindable array data field; can be bound to lists or individual elements can be bound to widgets
	 */
	DATATYPE_Collection<DisplayName=Array>,

	/**
	 * this tag represents an array of internal data providers. Can be bound to lists or the properties for individual elements
	 * can be bound to widgets
	 */
	DATATYPE_ProviderCollection<DisplayName=Array Of Providers>,
};

/** Various sets of characters which should be allowed in an editbox. */
enum EEditBoxCharacterSet
{
	/** Allows all charcters */
	CHARSET_All,
	/** Ignores special characters like !@# */
	CHARSET_NoSpecial,
	/** Allows only alphabetic characters */
	CHARSET_AlphaOnly,
	/** Allows only numeric characters */
	CHARSET_NumericOnly,
	/** Allows alpha numeric characters (a-z,A-Z,0-9) */
	CHARSET_AlphaNumeric,
};

/** Different presets to use for the rotation anchor's position */
enum ERotationAnchor
{
	/** Use the anchor's configured location */
	RA_Absolute,

	/** Position the anchor at the center of the widget's bounds */
	RA_Center,

	/**
	 * Position the anchor equidistant from the left, top, and bottom edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotLeft,

	/**
	 * Position the anchor equidistant from the right, top, and bottom edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotRight,

	/**
	 * Position the anchor equidistant from the left, top, and right edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotTop,

	/**
	 * Position the anchor equidistant from the left, bottom, and right edges.  Useful for widgets which will be rotated
	 * by right angles because it keeps those faces in the same relative screen positions
	 */
	RA_PivotBottom,

	/** Position the anchor at the upper left corner of the widget's bounds */
	RA_UpperLeft,

	/** Position the anchor at the upper right corner of the widget's bounds */
	RA_UpperRight,

	/** Position the anchor at the lower left corner of the widget's bounds */
	RA_LowerLeft,

	/** Position the anchor at the lower right corner of the widget's bounds */
	RA_LowerRight,
};

/**
 * The list of platforms which can provide input to the engine.  Not necessarily the platform the game is being played on -
 * for example, if the game is running on a PC, but the player is using an Xbox controller, the current InputPlatformType
 * would be IPT_360.
 */
enum EInputPlatformType
{
	/**
	 * Generally for PCs only, but could also be used for consoles which support keyboard/mouse.
	 */
	IPT_PC,

	/**
	 * Microsoft Xbox 360 TypeS-style Gamepad
	 */
	IPT_360,

	/**
	 * Sony Playstation 3 SIXAxis Gamepad
	 */
	IPT_PS3,

	// add any additional platforms supported by your game here:
	// IPT_Wii, IPT_PSP, etc.
};

/**
* Post process modes available for rendering UI Scenes
*/
enum EUIPostProcessGroup
{
	/** No post process pass for the UI Scene */
	UIPostProcess_None,
	/** Post process renders before UI Scene objects */
	UIPostProcess_Background,
	/** Post process renders after UI Scene objects */
	UIPostProcess_Foreground,
	/** Post process renders before and after UI Scene objects */
	UIPostProcess_BackgroundAndForeground,
	/** Post process group is dependent on whether the scene is the topmost scene or not. */
	UIPostProcess_Dynamic,
};

/**
 * A unique identifier assigned to a widget.
 */
struct native WIDGET_ID extends GUID
{
structcpptext
{
	FWIDGET_ID()
	: FGuid()
	{ }

	FWIDGET_ID(EEventParm)
	: FGuid(0,0,0,0)
	{}

	FWIDGET_ID( const FGuid& Other )
	: FGuid(Other)
	{ }
}
};

/**
 * A unique ID number for a resource located in a UI skin package.  Used to lookup materials in skin files.
 */
struct native STYLE_ID extends GUID
{
structcpptext
{
	FSTYLE_ID()
	: FGuid()
	{ }

	FSTYLE_ID(EEventParm)
	: FGuid(0,0,0,0)
	{}

	FSTYLE_ID( const FGuid& Other )
	: FGuid(Other)
	{ }
}
};

/**
 * Contains information about a data value that must be within a specific range.
 */
struct native UIRangeData
{
	/** the current value of this UIRange */
	var(Range)	public{private}		float	CurrentValue;

	/**
	 * The minimum value for this UIRange.  The value of this UIRange must be greater than or equal to this value.
	 */
	var(Range)						float	MinValue;

	/**
	 * The maximum value for this UIRange.  The value of this UIRange must be less than or equal to this value.
	 */
	var(Range)						float	MaxValue;

	/**
	 * Controls the amount to increment or decrement this UIRange's value when used by widgets that support "nudging".
	 * If NudgeValue is zero, reported NudgeValue will be 1% of MaxValue - MinValue.
	 */
	var(Range)	public{private}		float	NudgeValue;

	/**
	 * Indicates whether the values in this UIRange should be treated as ints.
	 */
	var(Range)						bool	bIntRange;

structcpptext
{
	/** Constructors */
	FUIRangeData() {}
	FUIRangeData(EEventParm)
	: CurrentValue(0.f), MinValue(0.f), MaxValue(0.f), NudgeValue(0.f), bIntRange(FALSE)
	{}

	FUIRangeData( const FUIRangeData& Other )
	: CurrentValue(Other.CurrentValue)
	, MinValue(Other.MinValue), MaxValue(Other.MaxValue)
	, NudgeValue(Other.NudgeValue), bIntRange(Other.bIntRange)
	{}

	/** Comparison operators */
	UBOOL operator==( const FUIRangeData& Other ) const;
	UBOOL operator!=( const FUIRangeData& Other ) const;

	/**
	 * Returns true if any values in this struct are non-zero.
	 */
	UBOOL HasValue() const;

	/**
	 * Returns the amount that this range should be incremented/decremented when nudging.
	 */
	FLOAT GetNudgeValue() const;

	/**
	 * Sets the NudgeValue for this UIRangeData to the value specified.
	 */
	void SetNudgeValue( FLOAT NewNudgeValue )
	{
		NudgeValue = NewNudgeValue;
	}

	/**
	 * Returns the current value of this UIRange.
	 */
	FLOAT GetCurrentValue() const;

	/**
	 * Sets the value of this UIRange.
	 *
	 * @param	NewValue				the new value to assign to this UIRange.
	 * @param	bClampInvalidValues		specify TRUE to automatically clamp NewValue to a valid value for this UIRange.
	 *
	 * @return	TRUE if the value was successfully assigned.  FALSE if NewValue was outside the valid range and
	 *			bClampInvalidValues was FALSE or MinValue <= MaxValue.
	 */
	UBOOL SetCurrentValue( FLOAT NewValue, UBOOL bClampInvalidValues=TRUE );
}
};

/** Coordinates for mapping an individual texture of a texture atlas */
struct native TextureCoordinates
{
	var()	float		U, V, UL, VL;

structcpptext
{
	/** Constructors */
	FTextureCoordinates()
	{ }

	FTextureCoordinates(EEventParm)
	: U(0), V(0), UL(0), VL(0)
	{}

	FTextureCoordinates( FLOAT inU, FLOAT inV, FLOAT inUL, FLOAT inVL )
	: U(inU), V(inV), UL(inUL), VL(inVL)
	{ }

	/**
	 * Returns whether the values in this coordinate are zero, accounting for floating point
	 * precision errors.
	 */
	inline UBOOL IsZero() const
	{
		return	Abs(U) < DELTA && Abs(V) < DELTA
			&&	Abs(UL) < DELTA && Abs(VL) < DELTA;
	}

	/** Comparison operators */
	inline UBOOL operator==( const FTextureCoordinates& Other ) const
	{
		return ARE_FLOATS_EQUAL(U,Other.U)
			&& ARE_FLOATS_EQUAL(V,Other.V)
			&& ARE_FLOATS_EQUAL(UL,Other.UL)
			&& ARE_FLOATS_EQUAL(VL,Other.VL);
	}
	inline UBOOL operator!=( const FTextureCoordinates& Other ) const
	{
		return !ARE_FLOATS_EQUAL(U,Other.U)
			|| !ARE_FLOATS_EQUAL(V,Other.V)
			|| !ARE_FLOATS_EQUAL(UL,Other.UL)
			|| !ARE_FLOATS_EQUAL(VL,Other.VL);
	}
}
};

/**
 * Contains the value for a property, as either text or an image.  Used for allowing script-only data provider classes to
 * resolve data fields parsed from UIStrings.
 */
struct native UIProviderScriptFieldValue
{
	/** the name of this resource; set natively after the list of available tags are retrieved from script */
	var			name		PropertyTag;

	/** the type of field this tag corresponds to */
	var			EUIDataProviderFieldType	PropertyType;

	/** If PropertyTag corresponds to data that should be represented as text, contains the value for this resource */
	var			string		StringValue;

	/** If PropertyTag correspondsd to data that should be represented as an image, contains the value for this resource */
	var			Surface		ImageValue;

	/** If PropertyTag corresponds to data that should be represented as a list of untyped data, contains the value of the selected elements */
	var			array<int>	ArrayValue;

	/** If PropertyTag corresponds to data that should be represented as value within a specific range, contains the value for this resource */
	var			UIRangeData	RangeValue;

	/** If PropertyTag corresponds to data that should be represented as a UniqueNetId, contains the value. */
	var			UniqueNetId	NetIdValue;

	/**
	 * Specifies the coordinates for ImageValue if it corresponds to a texture atlas
	 */
	var			TextureCoordinates	AtlasCoordinates;

	structcpptext
	{
		/** Constructors */
		FUIProviderScriptFieldValue() {}
		FUIProviderScriptFieldValue(EEventParm)
		{
			appMemzero(this, sizeof(FUIProviderScriptFieldValue));
		}

	    /** Copy constructor */
	    FUIProviderScriptFieldValue( const FUIProviderScriptFieldValue& Other )
	    : PropertyTag(Other.PropertyTag)
	    , PropertyType(Other.PropertyType)
	    , StringValue(Other.StringValue)
	    , ImageValue(Other.ImageValue)
	    , ArrayValue(Other.ArrayValue)
	    , RangeValue(Other.RangeValue)
	    , NetIdValue(Other.NetIdValue)
	    , AtlasCoordinates(Other.AtlasCoordinates)
	    {
		}

	    /**
	     * Returns true if this field value has been assigned.
	     */
	    UBOOL HasValue() const;

		/** @name Comparison operators */
		//@{
		UBOOL operator==( const struct FUIProviderScriptFieldValue& Other ) const;
		UBOOL operator!=( const struct FUIProviderScriptFieldValue& Other ) const;
		UBOOL operator==( const struct FUIProviderFieldValue& Other ) const;
		UBOOL operator!=( const struct FUIProviderFieldValue& Other ) const;
		//@}
	}
};


/**
 * This extension of UIProviderScriptFieldValue is used when resolving values for markup text found in UIStrings.  This struct
 * allows data stores to provide the UIStringNode that should be used when rendering the value for the data field represented
 * this struct.
 */
struct native UIProviderFieldValue extends UIProviderScriptFieldValue
{
	/**
	 * Only used by native code; allows the data store to create and initialize string nodes manually, rather than allowing
	 * the calling code to create a UIStringNode based on the value of StringValue or ImageValue
	 */
	var	const	native	transient	pointer		CustomStringNode{struct FUIStringNode};

	structcpptext
	{
		/** Constructor */
		FUIProviderFieldValue()
		: FUIProviderScriptFieldValue(), CustomStringNode(NULL)
		{ }
		FUIProviderFieldValue(EEventParm)
		: FUIProviderScriptFieldValue(EC_EventParm), CustomStringNode(NULL)
		{ }

		/** Copy constructor */
		FUIProviderFieldValue( const FUIProviderFieldValue& Other )
		: FUIProviderScriptFieldValue( (const FUIProviderScriptFieldValue&)Other ), CustomStringNode(Other.CustomStringNode)
		{ }

		FUIProviderFieldValue( const FUIProviderScriptFieldValue& Other )
		: FUIProviderScriptFieldValue(Other), CustomStringNode(NULL)
		{ }

		/** @name Comparison operators */
		//@{
		UBOOL operator==( const struct FUIProviderScriptFieldValue& Other ) const;
		UBOOL operator!=( const struct FUIProviderScriptFieldValue& Other ) const;
		UBOOL operator==( const struct FUIProviderFieldValue& Other ) const;
		UBOOL operator!=( const struct FUIProviderFieldValue& Other ) const;
		//@}
	}
};


/**
 * Encapsulates a reference to a UIStyle.  UIStyleReference supports the following features:
 *
 * - when a UIStyleReference does not have a valid STYLE_ID, the default style for this style reference (as determined by
 *		DefaultStyleTag + RequiredStyleClass) is assigned as the value for ResolvedStyle, but the value of AssignedStyleID
 *		is not modified.
 * - when a UIStyleReference has a valid STYLE_ID for the value of AssignedStyleID, but there is no style with that STYLE_ID
 *		in the current skin, ResolvedStyle falls back to using the default style for this style reference, but the value of
 *		AssignedStyleID is not modified.
 * - once a UIStyleReference has successfully resolved a style and assigned it to ResolvedStyle, it will not re-resolve the
 *		style until the style reference has been invalidated (by calling Invalidate); attempting to change the ResolvedStyle
 *		of this style reference to a style not contained in the currently active skin invalidates the ResolvedStyle.
 */
struct native UIStyleReference
{
	/**
	 * Specifies the name of the style to use if this style reference doesn't have a valid STYLE_ID (which indicates that the designer
	 * hasn't specified a style for this style reference
	 */
	var									name					DefaultStyleTag;

	/** if non-null, limits the type of style that can be assigned to this style reference */
	var const							class<UIStyle_Data>		RequiredStyleClass;

	/**
	 * The STYLE_ID for the style assigned to this style reference in the game's default skin.  This value is assigned when the designer
	 * changes the style for a style reference in the UI editor.  This value can be overridden by UICustomSkins.
	 */
	var	const							STYLE_ID				AssignedStyleID;

	/** the style data object that was associated with AssignedStyleID in the currently active skin */
	var	const transient	public{private}	UIStyle					ResolvedStyle;

	structcpptext
	{
		/** Default constructor; don't initialize any members or we'll overwrite values serialized from disk. */
		FUIStyleReference();
		/** Initialization constructor - zero initialize all members */
		FUIStyleReference(EEventParm);

		/**
		 * Clears the value for the resolved style.  Called whenever the resolved style is no longer valid, such as when the
		 * active skin has been changed.
		 */
		void InvalidateResolvedStyle();

		/**
		 * Returns the value of ResolvedStyle, optionally resolving the style reference from the currently active skin.
		 *
		 * @param	CurrentlyActiveSkin		if specified, will call ResolveStyleReference if the current value for ResolvedStyle is not valid
		 *									for the active skin (i.e. if ResolvedStyle is NULL or isn't contained by the active skin)
		 * @param	ResolvedStyleChanged	if specified, will be set to TRUE if the value for ResolvedStyle was changed during this call
		 *									to GetResolvedStyle()
		 *
		 * @return	a pointer to the UIStyle object that has been resolved from the style id and/or default style type for this
		 *			style reference.
		 */
		class UUIStyle* GetResolvedStyle( class UUISkin* CurrentlyActiveSkin=NULL, UBOOL* bResolvedStyleChanged=NULL );

		/**
		 * Resolves the style id or default style tag for this style reference into a UIStyle from the currently active skin, and assigns the result
		 * to ResolvedStyle
		 *
		 * @param	CurrentlyActiveSkin		the skin to use for resolving this style reference
		 *
		 * @return	TRUE if the style reference was successfully resolved
		 */
		UBOOL ResolveStyleReference( class UUISkin* CurrentlyActiveSkin );

		/**
		 * Resolves the style id or default style tag for this UIStyleReference and returns the result.
		 *
		 * @param	CurrentlyActiveSkin		the skin to use for resolving this style reference
		 *
		 * @return	a pointer to the UIStyle object resolved from the specified skin
		 */
		class UUIStyle* ResolveStyleFromSkin( class UUISkin* CurrentlyActiveSkin ) const;

		/**
		 * Determines whether the specified style is a valid style for this style reference, taking into account the RequiredStyleClass.
		 *
		 * @param	StyleToCheck	a pointer to a UIStyle with a valid StyleID.
		 * @param	bAllowNULLStyle	indicates whether a NULL value for StyleToCheck should be considered valid.
		 *
		 * @return	TRUE if the specified style is the right type for this style reference, or if StyleToCheck is NULL (it is always
		 *			valid to assign NULL styles to a style reference) and bAllowNULLStyle is TRUE.
		 */
		UBOOL IsValidStyle( class UUIStyle* StyleToCheck, UBOOL bAllowNULLStyle=TRUE ) const;

		/**
		 * Determines whether the specified style corresonds to the default style for this style reference.
		 *
		 * @param	StyleToCheck	a pointer to a UIStyle
		 *
		 * @return	TRUE if StyleToCheck is the same style that would be resolved by this style reference if it didn't have
		 *			a valid AssignedStyleId
		 */
		UBOOL IsDefaultStyle( class UUIStyle* StyleToCheck ) const;

		/**
		 * Returns the tag for the default style associated with this UIStyleReference.
		 *
		 * @param	CurrentlyActiveSkin		the skin to search for this style references' style tag in
		 * @param	bSkinContainsStyleTag	if specified, set to TRUE if CurrentlyActiveSkin contains this style reference's
		 *									DefaultStyleTag; useful for determining whether a result of e.g. "DefaultTextStyle" is
		 *									because the active skin didn't contain the style corresponding to this reference's DefaultStyleTag,
		 *									or whether this style reference's DefaultStyleTag is actually "DefaultTextStyle"
		 *
		 * @return	if DefaultStyleTag is set and a style with that tag exists in CurrentlyActiveSkin, returns that
		 *			style's tag; otherwise returns the tag for the default style corresponding to RequiredStyleClass.
		 */
		FName GetDefaultStyleTag( class UUISkin* CurrentlyActiveSkin, UBOOL* bSkinContainsStyleTag=NULL ) const;

		/**
		 * Returns the style data for the menu state specified.
		 */
		class UUIStyle_Data* GetStyleData( class UUIState* MenuState ) const;

		/**
		 * Returns the style data for the menu state specified.
		 */
		class UUIStyle_Data* GetStyleDataByClass( class UClass* MenuState ) const;

		/**
		 * Changes the style associated with this style refrerence.
		 *
		 * @param	NewStyle	the new style to assign to this style reference
		 *
		 * @return	TRUE if the style was successfully assigned to this reference.  FALSE if the specified style was invalid
		 *			or the currently assigned style matched the new style.
		 */
		UBOOL SetStyle( class UUIStyle* NewStyle );

		/**
		 * Changes the AssignedStyleID for this style reference
		 *
		 * @param	NewStyleID	the STYLE_ID for the UIStyle to link this style reference to
		 *
		 * @return	TRUE if the AssignedStyleId was changed.  FALSE if NewStyleID matched the value of AssignedStyleID.
		 */
		UBOOL SetStyleID( const struct FSTYLE_ID& NewStyleID );

	}

};

const DEFAULT_SIZE_X = 1024;
const DEFAULT_SIZE_Y = 768;

const SCENE_DATASTORE_TAG='SceneData';

const MAX_SUPPORTED_GAMEPADS=4;


/**
 * Represents a screen position, either as number of pixels or percentage.
 * Used for single dimension (point) values.
 */
struct native UIScreenValue
{
	/** the value, in either pixels or percentage */
	var()		float					Value;

	/** how this UIScreenValue should be evaluated */
	var()		EPositionEvalType		ScaleType;

	/** the orientation associated with this UIScreenValue.  Used for evaluating relative or percentage scaling types */
	var()		EUIOrientation			Orientation;

	structcpptext
	{
		/**
		 * Calculates the origin and extent for the position value of a single widget face
		 *
		 * @param	OwnerWidget			the widget that owns this position
		 * @param	Face				the face to evaluate
		 * @param	Type				indicates how the base values will be used, how they should be formatted
		 * @param	BaseValue			[out] absolute pixel values for the base of this position for the specified face.  For example,
		 *								if the Face is UIFACE_Left, BaseValue will represent the X position of the OwnerWidget's container,
		 *								in absolute pixel values
		 * @param	bInternalPosition	specify TRUE to indicate that BaseValue should come from OwnerWidget; FALSE to indicate that BaseValue should come from
		 *								OwnerWidget's parent widget.
		 * @param	bIgnoreDockPadding	used to prevent recursion when evaluting docking links
		 */
		static void CalculateBaseValue( const class UUIScreenObject* OwnerWidget, EUIWidgetFace Face, EPositionEvalType Type, FLOAT& BaseValue, FLOAT& BaseExtent, UBOOL bInternalPosition=FALSE, UBOOL bIgnoreDockPadding=FALSE );

		/**
		 * Evaluates the value stored in this UIScreenValue
		 *
		 * @param	OwnerWidget	the widget that contains this screen value
		 * @param	OutputType	determines the format of the result.
		 *						EVALPOS_None:
		 *							return value is formatted using this screen position's ScaleType for the specified face
		 *						EVALPOS_PercentageOwner:
		 *						EVALPOS_PercentageScene:
		 *						EVALPOS_PercentageViewport:
		 *							return a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *							base's actual size.  If OwnerWidget isn't specified, the size of the
		 *							entire viewport is used.
		 *						EVALPOS_PixelOwner
		 *						EVALPOS_PixelScene
		 *						EVALPOS_PixelViewport
		 *							return the actual pixel values represented by this UIScreenValue, relative to the corresponding base.
		 * @param	bInternalPosition
		 *						specify TRUE if this UIScreenValue represents a point or distance inside of OwnerWidget, in which case any
		 *						relative scale types will use OwnerWidget as the base.  Specify FALSE if it represents a point/distance outside
		 *						OwnerWidget, in which case OwnerWidget's parent will be used as a base.
		 *
		 * @return	the actual value for this UIScreenValue, in pixels or percentage, for the face specified.
		 */
		FLOAT GetValue( const class UUIScreenObject* OwnerWidget, EPositionEvalType OutputType=EVALPOS_None, UBOOL bInternalPosition=TRUE ) const;

		/**
		 * Convert the input value into the appropriate type for this UIScreenValue, and assign that Value
		 *
		 * @param	OwnerWidget		the widget that contains this screen value
		 * @param	NewValue		the new value (in pixels or percentage) to use
		 * @param	InputType		indicates the format of the input value
		 *							EVALPOS_None:
		 *								NewValue is assumed to be formatted with what this screen position's ScaleType is for the specified face
		 *							EVALPOS_PercentageOwner:
		 *							EVALPOS_PercentageScene:
		 *							EVALPOS_PercentageViewport:
		 *								Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *								base's actual size.
		 *							EVALPOS_PixelOwner
		 *							EVALPOS_PixelScene
		 *							EVALPOS_PixelViewport
		 *								Indicates that NewValue is an actual pixel value, relative to the corresponding base.
		 */
		void SetValue( class UUIScreenObject* OwnerWidget, FLOAT NewValue, EPositionEvalType InputType=EVALPOS_PixelViewport );

		/**
		 * Changes the scale type for the specified face to the value specified, and converts the Value for that face into the new type.
		 *
		 * @param	OwnerWidget			the widget that contains this screen value
		 * @param	NewEvalType			the evaluation type to set for the specified face
		 * @param	bAutoConvertValue	if TRUE, the current value of the position will be converted into the equivalent value for the new type
		 */
		void ChangeScaleType( class UUIScreenObject* OwnerWidget, EPositionEvalType NewEvalType, UBOOL bAutoConvertValue=TRUE );

		/**
		 * Constructors
		 */
		FUIScreenValue()
		{ }

		FUIScreenValue(EEventParm)
		{
			Value = 0.f;
			ScaleType = EVALPOS_PixelViewport;
		}

		FUIScreenValue( FLOAT inValue, EUIOrientation inOrientation )
		: Value(inValue), ScaleType(EVALPOS_None), Orientation(inOrientation)
		{ }

		FUIScreenValue( FLOAT inValue, EPositionEvalType inScaleType, EUIOrientation inOrientation )
		: Value(inValue), ScaleType(inScaleType), Orientation(inOrientation)
		{ }
	}

	structdefaultproperties
	{
		ScaleType=EVALPOS_PixelViewport
		Orientation=UIORIENT_Horizontal
	}

};


/**
 * Very similar to UIScreenValue (which represents a point within a widget), this data structure is used for representing
 * a sub-region of the screen, in a single dimension
 */
struct native UIScreenValue_Extent
{
	/** the value, in either pixels or percentage */
	var()		float					Value;

	/** how this extent value should be evaluated */
	var()		EUIExtentEvalType		ScaleType;

	/** the orientation associated with this extent.  Used for evaluating percentage scaling types */
	var()		EUIOrientation			Orientation;

	structcpptext
	{
		/**
		 * Calculates the extent to use as the base for evaluating percentage values.
		 *
		 * @param	OwnerWidget		the widget that contains this extent value
		 * @param	EvaluationType	indicates which base to use for calculating the base extent
		 * @param	BaseExtent		[out] set to the size of the region that will be used for evaluating this extent as a percentage; actual pixels
		 */
		void CalculateBaseExtent( const class UUIScreenObject* OwnerWidget, EUIExtentEvalType EvalType, FLOAT& BaseExtent ) const;

		/**
		 * Resolves the value stored in this extent according to the specified output type.
		 *
		 * @param	OwnerWidget		the widget that contains this extent value
		 * @param	OutputType	indicates the desired format for the result
		 *						UIEXTENTEVAL_Pixels:
		 *							Result should be the actual number of pixels
		 *						UIEXTENTEVAL_PercentOwner:
		 *							result should be formatted as a percentage of the widget's parent
		 *						UIEXTENTEVAL_PercentScene:
		 *							result should be formatted as a percentage of the scene
		 *						UIEXTENTEVAL_PercentViewport:
		 *							result should be formatted as a percentage of the viewport
		 *
		 * @return	the value of the auto-size region's min or max value
		 */
		FLOAT GetValue( const class UUIScreenObject* OwnerWidget, EUIExtentEvalType OutputType=UIEXTENTEVAL_Pixels ) const;

		/**
		 * Convert the input value into the appropriate type for this UIScreenValue, and assign that Value
		 *
		 * @param	OwnerWidget	the widget that contains this extent value
		 * @param	NewValue	the new value (in pixels or percentage) to use
		 * @param	OutputType	specifies how NewValue should be interpreted format for the result
		 *						UIEXTENTEVAL_Pixels:
		 *							NewValue is in absolute pixels
		 *						UIEXTENTEVAL_PercentOwner:
		 *							NewValue is a percentage of the OwnerWidget
		 *						UIEXTENTEVAL_PercentScene:
		 *							NewValue is a percentage of the scene
		 *						UIEXTENTEVAL_PercentViewport:
		 *							NewValue is a percentage of the viewport
		 */
		void SetValue( class UUIScreenObject* OwnerWidget, FLOAT NewValue, EUIExtentEvalType InputType=UIEXTENTEVAL_Pixels );

		/**
		 * Changes the scale type for this extent to the type specified, optionally converting the current Value into the new type.
		 *
		 * @param	OwnerWidget			the widget that contains this screen value
		 * @param	NewEvalType			the new evaluation type to ise
		 * @param	bAutoConvertValue	if TRUE, the current value of the position will be converted into the equivalent value for the new type
		 */
		void ChangeScaleType( class UUIScreenObject* OwnerWidget, EUIExtentEvalType NewEvalType, UBOOL bAutoConvertValue=TRUE );

		/**
		 * Convert a EUIExtentEvalType into a EPositionEvalType
		 */
		static EPositionEvalType TranslateScaleType( EUIExtentEvalType EvalType )
		{
			EPositionEvalType Result = EVALPOS_PixelViewport;
			switch ( EvalType )
			{
			case UIEXTENTEVAL_PercentSelf:
			case UIEXTENTEVAL_PercentOwner:
				Result = EVALPOS_PercentageOwner;
				break;
			case UIEXTENTEVAL_PercentScene:
				Result = EVALPOS_PercentageScene;
				break;
			case UIEXTENTEVAL_PercentViewport:
				Result = EVALPOS_PercentageViewport;
				break;
			}
			return Result;
		}


		/**
		 * Constructors
		 */
		FUIScreenValue_Extent()
		{ }

		FUIScreenValue_Extent(EEventParm)
		{
			Value = 0.f;
			ScaleType = UIEXTENTEVAL_Pixels;
			Orientation = UIORIENT_Horizontal;
		}

		FUIScreenValue_Extent( FLOAT inValue, EUIOrientation inOrientation )
		: Value(inValue), ScaleType(UIEXTENTEVAL_Pixels), Orientation(inOrientation)
		{ }

		FUIScreenValue_Extent( FLOAT inValue, EUIExtentEvalType inScaleType, EUIOrientation inOrientation )
		: Value(inValue), ScaleType(inScaleType), Orientation(inOrientation)
		{ }

		/** @name Comparison operators */
		//@{
		UBOOL operator==( const FUIScreenValue_Extent& Other ) const
		{
			return	ARE_FLOATS_EQUAL(Value,Other.Value)
				&&	ScaleType	== Other.ScaleType
				&&	Orientation	== Other.Orientation;
		}
		UBOOL operator!=( const FUIScreenValue_Extent& Other ) const
		{
			return	!ARE_FLOATS_EQUAL(Value,Other.Value)
				||	ScaleType	!= Other.ScaleType
				||	Orientation	!= Other.Orientation;
		}
		//@}
	}

	structdefaultproperties
	{
		Value=0.f
		ScaleType=UIEXTENTEVAL_Pixels
		Orientation=UIORIENT_Horizontal
	}
};

/**
 * Represents a screen position, either as number of pixels or percentage.
 * Used for double dimension (orientation) values.
 */
struct native UIScreenValue_Position
{
	var()		float					Value[EUIOrientation.UIORIENT_MAX];
	var()		EPositionEvalType		ScaleType[EUIOrientation.UIORIENT_MAX];

	structcpptext
	{
		/**
		 * Evaluates the value stored in this UIScreenValue. It assumes that a Dimension of UIORIENT_Horizontal will correspond to the Left face and
		 * that a Dinemsion of UIORIENT_Vertical will correspond to the Right face.
		 *
		 * @param	Dimension		indicates which element of the Value array to evaluate
		 * @param	InputType		indicates the format of the input value
		 *							EVALPOS_None:
		 *								NewValue is assumed to be formatted with what this screen position's ScaleType is for the specified face
		 *							EVALPOS_PercentageOwner:
		 *							EVALPOS_PercentageScene:
		 *							EVALPOS_PercentageViewport:
		 *								Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *								base's actual size.
		 *							EVALPOS_PixelOwner:
		 *							EVALPOS_PixelScene:
		 *							EVALPOS_PixelViewport
		 *								Indicates that NewValue is an actual pixel value, relative to the corresponding base.
		 * @param	OwnerWidget		the widget that contains this screen value
		 *
		 * @return	the actual value for this UIScreenValue, in pixels or percentage, for the dimension specified.
		 */
		FLOAT GetValue( EUIOrientation Dimension, EPositionEvalType OutputType, const class UUIScreenObject* OwnerWidget ) const;

		/**
		 * Evaluates the value stored in this UIScreenValue
		 *
		 * @param	Dimension		indicates which element of the Value array to evaluate
		 * @param	Face			indicates which face on the owner widget the element from the Value array will be relative to (if InputType is
		 *							applicable ).
		 * @param	InputType		indicates the format of the input value
		 *							EVALPOS_None:
		 *								NewValue is assumed to be formatted with what this screen position's ScaleType is for the specified face
		 *							EVALPOS_PercentageOwner:
		 *							EVALPOS_PercentageScene:
		 *							EVALPOS_PercentageViewport:
		 *								Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *								base's actual size.
		 *							EVALPOS_PixelOwner:
		 *							EVALPOS_PixelScene:
		 *							EVALPOS_PixelViewport
		 *								Indicates that NewValue is an actual pixel value, relative to the corresponding base.
		 * @param	OwnerWidget		the widget that contains this screen value
		 *
		 * @return	the actual value for this UIScreenValue, in pixels or percentage, for the dimension specified.
		 */
		FLOAT GetValue( EUIOrientation Dimension, EUIWidgetFace Face, EPositionEvalType OutputType, const class UUIScreenObject* OwnerWidget ) const;

		/**
		 * Convert the input value into the appropriate type for this UIScreenValue, and assign that Value
		 *
		 * @param	OwnerWidget		the widget that contains this screen value
		 * @param	Dimension		indicates which element of the Value array to evaluate
		 * @param	NewValue		the new value (in pixels or percentage) to use
		 * @param	InputType		indicates the format of the input value
		 *							EVALPOS_None:
		 *								NewValue is assumed to be formatted with what this screen position's ScaleType is for the specified face
		 *							EVALPOS_PercentageOwner:
		 *							EVALPOS_PercentageScene:
		 *							EVALPOS_PercentageViewport:
		 *								Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *								base's actual size.
		 *							EVALPOS_PixelOwner
		 *							EVALPOS_PixelScene
		 *							EVALPOS_PixelViewport
		 *								Indicates that NewValue is an actual pixel value, relative to the corresponding base.
		 */
		void SetValue( const class UUIScreenObject* OwnerWidget, EUIOrientation Dimension, FLOAT NewValue, EPositionEvalType InputType=EVALPOS_PixelViewport );

		/** Constructors */
		FUIScreenValue_Position()
		{
			// do not initialize any members in the default constructor
		}
		FUIScreenValue_Position(EEventParm)
		{
			Value[UIORIENT_Horizontal] = 0.f;
			Value[UIORIENT_Vertical] = 0.f;
			ScaleType[UIORIENT_Horizontal] = EVALPOS_PixelOwner;
			ScaleType[UIORIENT_Vertical] = EVALPOS_PixelOwner;
		}
		FUIScreenValue_Position( FLOAT XValue, FLOAT YValue )
		{
			Value[UIORIENT_Horizontal]	=	XValue;
			Value[UIORIENT_Vertical]	=	YValue;
			for ( INT i = 0; i < UIORIENT_MAX; i++ )
			{
				ScaleType[i] = EVALPOS_None;
			}
		}
		FUIScreenValue_Position( FLOAT XValue, FLOAT YValue, EPositionEvalType XScaleType, EPositionEvalType YScaleType )
		{
			Value[UIORIENT_Horizontal]		=	XValue;
			Value[UIORIENT_Vertical]		=	YValue;

			ScaleType[UIORIENT_Horizontal]	=	XScaleType;
			ScaleType[UIORIENT_Vertical]	=	YScaleType;
		}

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FUIScreenValue_Position& Other ) const
		{
			return	ARE_FLOATS_EQUAL(Other.Value[UIORIENT_Horizontal],Value[UIORIENT_Horizontal])
				&&	ARE_FLOATS_EQUAL(Other.Value[UIORIENT_Vertical],Value[UIORIENT_Vertical])
				&&	Other.ScaleType[UIORIENT_Horizontal]	== ScaleType[UIORIENT_Horizontal]
				&&	Other.ScaleType[UIORIENT_Vertical]		== ScaleType[UIORIENT_Vertical];
		}
		FORCEINLINE UBOOL operator!=( const FUIScreenValue_Position& Other ) const
		{
			return	!ARE_FLOATS_EQUAL(Other.Value[UIORIENT_Horizontal],Value[UIORIENT_Horizontal])
				||	!ARE_FLOATS_EQUAL(Other.Value[UIORIENT_Vertical],Value[UIORIENT_Vertical])
				||	Other.ScaleType[UIORIENT_Horizontal]	!= ScaleType[UIORIENT_Horizontal]
				||	Other.ScaleType[UIORIENT_Vertical]		!= ScaleType[UIORIENT_Vertical];
		}
	}

	structdefaultproperties
	{
		ScaleType[UIORIENT_Horizontal] = EVALPOS_PixelOwner;
		ScaleType[UIORIENT_Vertical] = EVALPOS_PixelOwner;
	}
};

/**
 * Represents a widget's position onscreen, either as number of pixels or percentage.
 * Used for four dimension (bounds) values.
 */
struct native UIScreenValue_Bounds
{
	/**
	 * The value for each face.  Can be a pixel or percentage value.
	 */
	var()	editconst public{private}		float							Value[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Specifies how the value for each face should be intepreted.
	 */
	var()	editconst public{private}		EPositionEvalType				ScaleType[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Indicates whether the position for each face has been modified since it was last resolved into screen pixels
	 * and applied to the owning widget's RenderBounds.  If this value is FALSE, it indicates that the RenderBounds for
	 * the corresponding face in the owning widget matches the position Value.  A value of TRUE indicates that the
	 * position Value for that face has been changed since it was last converted into RenderBounds.
	 */
	var		transient public{private}		byte							bInvalidated[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Specifies whether this position's values should be adjusted to constrain to the current aspect ratio.
	 *
	 * @fixme ronp - can't make editconst until we've exposed this to the position panel, context menu, and/or widget drag tools
	 */
	var()	/*editconst*/	public{private}		EUIAspectRatioConstraint		AspectRatioMode;

	structcpptext
	{
		/**
		 * Evaluates the value stored in this UIScreenValue
		 *
		 * @param	OwnerWidget	the widget that contains this screen value
		 * @param	Face		indicates which element of the Value array to evaluate
		 * @param	OutputType	determines the format of the result.
		 *						EVALPOS_None:
		 *							return value is formatted using this screen position's ScaleType for the specified face
		 *						EVALPOS_PercentageOwner:
		 *						EVALPOS_PercentageScene:
		 *						EVALPOS_PercentageViewport:
		 *							return a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *							base's actual size.  If OwnerWidget isn't specified, the size of the
		 *							entire viewport is used.
		 *						EVALPOS_PixelOwner
		 *						EVALPOS_PixelScene
		 *						EVALPOS_PixelViewport
		 *							return the actual pixel values represented by this UIScreenValue, relative to the corresponding base.
		 * @param	bIgnoreDockPadding
		 *						used to prevent recursion when evaluting docking links
		 *
		 * @return	the actual value for this UIScreenValue, in pixels or percentage, for the face specified.
		 */
		FLOAT GetPositionValue( const class UUIScreenObject* OwnerWidget, EUIWidgetFace Face, EPositionEvalType OutputType=EVALPOS_None, UBOOL bIgnoreDockPadding=FALSE ) const;


		/**
		 * Convert the value specified into the appropriate type for this screen value, and set that as the value for the face specified.
		 *
		 * @param	OwnerWidget		the widget that contains this screen value
		 * @param	NewValue		the new value (in pixels or percentage) to use
		 * @param	Face			indicates which element of the Value array to modify
		 * @param	InputType		indicates the format of the input value
		 *							EVALPOS_None:
		 *								NewValue is assumed to be formatted with what this screen position's ScaleType is for the specified face
		 *							EVALPOS_PercentageOwner:
		 *							EVALPOS_PercentageScene:
		 *							EVALPOS_PercentageViewport:
		 *								Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *								base's actual size.
		 *							EVALPOS_PixelOwner
		 *							EVALPOS_PixelScene
		 *							EVALPOS_PixelViewport
		 *								Indicates that NewValue is an actual pixel value, relative to the corresponding base.
		 * @param	bResolveChange	indicates whether a scene update should be requested if NewValue does not match the current value.
		 */
		void SetPositionValue( class UUIScreenObject* OwnerWidget, FLOAT NewValue, EUIWidgetFace Face, EPositionEvalType InputType=EVALPOS_PixelOwner, UBOOL bResolveChange=TRUE );

		/**
		 * Retrieves the value of the width or height of this widget's bounds.
		 *
		 * @param	OwnerWidget	the widget that contains this screen value
		 * @param	Dimension	determines whether width or height is desired.  Specify UIORIENT_Horizontal to get the width, or UIORIENT_Vertical to get the height.
		 * @param	OutputType	determines the format of the result.
		 *						EVALPOS_None:
		 *							return value is formatted using this screen position's ScaleType for the specified face
		 *						EVALPOS_PercentageOwner:
		 *						EVALPOS_PercentageScene:
		 *						EVALPOS_PercentageViewport:
		 *							return a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *							base's actual size.  If OwnerWidget isn't specified, the size of the
		 *							entire viewport is used.
		 *						EVALPOS_PixelOwner
		 *						EVALPOS_PixelScene
		 *						EVALPOS_PixelViewport
		 *							return the actual pixel values represented by this UIScreenValue, relative to the corresponding base.
		 * @param	bIgnoreDockPadding
		 *						used to prevent recursion when evaluting docking links
		 *
		 * @return	the value of the width/height of this UIScreenValue, in pixels or percentage.
		 */
		FLOAT GetBoundsExtent( const class UUIScreenObject* OwnerWidget, EUIOrientation Dimension, EPositionEvalType OutputType=EVALPOS_PixelOwner, UBOOL bIgnoreDockPadding=FALSE ) const;

		/**
		 * Changes the scale type for the specified face to the value specified, and converts the Value for that face into the new type.
		 *
		 * @param	Face				indicates which element of the Value array to modify
		 * @param	OwnerWidget			the widget that contains this screen value
		 * @param	NewEvalType			the evaluation type to set for the specified face
		 * @param	bAutoConvertValue	if TRUE, the current value of the position will be converted into the equivalent value for the new type
		 */
		void ChangeScaleType( class UUIScreenObject* OwnerWidget, EUIWidgetFace Face, EPositionEvalType NewEvalType, UBOOL bAutoConvertValue=TRUE );

		/**
		 * Returns the ScaleType for the specified face.
		 *
		 * @param	Face	indicates which element of the ScaleType array to return.
		 *
		 * @return	the current value of ScaleType for the specified face.
		 */
		FORCEINLINE EPositionEvalType GetScaleType( EUIWidgetFace Face ) const
		{
			checkSlow(Face<UIFACE_MAX);
			return (EPositionEvalType)ScaleType[Face];
		}

		/**
		 * Changes the value for the specified face without performing any conversion.
		 *
		 * @param	Face			indicates which element of the Value array to modify; value must be one of the EUIWidgetFace values.
		 * @param	NewValue		the new value (in pixels or percentage) to use
		 * @param	NewScaleType	if specified, modified the ScaleType for this face as well.
		 */
		void SetRawPositionValue( BYTE Face, FLOAT NewValue, EPositionEvalType NewScaleType=EVALPOS_None );

		/**
		 * Changes the ScaleType for the specified face without performing any conversion.
		 *
		 * @param	Face			indicates which element of the Value array to modify; value must be one of the EUIWidgetFace values.
		 * @param	NewScaleType	the new scale type to use.
		 */
		void SetRawScaleType( BYTE Face, EPositionEvalType NewScaleType );

		/**
		 * Changes the AspectRatioMode for this screen value.
		 *
		 * @param	NewAspectRatioMode	the new aspect ratio mode; must be one of the EUIAspectRatioConstraint values.
		 */
		void SetAspectRatioMode( BYTE NewAspectRatioMode );

		/**
		 * Gets the current AspectRatioMode for this screen value.
		 */
		EUIAspectRatioConstraint GetAspectRatioMode() const
		{
			return (EUIAspectRatioConstraint)AspectRatioMode;
		}

		/**
		 * Toggles the bInvalidated flag for the specified face.
		 *
		 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
		 */
		FORCEINLINE void ValidatePosition( BYTE Face )
		{
			checkSlow(Face<UIFACE_MAX);
			bInvalidated[Face] = FALSE;
		}
		FORCEINLINE void InvalidatePosition( BYTE Face )
		{
			checkSlow(Face<UIFACE_MAX);
			bInvalidated[Face] = TRUE;
		}
		FORCEINLINE void InvalidateAllFaces()
		{
			bInvalidated[UIFACE_Left] = TRUE;
			bInvalidated[UIFACE_Top] = TRUE;
			bInvalidated[UIFACE_Right] = TRUE;
			bInvalidated[UIFACE_Bottom] = TRUE;
		}

		/**
		 * Returns whether the Value for the specified face has been modified since that face was last resolved.
		 *
		 * @param	OwnerWidget			the widget that contains this screen value
		 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
		 */
		UBOOL IsPositionCurrent( const class UUIObject* OwnerWidget, EUIWidgetFace Face ) const;

		/** @name Constructors */
		//@{
		FUIScreenValue_Bounds()
		{
			// do not initialize any members in the default constructor
		}
		FUIScreenValue_Bounds( EEventParm )
		{
			// zero-initialization ctor
			appMemzero(this, sizeof(FUIScreenValue_Bounds));
		}
		FUIScreenValue_Bounds( FLOAT LeftValue, FLOAT TopValue, FLOAT RightValue, FLOAT BottomValue )
		{
			Value[UIFACE_Left]		=	LeftValue;
			Value[UIFACE_Top]		=	RightValue;
			Value[UIFACE_Right]		=	LeftValue;
			Value[UIFACE_Bottom]	=	RightValue;

			for ( INT i = 0; i < UIFACE_MAX; i++ )
			{
				ScaleType[i] = EVALPOS_None;
				bInvalidated[i] = TRUE;
			}
			AspectRatioMode = UIASPECTRATIO_AdjustNone;
		}
		FUIScreenValue_Bounds
		(
			FLOAT LeftValue, FLOAT TopValue, FLOAT RightValue, FLOAT BottomValue,
			EPositionEvalType LeftScaleType, EPositionEvalType TopScaleType, EPositionEvalType RightScaleType, EPositionEvalType BottomScaleType
		)
		{
			Value[UIFACE_Left]			=	LeftValue;
			Value[UIFACE_Top]			=	RightValue;
			Value[UIFACE_Right]			=	LeftValue;
			Value[UIFACE_Bottom]		=	RightValue;
			ScaleType[UIFACE_Left]		=	LeftScaleType;
			ScaleType[UIFACE_Top]		=	TopScaleType;
			ScaleType[UIFACE_Right]		=	RightScaleType;
			ScaleType[UIFACE_Bottom]	=	BottomScaleType;
			for ( INT i = 0; i < UIFACE_MAX; i++ )
			{
				bInvalidated[i] = TRUE;
			}

			AspectRatioMode = UIASPECTRATIO_AdjustNone;
		}
		//@}

		/** @name Comparison operators */
		//@{
		UBOOL operator==( const FUIScreenValue_Bounds& Other ) const
		{
			return	AspectRatioMode == Other.AspectRatioMode
				&&	ARE_FLOATS_EQUAL(Value[UIFACE_Left],Other.Value[UIFACE_Left])
				&&	ARE_FLOATS_EQUAL(Value[UIFACE_Top],Other.Value[UIFACE_Top])
				&&	ARE_FLOATS_EQUAL(Value[UIFACE_Right],Other.Value[UIFACE_Right])
				&&	ARE_FLOATS_EQUAL(Value[UIFACE_Bottom],Other.Value[UIFACE_Bottom])
				&&	appMemcmp(ScaleType, Other.ScaleType, sizeof(ScaleType)) == 0
				&&	appMemcmp(bInvalidated, Other.bInvalidated, sizeof(bInvalidated)) == 0;
		}
		UBOOL operator!=( const FUIScreenValue_Bounds& Other ) const
		{
			return !(FUIScreenValue_Bounds::operator==(Other));
		}
		//@}
	}

	structdefaultproperties
	{
		Value[UIFACE_Left]		= 0.0;
		Value[UIFACE_Top]		= 0.0;
		Value[UIFACE_Right]		= 1.0;
		Value[UIFACE_Bottom]	= 1.0;
		ScaleType[UIFACE_Left]	= EVALPOS_PercentageOwner;
		ScaleType[UIFACE_Top]	= EVALPOS_PercentageOwner;
		ScaleType[UIFACE_Right]	= EVALPOS_PercentageOwner;
		ScaleType[UIFACE_Bottom]= EVALPOS_PercentageOwner;
		bInvalidated[UIFACE_Left]	= 1;
		bInvalidated[UIFACE_Top]	= 1;
		bInvalidated[UIFACE_Right]	= 1;
		bInvalidated[UIFACE_Bottom]	= 1;
		AspectRatioMode=UIASPECTRATIO_AdjustNone;
	}
};


/**
 * Data structure for describing the location of a widget's rotation pivot.  Defines a 2D point within a widget's bounds,
 * either in pixels or percentage, along with a z-depth value (in pixels)
 */
struct native UIAnchorPosition extends UIScreenValue_Position
{
	var()	/*editconst public{private}*/	float		ZDepth;

	structcpptext
	{
		/** Constructors */
		FUIAnchorPosition()
		{
			// do not initialize any members in the default constructor
		}
		FUIAnchorPosition(EEventParm)
		: FUIScreenValue_Position(EC_EventParm), ZDepth(0.f)
		{ }
		FUIAnchorPosition(FLOAT XValue, FLOAT YValue)
		: FUIScreenValue_Position(XValue, YValue), ZDepth(0.f)
		{ }
		FUIAnchorPosition(FLOAT XValue, FLOAT YValue, FLOAT InZDepth)
		: FUIScreenValue_Position(XValue, YValue), ZDepth(InZDepth)
		{ }
		FUIAnchorPosition( FLOAT XValue, FLOAT YValue, EPositionEvalType XScaleType, EPositionEvalType YScaleType )
		: FUIScreenValue_Position(XValue, YValue, XScaleType, YScaleType), ZDepth(0.f)
		{ }
		FUIAnchorPosition( FLOAT XValue, FLOAT YValue, EPositionEvalType XScaleType, EPositionEvalType YScaleType, FLOAT InZDepth )
		: FUIScreenValue_Position(XValue, YValue, XScaleType, YScaleType), ZDepth(InZDepth)
		{ }

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FUIAnchorPosition& Other ) const
		{
			return ARE_FLOATS_EQUAL(ZDepth,Other.ZDepth)
				&& FUIScreenValue_Position::operator==((const FUIScreenValue_Position&)Other);
		}
		FORCEINLINE UBOOL operator!=( const FUIAnchorPosition& Other ) const
		{
			return !ARE_FLOATS_EQUAL(ZDepth,Other.ZDepth)
				|| FUIScreenValue_Position::operator!=((const FUIScreenValue_Position&)Other);
		}
	}
};

/**
 * Data structure for mapping a region on the screen.
 * Rather than representing an X,Y coordinate, this struct represents the beginning and end of a dimension (X1, X2)
 */
struct native ScreenPositionRange extends UIScreenValue_Position
{
	structcpptext
	{
		/**
		 * Retrieves the value of the distance between the endpoints of this region
		 *
		 * @param	Dimension	indicates which element of the Value array to evaluate
		 * @param	OutputType	determines the format of the result.
		 *						EVALPOS_None:
		 *							return value is formatted using this screen position's ScaleType for the specified face
		 *						EVALPOS_PercentageOwner:	(only valid when OwnerWidget is specified)
		 *						EVALPOS_PercentageScene:	(only valid when OwnerWidget is specified)
		 *						EVALPOS_PercentageViewport:
		 *							return a value between 0.0 and 1.0, which represents the percentage of the corresponding
		 *							base's actual size.  If OwnerWidget isn't specified, the size of the
		 *							entire viewport is used.
		 *						EVALPOS_PixelOwner:			(only valid when OwnerWidget is specified)
		 *						EVALPOS_PixelScene:			(only valid when OwnerWidget is specified)
		 *						EVALPOS_PixelViewport
		 *							return the actual pixel values represented by this UIScreenValue, relative to the corresponding base.
		 * @param	OwnerWidget	the widget that contains this screen value
		 *
		 * @return	the value of the width of this UIScreenValue, in pixels or percentage.
		 */
		FLOAT GetRegionValue( EUIOrientation Dimension, EPositionEvalType OutputType, class UUIScreenObject* OwnerWidget ) const;

		/** Comparison */
		UBOOL operator ==( const FScreenPositionRange& Other ) const;
		UBOOL operator !=( const FScreenPositionRange& Other ) const;
	}
};

struct native UIScreenValue_DockPadding
{
	/**
	 * The value for each face.  Can be in pixels or a percentage of the owning widget's bounding region, depending on the
	 * ScaleType for each face.
	 */
	var()	editconst public{private}		float							PaddingValue[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Specifies how the Value for each face should be intepreted.
	 */
	var()	editconst public{private}		EUIDockPaddingEvalType			PaddingScaleType[EUIWidgetFace.UIFACE_MAX];

	structcpptext
	{
		/**
		 * Calculates the size of the base region used for formatting the padding value of a single widget face
		 *
		 * @param	OwnerWidget			the widget that owns this padding
		 * @param	EvalFace			the face to evaluate
		 * @param	EvalType			indicates which type of base value is desired
		 * @param	BaseExtent			[out] the base extent for the specified face, in absolute pixel values.  BaseExtent is defined as the size of the widget associated with
		 *								the specified dock padding type and face's orientation.
		 */
		static void CalculateBaseExtent( const class UUIObject* OwnerWidget, EUIWidgetFace EvalFace, EUIDockPaddingEvalType EvalType, FLOAT& BaseExtent );

		/**
		 * Evaluates the value stored in this UIScreenValue_DockPadding
		 *
		 * @param	OwnerWidget	the widget that contains this screen value
		 * @param	Face		indicates which element of the Value array to evaluate
		 * @param	OutputType	indicates the desired format for the result
		 *						UIPADDINGEVAL_Pixels:
		 *							Result should be the actual number of pixels
		 *						UIPADDINGEVAL_PercentTarget:
		 *							result should be formatted as a percentage of the dock target
		 *						UIPADDINGEVAL_PercentOwner:
		 *							result should be formatted as a percentage of the widget's parent
		 *						UIPADDINGEVAL_PercentScene:
		 *							result should be formatted as a percentage of the scene
		 *						UIPADDINGEVAL_PercentViewport:
		 *							result should be formatted as a percentage of the viewport
		 *
		 * @return	the actual value for this UIScreenValue, in pixels or percentage, for the face specified.
		 */
		FLOAT GetPaddingValue( const class UUIObject* OwnerWidget, EUIWidgetFace Face, EUIDockPaddingEvalType OutputType=UIPADDINGEVAL_Pixels ) const;


		/**
		 * Convert the value specified into the appropriate format and assign the converted value to the Value element for the face specified.
		 *
		 * @param	OwnerWidget		the widget that contains this screen value
		 * @param	NewValue		the new value (in pixels or percentage) to use
		 * @param	Face			indicates which element of the Value array to modify
		 * @param	InputType		indicates the desired format for the result
		 *							UIPADDINGEVAL_Pixels:
		 *								NewValue is in pixels
		 *							UIPADDINGEVAL_PercentTarget:
		 *								NewValue is a percentage of the dock target extent in the corresponding orientation
		 *							UIPADDINGEVAL_PercentOwner:
		 *								NewValue is a percentage of OwnerWidget parent's extent in the corresponding orientation
		 *							UIPADDINGEVAL_PercentScene:
		 *								NewValue is a percentage of the scene
		 *							UIPADDINGEVAL_PercentViewport:
		 *								NewValue is a percentage of the viewport.
		 * @param	bResolveChange	indicates whether a scene update should be requested if NewValue does not match the current value.
		 */
		void SetPaddingValue( class UUIObject* OwnerWidget, FLOAT NewValue, EUIWidgetFace Face, EUIDockPaddingEvalType InputType=UIPADDINGEVAL_Pixels, UBOOL bResolveChange=TRUE );

		/**
		 * Changes the scale type for the specified face to the value specified, optionally converting the Value for that face into the new type.
		 *
		 * @param	OwnerWidget			the widget that contains this screen value
		 * @param	Face				indicates which element of the Value array to modify
		 * @param	NewEvalType			the evaluation type to set for the specified face
		 * @param	bAutoConvertValue	if TRUE, the current value of the position will be converted into the equivalent value for the new type
		 */
		void ChangePaddingScaleType( class UUIObject* OwnerWidget, EUIWidgetFace Face, EUIDockPaddingEvalType NewEvalType, UBOOL bAutoConvertValue=TRUE );

		/**
		 * Returns the PaddingScaleType for the specified face.
		 *
		 * @param	Face	indicates which element of the ScaleType array to return.
		 *
		 * @return	the current value of ScaleType for the specified face.
		 */
		FORCEINLINE EUIDockPaddingEvalType GetPaddingScaleType( EUIWidgetFace Face ) const
		{
			checkSlow(Face<UIFACE_MAX);
			return static_cast<EUIDockPaddingEvalType>(PaddingScaleType[Face]);
		}

		/** @name Constructors */
		//@{
		FUIScreenValue_DockPadding()
		{
			// do not initialize any members in the default constructor
		}
		FUIScreenValue_DockPadding( EEventParm )
		{
			// zero-initialization ctor
			appMemzero(this, sizeof(FUIScreenValue_DockPadding));
		}
		/** Stack constructor */
		FUIScreenValue_DockPadding
		(
			FLOAT LeftValue, FLOAT TopValue, FLOAT RightValue, FLOAT BottomValue,
			EUIDockPaddingEvalType LeftScaleType=UIPADDINGEVAL_Pixels, EUIDockPaddingEvalType TopScaleType=UIPADDINGEVAL_Pixels,
			EUIDockPaddingEvalType RightScaleType=UIPADDINGEVAL_Pixels, EUIDockPaddingEvalType BottomScaleType=UIPADDINGEVAL_Pixels
		)
		{
			PaddingValue[UIFACE_Left]		=	LeftValue;
			PaddingValue[UIFACE_Top]		=	RightValue;
			PaddingValue[UIFACE_Right]		=	LeftValue;
			PaddingValue[UIFACE_Bottom]		=	RightValue;
			PaddingScaleType[UIFACE_Left]	=	LeftScaleType;
			PaddingScaleType[UIFACE_Top]	=	TopScaleType;
			PaddingScaleType[UIFACE_Right]	=	RightScaleType;
			PaddingScaleType[UIFACE_Bottom]	=	BottomScaleType;
		}
		//@}

		/** @name Comparison operators */
		//@{
		UBOOL operator==( const FUIScreenValue_DockPadding& Other ) const
		{
			return	ARE_FLOATS_EQUAL(PaddingValue[UIFACE_Left],Other.PaddingValue[UIFACE_Left])
				&&	ARE_FLOATS_EQUAL(PaddingValue[UIFACE_Top],Other.PaddingValue[UIFACE_Top])
				&&	ARE_FLOATS_EQUAL(PaddingValue[UIFACE_Right],Other.PaddingValue[UIFACE_Right])
				&&	ARE_FLOATS_EQUAL(PaddingValue[UIFACE_Bottom],Other.PaddingValue[UIFACE_Bottom])
				&&	appMemcmp(PaddingScaleType, Other.PaddingScaleType, sizeof(PaddingScaleType)) == 0;
		}
		UBOOL operator!=( const FUIScreenValue_DockPadding& Other ) const
		{
			return !(FUIScreenValue_DockPadding::operator==(Other));
		}
		//@}
	}

	structdefaultproperties
	{
		PaddingValue[UIFACE_Left]		= 0.0;
		PaddingValue[UIFACE_Top]		= 0.0;
		PaddingValue[UIFACE_Right]		= 0.0;
		PaddingValue[UIFACE_Bottom]		= 0.0;
		PaddingScaleType[UIFACE_Left]	= UIPADDINGEVAL_Pixels;
		PaddingScaleType[UIFACE_Top]	= UIPADDINGEVAL_Pixels;
		PaddingScaleType[UIFACE_Right]	= UIPADDINGEVAL_Pixels;
		PaddingScaleType[UIFACE_Bottom]	= UIPADDINGEVAL_Pixels;
	}
};

/**
 * Represents the constraint region for auto-sizing text.
 */
struct native UIScreenValue_AutoSizeRegion
{
	var()		float					Value[EUIAutoSizeConstraintType.UIAUTOSIZEREGION_MAX];
	var()		EUIExtentEvalType		EvalType[EUIAutoSizeConstraintType.UIAUTOSIZEREGION_MAX];

	structcpptext
	{
		/** Constructors */
		FUIScreenValue_AutoSizeRegion()
		{}
		FUIScreenValue_AutoSizeRegion(EEventParm)
		{
			Value[UIAUTOSIZEREGION_Minimum] = 0.f;
			Value[UIAUTOSIZEREGION_Maximum] = 0.f;
			EvalType[UIAUTOSIZEREGION_Minimum] = UIEXTENTEVAL_Pixels;
			EvalType[UIAUTOSIZEREGION_Maximum] = UIEXTENTEVAL_Pixels;
		}

		/** Comparison operator */
		UBOOL operator==( const FUIScreenValue_AutoSizeRegion& Other ) const
		{
			return	ARE_FLOATS_EQUAL(Value[UIAUTOSIZEREGION_Minimum],Other.Value[UIAUTOSIZEREGION_Minimum])
				&&	ARE_FLOATS_EQUAL(Value[UIAUTOSIZEREGION_Maximum],Other.Value[UIAUTOSIZEREGION_Maximum])
				&&	EvalType[UIAUTOSIZEREGION_Minimum] == Other.EvalType[UIAUTOSIZEREGION_Minimum]
				&&	EvalType[UIAUTOSIZEREGION_Maximum] == Other.EvalType[UIAUTOSIZEREGION_Maximum];
		}

		/**
		 * Calculates the extent to use as the base for evaluating percentage values.
		 *
		 * @param	Orientation		indicates which orientation to use for evaluating the actual extent of the widget's parent
		 * @param	EvaluationType	indicates which base to use for calculating the base extent
		 * @param	OwnerWidget		the widget that this auto-size region is for
		 * @param	BaseExtent		[out] set to the size of the region that will be used for evaluating this auto-size region as a percentage; actual pixels
		 */
		static void CalculateBaseValue( EUIOrientation Orientation, EUIExtentEvalType EvaluationType, class UUIScreenObject* OwnerWidget, FLOAT& BaseExtent );

		/**
		 * Resolves the value stored in this AutoSizeRegion according to the specified output type.
		 *
		 * @param	ValueType	indicates whether to return the min or max value.
		 * @param	Orientation	indicates which orientation to use for e.g. evaluting values as percentage of the owning widget's parent
		 * @param	OutputType	indicates the desired format for the result
		 *						UIEXTENTEVAL_Pixels:
		 *							Result should be the actual number of pixels
		 *						UIEXTENTEVAL_PercentOwner:
		 *							result should be formatted as a percentage of the widget's parent
		 *						UIEXTENTEVAL_PercentScene:
		 *							result should be formatted as a percentage of the scene
		 *						UIEXTENTEVAL_PercentViewport:
		 *							result should be formatted as a percentage of the viewport
		 * @param	OwnerWidget	the widget that this auto-size region is for
		 *
		 * @return	the value of the auto-size region's min or max value
		 */
		FLOAT GetValue( EUIAutoSizeConstraintType ValueType, EUIOrientation Orientation, EUIExtentEvalType OutputType, class UUIScreenObject* OwnerWidget ) const;

		/**
		 * Convert the input value into the appropriate type for this UIScreenValue, and assign that Value
		 *
		 * @param	ValueType	indicates whether to set the min or max value.
		 * @param	Orientation	indicates which orientation to use for e.g. evaluting values as percentage of the owning widget's parent
		 * @param	OwnerWidget	the widget that contains this extent value
		 * @param	NewValue	the new value (in pixels or percentage) to use
		 * @param	OutputType	specifies how NewValue should be interpreted format for the result
		 *						UIEXTENTEVAL_Pixels:
		 *							NewValue is in absolute pixels
		 *						UIEXTENTEVAL_PercentOwner:
		 *							NewValue is a percentage of the OwnerWidget
		 *						UIEXTENTEVAL_PercentScene:
		 *							NewValue is a percentage of the scene
		 *						UIEXTENTEVAL_PercentViewport:
		 *							NewValue is a percentage of the viewport
		 */
		void SetValue( EUIAutoSizeConstraintType ValueType, EUIOrientation Orientation, class UUIScreenObject* OwnerWidget, FLOAT NewValue, EUIExtentEvalType InputType=UIEXTENTEVAL_Pixels );

		/**
		 * Changes the scale type for this extent to the type specified, optionally converting the current Value into the new type.
		 *
		 * @param	ValueType			indicates whether to set the min or max value.
		 * @param	Orientation			indicates which orientation to use for e.g. evaluting values as percentage of the owning widget's parent
		 * @param	OwnerWidget			the widget that contains this screen value
		 * @param	NewEvalType			the new evaluation type to ise
		 * @param	bAutoConvertValue	if TRUE, the current value of the position will be converted into the equivalent value for the new type
		 */
		void ChangeScaleType( EUIAutoSizeConstraintType ValueType, EUIOrientation Orientation, class UUIScreenObject* OwnerWidget, EUIExtentEvalType NewEvalType, UBOOL bAutoConvertValue=TRUE );
	}

	structdefaultproperties
	{
		EvalType(UIAUTOSIZEREGION_Minimum)=UIEXTENTEVAL_Pixels
		EvalType(UIAUTOSIZEREGION_Maximum)=UIEXTENTEVAL_Pixels
	}
};

/**
 * Data structure for representing the padding to apply to an auto-size region
 */
struct native AutoSizePadding extends UIScreenValue_AutoSizeRegion
{
};

/**
 * Defines parameters for auto-sizing a widget
 */
struct native AutoSizeData
{
	/** specifies the minimum and maximum values that the region can be auto-sized to */
	var()		UIScreenValue_AutoSizeRegion		Extent;

	/** the internal padding to apply to the region */
	var()		AutoSizePadding						Padding;

	/** whether auto-sizing is enabled for this dimension */
	var()		bool								bAutoSizeEnabled;

	structcpptext
	{
		/**
		 * Evaluates and returns the padding value stored in this AutoSizeData
		 *
		 * @param	ValueType	indicates which element of the Value array to evaluate
		 * @param	Orientation	indicates which orientation to use for e.g. evaluting values as percentage of the owning widget's parent
		 * @param	OutputType	specifies how the result should be formatted
		 *						UIEXTENTEVAL_Pixels:
		 *							NewValue is in absolute pixels
		 *						UIEXTENTEVAL_PercentOwner:
		 *							NewValue is a percentage of the OwnerWidget
		 *						UIEXTENTEVAL_PercentScene:
		 *							NewValue is a percentage of the scene
		 *						UIEXTENTEVAL_PercentViewport:
		 *							NewValue is a percentage of the viewport
		* @param	OwnerWidget		the widget that contains this screen value
		*
		* @return	the actual padding value for this AutoSizeData, in pixels or percentage, for the dimension specified.
		*/
		FLOAT GetPaddingValue( EUIAutoSizeConstraintType ValueType, EUIOrientation Orientation, EUIExtentEvalType OutputType, class UUIScreenObject* OwnerWidget ) const;

		/**
		 * Returns the minimum allowed size for this auto-size region.
		 *
		 * @param	OutputType		indicates how the result should be formatted.
		 * @param	Orientation		indicates which axis this auto-size region is associated with on the owner widget.
		 * @param	OwnerWidget		the widget that this auto-size region is used by.
		 *
		 * @return	the minimum size allowed for this auto-size region, or 0 if this auto-size region is disabled.
		 */
		FLOAT GetMinValue( EUIExtentEvalType OutputType, EUIOrientation Orientation, class UUIScreenObject* OwnerWidget ) const;

		/**
		 * Returns the maximum allowed size for this auto-size region.
		 *
		 * @param	OutputType		indicates how the result should be formatted.
		 * @param	Orientation		indicates which axis this auto-size region is associated with on the owner widget.
		 * @param	OwnerWidget		the widget that this auto-size region is used by.
		 *
		 * @return	the maximum size allowed for this auto-size region, or 0 if there is no max size configured or this auto-size region
		 *			is not enabled.
		 */
		FLOAT GetMaxValue( EUIExtentEvalType OutputType, EUIOrientation Orientation, class UUIScreenObject* OwnerWidget ) const;
	}
};

/**
 * Represents a sub-region within another render bounding region.
 */
struct native UIRenderingSubregion
{
	/** the size of the subregion; will be clamped to the size of the bounding region */
	var()	UIScreenValue_Extent	ClampRegionSize<DisplayName=Subregion Size>;

	/**
	 * Only relevant if ClampRegionAlignment is "Inherit/Other".  The offset for the sub-region, relative to the
	 * beginning of the bounding region.
	 */
	var()	UIScreenValue_Extent	ClampRegionOffset<DisplayName=Subregion Position>;

	/**
	 * the alignment for the sub-region; to enable "Subregion Position", this must be set to "Inherit/Other"
	 */
	var()	EUIAlignment			ClampRegionAlignment<DisplayName=Subregion Alignment>;

	/** Must be true to specify a subregion */
	var()	bool					bSubregionEnabled;

	structdefaultproperties
	{
		ClampRegionSize=(Value=1.f,ScaleType=UIEXTENTEVAL_PercentSelf)
		ClampRegionOffset=(ScaleType=UIEXTENTEVAL_PercentSelf)
		ClampRegionAlignment=UIALIGN_Default
	}
};

/**
 * Represents a mapping of input key to widgets which contain EventComponents that respond to the associated input key.
 */
struct native transient InputEventSubscription
{
	/** The name of the key represented by this InputEventSubscription (i.e. KEY_XboxTypeS_LeftTrigger, etc.) */
	var		name						KeyName;

	/** a list of widgets which are eligible to process this input key event */
	var		array<UIScreenObject>		Subscribers;

	structcpptext
	{
		/** Constructors */
		FInputEventSubscription() {}
		FInputEventSubscription( FName InKeyName )
		: KeyName(InKeyName)
		{}
	}
};

/**
 * Represents a UIEvent that should be automatically added to all instances of a particular widget.
 */
struct native DefaultEventSpecification
{
	/** the UIEvent template to use when adding the event instance to a widget's EventProvider */
	var	UIEvent				EventTemplate;

	/**
	 * Optionally specify the state in which this event should be active.  The event will be added to
	 * the corresponding UIState instance's list of events, rather than the widget's list of events
	 */
	var	class<UIState>		EventState;
};

/**
 * Associates a UIAction with input key name.
 */
struct native InputKeyAction
{
	/** the input key name that will activate the action */
	var()	name								InputKeyName;

	/** the state (pressed, released, etc.) that will activate the action */
	var()	EInputEvent							InputKeyState;

	/** The sequence operations to activate when the input key is received */
	var	array<SequenceOp.SeqOpOutputInputLink>	TriggeredOps;
	var	deprecated	array<SequenceOp>			ActionsToExecute;

	// FInputKeyAction's == operator doesn't consider the triggeredops array, so
	// we have to compare these ourselves;  actually we should fix this because
	// otherwise states might lose data when saved if the only different between
	// their archetype is the linked ops
	structcpptext
	{
		/** Default constructor; don't initialize any members or we'll overwrite values serialized from disk. */
		FInputKeyAction() {}

		/** Initialization constructor - zero initialize all members */
		FInputKeyAction(EEventParm)
		{
			appMemzero(this, sizeof(FInputKeyAction));
			InputKeyName = NAME_None;
			InputKeyState = IE_Released;
		}

		/** Copy constructor */
		FInputKeyAction( const FInputKeyAction& Other );

		/** Standard ctor */
		FInputKeyAction( FName InKeyName, EInputEvent InKeyState )
		{
			appMemzero(this, sizeof(FInputKeyAction));
			InputKeyName = InKeyName;
			InputKeyState = InKeyState;
		}

		/** Comparison operator */
		UBOOL operator==( const FInputKeyAction& Other ) const;

		/** Serialization operator */
		friend FArchive& operator<<(FArchive& Ar,FInputKeyAction& MyInputKeyAction);

		/**
		 * @return	TRUE if this input key action is linked to the sequence op.
		 */
		UBOOL IsLinkedTo( const class USequenceOp* CheckOp ) const;
	}

	structdefaultproperties
	{
		InputKeyState=IE_Released
	}
};

/**
 * Specialized version of InputKeyAction used for constraining the input action to a particular UIState.
 */
struct native StateInputKeyAction extends InputKeyAction
{
	/**
	 * Allows an input action to be tied to a specific UIState. If NULL, the action will be active
	 * in all states that support UIEvent_ProcessInput.  If non-NULL, the input key will only be accepted
	 * when the widget is in the specified state.
	 */
	var()	class<UIState>	Scope;

	structcpptext
	{
		/** Default constructor; don't initialize any members or we'll overwrite values serialized from disk. */
		FStateInputKeyAction() {}
		/** Initialization constructor - zero initialize all members */
		FStateInputKeyAction(EEventParm) : FInputKeyAction(EC_EventParm), Scope(NULL) {}
		/** Copy constructor */
		FStateInputKeyAction( const FStateInputKeyAction& Other )
		: FInputKeyAction(Other), Scope(Other.Scope) { }
		/** Standard ctor */
		FStateInputKeyAction( FName InKeyName, EInputEvent InKeyState, UClass* InScope )
		: FInputKeyAction(InKeyName,InKeyState), Scope(InScope)
		{}
		/** Copy ctor from FInputKeyAction */
		FStateInputKeyAction( const FInputKeyAction& Other, class UClass* OwnerStateClass )
		: FInputKeyAction(Other), Scope(OwnerStateClass)
		{}

		/** Comparison operator */
		UBOOL operator==( const FStateInputKeyAction& Other ) const
		{
			return ((FInputKeyAction&)*this) == Other && Scope == Other.Scope;
		}
	}

	structdefaultproperties
	{
		Scope=class'UIState_Enabled'
	}
};

/**
 * Tracks widgets which are currently in special states.
 */
struct native transient PlayerInteractionData
{
	/** The widget/scene that currently has focus */
	var		transient	UIObject			FocusedControl;

	/** The widget/scene that last had focus */
	var		transient	UIObject			LastFocusedControl;

	structcpptext
	{
		/**
		 * Changes the FocusedControl to the widget specified
		 *
		 * @param	NewFocusedControl	the widget that should become the focused control
		 */
		void SetFocusedControl( class UUIObject* NewFocusedControl );

		/**
		 * Gets the currently focused control.
		 */
		class UUIObject* GetFocusedControl() const;

		/**
		 * Changes the FocusedControl to the widget specified
		 *
		 * @param	Widget	the widget that should become the LastFocusedControl control
		 */
		void SetLastFocusedControl( class UUIObject* Widget );

		/**
		 * Gets the previously focused control.
		 */
		class UUIObject* GetLastFocusedControl() const;
	}
};

/**
 * Contains information about how to propagate focus between parent and child widgets.
 */
struct native UIFocusPropagationData
{
	/**
	 * Specifies the child widget that should automatically receive focus when this widget receives focus.
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	FirstFocusTarget;


	/**
	 * Specifies the child widget which will automatically receive focus when this widget receives focus and the user
	 * is navigating backwards through the scene (i.e. Shift+Tab).
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	LastFocusTarget;

	/**
	 * Specifies the sibling widget that is next in the tab navigation system for this widget's parent.
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	NextFocusTarget;

	/**
	 * Specifies the sibling widget that is previous in the tab navigation system for this widget's parent.
	 * Set automatically when RebuildNavigationLinks() is called on the owning widget.
	 */
	var()	const	editconst	transient	UIObject	PrevFocusTarget;

	/**
	 * Indicates that this widget is currently becoming the focused control.  Used for preventing KillFocus from clobbering this
	 * pending focus change if one of this widget's children is the currently focused control (since killing focus on a child of this
	 * widget would normally cause this widget to lose focus as well
	 */
	var							transient	bool		bPendingReceiveFocus;

	structcpptext
	{
		/**
		 * Returns the child widget that is configured as the first focus target for this widget.
		 */
		class UUIObject* GetFirstFocusTarget() const;

		/**
		 * Returns the child widget that is configured as the last focus target for this widget.
		 */
		class UUIObject* GetLastFocusTarget() const;

		/**
		 * Returns the sibling widget that is configured as the next focus target for tab navigation.
		 */
		class UUIObject* GetNextFocusTarget() const;

		/**
		 * Returns the sibling widget that is configured as the previous focus target for tab navigation.
		 */
		class UUIObject* GetPrevFocusTarget() const;

		/**
		 * Sets the default first focus target for this widget.
		 *
		 * @param	FocusTarget			the child of this widget that should become the first focus target for this widget
		 *
		 * @return	TRUE if the navigation link for the specified face changed.  FALSE if the new value wasn't applied or if the
		 *			the new value was the same as the current value.
		 */
		UBOOL SetFirstFocusTarget( class UUIObject* FocusTarget );

		/**
		 * Sets the default last focus target for this widget.
		 *
		 * @param	FocusTarget			the child of this widget that should become the last focus target for this widget.
		 *
		 * @return	TRUE if the focus target changed.  FALSE if the new value wasn't applied or if the
		 *			the new value was the same as the current value.
		 */
		UBOOL SetLastFocusTarget( class UUIObject* FocusTarget );

		/**
		 * Sets the next tab-nav focus target for this widget.
		 *
		 * @param	FocusTarget			a sibling of this widget that should become the next tab-nav target for this widget.
		 *
		 * @return	TRUE if the focus target changed.  FALSE if the new value wasn't applied or if the
		 *			the new value was the same as the current value.
		 */
		UBOOL SetNextFocusTarget( class UUIObject* FocusTarget );

		/**
		 * Sets the previous tab-nav focus target for this widget.
		 *
		 * @param	FocusTarget			a sibling of this widget that should become the previous tab-nav target for this widget.
		 *
		 * @return	TRUE if the focus target changed.  FALSE if the new value wasn't applied or if the
		 *			the new value was the same as the current value.
		 */
		UBOOL SetPrevFocusTarget( class UUIObject* FocusTarget );
	}
};

/**
 * Defines the navigation links for a widget.
 */
struct native UINavigationData
{
	/**
	 * The widgets that will receive focus when the user presses the corresonding direction.  For keyboard navigation, pressing
	 * "tab" will set focus to the widget in the UIFACE_Right slot, pressing "shift+tab" will set focus to the widget in the
	 * UIFACE_Left slot.
	 *
	 * Filled in at runtime when RebuildNavigationLinks is called.
	 */
	var()	editconst	transient	UIObject			NavigationTarget[EUIWidgetFace.UIFACE_MAX];

	/**
	 * Allows the designer to override the auto-generated focus target for each face.  If a value is set for NavigationTarget,
	 * that widget will always be set as the value for CurrentNavTarget for that face.
	 */
	var()	editconst				UIObject			ForcedNavigationTarget[EUIWidgetFace.UIFACE_MAX];

	/**
	 * By default, a NULL value for the forced nav taget indicates that the nav target for that face should be automatically
	 * calculated.  bNullOverride indicates that a value of NULL *is* the designer specified nav target.
	 */
	var()							byte				bNullOverride[EUIWidgetFace.UIFACE_MAX];

	structcpptext
	{
		/**
		 * Sets the actual navigation target for the specified face.
		 *
		 * @param	Face			the face to set the navigation link for
		 * @param	NewNavTarget	the widget to set as the link for the specified face
		 *
		 * @return	TRUE if the navigation link for the specified face changed.  FALSE if the new value wasn't applied or if the
		 *			the new value was the same as the current value.
		 */
		UBOOL SetNavigationTarget( EUIWidgetFace Face, class UUIObject* NewNavTarget );
		UBOOL SetNavigationTarget( class UUIObject* LeftTarget, class UUIObject* TopTarget, class UUIObject* RightTarget, class UUIObject* BottomTarget );

		/**
		 * Sets the designer-specified navigation target for the specified face.  When navigation links for the scene are rebuilt,
		 * the designer-specified navigation target will always override any auto-calculated targets.
		 *
		 * @param	Face				the face to set the navigation link for
		 * @param	NavTarget			the widget to set as the link for the specified face
		 * @param	bIsNullOverride		if NavTarget is NULL, specify TRUE to indicate that this face's nav target should not
		 *								be automatically calculated.
		 *
		 * @return	TRUE if the navigation link for the specified face changed.  FALSE if the new value wasn't applied or if the
		 *			the new value was the same as the current value.
		 */
		UBOOL SetForcedNavigationTarget( EUIWidgetFace Face, class UUIObject* NavTarget, UBOOL bIsNullOverride=FALSE );
		UBOOL SetForcedNavigationTarget( class UUIObject* LeftTarget, class UUIObject* TopTarget, class UUIObject* RightTarget, class UUIObject* BottomTarget );

		/**
		 * Gets the navigation target for the specified face.  If a designer-specified nav target is set for the specified face,
		 * that object is returned.
		 *
		 * @param	Face		the face to get the nav target for
		 * @param	LinkType	specifies which navigation link type to return.
		 *							NAVLINK_MAX: 		return the designer specified navigation target, if set; otherwise returns the auto-generated navigation target
		 *							NAVLINK_Automatic:	return the auto-generated navigation target, even if the designer specified nav target is set
		 *							NAVLINK_Manual:		return the designer specified nav target, even if it isn't set
		 *
		 * @return	a pointer to a widget that will be the navigation target for the specified direction, or NULL if there is
		 *			no nav target for that face.
		 */
		class UUIObject* GetNavigationTarget( EUIWidgetFace Face, ENavigationLinkType LinkType=NAVLINK_MAX ) const;

		/**
		 * Determines whether the designer has overriden all navigation targets.
		 *
		 * @return	FALSE if an override target has been specified for all faces.
		 */
		UBOOL NeedsLinkGeneration() const;
	}
};

/**
 * Defines the desired docking behavior for all faces of a single widget
 */
struct native UIDockingSet
{
	/**
	 * The widget that is associated with this docking set.  Set by InitializeDockingSet().
	 */
	var		const							UIObject			OwnerWidget;

	/**
	 * The widget that will be docked against.
	 * If this value is NULL, it means that docking isn't enabled for this face
	 * If this value points to OwnerWidget, it means that the face is docked to the owner scene.
	 */
	var()	editconst	private{private}	UIObject			TargetWidget[EUIWidgetFace.UIFACE_MAX];

	/**
	 * The amount of padding to use for docking each face.  Positive values are considered "inside" padding,
	 * while negative values are considered "outside" padding.
	 */
	var()	editconst	private{private}	UIScreenValue_DockPadding			DockPadding;

	/**
	 * Controls whether the width of this widget should remain constant when adjusting the position of the left or right
	 * face as a result of docking.  Only relevant when either the left or right faces are docked.
	 */
	var()				public{private}		bool				bLockWidthWhenDocked;

	/**
	 * Controls whether the height of this widget should remain constant when adjusting the position of the top or bottom
	 * face as a result of docking.  Only relevant when either the top or bottom faces are docked.
	 */
	var()				public{private}		bool				bLockHeightWhenDocked;

	/** The face on the TargetWidget that this docking set applies to. */
	var()	editconst	private{private}	EUIWidgetFace		TargetFace[EUIWidgetFace.UIFACE_MAX];

	/** tracks whether each face has been resolved (via UpdateDockingSet).  Reset whenever ResolveScenePositions is called */
	var		transient	private{private}	byte				bResolved[EUIWidgetFace.UIFACE_MAX];

	/**
	 * set to 1 when this node is in the process of being added to the scene's docking stack; used to easily
	 * track down circular relationships between docking sets
	 */
	var		transient						byte				bLinking[EUIWidgetFace.UIFACE_MAX];

	structcpptext
	{
		/**
		 * Evaluate the widget's Position into an absolute pixel value, and store that value in the corresponding
		 * member of the widget's RenderBounds array.
		 * This function assumes that UpdateDockingSet has already been called for the TargetFace of the TargetWidget.
		 * This function should only be called from ResolveScenePositions.
		 *
		 * @param	Face			the face that needs to be resolved
		 */
		void UpdateDockingSet( EUIWidgetFace Face );

		/**
		 * Used to determine whether the specified face is docked.
		 *
		 * @return	TRUE if SourceFace is docked, FALSE if it isn't.
		 */
		UBOOL IsDocked( EUIWidgetFace SourceFace, UBOOL bRequireValidTargetFace=TRUE, UBOOL bIgnoreSceneTargets=FALSE ) const
		{
			checkSlow(SourceFace<UIFACE_MAX);
			return	TargetWidget[SourceFace] != NULL
				&& (TargetWidget[SourceFace] != OwnerWidget || !bIgnoreSceneTargets)
				&& (!bRequireValidTargetFace || TargetFace[SourceFace] < UIFACE_MAX);
		}

		/**
		 * Accessor for checking the value of bResolved
		 */
		UBOOL IsResolved( BYTE FaceToCheck ) const
		{
			checkSlow(FaceToCheck<UIFACE_MAX);
			return bResolved[FaceToCheck] != 0;
		}

		/**
		 * Accessor for updating the value of bResolved
		 */
		void MarkResolved( BYTE FaceToMark, BYTE bIsResolved=1 )
		{
			checkSlow(FaceToMark<UIFACE_MAX);
			bResolved[FaceToMark] = bIsResolved;
		}

		/**
		 * Retrieves the target widget for the specified face in this docking set.
		 *
		 * @param	SourceFace		the face to retrieve the dock target for
		 *
		 * @return	a pointer to the widget that the specified face is docked to.  NULL if the face is not docked or is docked to the scene.
		 *			If return value is NULL, IsDocked() can be used to determine whether the face is docked to the scene or not.
		 */
		class UUIObject* GetDockTarget( EUIWidgetFace SourceFace ) const;

		/**
		 * Retrieves the target face for the specified source face in this docking set.
		 *
		 * @param	SourceFace		the face to retrieve the dock target face for
		 *
		 * @return	the face of the dock target that SourceFace is docked to, or UIFACE_MAX if SourceFace is not docked.
		 */
		EUIWidgetFace GetDockFace( EUIWidgetFace SourceFace ) const;

		/**
		 *	Returns the ammount of padding for the specified face.
		 */
		FLOAT GetDockPadding( EUIWidgetFace SourceFace, EUIDockPaddingEvalType OutputType=UIPADDINGEVAL_Pixels ) const;

		/**
		 * Returns the dock padding eval type for the specified face.
		 */
		EUIDockPaddingEvalType GetDockPaddingType( EUIWidgetFace SourceFace ) const;

		/**
		 * Changes the configured dock target and face for the specified face.
		 *
		 * @param	SourceFace	the face to set the value for
		 * @param	DockTarget	the widget that SourceFace should be docked to, or NULL to indicate that this face should no longer be docked.
		 * @param	DockFace	the face on the dock target that SourceFace should be docked to.
		 *
		 * @return	TRUE indicates that the dock target values for the specified face were successfully changed.
		 */
		UBOOL SetDockTarget( EUIWidgetFace SourceFace, class UUIScreenObject* DockTarget, EUIWidgetFace DockFace );

		/**
		 * Changes the dock padding value for the specified face.
		 *
		 * @param	DockFace			the face to change padding for
		 * @param	NewValue			the new value to use for padding
		 * @param	InputType			the format to use for interpreting NewValue.
		 * @param	bChangeScaleType	specify TRUE to permanently change the scale type for the specified face to InputType.
		 *
		 * @return	TRUE indicates that the dock padding values for the specified face were successfully changed.
		 */
		UBOOL SetDockPadding( EUIWidgetFace DockFace, float NewValue, EUIDockPaddingEvalType InputType=UIPADDINGEVAL_Pixels, UBOOL bChangeScaleType=FALSE );

		/**
		 * Initializes the value of this docking set's OwnerWidget and convert UIDockingSets over to the new behavior
		 * (where TargetFace == OwnerWidget if docked to the scene)
		 *
		 * @param	inOwnerWidget	the widget that contains this docking set.
		 */
		void InitializeDockingSet( UUIObject* inOwnerWidget );

		/**
		 * Returns whether this widget's width should remain constant when adjusting its position due to docking relationships.
		 */
		UBOOL IsWidthLocked() const
		{
			return bLockWidthWhenDocked;
		}

		/**
		 * Returns whether this widget's height should remain constant when adjusting its position due to docking relationships.
		 */
		UBOOL IsHeightLocked() const
		{
			return bLockHeightWhenDocked;
		}

		/**
		 * Changes whether this widget's width should remain constant when adjusting its position due to docking relationships
		 * according to the value specified.
		 */
		void LockWidth( UBOOL bShouldLockWidth=TRUE )
		{
			bLockWidthWhenDocked = bShouldLockWidth;
		}

		/**
		 * Changes whether this widget's width should remain constant when adjusting its position due to docking relationships
		 * according to the value specified.
		 */
		void LockHeight( UBOOL bShouldLockHeight=TRUE )
		{
			bLockHeightWhenDocked = bShouldLockHeight;
		}
	}

	structdefaultproperties
	{
		TargetFace(UIFACE_Left)=UIFACE_MAX
		TargetFace(UIFACE_Top)=UIFACE_MAX
		TargetFace(UIFACE_Right)=UIFACE_MAX
		TargetFace(UIFACE_Bottom)=UIFACE_MAX
	}
};

/**
 * A widget/face pair.  Used by the docking system to track the order in which widget face positions should be evaluated
 */
struct native UIDockingNode
{
	/** the widget that this docking node is associated with */
	var()			UIObject						Widget;

	/** the face on the Widget that should be updated when this docking node is processed */
	var()			EUIWidgetFace					Face;

	structcpptext
	{
		/**
		 * Comparison operator
		 */
		UBOOL operator==( const FUIDockingNode& Other ) const
		{
			return Widget == Other.Widget && Face == Other.Face;
		}

		/**
		 * Constructors
		 */
		FUIDockingNode( UUIObject* inWidget=NULL, EUIWidgetFace inFace=UIFACE_MAX )
		: Widget(inWidget), Face(inFace)
		{ }

		FUIDockingNode( const FUIDockingNode& Other )
		: Widget(Other.Widget), Face(Other.Face)
		{ }

		/** Required in order for FUIDockingNode to be used as the key in a map */
		friend inline DWORD GetTypeHash( const FUIDockingNode& Node )
		{
			return PointerHash(Node.Widget,Node.Face);
		}
	}
};


/**
 * Data structure for representation the rotation of a UI Widget.
 */
struct native UIRotation
{
	/** the UE representation of the rotation of the widget */
	var()	const			rotator						Rotation;

	/**
	 * Transform matrix to use for rendering the widget.
	 */
	var	const	transient	matrix						TransformMatrix;

	/** point used for the origin in rotation animations */
	var()	const			UIAnchorPosition			AnchorPosition;

	/** defines whether the AnchorPosition is used or one of the presets */
	var()					ERotationAnchor				AnchorType;

	structcpptext
	{
		/**
		 * Sets the location of the anchor of rotation for this widget.
		 *
		 * @param	AnchorPos		New location for the anchor of rotation.
		 * @param	InputType		indicates which format the AnchorPos value is in
		 */
		void SetAnchorLocation(const class UUIScreenObject* OwnerWidget, const FVector& AnchorPos, EPositionEvalType InputType=EVALPOS_PixelViewport);
	}

	structdefaultproperties
	{
		TransformMatrix=(XPlane=(X=1,Y=0,Z=0,W=0),YPlane=(X=0,Y=1,Z=0,W=0),ZPlane=(X=0,Y=0,Z=1,W=0),WPlane=(X=0,Y=0,Z=0,W=1))
		AnchorType=RA_Center

		// this should already be the default scaletype, but no harm in making sure
		AnchorPosition=(ScaleType[UIORIENT_Horizontal]=EVALPOS_PixelOwner,ScaleType[UIORIENT_Vertical]=EVALPOS_PixelOwner)
	}
};

/**
 * Contains information about a UI data store binding, including the markup text used to reference the data store and
 * the resolved value of the markup text.
 *
 * @NOTE: if you move this struct declaration to another class, make sure to update UUIObject::GetDataBindingProperties()
 */
struct native UIDataStoreBinding
{
	/**
	 * The UIDataStoreSubscriber that contains this UIDataStoreBinding
	 */
	var		const	transient		UIDataStoreSubscriber		Subscriber;

	/**
	 * Indicates which type of data fields can be used in this data store binding
	 */
	var()	const	editconst		EUIDataProviderFieldType	RequiredFieldType;

	/**
	 * A datastore markup string which resolves to a property/data type exposed by a UI data store.
	 *
	 * @note: cannot be editconst until we have full editor support for manipulating markup strings (e.g. inserting embedded
	 * markup, etc.)
	 */
	var()	const	/*editconst*/		string					MarkupString;

	/**
	 * Used to differentiate multiple data store properties in a single class.
	 */
	var		const	transient		int							BindingIndex;

	/** the name of the data store resolved from MarkupString */
	var		const	transient		name						DataStoreName;

	/** the name of the field resolved from MarkupString; must be a field supported by ResolvedDataStore */
	var		const	transient		name						DataStoreField;

	/** a pointer to the data store resolved from MarkupString */
	var		const	transient		UIDataStore					ResolvedDataStore;

	structcpptext
	{
		/**
		 * Registers the current subscriber with ResolvedDataStore's list of RefreshSubscriberNotifies
		 */
		void RegisterSubscriberCallback();

		/**
		 * Removes the current subscriber from ResolvedDataStore's list of RefreshSubscriberNotifies.
		 */
		void UnregisterSubscriberCallback();

		/**
		 * Determines whether the specified data field can be assigned to this data store binding.
		 *
		 * @param	DataField	the data field to verify.
		 *
		 * @return	TRUE if DataField's FieldType is compatible with the RequiredFieldType for this data binding.
		 */
		UBOOL IsValidDataField( const struct FUIDataProviderField& DataField ) const;

		/**
		 * Determines whether the specified field type is valid for this data store binding.
		 *
		 * @param	FieldType	the data field type to check
		 *
		 * @return	TRUE if FieldType is compatible with the RequiredFieldType for this data binding.
		 */
		UBOOL IsValidDataField( EUIDataProviderFieldType FieldType ) const;

		/**
		 * Resolves the value of MarkupString into a data store reference, and fills in the values for all members of this struct
		 *
		 * @param	InSubscriber	the subscriber that contains this data store binding
		 *
		 * @return	TRUE if the markup was successfully resolved.
		 */
		UBOOL ResolveMarkup( TScriptInterface<class IUIDataStoreSubscriber> InSubscriber );

		/**
		 * Retrieves the value for this data store binding from the ResolvedDataStore.
		 *
		 * @param	out_ResolvedValue	will contain the value of the data store binding.
		 *
		 * @return	TRUE if the value for this data store binding was successfully retrieved from the data store.
		 */
		UBOOL GetBindingValue( struct FUIProviderFieldValue& out_ResolvedValue ) const;

		/**
		 * Publishes the value for this data store binding to the ResolvedDataStore.
		 *
		 * @param	NewValue	contains the value that should be published to the data store
		 *
		 * @return	TRUE if the value was successfully published to the data store.
		 */
		UBOOL SetBindingValue( const struct FUIProviderScriptFieldValue& NewValue ) const;

		/**
		 * Unregisters any bound data stores and clears all references.
		 */
		UBOOL ClearDataBinding();

	    /** Constructors */
		FUIDataStoreBinding() {}
	    FUIDataStoreBinding(EEventParm)
		{
			appMemzero(this, sizeof(FUIDataStoreBinding));
		}

		/**
		 * Member access operator.  Provides transparent access to the ResolvedDataStore pointer contained by this UIDataStoreBinding
		 */
		FORCEINLINE class UUIDataStore* operator->()
		{
			return ResolvedDataStore;
		}

		/**
		 * Dereference operator.  Provides transparent access to the ResolvedDataStore pointer contained by this UIDataStoreBinding
		 *
		 * @return	ResolvedDataStore
		 */
		FORCEINLINE class UUIDataStore*& operator*()
		{
			return ResolvedDataStore;
		}

		/**
		 * Boolean operator.  Provides transparent access to the ResolvedDataStore pointer contained by this UIDataStoreBinding
		 *
		 * @return	TRUE if ResolvedDataStore is non-NULL.
		 */
		FORCEINLINE operator UBOOL() const
		{
			return ResolvedDataStore != NULL;
		}

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FUIDataStoreBinding& Other ) const
		{
			return	Subscriber			== Other.Subscriber
				&&	RequiredFieldType	== Other.RequiredFieldType
				&&	MarkupString		== Other.MarkupString
				&&	DataStoreName		== Other.DataStoreName
				&&	DataStoreField		== Other.DataStoreField
				&&	ResolvedDataStore	== Other.ResolvedDataStore;
		}
		FORCEINLINE UBOOL operator!=( const FUIDataStoreBinding& Other ) const
		{
			return !(FUIDataStoreBinding::operator==(Other));
		}

		/* Editor serialization operator */
		friend FArchive& operator<<( FArchive& Ar, FUIDataStoreBinding& Binding )
		{
			return Ar << (UObject*&)Binding.ResolvedDataStore << Binding.Subscriber;
		}
		friend FArchive& operator<<( FArchive& Ar, FUIDataStoreBinding* Binding )
		{
			if ( Binding != NULL )
			{
				Ar << (UObject*&)Binding->ResolvedDataStore << Binding->Subscriber;
			}
			return Ar;
		}
	}

	structdefaultproperties
	{
		BindingIndex=INDEX_NONE
		RequiredFieldType=DATATYPE_MAX
	}
};

/**
 * Pairs a unique name with a UIStyleResolver reference.
 *
 * not currently used.
 */
struct transient native UIStyleSubscriberReference
{
	/**
	 * A unique name for identifying this StyleResolver - usually the name of the property referencing this style resolver
	 * Used for differentiating styles from multiple UIStyleResolvers of the same class.
	 */
	var		name				SubscriberId;

	/** the reference to the UIStyleResolver object */
	var		UIStyleResolver		Subscriber;

	structcpptext
	{
		/** Constructors */
		FUIStyleSubscriberReference()
		: SubscriberId(NAME_None)
		{
		}
		FUIStyleSubscriberReference(EEventParm)
		: SubscriberId(NAME_None)
		{
		}

		FUIStyleSubscriberReference( FName InSubscriberId, const class TScriptInterface<class IUIStyleResolver>& InSubscriber );

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FUIStyleSubscriberReference& Other ) const
		{
			return SubscriberId == Other.SubscriberId && Subscriber == Other.Subscriber;
		}
		FORCEINLINE UBOOL operator!=( const FUIStyleSubscriberReference& Other ) const
		{
			return SubscriberId != Other.SubscriberId || Subscriber != Other.Subscriber;
		}
	}
};

/**
 * Container used for identifying UIStyleReference properties from multiple UIStyleResolvers of the same class
 */
struct transient native StyleReferenceId
{
	/** The tag to use for this UIStyleResolver's properties */
	var		name		StyleReferenceTag;

	/** the actual UIStyleReference property */
	var		Property		StyleProperty;

	structcpptext
	{
		/** Constructors */
		FStyleReferenceId()
		: StyleReferenceTag(NAME_None), StyleProperty(NULL)
		{}
		FStyleReferenceId( UProperty* InStyleProperty )
		: StyleReferenceTag(NAME_None), StyleProperty(InStyleProperty)
		{}
		FStyleReferenceId( const FName& InReferenceTag, class UProperty* InStyleProperty )
		: StyleReferenceTag(InReferenceTag), StyleProperty(InStyleProperty)
		{}

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FStyleReferenceId& Other ) const
		{
			return GetStyleReferenceTag() == Other.GetStyleReferenceTag() && StyleProperty == Other.StyleProperty;
		}
		FORCEINLINE UBOOL operator!=( const FStyleReferenceId& Other ) const
		{
			return GetStyleReferenceTag() != Other.GetStyleReferenceTag() || StyleProperty != Other.StyleProperty;
		}

		friend FORCEINLINE DWORD GetTypeHash( const FStyleReferenceId& RefId )
		{
			return PointerHash(RefId.StyleProperty);
		}

		/**
		 * Returns the display name for this style reference
		 */
		FString GetStyleReferenceName( UBOOL bAllowDisplayName=!GIsGame ) const;

		/**
		 * Faster version of GetStyleReferenceName which never allows meta data localized text to be used.
		 */
		FName GetStyleReferenceTag() const;
	}
};

/** Defines a group of attributes that can be applied to text, such as bold, italic, underline, shadow, etc. */
struct native UITextAttributes
{
	var()		bool					Bold<ToolTip=Not yet implemented>;
	var()		bool					Italic<ToolTip=Not yet implemented>;
	var()		bool					Underline<ToolTip=Not yet implemented>;
	var()		bool					Shadow<ToolTip=Not yet implemented>;
	var()		bool					Strikethrough<ToolTip=Not yet implemented>;

	structcpptext
	{
		/** Comparison operator */
		UBOOL operator==( const FUITextAttributes& Other ) const
		{
			return appMemcmp(this, &Other, sizeof(FUITextAttributes)) == 0;
		}

		UBOOL operator!=( const FUITextAttributes& Other ) const
		{
			return !((*this)==Other);
		}

		/**
		 * Resets the values for all attributes to false.
		 */
		void Reset();
	}
};

/** Describes the parameters for adjusting a material to match the dimensions of a target region. */
struct native UIImageAdjustmentData
{
	/** size of buffer zone for constraining the image adjustment */
	var()			UIScreenValue_Extent			ProtectedRegion[EUIOrientation.UIORIENT_MAX]<DisplayName=Gutter|ToolTip=Controls the size of the region that should be ignored by any scaling>;

	/** the type of adjustment to perform to the image for each orientation */
	var()			EMaterialAdjustmentType			AdjustmentType<DisplayName=Scale Type|ToolTip=Controls how the image should be fitted to the bounding region>;

	/** alignment within the region */
	var()			EUIAlignment					Alignment<DisplayName=Image Alignment|ToolTip=Controls how the image will be aligned within the bounding region>;

	structcpptext
	{
		/** Comparison */
		UBOOL operator ==( const FUIImageAdjustmentData& Other ) const;
		UBOOL operator !=( const FUIImageAdjustmentData& Other ) const;
	}

	structdefaultproperties
	{
		AdjustmentType=ADJUST_Normal
	}
};

struct native UIStringCaretParameters
{
	/** Controls whether a caret is displayed at all */
	var()			bool				bDisplayCaret;

	/**
	 * Determines which color pen (from GameUISceneClient's DefaultUITextures) is used to render the caret
	 */
	var()			EUIDefaultPenColor	CaretType;

	/** Specifies the width of the caret, in pixels */
	var()			float				CaretWidth;

	/** the tag of the style to use for displaying this caret */
	var()			name				CaretStyle;

	/**
	 * The current position of the caret in the string
	 */
	var	transient	int					CaretPosition;

	/**
	 * For carets that use parametized materials, the MaterialInterface that was created for this caret
	 */
	var	transient	MaterialInterface	CaretMaterial;

	structdefaultproperties
	{
		CaretType=UIPEN_White
		CaretWidth=1.0f
		CaretStyle=DefaultCaretStyle
	}
};

/**
 * General purpose data structure for grouping all parameters needed when rendering or sizing a string/image
 */
struct native transient RenderParameters
{
	/** a pixel value representing the horizontal screen location to begin rendering the string */
	var		float				DrawX;

	/** a pixel value representing the vertical screen location to begin rendering the string */
	var		float				DrawY;

	/** a view-space value representing how far into the screen the text should be rendered at. */
	var		float				DrawZ;

	/** a pixel value representing the width of the area available for rendering the string */
	var		float				DrawXL;

	/** a pixel value representing the height of the area available for rendering the string */
	var		float				DrawYL;

	/**
	 * A value between 0.0 and 1.0, which represents how much the width/height should be scaled,
	 * where 1.0 represents 100% scaling.
	 */
	var		Vector2D			Scaling;

	/** the font to use for rendering/sizing the string */
	var		Font				DrawFont;

	/** The alignment for the string we are drawing. */
	var     EUIAlignment		TextAlignment[EUIOrientation.UIORIENT_MAX];

	/**
	 * Only used when rendering string nodes that contain images.
	 * Represents the size to use for rendering the image
	 */
	var		Vector2D			ImageExtent;

	/** the coordinates to use to render images */
	var		TextureCoordinates	DrawCoords;

	/** Horizontal spacing adjustment between characters and vertical spacing adjustment between wrapped lines */
	var		Vector2D			SpacingAdjust;

	/** the current height of the viewport; needed to support multifont */
	var		float				ViewportHeight;

	/** Whether to use the override color (will typically get turned on for a short time then turned back off) */
	var		bool				bUseOverrideColor;

	/** The color to use when overriding the currently rendering color */
	var		LinearColor			OverideDrawColor;

	structcpptext
	{
		/** Constructors */
		FRenderParameters( FLOAT InViewportHeight=0.f )
		: DrawX(0.f), DrawY(0.f), DrawZ(1.f), DrawXL(0.f), DrawYL(0.f)
		, Scaling(1.f,1.f), DrawFont(NULL), ImageExtent(0.f,0.f)
		, DrawCoords(0,0,0,0), SpacingAdjust(0.0f,0.0f), ViewportHeight(InViewportHeight)
		, bUseOverrideColor(FALSE)
		{
			TextAlignment[UIORIENT_Horizontal] = UIALIGN_Default;
			TextAlignment[UIORIENT_Vertical] = UIALIGN_Default;
		}

		FRenderParameters( FLOAT inDrawX, FLOAT inDrawY, FLOAT inDrawXL, FLOAT inDrawYL, UFont* inFont=NULL, FLOAT InViewportHeight=0.f, FLOAT inDrawZ=1.0f )
		: DrawX(inDrawX), DrawY(inDrawY), DrawZ(inDrawZ), DrawXL(inDrawXL), DrawYL(inDrawYL)
		, Scaling(1.f,1.f), DrawFont(inFont), ImageExtent(0.f,0.f)
		, DrawCoords(0,0,0,0), SpacingAdjust( 0.0f, 0.0f ), ViewportHeight(InViewportHeight)
		, bUseOverrideColor(FALSE)
		{
			TextAlignment[UIORIENT_Horizontal] = UIALIGN_Default;
			TextAlignment[UIORIENT_Vertical] = UIALIGN_Default;
		}

		FRenderParameters( UFont* inFont, FLOAT ScaleX, FLOAT ScaleY, FLOAT InViewportHeight=0.f )
		: DrawX(0.f), DrawY(0.f), DrawZ(1.0f), DrawXL(0.f), DrawYL(0.f)
		, Scaling(ScaleX,ScaleY), DrawFont(inFont), ImageExtent(0.f,0.f)
		, DrawCoords(0,0,0,0), SpacingAdjust( 0.0f, 0.0f ), ViewportHeight(InViewportHeight)
		, bUseOverrideColor(FALSE)
		{
			TextAlignment[UIORIENT_Horizontal] = UIALIGN_Default;
			TextAlignment[UIORIENT_Vertical] = UIALIGN_Default;
		}
	}
};

/**
 * Container for text autoscaling values.
 */
struct native TextAutoScaleValue
{
	/**
	 * the minimum amount of scaling that can be applied to the text; this value must be set in order for
	 * auto-scaling to be used in conjunction with any type of string formatting (i.e. wrapping, clipping, etc.).  Negative
	 * values will be ignored and a value of 0 indicates that MinScale is not enabled.
	 */
	var()				float	MinScale<DisplayName=Min Scale Value>;

	/** Allows text to be scaled to fit within the bounding region */
	var()	ETextAutoScaleMode	AutoScaleMode<DisplayName=Auto Scaling|ToolTip=Scales the text so that it fits into the bounding region>;

	structdefaultproperties
	{
		AutoScaleMode=UIAUTOSCALE_None
		MinScale=0.6
	}

	structcpptext
	{
		/** Constructors */
		FTextAutoScaleValue() {}
		FTextAutoScaleValue(EEventParm)
		: MinScale(0.f), AutoScaleMode(UIAUTOSCALE_None)
		{}

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FTextAutoScaleValue& Other ) const
		{
			return	ARE_FLOATS_EQUAL(MinScale,Other.MinScale)
				&&	AutoScaleMode	== Other.AutoScaleMode;
		}
		FORCEINLINE UBOOL operator!=( const FTextAutoScaleValue& Other ) const
		{
			return	!ARE_FLOATS_EQUAL(MinScale,Other.MinScale)
				||	AutoScaleMode	!= Other.AutoScaleMode;
		}
	}
};

/**
 * This struct contains properties which override values in a style.
 */
struct native UIStyleOverride
{
	/**
	 * Color to use for rendering the string or image.  Values for each color range from 0.0 to 1.0, where
	 * 0.0 means "none of this color" and 1.0 means "full-color".  Use values higher than 1.0 to create a
	 * "bloom" effect behind the text.  Give DrawColor.A a value higher than 1.0 in order to bloom all colors
	 * uniformly. (requires UI post processing to be enabled - UISceneClient.bEnablePostProcess and the owning
	 * scene's bEnableScenePostProcessing properties must both be set to TRUE).
	 *
	 */
	var()				LinearColor			DrawColor<DisplayName=Draw Color|EditCondition=bOverrideDrawColor>;

	/**
	 * Provides a simple way for overriding the opacity of the text regardless of the DrawColor's Alpha value
	 * A value of 0.0 means "completely transparent"; a value of 1.0 means "completely opaque".  Use values greater
	 * than 1.0 to bloom the DrawColor uniformly. (requires UI post processing to be enabled -
	 * UISceneClient.bEnablePostProcess and the owning scene's bEnableScenePostProcessing properties must both be
	 * set to TRUE).
	 */
	var()				float				Opacity<DisplayName=Opacity|EditCondition=bOverrideOpacity>;

	/**
	 * The amount of padding to apply for each orientation, in pixels.  Padding will be scaled against the value of the
	 * DEFAULT_SIZE_Y const (currently 1024).
	 */
	var()				float				Padding[EUIOrientation.UIORIENT_MAX]<DisplayName=Padding|EditCondition=bOverridePadding>;

	/** indicates whether the draw color has been customized */
	var		public{private}	bool			bOverrideDrawColor;

	/** Allow us to override the final alpha */
	var		public{private}	bool			bOverrideOpacity;

	/** Indicates whether the padding has been customized */
	var		public{private}	bool			bOverridePadding;

	structdefaultproperties
	{
		DrawColor=(R=1.f,B=1.f,G=1.f,A=1.f)
		Opacity=1.f
	}

	structcpptext
	{
		/**
		 * Enables/disables customization of style data without changing the existing value.
		 *
		 * @return	TRUE if the value was changed.
		 */
		UBOOL EnableCustomDrawColor( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideDrawColor != bEnabled);
			bOverrideDrawColor=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomOpacity( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideOpacity != bEnabled);
			bOverrideOpacity=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomPadding( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverridePadding != bEnabled);
			bOverridePadding=bEnabled;
			return bResult;
		}

		UBOOL IsCustomDrawColorEnabled()	const	{ return bOverrideDrawColor; }
		UBOOL IsCustomOpacityEnabled()		const	{ return bOverrideOpacity; }
		UBOOL IsCustomPaddingEnabled()		const	{ return bOverridePadding; }

		/**
		 * Changes the draw color to the color specified and enables draw color override.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomDrawColor( const struct FLinearColor& NewDrawColor );

		/**
		 * Changes the opacity
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomOpacity( float NewOpacity );

		/**
		 * Changes the padding for the specified orientation.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomPadding( EUIOrientation Orientation, FLOAT NewPadding );

		/**
		 * Copies the value of DrawColor onto the specified value if draw color customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeDrawColor( struct FLinearColor& OriginalColor ) const;

		/**
		 * Applies the value of Opacity onto the specified value if draw color customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeOpacity( struct FLinearColor& OriginalColor ) const;

		/**
		 * Applies the value of StylePadding onto the specified value if padding customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizePadding( EUIOrientation Orientation, FLOAT& OriginalPadding ) const;
	}
};

/**
 * This struct is used to override values from a text style.
 */
struct native UITextStyleOverride extends UIStyleOverride
{
	/** The font to use for rendering text */
	var()				Font				DrawFont<DisplayName=Draw Font|EditCondition=bOverrideDrawFont>;

	/** Attributes to apply to the text, such as bold, italic, etc. */
	var()				UITextAttributes	TextAttributes<DisplayName=Attributes|EditCondition=bOverrideAttributes>;

	/** Text alignment within the bounding region */
	var()				EUIAlignment		TextAlignment[EUIOrientation.UIORIENT_MAX]<DisplayName=Text Alignment|EditCondition=bOverrideAlignment>;

	/**
	 * Determines what happens when the text doesn't fit into the bounding region.
	 */
	var() 				ETextClipMode		ClipMode<DisplayName=Clip Mode|ToolTip=Controls how the string is formatted when it doesn't fit into the bounding region|EditCondition=bOverrideClipMode>;

	/** Determines how the nodes of this string are ordered when the string is being clipped */
	var()				EUIAlignment		ClipAlignment<DisplayName=Clip Alignment|ToolTip=Determines which part of the string should be clipped when it doesn't fit into the bounding region only relevant is wrap mode is Clipped or wrapped)|EditCondition=bOverrideClipAlignment>;

	/** Allows text to be scaled to fit within the bounding region */
	var()				TextAutoScaleValue	AutoScaling<DisplayName=Auto Scaling|ToolTip=Scales the text so that it fits into the bounding region|EditCondition=bOverrideAutoScale>;

	/** Scale for rendering text */
	var()				float				DrawScale[EUIOrientation.UIORIENT_MAX]<DisplayName=Text Scale|EditCondition=bOverrideScale>;

	/** Sets the horizontal spacing adjustment between characters (in pixels), as well as the vertical spacing adjustment between lines of wrapped text (in pixels). */
	var()				float				SpacingAdjust[EUIOrientation.UIORIENT_MAX]<DisplayName=Spacing Adjust|EditCondition=bOverrideSpacingAdjust>;

	/** indicates whether the draw font has been customized */
	var		public{private}	bool			bOverrideDrawFont;

	/** indicates whether the coordinates have been customized */
	var		public{private}	bool			bOverrideAttributes;

	/** indicates whether the formatting has been customized */
	var		public{private}	bool			bOverrideAlignment;

	/** indicates whether the clipping mode has been customized */
	var		public{private}	bool			bOverrideClipMode;

	/** indicates whether the clip alignment has been customized */
	var		public{private}	bool			bOverrideClipAlignment;

	/** indicates whether the autoscale mode has been customized */
	var		public{private}	bool			bOverrideAutoScale;

	/** indicates whether the scale factor has been customized */
	var		public{private}	bool			bOverrideScale;

	/** indicates whether the spacing adjust has been customized */
	var		public{private}	bool			bOverrideSpacingAdjust;


	structdefaultproperties
	{
		DrawScale(UIORIENT_Horizontal)=1.f
		DrawScale(UIORIENT_Vertical)=1.f
	}

	structcpptext
	{
		UBOOL EnableCustomDrawFont( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideDrawFont != bEnabled);
			bOverrideDrawFont=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomAttributes( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideAttributes != bEnabled);
			bOverrideAttributes=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomClipMode( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideClipMode != bEnabled);
			bOverrideClipMode=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomClipAlignment( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideClipAlignment != bEnabled);
			bOverrideClipAlignment=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomAlignment( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideAlignment != bEnabled);
			bOverrideAlignment=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomAutoScaleMode( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideAutoScale != bEnabled);
			bOverrideAutoScale=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomScale( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideScale != bEnabled);
			bOverrideScale=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomSpacingAdjust( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideSpacingAdjust != bEnabled);
			bOverrideSpacingAdjust=bEnabled;
			return bResult;
		}
		UBOOL IsCustomDrawFontEnabled()		const	{ return bOverrideDrawFont; }
		UBOOL IsCustomAttributesEnabled()	const	{ return bOverrideAttributes; }
		UBOOL IsCustomClipModeEnabled()		const	{ return bOverrideClipMode; }
		UBOOL IsCustomAlignmentEnabled()	const	{ return bOverrideAlignment; }
		UBOOL IsCustomClipAlignmentEnabled()const	{ return bOverrideClipAlignment; }
		UBOOL IsCustomAutoScaleEnabled()	const	{ return bOverrideAutoScale; }
		UBOOL IsCustomScaleEnabled()		const	{ return bOverrideScale; }
		UBOOL IsCustomSpacingAdjustEnabled()	const	{ return bOverrideSpacingAdjust; }

		/**
		 * Changes the draw font to the font specified and enables font override.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomDrawFont( class UFont* NewFont );

		/**
		 * Changes the custom attributes to the value specified and enables text attribute customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomAttributes( const struct FUITextAttributes& NewAttributes );

		/**
		 * Changes the custom text clipping mode to the value specified and enables clipmode customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomClipMode( enum ETextClipMode CustomClipMode );

		/**
		 * Changes the custom text clip alignment to the value specified and enables clip alignment customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomClipAlignment( enum EUIAlignment NewClipAlignment );

		/**
		 * Changes the custom text alignment to the value specified and enables alignment customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomAlignment( enum EUIOrientation Orientation, enum EUIAlignment NewAlignment );

		/**
		 * Changes the custom text auto scale mode to the value specified and enables auto scale mode customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomAutoScaling( enum ETextAutoScaleMode NewAutoScaleMode, FLOAT NewMinScale );

		/**
		 * Changes the custom text auto scale mode to the value specified and enables auto scale mode customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomAutoScaling( const struct FTextAutoScaleValue& NewAutoScaleValue );

		/**
		 * Changes the custom text scale to the value specified and enables scale customization.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomScale( enum EUIOrientation Orientation, FLOAT NewScale );

		/**
		 * Changes the custom horizontal spacing adjustment between characters and vertical spacing between wrapped lines
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomSpacingAdjust( enum EUIOrientation Orientation, FLOAT NewSpacingAdjust );

		/**
		 * Copies the value of DrawFont onto the specified value if font customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeDrawFont( class UFont*& OriginalFont ) const;

		/**
		 * Copies the value of TextAttributes into the specified value if attribute customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeAttributes( struct FUITextAttributes& OriginalAttributes ) const;

		/**
		 * Copies the value of ClipMode into the specified value if clipmode customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeClipMode( enum ETextClipMode& OriginalClipMode ) const;

		/**
		 * Copies the value of TextAlignment for the specified orientation into the specified value if alignment customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeAlignment( enum EUIOrientation Orientation, enum EUIAlignment& OriginalAlignment ) const;

		/**
		 * Copies the value of ClipAlignment into the specified value if alignment customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeClipAlignment( enum EUIAlignment& OriginalAlignment ) const;

		/**
		 * Copies the value of AutoScaleMode into the specified value if attribute customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeAutoScaling( struct FTextAutoScaleValue& OriginalAutoScaling ) const;

		/**
		 * Copies the value of Scale into the specified value if attribute customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeScale( enum EUIOrientation Orientation, FLOAT& OriginalScale ) const;

		/**
		 * Copies the value of SpacingAdjust into the specified value if attribute customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeSpacingAdjust( enum EUIOrientation Orientation, FLOAT& OriginalSpacingAdjust ) const;
	}
};

/**
 * Contains data for overriding the corresponding data in an image style.
 */
struct native UIImageStyleOverride extends UIStyleOverride
{
	/** if DefaultImage points to a texture atlas, represents the coordinates to use for rendering this image */
	var()			TextureCoordinates		Coordinates<DisplayName=UV Coordinates|EditCondition=bOverrideCoordinates>;

	/** Information about how to modify the way the image is rendered. */
	var()			UIImageAdjustmentData	Formatting[EUIOrientation.UIORIENT_MAX]<EditCondition=bOverrideFormatting>;

	/** indicates whether the coordinates have been customized */
	var		public{private}	bool			bOverrideCoordinates;

	/** indicates whether the formatting has been customized */
	var		public{private}	bool			bOverrideFormatting;

	structcpptext
	{
		UBOOL EnableCustomCoordinates( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideCoordinates != bEnabled);
			bOverrideCoordinates=bEnabled;
			return bResult;
		}
		UBOOL EnableCustomFormatting( UBOOL bEnabled=TRUE )
		{
			UBOOL bResult = (bOverrideFormatting != bEnabled);
			bOverrideFormatting=bEnabled;
			return bResult;
		}
		UBOOL IsCustomCoordinatesEnabled()	const	{ return bOverrideCoordinates; }
		UBOOL IsCustomFormattingEnabled()	const	{ return bOverrideFormatting; }

		/**
		 * Changes the draw coordinates to the coordinates specified and enables coordinate override.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomCoordinates( const struct FTextureCoordinates& NewCoordinates );

		/**
		 * Changes the image adjustment data to the values specified and enables image adjustment data override.
		 *
		 * @return	TRUE if the value was changed; FALSE if the current value matched the new value or the new value
		 *			otherwise couldn't be applied.
		 */
		UBOOL SetCustomFormatting( enum EUIOrientation Orientation, const struct FUIImageAdjustmentData& NewAdjustmentData );

		/**
		 * Copies the value of Coordinates onto the specified value if coordinates customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeCoordinates( struct FTextureCoordinates& OriginalCoordinates ) const;

		/**
		 * Copies the value of Formatting for the specified orientation onto the specified value if formatting customization is enabled.
		 *
		 * @return	TRUE if the input value was modified.
		 */
		UBOOL CustomizeFormatting( enum EUIOrientation Orientation, struct FUIImageAdjustmentData& OriginalFormatting ) const;
	}

	structdefaultproperties
	{
		Formatting[UIORIENT_Horizontal]=(ProtectedRegion[0]=(Orientation=UIORIENT_Horizontal),ProtectedRegion[1]=(Orientation=UIORIENT_Horizontal))
		Formatting[UIORIENT_Vertical]=(ProtectedRegion[0]=(Orientation=UIORIENT_Vertical),ProtectedRegion[1]=(Orientation=UIORIENT_Vertical))
	}
};

/**
 * Container for all data contained by UI styles.  Used for applying inline modifications to UIString nodes,
 * such as changing the font, draw color, or attributes
 *
 * @todo - support for embedded markup, such as <font>blah blah<font>blah blah</font></font>
 */
struct native transient UICombinedStyleData
{
	/** color to use for rendering text */
	var	LinearColor					TextColor;

	/** color to use for rendering images */
	var LinearColor					ImageColor;

	/** padding to use for rendering text */
	var	float						TextPadding[EUIOrientation.UIORIENT_MAX];

	/** padding to use for rendering images */
	var float						ImagePadding[EUIOrientation.UIORIENT_MAX];

	/** the font to use when rendering text */
	var	Font						DrawFont;

	/** the material to use when rendering images if the image material cannot be loaded or isn't set */
	var	Surface						FallbackImage;

	/** the coordinates to use if FallbackImage is a texture atlas */
	var	TextureCoordinates			AtlasCoords;

	/** attributes to apply to this style's font */
	var	UITextAttributes			TextAttributes;

	/** text alignment within the bounding region */
	var	EUIAlignment				TextAlignment[EUIOrientation.UIORIENT_MAX];

	/** determines how strings that overrun the bounding region are handled */
	var	ETextClipMode				TextClipMode;

	/** Determines how the nodes of this string are ordered when the string is being clipped */
	var	EUIAlignment				TextClipAlignment;

	/** Information about how to modify the way the image is rendered. */
	var	UIImageAdjustmentData		AdjustmentType[EUIOrientation.UIORIENT_MAX];

	/** Allows text to be scaled to fit within the bounding region */
	var	TextAutoScaleValue			TextAutoScaling;

	/** text scale to use when rendering text */
	var Vector2D					TextScale;

	/** Horizontal spacing adjustment between characters and vertical spacing between wrapped lines of text */
	var Vector2D					TextSpacingAdjust;

	/** indicates whether this style data container has been initialized */
	var	const	private{private}	bool	bInitialized;

	structdefaultproperties
	{
		TextScale=(X=1.f,Y=1.f)
		TextClipMode=CLIP_MAX
	}

	structcpptext
	{
		/** Serializer for GC */
	    friend FArchive& operator<<( FArchive& Ar, struct FUICombinedStyleData& Container)
	    {
	        Ar << (UObject*&)Container.DrawFont << (UObject*&)Container.FallbackImage;
	        return Ar;
	    }

		/** Default Constructor */
		FUICombinedStyleData();

		/** Copy constructor */
		FUICombinedStyleData( const struct FUICombinedStyleData& Other );

		/**
		 * Standard constructor
		 *
		 * @param	SourceStyle		the style to use for initializing this StyleDataContainer.
		 */
		FUICombinedStyleData( class UUIStyle_Data* SourceStyle );

		/** Comparison operators */
		UBOOL operator==( const struct FUICombinedStyleData& Other ) const;
		UBOOL operator!=(const struct FUICombinedStyleData& Other ) const;

		/**
		 * Initializes the values of this UICombinedStyleData based on the values of the UIStyle_Data specified.
		 *
		 * @param	SourceStyle			the style to copy values from
		 * @param	bClearUnusedData	controls whether style data that isn't found in SourceStyle should be zero'd; for example
		 *								if SourceStyle is a text style, the image style data in this struct will be cleared if
		 *								bClearUnusedData is TRUE, or left alone if FALSE
		 */
		void InitializeStyleDataContainer( class UUIStyle_Data* SourceStyle, UBOOL bClearUnusedData=TRUE );

		/**
		 * Determines if this style data container has been initialized.
		 *
		 * @return	TRUE if either DrawFont or FallbackImage is set.
		 */
		UBOOL IsInitialized() const { return bInitialized; }
	}
};

/**
 * This struct contains data about the current modifications that are being applied to a string as it is being parsed, such as any inline styles, fonts, or attributes.
 */
struct native transient UIStringNodeModifier
{
	/**
	 * The current style data to apply to each new string node that is created
	 *
	 * @note: when data stores need to access additional fields of this member, add accessors to this struct rather than removing the private access specifier
	 */
	var	const	transient	public{private}		UICombinedStyleData		CustomStyleData;

	/**
	 * Optional style data that this UIStringNodeModifier was initialized from.  If BaseStyleData is not valid, there must be at least one
	 * UIStyle in the ModifierStack.
	 */
	var	const	transient	public{private}		UICombinedStyleData		BaseStyleData;

	/**
	 * Contains data about a custom inline style, along with the inline fonts that have been activated while this style was
	 * the current style.  Handles proper interaction between nested font and style inline markup.
	 */
	struct native transient ModifierData
	{
		/**
		 * the style for this data block.  Refers to either the UIString's DefaultStringStyle, or a style resolved from
		 * an inline style markup reference (i.e. Styles:SomeStyle)
		 */
		var	const	transient	UIStyle_Data	Style;

		/**
		 * The fonts that have been resolved from inline font markup while this style was the current style.
		 */
		var	const	transient	array<Font>		InlineFontStack;
	};

	var	const	transient	private{private}	array<ModifierData>		ModifierStack;

	/**
	 * The current menu state of the widget that owns the source UIString.
	 */
	var	const	transient	private{private}	UIState					CurrentMenuState;

	//@todo - Attribute stack, etc.

	structcpptext
	{
		/**
		 * Constructor
		 *
		 * @param	SourceStyle		the style to use for initializing the CustomStyleData member;  normally the UIString's DefaultStringStyle
		 * @param	MenuState		the current menu state of the widget that owns the UIString.
		 */
		FUIStringNodeModifier( class UUIStyle_Data* SourceStyle, class UUIState* MenuState );
		FUIStringNodeModifier( const struct FUICombinedStyleData& SourceStyleData, class UUIState* MenuState );

		/** Copy constructor */
		FUIStringNodeModifier( const struct FUIStringNodeModifier& Other );

		/**
		 * Adds the specified font to the InlineFontStack of the current ModifierData, then updates the DrawFont of CustomStyleData to point to the new font
		 *
		 * @param	NewFont	the font to use when creating new string nodes
		 *
		 * @return	TRUE if the specified font was successfully added to the list.
		 */
		UBOOL AddFont( class UFont* NewFont );

		/**
		 * Removes a font from the InlineFontStack of the current ModifierData.  If the font that was removed was the style data container's
		 * current DrawFont, updates CustomStyleData's font as well.
		 *
		 * @param	FontToRemove	if specified, the font to remove.  If NULL, removes the font at the top of the stack.
		 *
		 * @return	TRUE if the font was successfully removed from the InlineFontStack.  FALSE if the font wasn't part of the InlineFontStack
		 */
		UBOOL RemoveFont( class UFont* FontToRemove=NULL );

		/**
		 * Adds a new element to the ModifierStack using the specified style, then reinitializes the CustomStyleData with the values from this style.
		 *
		 * @param	NewStyle	the style to add to the stack
		 *
		 * @return	TRUE if the specified style was successfully added to the list.
		 */
		UBOOL AddStyle( class UUIStyle_Data* NewStyle );

		/**
		 * Removes the element containing StyleToRemove from ModifierStack.  If the style that was removed was style at the top of the StyleStack,
		 * reinitializes CustomStyleData with the style data from the previous style in the stack.
		 *
		 * @param	StyleToRemove	if specified, the style to remove.  If NULL, removes the style at the top of the stack.
		 *
		 * @return	TRUE if the style was successfully removed from the ModifierStack.  FALSE if the style wasn't part of the ModifierStack or it
		 *			was the last node in the ModifierStack (which cannot be removed).
		 */
		UBOOL RemoveStyle( class UUIStyle_Data* StyleToRemove=NULL );

		/**
		 * Returns the location of the ModifierData that contains the specified style.
		 *
		 * @param	SearchStyle	the style to search for
		 *
		 * @return	an index into the ModifierStack array for the ModifierData that contains the specified style, or INDEX_NONE
		 *			if there are no elements referencing that style.
		 */
		INT FindModifierIndex( class UUIStyle_Data* SearchStyle );

		/**
		 * Returns the style data contained by this string customizer
		 */
		const struct FUICombinedStyleData& GetCustomStyleData() const;

		/**
		 * Returns the configured menu state.
		 */
		class UUIState* GetMenuState() { return CurrentMenuState; }

		/**
		 * Sets the Custom Text Color to use
		 *
		 * @param	CustomTextColor		The linear color to use
		 */
		void SetCustomTextColor(FLinearColor CustomTextColor);

		/**
		 * Resets the current text color to the active style's draw color.
		 */
		void ClearCustomTextColor();

		/**
		 * returns the current text color
		 */
		FLinearColor GetCustomTextColor();


	}
};

/**
 * Represents a single text block (or inline image), where all of the text is the same style/font,etc.
 * Able to calculate its extend at any time
 */
struct native transient UIStringNode
{
	/**
	 * The vtable for this struct.
	 */
	var		native	const	transient	noexport	pointer		VfTable;

	/**
	 * The data store that was resolved from this string nodes markup.  NULL if this string node doesn't
	 * contain data store markup text.
	 */
	var				const	transient	UIDataStore				NodeDataStore;

	/**
	 * For slave nodes (such as nodes that were created as a result of wrapping or nested markup resolution), the original
	 * node which contains the markup source text for this entire group of nodes.
	 */
	var		native	const	transient	pointer					ParentNode{FUIStringNode};

	/**
	 * The original text that is represented by this string node.  For example, for a UITextNode that represents
	 * some bold text, the original text would look like:
	 * <b>some text</b>
	 * For an image node, the original text might look like:
	 * <img={SOME_ID}>
	 *
	 * @fixme - hmmm, should this be changed to be a UIDataStoreBinding instead?
	 */
	var()	string		SourceText;

	/**
	 * Represents the width and height of this string node in pixels.  Can be calculated dynamically based on
	 * the content of the node, or set by the parent UIString to some preconfigured value.
	 */
	var()	vector2D	Extent;

	/**
	 * A value between 0.0 and 1.0, which represents the amount of scaling the apply to the node's Extent,
	 * where 1.0 represents 100% scaling.  Typically only specified per-node for image nodes.
	 */
	var()	vector2D	Scaling;

	/**
	 * if TRUE, this node should be the last node on the current line
	 */
	var		bool		bForceWrap;

	structcpptext
	{
		/** Constructor */
		FUIStringNode( const TCHAR* inSourceText )
		: NodeDataStore(NULL), ParentNode(NULL)
		, SourceText(inSourceText), Extent(0.f,0.f)
		, Scaling(1.f,1.f), bForceWrap(FALSE)
		{}

		/** Destructor */
		virtual ~FUIStringNode() {}

		/**
		 * Initializes this node's style
		 */
		virtual void InitializeStyle( class UUIStyle_Data* CurrentStyle )=0;

		/**
		 * Initializes this node's style.
		 */
		virtual void InitializeStyle( const struct FUICombinedStyleData& StyleData )=0;

		/**
		 * Calculates the precise extent of this text node, and assigns the result to UIStringNode::Extent
		 *
		 * @param	DefaultLineHeight		the default height of a single line in the string...used by UIStringNode_Image to
		 *									scale the image correctly.
		 * @param	ViewportHeight			the height of the viewport that this string node will render to; used by the string
		 *									rendering functions to support multifonts
		 */
		virtual void CalculateExtent( FLOAT DefaultLineHeight, FLOAT ViewportHeight )=0;

		/**
		 * Returns the value of this UIStringNode
		 *
		 * @param	bProcessedValue		indicates whether the raw or processed version of the value is desired
		 *								The raw value will contain any markup; the processed string will be text only.
		 *								Any image tokens are converted to their text counterpart.
		 *
		 * @return	the value of this UIStringNode, or NULL if this node has no value
		 */
		virtual const TCHAR* GetValue( UBOOL bProcessedValue ) const;

		/**
		 * Renders this UIStringNode using the parameters specified.
		 *
		 * @param	Canvas		the canvas to use for rendering this node
		 * @param	Parameters	the bounds for the region that this node should render to
		 *						the Scaling value of Parameters will be applied against the Scaling
		 *						value for this node.  The DrawXL/YL of the Parameters are used to
		 *						determine whether this node has enough room to render itself completely.
		 */
		virtual void Render_Node( FCanvas* Canvas, const struct FRenderParameters& Parameters) {};

		// UObject interface.
		/**
		 * Callback used to allow object register its direct object references that are not already covered by
		 * the token stream.
		 *
		 * @param Owner			the UIString that owns this node.  used to provide access to UObject::AddReferencedObject
		 * @param ObjectArray	array to add referenced objects to via AddReferencedObject
		 */
		virtual void AddReferencedObjects( class UUIString* Owner, TArray<UObject*>& Objects ) {};

		/** Serializers */
		friend FArchive& operator<<( FArchive& Ar, FUIStringNode& StringNode);
		virtual void Serialize( FArchive& Ar ) {};

		/**
		 * Poor man's RTTI
		 */
		virtual UBOOL IsTextNode() const=0;
		virtual UBOOL IsImageNode() const=0;
		virtual UBOOL IsNestParent() const { return FALSE; }
		virtual UBOOL IsFormattingParent() const { return FALSE; }

		/**
		 * Determines whether this node was created to contain additional text as a result of wrapping, clipping, or nested markup resolution.
		 *
		 * @param	SearchParent	if specified, will iterate up the ParentNode chain to determine whether this string node is a direct or indirect
		 *							slave of the specified parent node.
		 */
		UBOOL IsSlaveNode( struct FUIStringNode* SearchParent=NULL ) const;
	}

	structdefaultproperties
	{
		Scaling=(X=1.f,Y=1.f)
	}
};

/**
 * Specialized text node for rendering text in a UIString.
 */
struct native transient UIStringNode_Text extends UIStringNode
{
	/**
	 * This is the string that will actually be drawn.  It doesn't contain any markup (that's stored in OriginalText),
	 * and is the string that is used to determine the extent of this string.
	 */
	var()	string								RenderedText;

	/**
	 * The style property values to use for rendering this node.  Initialized based on the default text style of the parent
	 * UIString, then customized by any attribute markup in the source text for this node.
	 */
	var	public{protected}	UICombinedStyleData	NodeStyleParameters;

	structcpptext
	{
		FUIStringNode_Text( const TCHAR* inSourceText )
		: FUIStringNode(inSourceText)
		{}

		/** Conversion constructor - copies the data from a formatting parent to a text node */
		FUIStringNode_Text( const struct FUIStringNode_FormattedNodeParent& SourceNode );

		/**
		 * Initializes this node's style data
		 */
		virtual void InitializeStyle( class UUIStyle_Data* CurrentStyle );

		/**
		 * Initializes this node's style.
		 */
		virtual void InitializeStyle( const struct FUICombinedStyleData& StyleData );

		/**
		 * Return the style data for this node.
		 */
		struct FUICombinedStyleData& GetNodeStyleData();

		/**
		 * Calculates the precise extent of this text node, and assigns the result to UIStringNode::Extent
		 *
		 * @param	DefaultLineHeight		the default height of a single line in the string...used by UIStringNode_Image to
		 *									scale the image correctly.
		 * @param	ViewportHeight			the height of the viewport that this string node will render to; used by the string
		 *									rendering functions to support multifonts
		 */
		virtual void CalculateExtent( FLOAT DefaultLineHeight, FLOAT ViewportHeight );

		/**
		 * Assigns the RenderedText to the value specified, and recalculates the extent for this node.
		 */
		void SetRenderText( const TCHAR* NewRenderText );

		/**
		 * Returns the value of this UIStringNode
		 *
		 * @param	bProcessedValue		indicates whether the raw or processed version of the value is desired
		 *								The raw value will contain any markup; the processed string will be text only.
		 *								Any image tokens are converted to their text counterpart.
		 *
		 * @return	the value of this UIStringNode, or NULL if this node has no value
		 */
		virtual const TCHAR* GetValue( UBOOL bProcessedValue ) const;

		/**
		 * Renders this UIStringNode using the parameters specified.
		 *
		 * @param	Canvas		the canvas to use for rendering this node
		 * @param	Parameters	the bounds for the region that this node should render to
		 *						the Scaling value of Parameters will be applied against the Scaling
		 *						value for this node.  The DrawXL/YL of the Parameters are used to
		 *						determine whether this node has enough room to render itself completely.
		 */
		virtual void Render_Node( FCanvas* Canvas, const struct FRenderParameters& Parameters);

		/**
		 * Determines whether this node contains only modification markup.
		 */
		UBOOL IsModifierNode() const;

		// UObject interface
		/**
		 * Callback used to allow object register its direct object references that are not already covered by
		 * the token stream.
		 *
		 * @param Owner			the UIString that owns this node.  used to provide access to UObject::AddReferencedObject
		 * @param ObjectArray	array to add referenced objects to via AddReferencedObject
		 */
		virtual void AddReferencedObjects( class UUIString* Owner, TArray<UObject*>& Objects );

		/**
		 * Serializer
		 */
		virtual void Serialize( FArchive& Ar )
		{
			Ar << RenderedText << NodeStyleParameters;
		}

		/**
		 * Poor man's RTTI
		 */
		virtual UBOOL IsTextNode() const { return TRUE; }
		virtual UBOOL IsImageNode() const { return FALSE; }
	}
};

/**
 * Specialized text node for rendering images in a UIString.
 */
struct native transient UIStringNode_Image extends UIStringNode
{
	/**
	 * The extent to use for this image node.  If this value is zero, the image node uses the size of the image
	 * to calculate its extent
	 */
	var()	Vector2D				ForcedExtent;

	/** Texture coordinates to use when rendering the image node's texture. If the TextureCoordinates struct is all zero, the entire texture will be drawn. */
	var()	TextureCoordinates		TexCoords;

	/**
	 * A pointer to the image being displayed by this text node.  The RenderedImage's ImageStyle will be
	 * initialized from the parent UIString's default image style, then customized by any attribute markup
	 * found in the source text for this node.
	 */
	var()	UITexture				RenderedImage;

	structcpptext
	{
		FUIStringNode_Image( const TCHAR* inSourceText )
		: FUIStringNode(inSourceText), ForcedExtent(0.f,0.f), TexCoords(EC_EventParm), RenderedImage(NULL)
		{}

		/**
		 * Initializes this node's style
		 */
		virtual void InitializeStyle( class UUIStyle_Data* CurrentStyle );

		/**
		 * Initializes this node's style.
		 */
		virtual void InitializeStyle( const struct FUICombinedStyleData& StyleData );

		/**
		 * Calculates the precise extent of this text node, and assigns the result to UIStringNode::Extent
		 *
		 * @param	DefaultLineHeight		the default height of a single line in the string...used by UIStringNode_Image to
		 *									scale the image correctly.
		 * @param	ViewportHeight			the height of the viewport that this string node will render to; used by the string
		 *									rendering functions to support multifonts
		 */
		virtual void CalculateExtent( FLOAT DefaultLineHeight, FLOAT ViewportHeight );

		/**
		 * Renders this UIStringNode using the parameters specified.
		 *
		 * @param	Canvas		the canvas to use for rendering this node
		 * @param	Parameters	the bounds for the region that this node should render to
		 *						the Scaling value of Parameters will be applied against the Scaling
		 *						value for this node.  The DrawXL/YL of the Parameters are used to
		 *						determine whether this node has enough room to render itself completely.
		 */
		virtual void Render_Node( FCanvas* Canvas, const struct FRenderParameters& Parameters);

		// UObject interface
		/**
		 * Callback used to allow object register its direct object references that are not already covered by
		 * the token stream.
		 *
		 * @param Owner			the UIString that owns this node.  used to provide access to UObject::AddReferencedObject
		 * @param ObjectArray	array to add referenced objects to via AddReferencedObject
		 */
		virtual void AddReferencedObjects( class UUIString* Owner, TArray<UObject*>& Objects );

		/**
		 * Serializer
		 */
		virtual void Serialize( FArchive& Ar )
		{
			Ar << (UObject*&)RenderedImage;
		}

		/**
		 * Poor man's RTTI
		 */
		virtual UBOOL IsTextNode() const { return FALSE; }
		virtual UBOOL IsImageNode() const { return TRUE; }
	}
};

/**
 * This node type is created when a string node's resolved value contains embedded markup text.  This node stores the original markup
 * text and the data store that was resolved from the original markup.
 */
struct native transient UIStringNode_NestedMarkupParent extends UIStringNode
{
	structcpptext
	{
		/* === UIStringNode_NestedMarkupParent interface === */
		FUIStringNode_NestedMarkupParent( const TCHAR* inSourceText )
		: FUIStringNode(inSourceText)
		{}


		/** === UIStringNode interface === */

		/**
		 * Initializes this node's style
		 */
		virtual void InitializeStyle( class UUIStyle_Data* CurrentStyle ) {};

		/**
		 * Initializes this node's style.
		 */
		virtual void InitializeStyle( const struct FUICombinedStyleData& StyleData ) {};

		/**
		 * Calculates the precise extent of this text node, and assigns the result to UIStringNode::Extent
		 *
		 * @param	DefaultLineHeight		the default height of a single line in the string...used by UIStringNode_Image to
		 *									scale the image correctly.
		 * @param	ViewportHeight			the height of the viewport that this string node will render to; used by the string
		 *									rendering functions to support multifonts
		 */
		virtual void CalculateExtent( FLOAT DefaultLineHeight, FLOAT ViewportHeight );

		virtual UBOOL IsTextNode() const { return FALSE; }
		virtual UBOOL IsImageNode() const { return FALSE; }
		virtual UBOOL IsNestParent() const { return TRUE; }
	}
};

/**
 * This node is created when when a string node's resolved value is wrapped into multiple lines (or otherwise formatted).
 * This node stores the source and render text from the pre-formatted node, but is never rendered.
 */
struct native transient UIStringNode_FormattedNodeParent extends UIStringNode_Text
{
	structcpptext
	{
		/** constructor */
		FUIStringNode_FormattedNodeParent( struct FUIStringNode_Text& SourceNode );

		/**
		 * UIString_WrappedNodeParent is never rendered, so the extent for this node type is always 0.
		 */
		virtual void CalculateExtent( FLOAT Unused, FLOAT Unused2 ) { Extent.X = Extent.Y = 0.f; }

		/**
		 * UIString_WrappedNodeParent is never rendered.
		 */
		virtual void Render_Node( FCanvas* Canvas, const struct FRenderParameters& Parameters) {}

		virtual UBOOL IsFormattingParent() const { return TRUE; }
	}
};

/**
 * Used by UUIString::WrapString to track information about each line that is generated as the result of wrapping.
 */
struct native transient WrappedStringElement
{
	/** the string associated with this line */
	var	string		Value;

	/** the size (in pixels) that it will take to render this string */
	var Vector2D	LineExtent;

	structcpptext
	{
		/** Constructor */
		FWrappedStringElement( const TCHAR* InValue, FLOAT Width, FLOAT Height )
		: Value(InValue), LineExtent(Width,Height)
		{}
	}
};

/**
 * Contains information about a mouse cursor resource that can be used ingame.
 */
struct native export UIMouseCursor
{
	/** the tag of the style to use for displaying this cursor */
	var()	name			CursorStyle;

	/** The actual cursor resource */
	var()	UITexture		Cursor;
};

/**
 * This struct contains all data used by the various UI input processing methods.
 */
struct native transient InputEventParameters
{
	/**
	 * Index [into the Engine.GamePlayers array] for the player that generated this input event.  If PlayerIndex is not
	 * a valid index for the GamePlayers array, it indicates that this input event was generated by a gamepad that is not
	 * currently associated with an active player
	 */
	var	const transient	int				PlayerIndex;

	/**
	 * The ControllerId that generated this event.  Not guaranteed to be a ControllerId associated with a valid player.
	 */
	var	const transient	int				ControllerId;

	/**
	 * Name of the input key that was generated, such as KEY_Left, KEY_Enter, etc.
	 */
	var	const transient	name			InputKeyName;

	/**
	 * The type of input event generated (i.e. IE_Released, IE_Pressed, IE_Axis, etc.)
	 */
	var	const transient	EInputEvent		EventType;

	/**
	 * For input key events generated by analog buttons, represents the amount the button was depressed.
	 * For input axis events (i.e. joystick, mouse), represents the distance the axis has traveled since the last update.
	 */
	var	const transient	float			InputDelta;

	/**
	 * For input axis events, represents the amount of time that has passed since the last update.
	 */
	var	const transient	float			DeltaTime;

	/**
	 * For PC input events, tracks whether the corresponding modifier keys are pressed.
	 */
	var	const transient bool			bAltPressed, bCtrlPressed, bShiftPressed;

	structcpptext
	{
		/** Default constructor */
		FInputEventParameters();

		/** Input Key Event constructor */
		FInputEventParameters( INT InPlayerIndex, INT InControllerId, FName KeyName, EInputEvent Event, UBOOL bAlt, UBOOL bCtrl, UBOOL bShift, FLOAT AmountDepressed=1.f );

		/** Input Axis Event constructor */
		FInputEventParameters( INT InPlayerIndex, INT InControllerId, FName KeyName, FLOAT AxisAmount, FLOAT InDeltaTime, UBOOL bAlt, UBOOL bCtrl, UBOOL bShift );
	}
};

/**
 * Contains additional data for an input event which a widget has registered for (via UUIComp_Event::RegisterInputEvents).is
 * in the correct state capable of processing is registered to handle.the data for a Stores the UIInputAlias name translated from a combination of input key, input event type, and modifier keys.
 */
struct native transient SubscribedInputEventParameters extends InputEventParameters
{
	/**
	 * Name of the UI input alias determined from the current input key, event type, and active modifiers.
	 */
	var	const transient	name			InputAliasName;

	structcpptext
	{
		/** Default constructor */
		FSubscribedInputEventParameters();

		/** Input Key Event constructor */
		FSubscribedInputEventParameters( INT InPlayerIndex, INT InControllerId, FName KeyName, EInputEvent Event, FName InInputAliasName, UBOOL bAlt, UBOOL bCtrl, UBOOL bShift, FLOAT AmountDepressed=1.f );

		/** Input Axis Event constructor */
		FSubscribedInputEventParameters( INT InPlayerIndex, INT InControllerId, FName KeyName, FName InInputAliasName, FLOAT AxisAmount, FLOAT InDeltaTime, UBOOL bAlt, UBOOL bCtrl, UBOOL bShift );

		/** Copy constructor */
		FSubscribedInputEventParameters( const FSubscribedInputEventParameters& Other );
		FSubscribedInputEventParameters( const FInputEventParameters& Other, FName InInputAliasName );
	}
};

/**
 * Contains information for simulating a button press input event in response to axis input.
 */
struct native UIAxisEmulationDefinition
{
	/**
	 * The axis input key name that this definition represents.
	 */
	var	name	AxisInputKey;

	/**
	 * The axis input key name that represents the other axis of the joystick associated with this axis input.
	 * e.g. if AxisInputKey is MouseX, AdjacentAxisInputKey would be MouseY.
	 */
	var	name	AdjacentAxisInputKey;

	/**
	 * Indicates whether button press/release events should be generated for this axis key
	 */
	var	bool	bEmulateButtonPress;

	/**
	 * The button input key that this axis input should emulate.  The first element corresponds to the input key
	 * that should be emulated when the axis value is positive; the second element corresponds to the input key
	 * that should be emulated when the axis value is negative.
	 */
	var	name	InputKeyToEmulate[2];
};

struct native export RawInputKeyEventData
{
	/** the name of the key (i.e. 'Left' [KEY_Left], 'LeftMouseButton' [KEY_LeftMouseButton], etc.) */
	var		name	InputKeyName;

	/**
	 * a bitmask of values indicating which modifier keys are associated with this input key event, or which modifier
	 * keys are excluded.  Bit values are:
	 *	0: Alt active (or required)
	 *	1: Ctrl active (or required)
	 *	2: Shift active (or required)
	 *	3: Alt excluded
	 *	4: Ctrl excluded
	 *	5: Shift excluded
	 *
	 * (key states)
	 *	6: Pressed
	 *	7: Released
	 */
	var		byte	ModifierKeyFlags;

	structdefaultproperties
	{
		ModifierKeyFlags=56		//	1<<3 + 1<<4 + 1<<5 (alt, ctrl, shift excluded)
	}

	structcpptext
	{
		/** Constructors */
		FRawInputKeyEventData() {}
		FRawInputKeyEventData(EEventParm)
		{
			appMemzero(this, sizeof(FRawInputKeyEventData));
		}

		explicit FRawInputKeyEventData( FName InKeyName, BYTE InModifierFlags=(KEYMODIFIER_AltExcluded|KEYMODIFIER_CtrlExcluded|KEYMODIFIER_ShiftExcluded) )
		: InputKeyName(InKeyName), ModifierKeyFlags(InModifierFlags)
		{}

		FRawInputKeyEventData( const FRawInputKeyEventData& Other )
		: InputKeyName(Other.InputKeyName), ModifierKeyFlags(Other.ModifierKeyFlags)
		{}

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FRawInputKeyEventData& Other ) const
		{
			return InputKeyName == Other.InputKeyName && ModifierKeyFlags == Other.ModifierKeyFlags;
		}
		FORCEINLINE UBOOL operator!=( const FRawInputKeyEventData& Other ) const
		{
			return InputKeyName != Other.InputKeyName || ModifierKeyFlags != Other.ModifierKeyFlags;
		}
		/** Required in order for FRawInputKeyEventData to be used as the key in a map */
		friend inline DWORD GetTypeHash( const FRawInputKeyEventData& KeyEvt )
		{
			return GetTypeHash(KeyEvt.InputKeyName);
		}

		/**
		 * Applies the specified modifier key bitmask to ModifierKeyFlags
		 */
		FORCEINLINE void SetModifierKeyFlags( BYTE ModifierFlags )
		{
			ModifierKeyFlags |= ModifierFlags;
		}
		/** Clears the specified modifier key bitmask from ModifierKeyFlags */
		FORCEINLINE void ClearModifierKeyFlags( BYTE ModifierFlags )
		{
			ModifierKeyFlags &= ~ModifierFlags;
		}

		/**
		 * Returns TRUE if ModifierKeyFlags contains any of the bits in FlagsToCheck.
		 */
		FORCEINLINE UBOOL HasAnyModifierKeyFlags( BYTE FlagsToCheck ) const
		{
			return (ModifierKeyFlags&FlagsToCheck) != 0 || FlagsToCheck == KEYMODIFIER_All;
		}

		/**
		 * Returns TRUE if ModifierKeyFlags contains all of the bits in FlagsToCheck
		 */
		FORCEINLINE UBOOL HasAllModifierFlags( BYTE FlagsToCheck ) const
		{
			return (ModifierKeyFlags&FlagsToCheck) == FlagsToCheck;
		}
	}
};

/**
 * Stores a list of input key names that should be linked to an input action alias key (i.e. NAV_Left, NAV_Right)
 * Used by the UI system to handle input events in a platform & game agnostic way.
 */
struct native export UIInputActionAlias
{
	/** the name of an input action alias that the UI responds to */
	var name			InputAliasName;

	/**
	 * the input key names (e.g. KEY_Left, KEY_Right) and modifier which will trigger this input alias
	 */
	var	array<RawInputKeyEventData>	LinkedInputKeys;
};

/**
 * Combines an input alias name with the modifier flag bitmask required to activate it.
 */
struct native transient export UIInputAliasValue
{
	/**
	 * a bitmask representing the modifier key state required to activate this input alias
	 */
	var	byte	ModifierFlagMask;

	/** the name of the input alias */
	var	name	InputAliasName;

	structcpptext
	{
		FUIInputAliasValue()
		: ModifierFlagMask(0), InputAliasName(NAME_None)
		{}

		FUIInputAliasValue( BYTE InModifierFlagMask, const FName& inAliasName )
		: ModifierFlagMask(InModifierFlagMask), InputAliasName(inAliasName)
		{}
		FUIInputAliasValue(EEventParm)
		{
			appMemzero(this, sizeof(FUIInputAliasValue));
		}

		/**
		 * Returns FALSE if this input alias value's ModifierFlagMask disallows the provided modifier key states.
		 */
		UBOOL MatchesModifierState( UBOOL bAltPressed, UBOOL bCtrlPressed, UBOOL bShiftPressed ) const;

		/** Comparison operators */
		FORCEINLINE UBOOL operator==( const FUIInputAliasValue& Other ) const
		{
			return InputAliasName == Other.InputAliasName && ModifierFlagMask == Other.ModifierFlagMask;
		}
		FORCEINLINE UBOOL operator!=( const FUIInputAliasValue& Other ) const
		{
			return InputAliasName != Other.InputAliasName || ModifierFlagMask != Other.ModifierFlagMask;
		}
	}
};

/**
 * A TMultiMap wrapper which maps input key names (i.e. KEY_Left) to a list of input action alias data.
 */
struct native export UIInputAliasMap
{
	/**
	 * A mapping from input key data (name + modifier key) <==> input alias triggered by that input key event
	 * Used to retrieve the input action alias for a given input key when input events are received.
	 */
	var const native transient MultiMap_Mirror			InputAliasLookupTable{TMultiMap< FName, FUIInputAliasValue >};

	structcpptext
	{
		/** Constructors */
	    FUIInputAliasMap() {}
	    FUIInputAliasMap(EEventParm)
	    {
	        appMemzero(this, sizeof(FUIInputAliasMap));
	    }
	}
};

/**
 * Defines the list of key mappings supported in a paticular widget state.
 */
struct native export UIInputAliasStateMap
{
	/** the path name for the state class to load */
	var	string										StateClassName;

	/** The widget state that this map contains input aliases for. */
	var class<UIState>								State;

	/** the input action aliases that this widget state supports */
	var array<UIInputActionAlias>					StateInputAliases;
};

/**
 * Defines the UIInputActionAliases that are supported by a particular widget class for each state.
 *
 * @todo ronp - add support for specifying "input alias => raw input key" mappings for widget archetypes
 */
struct native UIInputAliasClassMap
{
	/** the name of the widget class to load */
	var	string																	WidgetClassName;

	/** the widget class that this UIInputAliasMap contains input aliases for */
	var class<UIScreenObject>													WidgetClass;

	/** the states that this widget class supports */
	var array<UIInputAliasStateMap>												WidgetStates;

	/**
	 * Runtime lookup map to find a input alias map.  Maps a UIState class <=> (map of input key name (KEY_Left) + modifier keys <=> input key alias (UIKEY_Clicked)).
	 * Used for quickly unregistering input keys when a state goes out of scope.
	 */
	var const native transient Map{UClass*,  FUIInputAliasMap}					StateLookupTable;

	/**
	 * Runtime lookup map to find a state input struct.  Maps a UIState class => (map of input key alias (UIKEY_Clicked) => input key name (KEY_Left))
	 * Used for quickly registering input keys when a state enters scope - since multiple input keys can be mapped to a single input key alias, and
	 * each input key alias name must be checked against the list of disabled input aliases, storing this reverse lookup table allows us to check only
	 * once for each input alias.
	 */
	var const native transient Map{UClass*,  TArray<const FUIInputAliasStateMap*>}	StateReverseLookupTable;

	structcpptext
	{
		/** Constructors */
	    FUIInputAliasClassMap() {}
	    FUIInputAliasClassMap(EEventParm)
	    {
	        appMemzero(this, sizeof(FUIInputAliasClassMap));
	    }

		/**
		 * Initializes the runtime lookup table with the aliases stored in WidgetInputAliases
		 *
		 * @param	InputAliasList	the list of input alias mappings for all registered UI classes.
		 */
		void InitializeLookupTable( const TMap<UClass*,FUIInputAliasClassMap*>& InputAliasList );
	}
};


cpptext
{
	/**
	 * Given a face, return the opposite face.
	 *
	 * @return	the EUIWidgetFace member corresponding to the opposite face of the input value, or UIFACE_MAX if the input
	 *			value is invalid.
	 */
	static EUIWidgetFace GetOppositeFace( BYTE Face );

	/**
	 * Returns the friendly name of for the specified face from the EUIWidgetFace enum.
	 *
	 * @return	the textual representation of the enum member specified, or "Unknown" if the value is invalid.
	 */
	static FString GetDockFaceText( BYTE Face );

	/**
	 * Returns the friendly name for the specified input event from the EInputEvent enum.
	 *
	 * @return	the textual representation of the enum member specified, or "Unknown" if the value is invalid.
	 */
	static FString GetInputEventText( BYTE InputEvent );

	/**
	 * Returns the friendly name for the specified cell state from the UIListElementState enum.
	 *
	 * @return	the textual representation of the enum member specified, or "Unknown" if the value is invalid.
	 */
	static FString GetCellStateText( BYTE CellState );

	/**
	 * Returns the friendly name for the specified field type from the UIDataProviderFieldType enum.
	 *
	 * @return	the textual representation of the enum member specified, or "Unknown" if the value is invalid.
	 */
	static FString GetDataProviderFieldTypeText( BYTE FieldType );

	/**
	 * Returns the friendly name for the specified platform type from the EInputPlatformType enum.
	 *
	 * @return	the textual representation of the enum member specified, or "Unknown" if the value is invalid.
	 */
	static FString GetInputPlatformTypeText( BYTE PlatformType );

	/**
	 * Wrapper for returns the orientation associated with the specified face.
	 */
	static EUIOrientation GetFaceOrientation( BYTE Face );

	/**
	 * Returns the platform type for the current input device.  This is not necessarily the platform the game is actually running
	 * on; for example, if the game is running on a PC, but the player is using an Xbox controller, the current InputPlatformType
	 * would be IPT_360.
	 *
	 * @param	OwningPlayer	if specified, the returned InputPlatformType will reflect the actual input device the player
	 *							is using.  Otherwise, the returned InputPlatformType is always the platform the game is running on.
	 *
	 * @return	the platform type for the current input device (if a player is specified) or the host platform.
	 */
	static EInputPlatformType GetInputPlatformType( ULocalPlayer* OwningPlayer=NULL );

	/**
	 * Returns the current position of the mouse or joystick cursor.
	 *
	 * @param	CursorPosition	receives the position of the cursor
	 * @param	Scene			if specified, provides access to an FViewport through the scene's SceneClient that can be used
	 *							for retrieving the mouse position when not in the game.
	 *
	 * @return	TRUE if the cursor position was retrieved correctly.
	 */
	static UBOOL GetCursorPosition( FVector2D& CursorPosition, const UUIScene* Scene=NULL );

	/**
	 * Returns the current position of the mouse or joystick cursor.
	 *
	 * @param	CursorX		receives the X position of the cursor
	 * @param	CursorY		receives the Y position of the cursor
	 * @param	Scene		if specified, provides access to an FViewport through the scene's SceneClient that can be used
	 *						for retrieving the mouse position when not in the game.
	 *
	 * @return	TRUE if the cursor position was retrieved correctly.
	 */
	static UBOOL GetCursorPosition( INT& CursorX, INT& CursorY, const UUIScene* Scene=NULL );

	/**
	 * Returns the current position of the mouse or joystick cursor.
	 *
	 * @param	CursorXL	receives the width of the cursor
	 * @param	CursorYL	receives the height of the cursor
	 *
	 * @return	TRUE if the cursor size was retrieved correctly.
	 */
	static UBOOL GetCursorSize( FLOAT& CursorXL, FLOAT& CursorYL );

	/**
	 * Changes the value of GameViewportClient.bUIMouseCaptureOverride to the specified value.  Used by widgets that process
	 * dragging to ensure that the widget receives the mouse button release event.
	 *
	 * @param	bCaptureMouse	whether to capture all mouse input.
	 */
	static void SetMouseCaptureOverride( UBOOL bCaptureMouse );

	/**
	 * @return	TRUE if the specified key is a mouse key
	 */
	static UBOOL IsCursorInputKey( FName KeyName );

	/**
	 * Returns the UIController class set for this game.
	 *
	 * @return	a pointer to a UIInteraction class which is set as the value for GameViewportClient.UIControllerClass.
	 */
	static class UClass* GetUIControllerClass();

	/**
	 * Returns the default object for the UIController class set for this game.
	 *
	 * @return	a pointer to the CDO for UIInteraction class configured for this game.
	 */
	static class UUIInteraction* GetDefaultUIController();

	/**
	 * Returns the UIInteraction instance currently controlling the UI system, which is valid in game.
	 *
	 * @return	a pointer to the UIInteraction object currently controlling the UI system.
	 */
	static class UUIInteraction* GetCurrentUIController();

	/**
	 * Returns the game's scene client.
	 *
	 * @return 	a pointer to the UGameUISceneClient instance currently managing the scenes for the UI System.
	 */
	static class UGameUISceneClient* GetSceneClient();

	/**
	 * Resolves a data store from markup.
	 *
	 * @param	DatafieldMarkupString	The markup string to resolve
	 * @param	InOwnerScene			The scene to use (can be null)
	 * @param	InOwnerPlayer			The local player to use (can be null)
	 * @param	out_ResolvedProvider	The provider associated with the markup
	 * @param 	out_DataFieldName		The Datafield associated with the markup
	 * @param	out_ResolvedDataStore	The resolved data store
	 *
	 */
	static UBOOL ResolveDataStoreMarkup(const FString &DataFieldMarkupString, UUIScene* InOwnerScene, ULocalPlayer* InOwnerPlayer,
					class UUIDataProvider*& out_ResolvedProvider, FString& out_DataFieldName, class UUIDataStore** out_ResolvedDataStore=NULL );

	/**
	 * Returns a matrix which includes the translation, rotation and scale necessary to transform a point from origin to the
	 * the specified widget's position onscreen.  This matrix can then be passed to ConditionalUpdateTransform() for primitives
	 * in use by the UI.
	 *
	 * @param	Widget					the widget to generate the matrix for
	 * @param	bIncludeAnchorPosition	specify TRUE to include translation to the widget's anchor; if FALSE, the translation will move
	 *									the point to the widget's upper left corner (in local space)
	 * @param	bIncludeRotation		specify FALSE to remove the widget's rotation from the resulting matrix
	 * @param	bIncludeScale			specify FALSE to remove the viewport's scale from the resulting matrix
	 *
	 * @return	a matrix which can be used to translate from origin (0,0) to the widget's position, including rotation and viewport scale.
	 */
	static class FMatrix GetPrimitiveTransform( UUIObject* Widget, UBOOL bIncludeAnchorPosition=FALSE, UBOOL bIncludeRotation=TRUE, UBOOL bIncludeScale=TRUE );
}


/**
 * Returns the platform type for the current input device.  This is not necessarily the platform the game is actually running
 * on; for example, if the game is running on a PC, but the player is using an Xbox controller, the current InputPlatformType
 * would be IPT_360.
 *
 * @param	OwningPlayer	if specified, the returned InputPlatformType will reflect the actual input device the player
 *							is using.  Otherwise, the returned InputPlatformType is always the platform the game is running on.
 *
 * @return	the platform type for the current input device (if a player is specified) or the host platform.
 *
 * @note: noexport because the C++ version is static too.
 */
native static final noexport function EInputPlatformType GetInputPlatformType( optional LocalPlayer OwningPlayer );

/**
 * @return Returns the current platform the game is running on.
 */
static final function bool IsConsole( optional EConsoleType ConsoleType=CONSOLE_Any )
{
	return class'WorldInfo'.static.IsConsoleBuild(ConsoleType);
}

/**
 * @return	TRUE if we're in the editor.
 */
static final function bool IsEditor()
{
	return GetCurrentUIController() == None;
}

/**
 * Returns the UIInteraction instance currently controlling the UI system, which is valid in game.
 *
 * @return	a pointer to the UIInteraction object currently controlling the UI system.
 */
native static final noexport function UIInteraction GetCurrentUIController();

/**
 * Returns the game's scene client.
 *
 * @return 	a pointer to the UGameUISceneClient instance currently managing the scenes for the UI System.
 */
native static final noexport function GameUISceneClient GetSceneClient();

/**
 * Wrapper for returns the orientation associated with the specified face.
 *
 * @note: noexport because the C++ version is static too.
 */
native static final noexport function EUIOrientation GetFaceOrientation( EUIWidgetFace Face );

/**
 * Returns the current position of the mouse or joystick cursor.
 *
 * @param	CursorX		receives the X position of the cursor
 * @param	CursorY		receives the Y position of the cursor
 * @param	Scene		if specified, provides access to an FViewport through the scene's SceneClient that can be used
 *						for retrieving the mouse position when not in the game.
 *
 * @return	TRUE if the cursor position was retrieved correctly.
 */
native static final noexport function bool GetCursorPosition( out int CursorX, out int CursorY, const optional UIScene Scene );

/**
 * Returns the current position of the mouse or joystick cursor.
 *
 * @param	CursorXL	receives the width of the cursor
 * @param	CursorYL	receives the height of the cursor
 *
 * @return	TRUE if the cursor size was retrieved correctly.
 */
native static final noexport function bool GetCursorSize( out float CursorXL, out float CursorYL );

/**
 * Changes the value of GameViewportClient.bUIMouseCaptureOverride to the specified value.  Used by widgets that process
 * dragging to ensure that the widget receives the mouse button release event.
 *
 * @param	bCaptureMouse	whether to capture all mouse input.
 */
native static final noexport function SetMouseCaptureOverride( bool bCaptureMouse );

/**
 * Returns a matrix which includes the translation, rotation and scale necessary to transform a point from origin to the
 * the specified widget's position onscreen.  This matrix can then be passed to ConditionalUpdateTransform() for primitives
 * in use by the UI.
 *
 * @param	Widget	the widget to generate the matrix for
 * @param	bIncludeAnchorPosition	specify TRUE to include translation to the widget's anchor; if FALSE, the translation will move
 *									the point to the widget's upper left corner (in local space)
 * @param	bIncludeRotation		specify FALSE to remove the widget's rotation from the resulting matrix
 * @param	bIncludeScale			specify FALSE to remove the viewport's scale from the resulting matrix
 *
 * @return	a matrix which can be used to translate from origin (0,0) to the widget's position, including rotation and viewport scale.
 *
 * @note: noexport because we want this method to be static in C++ as well.
 */
native static final noexport function Matrix GetPrimitiveTransform( UIObject Widget, optional bool bIncludeAnchorPosition, optional bool bIncudeRotation=true, optional bool bIncludeScale=true ) const;

static final function UIDataStore StaticResolveDataStore( name DataStoreTag, optional UIScene OwnerScene, optional LocalPlayer InPlayerOwner )
{
	local UIDataStore Result;
	local DataStoreClient DSClient;

	if ( OwnerScene != None )
	{
		Result = OwnerScene.ResolveDataStore(DataStoreTag, InPlayerOwner);
	}
	else
	{
		DSClient = class'UIInteraction'.static.GetDataStoreClient();
		if ( DSClient != None )
		{
			Result = DSClient.FindDataStore(DataStoreTag, InPlayerOwner);
		}
	}

	return Result;
}

/**
 * Sets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to set the value of.
 * @param InFieldValue			Value to set the datafield's value to.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was set, FALSE otherwise.
 */
native static final function bool SetDataStoreFieldValue(string InDataStoreMarkup, const out UIProviderFieldValue InFieldValue, optional UIScene OwnerScene, optional LocalPlayer OwnerPlayer);


/**
 * Sets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to set the value of.
 * @param InStringValue			Value to set the datafield's string value to.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was set, FALSE otherwise.
 */
static function bool SetDataStoreStringValue(string InDataStoreMarkup, string InStringValue, optional UIScene OwnerScene, optional LocalPlayer OwnerPlayer)
{
	local UIProviderFieldValue FieldValue;

	FieldValue.StringValue = InStringValue;
	FieldValue.PropertyType = DATATYPE_Property;

	return SetDataStoreFieldValue(InDataStoreMarkup, FieldValue, OwnerScene, OwnerPlayer);
}


/**
 * Gets the field value struct of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to retrieve the value of.
 * @param OutFieldValue			Variable to store the result field value in.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was retrieved, FALSE otherwise.
 */
native static final function bool GetDataStoreFieldValue(string InDataStoreMarkup, out UIProviderFieldValue OutFieldValue, optional UIScene OwnerScene, optional LocalPlayer OwnerPlayer);

/**
 * Gets the string value of the datastore entry specified.
 *
 * @param InDataStoreMarkup		Markup to find the field we want to retrieve the value of.
 * @param OutStringValue		Variable to store the result string in.
 * @param OwnerScene			Owner scene for the datastore, used when dealing with scene specific datastores.
 * @param OwnerPlayer			Owner player for the datastore, used when dealing with player datastores.
 *
 * @return TRUE if the value was retrieved, FALSE otherwise.
 */
static function bool GetDataStoreStringValue(string InDataStoreMarkup, out string OutStringValue, optional UIScene OwnerScene=none, optional LocalPlayer OwnerPlayer=none)
{
	local UIProviderFieldValue FieldValue;
	local bool Result;

	if(GetDataStoreFieldValue(InDataStoreMarkup, FieldValue, OwnerScene, OwnerPlayer))
	{
		OutStringValue = FieldValue.StringValue;
		Result = TRUE;
	}

	return Result;
}


/**
 * Generates a unique tag that can be used in the scene's data store as the data field name for a widget's
 * context menu items.
 *
 * @param	SourceWidget	the widget to generate the unique tag for
 *
 * @return	a string guaranteed to be unique which represents the source widget.
 */
static final function string ConvertWidgetIDToString( UIObject SourceWidget )
{
	local string Result;

	if ( SourceWidget != None )
	{
		// the widget's ID is guaranteed to be unique
		Result
			= ToHex(SourceWidget.WidgetId.A)
			$ ToHex(SourceWidget.WidgetId.B)
			$ ToHex(SourceWidget.WidgetId.C)
			$ ToHex(SourceWidget.WidgetId.D);
	}

	return Result;
}

/**
 * Wrapper for getting a reference to the online subsystem's game interface.
 */
static final function OnlineGameInterface GetOnlineGameInterface()
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface Result;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None )
	{
		Result = OnlineSub.GameInterface;
	}
	else
	{
		`Log("GetOnlinePlayerInterfaceEx: Unable to find OnlineSubSystem!");
	}

	return Result;
}

/**
 * Wrapper for getting a reference to the online subsystem's player interface.
 */
static final function OnlinePlayerInterface GetOnlinePlayerInterface()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface Result;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if ( OnlineSub != None )
	{
		Result = OnlineSub.PlayerInterface;
	}
	else
	{
		`Log("GetOnlinePlayerInterfaceEx: Unable to find OnlineSubSystem!");
	}

	return Result;
}

/**
 * Wrapper for getting a reference to the extended online player interface
 */
static final function OnlinePlayerInterfaceEx GetOnlinePlayerInterfaceEx()
{
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterfaceEx PlayerIntEx;

	// Display the login UI
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		PlayerIntEx = OnlineSub.PlayerInterfaceEx;
	}
	else
	{
		`Log("GetOnlinePlayerInterfaceEx: Unable to find OnlineSubSystem!");
	}

	return PlayerIntEx;
}

defaultproperties
{
}
