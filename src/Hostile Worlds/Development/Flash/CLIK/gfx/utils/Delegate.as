/** 
 * The Delegate helps resolve function callbacks when no scope can be passed in. Currently, all component callbacks include a scope, so this class may be deprecated.
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

class gfx.utils.Delegate extends Object {
	
// Public Methods
	/**
	 * Creates a function wrapper for the original function so that it runs in the provided context.
	 * @parameter obj Context in which to run the function.
	 * @paramater func Function to run.
	 * @return A wrapper function that when called will make the appropriate scoped callback.
	*/
	public static function create(obj:Object, func:Function):Function {
		var f = function() {
			var target = arguments.callee.target;
			var _func = arguments.callee.func;
			return _func.apply(target, arguments);
		};
		f.target = obj;
		f.func = func;
		return f;
	}

}