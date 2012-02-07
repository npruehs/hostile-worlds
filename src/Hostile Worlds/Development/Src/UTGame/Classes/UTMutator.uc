/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTMutator extends Mutator
	abstract;

function bool MutatorIsAllowed()
{
	return UTGame(WorldInfo.Game) != None && Super.MutatorIsAllowed();
}

/** utility to get the next UTMutator in the mutator list, for hooks that aren't in the base engine */
function UTMutator GetNextUTMutator()
{
	local Mutator M;
	local UTMutator UTMut;

	for (M = NextMutator; M != None; M = M.NextMutator)
	{
		UTMut = UTMutator(M);
		if (UTMut != None)
		{
			return UTMut;
		}
	}

	return None;
}

/* ReplaceWith()
 * Call this function to replace an actor Other with an actor of aClass.
 * @note: doesn't destroy the original; can return false from CheckReplacement() to do that
 */
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;
	local PickupFactory OldFactory, NewFactory;

	if ( aClassName == "" )
		return true;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
	{
		A = Spawn(aClass,Other.Owner,,Other.Location, Other.Rotation);
		if (A != None)
		{
			OldFactory = PickupFactory(Other);
			NewFactory = PickupFactory(A);
			if (OldFactory != None && NewFactory != None)
			{
				OldFactory.ReplacementFactory = NewFactory;
				NewFactory.OriginalFactory = OldFactory;
			}
		}
	}
	return ( A != None );
}

/** parses the given player's recognized speech into bot orders, etc */
function ProcessSpeechRecognition(UTPlayerController Speaker, const out array<SpeechRecognizedWord> Words)
{
	local UTMutator UTMut;

	UTMut = GetNextUTMutator();
	if (UTMut != None)
	{
		UTMut.ProcessSpeechRecognition(Speaker, Words);
	}
}

defaultproperties
{
}

