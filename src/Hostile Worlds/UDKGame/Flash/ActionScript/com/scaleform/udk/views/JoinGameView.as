/**
 * ...
 * @author 
 */

import com.scaleform.udk.views.View;
import gfx.controls.ScrollingList;
 
class com.scaleform.udk.views.JoinGameView extends View
{
    // References to relevant MovieClips to setup the focus path.
    private var _list:MovieClip;    
    private var _refreshBtn:MovieClip;
    private var _backBtn:MovieClip;
        
    public function JoinGameView() {
        super(); 	
    }       
    
	/*
    // Custom handleInput for the view to setup the focus path.
    function handleInput(details:InputDetails, pathToFocus:Array):Boolean {          
        var nextItem:MovieClip = MovieClip(pathToFocus.shift());
        var handled:Boolean = nextItem.handleInput(details, pathToFocus);
        if (handled) { return true; }	               
        
        return false; // or true if handled
    } 
	*/
}