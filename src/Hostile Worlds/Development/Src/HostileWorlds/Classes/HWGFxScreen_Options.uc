// ============================================================================
// HWGFxScreen_Options
// The Options screen of Hostile Worlds. Allows changing player-specific
// settings like the scroll speed.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_options.fla
//
// Author:  Nick Pruehs
// Date:    2011/04/07
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_Options extends HWGFxScreen;

/** The number of steps of the scroll speed slider. */
const SCROLL_SPEED_SNAP_INTERVALS = 20;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelGraphics;
var GFxObject LabelGraphicsNote;
var GFxObject LabelGraphicsDisplayedSettings;
var GFxObject LabelResolution;
var GFxObject LabelAnisotropicFiltering;
var GFxObject LabelAntiAliasing;
var GFxClikWidget DropdownResolution;
var GFxClikWidget DropdownAnisotropicFiltering;
var GFxClikWidget DropdownAntiAliasing;
var GFxClikWidget CheckboxFullScreen;
var GFxClikWidget CheckboxDynamicLights;
var GFxClikWidget CheckboxDynamicShadows;
var GFxClikWidget CheckboxAmbientOcclusion;
var GFxClikWidget CheckboxD3D10;

var GFxObject LabelSound;
var GFxObject LabelVolumeMaster;
var GFxObject LabelVolumeSFX;
var GFxObject LabelVolumeMusic;
var GFxObject LabelVolumeVoice;
var GFxObject LabelVolumeMasterCurrent;
var GFxObject LabelVolumeSFXCurrent;
var GFxObject LabelVolumeMusicCurrent;
var GFxObject LabelVolumeVoiceCurrent;
var GFxClikWidget SliderVolumeMaster;
var GFxClikWidget SliderVolumeSFX;
var GFxClikWidget SliderVolumeMusic;
var GFxClikWidget SliderVolumeVoice;

var GFxObject LabelInput;
var GFxObject LabelScrollSpeed;
var GFxObject LabelScrollSpeedCurrent;
var GFxClikWidget CheckboxMouseScrolling;
var GFxClikWidget SliderScrollSpeed;

var GFxObject LabelGameplay;
var GFxClikWidget CheckboxShowHealthBars;

var GFxClikWidget BtnSaveChanges;
var GFxClikWidget BtnDiscardChanges;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextGraphics;
var localized string LabelTextGraphicsNote;
var localized string LabelTextGraphicsDisplayedSettings;
var localized string LabelTextResolution;
var localized string LabelTextAnisotropicFiltering;
var localized string LabelTextAntiAliasing;
var localized string CheckboxTextFullScreen;
var localized string CheckboxTextDynamicLights;
var localized string CheckboxTextDynamicShadows;
var localized string CheckboxTextAmbientOcclusion;
var localized string CheckboxTextD3D10;

var localized string LabelTextSound;
var localized string LabelTextVolumeMaster;
var localized string LabelTextVolumeSFX;
var localized string LabelTextVolumeMusic;
var localized string LabelTextVolumeVoice;

var localized string LabelTextInput;
var localized string LabelTextScrollSpeed;
var localized string CheckboxTextMouseScrolling;

var localized string LabelTextGameplay;
var localized string CheckboxTextShowHealthBars;

var localized string BtnTextSaveChanges;
var localized string BtnTextDiscardChanges;

// ----------------------------------------------------------------------------
// Description texts.

var localized string DescriptionResolution;
var localized string DescriptionAnisotropicFiltering;
var localized string DescriptionAntiAliasing;
var localized string DescriptionFullScreen;
var localized string DescriptionDynamicLights;
var localized string DescriptionDynamicShadows;
var localized string DescriptionAmbientOcclusion;
var localized string DescriptionD3D10;

var localized string DescriptionMouseScrolling;
var localized string DescriptionScrollSpeed;

var localized string DescriptionShowHealthBars;

var localized string DescriptionSaveChanges;
var localized string DescriptionDiscardChanges;

// ----------------------------------------------------------------------------
// Dialog texts.

var localized string DialogTitleAntiAliasingChanged;
var localized string DialogMessageAntiAliasingChanged;
var localized string DialogTitleGraphicsSettingsChanged;
var localized string DialogMessageGraphicsSettingsChanged;
var localized string DialogMessageDiscardChanges;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local array<string> Resolutions;
	local array<string> AnisotropicFilteringLevels;
	local array<string> AntiAliasingLevels;

	local float VolumeMaster;
	local float VolumeSFX;
	local float VolumeMusic;
	local float VolumeVoice;

	local bool bMouseScrollingEnabled;
	local int ScrollSpeed;
	local float ScrollSpeedMin;
	local float ScrollSpeedMax;
	local float ScrollSpeedCurrent;
	local float ScrollSpeedSnapInterval;

	local bool bAlwaysShowHealthBars;

    switch (WidgetName)
    {
        case ('labelGraphics'): 
            if (LabelGraphics == none)
            {
				LabelGraphics = InitLabel(Widget, WidgetName, LabelTextGraphics);
				return true;
            }
            break;

        case ('labelGraphicsNote'): 
            if (LabelGraphicsNote == none)
            {
				LabelGraphicsNote = InitLabel(Widget, WidgetName, LabelTextGraphicsNote);
				return true;
            }
            break;

        case ('labelGraphicsDisplayedSettings'): 
            if (LabelGraphicsDisplayedSettings == none)
            {
				LabelGraphicsDisplayedSettings = InitLabel(Widget, WidgetName, LabelTextGraphicsDisplayedSettings);
				return true;
            }
            break;


        case ('labelResolution'): 
            if (LabelResolution == none)
            {
				LabelResolution = InitLabel(Widget, WidgetName, LabelTextResolution);
				return true;
            }
            break;

        case ('labelAnisotropicFiltering'): 
            if (LabelAnisotropicFiltering == none)
            {
				LabelAnisotropicFiltering = InitLabel(Widget, WidgetName, LabelTextAnisotropicFiltering);
				return true;
            }
            break;

        case ('labelAntiAliasing'): 
            if (LabelAntiAliasing == none)
            {
				LabelAntiAliasing = InitLabel(Widget, WidgetName, LabelTextAntiAliasing);
				return true;
            }
            break;

		case ('dropdownResolution'):
			if (DropdownResolution == none)
			{
				Resolutions.AddItem("1280 x 800 x 16");
				Resolutions.AddItem("1280 x 800 x 32");
				Resolutions.AddItem("1280 x 960 x 16");
				Resolutions.AddItem("1280 x 960 x 32");
				Resolutions.AddItem("1440 x 900 x 16");
				Resolutions.AddItem("1440 x 900 x 32");
				Resolutions.AddItem("1600 x 900 x 16");
				Resolutions.AddItem("1600 x 900 x 32");
				Resolutions.AddItem("1600 x 1200 x 16");
				Resolutions.AddItem("1600 x 1200 x 32");
				Resolutions.AddItem("1680 x 1050 x 16");
				Resolutions.AddItem("1680 x 1050 x 32");
				Resolutions.AddItem("1920 x 1080 x 16");
				Resolutions.AddItem("1920 x 1080 x 32");
				Resolutions.AddItem("1920 x 1200 x 16");
				Resolutions.AddItem("1920 x 1200 x 32");

				DropdownResolution = InitDropdown(Widget, WidgetName, Resolutions, OnDropdownSelectResolution, OnDropdownRollOverResolution);
				return true;
			}
			break;

		case ('dropdownAnisotropicFiltering'):
			if (DropdownAnisotropicFiltering == none)
			{
				AnisotropicFilteringLevels.AddItem("1x");
				AnisotropicFilteringLevels.AddItem("2x");
				AnisotropicFilteringLevels.AddItem("4x");
				AnisotropicFilteringLevels.AddItem("8x");
				AnisotropicFilteringLevels.AddItem("16x");

				DropdownAnisotropicFiltering = InitDropdown(Widget, WidgetName, AnisotropicFilteringLevels, OnDropdownSelectAnisotropicFiltering, OnDropdownRollOverAnisotropicFiltering);
				return true;
			}

			break;

		case ('dropdownAntiAliasing'):
			if (DropdownAntiAliasing == none)
			{
				AntiAliasingLevels.AddItem("1x");
				AntiAliasingLevels.AddItem("2x");
				AntiAliasingLevels.AddItem("4x");
				AntiAliasingLevels.AddItem("8x");
				AntiAliasingLevels.AddItem("16x");

				DropdownAntiAliasing = InitDropdown(Widget, WidgetName, AntiAliasingLevels, OnDropdownSelectAntiAliasing, OnDropdownRollOverAntiAliasing);
				return true;
			}

			break;

		case ('checkboxFullScreen'):
			if (CheckboxFullScreen == none)
			{
				CheckboxFullScreen = InitCheckBox(Widget, WidgetName, CheckboxTextFullScreen, false, OnCheckboxRollOverFullScreen);
				return true;
			}
			break;

		case ('checkboxDynamicLights'):
			if (CheckboxDynamicLights == none)
			{
				CheckboxDynamicLights = InitCheckBox(Widget, WidgetName, CheckboxTextDynamicLights, false, OnCheckboxRollOverDynamicLights);
				return true;
			}
			break;

		case ('checkboxDynamicShadows'):
			if (CheckboxDynamicShadows == none)
			{
				CheckboxDynamicShadows = InitCheckBox(Widget, WidgetName, CheckboxTextDynamicShadows, false, OnCheckboxRollOverDynamicShadows);
				return true;
			}
			break;

		case ('checkboxAmbientOcclusion'):
			if (CheckboxAmbientOcclusion == none)
			{
				CheckboxAmbientOcclusion = InitCheckBox(Widget, WidgetName, CheckboxTextAmbientOcclusion, false, OnCheckboxRollOverAmbientOcclusion);
				return true;
			}
			break;

		case ('checkboxD3D10'):
			if (CheckboxD3D10 == none)
			{
				CheckboxD3D10 = InitCheckBox(Widget, WidgetName, CheckboxTextD3D10, false, OnCheckboxRollOverD3D10);
				return true;
			}
			break;

        case ('labelSound'): 
            if (LabelSound == none)
            {
				LabelSound = InitLabel(Widget, WidgetName, LabelTextSound);
				return true;
            }
            break;

        case ('labelVolumeMaster'): 
            if (LabelVolumeMaster == none)
            {
				LabelVolumeMaster = InitLabel(Widget, WidgetName, LabelTextVolumeMaster);
				return true;
            }
            break;

        case ('labelVolumeSFX'): 
            if (LabelVolumeSFX == none)
            {
				LabelVolumeSFX = InitLabel(Widget, WidgetName, LabelTextVolumeSFX);
				return true;
            }
            break;

        case ('labelVolumeMusic'): 
            if (LabelVolumeMusic == none)
            {
				LabelVolumeMusic = InitLabel(Widget, WidgetName, LabelTextVolumeMusic);
				return true;
            }
            break;

        case ('labelVolumeVoice'): 
            if (LabelVolumeVoice == none)
            {
				LabelVolumeVoice = InitLabel(Widget, WidgetName, LabelTextVolumeVoice);
				return true;
            }
            break;

        case ('labelVolumeMasterCurrent'): 
            if (LabelVolumeMasterCurrent == none)
            {
				VolumeMaster = HWPlayerController(GetPC()).GetPlayerSettings().VolumeMaster;

				LabelVolumeMasterCurrent = InitLabel(Widget, WidgetName, VolumeMaster);
				return true;
            }
            break;

        case ('labelVolumeSFXCurrent'): 
            if (LabelVolumeSFXCurrent == none)
            {
				VolumeSFX = HWPlayerController(GetPC()).GetPlayerSettings().VolumeSFX;

				LabelVolumeSFXCurrent = InitLabel(Widget, WidgetName, VolumeSFX);
				return true;
            }
            break;

        case ('labelVolumeMusicCurrent'): 
            if (LabelVolumeMusicCurrent == none)
            {
				VolumeMusic = HWPlayerController(GetPC()).GetPlayerSettings().VolumeMusic;

				LabelVolumeMusicCurrent = InitLabel(Widget, WidgetName, VolumeMusic);
				return true;
            }
            break;

        case ('labelVolumeVoiceCurrent'): 
            if (LabelVolumeVoiceCurrent == none)
            {
				VolumeVoice = HWPlayerController(GetPC()).GetPlayerSettings().VolumeVoice;

				LabelVolumeVoiceCurrent = InitLabel(Widget, WidgetName, VolumeVoice);
				return true;
            }
            break;

		case ('sliderVolumeMaster'):
			if (SliderVolumeMaster == none)
			{
				VolumeMaster = HWPlayerController(GetPC()).GetPlayerSettings().VolumeMaster;

				SliderVolumeMaster = InitSlider(Widget, WidgetName, 0, 100, VolumeMaster, OnSliderChangeVolumeMaster, 1);
				return true;
			}
			break;

		case ('sliderVolumeSFX'):
			if (SliderVolumeSFX == none)
			{
				VolumeSFX = HWPlayerController(GetPC()).GetPlayerSettings().VolumeSFX;

				SliderVolumeSFX = InitSlider(Widget, WidgetName, 0, 100, VolumeSFX, OnSliderChangeVolumeSFX, 1);
				return true;
			}
			break;

		case ('sliderVolumeMusic'):
			if (SliderVolumeMusic == none)
			{
				VolumeMusic = HWPlayerController(GetPC()).GetPlayerSettings().VolumeMusic;

				SliderVolumeMusic = InitSlider(Widget, WidgetName, 0, 100, VolumeMusic, OnSliderChangeVolumeMusic, 1);
				return true;
			}
			break;

		case ('sliderVolumeVoice'):
			if (SliderVolumeVoice == none)
			{
				VolumeVoice = HWPlayerController(GetPC()).GetPlayerSettings().VolumeVoice;

				SliderVolumeVoice = InitSlider(Widget, WidgetName, 0, 100, VolumeVoice, OnSliderChangeVolumeVoice, 1);
				return true;
			}
			break;

        case ('labelInput'): 
            if (LabelInput == none)
            {
				LabelInput = InitLabel(Widget, WidgetName, LabelTextInput);
				return true;
            }
            break;

        case ('labelScrollSpeed'): 
            if (LabelScrollSpeed == none)
            {
				LabelScrollSpeed = InitLabel(Widget, WidgetName, LabelTextScrollSpeed);
				return true;
            }
            break;

        case ('labelScrollSpeedCurrent'): 
            if (LabelScrollSpeedCurrent == none)
            {
				ScrollSpeed =  HWPlayerController(GetPC()).GetPlayerSettings().ScrollSpeed;

				LabelScrollSpeedCurrent = InitLabel(Widget, WidgetName, ScrollSpeed);
				return true;
            }
            break;

		case ('checkboxMouseScrolling'):
			if (CheckboxMouseScrolling == none)
			{
				bMouseScrollingEnabled = HWPlayerController(GetPC()).GetPlayerSettings().bMouseScrollEnabled;

				CheckboxMouseScrolling = InitCheckBox(Widget, WidgetName, CheckboxTextMouseScrolling, bMouseScrollingEnabled, OnCheckboxRollOverMouseScrolling);
				return true;
			}
			break;

		case ('sliderScrollSpeed'):
			if (SliderScrollSpeed == none)
			{
				ScrollSpeedMin = class'HWPlayerSettings'.const.SCROLL_SPEED_MIN;
				ScrollSpeedMax = class'HWPlayerSettings'.const.SCROLL_SPEED_MAX;
				ScrollSpeedCurrent = HWPlayerController(GetPC()).GetPlayerSettings().ScrollSpeed;
				ScrollSpeedSnapInterval = (ScrollSpeedMax - ScrollSpeedMin) / SCROLL_SPEED_SNAP_INTERVALS;

				SliderScrollSpeed = InitSlider(Widget, WidgetName, ScrollSpeedMin, ScrollSpeedMax, ScrollSpeedCurrent, OnSliderChangeScrollSpeed, ScrollSpeedSnapInterval);
				return true;
			}
			break;

		case ('labelGameplay'): 
            if (LabelGameplay == none)
            {
				LabelGameplay = InitLabel(Widget, WidgetName, LabelTextGameplay);
				return true;
            }
            break;

		case ('checkboxShowHealthBars'):
			if (CheckboxShowHealthBars == none)
			{
				bAlwaysShowHealthBars =  HWPlayerController(GetPC()).GetPlayerSettings().bAlwaysShowHealthBars;

				CheckboxShowHealthBars = InitCheckBox(Widget, WidgetName, CheckboxTextShowHealthBars, bAlwaysShowHealthBars, OnCheckboxRollOverShowHealthBars);
				return true;
			}
			break;

		case ('btnSaveChanges'):
			if (BtnSaveChanges == none)
			{
				BtnSaveChanges = InitButton(Widget, WidgetName, BtnTextSaveChanges, OnButtonPressSaveChanges, OnButtonRollOverSaveChanges);
				return true;
			}
            break;

		case ('btnDiscardChanges'):
			if (BtnDiscardChanges == none)
			{
				BtnDiscardChanges = InitButton(Widget, WidgetName, BtnTextDiscardChanges, OnButtonPressDiscardChanges, OnButtonRollOverDiscardChanges);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function ShowView()
{
	local HWPlayerSettings PlayerSettings;

	super.ShowView();

	// read config values
	PlayerSettings = HWPlayerController(GetPC()).GetPlayerSettings();

	DropdownResolution.SetFloat("selectedIndex", PlayerSettings.ResolutionIndex);
	DropdownAnisotropicFiltering.SetFloat("selectedIndex", PlayerSettings.AnisotropicFilteringIndex);
	DropdownAntiAliasing.SetFloat("selectedIndex", PlayerSettings.AntiAliasingIndex);
	CheckboxFullScreen.SetBool("selected", PlayerSettings.bEnableFullScreen);
	CheckboxDynamicLights.SetBool("selected", PlayerSettings.bDynamicLights);
	CheckboxDynamicShadows.SetBool("selected", PlayerSettings.bDynamicShadows);
	CheckboxAmbientOcclusion.SetBool("selected", PlayerSettings.bAmbientOcclusion);
	CheckboxD3D10.SetBool("selected", PlayerSettings.bAllowD3D10);

	LabelVolumeMasterCurrent.SetText(PlayerSettings.VolumeMaster);
	LabelVolumeSFXCurrent.SetText(PlayerSettings.VolumeSFX);
	LabelVolumeMusicCurrent.SetText(PlayerSettings.VolumeMusic);
	LabelVolumeVoiceCurrent.SetText(PlayerSettings.VolumeVoice);
	SliderVolumeMaster.SetFloat("value", PlayerSettings.VolumeMaster);
	SliderVolumeSFX.SetFloat("value", PlayerSettings.VolumeSFX);
	SliderVolumeMusic.SetFloat("value", PlayerSettings.VolumeMusic);
	SliderVolumeVoice.SetFloat("value", PlayerSettings.VolumeVoice);

	CheckboxMouseScrolling.SetBool("selected", PlayerSettings.bMouseScrollEnabled);
	LabelScrollSpeedCurrent.SetText(PlayerSettings.ScrollSpeed);
	SliderScrollSpeed.SetFloat("value", PlayerSettings.ScrollSpeed);

	CheckboxShowHealthBars.SetBool("selected", PlayerSettings.bAlwaysShowHealthBars);
}

/** Sets the screen resolution, color depth and display mode to the ones specified by the user. */
function ChangeResolution()
{
	local string DisplayMode;

	DisplayMode = CheckboxFullScreen.GetBool("selected") ? "f" : "w";

	switch (DropdownResolution.GetFloat("selectedIndex"))
	{
		case 0:
			ConsoleCommand("SETRES 1280x800x16"$DisplayMode);
			break;
		case 1:
			ConsoleCommand("SETRES 1280x800x32"$DisplayMode);
			break;
		case 2:
			ConsoleCommand("SETRES 1280x960x16"$DisplayMode);
			break;
		case 3:
			ConsoleCommand("SETRES 1280x960x32"$DisplayMode);
			break;
		case 4:
			ConsoleCommand("SETRES 1440x900x16"$DisplayMode);
			break;
		case 5:
			ConsoleCommand("SETRES 1440x900x32"$DisplayMode);
			break;
		case 6:
			ConsoleCommand("SETRES 1600x900x16"$DisplayMode);
			break;
		case 7:
			ConsoleCommand("SETRES 1600x900x32"$DisplayMode);
			break;
		case 8:
			ConsoleCommand("SETRES 1600x1200x16"$DisplayMode);
			break;
		case 9:
			ConsoleCommand("SETRES 1600x1200x32"$DisplayMode);
			break;
		case 10:
			ConsoleCommand("SETRES 1680x1050x16"$DisplayMode);
			break;
		case 11:
			ConsoleCommand("SETRES 1680x1050x32"$DisplayMode);
			break;
		case 12:
			ConsoleCommand("SETRES 1920x1080x16"$DisplayMode);
			break;
		case 13:
			ConsoleCommand("SETRES 1920x1080x32"$DisplayMode);
			break;
		case 14:
			ConsoleCommand("SETRES 1920x1200x16"$DisplayMode);
			break;
		case 15:
			ConsoleCommand("SETRES 1920x1200x32"$DisplayMode);
			break;
	}
}

/** Sets the level of anisotropic filtering to the one specified by the user. */
function ChangeAnisotropicFiltering()
{
	switch (DropdownAnisotropicFiltering.GetFloat("selectedIndex"))
	{
		case 0:
			ConsoleCommand("SCALE SET MaxAnisotropy 1");
			break;
		case 1:
			ConsoleCommand("SCALE SET MaxAnisotropy 2");
			break;
		case 2:
			ConsoleCommand("SCALE SET MaxAnisotropy 4");
			break;
		case 3:
			ConsoleCommand("SCALE SET MaxAnisotropy 8");
			break;
		case 4:
			ConsoleCommand("SCALE SET MaxAnisotropy 16");
			break;
	}
}

/** Sets the level of anti-aliasing to the one specified by the user. */
function ChangeAntiAliasing()
{
	switch (DropdownAntiAliasing.GetFloat("selectedIndex"))
	{
		case 0:
			ConsoleCommand("SCALE SET MaxMultiSamples 1");
			break;
		case 1:
			ConsoleCommand("SCALE SET MaxMultiSamples 2");
			break;
		case 2:
			ConsoleCommand("SCALE SET MaxMultiSamples 4");
			break;
		case 3:
			ConsoleCommand("SCALE SET MaxMultiSamples 8");
			break;
		case 4:
			ConsoleCommand("SCALE SET MaxMultiSamples 16");
			break;
	}

	if (CheckboxD3D10.GetBool("selected"))
	{
		ConsoleCommand("SCALE SET AllowD3D10 True");
	}
	else
	{
		ConsoleCommand("SCALE SET AllowD3D10 False");
	}
}

/** Enables or disables dynamic lights and dynamic shadows as specified by the user. */
function ChangeLightsAndShadows()
{
	if (CheckboxDynamicLights.GetBool("selected"))
	{
		ConsoleCommand("SCALE SET DynamicLights True");
	}
	else
	{
		ConsoleCommand("SCALE SET DynamicLights False");
	}

	if (CheckboxDynamicShadows.GetBool("selected"))
	{
		ConsoleCommand("SCALE SET DynamicShadows True");
	}
	else
	{
		ConsoleCommand("SCALE SET DynamicShadows False");
	}
}

/** Enables or disables the use of ambient occlusion for local reflection models. */
function ChangeAmbientOcclusion()
{
	if (CheckboxAmbientOcclusion.GetBool("selected"))
	{
		ConsoleCommand("SCALE SET AmbientOcclusion True");
	}
	else
	{
		ConsoleCommand("SCALE SET AmbientOcclusion False");
	}
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressSaveChanges(GFxClikWidget.EventData ev)
{
	FrontEnd.SpawnDialogInformation(DialogTitleGraphicsSettingsChanged, DialogMessageGraphicsSettingsChanged, OnDialogYesSaveChanges);
}

function OnButtonPressDiscardChanges(GFxClikWidget.EventData ev)
{
	FrontEnd.SpawnDialogWarning(DialogMessageDiscardChanges,  OnDialogYesDiscardChanges);
}

// ----------------------------------------------------------------------------
// OnRollOver events.

function OnDropdownRollOverResolution(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionResolution);
}

function OnDropdownRollOverAnisotropicFiltering(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionAnisotropicFiltering);
}

function OnDropdownRollOverAntiAliasing(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionAntiAliasing);
}

function OnCheckboxRollOverFullScreen(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionFullScreen);
}

function OnCheckboxRollOverDynamicLights(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionDynamicLights);
}

function OnCheckboxRollOverDynamicShadows(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionDynamicShadows);
}

function OnCheckboxRollOverAmbientOcclusion(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionAmbientOcclusion);
}

function OnCheckboxRollOverD3D10(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionD3D10);
}

function OnCheckboxRollOverMouseScrolling(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionMouseScrolling);
}

function OnCheckboxRollOverShowHealthBars(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionShowHealthBars);
}

function OnButtonRollOverSaveChanges(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionSaveChanges);
}

function OnButtonRollOverDiscardChanges(GFxClikWidget.EventData ev)
{
	FrontEnd.SetInfo(DescriptionDiscardChanges);
}

// ----------------------------------------------------------------------------
// Dropdown OnSelect events.

function OnDropdownSelectResolution(GFxClikWidget.EventData ev);
function OnDropdownSelectAnisotropicFiltering(GFxClikWidget.EventData ev);

function OnDropdownSelectAntiAliasing(GFxClikWidget.EventData ev)
{
	if (!DropdownAntiAliasing.GetBool("isOpen"))
	{
		// HACK prevent mouse scrolling checkbox from responding to dialog button onClick
		CheckboxMouseScrolling.SetBool("selected", !CheckboxMouseScrolling.GetBool("selected"));

		FrontEnd.SpawnDialogInformation(DialogTitleAntiAliasingChanged, DialogMessageAntiAliasingChanged);
	}
}

// ----------------------------------------------------------------------------
// Slider OnChange events.

function OnSliderChangeScrollSpeed(GFxClikWidget.EventData ev)
{
	LabelScrollSpeedCurrent.SetText(SliderScrollSpeed.GetFloat("value"));
}

function OnSliderChangeVolumeMaster(GFxClikWidget.EventData ev)
{
	LabelVolumeMasterCurrent.SetText(SliderVolumeMaster.GetFloat("value"));
}

function OnSliderChangeVolumeSFX(GFxClikWidget.EventData ev)
{
	LabelVolumeSFXCurrent.SetText(SliderVolumeSFX.GetFloat("value"));
}

function OnSliderChangeVolumeMusic(GFxClikWidget.EventData ev)
{
	LabelVolumeMusicCurrent.SetText(SliderVolumeMusic.GetFloat("value"));
}

function OnSliderChangeVolumeVoice(GFxClikWidget.EventData ev)
{
	LabelVolumeVoiceCurrent.SetText(SliderVolumeVoice.GetFloat("value"));
}

// ----------------------------------------------------------------------------
// Dialog events.

function OnDialogYesSaveChanges()
{
	local HWPlayerSettings PlayerSettings;

	// save settings
	PlayerSettings = HWPlayerController(GetPC()).GetPlayerSettings();

	PlayerSettings.ResolutionIndex = DropdownResolution.GetFloat("selectedIndex");
	PlayerSettings.AnisotropicFilteringIndex = DropdownAnisotropicFiltering.GetFloat("selectedIndex");
	PlayerSettings.AntiAliasingIndex= DropdownAntiAliasing.GetFloat("selectedIndex");
	PlayerSettings.bEnableFullScreen = CheckboxFullScreen.GetBool("selected");
	PlayerSettings.bDynamicLights = CheckboxDynamicLights.GetBool("selected");
	PlayerSettings.bDynamicShadows = CheckboxDynamicShadows.GetBool("selected");
	PlayerSettings.bAmbientOcclusion = CheckboxAmbientOcclusion.GetBool("selected");
	PlayerSettings.bAllowD3D10 = CheckboxD3D10.GetBool("selected");

	PlayerSettings.VolumeMaster = SliderVolumeMaster.GetFloat("value");
	PlayerSettings.VolumeSFX = SliderVolumeSFX.GetFloat("value");
	PlayerSettings.VolumeMusic = SliderVolumeMusic.GetFloat("value");
	PlayerSettings.VolumeVoice = SliderVolumeVoice.GetFloat("value");

	PlayerSettings.bMouseScrollEnabled = CheckboxMouseScrolling.GetBool("selected");
	PlayerSettings.ScrollSpeed = Round(SliderScrollSpeed.GetFloat("value"));

	PlayerSettings.bAlwaysShowHealthBars = CheckboxShowHealthBars.GetBool("selected");

	PlayerSettings.SaveConfig();

	// change settings
	ChangeResolution();
	ChangeAnisotropicFiltering();
	ChangeAntiAliasing();
	ChangeLightsAndShadows();
	ChangeAmbientOcclusion();

	HWPlayerController(GetPC()).ClientSetSoundVolume();

	// return to main menu
	FrontEnd.SwitchToScreenMainMenu();
}

function OnDialogYesDiscardChanges()
{
	 FrontEnd.SwitchToScreenMainMenu();
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_options'

	WidgetBindings.Add((WidgetName="labelGraphics",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelGraphicsNote",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelGraphicsDisplayedSettings",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelResolution",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelAnisotropicFiltering",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelAntiAliasing",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="dropdownResolution",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="dropdownAnisotropicFiltering",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="dropdownAntiAliasing",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="checkboxFullScreen",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="checkboxDynamicLights",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="checkboxDynamicShadows",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="checkboxAmbientOcclusion",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="checkboxD3D10",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="labelSound",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeMaster",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeSFX",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeMusic",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeVoice",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeMasterCurrent",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeSFXCurrent",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeMusicCurrent",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelVolumeVoiceCurrent",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="sliderVolumeMaster",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="sliderVolumeSFX",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="sliderVolumeMusic",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="sliderVolumeVoice",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="labelInput",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelScrollSpeed",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelScrollSpeedCurrent",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="checkboxMouseScrolling",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="sliderScrollSpeed",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="labelGameplay",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="checkboxShowHealthBars",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSaveChanges",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnDiscardChanges",WidgetClass=class'GFxClikWidget'))
}
