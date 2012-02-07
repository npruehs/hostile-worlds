// ============================================================================
// HWGFxHUD_VictoryPoints
// The HUD window showing the current team scores and the score limit.
//
// Related Flash content: UDKGame/Flash/HWHud/hwhud_victorypoints.fla
//
// Author:  Nick Pruehs
// Date:    2011/05/09
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxHUD_VictoryPoints extends HWGFxHUDView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelTeam1;
var GFxObject LabelTeam2;
var GFxObject LabelTeam1VictoryPoints;
var GFxObject LabelTeam2VictoryPoints;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextTeam1;
var localized string LabelTextTeam2;


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
		case ('labelTeam1'):
			if (LabelTeam1 == none)
			{
				LabelTeam1 = Widget;
				LabelTeam1.SetString("htmlText", "<b><font color=\"#00FF00\">"$LabelTextTeam1$"</font></b>");
				return true;
			}
            break;

		case ('labelTeam2'):
			if (LabelTeam2 == none)
			{
				LabelTeam2 = Widget;
				LabelTeam2.SetString("htmlText", "<b><font color=\"#0000FF\">"$LabelTextTeam2$"</font></b>");
				return true;
			}
            break;

		case ('labelTeam1VictoryPoints'):
			if (LabelTeam1VictoryPoints == none)
			{
				LabelTeam1VictoryPoints = Widget;
				return true;
			}
            break;

		case ('labelTeam2VictoryPoints'):
			if (LabelTeam2VictoryPoints == none)
			{
				LabelTeam2VictoryPoints = Widget;
				return true;
			}
            break;

        default:
            break;
    }

	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/**
 * Updates this scores window, showing the passed team scores and score limit.
 * 
 * @param Team1Score
 *      the current score of team 1
 * @param Team2Score
 *      the current score of team 2
 * @param ScoreLimit
 *      the score limit of the current match
 */
function Update(optional int Team1Score, optional int Team2Score, optional int ScoreLimit)
{
	// use default score if this is the initializing update call
	if (ScoreLimit <= 0)
	{
		ScoreLimit = class'HWGame'.default.GoalScore;
	}

	// clamp team scores to the score limit for passing them to the progress bar
	Team1Score = Min(Team1Score, ScoreLimit);
	Team2Score = Min(Team2Score, ScoreLimit);

	// update labels and progress bars
	LabelTeam1VictoryPoints.SetString("htmlText", "<b><font color=\"#00FF00\">"$Team1Score$" / "$ScoreLimit$"</font></b>");
	LabelTeam2VictoryPoints.SetString("htmlText", "<b><font color=\"#0000FF\">"$Team2Score$" / "$ScoreLimit$"</font></b>");

	ASSetScores(Team1Score, Team2Score, ScoreLimit);
}

/**
 * Calls the appropriate ActionScript function to update the progress bars of
 * this scores window.
 * 
 * @param Team1Score
 *      the current score of team 1
 * @param Team2Score
 *      the current score of team 2
 * @param ScoreLimit
 *      the score limit of the current match
 */
function ASSetScores(int Team1Score, int Team2Score, int ScoreLimit)
{
	ActionScriptVoid("setScores");
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWHud.hwhud_victorypoints'

	WidgetBindings.Add((WidgetName="labelTeam1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1VictoryPoints",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2VictoryPoints",WidgetClass=class'GFxObject'))
}
