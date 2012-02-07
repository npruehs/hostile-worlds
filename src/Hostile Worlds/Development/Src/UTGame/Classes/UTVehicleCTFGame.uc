/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleCTFGame extends UTCTFGame
	abstract;

// Returns whether a mutator should be allowed with this gametype
static function bool AllowMutator( string MutatorClassName )
{
	if ( (MutatorClassName ~= "UTGame.UTMutator_WeaponsRespawn")
		|| (MutatorClassName ~= "UTGame.UTMutator_LowGrav") )
	{
		return false;
	}
	return Super.AllowMutator(MutatorClassName);
}

defaultproperties
{
	MapPrefixes[0]="VCTF"
	Acronym="VCTF"

	bAllowHoverboard=true
	bStartWithLockerWeaps=true

	OnlineGameSettingsClass=class'UTGameSettingsVCTF'
	bMidGameHasMap=true
}
