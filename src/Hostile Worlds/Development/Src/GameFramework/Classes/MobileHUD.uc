/**
* MobileHUD
* Extra floating always on top HUD for touch screen devices
*
*
* Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
*/

class MobileHUD extends HUD
	native
	config(Game)
	dependson(MobilePlayerInput);

/**
 *  Structure to allow easy storage of UVs for a rendered image                                                                     
 */
struct native TextureUVs
{
	var float U, V, UL, VL;
};


/** If true, we want to display the normal hud.  We need a third variable to support hiding the hud completly yet still supporting the ShowHud command */
var config bool bShowGameHud;	

/** If true, we want to display the mobile hud (ie: Input zones. etc) */
var config bool bShowMobileHud;

/** Allow for enabling/disabling the Mobile HUD stuff on non-mobile platforms */
var globalconfig bool bForceMobileHUD;

/** Texture to fill the zones with */

var Texture2D JoystickBackground;
var TextureUVs JoystickBackgroundUVs;
var Texture2D JoystickHat;
var TextureUVs JoystickHatUVs;

var Texture2D ButtonImages[2];
var TextureUVs ButtonUVs[2];
var font ButtonFont;
var color ButtonCaptionColor;

var Texture2D TrackballBackground;
var TextureUVs TrackballBackgroundUVs;
var Texture2D TrackballTouchIndicator;
var TextureUVs TrackballTouchIndicatorUVs;

var Texture2D SliderImages[4];
var TextureUVs SliderUVs[4];

/** If true, this hud will display the device tilt */
var config bool bShowMobileTilt;

/** Hold the position data for displaying the tilt */
var config float MobileTiltX, MobileTiltY, MobileTiltSize;

/** If true, display debug information regarding the touches */
var config bool bDebugTouches;

/** If true, debug info about the various mobile input zones will be displayed */
var config bool bDebugZones;

/** If true, debug info about a mobile input zone will be displayed, but only on presses */
var config bool bDebugZonePresses;

/**
* Create a list of actors needing post renders for.  Also Create the Hud Scene
*/
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// If we are on the actual mobile platform or we are forcing the issue, then
	// figure out if we want to show the game hud
	if (WorldInfo.IsConsoleBuild(CONSOLE_Mobile) ||	bForceMobileHUD)
	{
	}
	else	// Not a mobile game so make sure we don't restrict the hud
	{
		bShowGameHud = true;
	}
}

/**
 * The start of the rendering chain.                                                                     
 */
function PostRender()
{
	super.PostRender();

	if (bShowMobileHud)
	{
		DrawInputZoneOverlays();
	}

	RenderMobileMenu();

}

/**
 * Draw the Mobile hud                                                                     
 */
function RenderMobileMenu()
{
	local MobilePlayerInput  MobileInput;

	local float y;
	local int i;

	// Get a reference to the mobile player input.  Quick out if it's not a mobile input

	MobileInput = MobilePlayerInput(PlayerOwner.PlayerInput);
	if (MobileInput == none)
	{
		return;
	}

	if (bDebugTouches)
	{
		Y=20;
		Canvas.SetDrawColor(255,255,255,255);
		for (i=0;i<5;i++)
		{
			Canvas.SetPos(0,Y);
			Canvas.DrawText("" $ i @ MobileInput.Touches[i].bInUse @ MobileInput.Touches[i].State @ MobileInput.Touches[i].Zone @ MobileInput.Touches[i].Handle);
			Y+=10;
		}
	}


	MobileInput.RenderMenus(Canvas, RenderDelta);
}

/**
* Draws the input zones on top of everything else
*/
function DrawInputZoneOverlays()
{
	local int ZoneIndex;
	local MobileInputZone Zone;
	local float Fade;
	local MobilePlayerInput MobileInput;
	local array<MobileInputZone> Zones;

	// Get a reference to the mobile player input.  Quick out if it's not a mobile input

	MobileInput = MobilePlayerInput(PlayerOwner.PlayerInput);
	if (MobileInput == none)
	{
		return;
	}

	// reset the canvas state
	Canvas.Reset();
	Canvas.ClipX = Canvas.SizeX;
	Canvas.ClipY = Canvas.SizeY;

	Canvas.Font	 = class'Engine'.Static.GetSmallFont();

	if (MobileInput.HasZones())
	{
		Zones = MobileInput.GetCurrentZones();
	}

	// get the current zones from the game
	for (ZoneIndex = 0; ZoneIndex < Zones.Length; ZoneIndex++)
	{
		Zone = Zones[ZoneIndex];

		if ( !Zone.bIsInvisible )
		{
			// Setup the DrawColor, take the states in to consideration

			Canvas.DrawColor = Zone.RenderColor;
			switch (Zone.State)
			{
				case ZoneState_Inactive:
					Canvas.DrawColor.A *= Zone.InactiveAlpha;
					break;

				case ZoneState_Activating:
					Fade = Lerp(Zone.InactiveAlpha, 1.0, Zone.TransitionTime / Zone.ActivateTime);
					Canvas.DrawColor.A *= Fade;
					break;

				case ZoneState_Deactivating:
					Fade = Lerp(1.0, Zone.InactiveAlpha, Zone.TransitionTime / Zone.DeactivateTime);
					Canvas.DrawColor.A *= Fade;
					break;
			}

			// Give script a chance to override the zone 
			if (Zone.OnPreDrawZone(Zone,Canvas))
			{
				break;
			}

			switch (Zone.Type)
			{
				case ZoneType_Button:
					DrawMobileZone_Button(Zone);
					break;

				case ZoneType_Joystick:
					DrawMobileZone_Joystick(Zone);
					break;

				case ZoneType_Trackball:
					DrawMobileZone_Trackball(Zone);
					break;

				case ZoneType_Slider:
					DrawMobileZone_Slider(Zone);
					break;

			}

			Zone.OnPostDrawZone(Zone,Canvas);

		}

		if (bShowMobileTilt)
		{
			DrawMobileTilt(MobileInput);
		}

		if (bDebugZones || (bDebugZonePresses && (Zone.State == ZoneState_Active || Zone.State == ZoneState_Activating)))
		{
			Canvas.SetDrawColor(0,255,255,255);
			Canvas.SetPos(Zone.X, Zone.Y);
			Canvas.DrawBox(Zone.SizeX, Zone.SizeY);
		}
	}	
}
function DrawMobileZone_Button(MobileInputZone Zone)
{
	local int Pressed;
	local float X,Y,U,V,UL,VL,A;
	local Texture2D Tex;

	Pressed = int(Zone.State == ZoneState_Active);

	if (ButtonImages[Pressed] != none)
	{
		Canvas.SetPos(Zone.X, Zone.Y);

		Tex = ButtonImages[Pressed];
		U   = ButtonUVs[Pressed].U;
		V   = ButtonUVs[Pressed].V;
		UL  = ButtonUVs[Pressed].UL;
		VL  = ButtonUVs[Pressed].VL;
		
		Canvas.DrawTile(Tex,Zone.SizeX, Zone.SizeY, U,V,UL,VL);;

		// Draw the Caption

		if (Zone.Caption != "")
		{
			Canvas.Font = ButtonFont;
			Canvas.StrLen(Zone.Caption,UL,VL);
			X = Zone.X + (Zone.SizeX /2) - (UL/2);
			Y = zone.Y + (Zone.SizeY /2) - (VL/2);
			Canvas.SetPos(X + Zone.CaptionXAdjustment,Y+Zone.CaptionYAdjustment);
			A = Canvas.DrawColor.A;
			Canvas.DrawColor = ButtonCaptionColor;
			Canvas.DrawColor.A = A;
			Canvas.DrawText(Zone.Caption);
		}

	}
}

function DrawMobileZone_Joystick(MobileInputZone Zone)
{
	local int X, Y, Width, Height;
	local Color LineColor;
	local float ClampedX, ClampedY, Scale;
	local Color TempColor;

	if (JoystickBackground != none)
	{
		Width = Zone.bCenterOnEvent ? Zone.ActiveSizeX : Zone.SizeX;
		Height = Zone.bCenterOnEvent ? Zone.ActiveSizeY : Zone.SizeY;

		X = Zone.bCenterOnEvent ? Zone.CurrentCenter.X - (Width /2) : Zone.X;
		Y = Zone.bCenterOnEvent ? Zone.CurrentCenter.Y - (Height /2) : Zone.Y;

		Canvas.SetPos(X,Y);
		Canvas.DrawTile(JoystickBackground, Width, Height, JoystickBackgroundUVs.U, JoystickBackgroundUVs.V, JoystickBackgroundUVs.UL, JoystickBackgroundUVs.VL);
	}

	// Draw the Hat

	if (JoystickHat != none)
	{
		// Compute X and Y clamped to the size of the zone for the joystick
		ClampedX = Zone.CurrentLocation.X - Zone.CurrentCenter.X;
		ClampedY = Zone.CurrentLocation.Y - Zone.CurrentCenter.Y;
		Scale = 1.0f;
		if ( ClampedX != 0 || ClampedY != 0 )
		{
			Scale = Min( Zone.SizeX, Zone.SizeY ) / ( 2.0 * Sqrt(ClampedX * ClampedX + ClampedY * ClampedY) );
			Scale = FMin( 1.0, Scale );
		}
		ClampedX = ClampedX * Scale + Zone.CurrentCenter.X;
		ClampedY = ClampedY * Scale + Zone.CurrentCenter.Y;

		if (Zone.bRenderGuides)
		{
			TempColor = Canvas.DrawColor;
			LineColor.R = 128;
			LineColor.G = 128;
			LineColor.B = 128;
			LineColor.A = 255;
			Canvas.Draw2DLine(Zone.CurrentCenter.X, Zone.CurrentCenter.Y, ClampedX, ClampedY, LineColor);
			Canvas.DrawColor = TempColor;

		}

		// The size of the indicator will be a fraction of the background's total size
		Width = Zone.ActiveSizeX * 0.65;
		Height = Zone.ActiveSizeY * 0.65;

		Canvas.SetPos( ClampedX - Width / 2, ClampedY - Height / 2);
		Canvas.DrawTile(JoystickHat, Width, Height, JoystickHatUVs.U, JoystickHatUVs.V, JoystickHatUVs.UL, JoystickHatUVs.VL);
	}
}

function DrawMobileZone_Trackball(MobileInputZone Zone)
{
	local int Width, Height;
	if (TrackballBackground != none)
	{
		Canvas.SetPos( Zone.X, Zone.Y);
		Canvas.DrawTile(TrackballBackground, Zone.SizeX, Zone.SizeY, TrackballBackgroundUVs.U, TrackballBackgroundUVs.V, TrackballBackgroundUVs.UL, TrackballBackgroundUVs.VL);
	}

	// Draw the Touch indicator

	if (TrackballTouchIndicator != none && (Zone.State == ZoneState_Active || Zone.State == ZoneState_Activating))
	{
		// The size of the indicator will be a fraction of the background's total size
		Width = Zone.ActiveSizeX * 0.65;
		Height = Zone.ActiveSizeY * 0.65;

		Canvas.SetPos(Zone.CurrentLocation.X - Width / 2, Zone.CurrentLocation.Y - Height / 2);
		Canvas.DrawTile(TrackballTouchIndicator, Width, Height, TrackballTouchIndicatorUVs.U, TrackballTouchIndicatorUVs.V, TrackballTouchIndicatorUVs.UL, TrackballTouchIndicatorUVs.VL);
	}
}

function DrawMobileTilt(MobilePlayerInput MobileInput)
{
	local float X, Y, Scale;
	local float Yaw, Pitch;

	Yaw = 2.0 * FClamp(MobileInput.MobileYaw - MobileInput.MobileYawCenter,-0.5, 0.5) * MobileInput.MobileYawMultiplier;
	Pitch = 2.0 * FClamp(MobileInput.MobilePitch - MobileInput.MobilePitchCenter, -0.5, 0.5) * MobileInput.MobilePitchMultiplier;


	// Compute X and Y clamped to the size of the zone for the joystick
	X = (MobileTiltX +  Yaw * MobileTiltSize /2) - MobileTiltX;
	Y = (MobileTiltY +  Pitch * MobileTiltSize/2) - MobileTiltY;

	Scale = 1.0f;
	if ( X != 0 || Y != 0 )
	{
		Scale = MobileTiltSize  / ( 2.0 * Sqrt(X*X*Y*Y) );
		Scale = FMin( 1.0, Scale );
	}
	X = X * Scale + MobileTiltX;
	Y = Y * Scale + MobileTiltY;

	Canvas.DrawColor = WhiteColor;
	Canvas.Draw2DLine(MobileTiltX, MobileTiltY, X, Y, Canvas.DrawColor);
}

function DrawMobileZone_Slider(MobileInputZone Zone)
{
	local float X,Y;
	local TextureUVs UVs;
	local Texture2D Tex;

	// First, look up the Texture

	Tex = SliderImages[int(Zone.SlideType)];
	UVs = SliderUVs[int(Zone.SlideType)];

	// Now, figure out where we have to draw.

	X = (int(Zone.SlideType) > 1) ? Zone.CurrentLocation.X - (Zone.ActiveSizeX * 0.5) : Zone.X;
	Y = (int(Zone.SlideType) > 1) ? Zone.Y : Zone.CurrentLocation.Y - (Zone.ActiveSizeY * 0.5);

	Canvas.SetPos(X,Y);
	Canvas.DrawTile(Tex,Zone.ActiveSizeX, Zone.ActiveSizeY, UVs.U, UVs.V, UVs.UL, UVs.VL);
}


defaultproperties
{
	JoystickBackground=Texture2D'MobileResources.T_MobileControls_texture'
	JoystickBackgroundUVs=(U=0,V=0,UL=126,VL=126)
	JoystickHat=Texture2D'MobileResources.T_MobileControls_texture'
	JoystickHatUVs=(U=128,V=0,UL=78,VL=78)

	ButtonImages(0)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonImages(1)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonUVs(0)=(U=0,V=0,UL=32,VL=32)
	ButtonUVs(1)=(U=0,V=0,UL=32,VL=32)

	TrackballBackground=none
	TrackballTouchIndicator=Texture2D'MobileResources.T_MobileControls_texture'
	TrackballTouchIndicatorUVs=(U=160,V=0,UL=92,VL=92)

	SliderImages(0)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderImages(1)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderImages(2)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderImages(3)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderUVs(0)=(U=0,V=0,UL=32,VL=32)
	SliderUVs(1)=(U=0,V=0,UL=32,VL=32)
	SliderUVs(2)=(U=0,V=0,UL=32,VL=32)
	SliderUVs(3)=(U=0,V=0,UL=32,VL=32)


	ButtonFont = Font'EngineFonts.SmallFont'
	ButtonCaptionColor=(R=0,G=0,B=0,A=255);
}
