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
class com.scaleform.udk.controls.ServerItemRenderer extends FocusItemRenderer {
	
// Constants:

// Public Properties:

// Priver Properties:
    private var flags_icon:MovieClip;
	private var textField0:MovieClip;
	private var textField1:MovieClip;
	private var textField2:MovieClip;
	private var textField3:MovieClip;
	private var textField4:MovieClip;
    
    private var _players:String;
    private var _server:String;
    private var _map:String;
    private var _ping:String;
    private var _flags:String;
	
// Initialization:
	public function ServerItemRenderer() { 
        super(); 
    }

    public function setData(data:Object):Void {		
        super.setData(data);  
        
        _server = data.ServerName;
        if (data.ServerDesc) 
            _server += (": " + data.ServerDesc);
                   
        _players = data.Players;
        if (data.NumBots)
            _players = ("(+" + data.NumBots + ")");
        _players += ("/" + data.MaxPlayers);
        
        _ping = data.Ping;
        _map = data.Map;
                
		_flags = data.Flags;
        
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
		return "[Scaleform ServerItemRenderer " + _name + "]";
	}
		
// Private Methods:    
    private function UpdateTextFields() {
		if (textField0 && _flags)
			textField0.htmlText = _flags;
		
        if (textField1 && _server)
            textField1.text = _server;
            
        if (textField2 && _map)
            textField2.text = _map;
        
        if (textField3 && _players)
            textField3.text = _players;
            
        if (textField4 && _ping)
            textField4.text = _ping;        
    }
}