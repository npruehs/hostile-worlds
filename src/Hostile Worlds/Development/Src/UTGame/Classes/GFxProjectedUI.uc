/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/

/**
 * Implementation of 3D Inventory.
 * Related Flash content:   ut3_inventory.fla
 * 
 * 3D rotation logic can be found toward the end of this file in UpdatePos().
 * 
 * Certain objects in this Flash file are embedded within a hierarchy of containers.
 * This was done to avoid an issue where a MovieClip could not be tweened on the timeline
 * after one of its members had been manipulated via ActionScript. The workaround was to create
 * a new parent MovieClip and manage it with timeline and original MovieClip with ActionScript. 
 * This behavior has since been resolved, but artifacts remain in the Flash file and throughout 
 * this class (see SetupBG()).
 */

class GFxProjectedUI extends UTGFxTweenableMoviePlayer;

var GFxObject Root, Window;
var GFxObject MainMC, BackpackMC, ArsenalMC;

// An array with references to all of the buttons.
var array<GFxUI_InventoryButton> Buttons;

struct ItemData
{
    var string ItemInfo;
    var string ItemName;
    var byte ItemFrame;
};

var array<ItemData> Items;

var GFxObject EquippedWeapon, EquippedWeaponOutline, EquippedWeaponText1, EquippedWeaponText2;

var bool bArsenalTabFocused;
var GFxObject BackpackTabMC, ArsenalTabMC;
var GFxObject LeftArrow02, LeftArrow01;

var GFxObject BackgroundMC, CPCLogoMC, StartUpTextMC, BG_LineMC, BG_ArrowMC;
var GFxObject BG_Optic1MC, BG_Optic2MC, BG_Optic3MC, BG_Optic4MC;

var GFxObject BG_Edge_LeftBottom, BG_Edge_LeftMiddle, BG_Edge_LeftTop, BG_Edge_RightTop, BG_Edge_RightMiddle, BG_Edge_RightBottom;

var GFxObject  InfoMC, InfoIconWeap, InfoIconItem, InfoText, InfoTitle;

var float    Scale;
var float    Width, Height;
var float    rotval;

var float    rightThreshold, leftThreshold;
var bool     bInitialized;

var class<UTWeapon> WeaponClass[11];

var rotator StartRotation;

var localized string AcceptString, CancelString;

function bool Start(optional bool StartPaused = false)
{	
	Super.Start(StartPaused);
	Advance(0);

	AddCaptureKeys();

    rotval = 0;

	if (!bInitialized)
	{
		ConfigureInventory();
	}

	PopulateArsenal();
	UpdateEquippedWeapon();

	// Play the "open" animation.
	BackgroundMC.GotoAndPlay("open");

	// Set focus so the Movie receives input.
    //SetFocus(true, false); 

	StartRotation = GetPC().Rotation;

	return true;
}

function ConfigureInventory()
{
	local float x0, y0, x1, y1;

	Root = GetVariableObject("_root");
	Window = Root.GetObject("inventory");
	MainMC = Window.GetObject("main");

	SetupInfo();

	CreateItemData();

	SetupArsenal();
	SetupArsenalButtons();
	PopulateArsenal();
	UpdateEquippedWeapon();

	SetupBackpack();
	SetupBackpackButtons();
	PopulateBackpackFake();

	SetupBorder();
	SetupBG();

	scale = 1;
	GetVisibleFrameRect(x0, y0, x1, y1);
	Width = (x1-x0)*20;
	Height = (y1-y0)*20;
	bInitialized = true;

	// localize strings
	GetVariableObject("_root.inventory.main.info.help.help_g.text1").SetText(AcceptString);
	GetVariableObject("_root.inventory.main.info.help.help_g.text2").SetText(CancelString);
}

function AddCaptureKeys()
{
    AddCaptureKey('W');
    AddCaptureKey('A');
    AddCaptureKey('S');
    AddCaptureKey('D');
    AddCaptureKey('Spacebar');
    AddCaptureKey('T');
    AddCaptureKey('R');
    AddCaptureKey('Y');
    AddCaptureKey('X');
    AddCaptureKey('C');
    AddCaptureKey('Q');

    AddCaptureKey('Gamepad_LeftStick_Left');
    AddCaptureKey('Gamepad_LeftStick_Right');
    AddCaptureKey('Gamepad_LeftStick_Up');
    AddCaptureKey('Gamepad_LeftStick_Down');

    AddCaptureKey('Gamepad_RightStick_Left');
    AddCaptureKey('Gamepad_RightStick_Right');
    AddCaptureKey('Gamepad_RightStick_Up');
    AddCaptureKey('Gamepad_RightStick_Down');

    AddCaptureKey('XboxTypeS_DPad_Left');
    AddCaptureKey('XboxTypeS_DPad_Right');
    AddCaptureKey('XboxTypeS_DPad_Up');
    AddCaptureKey('XboxTypeS_DPad_Down');

    AddCaptureKey('XboxTypeS_A');
    AddCaptureKey('XboxTypeS_B');
    AddCaptureKey('XboxTypeS_Y');
    AddCaptureKey('XboxTypeS_X');

    AddCaptureKey('1');
    AddCaptureKey('2');
    AddCaptureKey('3');
    AddCaptureKey('4');
    AddCaptureKey('5');
    AddCaptureKey('6');
    AddCaptureKey('7');
    AddCaptureKey('8');
    AddCaptureKey('9');

    AddCaptureKey('Up');
    AddCaptureKey('Down');
    AddCaptureKey('Left');
    AddCaptureKey('Right');
    AddCaptureKey('Enter');
}

/*
 * Starts inventory's the "close" animation.
 */
function StartCloseAnimation()
{
    BackgroundMC.GotoAndPlay("close");
}

/*
 * Event handler for when the "close" animation is complete.
 * Fired from Flash.
 */
function OnCloseAnimComplete()
{
    UTGFxHudWrapper(GetPC().myHUD).CompleteCloseInventory();
}

/*
 * Setup the background and cache references to MovieClips
 * for reuse.
 */
function SetupBG()
{
    BackgroundMC = GetVariableObject("_root.inventory.bg");
    CPCLogoMC = GetVariableObject("_root.inventory.bg.cpc");
    StartUpTextMC = GetVariableObject("_root.inventory.bg.startup_text");

	// Note the troublesome hierarchy of containers to allow Z tweening while animating on the Timeline.
	// Again, this is now unnecessary.
    BG_Optic1MC = BackgroundMC.GetObject("bg_optic1").GetObject("bg_optic1_g").GetObject("bg_optic1_gg");
    BG_Optic2MC = GetVariableObject("_root.inventory.bg.bg_optic2.bg_optic2_g");
    BG_Optic3MC = BackgroundMC.GetObject("bg_optic3").GetObject("bg_optic3_g").GetObject("bg_optic3_gg");
    BG_Optic4MC = BackgroundMC.GetObject("bg_optic4").GetObject("bg_optic4_g").GetObject("bg_optic4_gg");

    BG_Edge_LeftTop = BackgroundMC.GetObject("bg_edge1");
    BG_Edge_LeftMiddle = GetVariableObject("_root.inventory.bg.bg_edge2.bg_edge_g");
    BG_Edge_LeftBottom = BackgroundMC.GetObject("bg_edge3");
    BG_Edge_RightTop = BackgroundMC.GetObject("bg_edge4");
    BG_Edge_RightMiddle = GetVariableObject("_root.inventory.bg.bg_edge5.bg_edge_g");
    BG_Edge_RightBottom = BackgroundMC.GetObject("bg_edge6");

    BG_LineMC = GetVariableObject("_root.inventory.bg.bg_line");
    BG_ArrowMC = GetVariableObject("_root.inventory.bg.bg_arrow");

    BackgroundMC.SetFloat("_z", 1500.0f);

    BG_Edge_RightMiddle.SetFloat("_z", (-200.0f));
    BG_Edge_LeftMiddle.SetFloat("_z", (-200.0f));

    TweenTurbines(true);

    BG_LineMC.SetFloat("_z", -200.0f);
    BG_ArrowMC.SetFloat("_z", -200.0f);
}

function SetupBorder()
{
    BackpackTabMC = BackpackMC.GetObject("tab2_mc");
    ArsenalTabMC = ArsenalMC.GetObject("tab1_mc");

    LeftArrow01 = GetVariableObject("_root.inventory.main.left.left_arrow1");
    LeftArrow02 = GetVariableObject("_root.inventory.main.left.left_arrow2");
}

/*
 * Setup the "Arsenal" section of the inventory. This is the top third of 
 * the menu. Also caches references to each button and its subcomponents for reuse.
 */
function SetupArsenal()
{
    local int i;

    ArsenalMC = MainMC.GetObject("arsenal");

    // Setup icon, background, text for buttons.
    for (i = 0; i < 10; i++)
    {
		Buttons[i] = GFxUI_InventoryButton(ArsenalMC.GetObject("weapon_btn"$(i+1), class'GFxUI_InventoryButton'));
		Buttons[i].GetObject("weapon_black_icon").GetObject("weapon_black").GotoAndStopI((i+2)); // weapon outlines.

		// store the weapon icon movieclip, but set it to false for the time being.
		// it will be set to visible later if the player has the weapon in their inventory
		Buttons[i].SetIconMC(Buttons[i].GetObject("weapon_icon"));
		Buttons[i].IconMC.SetVisible(false);

		// store an index in the button so we can know which button was interacted with when necessary.
		Buttons[i].SetFloat("data", (i+1));        

		// setup the text at the top right of the arsenal buttons.
		if (i < 9)
		   Buttons[i].GetObject("textField").GetObject("textField").SetText("0"$(i+1));
		else // Handle the last case (10)
		   Buttons[i].GetObject("textField").GetObject("textField").SetText("10");
    }

	// Setup equipped weapons
	EquippedWeaponOutline = ArsenalMC.GetObject("equipped");
	EquippedWeapon = EquippedWeaponOutline.GetObject("equipped_weapon").GetObject("equipped_weapon_g");
	EquippedWeaponText1 = EquippedWeaponOutline.GetObject("equipped_text2").GetObject("textField");
	EquippedWeaponText2 = EquippedWeaponOutline.GetObject("equipped_text1").GetObject("textField");
}


/*
 * Setup the "Backpack" section of the inventory. This is the middle third of 
 * the menu. Also caches references to each button and its subcomponents for reuse.
 */
function SetupBackpack()
{
    local byte i;

    BackpackMC = MainMC.GetObject("backpack");

    // Setup icon, background, text for buttons.
    for (i = 10; i < 20; i++)
    {
		// the explicit cast and class parameter are both necessary here.
		Buttons[i] = GFxUI_InventoryButton( BackpackMC.GetObject( "item_btn"$(i-9) , class'GFxUI_InventoryButton'));
		Buttons[i].SetIconMC(Buttons[i].GetObject("item").GetObject("item_g"));
		Buttons[i].IconMC.SetVisible(false);
		Buttons[i].SetFloat("data", (i+1));
    }
}

/*
 * Sets up the Information section of the inventory. This is the bottom most third.
 */
function SetupInfo()
{
    InfoMC = GetVariableObject("_root.inventory.main.info.info_mc.info_mc_g");
    InfoIconWeap = InfoMC.GetObject("weapon");
    InfoIconItem = InfoMC.GetObject("item");
    InfoText = InfoMC.GetObject("info_text").GetObject("textField");
    InfoTitle = InfoMC.GetObject("info_title").GetObject("textField");
}

/*
 * Populates the Backpack with 3 fake items.
 */
function PopulateBackpackFake()
{
    local byte i;

    for (i = 10; i < 13; i++)
    {
        Buttons[i].IconMC.GotoAndStopI(i+2);
        Buttons[i].IconMC.SetVisible(true);
        Buttons[i].AddEventListener('CLIK_click', OnClickFakeItem);
    }
}

/*
 * Setup EventListeners for interaction with Arsenal buttons.
 */
function SetupArsenalButtons()
{
    local byte i;

    for (i = 0; i < 10; i++)
    {
        Buttons[i].AddEventListener('CLIK_focusIn', OnFocusArsenalTab);
        Buttons[i].AddEventListener('CLIK_click',   OnClickWeaponButton);
        Buttons[i].AddEventListener('CLIK_focusIn', OnFocusUpdateInfo);
        Buttons[i].AddEventListener('CLIK_focusIn', OnFocusInSelection);
        Buttons[i].AddEventListener('CLIK_focusOut', OnFocusOutSelection);
    }
}

/*
 * Setup EventListeners for interaction with Backpack buttons.
 */
function SetupBackpackButtons()
{
    local int i;

    for (i = 10; i < 20; i++)
    {
        Buttons[i].AddEventListener('CLIK_focusIn', OnFocusBackpackTab);
        Buttons[i].AddEventListener('CLIK_focusIn', OnFocusUpdateInfo);
        Buttons[i].AddEventListener('CLIK_focusIn', OnFocusInSelection);
        Buttons[i].AddEventListener('CLIK_focusOut', OnFocusOutSelection);
    }
}

/*
 * EventListener for Arsenal button press.
 * Informs the controller that the player has equipped
 * a new weapon.
 */
function SwitchWeapon(byte index)
{
    UTPlayerController(GetPC()).SwitchWeapon(index);
}

/*
 * EventListener for when button gains focus.
 * Initializes the "floating" Z tween on the button's icon,
 * assuming it is visible.
 */
function OnFocusInSelection(GFxClikWidget.EventData ev)
{
    local byte data;
    data = ev.target.GetFloat("data") - 1;

    if (Buttons[data].IconMC.GetBool("_visible"))
        FloatSelectionUp(Buttons[data].IconMC);
}

/*
 * EventListener for when a button has lost focus.
 * Removes any existing tweens on MovieClip(generally, the "floating" Z-tween).
 */
function OnFocusOutSelection(GFxClikWidget.EventData ev)
{
    local byte index;
    index = ev.target.GetFloat("data")-1;

    ClearsTweensOnMovieClip(Buttons[index].IconMC);
}

/*
 * EventListener for when a button in the Arsenal has been
 * clicked.  
 */
function OnClickWeaponButton(GFxClikWidget.EventData ev)
{
    local int index;

    index = ev.target.GetFloat("data");

	if ( (index >= 0) && (WeaponClass[index] != None) )
	{
		UTPawn(GetPC().Pawn).SwitchWeapon(index);

		// Uses FakeUpdateEquippedWeapon because weapon change doesn't actually occur until the inventory is closed.
		FakeUpdateEquippedWeapon(index);
	}
}

/*
 * EventListener for when a button gains focus.
 * If an item in this button slot exists in the player's inventory,
 * it will populate the information portion of the inventory menu.
 */
function OnFocusUpdateInfo(GFxClikWidget.EventData ev)
{
    local int buttonIndex;

    buttonIndex = ev.target.GetFloat("data");

    if (Buttons[buttonIndex-1].IconMC.GetBool("_visible"))
        SetInfo(buttonIndex);
    else
        SetInfo(-1);
}

/*
 * EventListener for when the Arsenal tab gains focus.
 * Tweens the Arsenal tab forward and the Backpack tab backward.
 */
function OnFocusArsenalTab(GFxClikWidget.EventData ev)
{
	// Check to ensure an update is necessary.
    if (!bArsenalTabFocused)
    {
        ArsenalTabMC.GotoAndPlay("on"); // Highlight the Arsenal tab at right.
        BackpackTabMC.GotoAndPlay("off");

        LeftArrow01.GotoAndPlay("on"); // Highlight Arsenal arrow.
        LeftArrow02.GotoAndPlay("off");

        ClearsTweensOnMovieClip(ArsenalMC, false);
        ClearsTweensOnMovieClip(BackpackMC, false);
        TweenTo(ArsenalMC, 0.5, "_z", -1500.0, TWEEN_EaseOut, "");
        TweenTo(BackpackMC, 0.5, "_z", 0.0, TWEEN_EaseOut, "");

        bArsenalTabFocused = true;
    }
}

/*
 * EventListener for when the Backpack tab gains focus.
 * Tweens the Backpack tab forward and the Rasenal tab backward.
 */
function OnFocusBackpackTab(GFxClikWidget.EventData ev)
{
	// Check to ensure an update is necessary.
    if (bArsenalTabFocused)
    {
        ArsenalTabMC.GotoAndPlay("off");
        BackpackTabMC.GotoAndPlay("on"); // Highlight the Backpack tab at right.

        LeftArrow01.GotoAndPlay("off"); // Highlight Backpack arrow.
        LeftArrow02.GotoAndPlay("on");

        ClearsTweensOnMovieClip(ArsenalMC, false);
        ClearsTweensOnMovieClip(BackpackMC, false);
        TweenTo(ArsenalMC, 0.5, "_z", 0.0, TWEEN_EaseOut, "");
        TweenTo(BackpackMC, 0.5, "_z", -1500.0, TWEEN_EaseOut, "");

        bArsenalTabFocused = false;
    }
}


/* 
 * Fake actions for when the fake items are used. 
 */
function OnClickFakeItem(GFxClikWidget.EventData ev)
{
	local UTPawn P;

	switch(ev.target.GetFloat("data"))
    {
        case(11):
            GetPC().Pawn.Health = GetPC().Pawn.HealthMax;;
            return;
            break;
        case(12):
			P = UTPawn(GetPC().Pawn);
			if ( P != None )
			{
				P.PlayEmote('UseArmor', -1);
				P.VestArmor = Max(50, P.VestArmor);
			}
            return;
            break;
        default:
            break;
    }
}

/*
 * Set the data for the information section of the inventory.
 */
function SetInfo(int index)
{
    local string OldText;
    OldText = InfoText.GetText();

    if (index < 0)
    {
        if (OldText != "")
        {
            InfoMC.GotoAndPlay("off");
            InfoIconWeap.GotoAndStopI(0);
            InfoText.SetText("");
            InfoTitle.SetText("");
        }
    }
    else
    {
        InfoMC.GotoAndPlay("on");
		if ( Items.Length >= index )
		{
			InfoIconWeap.GotoAndStopI(Items[index-1].ItemFrame);
			InfoText.SetText(Items[index-1].ItemInfo);
			InfoTitle.SetText(Items[index-1].ItemName);
		}
    }
}

/*
 * Populate the Arsenal with the player's inventory of weapons.
 */
function PopulateArsenal()
{
    local byte i;

	if ( GetPC().Pawn != None )
	{
		for (i = 0; i < 9; i++)
		{
			if ( (WeaponClass[i+1] != None) && (GetPC().Pawn.FindInventoryType(WeaponClass[i+1], true) != None) )
			{
				Buttons[i].IconMC.SetVisible(true);
				Buttons[i].IconMC.GotoAndStopI((i+2));
				Buttons[i].SetFloat("data", (i+1));
			}
		}
	}
}

/*
 * Update the currently equipped weapon section of the
 * inventory menu. Plays a short animation and updates
 * text throughout the menu. Fired by the PlayerController
 * when SetCurrentWeapon is called.
 * 
 * This FakeUpdate is used in place of the real update
 * because the current implementation of the inventory
 * makes it impossible for the player to change their weapon
 * within the menu (it is done when the menu is closed).
 */
function FakeUpdateEquippedWeapon(int index)
{
    local string CurrentWeaponString;
    CurrentWeaponString = string(index);

    if (index < 10)
        CurrentWeaponString = "0"$CurrentWeaponString;

    EquippedWeapon.GotoAndStopI(index+1);               // Change the weapon icon.
    EquippedWeaponOutline.GotoAndPlay("equipped");      // Red hexagon outline animation.
    EquippedWeaponText1.SetText(CurrentWeaponString);
    EquippedWeaponText2.SetText(CurrentWeaponString);
}

/*
 * --- UNUSED ---
 * 
 * Update the currently equipped weapon section of the
 * inventory menu. Plays a short animation and updates
 * text throughout the menu. 
 */
function UpdateEquippedWeapon()
{
    local byte CurrentWeapon;
    local string CurrentWeaponString;

    CurrentWeapon = UTWeapon(GetPC().Pawn.Weapon).InventoryGroup;
    CurrentWeaponString = string(CurrentWeapon);

    if (CurrentWeapon < 10)
        CurrentWeaponString = "0"$CurrentWeaponString;

    EquippedWeapon.GotoAndStopI(CurrentWeapon+1);
    EquippedWeaponText1.SetText(CurrentWeaponString);
    EquippedWeaponText2.SetText(CurrentWeaponString);
}


/*
 * Implementation of ProcessTweenCallback.  Inherited from UTGFxTweenableMoviePlayer
 * (basic workaround for lack of multiple inheritance).
 * 
 * Callbacks are fired by the TweenManager. The TargetMC is target MovieClip
 * of the Tween that just finished. See UTGFxTweenableMoviePlayer
 * for more information.
 */
function ProcessTweenCallback(String Callback, GFxObject TargetMC)
{
     switch(Callback)
     {
        case ("TweenTurbines1"):
            TweenTurbines(true);
        break;
        case ("TweenTurbines2"):
            TweenTurbines(false);
        break;
        case ("ContinueFloatCheck"):
            FloatSelectionUp(TargetMC);
        break;
        case ("FloatSelectionDown"):
            FloatSelectionDown(TargetMC);
        break;
        default:
        break;
     }
}

/*
 * Tween callback:
 * Tween the background turbines back and forth.
 */
function TweenTurbines(bool toggle)
{
    if (toggle)
    {
        TweenTo( BG_Optic1MC, 11.0, "_z", -1000, TWEEN_EaseOut, "TweenTurbines2" );
        TweenTo( BG_Optic3MC, 10.0, "_z", -2000, TWEEN_EaseOut, "" );
        TweenTo( BG_Optic4MC, 10.0, "_z",  2000, TWEEN_EaseOut, "" );
    }
    else
    {
        TweenTo( BG_Optic1MC, 11.0, "_z", 1000,  TWEEN_EaseOut, "TweenTurbines1" );
        TweenTo( BG_Optic3MC, 10.0, "_z", 2000,  TWEEN_EaseOut, "" );
        TweenTo( BG_Optic4MC, 10.0, "_z", -2000, TWEEN_EaseOut, "" );
    }
}

/*
 * Tween callback:
 * Tween target MovieClip upward on the Z.
 * Used on selected items in the backpack and the arsenal.
 */
function FloatSelectionUp(GFxObject ButtonIconMC)
{
    TweenTo( ButtonIconMC, 1.0, "_z", (-600 * 4.0), TWEEN_Linear, "FloatSelectionDown");
}

/*
 * Tween callback:
 * Tween target MovieClip downward on the Z.
 * Used on selected items in the backpack and the arsenal.
 */
function FloatSelectionDown(GFxObject ButtonIconMC)
{
    TweenTo( ButtonIconMC, 1.0, "_z", (-600 * 3.5), TWEEN_Linear, "ContinueFloatCheck");
}

/*
 * 3D transformation code. The 3D transformation of the inventory
 * is based on the location and rotator for the player's third person
 * camera. 
 */
function UpdatePos()
{
    local float yawRadian;
    local float pitchRadian;
    local matrix mYaw, mTranslate, mPitch, mScale, mFinal;
    local float distFromPawn;
    local float pawnPosX, pawnPosZ;	 // relative to camera

    // Create identity matrix.
    mTranslate.XPlane.X = 1;
    mTranslate.YPlane.Y = 1;
    mTranslate.ZPlane.Z = 1;
    mTranslate.WPlane.W = 1;

    // Initialize all matrices.
    mYaw = mTranslate;
    mPitch = mTranslate;
    mScale = mTranslate;

    yawRadian = -((16384 + ((GetPC().Rotation.Yaw /*- 5000*/) - StartRotation.Yaw)) & 65535) * (Pi/32768.0);
    yawRadian -= (3*1.57079633);

    pitchRadian = -((16384 + (GetPC().Rotation.Pitch - StartRotation.Pitch)) & 65535) * (Pi/32768.0);
    pitchRadian -= (3*1.57079633);

    // Rotate about the Y
    mYaw.XPlane.X = cos(yawRadian) * Scale;
    mYaw.XPlane.Z = -sin(yawRadian) * Scale;

    mYaw.ZPlane.X = sin(yawRadian) * Scale;
    mYaw.ZPlane.Z = cos(yawRadian) * Scale;

    // Rotate about the X
    mPitch.YPlane.Y = cos(pitchRadian) * Scale;
    mPitch.YPlane.Z = sin(pitchRadian) * Scale;

    mPitch.ZPlane.Y = -sin(pitchRadian) * Scale;
    mPitch.ZPlane.Z = cos(pitchRadian) * Scale;

    distFrompawn = 12000.0;

    // move the center of rotation to be around the pawn
    pawnPosX = -4000;
    pawnPosZ = 0;	//2500;

    // move the swf around a circle, centered by pawnPos
    yawRadian += (1.57079633);
    yawRadian += 0.5;
    mTranslate.WPlane.X = -cos(yawRadian) * distFrompawn + pawnPosX;
    mTranslate.WPlane.Z = sin(yawRadian) * distFrompawn + pawnPosZ;

    // scale the projection.
    mScale.XPlane.X = 1.25;
    mScale.YPlane.Y = 1.25;
    mScale.ZPlane.Z = 0.5;
    mScale.WPlane.W = 1;
    mFinal = mYaw * mPitch * mTranslate * mScale;

    Window.SetDisplayMatrix3D(mFinal);
}

function CreateItemData()
{
    local byte i;
    local ItemData data;

	for ( i=0; i<10; i++ )
	{
		if ( WeaponClass[i+1] != None )
		{
			data.ItemName = WeaponClass[i+1].default.ItemName;
			data.ItemInfo = WeaponClass[i+1].default.UseHintString;
		}
		data.ItemFrame = i+2;
		Items[i] = data;
	}

    data.ItemName = class'UTHealthPickupFactory'.default.PickupMessage;
    data.ItemInfo = class'UTHealthPickupFactory'.default.UseHintMessage;
    data.ItemFrame = 12;
    Items[10] = data;

    data.ItemName = class'UTArmorPickupFactory'.default.PickupMessage;
    data.ItemInfo = class'UTArmorPickupFactory'.default.UseHintMessage;
    data.ItemFrame = 13;
    Items[11] = data;

    data.ItemName = "DAMAGE AMPLIFIER";
    data.ItemInfo = "Amplifies the user's damage by 4x.  Use with caution.";
    data.ItemFrame = 14;
    Items[12] = data;
}

defaultproperties
{
	bIgnoreMouseInput=TRUE
    bEnableGammaCorrection = FALSE
    rightThreshold = -10.9
    leftThreshold = -8.34
    bArsenalTabFocused = TRUE
    bDisplayWithHudOff = TRUE
	bInitialized = FALSE
	MovieInfo=SwfMovie'GFxUI_Inventory.ut3_inventory'

	WeaponClass(1)=class'UTWeap_LinkGun'
	WeaponClass(4)=class'UTWeap_ShockRifleBase'
	WeaponClass(8)=class'UTWeap_RocketLauncher'
}