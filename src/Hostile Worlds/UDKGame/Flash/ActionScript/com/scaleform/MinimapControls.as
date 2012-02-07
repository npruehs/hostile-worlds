/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY 
 OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

/**
 * This class drives the minimap controls symbol.
 */
import flash.external.ExternalInterface;
import gfx.core.UIComponent;
import gfx.controls.Button;

class com.scaleform.MinimapControls extends UIComponent {
	
	// The controls
	public var btn_compasslock:Button;
	public var btn_player_red:Button;
	public var btn_player_blue:Button;
	public var btn_waypoint:Button;
	public var btn_diamond:Button;
	public var btn_flag:Button;
	public var btn_zoomout:Button;
	public var btn_zoomin:Button;
	
	public function MinimapControls() {}
	
	public function configUI():Void {
		btn_zoomin.addEventListener("click", this, "ZoomIn");
		btn_zoomout.addEventListener("click", this, "ZoomOut");
		btn_flag.addEventListener("click", this, "FilterFlags");
		btn_diamond.addEventListener("click", this, "FilterDiamonds");
		btn_waypoint.addEventListener("click", this, "FilterWaypoints");
		btn_player_blue.addEventListener("click", this, "FilterBluePlayers");
		btn_player_red.addEventListener("click", this, "FilterRedPlayers");
		btn_compasslock.addEventListener("click", this, "CompassLock");
		
		// Add functionality to focus on rollover
		btn_zoomin.addEventListener("rollOver", this, "AcquireFocus");
		btn_zoomout.addEventListener("rollOver", this, "AcquireFocus");
		btn_flag.addEventListener("rollOver", this, "AcquireFocus");
		btn_diamond.addEventListener("rollOver", this, "AcquireFocus");
		btn_waypoint.addEventListener("rollOver", this, "AcquireFocus");
		btn_player_blue.addEventListener("rollOver", this, "AcquireFocus");		
		btn_player_red.addEventListener("rollOver", this, "AcquireFocus");		
		btn_compasslock.addEventListener("rollOver", this, "AcquireFocus");				
	}
	
	function AcquireFocus(e:Object):Void {
		Selection.setFocus(e.target);
	}
	
	function ZoomIn(e:Object):Void {
		ExternalInterface.call("zoomMiniMapView", 1);
	}
	
	function ZoomOut(e:Object):Void {
		ExternalInterface.call("zoomMiniMapView", -1);
	}
	
	function FilterFlags(e:Object):Void {
		ExternalInterface.call("filterFlags", !btn_flag.selected);
	}
	
	function FilterDiamonds(e:Object):Void {
		ExternalInterface.call("filterDiamonds", !btn_diamond.selected);
	}
	
	function FilterWaypoints(e:Object):Void {
		ExternalInterface.call("filterWaypoints", !btn_waypoint.selected);
	}
	
	function FilterBluePlayers(e:Object):Void {
		ExternalInterface.call("filterBluePlayers", !btn_player_blue.selected);
	}
	
	function FilterRedPlayers(e:Object):Void {
		ExternalInterface.call("filterRedPlayers", !btn_player_red.selected);
	}	
	
	function CompassLock(e:Object):Void {
		ExternalInterface.call("lockMiniMapCompass", !e.target.selected);
	}	
}