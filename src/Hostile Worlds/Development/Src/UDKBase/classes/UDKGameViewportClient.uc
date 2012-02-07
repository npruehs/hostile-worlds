/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UDKGameViewportClient extends GameViewportClient
	native
	config(Game);

/** Name of localized files containing hints */
var string HintLocFileName;

/**
 * Locates a random localized hint message string for the specified two categories.  
 * See UTGameViewportClient implementation, and UTGameUI.int for an example of use.
 * In the localization file, the section will be LoadingHints_CategoryName
 * For each category section, Hint_Count must be specified
 * Each hit message should be prefixed by Hint_, followed by the index of that hint
 *
 * @param Category1Name Name of the first hint category we're interested in
 * @param Category2Name Name of the second hint category we're interested in
 *
 * @return Returns random hint string for the specified game types
 */
native final function string LoadRandomLocalizedHintMessage( string Category1Name, string Category2Name );

