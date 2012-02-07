/**
 * Base class for all classes which provide data stores with data about specific instances of a particular data type.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UIDataProvider extends UIRoot
	native(UIPrivate)
	transient
	abstract;

cpptext
{
protected:
	/**
	 * Returns the data tag associated with the specified provider.
	 *
	 * @return	the data field tag associated with the provider specified, or NAME_None if the provider specified is not
	 *			contained by this data store.
	 */
	virtual FName GetProviderDataTag( class UUIDataProvider* Provider );

	/**
	 * Determines whether publishing updated values to the specified field is allowed.
	 *
	 * @param	PropTag		the name of the field within this data provider to check access for (might be blank)
	 * @param	ArrayIndex	optional array index for use with data collections.
	 *
	 * @return	TRUE if publishing updated values is allowed for the field.
	 */
	virtual UBOOL AllowsPublishingData( const FString& PropTag, INT ArrayIndex=INDEX_NONE );

	/**
	 * Resolves the value of the data field specified and stores it in the output parameter.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	out_FieldValue	receives the resolved value for the property specified.
	 *							@see ParseDataStoreReference for additional notes
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL GetFieldValue( const FString& FieldName, struct FUIProviderFieldValue& out_FieldValue, INT ArrayIndex=INDEX_NONE )
	{
		return eventGetFieldValue(FieldName, out_FieldValue, ArrayIndex);
	}

	/**
	 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
	 *
	 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
	 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
	 * @param	FieldValue		the value to store for the property specified.
	 * @param	ArrayIndex		optional array index for use with data collections
	 */
	virtual UBOOL SetFieldValue( const FString& FieldName, const struct FUIProviderScriptFieldValue& FieldValue, INT ArrayIndex=INDEX_NONE )
	{
		return eventSetFieldValue(FieldName, FieldValue, ArrayIndex);
	}

public:
	/**
	 * Gets the list of data fields exposed by this data provider.
	 *
	 * @param	out_Fields	will be filled in with the list of tags which can be used to access data in this data provider.
	 *						Will call GetScriptDataTags to allow script-only child classes to add to this list.
	 */
	virtual void GetSupportedDataFields( TArray<struct FUIDataProviderField>& out_Fields );

	/**
	 * Parses the data store reference and resolves it into a value that can be used by the UI.
	 *
	 * @param	MarkupString	a markup string that can be resolved to a data field contained by this data provider, or one of its
	 *							internal data providers.
	 * @param	out_FieldValue	receives the value of the data field resolved from MarkupString.  If the specified property corresponds
	 *							to a value that can be rendered as a string, the field value should be assigned to the StringValue member;
	 *							if the specified property corresponds to a value that can only be rendered as an image, such as an object
	 *							or image reference, the field value should be assigned to the ImageValue member.
	 *							Data stores can optionally manually create a UIStringNode_Text or UIStringNode_Image containing the appropriate
	 *							value, in order to have greater control over how the string node is initialized.  Generally, this is not necessary.
	 *
	 * @return	TRUE if this data store (or one of its internal data providers) successfully resolved the string specified into a data field
	 *			and assigned the value to the out_FieldValue parameter; false if this data store could not resolve the markup string specified.
	 */
	virtual UBOOL GetDataStoreValue( const FString& MarkupString, struct FUIProviderFieldValue& out_FieldValue );

	/**
	 * Parses the data store reference and publishes the value specified to that location.
	 *
	 * @param	MarkupString	a markup string that can be resolved to a data field contained by this data provider, or one of its
	 *							internal data providers.
	 * @param	FieldValue		contains the value that should be published to the location specified by MarkupString.
	 *
	 * @return	TRUE if this data store (or one of its internal data providers) successfully resolved the string specified into a data field
	 *			and assigned the value to the out_FieldValue parameter; false if this data store could not resolve the markup string specified.
	 */
	virtual UBOOL SetDataStoreValue( const FString& MarkupString, const struct FUIProviderScriptFieldValue& FieldValue );

	/**
	 * For data stores that are responsible for applying inline style modifications (such as the font, style, and attribute data stores),
	 * parses the data store reference and applies the appropriate style changes.
	 *
	 * @param	MarkupString	a markup string representing a style modification that this data store is aware of; i.e. the name of the font,
	 *							style, or attribute.
	 * @param	StyleData		the style data to apply the changes to.
	 *
	 * @return	TRUE if this data store applied a change to StyleData based on the value of MarkupString, FALSE otherwise.
	 */
	virtual UBOOL ParseStringModifier( const FString& MarkupString, struct FUIStringNodeModifier& StyleData ) { return FALSE; }

	/**
	 * Returns a pointer to the data provider which provides the tags for this data provider.  Normally, that will be this data provider,
	 * but for some data stores such as the Scene data store, data is pulled from an internal provider but the data fields are presented as
	 * though they are fields of the data store itself.
	 */
	virtual UUIDataProvider* GetDefaultDataProvider() { return this; }

	/**
	 * Resolves PropertyName into a list element provider that provides list elements for the property specified.
	 *
	 * @param	PropertyName	the name of the property that corresponds to a list element provider supported by this data store
	 *
	 * @return	a pointer to an interface for retrieving list elements associated with the data specified, or NULL if
	 *			there is no list element provider associated with the specified property.
	 */
	virtual TScriptInterface<class IUIListElementProvider> ResolveListElementProvider( const FString& PropertyName );

	/**
	 * Generates filler data for a given tag.  This is used by the editor to generate a preview that gives the
	 * user an idea as to what a bound datastore will look like in-game.
	 *
 	 * @param		DataTag		the tag corresponding to the data field that we want filler data for
 	 *
	 * @return		a string of made-up data which is indicative of the typical [resolved] value for the specified field.
	 */
	virtual FString GenerateFillerData( const FString& DataTag );

	/**
	 * Parses the data store reference and resolves the data provider and field that is referenced by the markup.
	 *
	 * @param	MarkupString	a markup string that can be resolved to a data field contained by this data provider, or one of its
	 *							internal data providers.
	 * @param	out_FieldOwner	receives the value of the data provider that owns the field referenced by the markup string.
	 * @param	out_FieldTag	receives the value of the property or field referenced by the markup string.
	 * @param	out_ArrayIndex	receives the optional array index for the data field referenced by the markup string.  If there is no array index embedded in the markup string,
	 *							value will be INDEX_NONE.
	 *
	 * @return	TRUE if this data store was able to successfully resolve the string specified.
	 */
	virtual UBOOL ParseDataStoreReference( const FString& MarkupString, class UUIDataProvider*& out_FieldOwner, FString& out_FieldTag, INT& out_ArrayIndex );

	// NON VIRTUALS
	/**
	 * Returns whether the specified provider is contained by this data provider.
	 *
	 * @param	Provider			the provider to search for
	 * @param	out_ProviderOwner	will contain the UIDataProvider that contains the field tag which corresonds to the
	 *								Provider being searched for.
	 *
	 * @return	TRUE if Provider can be accessed through this data provider.
	 */
	UBOOL ContainsProvider( class UUIDataProvider* Provider, class UUIDataProvider*& out_ProviderOwner );

	/**
	 * Generates a data store path to the specified provider.
	 *
	 * @param	Provider			the data store provider to generate a path name to
	 * @param	out_DataStorePath	will be filled in with the path name necessary to access the specified provider,
	 *								including any trailing dots or colons
	 */
	void GetPathToProvider(class UUIDataStore* ContainerDataStore, class UUIDataProvider* Provider, FString& out_DataStorePath );

	/**
	 * Builds the data store path name necessary to access the specified tag of this data provider.
	 *
	 * @param	ContainerDataStore	the data store to use as the starting point for building the data field path
	 * @param	DataTag				the tag corresponding to the data field that we want a path to
	 *
	 * @return		a string containing the complete path name required to access the specified data field
	 */
	FString BuildDataFieldPath( class UUIDataStore* ContainerDataStore, const FName& DataTag );

	/**
	 * Generates a data store markup string which can be used to access the data field specified.
	 *
	 * @param	ContainerDataStore	the data store to use as the starting point for building the markup string
	 * @param	DataTag				the data field tag to generate the markup string for
	 *
	 * @return	a datastore markup string which resolves to the datastore field associated with DataTag, in the format:
	 *			<DataStoreTag:DataFieldTag>
	 */
	FString GenerateDataMarkupString( class UUIDataStore* ContainerDataStore, FName DataTag );

	/**
	 * Builds the data store path name necessary to access the specified tag of this data provider.
	 *
	 * This is a bulk version of the BuildDataFieldPath function.
	 *
	 * @param	ContainerDataStore	the data store to use as the starting point for building the data field path
	 * @param	DataTags			Array of tags to build paths for, ALL of these tags are assumed to be under the same data provider.
	 * @param	Out_Paths			Array of generated paths, one for each of the datatags passed in.
	 */
	void BuildDataFieldPath( class UUIDataStore* ContainerDataStore, const TArray<FName>& DataTags, TArray<FString> &Out_Paths );


	/**
	 * Generates a data store markup string which can be used to access the data field specified.
	 *
	 * This is a bulk version of the GenerateDataMarkupString function.
	 *
	 * @param	ContainerDataStore	the data store to use as the starting point for building the markup string
	 * @param	DataTags			array of tags to generate the markup string for, ALL of these tags are assumed to be under the same data provider.
	 * @param	Out_Markup			Array of strings of generated markup, one for each tag passed in.
	 */
	void GenerateDataMarkupString( class UUIDataStore* ContainerDataStore, const TArray<FName>& DataTags, TArray<FString> &Out_Markup );


	/**
	 * Determines if the specified data tag is supported by this data provider
	 *
	 * @param	DataTag		the tag corresponding to the data field that we want to check for
	 *
	 * @return	TRUE if the data tag specified is supported by this data provider.
	 */
	UBOOL IsDataTagSupported( FName DataTag );

	/**
	 * Determines if the specified data tag is supported by this data provider
	 *
	 * @param	DataTag		a tag corresponding to the data field that we want to check for; ok for the tag to contain array indexes
	 * @param	SupportedFields		the collection of fields to search through; if empty, will automatically fill in the array by calling
	 *								GetSupportedFields; useful optimization when calling this method repeatedly, e.g. in a loop
	 *
	 * @return	TRUE if the data tag specified is supported by this data provider.
	 */
	UBOOL IsDataTagSupported( FName DataTag, TArray<struct FUIDataProviderField>& SupportedFields );

	/**
	 * Parses the specified markup string to get the data tag that should be evaluated by this data provider.
	 *
	 * @param	MarkupString	a string that contains a markup reference (either in whole, or in part), e.g. CurrentGame:Players;1.PlayerName.
	 *							if successfully parsed, after parsing,
	 * @param	out_NextDataTag	a string representing the data tag for the next portion of the data store path reference, including any
	 *							any array delimiters.
	 *
	 * @return	TRUE if the a data tag was successfully parsed.
	 */
	UBOOL ParseNextDataTag( FString& MarkupString, FString& out_NextDataTag ) const;

	/**
	 * Encapsulates the construction of a UITexture wrapper for the specified USurface.
	 *
	 * @param	SourceImage		the texture or material instance to apply to the newly created wrapper
	 *
	 * @return	a pointer to a UITexture instance which wraps the SourceImage passed in, or NULL if SourceImage was invalid
	 *			or the wrapper couldn't be created for some reason.
	 */
	static class UUITexture* CreateTextureWrapper( class USurface* SourceImage );

	/**
	 * Creates the appropriate type of string node for the NodeValue specified.  If NodeValue.CustomStringNode is set, returns
	 * that node; If NodeValue.StringValue is set, creates and initializes a UIStringNode_Text; if NodeValue.ImageValue is
	 * set, creates and initializes a UIStringNode_Image.
	 *
	 * @param	SourceText	the text to assign as the SourceText in the returned node
	 * @param	NodeValue	the value to use for initiailizing the string node that is returned
	 *
	 * @return	a pointer to either a UIStringNode of the appropriate type (Text or Image) that has been initialized from the
	 *			NodeValue specified.  The caller is responsible for cleaning up the memory for this return value.
	 */
	static struct FUIStringNode* CreateStringNode( const FString& SourceText, const struct FUIProviderFieldValue& NodeValue );
}

/**
 * Contains data about a single data field exposed by this data provider.
 */
struct native transient UIDataProviderField
{
	/** the tag used to access this field */
	var		name									FieldTag;

	/** the type of field this tag corresponds to */
	var		EUIDataProviderFieldType				FieldType;

	/**
	 * The list of providers associated with this field.  Only relevant if FieldType is DATATYPE_Provider or
	 * DATATYPE_ProviderCollection.  If FieldType is DATATYPE_Provider, the list should contain only one element.
	 */
	var	public{private}	array<UIDataProvider>		FieldProviders;

structcpptext
{
	/** Constructors */
	FUIDataProviderField() {}

	FUIDataProviderField( FName InFieldTag, EUIDataProviderFieldType InFieldType=DATATYPE_Property, class UUIDataProvider* InFieldProvider=NULL );
	FUIDataProviderField( FName InFieldTag, const TArray<class UUIDataProvider*>& InFieldProviders );

	/**
	 * Retrieves the list of providers contained by this data provider field.
	 *
	 * @return	FALSE if the FieldType for this provider field is not DATATYPE_Provider/ProviderCollection
	 */
	UBOOL GetProviders( TArray<class UUIDataProvider*>& out_Providers ) const;
}
};


/**
 * Types of write access that data providers can specify.
 */
enum EProviderAccessType
{
	/** no fields are writeable - readonly */
	ACCESS_ReadOnly,

	/** write-access is controlled per field */
	ACCESS_PerField,

	/** all fields are writeable */
	ACCESS_WriteAll,
};

/**
 * Determines whether/how subscribers to this data store are allowed to publish changes to property values.
 */
var	EProviderAccessType									WriteAccessType;

/**
 * The list of delegates to call when data exposed by this provider has been updated.
 *
 * @todo - change into a map of property name => delegate, so that when a property name is passed to NotifyPropertyChanged,
 *			only those delegates are called.
 */
var	protected transient	array<delegate<OnDataProviderPropertyChange> >	ProviderChangedNotifies;

/* == Delegates == */
/**
 * Delegate that notifies that a property has changed  Intended only for use between data providers and their owning data stores.
 * For external notifications, use the callbacks in UIDataStore instead.
 *
 * @param	SourceProvider		the data provider that generated the notification
 * @param	PropTag				the property that changed
 */
delegate transient OnDataProviderPropertyChange( UIDataProvider SourceProvider, optional name PropTag );

/* == Natives == */
/**
 * Retrieves the field type for the specified field
 *
 * @param	DataTag					the tag corresponding to the data field that we want the field type for
 * @param	out_ProviderFieldType	will receive the fieldtype for the data field specified; if DataTag isn't supported
 *									by this provider, this value will not be modified.
 *
 * @return	TRUE if the field specified is supported and out_ProviderFieldType was changed to the correct type.
 */
native final function bool GetProviderFieldType( coerce string DataTag, out EUIDataProviderFieldType out_ProviderFieldType );

/**
 * Parses the string specified, separating the array index portion from the data field tag.
 *
 * @param	DataTag		the data tag that possibly contains an array index
 *
 * @return	the array index that was parsed from DataTag, or INDEX_NONE if there was no array index in the string specified.
 */
native function int ParseArrayDelimiter( out string DataTag ) const;

/* == Events == */
/**
 * Callback to allow script-only child classes to add their own supported tags when GetSupportedDataFields is called.
 *
 * @param	out_Fields	the list of data tags supported by this data store.
 */
event GetSupportedScriptFields( out array<UIDataProviderField> out_Fields );

/**
 * Callback for allowing script-only children to specify whether modification of a particular field is allowed.  This callback
 * will only be called if the provider's WriteAccessType is ACCESS_PerField.
 *
 * Child classes should override this function to indicate which fields can be written to, if this provider's WriteAccessType
 * is set to ACCESS_PerField.  Otherwise, write access will not be allowed to any fields.
 *
 * @param	FieldName	the name of the field [within this provider] for the field to check
 * @param	ArrayIndex	optional array index for use with data collections.
 *
 * @return	TRUE if publishing data (change the value for) the field is allowed.
 */
event bool AllowPublishingToField( string FieldName, optional int ArrayIndex=INDEX_NONE );

/**
 * Resolves the value of the data field specified and stores it in the output parameter.
 *
 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
 * @param	out_FieldValue	receives the resolved value for the property specified.
 *							@see ParseDataStoreReference for additional notes
 * @param	ArrayIndex		optional array index for use with data collections
 *
 * @return	TRUE to indicate that this value was processed by script.
 */
event bool GetFieldValue( string FieldName, out UIProviderScriptFieldValue FieldValue, optional int ArrayIndex=INDEX_NONE );

/**
 * Resolves the value of the data field specified and stores the value specified to the appropriate location for that field.
 * Only called if WriteAccessType is ACCESS_WriteAll or AllowsPublishingToField returns TRUE.
 *
 * @param	FieldName		the data field to resolve the value for;  guaranteed to correspond to a property that this provider
 *							can resolve the value for (i.e. not a tag corresponding to an internal provider, etc.)
 * @param	FieldValue		the value to store for the property specified.
 * @param	ArrayIndex		optional array index for use with data collections
 *
 * @return	TRUE to indicate that this value was processed by script.
 */
event bool SetFieldValue( string FieldName, const out UIProviderScriptFieldValue FieldValue, optional int ArrayIndex=INDEX_NONE );

/**
 * Callback to allow script-only child classes to generate a markup string for their own data fields.  Called from
 * the native implementation of GenerateDataMarkupString if the tag specified doesn't correspond to any tags in the data store.
 *
 * @param	DataTag		the data field tag to generate the markup string for
 *
 * @return	a datastore markup string which resolves to the datastore field associated with DataTag, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
event string GenerateScriptMarkupString( Name DataTag );

/**
 * Callback to allow script-only child classes to return filler data for their own data fields.
 *
 * @param		DataTag		the tag corresponding to the data field that we want filler data for
 *
 * @return		a string of made-up data which is indicative of the typical values for the specified field.
 */
event string GenerateFillerData( string DataTag );

/**
 * Allows a data provider instance to indicate that it should be unselectable in lists
 *
 * @return	FALSE to indicate that list elements which represent this data provider should be considered unselectable
 *			or otherwise disabled (though it will still appear in the list).
 */
event bool IsProviderDisabled();

/**
 * Wrapper for determining whether the specified field type represents a collection of data.
 */
event bool IsCollectionDataType( EUIDataProviderFieldType FieldType )
{
	return FieldType == DATATYPE_Collection || FieldType == DATATYPE_ProviderCollection;
}

/**
 * Iterates over the list of subscribed delegates and fires off the event.  Called whenever the value of a field
 * managed by this data provider is modified.
 *
 * @param	PropTag				the name of the property that changed
 */
event NotifyPropertyChanged( optional name PropTag )
{
	local int Index;
	local delegate<OnDataProviderPropertyChange> Subscriber;

	local array<delegate<OnDataProviderPropertyChange> > SubscriberArrayCopy;
	SubscriberArrayCopy.Length = ProviderChangedNotifies.Length;
	for(Index = 0; Index < SubscriberArrayCopy.Length; Index++)
	{
		SubscriberArrayCopy[Index] = ProviderChangedNotifies[Index];
	}

	// Loop through and notify all subscribed delegates
	for (Index = 0; Index < SubscriberArrayCopy.Length; Index++)
	{
		Subscriber = SubscriberArrayCopy[Index];
		Subscriber(Self, PropTag);
	}
}

/* == Unrealscript == */
/**
 * Subscribes a function for receiving notifications that a property in this data provider has changed.  Intended
 * only for use between data providers and their owning data stores.  For external notifications, use the callbacks
 * in UIDataStore instead.
 *
 * @param InDelegate the delegate to add to the notification list
 */
final function bool AddPropertyNotificationChangeRequest( delegate<OnDataProviderPropertyChange> InDelegate, optional bool bAllowDuplicates )
{
	local int NewIndex;
	local bool bResult;

	NewIndex = ProviderChangedNotifies.Find(InDelegate);
	if ( bAllowDuplicates || NewIndex == INDEX_NONE )
	{
		NewIndex = ProviderChangedNotifies.Length;
		ProviderChangedNotifies[NewIndex] = InDelegate;
		bResult = true;
	}

	return bResult;
}

/**
 * Removes the delegate from the notification list
 *
 * @param InDelegate the delegate to remove from the list
 */
final function bool RemovePropertyNotificationChangeRequest(delegate<OnDataProviderPropertyChange> InDelegate)
{
	local int Index;
	local bool bResult;

	for ( Index = ProviderChangedNotifies.Find(InDelegate); Index != INDEX_NONE; Index = ProviderChangedNotifies.Find(InDelegate) )
	{
		ProviderChangedNotifies.Remove(Index,1);
		bResult = true;
	}

	return bResult;
}

/**
 * Wrapper for ParseArrayDelimiter that takes a name parameter.
 */
final function int ParseTagArrayDelimiter( out name FieldName )
{
	local string FieldNameString;
	local int Result;

	FieldNameString = string(FieldName);
	Result = ParseArrayDelimiter(FieldNameString);

	FieldName = name(FieldNameString);
	return Result;
}

DefaultProperties
{
	WriteAccessType=ACCESS_ReadOnly
}
