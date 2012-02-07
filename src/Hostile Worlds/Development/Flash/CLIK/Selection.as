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
 * This intrinsic class replaces the built-in intrinsic class, and adds the Scaleform GFx methods and Properties of the Selection class, making the GFx properties compile-safe so they can be typed using dot-notation instead of bracket-access.
 */
intrinsic class Selection {
	
	// Methods in the Flash Player
	static function addListener(listener:Object):Void;
	static function getBeginIndex():Number;
	static function getCaretIndex():Number;
	static function getEndIndex():Number;
	static function getFocus():String;
	static function removeListener(listener:Object):Void;
	static function setFocus(newFocus:Object):Boolean;
	static function setSelection(beginIndex:Number, endIndex:Number):Void;
	
	// GFx Extensions
	static var alwaysEnableArrowKeys:Boolean;
    static var alwaysEnableKeyboardPress:Boolean;
	static function captureFocus(doCapture:Boolean):Void;
	static var disableFocusAutoRelease:Boolean;
	static var disableFocusKeys:Boolean;
	static var disableFocusRolloverEvent:Boolean;
	static var modalClip:MovieClip;
	static var numFocusGroups:Number;
	static function moveFocus(keyToSimmulate:String, startFromMovie:Object):Object;
	static function findFocus(keyToSimulate:String, parentMovie:Object, loop:Boolean, startFromMovie:Object, includeFocusEnabledChars:Boolean, controllerIndex:Number):Object;
	static function setModalClip(modalClip:Object, controllerIndex:Number):Object;
	static function getModalClip(controllerIndex:Number):Void;
	static function setControllerFocusGroup(controllerIndex:Number, focusGroupIdx:Number):Boolean;
	static function getControllerFocusGroup(controllerIndex:Number):Number;
	static function getFocusArray(mc:Object):Array;
	static function getFocusBitmask(mc:Object):Number;
	static function getControllerMaskByFocusGroup(focusGroupIdx:Number):Number;
}