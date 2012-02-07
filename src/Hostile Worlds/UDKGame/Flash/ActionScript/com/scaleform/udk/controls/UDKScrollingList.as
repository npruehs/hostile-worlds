/**********************************************************************
 Copyright (c) 2010 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

import gfx.controls.ScrollingList
import com.scaleform.udk.controls.FocusItemRenderer;

[InspectableList("disabled", "visible", "itemRenderer", "inspectableScrollBar", "rowHeight", "inspectableRendererInstanceName", "margin", "paddingTop", "paddingBottom", "paddingLeft", "paddingRight", "thumbOffsetBottom", "thumbOffsetTop", "thumbSizeFactor", "enableInitCallback", "soundMap")]
class com.scaleform.udk.controls.UDKScrollingList extends ScrollingList {
	
// Constants:

// Public Properties:
	private var lastSelectedIndex:Number = -1;
	
// UI Elements:

// Initialization:
	/**
	 * The constructor is called when a ScrollingList or a sub-class of ScrollingList is instantiated on stage or by using {@code attachMovie()} in ActionScript. This component can <b>not</b> be instantiated using {@code new} syntax. When creating new components that extend ScrollingList, ensure that a {@code super()} call is made first in the constructor.
	 */
	public function UDKScrollingList() { 
    	super();
	    this.addEventListener("itemRollOver", this, "onItemRollOver_ChangeSelected");
    }
    
    /**
	 * Set a list of external MovieClips to use as renderers, instead of auto-generating the renderers at run-time. The rendererInstance property uses this method to set the renderer list.
	 */
	public function setRendererList(value:Array):Void  {
		// Clean up old external renderers.
		if (externalRenderers) {
			for (var i:Number = 0; i < renderers.length; i++) {
				var clip:MovieClip = renderers[i];
				clip.owner = null;
				clip.removeEventListener("click", this, "handleItemClick");
				clip.removeEventListener("rollOver", this, "dispatchItemEvent");
				clip.removeEventListener("rollOut", this, "dispatchItemEvent");
				clip.removeEventListener("press", this, "dispatchItemEvent");
				clip.removeEventListener("doubleClick", this, "dispatchItemEvent");
                clip.removeEventListener("change", this, "dispatchItemEvent"); // Added for internal components.
				Mouse.removeListener(clip);
			}
		} else {
			resetRenderers();
		}
		
		externalRenderers = (value != null);
		
		if (externalRenderers) {
			renderers = value;
		}
		invalidate();
	}        
    
    	// Dispatch a mouse event that comes from an itemRenderer.
	private function dispatchItemEvent(event:Object):Void {
		var type:String;
		switch (event.type) {
			case "press":
				type = "itemPress"; break;
			case "click":
				type = "itemClick"; break;
			case "rollOver":
				type = "itemRollOver"; break;
			case "rollOut":
				type = "itemRollOut"; break;
			case "doubleClick":
				type = "itemDoubleClick"; break;
            case "change":
                type = "itemChange"; break;
			default:
				return;
		}
		var newEvent:Object = {
			target:this,
			type:type,
			item:event.target.data, 
			renderer:event.target, 
			index:event.target.index,
			mouseIndex: event.mouseIndex
		};
        
		dispatchEventAndSound(newEvent);
	}
    
    private function changeFocus():Void {                    		
		setState();                        
		var renderer:MovieClip = getRendererAt(_selectedIndex);
		if (renderer != null) {    
            // Don't set renderer.selected. Instead, make the changes to the renderer manually for the focusIndicator.                  
            renderer.displayFocus = _focused;
            renderer.gotoAndPlay( (_focused) ? "selected_over" : "up" );                        
            FocusItemRenderer(renderer).updateAfterStateChange();
            var OptionStepper:MovieClip = renderer["optionstepper"];
			if (OptionStepper != null)
			{
				OptionStepper["prevBtn"]["displayFocus"] = _focused;
				OptionStepper["nextBtn"]["displayFocus"] = _focused;            
			}
		}		                       
	}
	        
    private function setUpRenderer(clip:MovieClip):Void {
		clip.owner = this;
		clip.tabEnabled = false; // Children can still be tabEnabled, or the renderer could re-enable this.
		clip.doubleClickEnabled = true;
		clip.addEventListener("press", this, "dispatchItemEvent");
		clip.addEventListener("click", this, "handleItemClick");
		clip.addEventListener("doubleClick", this, "dispatchItemEvent");		
		clip.addEventListener("rollOver", this, "dispatchItemEvent");
		clip.addEventListener("rollOut", this, "dispatchItemEvent");
        clip.addEventListener("change", this, "dispatchItemEvent"); // Added for internal components.
	}
    
    // Custom logic to give focus to a listItemRenderer on rollOver.
    private function onItemRollOver_ChangeSelected(p_event:Object) {         
        if (disabled) return;
                
        // If it's a rollOver event, remove the old SelectedIndex so we don't see it play an animation.
        if (!_focused) { _selectedIndex = -1; }
        
        // Set focus to the list so that the display indicator will be displayed when we do set the selectedIndex;
        Selection.setFocus(this);                       
        
        // Set the selected index.
        selectedIndex = p_event.index;        
    }	
}