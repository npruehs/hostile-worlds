/**********************************************************************
 ButtonContainer class to allow Flash artist to manipulate soundMap for 
 a component within Flash Studio even if its been wrapped inside a container
 to allow for more complex tweening on the embedded component.

 Copyright (c) 2010 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/
import gfx.core.UIComponent;

[InspectableList("enableInitCallback", "soundMap")]
class com.scaleform.udk.controls.ButtonContainer extends UIComponent {
	
// Constants:

// Public Properties:
	public var btn:MovieClip;

    /** Mapping between events and sound process */
    [Inspectable(type="Object", defaultValue="theme:default,focusIn:focusIn,focusOut:focusOut,select:select,rollOver:rollOver,rollOut:rollOut,press:press,doubleClick:doubleClick,click:click")]
	public var soundMap:Object = { theme:"default", focusIn:"focusIn", focusOut:"focusOut", select:"select", rollOver:"rollOver", rollOut:"rollOut", press:"press", doubleClick:"doubleClick", click:"click" };
	
// UI Elements:

// Initialization:
	public function ComponentContainer() { 
    	super();        
        btn.soundMap = this.soundMap;
    }   
    
    
}