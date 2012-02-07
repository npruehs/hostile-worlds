import mx.transitions.easing.Strong;
import gfx.motion.Tween;

[InspectableList("disabled", "disableFocus", "visible", "toggle", "labelID", "disableConstraints", "enableInitCallback", "autoSize", "soundMap")]
class com.scaleform.udk.controls.UDKButton extends gfx.controls.Button {
		
    var selectedZ:Number = -300;
    var arrow:MovieClip;
    var normalZ:Number = 0;
	
	public function UDKButton() { 
        super(); 
		Tween.init();
    }
    
    // A public version of parent method updateAfterStateChange() (Button.as).
	public function updateAfterStateChange():Void {
		// Redraw should only happen AFTER the initialization.
		if (!initialized) { return; }
		validateNow();// Ensure that the width/height is up to date.
		
        arrow._z = -450;
        
		if (textField != null && _label != null) { textField.text = _label; }		
		if (constraints != null) { 
			constraints.update(width, height);
		}
		dispatchEvent({type:"stateChange", state:state});
	}
    
    // Overides handleMouseRollOver to setFocus().
    // #state RollOver is only called by mouse interaction. Focus change happens in changeFocus.
	private function handleMouseRollOver(mouseIndex:Number):Void {
		if (_disabled) { return; }
		if ((!_focused && !_displayFocus) || focusIndicator != null) { setState("over"); } // Otherwise it is focused, and has no focusIndicator, so do nothing.
	    dispatchEventAndSound( { type:"rollOver", mouseIndex:mouseIndex } );
        if ((!_focused && !_displayFocus) || focusIndicator != null) { Selection.setFocus(this); }
    }   
    
    /*
     * Customized logic in changeFocus() to:
     * A. Display a focusIndicator.
     * B. Tween on the Z.
     */
	private function changeFocus():Void {        
		if (_disabled) { return; }
		if (focusIndicator == null) {
			setState((_focused || _displayFocus) ? "over" : "out");
		}        
        
        if (focused) {                                			
            MovieClip(this).tweenTo(0.5, { _z:selectedZ }, Strong.easeOut);                
        }
        else {				
            MovieClip(this).tweenTo(0.4, { _z:normalZ }, Strong.easeOut);                
        }

	}
}