/**********************************************************************
 Copyright (c) 2010 Scaleform Corporation. All Rights Reserved.
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/
class com.scaleform.udk.controls.ScoreboardItemRenderer extends MovieClip {
	
// Constants:

// Public Properties:
	public var data:Object;
	public var test:MovieClip;
	public var place:MovieClip;
	public var name:MovieClip;
	public var score:MovieClip;
	public var deaths:MovieClip;	
	
	public var PlayerName:String;
	public var PlayerScore:String;
	public var PlayerDeaths:String;
	
// Initialization:
	public function ScoreboardItemRenderer() { 
		super(); 		
    }
    	
// Public Methods:    
    public function UpdateAfterStateChange() {
        if (name && PlayerName)
            name.htmlText = PlayerName;
            
        if (score && PlayerScore)
            score.text = PlayerScore;
        
        if (deaths && PlayerDeaths)
            deaths.text = PlayerDeaths;
	}
}