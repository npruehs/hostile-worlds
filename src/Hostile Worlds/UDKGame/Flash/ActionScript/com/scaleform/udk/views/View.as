/**
 * ...
 * @author 
 */

import gfx.core.UIComponent;
import gfx.controls.ScrollingList;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import flash.external.ExternalInterface;
 
class com.scaleform.udk.views.View extends UIComponent
{
    public var firstSelection:MovieClip;
    public var lastSelection:MovieClip;
    
    public function View() {         
        super();   		
    }  
    
    /*
    public function SetFocus():Void { 
        //trace(this + "::SetFocus(): lastSelection: " + lastSelection + ", firstSelection: " + firstSelection);
        if (lastSelection != null) {
            Selection.setFocus(lastSelection);
            lastSelection = null;
        }
        else
            Selection.setFocus(firstSelection); 
    }
    */
   
    function handleInput(details:InputDetails, pathToFocus:Array):Boolean {
        //trace("handleInput: " + details.navEquivalent + " | " + details.value);      
        var nextItem:MovieClip = MovieClip(pathToFocus.shift());
        var handled:Boolean = nextItem.handleInput(details, pathToFocus);
        if (handled) { return true; }
        
        /*
        if (details.navEquivalent == NavigationCode.ESCAPE && details.value == "keyUp"){
            ExternalInterface.call("Select_Back");
        }
        */

        return false; // or true if handled
    }
}