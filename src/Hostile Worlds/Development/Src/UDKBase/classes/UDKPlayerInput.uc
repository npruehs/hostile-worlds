/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UDKPlayerInput extends MobilePlayerInput within UDKPlayerController
	native;

/** Will return the BindName based on the BindCommand 
  * Adds check for gamepad bindings which have _Gamepad appended to them  (for the special cases where a bind was modified to work special on the gamepad.)
  */
native function String GetUDKBindNameFromCommand( String BindCommand );
