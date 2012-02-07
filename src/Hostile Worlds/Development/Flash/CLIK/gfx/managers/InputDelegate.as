/**
 * InputDelegate receives commands from the game, by intercepting keys, controller buttons, etc, and dispatches Input events. InputDetail objects are generated containing a navigation equivelant. FocusHandler will instantiate an InputDelegate when input is required.
 */

/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

/*
*/

import gfx.events.EventDispatcher;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import mx.data.encoders.Bool;
 
class gfx.managers.InputDelegate extends EventDispatcher {
	
// Constants:
	private static var _instance:InputDelegate;
	
// Static Interface
	/** Returns the Singleton instance of the InputDelegate */
	public static function get instance():InputDelegate {
		if (_instance == null) { _instance = new InputDelegate(); }
		return _instance;
	}	
	
// Public Properties:

// Initialization:
	/**
	 * Create a new InputDelegate instance. This method should only be called internally by the InputDelegate class, as the implementation is a Singleton.
	 */
	public function InputDelegate() {
		Key.addListener(this);		
	}
	
// Public Methods:

	/** 
	 * Request input from the game engine.
	 * @param type The type of the required interaction.
	 * @param code The code of the required input.
	 * @param scope The scope of the callBack.
	 * @param callBack The function name of the callBack.
	 * @return An Object containing relevant information about the requested input.
	 */
	public function readInput(type:String, code:Number, scope:Object, callBack:String):Object {
		// Look up game engine stuff
		return null;
	}
	
	/**
	 * Convert input to readable navigation commands
	 * @param type The type of interaction
	 * @param code The numeric code of the input
	 * @param value Additional details from the input
	 * @return The navigation equivalent String.
	 */
	public function inputToNav(type:String, code:Number, value):String {
		// Keys, likely the PC Keyboard.
		if (type == "key") {
			switch (code) {
				case Key.UP:
					return NavigationCode.UP;
				case Key.DOWN:
					return NavigationCode.DOWN;
				case Key.LEFT: 
					return NavigationCode.LEFT;
				case Key.RIGHT:
					return NavigationCode.RIGHT;		
				case Key.ENTER:
				case Key.SPACE:
					return NavigationCode.ENTER;
				case Key.BACKSPACE:
					return NavigationCode.BACK;
				case Key.TAB:
					return Key.isDown(Key.SHIFT) ? NavigationCode.SHIFT_TAB : NavigationCode.TAB;
				case Key.HOME:
					return NavigationCode.HOME;
				case Key.END:
					return NavigationCode.END;
				case Key.PGDN:
					return NavigationCode.PAGE_DOWN;
				case Key.PGUP:
					return NavigationCode.PAGE_UP;
				case Key.ESCAPE:
					return NavigationCode.ESCAPE;
				
				// Custom handlers for gamepad support
				case 96:	// NumPad_0
					return NavigationCode.GAMEPAD_A;
				case 97:	// NumPad_1
					return NavigationCode.GAMEPAD_B;
				case 98:	// NumPad_2
					return NavigationCode.GAMEPAD_X;
				case 99:	// NumPad_3
					return NavigationCode.GAMEPAD_Y;
				case 100:	// NumPad_4
					return NavigationCode.GAMEPAD_L1;
				case 101:	// NumPad_5
					return NavigationCode.GAMEPAD_L2;
				case 102:	// NumPad_6
					return NavigationCode.GAMEPAD_L3;
				case 103:	// NumPad_7
					return NavigationCode.GAMEPAD_R1;
				case 104:	// NumPad_8
					return NavigationCode.GAMEPAD_R2;
				case 105:	// NumPad_9
					return NavigationCode.GAMEPAD_R3;
				case 106:	// NumPad_Multiply
					return NavigationCode.GAMEPAD_START;
				case 107:	// NumPad_Add
					return NavigationCode.GAMEPAD_BACK;
			}
		}
	}

// Private Methods:	
	private function onKeyDown(controllerIdx:Number):Void 
	{
		var code:Number = Key.getCode(controllerIdx);
		if ((_global.bIsKeyHold == undefined) || (_global.bIsKeyHold == false))
		{
			//trace("keydown " + _global.bIsKeyHold);
			handleKeyPress("keyDown", code, controllerIdx);
		}
		else
		{
			//trace("keyhold " + _global.bIsKeyHold);
			handleKeyPress("keyHold", code, controllerIdx);
		}
	}
	private function onKeyUp(controllerIdx:Number):Void {
		var code:Number = Key.getCode(controllerIdx);
		//keyRepeatState[code] = false;
		handleKeyPress("keyUp", code, controllerIdx);
	}
	
	private function handleKeyPress(type:String, code:Number, controllerIdx:Number):Void {
		var details:InputDetails = new InputDetails("key", code, type, inputToNav("key", code), controllerIdx);
		dispatchEvent({type:"input", details:details});
	}
	

}
