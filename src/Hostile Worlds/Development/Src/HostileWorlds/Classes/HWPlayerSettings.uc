// ============================================================================
// HWPlayerSettings
// Encapsulates settings specified by the player, like his or her nickname or
// the scroll speed.
//
// Author:  Nick Pruehs
// Date:    2011/04/07
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWPlayerSettings extends Actor
	config(HostileWorlds);

/** The minimum movement speed of the camera, in uu/s. */
const SCROLL_SPEED_MIN = 500;

/** The maximum movement speed of the camera, in uu/s. */
const SCROLL_SPEED_MAX = 1500;

/** The nickname of the local player. */
var config string PlayerName;

/** The display resolution the user picked at the options screen. */
var config int ResolutionIndex;

/** The level of anisotropic filtering the user picked at the options screen. */
var config int AnisotropicFilteringIndex;

/** The level of anti-aliasing the user picked at the options screen. */
var config int AntiAliasingIndex;

/** Whether the user enabled full-screen mode at the options screen, or not. */
var config bool bEnableFullScreen;

/** Whether the user enabled dynamic lights at the options screen, or not. */
var config bool bDynamicLights;

/** Whether the user enabled dynamic shadows at the options screen, or not. */
var config bool bDynamicShadows;

/** Whether the user enabled the use of ambient occlusion for local reflection models at the options screen, or not. */
var config bool bAmbientOcclusion;

/** Whether the user allowed D3D10 at the options screen, or not. */
var config bool bAllowD3D10;

/** The factor all sound volumes are multiplied with. */
var config float VolumeMaster;

/** The factor the sound effects volumes are multiplied with. */
var config float VolumeSFX;

/** The factor the music volumes are multiplied with. */
var config float VolumeMusic;

/** The factor the voice volumes are multiplied with. */
var config float VolumeVoice;

/** Whether mouse scrolling is enabled or not. */
var config bool bMouseScrollEnabled;

/** The camera's movement speed (in uu/s). */
var config int ScrollSpeed;

/** Whether to always display all health bars, or the user has to press the appropiate hotkey. */
var config bool bAlwaysShowHealthBars;

DefaultProperties
{
}
