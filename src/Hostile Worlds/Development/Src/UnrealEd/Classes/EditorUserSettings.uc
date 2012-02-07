/**
 * This class handles hotkey binding management for the editor.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class EditorUserSettings extends Object
	hidecategories(Object)
	config(EditorUserSettings)
	native;

/** Whether to automatically save after a time interval */
var(Options) config bool bAutoSaveEnable;
/** Whether to automatically save maps during an autosave */
var(Options) config bool bAutoSaveMaps;
/** Whether to automatically save content packages during an autosave */
var(Options) config bool bAutoSaveContent;
/** The time interval after which to auto save */
var(Options) config int AutoSaveTimeMinutes;
/** True if WASD keys should be remapped to flight controls while the right mouse button is held down */
var(Options) config bool AllowFlightCameraToRemapKeys;
/** The background color for material preview thumbnails in Generic Browser  */
var(Options) config Color PreviewThumbnailBackgroundColor;
/** The background color for translucent material preview thumbnails in Generic Browser */
var(Options) config Color PreviewThumbnailTranslucentMaterialBackgroundColor;
/** Controls whether packages which are checked-out are automatically fully loaded at startup */
var(Options) config	bool bAutoloadCheckedOutPackages;
/** If this is true, the user will not be asked to fully load a package before saving or before creating a new object */
var(Options) config bool bSuppressFullyLoadPrompt;
/** True if user should be allowed to select translucent objects in perspective viewports */
var(Options) config bool bAllowSelectTranslucent;
/** True if Play In Editor should only load currently-visible levels in PIE */
var(Options) config bool bOnlyLoadVisibleLevelsInPIE;
/** True if ortho-viewport box selection requires objects to be fully encompassed by the selection box to be selected */
var(Options) config bool bStrictBoxSelection;
/** Whether to automatically prompt for SCC checkout on package modification */
var(Options) config bool bPromptForCheckoutOnPackageModification;
/** If true audio will be enabled in the editor. Does not affect PIE **/
var(Options) config bool bEnableRealTimeAudio;
/** Global volume setting for the editor */
var(Options) config float EditorVolumeLevel;

/** True if we should move actors to their appropriate grid volume levels immediately after most operations */
var(Options) config bool bUpdateActorsInGridLevelsImmediately;

/** True if we should automatically restart playback Flash Movies that are reimported in the editor */
var(Options) config bool bAutoRestartReimportedFlashMovies;

/** True if we should automatically reimport textures when a change to source content is detected*/
var(Options) config bool bAutoReimportTextures;