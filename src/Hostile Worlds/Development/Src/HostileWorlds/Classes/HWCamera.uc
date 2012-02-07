// ============================================================================
// HWCamera
// The scrollable RTS camera of Hostile Worlds.
//
// Author:  Marcel Koehler
// Date:    2010/08/31
//
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================

class HWCamera extends Camera
	config(HostileWorlds);

/** The maximum distance of the camera from the terrain. */
const MAX_FREE_CAM_DISTANCE = 1000.0f;

/** The pitch angle of this camera. */
var config float CamRotPitch;

/** The roll angle of this camera. */
var config float CamRotRoll;

/** The yaw angle of this camera. */
var config float CamRotYaw;

/** The camera's yaw rotation speed (in degree/s). */
var config float CamRotYawSpeed;

/** The amount the camera distance from the terrain is increased or decreased by every time the user scrolls the mouse wheel. */
var config float CamZoomSpeed;

/** Whether this camera is currently being scrolled left with the mouse. */
var bool bMouseScrollingLeft;

/** Whether this camera is currently being scrolled right with the mouse. */
var bool bMouseScrollingRight;

/** Whether this camera is currently being scrolled up with the mouse. */
var bool bMouseScrollingUp;

/** Whether this camera is currently being scrolled down with the mouse. */
var bool bMouseScrollingDown;

/** Whether this camera is currently being scrolled left using the keyboard. */
var bool bKeyScrollingLeft;

/** Whether this camera is currently being scrolled right using the keyboard. */
var bool bKeyScrollingRight;

/** Whether this camera is currently being scrolled up using the keyboard. */
var bool bKeyScrollingUp;

/** Whether this camera is currently being scrolled down using the keyboard. */
var bool bKeyScrollingDown;

/** Whether this camera currently may be scrolled, or not. */
var bool bScrollingAllowed;

/** This value indicates the sign of the camera's yaw rotation (set to -1, 1 or 0 (no rotation)). */
var int CamRotYawModifier;

/** The maximum distance from the player camera for units to be culled (be visible), in UU. */
var config float CullDistance;


/** Makes this camera start scrolling left using the keyboard. */
function KeyScrollLeft()
{
	// Prevent left scroll if already doing right scroll
	if(!bKeyScrollingRight)
	{
		bKeyScrollingLeft = true;
	}
}

/** Makes this camera start scrolling right using the keyboard. */
function KeyScrollRight()
{
	// Prevent right scroll if already doing left scroll
	if(!bKeyScrollingLeft)
	{
		bKeyScrollingRight = true;
	}
}

/** Makes this camera start scrolling up using the keyboard. */
function KeyScrollUp()
{
	// Prevent up scroll if already doing down scroll
	if(!bKeyScrollingDown)
	{
		bKeyScrollingUp = true;
	}
}

/** Makes this camera start scrolling down using the keyboard. */
function KeyScrollDown()
{
	// Prevent down scroll if already doing up scroll
	if(!bKeyScrollingUp)
	{
		bKeyScrollingDown = true;
	}
}

/** Makes this camera stop scrolling left using the keyboard. */
function KeyScrollLeftStop()
{
	bKeyScrollingLeft = false;
}

/** Makes this camera stop scrolling right using the keyboard. */
function KeyScrollRightStop()
{
	bKeyScrollingRight = false;
}

/** Makes this camera stop scrolling up using the keyboard. */
function KeyScrollUpStop()
{
	bKeyScrollingUp = false;
}

/** Makes this camera stop scrolling down using the keyboard. */
function KeyScrollDownStop()
{	
	bKeyScrollingDown = false;
}

/** Makes this camera start scrolling left with the mouse. */
function MouseScrollLeft()
{
	bMouseScrollingLeft = true;
}

/** Makes this camera start scrolling right with the mouse. */
function MouseScrollRight()
{
	bMouseScrollingRight = true;
}

/** Makes this camera start scrolling up with the mouse. */
function MouseScrollUp()
{
	bMouseScrollingUp = true;
}

/** Makes this camera start scrolling down with the mouse. */
function MouseScrollDown()
{
	bMouseScrollingDown = true;
}

/** Makes this camera stop scrolling left with the mouse. */
function MouseScrollLeftStop()
{
	bMouseScrollingLeft = false;
}

/** Makes this camera stop scrolling right with the mouse. */
function MouseScrollRightStop()
{
	bMouseScrollingRight = false;
}

/** Makes this camera stop scrolling up with the mouse. */
function MouseScrollUpStop()
{
	bMouseScrollingUp = false;
}

/** Makes this camera stop scrolling down with the mouse. */
function MouseScrollDownStop()
{	
	bMouseScrollingDown = false;
}

/** Allows this camera to scroll. */
function AllowScrolling()
{
	bScrollingAllowed = true;
}

/** Forbids this camera to scroll until AllowScrolling() is called again. */
function ProhibitScrolling()
{
	bScrollingAllowed = false;
}

/** Zooms in a bit. */
function ZoomIn()
{
	FreeCamDistance = FMax(0, FreeCamDistance - CamZoomSpeed);
}

/** Zooms out a bit. */
function ZoomOut()
{
	FreeCamDistance = FMin(MAX_FREE_CAM_DISTANCE, FreeCamDistance + CamZoomSpeed);
}

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local Rotator Rot, TempRot;
	local Vector Loc, GlobalX, GlobalY, GlobalZ;
	local float ScrollOffset;

	// if owning PlayerController is in cinematic mode
	// use the CameraStyle.FirstPerson code from Camera.uc
	if(PlayerController(Owner).bCinematicMode)
	{
		OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
		return;
	}

	// modify the camera's yaw rotation
	if(CamRotYawModifier != 0)
	{
		CamRotYaw += CamRotYawModifier * (DeltaTime * CamRotYawSpeed);
	}

	// set the new camera rotation
	Rot.Pitch   = CamRotPitch * DegToUnrRot;
	Rot.Roll    = CamRotRoll  * DegToUnrRot;
	Rot.Yaw     = CamRotYaw   * DegToUnrRot;

	// Copy the Location vector since it can't be modified directly
	Loc = Location;	

	// set the new camera location	
	if (bScrollingAllowed)
	{
		// Only translate the camera if a scroll input was received.
		// Otherwise the "local to global space" transformation vectors would always be applied, resulting in an unwanted steady translation.
		if (bKeyScrollingLeft || bMouseScrollingLeft || bKeyScrollingRight || bMouseScrollingRight || bKeyScrollingUp || bMouseScrollingUp || bKeyScrollingDown || bMouseScrollingDown)
		{
			// Disable the pitch rotation in order to move the camera only on the x,y plane
			TempRot = Rot;
			TempRot.Pitch = 0;

			// Get the "local to global space" transformation vectors
			GetAxes(TempRot, GlobalX, GlobalY, GlobalZ);

			// Calculate the timebased scroll offset
			ScrollOffset = HWPlayerController(Owner).GetPlayerSettings().ScrollSpeed * DeltaTime;

			// Use the transformation vectors multiplied with the ScrollOffset to translate the camera's location based on the input.
			// "X points in view direction, Y points to the right and Z points upwards" (see http://wiki.beyondunreal.com/UE3:Object_static_native_functions_(UT3)#GetAxes).
			if (bKeyScrollingLeft || bMouseScrollingLeft)
			{
				Loc -= GlobalY * ScrollOffset;
			}

			if (bKeyScrollingRight || bMouseScrollingRight)
			{
				Loc += GlobalY * ScrollOffset;
			}

			if (bKeyScrollingUp || bMouseScrollingUp)
			{
				Loc += GlobalX * ScrollOffset;
			}

			if (bKeyScrollingDown || bMouseScrollingDown)
			{
				Loc -= GlobalX * ScrollOffset;
			}
		}

		CheckCameraBounds(Loc);

		SetLocation(Loc);
		SetRotation(Rot);

		// Trying to fix sound problems by relocating the PlayerPawn to the Camera location
		if(HWPlayerController(Owner).Pawn != none)
		{
			HWPlayerController(Owner).Pawn.SetLocation(Loc);
			HWPlayerController(Owner).Pawn.SetPhysics(PHYS_Flying);
		}
	}	

	// use default field of view
	OutVT.POV.FOV = DefaultFOV;

	// Apply the "Isometric Perspective" view
	OutVT.POV.Location = Loc - Vector(Rot) * FreeCamDistance;
	OutVT.POV.Rotation = Rot;
}

/**
 * Checks the specified location for being inside the camera bounds of the
 * map the player this camera belongs to plays on, and adjusts the location
 * if required.
 * 
 * @param Loc
 *      the location to check
 */
function CheckCameraBounds(out Vector Loc)
{
	local HWMapInfoActor Map;

	Map = HWPlayerController(PCOwner).Map;

	if (Map != none)
	{

		Loc.X = FMax(Loc.X, Map.Location.X - Map.CameraBounds.BoxExtent.X);
		Loc.X = FMin(Loc.X, Map.Location.X + Map.CameraBounds.BoxExtent.X);

		Loc.Y = FMax(Loc.Y, Map.Location.Y - Map.CameraBounds.BoxExtent.Y);
		Loc.Y = FMin(Loc.Y, Map.Location.Y + Map.CameraBounds.BoxExtent.Y);
	}
}

DefaultProperties
{
	DefaultFOV=90.f
	FreeCamDistance=MAX_FREE_CAM_DISTANCE
	bScrollingAllowed=true
}
