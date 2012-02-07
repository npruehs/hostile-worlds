/**
 * ...
 * @author 
 */

import com.scaleform.udk.views.View;
import gfx.controls.ScrollingList;
 
class com.scaleform.udk.views.MutatorsView extends View
{
    private var list:ScrollingList;    
    
    public function MutatorsView() {
        super(); 	
    }
    
    public function setList(listMC:MovieClip):Void {        
        list = ScrollingList(listMC);
    }    
}