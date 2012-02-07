/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.
 Portions of the integration code is from Epic Games as identified by Perforce annotations.
 Copyright © 2010 Epic Games, Inc. All rights reserved.
 
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY 
 OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

/**
 * This intrinsic class replaces the built-in intrinsic class, and adds the Scaleform GFx methods and Properties of the Stage class, making the GFx properties compile-safe so they can be typed using dot-notation instead of bracket-access.
 */
import flash.geom.Point;
import flash.geom.Rectangle;

intrinsic class Stage {
	
	static var align:String;
	static var height:Number;
	static var scaleMode:String;
	static var showMenu:Boolean;
	static var width:Number;

	static function addListener(listener:Object):Void;
	static function removeListener(listener:Object):Boolean;
	
	// GFx Extensions
	static var visibleRect:Rectangle;
	static var safeRect:Rectangle;
	static var originalRect:Rectangle;
	
	static function translateToScreen(pt:Object):Point;
}