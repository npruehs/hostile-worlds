/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY 
 OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

/**
 * This class drives the minimap symbol.
 */
import flash.external.ExternalInterface;
import gfx.controls.InventorySlot;
import gfx.controls.DragTarget;
import gfx.managers.DragManager;

class com.scaleform.HUDInventorySlot extends InventorySlot {
	
	public function HUDInventorySlot() {
		super();
		_visible = true;
	}	
	
	public function setData(data:Object){
		this._data = data;
		trace(this+".data.type: " + _data.type);
		trace(this+".data.asset: " + _data.asset);
		update();
	}
	
	public function setType(type:String){
		_data.type = type;
		trace(this+".type: " + this._data.type);
		update();
	}
	
	public function setAsset(asset:Number){
		_data.asset = asset;
		trace("asset: " + asset);
		trace(this+".asset: " + this._data.asset);
		update();
	}
	
	private function update():Void {
		icons.gotoAndStop(_data == null ? 1 : _data.asset);
	}
	
	private function acceptDrop(data:Object):Void {
		super.acceptDrop(data);
		ExternalInterface.call("swapInventorySlot", _data);
	}
	
	private function handleRollOver(mouseIndex:Number):Void {
		gotoAndPlay("over");
		if (trackAsMenu) {
			gotoAndPlay("dragOver");
		}
		DragManager.instance.dropTarget = this;
		
		if (DragManager.instance.target == null || DragManager.instance.target == undefined)
		{
			trace(this+"._data.asset: " + _data.asset);
			_root.itemInfo.gotoAndStop(_data == null ? 1 : _data.asset);
		}
	}
	
	private function handleRollOut(mouseIndex:Number):Void {
		gotoAndPlay("up");
		gotoAndPlay("out");
		if (trackAsMenu) {
			gotoAndStop("dragUp");
			gotoAndPlay("dragOut");
			DragManager.instance.dropTarget = null;
		}
		if (DragManager.instance.target == null || DragManager.instance.target == undefined)
		{
			_root.itemInfo.gotoAndStop(1);
		}
	}
}