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
import gfx.utils.Constraints;
import com.scaleform.udk.controls.FocusItemRenderer;

[InspectableList("disabled", "visible", "labelID", "disableConstraints"]
class com.scaleform.udk.controls.MultiControlItemRenderer extends FocusItemRenderer {

	// Constants:

// Public Properties:
	public var optionstepper:gfx.controls.OptionStepper;
    public var textinput:gfx.controls.TextInput;
    public var control:MovieClip;
	
// Private Properties
	private var _bDataUpdate:Boolean = false;
	private var hit:MovieClip;
	
// Initialization:
	public function MultiControlItemRenderer() { super(); }

// Public Methods:
	public function get selected():Boolean { return _selected; }
	public function set selected(value:Boolean):Void {		
		super.selected = value;		
	}    
	
	private function changeFocus():Void {
		super.changeFocus();		
		var state:String = (_selected) ? "focused" : "default";		
		/* Set the OptionStepper / TextInput to the focused state. */
		if (!control.disabled && control != null)
		{						
			control.gotoAndPlay(state);
		}
		// Control might be null the first time.
		else if (!optionstepper.disabled)
		{			
			optionstepper.gotoAndPlay(state);
		}
	}
		
    
	public function setData(data:Object):Void {
        super.setData(data);             
        
        if (data.disabled)
            this.disabled = data.disabled;
	}	
	
	public function draw() {
		super.draw();
		
		// If the control passed in was an option stepper.
        if (data.control == "stepper")
        {   
			control = optionstepper; 
			
			// Hide the text input.
            if (textinput != null) {
                textinput._visible = false;
                textinput.disabled = true;
            }
                                              
            optionstepper._visible = true;
			
			// Set the dataProvider for the optionStepper
            if (!optionstepper.disabled) {				
				optionstepper.dataProvider = data.dataProvider;           
				optionstepper.selectedIndex = data.optIndex;
				data.bUpdateFromUnreal = false;
			}					
			
			if (data.controlDisabled)
				optionstepper.disabled = data.controlDisabled;
        }       
        
		// If the control passed in was an text input
        else if (data.control == "input")
        {
            control = textinput;   
            
            if (optionstepper != null) {
                optionstepper._visible = false;
                optionstepper.disabled = true;
                optionstepper.dataProvider = null;
            }
            
            textinput._visible = true;
            textinput.disabled = false;
		    textinput.text = data.text;	
            textinput.maxChars = data.editBoxMaxLength;
        }
	}
	
	public function handleInput(details:InputDetails, pathToFocus:Array):Boolean {		        
        var nextItem:MovieClip = MovieClip(pathToFocus.shift());
		var handled:Boolean;
		if (nextItem != null) {
			handled = nextItem.handleInput(details, pathToFocus);
			if (handled) { return true; }
		}

        // If the user presses enter, shift focus to the textinput and vice versa.
        // details.code != 32 prevents spacebar from triggering this behavior.
        if (details.navEquivalent == NavigationCode.GAMEPAD_A && details.value == "keyUp" && details.code != 32)
        {       
            if (textinput)
            {
                if (!textinput.disabled && !textinput.focused) {                    
                    Selection.setFocus(textinput);
                    return true;
                }
                else if (textinput.focused) {                
                     Selection.setFocus(this);
                     return true;
                }
            }
        }

		if (details.navEquivalent == "left" || details.navEquivalent == "right") {            
            if (optionstepper && !optionstepper.disabled)
			    handled = optionstepper.handleInput(details, pathToFocus);
                
			if (handled) { return true; }
		}
        
		return false; // or true if handled
	}
	
	// Event for when the option stepper's value has been changed.
	public function onStepperChange(event:Object) {   						
		if (data.bUpdateFromUnreal) { return; }
		if (data.optIndex == event.target.selectedIndex) { return; }
		data.optIndex = event.target.selectedIndex;		
		data.selection = event.target.dataProvider[data.optIndex];
		var event:Object = { type:"change" };		
		dispatchEvent(event);
		
		// Workaround for an issue where the above dispatch does not seem to trigger a UDKScrollingList.dispatchEventAndSound.
		playSound("change");			
	}
    
    public function onTextChange(event:Object) {        
        data.text = textinput.text;
        var event:Object = {type:"change"};
        dispatchEvent(event);
    }
    
   	/** @exclude */
	public function toString():String {
		return "[Scaleform OptionItemRenderer " + _name + "]";
	}          
	
// Private Methods:
	private function configUI():Void {                
        constraints = new Constraints(this, true);
		if (!_disableConstraints) {
			constraints.addElement(textField, Constraints.ALL);
		}		
		
		// Force dimension check if autoSize is set to true
		if (_autoSize != "none") {
			sizeIsInvalid = true;
		}
        
        hit.onRollOver = Delegate.create(this, handleMouseRollOver);
		hit.onRollOut = Delegate.create(this, handleMouseRollOut);
		hit.onPress = Delegate.create(this, handleMousePress);
		hit.onRelease = Delegate.create(this, handleMouseRelease);		
		hit.onDragOver = Delegate.create(this, handleDragOver);
		hit.onDragOut = Delegate.create(this, handleDragOut);
		hit.onReleaseOutside = Delegate.create(this, handleReleaseOutside);		
        hit.tabEnabled = false;
        
		focusTarget = owner;
                    
        if (optionstepper != null) {
            optionstepper.addEventListener("change", this, "onStepperChange");
            optionstepper.tabEnabled = false;
            optionstepper.tabChildren = false;
			optionstepper.focusEnabled = false;
        }
        
        if (textinput != null) {			
            textinput.addEventListener("textChange", this, "onTextChange");
            textinput.tabEnabled = false;			
            textinput.tabChildren = false;                      
			textinput.focusEnabled = false;
        }
		
        updateAfterStateChange();
	}     
}