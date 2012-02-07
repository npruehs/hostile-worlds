class GFxUIView extends GFxObject
    dependson(WorldInfo);

`include(UTOnlineConstants.uci)
/**
 * TRUE to indicate that this scene requires a valid network connection in order to be opened.  If no network connection is
 * available, the scene will be closed.
 */
var(Flags)							bool					bRequiresNetwork;

/**
 * Retrieves a reference to a LocalPlayer.
 *
 * @param	PlayerIndex		if specified, returns the player at this index in the GamePlayers array.  Otherwise, returns
 *							the player associated with the owner scene.
 *
 * @return	the player that owns this scene or is located in the specified index of the GamePlayers array.
 */
final function LocalPlayer GetPlayerOwner( optional int PlayerIndex=INDEX_NONE )
{    
    return Outer.GetLP();
}

/** Get the UDKPlayerController that is associated with this HUD. */
final function UDKPlayerController GetUDKPlayerOwner(optional int PlayerIndex=-1)
{
    return UDKPlayerController(Outer.GetPC());
}

/** @return Returns the current status of the platform's network connection. */
static final function bool HasLinkConnection()
{
	return class'UIInteraction'.static.HasLinkConnection();
}

/** @return Returns whether or not the specified player can play online. */
final function bool CanPlayOnline( int ControllerId=0 /* GetBestControllerId() */)
{    
	return class'UIInteraction'.static.CanPlayOnline(ControllerId);
}

/** @return Returns the name of the specified player if they have an alias or are logged in, or "DefaultPlayer" otherwise. */
/*
function string GetPlayerName( int PlayerIndex = class'UIScreenObject'.static.GetBestPlayerIndex() )
{
	// @todo sf: True implementation needs to be added.
	return "Player";
}
*/
function String GetPlayerName()
{
	return "Player";
}

/** @return Returns whether or not the player with the specified controller id is logged i.n */
event bool IsLoggedIn( optional int ControllerId=255, optional bool bRequireOnlineLogin )
{
	if ( ControllerId == 255 )
	{
        ControllerId = 0;
	}
	return class'UIInteraction'.static.IsLoggedIn(ControllerId, bRequireOnlineLogin);
}

/** @return Generates a set of URL options common to both instant action and host game. */
function String GetCommonOptionsURL()
{
	local string URL;
	local string OutStringValue;

	// Set player name using the OnlinePlayerData	    
	URL $= "?name=" $ "Player"; // GetPlayerName();

	// Set player alias
	if(class'UIRoot'.static.GetDataStoreStringValue("<OnlinePlayerData:ProfileData.Alias>", OutStringValue, none, GetPlayerOwner()) && Len(OutStringValue)>0)
	{
		OutStringValue = Repl(OutStringValue," ","_");
		OutStringValue = Repl(OutStringValue,"?","_");
		OutStringValue = Repl(OutStringValue,"=","_");

		URL $= "?alias="$OutStringValue;
	}

	return URL;
}

/** @return Returns the player index of the player owner for this scene. */
function int GetPlayerIndex()
{
	local int PlayerIndex;
	local LocalPlayer LP;

	LP = GetPlayerOwner();
	if ( LP != None )
	{
		PlayerIndex = class'UIInteraction'.static.GetPlayerIndex(LP.ControllerId);
	}
	else
	{
		//PlayerIndex = class'UIScreenObject'.static.GetBestPlayerIndex();
	}

	return PlayerIndex;
}

/** @return Returns the controller id of a player given its player index. */
function int GetPlayerControllerId(int PlayerIndex)
{
	return class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex);;
}

/**
 * Executes a console command.
 *
 * @param string Cmd	Command to execute.
 */
final function ConsoleCommand(string Cmd, optional bool bWriteToLog)
{
    if (GetPC() != none)
        Outer.ConsoleCommand(Cmd);
}