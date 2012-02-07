import gfx.core.UIComponent;
import gfx.motion.Tween;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import mx.data.encoders.Bool;
import mx.transitions.easing.*;
import flash.external.ExternalInterface;
import com.scaleform.udk.views.View;

class com.scaleform.udk.managers.MenuManager extends UIComponent {
	
	// Manager movieClip to which all the views are attached.
    public var manager:MovieClip;
	
    // Reference to the current movieClip on the top of the stack.
    public var currentView:MovieClip;
    
    // The stack of views which are currently being displayed.
    private var _viewStack:Array;   
    
    // Parameters for the standard 'push view/pop view' tweens.
    private var _tweenInitParams:Object;
	
	private var cursor:MovieClip;
   
	public function MenuManager() { 
        super();         
        
        _viewStack = [];
        Tween.init();
				
        manager._z = 0;
        manager._x += 40;
		manager._yrotation = -8;
		
		// Removed _perspfov change until fix in GFx core is added for _perspfov mouse-picking.
		// manager._perspfov = 30;
		
		_tweenInitParams = { _alpha:0, _z: -15000, _x:750 };
    }
    
    // Returns a reference to the current view on the top of the _viewstack.
    public function getCurrentView():MovieClip { return _viewStack[_viewStack.lengh-1] };
    
    // Accessor, mutator for _viewStack.
    public function get viewStack():Array { return _viewStack; }
	public function set viewStack(value:Array):Void {
		_viewStack = value;        
	}	

    // Pushes a view onto the stack using the standard animation.
	public function pushStandardView(targetView:View):Void {		
        if (!targetView) return;		
		pushViewImpl(targetView, {z:-15000, x:-750});
	}
    
    // Pushes a dialog onto the stack with a different animation than pushStandardView.
	public function pushDialogView(targetView:View):Void {		
		if (!targetView) return;
        pushViewImpl(targetView, {z:-1000, x:-50});
	}
	
    // Pops a view from the view stack.
	public function popView(targetView:View):Void {
		if (_viewStack.length <= 1) return;		
		popViewImpl();
	}
	
    // Pushes a view onto the stack, tweening it in and configuring its modal properties.
    private function pushViewImpl(targetView:View, pushParams:Object):Void {              
		targetView["tweenPushParams"] = pushParams;
        Selection["modalClip"] = targetView;	        
		
		// Intro tween new screen
		var pushedContainer:MovieClip = targetView._parent;
        pushedContainer._visible = true;		// PPS: Do we need this?
		pushedContainer._alpha = 0;
		pushedContainer._z = -15000;
		pushedContainer._x = 750;    
		pushedContainer.tweenTo(0.3, 
		{
			_alpha: 100,
			_z: 0,
			_x: 0
		}, Strong.easeOut);
        pushedContainer.target = { z:0, x:0 };
		
		// Push in existing screens incrementally
		var zPush:Number = pushParams.z;
		var xPush:Number = pushParams.x;
		for (var i:Number = 0; i < _viewStack.length; i++) {
			var container:MovieClip = MovieClip(_viewStack[i])._parent;
			var invIdx:Number = (_viewStack.length - i - 1) + 1;
            var targetZ:Number = container.target.z - zPush;
            var targetX:Number = container.target.x + xPush;
			container.tweenTo(0.5, 
			{ 
				_alpha: 100 / (invIdx * 25 + 1), 
				_z: targetZ,
				_x: targetX
			}, Strong.easeOut);
            container.target = { z:targetZ, x:targetX };
		}		
        
        targetView["modalBG"].attachMovie("modal", "modal", this.getNextHighestDepth());
        _viewStack.push(targetView);		
    }
    
    private function popViewImpl():MovieClip {                		       
		// Restore next screen in stack
		var poppedView:MovieClip = MovieClip(_viewStack.pop());        	
        var latestView:MovieClip = MovieClip(_viewStack[_viewStack.length - 1]);	        
        Selection["modalClip"] = latestView;          
        
		trace("popView(" + poppedView + ")")        

		var popParams:Object = poppedView.tweenPushParams;
		var zPull:Number = popParams.z;
		var xPull:Number = popParams.x;				
		        
		// Outro tween popped screen
		var poppedContainer:MovieClip = poppedView._parent;
        poppedContainer.tweenTo(0.3, _tweenInitParams, Strong.easeOut);
                
        for (var i:Number = 0; i < _viewStack.length; i++) {
			var container:MovieClip = MovieClip(_viewStack[i])._parent;
			var invIdx:Number = _viewStack.length - i - 1;
            var targetZ:Number = container.target.z + zPull;
            var targetX:Number = container.target.x - xPull;
			container.tweenTo(0.5, 
			{ 
				_alpha:100 / (invIdx * 25 + 1), 
				_z: targetZ,
				_x: targetX
			}, Strong.easeOut);
            container.target = { z:targetZ, x:targetX };            
		}
        
        poppedView["modalBG"].modal.removeMovieClip();        
        return poppedView;
    }
    
    public function setSelectionFocus(mc:MovieClip):Void {        
        Selection.setFocus(mc);    
        trace("setSelectionFocus:: Selection.getFocus(): " + Selection.getFocus());
    }
    
    public function showCursor(value:Boolean) {
        cursor._visible = value;
    }
    
    // Custom handleInput to handle standard input + unique cases.
    function handleInput(details:InputDetails, pathToFocus:Array):Boolean {          
        // trace(details.code + " | " + details.navEquivalent + " | " + details.value + "\n");	
        var nextItem:MovieClip = MovieClip(pathToFocus.shift());
        var handled:Boolean = nextItem.handleInput(details, pathToFocus);
        if (handled) { return true; }	
        
        // Maps Escape-KeyUp to _global.OnEscapeKeyPress(), a function object defined in UnrealScript
        // and set by each view which calls some method. Generally this pops a view from the view stack.
        if (details.navEquivalent == NavigationCode.ESCAPE && details.value == "keyUp") {            
            _global.OnEscapeKeyPress();
            return true;
        }
        
        return false; // or true if handled
    }   
}