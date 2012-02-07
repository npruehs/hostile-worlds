// ============================================================================
// HWGFxHUD_InfoBar
// The HUD window showing the current shards and squad members of the local
// player, and the game clock.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_infobar.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/10
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_InfoBar extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelShards;
var GFxObject LabelSquadMembers;
var GFxObject LabelTime;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('labelShards'):
			if (LabelShards == none)
			{
				LabelShards = Widget;
				return true;
			}
            break;

		case ('labelSquadMembers'):
			if (LabelSquadMembers == none)
			{
				LabelSquadMembers = Widget;
				return true;
			}
            break;

		case ('labelTime'):
			if (LabelTime == none)
			{
				LabelTime = Widget;
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/** Updates the shards, squad members and game clock of this info bar. */
function Update()
{
	local HWPlayerController PC;
	local string Text;
	local GameReplicationInfo GRI;
	local int ElapsedMinutes;
	local int ElapsedSeconds;
	
	PC = HWPlayerController(GetPC());

	// update shards
	Text = string(PC.Shards);
	LabelShards.SetText(Text);

	// update squad members
	Text = PC.SquadMembers$" / "$class'HWSquadMember'.const.SQUAD_MEMBERS_MAXIMUM;
	LabelSquadMembers.SetText(Text);

	// update clock
	GRI = GetPC().WorldInfo.GRI;

	if (GRI != none)
	{
		ElapsedMinutes = GRI.RemainingTime / 60;
		ElapsedSeconds = GRI.RemainingTime % 60;

		Text = ElapsedMinutes$":"$((ElapsedSeconds < 10) ? "0" : "")$ElapsedSeconds;
		LabelTime.SetText(Text);
	}

	// update alien rage
	ASSetAlienRage(PC.AlienRage, 1.0f);
}

/**
 * Calls the appropriate ActionScript function to update the alien rage bar of
 * this info bar window.
 * 
 * @param AlienRageCurrent
 *      the current alien rage level of the local player
 * @param AlienRageMax
 *      the maximum alien rage level
 */
function ASSetAlienRage(float AlienRageCurrent, float AlienRageMax)
{
	ActionScriptVoid("setAlienRage");
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_infobar'

	WidgetBindings.Add((WidgetName="labelShards",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelSquadMembers",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTime",WidgetClass=class'GFxObject'))
}
