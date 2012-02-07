/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
//
// OptionalObject is an Pickup class
//
class UTPickupMessage extends UTLocalMessage;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local UTHUDBase HUD;
	local UTHUD MyUTHUD;

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	HUD = UTHUDBase(P.MyHUD);
	if ( HUD != None )
	{
		HUD.LastPickupTime = HUD.WorldInfo.TimeSeconds;
		MyUTHUD = UTHUD(HUD);
		if ( MyUTHUD != None )
		{
			if ( class<UTPickupFactory>(OptionalObject) != None )
			{
				class<UTPickupFactory>(OptionalObject).static.UpdateHUD(MyUTHUD);
			}
			else if ( class<UTWeapon>(OptionalObject) != None )
			{
				MyUTHUD.LastWeaponBarDrawnTime = HUD.WorldInfo.TimeSeconds + 2.0;
			}
		}
	}		
}

defaultproperties
{
	bIsUnique=true
	bCountInstances=true
	DrawColor=(R=255,G=255,B=128,A=255)
	FontSize=1
	bIsConsoleMessage=false
	MessageArea=5
}
