/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqAct_ScriptedVoiceMessage extends SequenceAction;

var() SoundNodeWave VoiceToPlay;
var() string SpeakingCharacterName;

event Activated()
{
	local UTGameReplicationInfo GRI;
	local UTPlayerReplicationInfo PRI, Sender;
	local int i;

	GRI = UTGameReplicationInfo(GetWorldInfo().GRI);
	if (GRI != None)
	{
		for (i = 0; i < GRI.PRIArray.length; i++)
		{
			PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
			if ( PRI != None && ( PRI.PlayerName ~= SpeakingCharacterName ) )
			{
				Sender = PRI;
				break;
			}
		}

		if (Sender != None)
		{
			GRI.BroadcastLocalizedMessage(class'UTScriptedVoiceMessage',, Sender,, VoiceToPlay);
		}
		else
		{
			ScriptLog("Failed to find character '" $ SpeakingCharacterName $ "' for scripted voice message");
		}
	}
}

/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjName="Play Voice Message"
	ObjCategory="Voice/Announcements"
	VariableLinks.Empty()
}
