/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTUITabPage_InGame extends UTTabPage;

var transient UIPanel PlayerPanel;

var transient UILabel TeamScore[2];
var transient UILabel MOTD;
var transient UILabel ConText;
var transient UILabel Servername;

var transient bool bShowingRules;
var transient int ConsoleTextCnt;

var transient bool bEndOfMatch;
var transient bool bTeamGame;

var transient UTUIButtonBar MyButtonBar;
var transient int RulesButtonIndex;

var transient string MOTDText;

var bool bCensor;

/** list of local maps - used to get more friendly names when possible */
var array<UTUIDataProvider_MapInfo> LocalMapList;

function PostInitialize()
{
	local UTConsole Con;
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local UTUIScene UTSceneOwner;
	local UDKPlayerController PC;
	local EFeaturePrivilegeLevel Level;
	local int i;
	local array<UDKUIResourceDataProvider> ProviderList;

	// Find Everything
	TeamScore[0] = UILabel(FindChild('RedScore',true));
	TeamScore[1] = UILabel(FindChild('BlueScore',true));

	MOTD = UILabel(FindChild('MOTD',true));
	ServerName = UILabel(FindChild('ServerName',true));

	SetMessageOfTheDay();

	PlayerPanel = UIPanel(FindChild('PlayerPanel',true));

	// Copy of the console...
	Con = UTConsole(GetPlayerOwner().ViewportClient.ViewportConsole);
	if (Con != none)
	{
		ConsoleTextCnt = Con.TextCount - 5;
	}

	// Precache if it's a team game or not

	UTSceneOwner = UTUIScene(GetScene());
	WI = UTSceneOwner.GetWorldInfo();
	if ( WI != none )
	{
		GRI = UTGameReplicationInfo(WI.GRI);
		if ( GRI != none )
		{
			bTeamGame = GRI.GameClass.default.bTeamGame;
		}
	}

	PC = UTSceneOwner.GetUDKPlayerOwner();
	if (PC != none )
	{
		Level = PC.OnlineSub.PlayerInterface.CanCommunicate( LocalPlayer(PC.Player).ControllerId );
		bCensor = Level != FPL_Enabled;
	}

	// fill the local map list
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', ProviderList);
	for (i = 0; i < ProviderList.length; i++)
	{
		LocalMapList.AddItem(UTUIDataProvider_MapInfo(ProviderList[i]));
	}
}


/**
 * Looks up the Message of the Day and sets it
 */
function SetMessageOfTheDay()
{
	local worldinfo WI;
	local UTGameReplicationInfo GRI;
	local UTUIDataStore_MenuItems MenuItems;
	local UTUIScene Parent;
	local string x;
	local int index;

    Parent = UTUIScene(GetScene());
	WI = Parent.GetWorldInfo();
	if ( WI != none )
	{
		GRI = UTGameReplicationInfo(WI.GRI);
		if ( GRI != none )
		{
			if (bCensor || WI.NetMode == NM_StandALone || GRI.bStoryMode )
			{
				MenuItems = UTUIDataStore_MenuItems(Parent.FindDataStore('UTMenuITems'));

				if ( MenuItems != none )
				{
					X = WI.GetMapName(true);

					Index = MenuItems.FindValueInProviderSet('Maps','MapName',x);
					if (Index != INDEX_None)
					{
						MenuItems.GetValueFromProviderSet('Maps','Description',Index,MOTDText);
					}
					ServerName.SetDataStoreBinding(X);
				}
			}
			else
			{
				MOTDText = GRI.MessageOfTheDay;
				ServerName.SetDatastoreBinding(GRI.ServerName);
			}

			MOTD.SetDatastoreBinding(MOTDText);

		}
	}
}

/**
 * This tab is being ticked
 */
function TabTick(float DeltaTime)
{
	// Update the game's status
	CheckGameStatus();
}

function OnMenuItemChosen(UDKSimpleList SourceList, int SelectedIndex, int PlayerIndex)
{
	local UTGameReplicationInfo GRI;
	local UTPlayerController UTPC;
	local UTUIScene_MidGameMenu MGM;

	MGM = UTUIScene_MidGameMenu(GetScene());
	GRI = UTGameReplicationInfo(UTUIScene(GetScene()).GetWorldInfo().GRI);
	UTPC = UTPlayerController(MGM.GetUDKPlayerOwner(PlayerIndex));
	if ( GRI != none )
	{
		if ( GRI.MidMenuMenu(UTPC,SourceList, SelectedIndex) )
		{
			MGM.Back();
		}
	}
}
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	local worldinfo WI;
	local UTGameReplicationInfo GRI;

	WI = UTUIScene(GetScene()).GetWorldInfo();
	Super.SetupButtonBar(ButtonBar);

	if ( WI != none )
	{
		GRI = UTGameReplicationInfo(WI.GRI);
		if ( GRI != none && GRI.CanChangeTeam() )
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ChangeTeam>",OnChangeTeam) ;
		}
	}

	RulesButtonIndex = ButtonBar.AppendButton("<Strings:UTGameUI.MidGameMenu.Rules>",RulesButtonClicked);
	MyButtonBar = ButtonBar;

}

function bool OnChangeTeam(UIScreenObject InButton, int InPlayerIndex)
{
	local LocalPlayer LP;

   	LP = GetPlayerOwner(InPlayerIndex);
	if ( LP != none && LP.Actor != none )
	{
		LP.Actor.ChangeTeam();
		CloseParentScene();
	}
	return true;
}


function bool RulesButtonClicked(UIScreenObject EventObject, int PlayerIndex)
{
	local string Work,t;
	bShowingRules = !bShowingRules;

	if (bShowingRules)
	{
		MyButtonBar.Buttons[RulesButtonIndex].SetCaption("<Strings:UTGameUI.MidGameMenu.MOTD>");

		Work = "<CurrentGame:RulesString>";
		t = UTGameReplicationInfo(GetScene().GetWorldInfo().GRI).MutatorList;
		if ( t  != "" )
		{
			Work $= "\n-<Strings:UTGameUI.FrontEnd.TabCaption_Mutators>-\n";
			work $= ParseMutatorList(t);
		}

		MOTD.SetDatastoreBinding(Work);
	}
	else
	{
		MOTD.SetDatastoreBinding(MOTDText);
		MyButtonBar.Buttons[RulesButtonIndex].SetCaption("<Strings:UTGameUI.MidGameMenu.Rules>");
	}
	return true;
}

function string ParseMutatorList(string t)
{
	local int p,i;
	local string Mut,List;
	local UTUIDataStore_MenuItems MenuDataStore;

	MenuDataStore = UTUIDataStore_MenuItems(StaticResolveDataStore('UTMenuItems'));

	P = InStr(t,"?");
	while (P != INDEX_None)
	{
		Mut = Left(t,p);
		t = right(t,len(t)-p-1);
		p = InStr(t,"?");

		i = MenuDataStore.FindValueInProviderSet('Mutators','classname',Mut);
		if (i != INDEX_None)
		{
			MenuDataStore.GetValueFromProviderSet('Mutators','friendlyname',i, Mut);
			List $= Mut  $ "\n";
		}
	}

	if (t != "")
	{
		i = MenuDataStore.FindValueInProviderSet('Mutators','classname',t);
		if (i != INDEX_None)
		{
			MenuDataStore.GetValueFromProviderSet('Mutators','friendlyname',i, Mut);
			List $= Mut  $ "\n";
		}
	}
	return list;
}


event bool ActivatePage( int PlayerIndex, bool bActivate, optional bool bTakeFocus=true )
{
	local bool b;
	b =  Super.ActivatePage( PlayerIndex, bActivate, bTakeFocus);

	CheckGameStatus();
	return b;
}

function CheckGameStatus()
{
	local UTUIScene_MidGameMenu Scene;
	local UTGameReplicationInfo GRI;
	local WorldInfo WI;

	Scene = UTUIScene_MidGameMenu( GetScene() );
	WI = Scene.GetWorldInfo();

	if (WI != none )
	{
		GRI = UTGameReplicationInfo(WI.GRI);
		if ( GRI != none )
		{
			if (WI.GRI.bMatchIsOver)
			{
				bEndOfMatch = true;
				if( MyButtonBar != none && IsActivePage() )
				{
					MyButtonBar.ClearButton(RulesButtonIndex);
				}
			}
		}
	}
}

function string GetMapFriendlyName(string Map)
{
	local int i, p, StartIndex, EndIndex;
	local array<string> LocPieces;

	// try to use a friendly name from the UI if we can find it
	for (i = 0; i < LocalMapList.length; i++)
	{
		if (LocalMapList[i].MapName ~= Map)
		{
			// try to resolve the UI string binding into a readable name
			StartIndex = InStr(Caps(LocalMapList[i].FriendlyName), "<STRINGS:");
			if (StartIndex == INDEX_NONE)
			{
				return LocalMapList[i].FriendlyName;
			}
			Map = Right(LocalMapList[i].FriendlyName, Len(LocalMapList[i].FriendlyName) - StartIndex - 9); // 9 = Len("<STRINGS:")
			EndIndex = InStr(Map, ">");
			if (EndIndex != INDEX_NONE)
			{
				Map = Left(Map, EndIndex);
				ParseStringIntoArray(Map, LocPieces, ".", true);
				if (LocPieces.length >= 3)
				{
					Map = Localize(LocPieces[1], LocPieces[2], LocPieces[0]);
				}
			}
			return Map;
		}
	}

	// just strip the prefix
	p = InStr(Map,"-");
	if (P > INDEX_NONE)
	{
		Map = Right(Map, Len(Map) - P - 1);
	}
	return Map;
}

function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;

	if (EventParms.EventType == IE_Released)
	{
		if (EventParms.InputKeyName == 'XboxtypeS_X')
		{
			WI = GetScene().GetWorldInfo();
			GRI = UTGameReplicationInfo(WI.GRI);
			if ( GRI != None && GRI.CanChangeTeam() )
			{
				OnChangeTeam(none, EventParms.PlayerIndex);
				return true;
			}
		}

		else if (EventParms.InputKeyName =='XboxtypeS_LeftTrigger')
		{
			RulesButtonClicked(none, EventParms.PlayerIndex);
			return true;
		}
	}
	return false;
}

function Reset(WorldInfo WI)
{
	local UIPanel MOTDPanel;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(UTUIScene(GetScene()).GetWorldInfo().GRI);

	MOTDPanel = UIPanel(FindChild('MOTDPanel',true));
	MOTDPanel.Opacity = 1.0;

	ServerName.SetVisibility(true);
	ServerName.SetDataStoreBinding(GRI.ServerName);

	SetMessageOfTheDay();
}


defaultproperties
{
	bRequiresTick=true
	OnTick=TabTick
}
