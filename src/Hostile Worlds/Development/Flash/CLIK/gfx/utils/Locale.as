/**
 * The locale class manages translation calls from the component framework, interfacing directly with translation features of the player, or using the GameEngine to make calls to the game for translation.
 */

/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.

 Portions of the integration code is from Epic Games as identified by Perforce annotations.
 Copyright © 2010 Epic Games, Inc. All rights reserved.
 
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

class gfx.utils.Locale {
	
// Constants:	

// Static Interface
	/**
	 * Requested a Locale string from the Player. Currently, this is not wired to the GameEngine or Player.
	 * @param value The untranslated string or ID.
	 * @returns A translated string
	 */
	public static function getTranslatedString(value:String):String {
		return value;//Intrinsic.getTranslatedString(value);
	}

}