/**
 * ...
 * @author 
 */

import com.scaleform.udk.views.View;
import com.scaleform.udk.controls.ImageScroller;
import gfx.controls.ScrollingList;
import gfx.core.UIComponent;

class com.scaleform.udk.views.MapSelectView extends View
{
	public static var viewName:String = "MapSelect";
    private var list:ScrollingList;
    private var info:MovieClip;
	private var imgScroller:ImageScroller;
    
    public function MapSelectView() {
        super();         
    }
    
    public function setList(listMC:MovieClip):Void {
        list = ScrollingList(listMC);
    }    
        
    public function setImgScroller(imgScrollerMC:MovieClip):Void {
        imgScroller = ImageScroller(imgScrollerMC);        
        list.addEventListener("change", this, "onListChange_UpdateImage");
        list.addEventListener("focusIn", this, "onListFocusIn_UpdateImage");
    }      
    
    public function onListChange_UpdateImage(event:Object):Void {
        imgScroller.selectedIndex = event.target.selectedIndex;       
    } 
    
    public function onListFocusIn_UpdateImage(event:Object):Void {
        trace("Setting imgScroller.selectedIndex: " + list.selectedIndex);
        imgScroller.selectedIndex = list.selectedIndex;       
    }       
}