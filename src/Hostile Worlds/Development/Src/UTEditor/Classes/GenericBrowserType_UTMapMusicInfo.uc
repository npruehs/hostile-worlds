/**
 * Generic browser type for UTMapMusicInfo
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class GenericBrowserType_UTMapMusicInfo extends GenericBrowserType
	native;

cpptext
{
	/**
	* Initialize the supported classes for this browser type.
	*/
	virtual void Init();
}

DefaultProperties
{
	Description="UT Map Music"
}
