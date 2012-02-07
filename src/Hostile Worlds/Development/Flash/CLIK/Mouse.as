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
 * This intrinsic class replaces the built-in intrinsic class, and adds the Scaleform GFx methods and Properties of the Mouse class, making the GFx properties compile-safe so they can be typed using dot-notation instead of bracket-access.
 */
 
import flash.geom.Point;

intrinsic class Mouse {
	
	static function addListener(listener:Object):Void;
	static function hide():Number;
	static function removeListener(listener:Object):Boolean;
	static function show():Number;
	
	// GFx Extensions
	static var HAND:Number;
	static var ARROW:Number;
	static var IBEAM:Number;
	static var LEFT:Number;
	static var RIGHT:Number;
	static var MIDDLE:Number;
	static var mouseIndex:Number;
	static function getButtonsState(mouseIndex:Number):Number;
	static function getTopMostEntity(arg1:Object,arg2:Number,arg3:Boolean):Object;
	static function getPosition(mouseIndex:Number):Point;
	static function setCursorType(cursorType:Number,mouseIndex:Number):Void;
	
}