untyped
global function OnProjectileCollision_titanability_sonar_pulse
global function OnWeaponPrimaryAttack_titanability_sonar_pulse
global function OnWeaponAttemptOffhandSwitch_titanability_sonar_pulse

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_sonar_pulse
global function PulseLocation
global function DelayedPulseLocation
#endif

const int SONAR_PULSE_RADIUS = 1250
const float SONAR_PULSE_DURATION = 5.0
const float FD_SONAR_PULSE_DURATION = 10.0

bool function OnWeaponAttemptOffhandSwitch_titanability_sonar_pulse( entity weapon )
{
	bool allowSwitch
	allowSwitch = weapon.GetWeaponChargeFraction() == 0.0

	return allowSwitch
}

var function OnWeaponPrimaryAttack_titanability_sonar_pulse( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	return FireSonarPulse( weapon, attackParams, true )
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanability_sonar_pulse( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( IsSingleplayer() )
	{
		entity titan = weapon.GetWeaponOwner()
		entity owner = GetPetTitanOwner( titan )
		if ( !IsValid( owner ) || !owner.IsPlayer() )
			return
		int conversationID = GetConversationIndex( "sonarPulse" )
		Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
	}
	return FireSonarPulse( weapon, attackParams, false )
}
#endif

int function FireSonarPulse( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	#endif
	int result = FireGenericBoltWithDrop( weapon, attackParams, playerFired )
	weapon.SetWeaponChargeFractionForced(1.0)
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnProjectileCollision_titanability_sonar_pulse( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		entity owner = projectile.GetOwner()
		array<string> mods = projectile.ProjectileGetMods()
		if( mods.contains( "tcp_smoke" ) )
		{
			thread SonarSmoke( projectile, owner )
			return
		}

		if ( !IsValid( owner ) )
			return

		int team = owner.GetTeam()

		bool hasIncreasedDuration = mods.contains( "fd_sonar_duration" )
		bool hasDamageAmp = mods.contains( "fd_sonar_damage_amp" )
		PulseLocation( owner, team, pos, hasIncreasedDuration, hasDamageAmp )
		if ( mods.contains( "pas_tone_sonar" ) )
			thread DelayedPulseLocation( owner, team, pos, hasIncreasedDuration, hasDamageAmp )

	#endif
}

void function SonarSmoke( entity projectile, entity owner )
{
	entity inflictor = CreateScriptMover( projectile.GetOrigin() )
	SetTeam( inflictor, projectile.GetTeam() )
	inflictor.SetOwner( projectile.GetOwner() )
	thread TitanSonarSmokescreen( inflictor, owner )
	wait 5
	inflictor.Destroy()
}

#if SERVER
void function DelayedPulseLocation( entity owner, int team, vector pos, bool hasIncreasedDuration, bool hasDamageAmp )
{
	wait 2.0
	if ( !IsValid( owner ) )
		return
	PulseLocation( owner, team, pos, hasIncreasedDuration, hasDamageAmp )
	if ( owner.IsPlayer() )
	{
		EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, pos, owner, "Titan_Tone_SonarLock_Impact_Pulse_3P" )
		EmitSoundAtPositionOnlyToPlayer( TEAM_UNASSIGNED, pos, owner, "Titan_Tone_SonarLock_Impact_Pulse_1P" )
	}
	else
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, pos, "Titan_Tone_SonarLock_Impact_Pulse_3P" )
	}

}

void function PulseLocation( entity owner, int team, vector pos, bool hasIncreasedDuration, bool hasDamageAmp )
{
	array<entity> nearbyEnemies = GetNearbyEnemiesForSonarPulse( team, pos )
	foreach( enemy in nearbyEnemies )
	{
		thread SonarPulseThink( enemy, pos, team, owner, hasIncreasedDuration, hasDamageAmp )
		ApplyTrackerMark( owner, enemy )
	}
	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_SonarPulseFromPosition", pos.x, pos.y, pos.z, SONAR_PULSE_RADIUS, 1.0, hasDamageAmp )
	}
}

void function SonarPulseThink( entity enemy, vector position, int team, entity sonarOwner, bool hasIncreasedDuration, bool hasDamageAmp )
{
	enemy.EndSignal( "OnDeath" )
	enemy.EndSignal( "OnDestroy" )

	if( IsValid( sonarOwner ) )
	{
		if( IsValid( sonarOwner.GetOffhandWeapon( OFFHAND_TITAN_CENTER ) ) )
			if( sonarOwner.GetOffhandWeapon( OFFHAND_TITAN_CENTER ).HasMod( "tcp_smoke" ) )
				return
	}


	int statusEffect = 0
	if ( hasDamageAmp )
		statusEffect = StatusEffect_AddEndless( enemy, eStatusEffect.damage_received_multiplier, 0.25 )

	SonarStart( enemy, position, team, sonarOwner )

	int sonarTeam = sonarOwner.GetTeam()
	IncrementSonarPerTeam( sonarTeam )

	OnThreadEnd(
	function() : ( enemy, sonarTeam, statusEffect, hasDamageAmp )
		{
			DecrementSonarPerTeam( sonarTeam )
			if ( IsValid( enemy ) )
			{
				SonarEnd( enemy, sonarTeam )
				if ( hasDamageAmp )
					StatusEffect_Stop( enemy, statusEffect )
			}
		}
	)

	float duration
	if ( hasIncreasedDuration )
		duration = FD_SONAR_PULSE_DURATION
	else
		duration = SONAR_PULSE_DURATION

	wait duration
}

array<entity> function GetNearbyEnemiesForSonarPulse( int team, vector origin )
{
	array<entity> nearbyEnemies
	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, origin, SONAR_PULSE_RADIUS )
	foreach ( guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		if ( IsEnemyTeam( team, guy.GetTeam() ) )
			nearbyEnemies.append( guy )
	}

	array<entity> ai = GetNPCArrayEx( "any", TEAM_ANY, team, origin, SONAR_PULSE_RADIUS )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) )
			nearbyEnemies.append( guy )
	}

	if ( GAMETYPE == FORT_WAR )
	{
		array<entity> harvesters = GetEntArrayByScriptName( "fw_team_tower" )
		foreach ( harv in harvesters )
		{
			if ( harv.GetTeam() == team )
				continue

			if ( Distance( origin, harv.GetOrigin() ) < SONAR_PULSE_RADIUS )
			{
				nearbyEnemies.append( harv )
			}
		}
	}

	return nearbyEnemies
}
#endif

void function TitanSonarSmokescreen( entity ent, entity owner )
{
	SmokescreenStruct smokescreen
	smokescreen.isElectric = true
	smokescreen.ownerTeam = ent.GetTeam()
	smokescreen.attacker = owner
	smokescreen.inflictor = ent
	smokescreen.weaponOrProjectile = ent
	smokescreen.damageInnerRadius = 320.0
	smokescreen.damageOuterRadius = 375.0
	smokescreen.dpsPilot = 45
	smokescreen.dpsTitan = 850
	smokescreen.damageDelay = 1.0
	smokescreen.deploySound1p = SFX_SMOKE_DEPLOY_BURN_1P
	smokescreen.deploySound3p = SFX_SMOKE_DEPLOY_BURN_3P

	vector eyeAngles = <0.0, ent.EyeAngles().y, 0.0>
	smokescreen.angles = eyeAngles

	vector forward = AnglesToForward( eyeAngles )
	vector testPos = ent.GetOrigin() + forward * 240.0
	vector basePos = testPos

	float trace = TraceLineSimple( ent.EyePosition(), testPos, ent )
	if ( trace != 1.0 )
		basePos = ent.GetOrigin()

	float fxOffset = 200.0
	float fxHeightOffset = 148.0

	smokescreen.origin = basePos

	smokescreen.fxOffsets = [ < -fxOffset, 0.0, 20.0>,
							  <0.0, fxOffset, 20.0>,
							  <0.0, -fxOffset, 20.0>,
							  <0.0, 0.0, fxHeightOffset>,
							  < -fxOffset, 0.0, fxHeightOffset> ]

	Smokescreen( smokescreen )
}