// ============================================================================
// HWGFxHUD_Submenus
// The HUD window allowing access to the Call Squad Member and Tactical
// Abilities submenus.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_submenus.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/04
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_Submenus extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxClikWidget BtnSelectSubmenuCallSM;
var GFxClikWidget BtnSelectSubmenuTactical;
var GFxClikWidget BtnSubmenu[3];
var GFxClikWidget BtnSurrender;
var GFxClikWidget BtnChatLog;

var HWGFxDialog DialogSurrender;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextSurrender;
var localized string LabelTextChatLog;

// ----------------------------------------------------------------------------
// Description texts.

var localized string TooltipSubmenuCallSquadMember;
var localized string TooltipSubmenuTacticalAbilities;
var localized string TooltipSubmenuCallSquadMemberDescription;
var localized string TooltipSubmenuTacticalAbilitiesDescription;

var localized string TooltipSurrender;
var localized string TooltipChatLog;
var localized string TooltipSurrenderDescription;
var localized string TooltipChatLogDescription;

// ----------------------------------------------------------------------------
// Dialog texts.

var localized string DialogTitleSurrender;
var localized string DialogMessageSurrender;

// ----------------------------------------------------------------------------
// Other variables.

/** The icon of the button used to switch to the Call Squad Member submenu. */
var Texture2D IconSelectSubmenuCallSM;

/** The icon of the button used to switch to the Tactical Abilities submenu. */
var Texture2D IconSelectSubmenuTactical;

/** The submenu that is currently shown. */
var enum ESubmenu
{
	SUBMENU_CallSquadMember,
	SUBMENU_TacticalAbilities
} CurrentSubmenu; // no states in non-Actor classes... :(


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('btnSelectSubmenuCallSM'):
			if (BtnSelectSubmenuCallSM == none)
			{
				BtnSelectSubmenuCallSM = GFxClikWidget(Widget);
				BtnSelectSubmenuCallSM.AddEventListener('CLIK_press', OnButtonPressSelectSubmenuCallSM);
				BtnSelectSubmenuCallSM.AddEventListener('CLIK_rollOver', OnButtonRollOverSelectSubmenuCallSM);
				BtnSelectSubmenuCallSM.AddEventListener('CLIK_rollOut',  OnButtonRollOut);

				SetExternalTexture("IconSelectSubmenuCallSM", IconSelectSubmenuCallSM);
				return true;
			}
            break;

		case ('btnSelectSubmenuTactical'):
			if (BtnSelectSubmenuTactical == none)
			{
				BtnSelectSubmenuTactical = GFxClikWidget(Widget);
				BtnSelectSubmenuTactical.AddEventListener('CLIK_press', OnButtonPressSelectSubmenuTactical);
				BtnSelectSubmenuTactical.AddEventListener('CLIK_rollOver', OnButtonRollOverSelectSubmenuTactical);
				BtnSelectSubmenuTactical.AddEventListener('CLIK_rollOut',  OnButtonRollOut);

				SetExternalTexture("IconSelectSubmenuTactical", IconSelectSubmenuTactical);
				return true;
			}
            break;

		case ('btnSubmenu0'):
			if (BtnSubmenu[0] == none)
			{
				BtnSubmenu[0] = GFxClikWidget(Widget);
				BtnSubmenu[0].AddEventListener('CLIK_press', OnButtonPressSubmenu0);
				BtnSubmenu[0].AddEventListener('CLIK_rollOver', OnButtonRollOverSubmenu0);
				BtnSubmenu[0].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnSubmenu1'):
			if (BtnSubmenu[1] == none)
			{
				BtnSubmenu[1] = GFxClikWidget(Widget);
				BtnSubmenu[1].AddEventListener('CLIK_press', OnButtonPressSubmenu1);
				BtnSubmenu[1].AddEventListener('CLIK_rollOver', OnButtonRollOverSubmenu1);
				BtnSubmenu[1].AddEventListener('CLIK_rollOut',  OnButtonRollOut);
				return true;
			}
            break;

		case ('btnSubmenu2'):
			if (BtnSubmenu[2] == none)
			{
				BtnSubmenu[2] = GFxClikWidget(Widget);
				BtnSubmenu[2].AddEventListener('CLIK_press', OnButtonPressSubmenu2);
				BtnSubmenu[2].AddEventListener('CLIK_rollOver', OnButtonRollOverSubmenu2);
				BtnSubmenu[2].AddEventListener('CLIK_rollOut',  OnButtonRollOut);

				return true;
			}
            break;

		case ('btnSurrender'):
			if (BtnSurrender == none)
			{
				BtnSurrender = GFxClikWidget(Widget);
				BtnSurrender.SetString("label", LabelTextSurrender);

				BtnSurrender.AddEventListener('CLIK_press', OnButtonPressSurrender);
				BtnSurrender.AddEventListener('CLIK_rollOver', OnButtonRollOverSurrender);
				BtnSurrender.AddEventListener('CLIK_rollOut',  OnButtonRollOut);

				return true;
			}
            break;

		case ('btnChatLog'):
			if (BtnChatLog == none)
			{
				BtnChatLog = GFxClikWidget(Widget);
				BtnChatLog.SetString("label", LabelTextChatLog);

				BtnChatLog.AddEventListener('CLIK_press', OnButtonPressChatLog);
				BtnChatLog.AddEventListener('CLIK_rollOver', OnButtonRollOverChatLog);
				BtnChatLog.AddEventListener('CLIK_rollOut',  OnButtonRollOut);

				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function bool Start(optional bool StartPaused = false)
{
	local bool bLoadErrors;

	bLoadErrors = super.Start(StartPaused);

	`log(`location);

	DialogSurrender = new class'HWGFxDialog';
	DialogSurrender.ShowView();
	DialogSurrender.InitDialogQuestion(DialogTitleSurrender, DialogMessageSurrender, OnDialogYesSurrender, OnDialogNoSurrender);
	DialogSurrender.HideView();

	return bLoadErrors; // (b && true = b)
}

/** Switches to the submenu specified by CurrentSubmenu. */
function Update()
{
	local int i;

	switch (CurrentSubmenu)
	{
		case SUBMENU_CallSquadMember:
			for (i = 0; i < 3; i++)
			{
				SetExternalTexture("IconSubmenu"$i, HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[i].default.UnitPortraitSubmenu);
			}
			break;

		case SUBMENU_TacticalAbilities:
			for (i = 0; i < 3; i++)
			{
				SetExternalTexture("IconSubmenu"$i, HWPlayerController(myHUD.PlayerOwner).Race.TacticalAbilities[i].default.AbilityIconSubmenu);
			}
			break;

		default:
			break;
	}
}

/**
 * Calls a squad member or triggers the tactical ability with the specified
 * index, depending on the submenu that is currently shown.
 * 
 * @param Index
 *      the index of the squad member to call or tactical ability to trigger
 */
function OnButtonPressSubmenu(int Index)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();

	switch (CurrentSubmenu)
	{
		case SUBMENU_CallSquadMember:
			HWPlayerController(myHUD.PlayerOwner).CallSquadMember(Index);
			break;

		case SUBMENU_TacticalAbilities:
			HWPlayerController(myHUD.PlayerOwner).ActivateTacticalAbilityByIndex(Index);
			break;

		default:
			break;
	}
}

/**
 * Shows the tooltip of the squad member or the tactical ability with the
 * specified index, depending on the submenu that is currently shown.
 * 
 * @param Index
 *      the index of the squad member or tactical ability to show the
 *      tooltip of
 */
function ShowTooltipForSubmenuButton(int Index)
{
	local string Title;
	local string Description;

	switch (CurrentSubmenu)
	{
		case SUBMENU_CallSquadMember:
			Title = HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[Index].default.MenuName;
			Description = HWPlayerController(myHUD.PlayerOwner).Race.SquadMemberClasses[Index].default.Description;
			
			ShowTooltipWithTitle(Title, Description, 
				class'HWGame'.static.GetHotkeyCallSquadmember(Index), 
				string(HWPlayerController(myHUD.PlayerOwner).GetSquadMemberCost()));
			break;

		case SUBMENU_TacticalAbilities:
			Title = HWPlayerController(myHUD.PlayerOwner).Race.TacticalAbilities[Index].default.AbilityName;
			Description = HWPlayerController(myHUD.PlayerOwner).Race.TacticalAbilities[Index].static.GetHTMLDescription();
			
			ShowTooltipWithTitle(Title, Description, 
				class'HWGame'.static.GetHotkeyTacticalAbility(Index), 
				string(HWPlayerController(myHUD.PlayerOwner).Race.TacticalAbilities[Index].static.GetShardsRequired()));
			break;

		default:
			break;
	}
}

/** Shows or hides the Surrender dialog. */
function ToggleDialogSurrender()
{
	if (DialogSurrender.bMovieIsOpen)
	{
		DialogSurrender.HideView();
	}
	else
	{
		DialogSurrender.ShowView();
	}
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressSelectSubmenuCallSM(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();

	CurrentSubmenu = SUBMENU_CallSquadMember;
	Update();
}

function OnButtonPressSelectSubmenuTactical(GFxClikWidget.EventData ev)
{
	HWPlayerController(myHUD.PlayerOwner).NotifyScaleformButtonClicked();

	CurrentSubmenu = SUBMENU_TacticalAbilities;
	Update();
}

function OnButtonPressSubmenu0(GFxClikWidget.EventData ev)
{
	OnButtonPressSubmenu(0);
}

function OnButtonPressSubmenu1(GFxClikWidget.EventData ev)
{
	OnButtonPressSubmenu(1);
}

function OnButtonPressSubmenu2(GFxClikWidget.EventData ev)
{
	OnButtonPressSubmenu(2);
}

function OnButtonPressSurrender(GFxClikWidget.EventData ev)
{
	DialogSurrender.ShowView();
}

function OnButtonPressChatLog(GFxClikWidget.EventData ev)
{
	myHUD.ShowChatLog();
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOverSelectSubmenuCallSM(GFxClikWidget.EventData ev)
{
	local string Description;

	Description = Repl(TooltipSubmenuCallSquadMemberDescription, "%1", "<b><font color=\"#FFFF00\">"$class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM$"</font></b>");
	Description = Repl(Description, "%2", "<b><font color=\"#FFFF00\">"$class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM / 2$"</font></b>");
	Description = Repl(Description, "%3", "<b><font color=\"#FFFF00\">"$class'HWSquadMember'.const.SQUAD_MEMBER_COST$"</font></b>");

	ShowTooltipWithTitle(TooltipSubmenuCallSquadMember, Description);
}

function OnButtonRollOverSelectSubmenuTactical(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipSubmenuTacticalAbilities, TooltipSubmenuTacticalAbilitiesDescription);
}

function OnButtonRollOverSubmenu0(GFxClikWidget.EventData ev)
{
	ShowTooltipForSubmenuButton(0);
}

function OnButtonRollOverSubmenu1(GFxClikWidget.EventData ev)
{
	ShowTooltipForSubmenuButton(1);
}

function OnButtonRollOverSubmenu2(GFxClikWidget.EventData ev)
{
	ShowTooltipForSubmenuButton(2);
}

function OnButtonRollOverSurrender(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipSurrender, TooltipSurrenderDescription);
}

function OnButtonRollOverChatLog(GFxClikWidget.EventData ev)
{
	ShowTooltipWithTitle(TooltipChatLog, TooltipChatLogDescription);
}

// ----------------------------------------------------------------------------
// Button OnRollOver events.

function OnButtonRollOut(GFxClikWidget.EventData ev)
{
	myHUD.ClearTooltip();
}

// ----------------------------------------------------------------------------
// Dialog events.

function OnDialogYesSurrender()
{
	DialogSurrender.Close(true);

	ConsoleCommand("open "$class'HWGame'.const.FRONTEND_MAP_NAME);
}

function OnDialogNoSurrender()
{
	DialogSurrender.HideView();
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_submenus'

	CurrentSubmenu=SUBMENU_CallSquadMember

	WidgetBindings.Add((WidgetName="btnSelectSubmenuCallSM",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSelectSubmenuTactical",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSubmenu0",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSubmenu1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSubmenu2",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSurrender",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnChatLog",WidgetClass=class'GFxClikWidget'))

	IconSelectSubmenuCallSM=Texture2D'UI_HWSubmenus.T_UI_SelectSubmenu_CallSquadMember_Test'
	IconSelectSubmenuTactical=Texture2D'UI_HWSubmenus.T_UI_SelectSubmenu_Tactical_Test'
}
