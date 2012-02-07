// ============================================================================
// HWGFxScreen_Scores
// The Scores screen of Hostile Worlds. Gives all players an overview of what
// they've achieved during the match. Note that this screen is not managed
// by the frontend.
//
// Related Flash content: UDKGame/Flash/HWScreens/hw_scorescreen.fla
//
// Author:  Nick Pruehs
// Date:    2011/04/11
// 
// (C) 2011 2nd Reality Studios. All Rights Reserved.
// ============================================================================
class HWGFxScreen_Scores extends HWGFxView;

// ----------------------------------------------------------------------------
// Widgets.

var GFxObject LabelOutcome;
var GFxObject LabelMapTime;
var GFxObject LabelTeam1;
var GFxObject LabelTeam2;
var GFxObject LabelTeam1Players[4];
var GFxObject LabelTeam2Players[4];
var GFxClikWidget ButtonBarTabs;
var GFxClikWidget ButtonBarStats;
var GFxClikWidget ListStatsTeam1Columns[5];
var GFxClikWidget ListStatsTeam2Columns[5];
var GFxClikWidget BtnBackToMainMenu;

// ----------------------------------------------------------------------------
// Labels and captions.

var localized string LabelTextOutcomeVictory;
var localized string LabelTextOutcomeDefeat;
var localized string LabelTextTimePlayed;
var localized string LabelTextTeam1;
var localized string LabelTextTeam2;
var localized string ButtonBarTextTabs[6];
var localized string ButtonBarTextOverview[5];
var localized string ButtonBarTextUnits[5];
var localized string ButtonBarTextResources[5];
var localized string ButtonBarTextCombat[5];
var localized string ButtonBarTextAbilities[5];
var localized string ButtonBarTextTerrain[5];
var localized string BtnTextBackToMainMenu;

/** The results to show. */
var HWGameResults Results;


function bool Start(optional bool StartPaused = false)
{
	local bool bLoadErrors;

	bLoadErrors = super.Start(StartPaused);

	// pause the game running in the background
	ConsoleCommand("pause");

	return bLoadErrors;
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local array<string> EmptyList;
	local array<string> TabCaptions;
	local int i;

	EmptyList.Length = 0;

    switch (WidgetName)
    {
        case ('labelOutcome'): 
            if (LabelOutcome == none)
            {
				LabelOutcome = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelMapTime'): 
            if (LabelMapTime == none)
            {
				LabelMapTime = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1'): 
            if (LabelTeam1 == none)
            {
				LabelTeam1 = InitLabel(Widget, WidgetName, LabelTextTeam1);
				return true;
            }
            break;

        case ('labelTeam2'): 
            if (LabelTeam2 == none)
            {
				LabelTeam2 = InitLabel(Widget, WidgetName, LabelTextTeam2);
				return true;
            }
            break;

        case ('labelTeam1Player1'): 
            if (LabelTeam1Players[0] == none)
            {
				LabelTeam1Players[0] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1Player2'): 
            if (LabelTeam1Players[1] == none)
            {
				LabelTeam1Players[1] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1Player3'): 
            if (LabelTeam1Players[2] == none)
            {
				LabelTeam1Players[2] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam1Player4'): 
            if (LabelTeam1Players[3] == none)
            {
				LabelTeam1Players[3] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

       case ('labelTeam2Player1'): 
            if (LabelTeam2Players[0] == none)
            {
				LabelTeam2Players[0] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam2Player2'): 
            if (LabelTeam2Players[1] == none)
            {
				LabelTeam2Players[1] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam2Player3'): 
            if (LabelTeam2Players[2] == none)
            {
				LabelTeam2Players[2] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

        case ('labelTeam2Player4'): 
            if (LabelTeam2Players[3] == none)
            {
				LabelTeam2Players[3] = InitLabel(Widget, WidgetName, "");
				return true;
            }
            break;

		case ('buttonBarTabs'):
			if (ButtonBarTabs == none)
			{
				for (i = 0; i < 6; i++)
				{
					TabCaptions[i] = ButtonBarTextTabs[i];
				}

				ButtonBarTabs = InitList(Widget, WidgetName, TabCaptions, OnButtonBarChangeTabs);
				return true;
			}
			break;

		case ('buttonBarStats'):
			if (ButtonBarStats == none)
			{
				ButtonBarStats = InitList(Widget, WidgetName, EmptyList, OnButtonBarChangeStats);
				return true;
			}
			break;

		case ('listStatsTeam1Column1'):
			if (ListStatsTeam1Columns[0] == none)
			{
				ListStatsTeam1Columns[0] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam1Column2'):
			if (ListStatsTeam1Columns[1] == none)
			{
				ListStatsTeam1Columns[1] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam1Column3'):
			if (ListStatsTeam1Columns[2] == none)
			{
				ListStatsTeam1Columns[2] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam1Column4'):
			if (ListStatsTeam1Columns[3] == none)
			{
				ListStatsTeam1Columns[3] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam1Column5'):
			if (ListStatsTeam1Columns[4] == none)
			{
				ListStatsTeam1Columns[4] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam2Column1'):
			if (ListStatsTeam2Columns[0] == none)
			{
				ListStatsTeam2Columns[0] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam2Column2'):
			if (ListStatsTeam2Columns[1] == none)
			{
				ListStatsTeam2Columns[1] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam2Column3'):
			if (ListStatsTeam2Columns[2] == none)
			{
				ListStatsTeam2Columns[2] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam2Column4'):
			if (ListStatsTeam2Columns[3] == none)
			{
				ListStatsTeam2Columns[3] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('listStatsTeam2Column5'):
			if (ListStatsTeam2Columns[4] == none)
			{
				ListStatsTeam2Columns[4] = InitList(Widget, WidgetName, EmptyList, none);
				return true;
			}
			break;

		case ('btnBackToMainMenu'):
			if (BtnBackToMainMenu == none)
			{
				BtnBackToMainMenu = InitButton(Widget, WidgetName, BtnTextBackToMainMenu, OnButtonPressBackToMainMenu);
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
	local HWPlayerController ThePlayer;
	local string MapAndTime;
	local int ElapsedMinutes;
	local int ElapsedSeconds;
	local int i;

	super.ShowView();

	ThePlayer = HWPlayerController(GetPC());
	Results = ThePlayer.Results;

	// show outcome
	if (ThePlayer.bWinner)
	{
		LabelOutcome.SetText(LabelTextOutcomeVictory);
	}
	else
	{
		LabelOutcome.SetText(LabelTextOutcomeDefeat);
	}

	// show map and time
	ElapsedMinutes = Results.MapTime / 60;
	ElapsedSeconds = Results.MapTime % 60;

	MapAndTime = ThePlayer.Results.MapName;
	MapAndTime $= " - ";
	MapAndTime $= LabelTextTimePlayed$": "$ElapsedMinutes$":"$ElapsedSeconds;
	
	LabelMapTime.SetText(MapAndTime);

	// show player names
	for (i = 0; i < 4; i++)
	{
		if (Results.PlayerNames[i] != "")
		{
			LabelTeam1Players[i].SetText(Results.PlayerNames[i]);
		}
	}

	for (i = 0; i < 4; i++)
	{
		if (Results.PlayerNames[i + 4] != "")
		{
			LabelTeam2Players[i].SetText(Results.PlayerNames[i + 4]);
		}
	}

	// show scores overview
	ShowScoresOverview();
}

// ----------------------------------------------------------------------------
// Button OnPress events.

function OnButtonPressBackToMainMenu(GFxClikWidget.EventData ev)
{
	ConsoleCommand("open "$class'HWGame'.const.FRONTEND_MAP_NAME);
}

// ----------------------------------------------------------------------------
// OnButtonBarChange events.

function OnButtonBarChangeTabs(GFxClikWidget.EventData ev)
{
	switch (ev.Index)
	{
		case 0:
			ShowScoresOverview();
			break;
		case 1:
			ShowScoresUnits();
			break;
		case 2:
			ShowScoresResources();
			break;
		case 3:
			ShowScoresCombat();
			break;
		case 4:
			ShowScoresAbilities();
			break;
		case 5:
			ShowScoresTerrain();
			break;
		default:
			break;
	}
}

function OnButtonBarChangeStats(GFxClikWidget.EventData ev)
{
	// TODO add column sorting
}

/** Shows the meta scores of all players. */
function ShowScoresOverview()
{
	ChangeColumnTitles(ButtonBarTextOverview, 5);

	FillScoresColumn(Results.ScoresUnits, 0);
	FillScoresColumn(Results.ScoresResources, 1);
	FillScoresColumn(Results.ScoresCombat, 2);
	FillScoresColumn(Results.ScoresAbilities, 3);
	FillScoresColumn(Results.ScoresTotal, 4);
}

/** Shows the unit scores of all players. */
function ShowScoresUnits()
{
	ChangeColumnTitles(ButtonBarTextUnits, 5);

	FillScoresColumn(Results.TotalAliensKilled, 0);
	FillScoresColumn(Results.TotalSquadMembersKilled, 1);
	FillScoresColumn(Results.TotalSquadMembersLost, 2);
	FillScoresColumn(Results.TotalSquadMembersDismissed, 3);
	FillScoresColumn(Results.TotalReinforcementsCalled, 4);
}

/** Shows the resource scores of all players. */
function ShowScoresResources()
{
	ChangeColumnTitles(ButtonBarTextResources, 4);

	FillScoresColumn(Results.TotalShardsFarmed, 0);
	FillScoresColumn(Results.TotalArtifactsAcquired, 1);
	FillScoresColumn(Results.TotalVision, 2);
	FillScoresColumn(Results.TotalActions, 3);
	ClearScoresColumn(4);
}

/** Shows the combat scores of all players. */
function ShowScoresCombat()
{
	ChangeColumnTitles(ButtonBarTextCombat, 3);

	FillScoresColumn(Results.TotalDamageDealt, 0);
	FillScoresColumn(Results.TotalDamageTaken, 1);
	FillScoresColumn(Results.TotalDamageHealed, 2);
	ClearScoresColumn(3);
	ClearScoresColumn(4);
}

/** Shows the ability scores of all players. */
function ShowScoresAbilities()
{
	ChangeColumnTitles(ButtonBarTextAbilities, 4);

	FillScoresColumn(Results.TotalAbilitiesTriggered, 0);
	FillScoresColumn(Results.TotalTacticalAbilitiesTriggered, 1);
	FillScoresColumn(Results.TotalKnockbacksCaused, 2);
	FillScoresColumn(Results.TotalKnockbacksTaken, 3);
	ClearScoresColumn(4);
}

/** Shows the terrain scores of all players. */
function ShowScoresTerrain()
{
	ChangeColumnTitles(ButtonBarTextTerrain, 3);

	FillScoresColumn(Results.TotalTimeSpentInDamageArea, 0);
	FillScoresColumn(Results.TotalTimeSpentInSlowArea, 1);
	FillScoresColumn(Results.TotalTowersCaptured, 2);
	ClearScoresColumn(3);
	ClearScoresColumn(4);
}

/**
 * Shows the passed column headers.
 * 
 * @param Titles
 *      the column titles to show
 * @param ColumnCount
 *      the number of columns to grab from the passed array
 */
function ChangeColumnTitles(string Titles[5], int ColumnCount)
{
	local GFxObject DataProvider;
	local int i;

	DataProvider = CreateArray();

    for (i = 0; i < ColumnCount; i++)
    {
		DataProvider.SetElementString(i, Titles[i]);
    }

    ButtonBarStats.SetObject("dataProvider", DataProvider);
}

/**
 * Shows the passed values in the scores column with the specified index.
 * 
 * @param Values
 *      the values to show
 * @param Column
 *      the index of the column to fill
 */
function FillScoresColumn(int Values[8], int Column)
{
	local GFxObject DataProvider;
	local int i;

	// show team 1 stats
	DataProvider = CreateArray();

    for (i = 0; i < 4; i++)
    {
		if (Results.PlayerNames[i] != "")
		{
			DataProvider.SetElementString(i, string(Values[i]));
		}
    }

    ListStatsTeam1Columns[Column].SetObject("dataProvider", DataProvider);

	// show team 2 stats
	DataProvider = CreateArray();

    for (i = 0; i < 4; i++)
    {
		if (Results.PlayerNames[i + 4] != "")
		{
			DataProvider.SetElementString(i, string(Values[i + 4]) );
		}
    }

    ListStatsTeam2Columns[Column].SetObject("dataProvider", DataProvider); 
}

/**
 * Clears the scores column with the specified index.
 * 
 * @param Column
 *      the index of the column to clear
 */
function ClearScoresColumn(int Column)
{
	local GFxObject DataProvider;

	// clear team 1 stats
	DataProvider = CreateArray();
    ListStatsTeam1Columns[Column].SetObject("dataProvider", DataProvider);

	// clear team 2 stats
	DataProvider = CreateArray();
    ListStatsTeam2Columns[Column].SetObject("dataProvider", DataProvider); 
}


DefaultProperties
{
	MovieInfo=SwfMovie'UI_HWScreens.hw_scorescreen'

	WidgetBindings.Add((WidgetName="labelOutcome",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelMapTime",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player3",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam1Player4",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player1",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player2",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player3",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="labelTeam2Player4",WidgetClass=class'GFxObject'))

	WidgetBindings.Add((WidgetName="buttonBarTabs",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="buttonBarStats",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam1Column1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam1Column2",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam1Column3",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam1Column4",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam1Column5",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam2Column1",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam2Column2",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam2Column3",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam2Column4",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="listStatsTeam2Column5",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackToMainMenu",WidgetClass=class'GFxClikWidget'))
}
