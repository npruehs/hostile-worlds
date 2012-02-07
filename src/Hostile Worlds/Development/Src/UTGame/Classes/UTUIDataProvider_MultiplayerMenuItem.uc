/**
 * Provides menu items for the multiplayer menu.
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_MultiplayerMenuItem extends UTUIResourceDataProvider
	PerObjectConfig;

/** Localized description of the map */
var config localized string Description;

/** Indicates that this menu item should only be shown if the user is online, signed in, and has the required priveleges */
var	config	bool	bRequiresOnlineAccess;


/** 
  * Script interface for determining whether or not this provider should be filtered 
  * @return 	TRUE if this data provider requires online access but is not able or allowed to play online
  */
event bool ShouldBeFiltered()
{
	local UIInteraction InteractionCDO;
	local LocalPlayer LP;
	local PlayerController PC;
	
	if ( Super.ShouldBeFiltered() )
	{
		return true;
	}
	
	if ( bRequiresOnlineAccess )
	{
		InteractionCDO = GetCurrentUIController();
		ForEach class'Engine'.static.GetCurrentWorldInfo().LocalPlayerControllers(class'PlayerController', PC)
		{
			LP = LocalPlayer(PC.Player);
			if ( LP != None )
			{
				if (!InteractionCDO.IsLoggedIn(LP.ControllerId,TRUE)
				||	!InteractionCDO.CanPlayOnline(LP.ControllerId) )
				{
					return true;
				}
			}
		}
	}

	return false;
}