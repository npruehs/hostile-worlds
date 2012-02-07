/**
 * A simple widget for displaying text in the UI.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UILabel extends UIObject
	native(UIPrivate)
	implements(UIDataStoreSubscriber,UIStringRenderer);

/** the text that will be rendered by this label */
var(Data)	private						UIDataStoreBinding		DataSource;

/** Renders the text displayed by this label */
var(Components)	editinline	const noclear	UIComp_DrawString		StringRenderComponent;

/** Optional component for rendering a background image for this UILabel */
var(Components)	editinline	const			UIComp_DrawImage		LabelBackground;

cpptext
{
	/* === UUIScreenObject interface === */
	/**
	 * Perform all initialization for this widget. Called on all widgets when a scene is opened,
	 * once the scene has been completely initialized.
	 * For widgets added at runtime, called after the widget has been inserted into its parent's
	 * list of children.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/* === UUIObject interface === */
	/**
	 * Provides a way for widgets to fill their style subscribers array prior to performing any other initialization tasks.
	 *
	 * This version adds the LabelBackground (if non-NULL) to the StyleSubscribers array.
	 */
	virtual void InitializeStyleSubscribers();

	/**
	 * Adds the specified face to the DockingStack for the specified widget
	 *
	 * @param	DockingStack	the docking stack to add this docking node to.  Generally the scene's DockingStack.
	 * @param	Face			the face that should be added
	 *
	 * @return	TRUE if a docking node was added to the scene's DockingStack for the specified face, or if a docking node already
	 *			existed in the stack for the specified face of this widget.
	 */
	virtual UBOOL AddDockingNode( TArray<struct FUIDockingNode>& DockingStack, EUIWidgetFace Face );

	/**
	 * Evalutes the Position value for the specified face into an actual pixel value.  Should only be
	 * called from UIScene::ResolvePositions.  Any special-case positioning should be done in this function.
	 *
	 * @param	Face	the face that should be resolved
	 */
	virtual void ResolveFacePosition( EUIWidgetFace Face );

protected:
	/**
	 * Marks the Position for any faces dependent on the specified face, in this widget or its children,
	 * as out of sync with the corresponding RenderBounds.
	 *
	 * @param	Face	the face to modify; value must be one of the EUIWidgetFace values.
	 */
	virtual void InvalidatePositionDependencies( BYTE Face );

public:
	/**
	 * Render this widget.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas );

	/**
	 * Called when a property is modified that could potentially affect the widget's position onscreen.
	 */
	virtual void RefreshPosition();

	/**
	 * Called to globally update the formatting of all UIStrings.
	 */
	virtual void RefreshFormatting( UBOOL bRequestSceneUpdate=TRUE );

	/**
	 * Changes this widget's position to the specified value.  This version changes the default value for the bClampValues parameter to TRUE
	 *
	 * @param	LeftFace		the value (in pixels or percentage) to set the left face to
	 * @param	TopFace			the value (in pixels or percentage) to set the top face to
	 * @param	RightFace		the value (in pixels or percentage) to set the right face to
	 * @param	BottomFace		the value (in pixels or percentage) to set the bottom face to
	 * @param	InputType		indicates the format of the input value.  All values will be evaluated as this type.
	 *								EVALPOS_None:
	 *									NewValue will be considered to be in whichever format is configured as the ScaleType for the specified face
	 *								EVALPOS_PercentageOwner:
	 *								EVALPOS_PercentageScene:
	 *								EVALPOS_PercentageViewport:
	 *									Indicates that NewValue is a value between 0.0 and 1.0, which represents the percentage of the corresponding
	 *									base's actual size.
	 *								EVALPOS_PixelOwner
	 *								EVALPOS_PixelScene
	 *								EVALPOS_PixelViewport
	 *									Indicates that NewValue is an actual pixel value, relative to the corresponding base.
	 * @param	bIncludesViewportOrigin
	 *							TRUE indicates that the value is relative to the 0,0 on the screen (or absolute position); FALSE to indicate
	 *							the value is relative to the viewport's origin.
	 * @param	bClampValues	if TRUE, clamps the values of RightFace and BottomFace so that they cannot be less than the values for LeftFace and TopFace
	 */
	virtual void SetPosition( const FLOAT LeftFace, const FLOAT TopFace, const FLOAT RightFace, const FLOAT BottomFace, EPositionEvalType InputType=EVALPOS_PixelViewport, UBOOL bIncludesViewportOrigin=FALSE, UBOOL bClampValues=TRUE )
	{
		Super::SetPosition(LeftFace, TopFace, RightFace, BottomFace, InputType, bIncludesViewportOrigin, bClampValues);
	}

	/**
	 * Retrieves the current value for some data currently being interpolated by this widget.
	 *
	 * @param	AnimationType		the type of animation data to retrieve
	 * @param	out_CurrentValue	receives the current data value; animation type determines which of the fields holds the actual data value.
	 *
	 * @return	TRUE if the widget supports the animation type specified.
	 */
	virtual UBOOL Anim_GetValue( BYTE AnimationType, FUIAnimationRawData& out_CurrentValue ) const;
	/**
	 * Updates the current value for some data currently being interpolated by this widget.
	 *
	 * @param	AnimationType		the type of animation data to set
	 * @param	out_CurrentValue	contains the updated data value; animation type determines which of the fields holds the actual data value.
	 *
	 * @return	TRUE if the widget supports the animation type specified.
	 */
	virtual UBOOL Anim_SetValue( BYTE AnimationType, const FUIAnimationRawData& NewValue );

	/* === UObject interface === */
	/**
	 * Called when a property value from a member struct or array has been changed in the editor, but before the value has actually been modified.
	 */
	virtual void PreEditChange( FEditPropertyChain& PropertyThatChanged );

	/**
	 * Called when a property value has been changed in the editor.
	 */
	virtual void PostEditChangeChainProperty(FPropertyChangedChainEvent& PropertyChangedEvent);

	/**
	 * Called after this object has been completely de-serialized.  This version migrates the PrimaryStyle for this label over to the label's component.
	 */
	virtual void PostLoad();
}

/**
 * Change the value of this label at runtime.
 *
 * @param	NewText		the new text that should be displayed in the label
 */
native final function SetValue( string NewText );

/** UIStringRenderer interface */

/**
 * Sets the text alignment for the string that the widget is rendering.
 *
 * @param	Horizontal		Horizontal alignment to use for text, UIALIGN_MAX means no change.
 * @param	Vertical		Vertical alignment to use for text, UIALIGN_MAX means no change.
 */
native final virtual function SetTextAlignment(EUIAlignment Horizontal, EUIAlignment Vertical);

/** UIDataSourceSubscriber interface */
/**
 * Sets the data store binding for this object to the text specified.
 *
 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
 *								<DataStoreTag:DataFieldTag>
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 */
native final virtual function SetDataStoreBinding( string MarkupText, optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the markup string corresponding to the data store that this object is bound to.
 *
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	a datastore markup string which resolves to the datastore field that this object is bound to, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
native final virtual function string GetDataStoreBinding( optional int BindingIndex=INDEX_NONE ) const;

/**
 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
 *
 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
 */
native final virtual function bool RefreshSubscriberValue( optional int BindingIndex=INDEX_NONE );

/**
 * Handler for the UIDataStore.OnDataStoreValueUpdated delegate.  Used by data stores to indicate that some data provided by the data
 * has changed.  Subscribers should use this function to refresh any data store values being displayed with the updated value.
 * notify subscribers when they should refresh their values from this data store.
 *
 * @param	SourceDataStore		the data store that generated the refresh notification; useful for subscribers with multiple data store
 *								bindings, to tell which data store sent the notification.
 * @param	PropertyTag			the tag associated with the data field that was updated; Subscribers can use this tag to determine whether
 *								there is any need to refresh their data values.
 * @param	SourceProvider		for data stores which contain nested providers, the provider that contains the data which changed.
 * @param	ArrayIndex			for collection fields, indicates which element was changed.  value of INDEX_NONE indicates not an array
 *								or that the entire array was updated.
 */
native final virtual function NotifyDataStoreValueUpdated( UIDataStore SourceDataStore, bool bValuesInvalidated, name PropertyTag, UIDataProvider SourceProvider, int ArrayIndex );

/**
 * Retrieves the list of data stores bound by this subscriber.
 *
 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
 */
native final virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final function ClearBoundDataStores();


/** === Unrealscript === */
final function SetArrayValue( array<string> ValueArray )
{
	local string Str;

	JoinArray(ValueArray, Str, "\n", false);
	SetValue(Str);
}

/**
 * Retrieve the value of this label
 */
function string GetValue()
{
	return StringRenderComponent.GetValue();
}

/**
 * Changes whether this label's string should process markup
 *
 * @param	bShouldIgnoreMarkup		if TRUE, markup will not be processed by this label's string
 *
 * @note: does not update any existing text contained by the label.
 */
final function IgnoreMarkup( bool bShouldIgnoreMarkup )
{
	StringRenderComponent.bIgnoreMarkup = bShouldIgnoreMarkup;
}

DefaultProperties
{
	Position=(Value[UIFACE_Right]=100,Value[UIFACE_Bottom]=40,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner,ScaleType[UIFACE_Bottom]=EVALPOS_PixelOwner)
	PrimaryStyle=(DefaultStyleTag="DefaultComboStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	bSupportsPrimaryStyle=false

	DataSource=(MarkupString="Initial Label Text",RequiredFieldType=DATATYPE_Property)

	Begin Object Class=UIComp_DrawString Name=LabelStringRenderer
		StringStyle=(DefaultStyleTag="DefaultComboStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	End Object
	StringRenderComponent=LabelStringRenderer
}
