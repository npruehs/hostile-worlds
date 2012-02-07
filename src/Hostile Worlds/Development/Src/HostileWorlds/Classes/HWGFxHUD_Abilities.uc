// ============================================================================
// HWGFxHUD_Abilities
// The HUD window showing the portraits, ability buttons and Dismiss buttons
// of the selected unit(s).
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_abilities.fla
//
// Author:  Nick Pruehs
// Date:    2011/04/20
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_Abilities extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxClikWidget BtnPortrait[3];
var GFxClikWidget BtnAbility[12];
var GFxClikWidget BtnDismiss[3];

// ----------------------------------------------------------------------------
// Description texts.

var localized string TooltipCooldown;
var localized string TooltipShards;

var localized string TooltipDismiss;
var localized string TooltipDismissDescription;

// ----------------------------------------------------------------------------
// Other variables.

/** References to abilities, for showing tooltips. */
var HWAbility Abilities[12];


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('btnPortrait0'):
			if (BtnPortrait[0] == none)
			{
				BtnPortrait[0] = GFxClikWidget(Widget);
				BtnPortrait[0].AddEventListener('CLIK_press', OnButtonPressPortrait0);
				SetExternalTexture("IconPortrait0", HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[0].default.UnitPortrait);
				return true;
			}
            break;

		case ('btnPortrait1'):
			if (BtnPortrait[1] == none)
			{
				BtnPortrait[1] = GFxClikWidget(Widget);
				BtnPortrait[1].AddEventListener('CLIK_press', OnButtonPressPortrait1);
				SetExternalTexture("IconPortrait1", HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[1].default.UnitPortrait);
				return true;
			}
            break;

		case ('btnPortrait2'):
			if (BtnPortrait[2] == none)
			{
				BtnPortrait[2] = GFxClikWidget(Widget);
				BtnPortrait[2].AddEventListener('CLIK_press', OnButtonPressPortrait2);
				SetExternalTexture("IconPortrait2", HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[2].default.UnitPortrait);
				return true;
			}
            break;

		case ('btnAbility00'):
			if (BtnAbility[0] == none)
			{
				BtnAbility[0] = GFxClikWidget(Widget);
				BtnAbility[0].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility00);
				BtnAbility[0].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[0].AddEventListener('CLIK_press', OnButtonPressAbility00);
				return true;
			}
            break;

		case ('btnAbility10'):
			if (BtnAbility[1] == none)
			{
				BtnAbility[1] = GFxClikWidget(Widget);
				BtnAbility[1].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility10);
				BtnAbility[1].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[1].AddEventListener('CLIK_press', OnButtonPressAbility10);
				return true;
			}
            break;

		case ('btnAbility20'):
			if (BtnAbility[2] == none)
			{
				BtnAbility[2] = GFxClikWidget(Widget);
				BtnAbility[2].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility20);
				BtnAbility[2].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[2].AddEventListener('CLIK_press', OnButtonPressAbility20);
				return true;
			}
            break;

		case ('btnAbility30'):
			if (BtnAbility[3] == none)
			{
				BtnAbility[3] = GFxClikWidget(Widget);
				BtnAbility[3].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility30);
				BtnAbility[3].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[3].AddEventListener('CLIK_press', OnButtonPressAbility30);
				return true;
			}
            break;

		case ('btnAbility01'):
			if (BtnAbility[4] == none)
			{
				BtnAbility[4] = GFxClikWidget(Widget);
				BtnAbility[4].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility01);
				BtnAbility[4].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[4].AddEventListener('CLIK_press', OnButtonPressAbility01);
				return true;
			}
            break;

		case ('btnAbility11'):
			if (BtnAbility[5] == none)
			{
				BtnAbility[5] = GFxClikWidget(Widget);
				BtnAbility[5].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility11);
				BtnAbility[5].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[5].AddEventListener('CLIK_press', OnButtonPressAbility11);
				return true;
			}
            break;

		case ('btnAbility21'):
			if (BtnAbility[6] == none)
			{
				BtnAbility[6] = GFxClikWidget(Widget);
				BtnAbility[6].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility21);
				BtnAbility[6].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[6].AddEventListener('CLIK_press', OnButtonPressAbility21);
				return true;
			}
            break;

		case ('btnAbility31'):
			if (BtnAbility[7] == none)
			{
				BtnAbility[7] = GFxClikWidget(Widget);
				BtnAbility[7].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility31);
				BtnAbility[7].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[7].AddEventListener('CLIK_press', OnButtonPressAbility31);
				return true;
			}
            break;

		case ('btnAbility02'):
			if (BtnAbility[8] == none)
			{
				BtnAbility[8] = GFxClikWidget(Widget);
				BtnAbility[8].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility02);
				BtnAbility[8].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[8].AddEventListener('CLIK_press', OnButtonPressAbility02);
				return true;
			}
            break;

		case ('btnAbility12'):
			if (BtnAbility[9] == none)
			{
				BtnAbility[9] = GFxClikWidget(Widget);
				BtnAbility[9].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility12);
				BtnAbility[9].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[9].AddEventListener('CLIK_press', OnButtonPressAbility12);
				return true;
			}
            break;

		case ('btnAbility22'):
			if (BtnAbility[10] == none)
			{
				BtnAbility[10] = GFxClikWidget(Widget);
				BtnAbility[10].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility22);
				BtnAbility[10].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[10].AddEventListener('CLIK_press', OnButtonPressAbility22);
				return true;
			}
            break;

		case ('btnAbility32'):
			if (BtnAbility[11] == none)
			{
				BtnAbility[11] = GFxClikWidget(Widget);
				BtnAbility[11].AddEventListener('CLIK_rollOver', OnButtonRollOverAbility32);
				BtnAbility[11].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnAbility[11].AddEventListener('CLIK_press', OnButtonPressAbility32);
				return true;
			}
            break;

		case ('btnDismiss0'):
			if (BtnDismiss[0] == none)
			{
				BtnDismiss[0] = GFxClikWidget(Widget);
				BtnDismiss[0].AddEventListener('CLIK_rollOver', OnButtonRollOverDismiss0);
				BtnDismiss[0].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnDismiss[0].AddEventListener('CLIK_press', OnButtonPressDismiss0);
				return true;
			}
            break;

		case ('btnDismiss1'):
			if (BtnDismiss[1] == none)
			{
				BtnDismiss[1] = GFxClikWidget(Widget);
				BtnDismiss[1].AddEventListener('CLIK_rollOver', OnButtonRollOverDismiss1);
				BtnDismiss[1].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnDismiss[1].AddEventListener('CLIK_press', OnButtonPressDismiss1);
				return true;
			}
            break;

		case ('btnDismiss2'):
			if (BtnDismiss[2] == none)
			{
				BtnDismiss[2] = GFxClikWidget(Widget);
				BtnDismiss[2].AddEventListener('CLIK_rollOver', OnButtonRollOverDismiss2);
				BtnDismiss[2].AddEventListener('CLIK_rollOut',  ClearTooltip);
				BtnDismiss[2].AddEventListener('CLIK_press', OnButtonPressDismiss2);
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/** Updates all buttons based on the current selection of the local player. */
function Update()
{
	local HWPlayerController ThePlayer;
	
	ThePlayer = HWPlayerController(myHUD.PlayerOwner);

	UpdateSubSection(ThePlayer, ThePlayer.SelectedSquadMembers1, 0);
	UpdateSubSection(ThePlayer, ThePlayer.SelectedSquadMembers2, 1);
	UpdateSubSection(ThePlayer, ThePlayer.SelectedSquadMembers3, 2);
}

/**
 * Updates a the sub-section of this HUD window belonging to a specific squad
 * member class, showing or hiding the appropriate portrait and buttons as
 * specified in task #361:
 * 
 * http://hostileworlds.clockingit.com/tasks/edit/1710349
 * 
 * @param ThePlayer
 *      the local player
 * @param SquadMembers
 *      the list of squad members to check the abilities of
 * @param Index
 *      the index of the subsection to update
 */
function UpdateSubSection(HWPlayerController ThePlayer, array<HWSquadMember> SquadMembers, int Index)
{
	local int i;
	local Actor a;
	local HWSquadMember SquadMember;
	local HWSquadMember SelectedSquadMember;

	// check if any own squad members of that class are alive
	foreach ThePlayer.DynamicActors(ThePlayer.Race.SquadMemberClasses[Index], a)
	{
		SquadMember = HWSquadMember(a);

		if (SquadMember.OwningPlayer == ThePlayer && SquadMember.Health > 0)
		{
			// while any squad member of that class is alive: show all ability buttons and dismiss button of that class
			BtnPortrait[Index].SetBool("visible", true);
			BtnDismiss[Index].SetBool("visible", true);

			for (i = 0; i < 4; i++)
			{
				BtnAbility[Index * 4 + i].SetBool("visible", true);

				// cache a reference to any (maybe unlearned ability) for showing tooltips
				Abilities[Index * 4 + i] = SquadMember.Abilities[i];

                // assume the ability has not been learned yet by any selected squad member
				SetExternalTexture("IconAbility"$i$Index, SquadMember.Abilities[i].AbilityIcon);

				// look for a squad member with the ability
				foreach SquadMembers(SelectedSquadMember)
				{
					if (SelectedSquadMember.Abilities[i].bLearned)
					{
						// show colored version of the ability button
						SetExternalTexture("IconAbility"$i$Index, SelectedSquadMember.Abilities[i].AbilityIconColored);
					}
				}
			}

			if (SquadMembers.Length > 0)
			{
				// while a squad member of that class is selected: show colored portrait of that class
				SetExternalTexture("IconPortrait"$Index, HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[Index].default.UnitPortrait);
			}
			else
			{
				// while no squad member of that class is selected: show colorless portrait of that class
				SetExternalTexture("IconPortrait"$Index, HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[Index].default.UnitPortraitNotSelected);
			}

			return;
		}
	}

	// while no squad member of that class is alive: hide portrait and all buttons of that class
	BtnPortrait[Index].SetBool("visible", false);
	BtnDismiss[Index].SetBool("visible", false);

	for (i = 0; i < 4; i++)
	{
		BtnAbility[Index * 4 + i].SetBool("visible", false);
	}
}

/**
 * Triggers the ability with the specified index of the class with the passed
 * index, or promotes a squad member to learn that ability if no one has
 * learned it yet. If no squad members are selected at all, all culled squad
 * members of that class are selected first.
 * 
 * @param AbilityIndex
 *      the index of the ability to trigger
 * @param ClassIndex
 *      the index of squad member class within the race squad member array
 *      of the local player
 */
function TriggerAbility(int AbilityIndex, int ClassIndex)
{
	local HWPlayerController LocalHWPlayer;
	local HWSquadMember SquadMember;
	local array<HWSquadMember> SelectedSquadMembers;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);
	SelectedSquadMembers = LocalHWPlayer.FindSelectedSquadMembersByClassIndex(ClassIndex);

	// if no units of the specified class are selected, try to select all culled ones
	if (SelectedSquadMembers.Length == 0)
	{
		LocalHWPlayer.SelectCulledSquadMembersByClassIndex(ClassIndex, false);
	}

	SelectedSquadMembers = LocalHWPlayer.FindSelectedSquadMembersByClassIndex(ClassIndex);

	if (SelectedSquadMembers.Length > 0)
	{
		// look for a squad member with the ability
		foreach SelectedSquadMembers(SquadMember)
		{
			if (SquadMember.Abilities[AbilityIndex].bLearned)
			{
				// if any squad member has already learned the ability, trigger it
				LocalHWPlayer.ActivateAbility(SquadMember.Abilities[AbilityIndex]);
				return;
			}
		}

		// if no squad member has the ability, promote one
		SquadMember = SelectedSquadMembers[0];
		LocalHWPlayer.ActivateAbility(SquadMember.Abilities[AbilityIndex]);
	}
}

/**
 * Shows the tooltip for the passed ability with the specified index within
 * its owning squad member's ability index.
 * 
 * @param Ability
 *      the ability to show the tooltip of
 * @param Index
 *      the index of the ability within its owning squad member's ability array
 */
function ShowTooltipForAbility(HWAbility Ability, int Index)
{
	local string Tooltip;

	// show hotkey
	switch (Index)
	{
		case 0:
			Tooltip = "<b><font color=\"#FFFF00\">[Q] ";
			break;

		case 1:
			Tooltip = "<b><font color=\"#FFFF00\">[W] ";
			break;

		case 2:
			Tooltip = "<b><font color=\"#FFFF00\">[E] ";
			break;

		case 3:
			Tooltip = "<b><font color=\"#FFFF00\">[R] ";
			break;

		default:
			break;
	}

	// show ability name
	Tooltip $= Ability.AbilityName$"</font></b>";
	Tooltip $= "<br />";
	
	// show cooldown
	Tooltip $= TooltipCooldown$": "$int(Ability.Cooldown)$" s";
	Tooltip $= "<br />";

	// show costs
	if (Ability.ShardsRequired > 0)
	{
		Tooltip $= TooltipShards$": "$Ability.ShardsRequired;
		Tooltip $= "<br />";
	}

	// show ability description
	Tooltip $= "<br />";
	Tooltip $= Ability.GetHTMLDescription();

	myHUD.ShowTooltip(Tooltip);
}

/**
 * Shows the tooltip for dismissing the strongest selected squad member of the
 * class with the specified index within the squad member class array of the
 * race of the local player.
 * 
 * @param Index
 *      the index of the squad member class to dismiss a squad member of
 */
function ShowTooltipForDismissButton(int Index)
{
	local HWSquadMember SquadMember;
	local string Tooltip;
	
	// get the squad member that would be dismissed if the button is clicked
	SquadMember = HWPlayerController(myHUD.PlayerOwner).FindWeakestSquadMemberByClassIndex(Index);

	// get its name and the number of shards awarded
	Tooltip = Repl(TooltipDismissDescription, "%1", class'HWHud'.static.HTMLMarkup(SquadMember.MenuName));
	Tooltip = Repl(Tooltip, "%2", class'HWHud'.static.HTMLMarkup(SquadMember.ShardsEarnedWhenDismissed()));

	// show tooltip
	ShowTooltipWithTitle(TooltipDismiss, Tooltip);
}

/** Clears the ability tooltip. */
function ClearTooltip(GFxClikWidget.EventData ev)
{
	myHUD.ClearTooltip();
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressPortrait0(GFxClikWidget.EventData ev)
{
	local HWPlayerController LocalHWPlayer;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);

	LocalHWPlayer.NotifyScaleformButtonClicked();
	LocalHWPlayer.SelectCulledSquadMembersByClassIndex(0);
}

function OnButtonPressPortrait1(GFxClikWidget.EventData ev)
{
	local HWPlayerController LocalHWPlayer;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);

	LocalHWPlayer.NotifyScaleformButtonClicked();
	LocalHWPlayer.SelectCulledSquadMembersByClassIndex(1);
}

function OnButtonPressPortrait2(GFxClikWidget.EventData ev)
{
	local HWPlayerController LocalHWPlayer;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);

	LocalHWPlayer.NotifyScaleformButtonClicked();
	LocalHWPlayer.SelectCulledSquadMembersByClassIndex(2);
}

function OnButtonPressAbility00(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(0, 0);
}

function OnButtonPressAbility10(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(1, 0);
}

function OnButtonPressAbility20(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(2, 0);
}

function OnButtonPressAbility30(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(3, 0);
}

function OnButtonPressAbility01(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(0, 1);
}

function OnButtonPressAbility11(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(1, 1);
}

function OnButtonPressAbility21(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(2, 1);
}

function OnButtonPressAbility31(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(3, 1);
}

function OnButtonPressAbility02(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(0, 2);
}

function OnButtonPressAbility12(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(1, 2);
}

function OnButtonPressAbility22(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(2, 2);
}

function OnButtonPressAbility32(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();
	TriggerAbility(3, 2);
}

function OnButtonPressDismiss0(GFxClikWidget.EventData ev)
{
	local HWPlayerController LocalHWPlayer;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);

	LocalHWPlayer.NotifyScaleformButtonClicked();
	LocalHWPlayer.DismissWeakestSquadMemberByClassIndex(0);
}

function OnButtonPressDismiss1(GFxClikWidget.EventData ev)
{
	local HWPlayerController LocalHWPlayer;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);

	LocalHWPlayer.NotifyScaleformButtonClicked();
	LocalHWPlayer.DismissWeakestSquadMemberByClassIndex(1);
}

function OnButtonPressDismiss2(GFxClikWidget.EventData ev)
{
	local HWPlayerController LocalHWPlayer;

	LocalHWPlayer = HWPlayerController(myHUD.PlayerOwner);

	LocalHWPlayer.NotifyScaleformButtonClicked();
	LocalHWPlayer.DismissWeakestSquadMemberByClassIndex(2);
}

// ----------------------------------------------------------------------------
// OnRollOver events.

function OnButtonRollOverAbility00(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[0], 0);
}

function OnButtonRollOverAbility10(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[1], 1);
}

function OnButtonRollOverAbility20(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[2], 2);
}

function OnButtonRollOverAbility30(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[3], 3);
}

function OnButtonRollOverAbility01(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[4], 0);
}

function OnButtonRollOverAbility11(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[5], 1);
}

function OnButtonRollOverAbility21(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[6], 2);
}

function OnButtonRollOverAbility31(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[7], 3);
}

function OnButtonRollOverAbility02(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[8], 0);
}

function OnButtonRollOverAbility12(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[9], 1);
}

function OnButtonRollOverAbility22(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[10], 2);
}

function OnButtonRollOverAbility32(GFxClikWidget.EventData ev)
{
	ShowTooltipForAbility(Abilities[11], 3);
}

function OnButtonRollOverDismiss0(GFxClikWidget.EventData ev)
{
	ShowTooltipForDismissButton(0);
}

function OnButtonRollOverDismiss1(GFxClikWidget.EventData ev)
{
	ShowTooltipForDismissButton(1);
}

function OnButtonRollOverDismiss2(GFxClikWidget.EventData ev)
{
	ShowTooltipForDismissButton(2);
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_abilities'

	WidgetBindings.Add((WidgetName="btnPortrait0",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnPortrait1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnPortrait2",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnAbility00",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility10",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility20",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility30",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility01",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility11",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility21",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility31",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility02",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility12",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility22",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnAbility32",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnDismiss0",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnDismiss1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnDismiss2",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="textAreaTooltip",WidgetClass=class'GFxClikWidget'))
}
