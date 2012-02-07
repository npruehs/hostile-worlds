/**
 * ...
 * @author 
 */

import com.scaleform.udk.views.View;
import com.scaleform.udk.controls.ImageScroller;
import gfx.controls.ScrollingList;
import gfx.core.UIComponent;
 
class com.scaleform.udk.views.GameModeView extends View
{
	public static var viewName:String = "GameMode";
    private var list:ScrollingList;
    private var info:MovieClip;
    private var imgScroller:ImageScroller;
    
    public function GameModeView() {
        super();         
    }
    
    public function setList(listMC:MovieClip):Void {
        list = ScrollingList(listMC);        
    }    
    
    public function setImgScroller(imgScrollerMC:MovieClip):Void {
        imgScroller = ImageScroller(imgScrollerMC);        
        list.addEventListener("change", this, "onListChange_UpdateImage");
    }      
    
    public function onListChange_UpdateImage(event:Object):Void {
        imgScroller.selectedIndex = event.target.selectedIndex;       
    }  
}