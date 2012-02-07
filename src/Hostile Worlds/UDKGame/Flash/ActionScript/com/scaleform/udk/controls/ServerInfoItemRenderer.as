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
import gfx.controls.ListItemRenderer;
import com.scaleform.udk.controls.FocusItemRenderer;

[InspectableList("disabled", "visible", "labelID", "disableConstraints"]
class com.scaleform.udk.controls.ServerInfoItemRenderer extends FocusItemRenderer {
	
// Constants:

// Public Properties:

// Priver Properties:
	private var textField1:MovieClip;
	private var textField2:MovieClip;  
   
// Initialization:
	public function ServerInfoItemRenderer() { 
        super(); 
        this.disableFocus(true);        
        this.enabled = false;
    }

    public function setData(data:Object):Void {		
        super.setData(data);          
        UpdateTextFields();                
	}   
    
        
    // This method is fired after the state has changed to allow the component to ensure the state is up-to-date.  For instance, updating the contraints in Button.
	private function updateAfterStateChange():Void {
		// Redraw should only happen AFTER the initialization.
		if (!initialized) { return; }
		validateNow();// Ensure that the width/height is up to date.		
		UpdateTextFields();		
		if (constraints != null) { 
			constraints.update(width, height);
		}
		dispatchEvent({type:"stateChange", state:state});
	}
 
// Public Methods:	
	/** @exclude */
	public function toString():String {
		return "[Scaleform ServerInfoItemRenderer " + _name + "]";
	}
		
// Private Methods:    
    private function UpdateTextFields() {        
        if (textField1 && data.label)
            textField1.text = data.label;
        
        if (textField2 && data.value)
            textField2.text = data.value;     
    }
}