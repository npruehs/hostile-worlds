import flash.external.ExternalInterface; 
import flash.geom.Rectangle;
import gfx.core.UIComponent;
import gfx.data.DataProvider;
import gfx.controls.UILoader;

[InspectableList("disabled", "visible", "itemRenderer", "inspectableScrollBar", "rowHeight", "inspectableRendererInstanceName", "margin", "paddingTop", "paddingBottom", "paddingLeft", "paddingRight", "thumbOffsetBottom", "thumbOffsetTop", "thumbSizeFactor", "bindingEnabled")]
class com.scaleform.udk.controls.ImageScroller extends UIComponent {
	
// Constants:

// Public Properties:
	public var loaderWidth:Number = 462;
	public var loaderHeight:Number = 254;
	
	public var xmargin:Number = 350;
	public var ymargin:Number = 0;
	public var zmargin:Number = 10000;
    public var alphaMargin:Number = 25;

// Private Properties:
	private var _scrollPosition:Number = 0;
	private var _rowCount:Number;
	
	private var _dataProvider:Object;
	private var _itemRenderer:String = "map_mc";
	private var _selectedIndex:Number = -1;
		
    private var _drawnRendererCount:Number = 5;
	private var renderers:Array;
	private var totalRenderers:Number;    

// Initialization:
	/**
	 * The constructor is called when a ScrollingList or a sub-class of ScrollingList is instantiated on stage or by using {@code attachMovie()} in ActionScript. This component can <b>not</b> be instantiated using {@code new} syntax. When creating new components that extend ScrollingList, ensure that a {@code super()} call is made first in the constructor.
	 */
	public function ImageScroller() { 
		super();
		renderers = [];
		dataProvider = []; // Default Data.		
	}
	
// Public Methods:	

	public function get dataProvider():Object { return _dataProvider; }
	public function set dataProvider(value:Object):Void {
		if (_dataProvider == value) { return; }
		if (_dataProvider != null) {
			_dataProvider.removeEventListener("change", this, "onDataChange");
		}
		_dataProvider = value;
		if (_dataProvider == null) { return; }
		
		if ((value instanceof Array) && !value.isDataProvider) { 
			DataProvider.initialize(_dataProvider);
		} else if (_dataProvider.initialize != null) {
			_dataProvider.initialize(this);
		}
		
		_dataProvider.addEventListener("change", this, "onDataChange");  // Do a full redraw
		invalidate();
	}
	
	public function animateRenderers(value:Number):Void {
		for (var i:Number = 0; i < renderers.length; i++) {
			var renderer:MovieClip = renderers[i];                       
            
			var targetZ:Number = 0;
			if (i < value)
				targetZ = (value - i) * zmargin;
			else if (i > value)
				targetZ = (i - value) * -zmargin;
			
			var targetX:Number = 0;
			if (i < value)
				targetX = (value - i) * -xmargin;
			else if (i > value)
				targetX = (i - value) * xmargin;
        
                
            var targetAlpha:Number = 0;
            var relIndex:Number = (i - value);
            if (relIndex <= 0) {
                if (relIndex == -1)
                    targetAlpha = 25;
                else if (relIndex == -2)
                    targetAlpha = 15;                                    
                else if (relIndex == 0)
                    targetAlpha = 100;                
            }
                
			renderer.tweenTo(1, { _z:targetZ, _x:targetX, _alpha:targetAlpha }, mx.transitions.easing.Strong.easeOut);
			
			// Hide images that are offscreen to the right or out of view to the
			// the left.
			if ( (i > selectedIndex + 2) || (i < selectedIndex - 4) ) {
				renderer._visible = false;
            }
			else {
				renderer._visible = true;
            }
		}
	}

	// When the selectedIndex changes we will shift it to the middle and do some fancy
	// code tween.	Do not check if the new selectedIndex == newSelectedIndex so that we
    // ensure the lists animates properly moving between screens and when focus comes in and 
    // out of the list.
	public function get selectedIndex():Number { return _selectedIndex; }
	public function set selectedIndex(value:Number):Void {
		// if (value == _selectedIndex) { return; }        
        if (value != _selectedIndex) {
		    var renderer:MovieClip = getRendererAt(_selectedIndex);
		    if (renderer != null) {
			    //renderer.selected = false; 
			    renderer.gotoAndPlay("off");
		    }		
        }		       
        
		var lastIndex:Number = _selectedIndex;
		_selectedIndex = value;
		dispatchEvent({type:"change", index:_selectedIndex, lastIndex:lastIndex});		             
        
        for (var i = _selectedIndex - 2; i < selectedIndex + 2; i++)
        {
            if ( i >= 0 && i < renderers.length)
                loadDataForRenderer(i);
        }
        
        animateRenderers(_selectedIndex);
        
		if (totalRenderers == 0) { return; }
		renderer = getRendererAt(_selectedIndex);
		if (renderer != null) {			
            if (value != lastIndex)
			    renderer.gotoAndPlay("on");		
            
		} else {
			// scrollToIndex(_selectedIndex); // Handled by animate renderers.
		}
	}      
	
	private function getRendererAt(index:Number):MovieClip {
		return renderers[index - _scrollPosition];
	}
	
		/**
	 * Scroll the list to the specified index.  If the index is currently visible, the position will not change. The scroll position will only change the minimum amount it has to to display the item at the specified index.
	 * @param index The index to scroll to.
	 */
	public function scrollToIndex(index:Number):Void {
		if (totalRenderers == 0) { return; }
		//
	}
    
    private function loadDataForRenderer(index:Number):Void {
        var renderer:MovieClip = renderers[index];
        var indexData:Object = dataProvider[index];
      
        if (indexData.bIsConfigured || renderer == null)
            return;
        
        if (indexData.label) {       
            renderer.image_text.mode.textField.text = indexData.label;        
        }        
        if (indexData.players) {
            renderer.image_text.players.textField.text = indexData.players;
        }        
        if (indexData.image) {
            renderer.image.loadMovie(indexData.image);
        }
        
        dataProvider[index].bIsConfigured = true;
    }

	/**
	 * Called by sub-classes to create a single renderer based on an index.  The renderer is specified by the {@code itemLinkage} property.
	 * @param index The index in the dataProvider
	 * @returns The newly-created itemRenderer
	 */
	private function createItemRenderer(index:Number):MovieClip {
		var clip:MovieClip = this.attachMovie(_itemRenderer, "renderer"+index, index);
		if (clip == null) { return null; }
		return clip;
	}

	private function createItemRenderers(startIndex:Number, endIndex:Number):Array {
		var list:Array = [];
		for (var i:Number=startIndex; i<=endIndex; i++) {
			list.push(createItemRenderer[i]);
		}
		return list;
	}
	
	/**
	 * Create new renderers and destroy old renderers to ensure there are a specific number of renderers in the component.
	 * @param totalRenderers The number of renderers that the component needs.
	 */
	private function drawRenderers(totalRenderers:Number):Void {
		// Remove extra renderers
		while (renderers.length > totalRenderers) {
			renderers.pop().removeMovieClip();
		}
		
		// Add new renderers
		while (renderers.length < totalRenderers) {
			renderers.push(createItemRenderer(renderers.length));
		}
	}	
	
	public function invalidateData():Void {
		selectedIndex = Math.min(_dataProvider.length-1, _selectedIndex);
		_dataProvider.requestItemRange(_scrollPosition, Math.min(_dataProvider.length-1, _scrollPosition+totalRenderers-1), this, "populateData");
	}
		
	/** @exclude */
	public function toString():String {
		return "[Scaleform ImageScroller " + _name + "]";
	}
	
	private function draw():Void {
		if (sizeIsInvalid) { 
			_width = __width;
			_height = __height;
		}	
        
		drawRenderers(_dataProvider.length);        
		drawLayout(loaderWidth, loaderHeight);
		invalidateData();
		
		super.draw();
	}
	
	private function drawLayout(rendererWidth:Number, rendererHeight:Number):Void {
		for (var i:Number = 0; i < renderers.length; i++) {
			
			// Bring the renderers toward the camera (-_z) and to the right (+x)
			renderers[i]._z = (i * -zmargin); 
			renderers[i]._x = (i * 350);
			
			// Ensure they are the enforced width / height.
			renderers[i].width = rendererWidth;
			renderers[i].height = rendererHeight;
		}
	}
	
    // Only fired at the start.
	private function populateData(data:Array):Void {
        loadDataForRenderer(0);
		for (var i:Number = 0; i < renderers.length; i++) {            
			var renderer:MovieClip = renderers[i];
            
			if (i == selectedIndex) {
                if (renderer) {                    
				    renderer.gotoAndPlay("on");
                }
            }		
            else {           
                if (renderer) {                
				    renderer.gotoAndStop(0);
                }
            }                       
            	    		            
            /* Debugging...             
            trace("data[" + i + "]: " + data[i]);
            trace("renderer[" + i + "]: image_text: " + renderer.image_text);
            trace("renderer[" + i + "]: image_text.mode.textField: " + renderer.image_text.mode.textField + ", name: " + data[i].name);
            trace("renderer[" + i + "]: players.textField.text " + renderer.players.textField.text + ", players: " + data[i].players);
            trace("renderer[" + i + "]: image: " + renderer.image + ", image: " + data[i].image);            
            */
		}
	}
}