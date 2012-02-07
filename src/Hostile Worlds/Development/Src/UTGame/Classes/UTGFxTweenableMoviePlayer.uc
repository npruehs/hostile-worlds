/**********************************************************************

Copyright   :   (c) 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright © 2010 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
/**
 * Base class for a GFxMoviePlayer with a TweenManager.
 * Workaround for lack of multiple inheritance.
 */
class UTGFxTweenableMoviePlayer extends GFxMoviePlayer;

enum TweenType
{
	TWEEN_EaseOut,
	TWEEN_EaseIn,
	TWEEN_Linear
};

struct GFxTween
{
	var GFxObject TargetMC;
	var float TweenTime;
	var float Duration, StartValue, Delta, DesiredValue;
	var string MemberName;
	var string Callback;
	var ASDisplayInfo displayInfo;
	var bool bFinished;
	var TweenType ThisTweenType;
};

var array<GFxTween> TweenList;

/*
 * Create a new tween on a GFxObject.
 * 
 * mc: Target GFxObject to tween.
 * duration: Duration of tween.
 * member: A number member of GFxObject to tween (ie. "_z").
 * target: A float that, when reached, triggers the tween stop.
 * tweenClass: The type of tween (EaseOut, EaseIn, Linear).
 * callback: Data which can be used by the class which instaniated the tween to trigger a subsequent event.
 */
function TweenTo(GFxObject mc, float duration, String member, float target, TweenType NewTweenType, optional String callback = "")
{
    local GFxTween Tween;

    Tween.TargetMC = mc;
    Tween.Duration = Duration;
    Tween.MemberName = member;
    Tween.DesiredValue = target;
    Tween.StartValue = mc.GetFloat(member);
    Tween.Callback = Callback;
	Tween.ThisTweenType = NewTweenType;

	TweenList[TweenList.Length] = Tween;
}

function ProcessTweenCallback(String Callback, GFxObject TargetMC);

/*
 * Iterate through managed tweens and update each.
 */
function Tick(Float deltaTime)
{
	local int i;
	local float pos, CurrentValue;

	for ( i=0; i<TweenList.Length; i++ )
	{
		if (!TweenList[i].bFinished)
		{
			TweenList[i].TweenTime += DeltaTime;
			pos = TweenList[i].TweenTime/TweenList[i].Duration;
			switch(TweenList[i].ThisTweenType)
			{
			case TWEEN_EaseIn:
				pos = pos*pos*pos;
			case TWEEN_EaseOut:
				pos = pos - 1;
				pos = (pos * pos * pos) + 1;
			case TWEEN_Linear:
				break;
			default:
				pos = 1.0;
				break;
			}

			CurrentValue = (TweenList[i].DesiredValue - TweenList[i].StartValue) * pos + TweenList[i].StartValue;
			TweenList[i].TargetMC.SetFloat(TweenList[i].MemberName, CurrentValue);

			if (pos > 1.0)
			{
				TweenList[i].bFinished = true;
				TweenComplete(i);
			}
		}
	}
}

/*
 * Remove all existing tweens on target MovieClip.
 * 
 * mc: Target GFxObject.
 * bReset:  If true, MovieClip immediately reverts to original position.
 *          If false, MovieClip tweens back to original position.
 */
function ClearsTweensOnMovieClip(GFxObject mc, optional bool bReset = TRUE)
{
	local int i;
	local GFxTween Item;

	for ( i=0; i<TweenList.Length; i++ )
	{
		Item = TweenList[i];
        if (Item.TargetMC == mc)
        {
            Item.bFinished = true;
            if (bReset)
			{
                Item.TargetMC.SetFloat(Item.MemberName, Item.StartValue);
			}
			TweenList.Remove(i,1);
        }
    }
}

/*
 * Print a list of existing managed tweens to the log.
 * Used for debugging.
 */
function PrintTweensToLog()
{
	local int i;

	for ( i=0; i<TweenList.Length; i++ )
        `Log(i @ TweenList[i].ThisTweenType);
}

/*
 * When a managed tween is finished, it fires a callback to this function.
 * Pass the tween's callback to ProcessTweenCallback() and delete
 * the tween.
 */
function TweenComplete(int index)
{
    ProcessTweenCallback(TweenList[index].Callback, TweenList[index].TargetMC);
	TweenList.Remove(index,1);
}
