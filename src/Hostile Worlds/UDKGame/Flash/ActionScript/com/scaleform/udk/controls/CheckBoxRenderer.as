/**********************************************************************
 Copyright (c) 2010 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/
import gfx.utils.Delegate;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import com.scaleform.udk.controls.FocusItemRenderer;

[InspectableList("disabled", "visible", "labelID", "disableConstraints"]
class com.scaleform.udk.controls.CheckBoxRenderer extends FocusItemRenderer {
	
// Constants:

// Public Properties:
	private var check:MovieClip;
    private var lastIndex:Number;

// Initialization:
	public function CheckBoxRenderer() { 
        super(); 
    }

    public function setData(data:Object):Void {		
        super.setData(data);       		
		if (lastIndex != index || !this.selected || this.data.bForceToggledUpdate)
        {
            if (data.toggled) { 
                check.gotoAndStop("on_noAnim"); 
            }
            else { 
                check.gotoAndStop("off_noAnim"); 
            }
			this.data.bForceToggledUpdate = false;
		}        
        lastIndex = index;
	}
    
    public function updateAfterStateChange() {
        super.updateAfterStateChange();
        check.icon._z = -450;
    }
    
    public function setListData(index:Number, label:String, selected:Boolean):Void {
        lastIndex = this.index;
		this.index = index;
		if (label == null) {
			this.label = "Empty";
		} else {
			this.label = label;
		}
		state = "up";
		this.selected = selected;	
	}
	
    
// Public Methods:	
    public function setToggled(value:Boolean) { 
        if (data.toggled == value) return;            
        
        data.toggled = value;                
        if (data.toggled) {
            check.gotoAndPlay("on");
        }
        else {
            check.gotoAndPlay("off");
        }
    }       
    
    public function handleInput(details:InputDetails, pathToFocus:Array):Boolean {
		switch(details.navEquivalent) {
			case NavigationCode.ENTER:
				if (details.value == "keyDown") { // A more generic solution may be required for Button
					if (!pressedByKeyboard) { 
                        handlePress();                         
                        setToggled(!data.toggled);
                    }
				} else {
					handleRelease();                    
				}
				return true; // Even though the press may not have handled it (automatic=repeat presses), we want to indicate that we did, since the Button handles repeat, but it won't respond to multiple.
		}
		return false;
	}	

	/** @exclude */
	public function toString():String {
		return "[Scaleform CheckBoxRenderer " + _name + "]";
	}
		
// Private Methods:    
    private function handleMousePress(mouseIndex:Number, button:Number):Void {        
		super.handleMousePress(mouseIndex, button);
        setToggled(!data.toggled);
	}	
}