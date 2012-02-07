/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 * This object is used as a store for all character profile information.
 */
class UTCharInfo extends Object
	config(CharInfo);

/** information about AI abilities/personality (generally map directly to UTBot properties) */
struct CustomAIData
{
	var float Tactics, StrafingAbility, Accuracy, Aggressiveness, CombatStyle, Jumpiness, ReactionTime;
	/** full path to class of bot's favorite weapon */
	var string FavoriteWeapon;

	structdefaultproperties
	{
		Aggressiveness=0.4
		CombatStyle=0.2
	}
};

/** Structure defining a pre-made character in the game. */
struct CharacterInfo
{
	/** Short unique string . */
	var string CharID;

	/** This defines which 'set' of parts we are drawing from. */
	var string FamilyID;

	/** Friendly name for character. */
	var localized string CharName;

	/** Localized description of the character. */
	var localized string Description;

	/** Preview image markup for the character. */
	var string PreviewImageMarkup;

	/** Faction to which this character belongs (e.g. IronGuard). */
	var string Faction;

	/** AI personality */
	var CustomAIData AIData;
};

/** Aray of all complete character profiles, defined in UTCustomChar.ini file. */
var() config array<CharacterInfo>		Characters;

/** Array of info for each family (eg IRNM) */
var() array< class<UTFamilyInfo> >		Families;

var() config float LOD1DisplayFactor;
var() config float LOD2DisplayFactor;
var() config float LOD3DisplayFactor;

/** Find the info class for a particular family */
static final function class<UTFamilyInfo> FindFamilyInfo(string InFamilyID)
{
	local int i;

	for( i=0; i<default.Families.Length; i++ )
	{
		if( (default.Families[i] != None) && (default.Families[i].default.FamilyID == InFamilyID) )
		{
			return default.Families[i];
		}
	}
	return None;
}

/** Return a random family from the list of all families */
static final function string GetRandomCharClassName()
{
	return "UTGame."$string(default.Families[Rand(default.Families.length - 1)].name);
}

defaultproperties
{
	Families.Add(class'UTFamilyInfo_Liandri_Male')
}
