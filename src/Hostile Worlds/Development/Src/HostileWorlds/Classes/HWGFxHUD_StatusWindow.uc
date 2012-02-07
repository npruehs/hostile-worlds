// ============================================================================
// HWGFxHUD_StatusWindow
// The HUD window showing the information on the selected unit(s), such as
// their damage or game object description.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_statuswindow.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/03
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_StatusWindow extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelNameLevel;
var GFxObject LabelDamage;
var GFxObject LabelCooldown;
var GFxObject LabelArmor;
var GFxObject LabelRange;
var GFxObject LabelDamageValue;
var GFxObject LabelCooldownValue;
var GFxObject LabelArmorValue;
var GFxObject LabelRangeValue;
var GFxObject LabelBuffs;
var GFxObject LabelShields;
var GFxObject LabelStructure;
var GFxClikWidget BtnPortrait;
var GFxClikWidget BtnBuff[8];

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextLevel;
var localized string LabelTextDamage;
var localized string LabelTextCooldown;
var localized string LabelTextArmor;
var localized string LabelTextRange;
var localized string LabelTextBuffs;
var localized string LabelTextMore;

// ----------------------------------------------------------------------------
// Other variables.

/** Cached references to applied buffs, for showing tooltips. */
var HWBuff Buffs[8];


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('labelNameLevel'):
			if (LabelNameLevel == none)
			{
				LabelNameLevel = Widget;
				return true;
			}
            break;

		case ('labelDamage'):
			if (LabelDamage == none)
			{
				LabelDamage = Widget;
				return true;
			}
            break;

		case ('labelCooldown'):
			if (LabelCooldown == none)
			{
				LabelCooldown = Widget;
				return true;
			}
            break;

		case ('labelArmor'):
			if (LabelArmor == none)
			{
				LabelArmor = Widget;
				return true;
			}
            break;

		case ('labelRange'):
			if (LabelRange == none)
			{
				LabelRange = Widget;
				return true;
			}
            break;

		case ('labelDamageValue'):
			if (LabelDamageValue == none)
			{
				LabelDamageValue = Widget;
				return true;
			}
            break;

		case ('labelCooldownValue'):
			if (LabelCooldownValue == none)
			{
				LabelCooldownValue = Widget;
				return true;
			}
            break;

		case ('labelArmorValue'):
			if (LabelArmorValue == none)
			{
				LabelArmorValue = Widget;
				return true;
			}
            break;

		case ('labelRangeValue'):
			if (LabelRangeValue == none)
			{
				LabelRangeValue = Widget;
				return true;
			}
            break;

		case ('labelBuffs'):
			if (LabelBuffs == none)
			{
				LabelBuffs = Widget;
				return true;
			}
            break;

		case ('labelShields'):
			if (LabelShields == none)
			{
				LabelShields = Widget;
				return true;
			}
            break;

		case ('labelStructure'):
			if (LabelStructure == none)
			{
				LabelStructure = Widget;
				return true;
			}
            break;

		case ('btnPortrait'):
			if (BtnPortrait == none)
			{
				BtnPortrait = GFxClikWidget(Widget);
				BtnPortrait.AddEventListener('CLIK_press', OnButtonPressPortrait);
				return true;
			}
            break;

		case ('btnBuff0'):
			if (BtnBuff[0] == none)
			{
				BtnBuff[0] = GFxClikWidget(Widget);
				BtnBuff[0].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff0);
				BtnBuff[0].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff1'):
			if (BtnBuff[1] == none)
			{
				BtnBuff[1] = GFxClikWidget(Widget);
				BtnBuff[1].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff1);
				BtnBuff[1].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff2'):
			if (BtnBuff[2] == none)
			{
				BtnBuff[2] = GFxClikWidget(Widget);
				BtnBuff[2].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff2);
				BtnBuff[2].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff3'):
			if (BtnBuff[3] == none)
			{
				BtnBuff[3] = GFxClikWidget(Widget);
				BtnBuff[3].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff3);
				BtnBuff[3].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff4'):
			if (BtnBuff[4] == none)
			{
				BtnBuff[4] = GFxClikWidget(Widget);
				BtnBuff[4].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff4);
				BtnBuff[4].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff5'):
			if (BtnBuff[5] == none)
			{
				BtnBuff[5] = GFxClikWidget(Widget);
				BtnBuff[5].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff5);
				BtnBuff[5].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff6'):
			if (BtnBuff[6] == none)
			{
				BtnBuff[6] = GFxClikWidget(Widget);
				BtnBuff[6].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff6);
				BtnBuff[6].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnBuff7'):
			if (BtnBuff[7] == none)
			{
				BtnBuff[7] = GFxClikWidget(Widget);
				BtnBuff[7].AddEventListener('CLIK_rollOver', OnButtonRollOverBuff7);
				BtnBuff[7].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/** Updates this status window, refreshing any information on the selected unit(s), if any. */
function Update()
{
	local HWPlayerController ThePlayer;
	local HWSelectable SelectedUnit;
	local HWPawn SelectedPawn;
	local HWGameObject SelectedGo;

	ThePlayer = HWPlayerController(myHUD.PlayerOwner);

	if (ThePlayer.SelectedUnits.Length > 0)
    {
		// get the unit to display information on
		SelectedUnit = ThePlayer.StrongestSelectedUnit;

		// check if a pawn is selected
		SelectedPawn = HWPawn(SelectedUnit);

		if (SelectedPawn != none)
		{
			ShowInfoPawn(SelectedPawn, ThePlayer.SelectedUnits.Length - 1);
			return;
		}

		// a game object must have been selected - check for none anyway, could have been destroyed...
		SelectedGo = HWGameObject(SelectedUnit);

		if (SelectedGo != none)
		{
			ShowInfoGameObject(SelectedGo, ThePlayer.SelectedUnits.Length - 1);
		}
    }
	else
	{
		ClearInfo();
	}
}

/** Clears this status window, hiding all sub-components. */
function ClearInfo()
{
	local int i;

	LabelNameLevel.SetText("");
	BtnPortrait.SetVisible(false);

	LabelStructure.SetText("");
	LabelShields.SetText("");

	LabelDamage.SetText("");
	LabelDamageValue.SetText("");

	LabelCooldown.SetText("");
	LabelCooldownValue.SetText("");

	LabelArmor.SetText("");
	LabelArmorValue.SetText("");

	LabelRange.SetText("");
	LabelRangeValue.SetText("");

	LabelBuffs.SetText("");

	for (i = 0; i < 8; i++)
	{
		BtnBuff[i].SetVisible(false);
	}
}

/**
 * Shows information on the passed unit, including its name and portrait,
 * structure, attack damage and buffs.
 * 
 * @param SelectedUnit
 *      the unit to show information on
 * @param AdditionalUnits
 *      the number of additional selected units
 */
function ShowInfoPawn(HWPawn SelectedUnit, int AdditionalUnits)
{
	local string Text;

	local Color HealthColor;
	local string HexColor;

	local HWSquadMember SelectedSM;

	local HWBuff Buff;
	local int BuffIndex;

	SelectedSM = HWSquadMember(SelectedUnit);

	// show unit name and level
	Text = SelectedUnit.MenuName;

	if (SelectedSM != none)
	{
		Text @= "("$LabelTextLevel@SelectedSM.Level$")";
	}

	if (AdditionalUnits > 0)
	{
		Text @= "(+ "$AdditionalUnits@LabelTextMore$")";
	}

	LabelNameLevel.SetText(Text);

	// show portrait
	BtnPortrait.SetVisible(true);
	SetExternalTexture("IconPortrait", SelectedUnit.UnitPortrait);
	
	// show structure points
	HealthColor = myHUD.GetHealthColor(SelectedUnit);
	HexColor $= myHUD.ByteToHex(HealthColor.R);
	HexColor $= myHUD.ByteToHex(HealthColor.G);
	HexColor $= myHUD.ByteToHex(HealthColor.B);

	Text = "<font color=\"#"$HexColor$"\">";
	Text $=	SelectedUnit.Health$" / "$SelectedUnit.HealthMax;
	Text $= "</font>";

	LabelStructure.SetString("htmlText", Text);

	if (SelectedSM != none)
	{
		// show shields
		Text = SelectedSM.ShieldsCurrent$" / "$SelectedSM.ShieldsMax;
		LabelShields.SetText(Text);
	}
	else
	{
		// hide shields
		LabelShields.SetText("");
	}

	if (SelectedUnit.AttackDamage > 0)
	{
		// show damage
		LabelDamage.SetText(LabelTextDamage);
		LabelDamageValue.SetText(myHUD.FloatToString(SelectedUnit.AttackDamage, 2));

		// show cooldown
		LabelCooldown.SetText(LabelTextCooldown);
		LabelCooldownValue.SetText(myHUD.FloatToString(SelectedUnit.Cooldown, 2));

		// show range
		LabelRange.SetText(LabelTextRange);
		LabelRangeValue.SetText(myHUD.FloatToString(SelectedUnit.Range, 2));
	}
	else
	{
		// hide damage
		LabelDamage.SetText("");
		LabelDamageValue.SetText("");

		// hide cooldown
		LabelCooldown.SetText("");
		LabelCooldownValue.SetText("");

		// hide range
		LabelRange.SetText("");
		LabelRangeValue.SetText("");
	}

	// show armor
	LabelArmor.SetText(LabelTextArmor);
	LabelArmorValue.SetText(SelectedUnit.Armor);

	// show buffs
	LabelBuffs.SetText(LabelTextBuffs);

	Buff = SelectedUnit.Buffs;
	BuffIndex = 0;

	while (Buff != none)
	{
		// show buff icon
		BtnBuff[BuffIndex].SetVisible(true);
		SetExternalTexture("IconBuff"$BuffIndex, Buff.BuffIcon);

		// cache a reference to the buff for showing tooltips
		Buffs[BuffIndex] = Buff;
		
		// go on with next one
		Buff = Buff.NextBuff;
		BuffIndex++;
	}
	
	// hide any further buff icons
	while (BuffIndex < 8)
	{
		BtnBuff[BuffIndex].SetVisible(false);
		BuffIndex++;
	}
}

/**
 * Shows information on the passed game object, like its name and
 * portraits and further description texts.
 * 
 * @param GameObject
 *      the game object to show information on
 * @param AdditionalUnits
 *      the number of additional selected units
 */
function ShowInfoGameObject(HWGameObject GameObject, int AdditionalUnits)
{
	local string Text;
	local int i;

	// show object name
	Text = GameObject.MenuName;

	if (AdditionalUnits > 0)
	{
		Text @= "(+ "$AdditionalUnits@LabelTextMore$")";
	}

	LabelNameLevel.SetText(Text);

	// show portrait
	BtnPortrait.SetVisible(true);
	SetExternalTexture("IconPortrait", GameObject.UnitPortrait);

	// hide structure points and shields
	LabelStructure.SetText("");
	LabelShields.SetText("");

	// show description line 1
	LabelDamage.SetText(GameObject.DescriptionLineOne);
	LabelDamageValue.SetText("");

	// show description line 2
	LabelCooldown.SetText(GameObject.DescriptionLineTwo);
	LabelCooldownValue.SetText("");

	// show description line 3
	LabelArmor.SetText(GameObject.DescriptionLineThree);
	LabelArmorValue.SetText("");

	LabelRange.SetText("");
	LabelRangeValue.SetText("");

	// show additional info
	LabelBuffs.SetText(GameObject.GetAdditionalInfo());

	for (i = 0; i < 8; i++)
	{
		BtnBuff[i].SetVisible(false);
	}
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressPortrait(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	HWPlayerController(myHUD.PlayerOwner).FocusStrongestSelectedUnit();
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOverBuff0(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[0].BuffName, Buffs[0].GetHTMLDescription());
}

function OnButtonRollOverBuff1(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[1].BuffName, Buffs[1].GetHTMLDescription());
}

function OnButtonRollOverBuff2(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[2].BuffName, Buffs[2].GetHTMLDescription());
}

function OnButtonRollOverBuff3(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[3].BuffName, Buffs[3].GetHTMLDescription());
}

function OnButtonRollOverBuff4(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[4].BuffName, Buffs[4].GetHTMLDescription());
}

function OnButtonRollOverBuff5(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[5].BuffName, Buffs[5].GetHTMLDescription());
}

function OnButtonRollOverBuff6(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[6].BuffName, Buffs[6].GetHTMLDescription());
}

function OnButtonRollOverBuff7(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(Buffs[7].BuffName, Buffs[7].GetHTMLDescription());
}

// ----------------------------------------------------------------------------
// Button OnRollOut events.

function OnButtonRollOut(GFxClikWidget.EventData ev)
{
	myHUD.ClearTooltip();
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_statuswindow'

	WidgetBindings.Add((WidgetName="labelNameLevel",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelDamage",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelCooldown",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelArmor",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelRange",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelDamageValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelCooldownValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelArmorValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelRangeValue",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelBuffs",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelShields",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelStructure",WidgetClass=class'GFxObject'))

	WidgetBindings.Add((WidgetName="btnPortrait",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnBuff0",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff2",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff3",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff4",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff5",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff6",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBuff7",WidgetClass=class'GFxClikWidget'))
}
