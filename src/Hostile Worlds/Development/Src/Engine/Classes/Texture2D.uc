/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class Texture2D extends Texture
	native(Texture)
	hidecategories(Object);

/**
 * A mip-map of the texture.
 */
struct native Texture2DMipMap
{
	var native UntypedBulkData_Mirror Data{FTextureMipBulkData};	
	var native int SizeX;
	var native int SizeY;

	structcpptext
	{
		/**
		 * Special serialize function passing the owning UObject along as required by FUnytpedBulkData
		 * serialization.
		 *
		 * @param	Ar		Archive to serialize with
		 * @param	Owner	UObject this structure is serialized within
		 * @param	MipIdx	Current mip being serialized
		 */
		void Serialize( FArchive& Ar, UObject* Owner, INT MipIdx );
	}
};

/** The texture's mip-map data.												*/
var native const IndirectArray_Mirror Mips{TIndirectArray<FTexture2DMipMap>};

/** Cached PVRTC compressed texture data										*/
var native const IndirectArray_Mirror CachedPVRTCMips{TIndirectArray<FTexture2DMipMap>};

/** The width of the texture.												*/
var const int SizeX;

/** The height of the texture.												*/
var const int SizeY;

/** The original width of the texture source art we imported from.			*/
var const int OriginalSizeX;

/** The original height of the texture source art we imported from.			*/
var const int OriginalSizeY;


/** The format of the texture data.											*/
var const EPixelFormat Format;

/** The addressing mode to use for the X axis.								*/
var() TextureAddress AddressX;

/** The addressing mode to use for the Y axis.								*/
var() TextureAddress AddressY;

/** Whether the texture is currently streamable or not.						*/
var transient const bool						bIsStreamable;
/** Whether the current texture mip change request is pending cancelation.	*/
var transient const bool						bHasCancelationPending;
/**
 * Whether the texture has been loaded from a persistent archive. We keep track of this in order to not stream 
 * textures that are being re-imported over as they will have a linker but won't have been serialized from disk 
 * and are therefore not streamable.
 */
var transient const bool						bHasBeenLoadedFromPersistentArchive;

/** Override whether to fully stream even if texture hasn't been rendered.	*/
var transient bool								bForceMiplevelsToBeResident;
/** Global/ serialized version of ForceMiplevelsToBeResident.				*/
var() const bool								bGlobalForceMipLevelsToBeResident;
/** WorldInfo timestamp that tells the streamer to force all miplevels to be resident up until that time. */ 
var private transient float						ForceMipLevelsToBeResidentTimestamp;

/** Name of texture file cache texture mips are stored in, NAME_None if it is not part of one. */
var		name									TextureFileCacheName;
/** ID generated whenever the texture is changed so that its bulk data can be updated in the TextureFileCache during cook */
var native const guid							TextureFileCacheGuid;

/** Number of miplevels the texture should have resident.					*/
var transient const int							RequestedMips;
/** Number of miplevels currently resident.									*/
var transient const int							ResidentMips;
/**
 * Thread safe counter indicating status of mip change request.	The below defines are mirrored in UnTex.h.
 *
 * >=  3 == TEXTURE_STATUS_REQUEST_IN_FLIGHT	- a request has been kicked off and is in flight
 * ==  2 == TEXTURE_READY_FOR_FINALIZATION		- initial request has completed and finalization needs to be kicked off
 * ==  1 == TEXTURE_FINALIZATION_IN_PROGRESS	- finalization has been kicked off and is in progress
 * ==  0 == TEXTURE_READY_FOR_REQUESTS			- there are no pending requests/ all requests have been fulfilled
 * == -1 == TEXTURE_PENDING_INITIALIZATION		- the renderer hasn't created the resource yet
 */
var native transient const ThreadSafeCounter	PendingMipChangeRequestStatus{mutable FThreadSafeCounter};

/** Data formatted only for 1 bit textures which are CPU based and never allocate GPU Memory  **/
var private{private} array<byte>				SystemMemoryData;

/**
 * Mirror helper structure for linked list of texture objects. The linked list should NOT be traversed by the
 * garbage collector, which is why Element is declared as a pointer.
 */
struct TextureLinkedListMirror
{
	var native const POINTER Element;
	var native const POINTER Next;
	var native const POINTER PrevLink;
};

/** This texture's link in the global streamable texture list. */
var private{private} native const duplicatetransient noimport TextureLinkedListMirror StreamableTexturesLink{TLinkedList<UTexture2D*>};

/** FStreamingTexture index used by the texture streaming system. */
var private{private} const transient duplicatetransient int StreamingIndex;

/** 
* Keep track of the first mip level stored in the packed miptail.
* it's set to highest mip level if no there's no packed miptail 
*/
var const int MipTailBaseIdx; 

/** memory used for directly loading bulk mip data */
var private const native transient pointer		ResourceMem{FTexture2DResourceMem};
/** keep track of first mip level used for ResourceMem creation */
var private const native transient int			FirstResourceMemMip;

/** Used for various timing measurements, e.g. streaming latency. */
var private const native transient float		Timer;

/**
 * Tells the streaming system that it should force all mip-levels to be resident for a number of seconds.
 * @param Seconds					Duration in seconds
 * @param CinematicTextureGroups	Bitfield indicating which texture groups that use extra high-resolution mips
 */
native final function							SetForceMipLevelsToBeResident( float Seconds, optional int CinematicTextureGroups = 0 );

cpptext
{
	// Static private variables.
private:
	/** First streamable texture link. Not handled by GC as BeginDestroy automatically unlinks.	*/
	static TLinkedList<UTexture2D*>* FirstStreamableLink;
	/** Current streamable texture link for iteration over textures. Not handled by GC as BeginDestroy automatically unlinks. */
	static TLinkedList<UTexture2D*>* CurrentStreamableLink;
	/** Number of streamable textures. */
	static INT NumStreamableTextures;

public:

	// UObject interface.
	void InitializeIntrinsicPropertyValues();
	virtual void Serialize(FArchive& Ar);
#if !CONSOLE
	// SetLinker is only virtual on consoles.
	virtual void SetLinker( ULinkerLoad* L, INT I );
#endif
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	 * Called after the garbage collection mark phase on unreachable objects.
	 */
	virtual void BeginDestroy();
	/**
 	 * Called after object and all its dependencies have been serialized.
	 */
	virtual void PostLoad();
	/**
 	 * Called after object has been duplicated.
	 */
	virtual void PostDuplicate();

	/** 
	 * Generates a GUID for the texture if one doesn't already exist. 
	 *
	 * @param bForceGeneration	Whether we should generate a GUID even if it is already valid.
	 */
	void GenerateTextureFileCacheGUID(UBOOL bForceGeneration=FALSE);

	// USurface interface
	virtual FLOAT GetSurfaceWidth() const { return SizeX; }
	virtual FLOAT GetSurfaceHeight() const { return SizeY; }

	/**
	 * @return Width/height this surface was before cooking or other modifications
	 */
	virtual FLOAT GetOriginalSurfaceWidth() const { return OriginalSizeX; }
	virtual FLOAT GetOriginalSurfaceHeight() const { return OriginalSizeY; }

	// UTexture interface.
	virtual FTextureResource* CreateResource();
	virtual void Compress();
	virtual EMaterialValueType GetMaterialType() { return MCT_Texture2D; }

	/**
	 * Creates a new resource for the texture, and updates any cached references to the resource.
	 */
	virtual void UpdateResource();

	/**
	 * Used by various commandlets to purge Editor only data from the object.
	 * 
	 * @param TargetPlatform Platform the object will be saved for (ie PC vs console cooking, etc)
	 */
	virtual void StripData(UE3::EPlatformType TargetPlatform);

	/**
	 *	Gets the average brightness of the texture in linear space
	 *
	 *	@param	bIgnoreTrueBlack		If TRUE, then pixels w/ 0,0,0 rgb values do not contribute.
	 *	@param	bUseGrayscale			If TRUE, use gray scale else use the max color component.
	 *
	 *	@return	FLOAT					The average brightness of the texture
	 */
	virtual FLOAT GetAverageBrightness(UBOOL bIgnoreTrueBlack, UBOOL bUseGrayscale);

	// UTexture2D interface.
	void Init(UINT InSizeX,UINT InSizeY,EPixelFormat InFormat);
	void LegacySerialize(FArchive& Ar);

	/**
	* return the texture/pixel format that should be used internally for an incoming texture load request, if different onload conversion is required 
	*
	*	@param	Format					source texture format	
	*	@param	Platform				destination platform, useful during cooking
	*/
	static EPixelFormat GetEffectivePixelFormat( const EPixelFormat Format, UBOOL bSRGB, UE3::EPlatformType Platform = UE3::PLATFORM_Unknown );

	/** 
	 * Returns a one line description of an object for viewing in the thumbnail view of the generic browser
	 */
	virtual FString GetDesc();

	/** 
	 * Returns detailed info to populate listview columns
	 */
	virtual FString GetDetailedDescription( INT InIndex );

	/**
	 * Returns the size of this texture in bytes if it had MipCount miplevels streamed in.
	 *
	 * @param	MipCount	Number of toplevel mips to calculate size for
	 * @return	size of top mipcount mips in bytes
	 */
	INT GetSize( INT MipCount ) const;

	/**
	 * Returns the size of this texture in bytes on 360 if it had MipCount miplevels streamed in.
	 *
	 * @param	MipCount	Number of toplevel mips to calculate size for
	 * @return	size of top mipcount mips in bytes
	 */
	INT Get360Size( INT MipCount ) const;

	/**
	 *	Get the CRC of the source art pixels.
	 *
	 *	@param	[out]	OutSourceCRC		The CRC value of the source art pixels.
	 *
	 *	@return			UBOOL				TRUE if successful, FALSE if failed (or no source art)
	 */
	UBOOL GetSourceArtCRC(DWORD& OutSourceCRC);

	/**
	 * Returns whether or not the texture has source art at all
	 *
	 * @return	TRUE if the texture has source art. FALSE, otherwise.
	 */
	virtual UBOOL HasSourceArt() const;

	/**
	 * Compresses the source art, if needed
	 */
	virtual void CompressSourceArt();

	/**
	 * Returns uncompressed source art.
	 *
	 * @param	OutSourceArt	[out]A buffer containing uncompressed source art.
	 */
	virtual void GetUncompressedSourceArt( TArray<BYTE>& OutSourceArt );

	/**
	 * Sets the given buffer as the uncompressed source art.
	 *
	 * @param	UncompressedData	Uncompressed source art data. 
	 * @param	DataSize			Size of the UncompressedData.
	 */
	virtual void SetUncompressedSourceArt( const void* UncompressedData, INT DataSize );
	
	/**
	 * Sets the given buffer as the compressed source art. 
	 *
	 * @param	CompressedData		Compressed source art data. 
	 * @param	DataSize			Size of the CompressedData.
	 */
	virtual void SetCompressedSourceArt( const void* CompressedData, INT DataSize );
	
	/**
	 *	See if the source art of the two textures matches...
	 *
	 *	@param		InTexture		The texture to compare it to
	 *
	 *	@return		UBOOL			TRUE if they matche, FALSE if not
	 */
	UBOOL HasSameSourceArt(UTexture2D* InTexture);
	
	UBOOL HasAlphaChannel() const 
	{
		return Format == PF_A8R8G8B8 || Format == PF_DXT3 || Format == PF_DXT5;
	}

	/**
	 * Returns if the texture should be automatically biased to -1..1 range
	 */
	UBOOL BiasNormalMap() const;

	/**
	 * Returns whether the texture is ready for streaming aka whether it has had InitRHI called on it.
	 *
	 * @return TRUE if initialized and ready for streaming, FALSE otherwise
	 */
	UBOOL IsReadyForStreaming();

	/**
	 * Waits until all streaming requests for this texture has been fully processed.
	 */
	virtual void WaitForStreaming();
	
	/**
	 * Updates the streaming status of the texture and performs finalization when appropriate. The function returns
	 * TRUE while there are pending requests in flight and updating needs to continue.
	 *
	 * @param bWaitForMipFading	Whether to wait for Mip Fading to complete before finalizing.
	 * @return					TRUE if there are requests in flight, FALSE otherwise
	 */
	virtual UBOOL UpdateStreamingStatus( UBOOL bWaitForMipFading = FALSE );

	/**
	 * Tries to cancel a pending mip change request. Requests cannot be canceled if they are in the
	 * finalization phase.
	 *
	 * @param	TRUE if cancelation was successful, FALSE otherwise
	 */
	UBOOL CancelPendingMipChangeRequest();

	/**
	 * Returns the size of the object/ resource for display to artists/ LDs in the Editor.
	 *
	 * @return size of resource as to be displayed to artists/ LDs in the Editor.
	 */
	virtual INT GetResourceSize();

	/**
	 * Returns whether miplevels should be forced resident.
	 *
	 * @return TRUE if either transient or serialized override requests miplevels to be resident, FALSE otherwise
	 */
	UBOOL ShouldMipLevelsBeForcedResident() const;

	/**
	 * Whether all miplevels of this texture have been fully streamed in, LOD settings permitting.
	 */
	UBOOL IsFullyStreamedIn();

	/**
	 * Returns a reference to the global list of streamable textures.
	 *
	 * @return reference to global list of streamable textures.
	 */
	static TLinkedList<UTexture2D*>*& GetStreamableList();

	/**
	 * Returns a reference to the current streamable link.
	 *
	 * @return reference to current streamable link
	 */
	static TLinkedList<UTexture2D*>*& GetCurrentStreamableLink();

	/**
	 * Links texture to streamable list and updates streamable texture count.
	 */
	void LinkStreaming();

	/**
	 * Unlinks texture from streamable list, resets CurrentStreamableLink if it matches
	 * StreamableTexturesLink and also updates the streamable texture count.
	 */
	void UnlinkStreaming();
	
	/**
	 * Returns the number of streamable textures, maintained by link/ unlink code
	 *
	 * @return	Number of streamable textures
	 */
	static INT GetNumStreamableTextures();

	/**
	 * Cancels any pending texture streaming actions if possible.
	 * Returns when no more async loading requests are in flight.
	 */
	static void CancelPendingTextureStreaming();

	/**
	* Initialize the GPU resource memory that will be used for the bulk mip data
	* This memory is allocated based on the SizeX,SizeY of the texture and the first mip used
	*
	* @param FirstMipIdx first mip that will be resident	
	* @return FTexture2DResourceMem container for the allocated GPU resource mem
	*/
	class FTexture2DResourceMem* InitResourceMem(INT FirstMipIdx);

#if WITH_EDITOR
	/** Recreates system memory data for textures that do not use GPU resources (1 bit textures).  Should be called when data in the top level mip changes **/
	void UpdateSystemMemoryData();
#endif

	/** Returns system memory data for read only purposes **/
	const TArray<BYTE>& AccessSystemMemoryData() const { return SystemMemoryData; }
	
	virtual UINT SumMipMemorySize(UBOOL bFullMipChain) const;

	friend struct FStreamingManagerTexture;
	friend struct FStreamingTexture;
}

/** creates and initializes a new Texture2D with the requested settings */
static native noexport final function Texture2D Create(int InSizeX, int InSizeY, optional EPixelFormat InFormat = PF_A8R8G8B8);

defaultproperties
{
	StreamingIndex=-1
}
