/**
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTGib_Robot extends UTGib
	abstract;


var name CustomGibSocketName;

simulated function DoCustomGibEffects()
{
	local SkeletalMeshComponent SMC;
	local SkeletalMeshSocket SMS;

	SMC = SkeletalMeshComponent(GibMeshComp);

	if( SMC != none )
	{
		SMS = SMC.GetSocketByName( CustomGibSocketName );

		// so we know the spark exists in this MeshComponent
		if( SMS != none )
		{
			PSC_GibEffect = new(self) class'UTParticleSystemComponent';
			PSC_GibEffect.SetTemplate( PS_CustomEffect );
			SMC.AttachComponentToSocket( PSC_GibEffect, CustomGibSocketName );
		}
	}
}



defaultproperties
{
	HitSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_GibMedium_Cue'

	CustomGibSocketName="Spark"
	PS_CustomEffect=ParticleSystem'Envy_Effects2.Particles.P_Robot_Gib_Spark'

	MITV_GibMeshTemplate=MaterialInstanceTimeVarying'CH_Gibs.Materials.MITV_CH_Gibs_Corrupt01'
}
