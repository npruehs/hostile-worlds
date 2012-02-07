/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Base class for generating reports from the game stats data
 */
class GameStatsReport extends Object
	abstract
	native(GameStats);

/** Basic key value pair structure for XML output */
struct native MetaKeyValuePair
{
	var init string Tag;
	var init string Key;
	var init string Value;

	structcpptext
	{
		FMetaKeyValuePair()
		{}
		FMetaKeyValuePair(EEventParm)
		{
			appMemzero(this, sizeof(FMetaKeyValuePair));
		}
		FMetaKeyValuePair(const FString& InTag) : Tag(InTag) {}
	}
};

/** Basic XML container, contains key value pairs and other sub categories */
struct native Category
{
	var init string Tag;
	var init string Header;
	var int id;
	var init array<MetaKeyValuePair> KeyValuePairs;
	var init array<Category> SubCategories;

	structcpptext
	{
		FCategory()
		{}
		FCategory(EEventParm)
		{
			appMemzero(this, sizeof(FCategory));
		}
		FCategory(const FString& InTag, const FString& InHeader) : Tag(InTag), Header(InHeader), Id(INDEX_NONE) {}
	}
};

/** Instance of the file reader */
var transient GameplayEventsReader StatsFileReader;
/** Game stats aggregator */
var transient GameStatsAggregator Aggregator;

cpptext
{
	/** Given an aggregation search key, returns all key value pairs under it */
	void GetEventKeyValuePairs(INT SearchKey, TArray<FMetaKeyValuePair>& KeyValuePairs);

	/** Output the entire report in XML */
	virtual void WriteReport(FArchive& Ar);
	/** 
	 * Write the session header information to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteSessionHeader(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the any image reference information to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteImageMetadata(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the session metadata to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteMetadata(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the game stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteGameValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the team stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteTeamValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the player stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WritePlayerValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the session header information to XML 
	 * @param Player - XML object to fill in with data
	 * @param PlayerIndex - player currently being written out
	 */	
	virtual void WritePlayerValue(FCategory& Player, INT PlayerIndex);
	/** 
	 * Write the weapon stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteWeaponValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the damage stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteDamageValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the projectile stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteProjectileValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write the pawn stats data to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WritePawnValues(FArchive& Ar, INT IndentCount);
	/** 
	 * Write anything game specific to XML 
	 * @param Ar - archive to write out
	 * @param IndentCount - number of tabs to indent this information
	 */	
	virtual void WriteGameSpecificValues(FArchive& Ar, INT IndentCount) {}

	/** @return the URL of the stats report, if supported */
	virtual FString GetReportURL() { return TEXT(""); } 
	/** @return the location of the file generated */
	virtual FString GetReportFilename(const FString& FileExt);
};

