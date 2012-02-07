/*=============================================================================
	ApexGenericAsset.h: PhysX APEX integration. Clothing Asset
	Copyright 2008-2009 NVIDIA Corporation.
=============================================================================*/

/*** This class defines an Apex Generic Asset
*   An Apex Generic asset is any APEX asset that is described purely as a data blob and does not have any factories associated with it.
*/
class ApexGenericAsset extends ApexAsset
	hidecategories(Object)
	native(Mesh);

/*** Contains a pointer to the allocated Apex asset interface */
var   native pointer                                          MApexAsset{class FIApexAsset};

cpptext
{
	public:
		/**** Serializes the asset
		* @param : Ar is a reference to the FArchive to either serialize from or to.
		*/
		virtual void                 Serialize(FArchive& Ar);

		/*** Returns the array of strings to display in the browser window */
		virtual TArray<FString>      GetGenericBrowserInfo();

		/*** This method is called when a generic asset is imported from an external file on disk.
		**
		** @param Buffer : A pointer to the raw data.
		** @param BufferSize : The length of the raw input data.
		** @param Name : The name of the asset which is being imported.
		**
		** @return : Returns true if the import was successful.
		**/
		UBOOL                        Import( const BYTE* Buffer, INT BufferSize, const FString& Name );

		/*** This method is called after a property has changed. */
		virtual void                 PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

		/** This method is called prior to the object being destroyed */
		virtual void                 BeginDestroy(void);

		/*** This method is called when the asset is renamed
		**
		** @param : InName : The new name of the object
		** @param : NewOuter : The new outer object (package) for this object.
		** @param : Flags : The ERenameFlags to honor.
		**
		** @return : Returns TRUE if the rename was successful
		**/
		virtual UBOOL Rename( const TCHAR* InName, UObject* NewOuter, ERenameFlags Flags );

		/** Returns the default NxParameterized::Interface for this object */
		virtual void * GetNxParameterized(void);

	protected:
		/** Returns the pointer to the FIApexAsset interface */
		class FIApexAsset * GetApexGenericAsset() const { return MApexAsset; }


	private:
}

defaultproperties
{
}

