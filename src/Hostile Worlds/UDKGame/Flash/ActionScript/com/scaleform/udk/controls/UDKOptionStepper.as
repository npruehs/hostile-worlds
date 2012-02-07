/**********************************************************************
 Copyright (c) 2010 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

import gfx.controls.OptionStepper;

[InspectableList("disabled", "visible", "enableInitCallback", "soundMap")]
class com.scaleform.udk.controls.UDKOptionStepper extends OptionStepper {
	
// Constants:

// Public Properties:	
	
// UI Elements:

// Initialization:
	public function UDKOptionStepper() { 
		super();	   		    	
    }
	
	public function get selectedIndex():Number { return _selectedIndex; }
	public function set selectedIndex(value:Number):Void {
		var newIndex:Number = Math.max(0, Math.min(_dataProvider.length-1, value));
		if (newIndex == _selectedIndex) { return; }			
		_selectedIndex = newIndex;
		
		if (_selectedIndex == dataProvider.length-1) { nextBtn.visible = false; }
		else {
			nextBtn.visible = true;
		}
		
		if (selectedIndex == 0) { prevBtn.visible = false; }
		else {			
			prevBtn.visible = true;
		}
		
		updateSelectedItem();
	}      
}