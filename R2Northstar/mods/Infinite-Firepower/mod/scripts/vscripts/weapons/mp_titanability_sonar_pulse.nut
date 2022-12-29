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
		if( mods.contains( "tcp" ) )
		{
			thread EmpSonar( projectile )
		}
		if( mods.contains( "tcp_fast_emp" ) )
		{
			entity inflictor = CreateScriptMover( projectile.GetOrigin() )
			if( IsValid( owner ) )
				owner.TakeSharedEnergy( int( float( owner.GetSharedEnergyCount() ) / 2 ) )
			thread FastEmpSonar( projectile, inflictor )
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

void function EmpSonar( entity projectile )
{
	entity inflictor = CreateScriptMover( projectile.GetOrigin() )
	SetTeam( inflictor, projectile.GetTeam() )
	inflictor.SetOwner( projectile.GetOwner() )
	wait 1
	int val = 0
	while( val <= 8 )
	{
		thread EMPSonarThinkConstant( inflictor )
		++val
	}
	wait 5
	inflictor.Destroy()
}

void function FastEmpSonar( entity projectile, entity inflictor )
{
	SetTeam( inflictor, projectile.GetTeam() )
	inflictor.SetOwner( projectile.GetOwner() )
	int val = 0
	while( val <= 8 )
	{
		thread EMPSonarThinkConstant( inflictor, false )
		++val
	}
	wait 0.5
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
	if( IsValid( sonarOwner ) )
		if( IsValid( sonarOwner.GetOffhandWeapon( OFFHAND_SPECIAL ) ) )
			if( sonarOwner.GetOffhandWeapon( OFFHAND_SPECIAL ).HasMod( "tcp" ) )
				return

	enemy.EndSignal( "OnDeath" )
	enemy.EndSignal( "OnDestroy" )

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




const DAMAGE_AGAINST_TITANS_EMPBOMB 			= 25
const DAMAGE_AGAINST_PILOTS_EMPBOMB 			= 1

const DAMAGE_AGAINST_TITANS 			= 15
const DAMAGE_AGAINST_PILOTS 			= 1

const EMP_DAMAGE_TICK_RATE = 0.1
const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"

struct
{
	array<entity> empTitans
} file

void function timeoutcheck( entity titan, bool EMPSonar )
{
	if( EMPSonar )
		wait 5
	else
		wait 0.5
	titan.Signal("empistimeout")
}

void function EMPSonarThinkConstant( entity titan, bool EMPSonar = true )
{
	RegisterSignal( "empistimeout" )
	thread timeoutcheck( titan, EMPSonar )

	titan.EndSignal( "empistimeout" )
	//titan.EndSignal( "OnDeath" )
	//titan.EndSignal( "OnDestroy" )
	//titan.EndSignal( "Doomed" )
	//titan.EndSignal( "StopEMPField" )

	//We don't want pilots accidently rodeoing an electrified titan.
	//DisableTitanRodeo( titan )

	//Used to identify this titan as an arc titan
	// SetTargetName( titan, "empTitan" ) // unable to do this due to FD reasons
	file.empTitans.append( titan )

	//Wait for titan to stand up and exit bubble shield before deploying arc ability.
	WaitTillHotDropComplete( titan )

	/*if ( HasSoul( titan ) )
	{
		entity soul = titan.GetTitanSoul()
		soul.EndSignal( "StopEMPField" )
	}*/

	local attachment = "hijack"

	local attachID = titan.LookupAttachment( attachment )

	EmitSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )

	array<entity> particles = []

	//emp field fx
	vector origin = titan.GetOrigin()
	if ( titan.IsPlayer() )
	{
		entity particleSystem = CreateEntity( "info_particle_system" )
		particleSystem.kv.start_active = 1
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
		particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD_1P )

		particleSystem.SetOrigin( origin )
		particleSystem.SetOwner( titan.GetOwner() )
		DispatchSpawn( particleSystem )
		//particleSystem.SetParent( titan, "" )
		particles.append( particleSystem )
	}

	entity particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	if ( titan.IsPlayer() )
		particleSystem.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	else
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD )
	particleSystem.SetOwner( titan.GetOwner() )
	particleSystem.SetOrigin( origin )
	DispatchSpawn( particleSystem )
	//particleSystem.SetParent( titan, "" )
	particles.append( particleSystem )

	//titan.SetDangerousAreaRadius( ARC_TITAN_EMP_FIELD_RADIUS )

	OnThreadEnd(
		function () : ( titan, particles )
		{
			if ( IsValid( titan ) )
			{
				StopSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )
				//EnableTitanRodeo( titan ) //Make the arc titan rodeoable now that it is no longer electrified.
				if (file.empTitans.find( titan ) )
					file.empTitans.remove( file.empTitans.find( titan ) )
			}

			foreach ( particleSystem in particles )
			{
				if ( IsValid_ThisFrame( particleSystem ) )
				{
					particleSystem.ClearParent()
					particleSystem.Fire( "StopPlayEndCap" )
					particleSystem.Kill_Deprecated_UseDestroyInstead( 1.0 )
				}
			}
		}
	)

	if( EMPSonar )
	{

		wait RandomFloat( EMP_DAMAGE_TICK_RATE )

		while ( true )
		{
			origin = titan.GetOrigin()

			RadiusDamage(
   				origin,									// center
   				titan,									// attacker
   				titan,									// inflictor
   				DAMAGE_AGAINST_PILOTS,					// damage
   				DAMAGE_AGAINST_TITANS,					// damageHeavyArmor
   				ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
   				ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
   				SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
   				0,										// distanceFromAttacker
   				DAMAGE_AGAINST_PILOTS,					// explosionForce
   				DF_ELECTRICAL | DF_STOPS_TITAN_REGEN,	// scriptDamageFlags
	   			eDamageSourceId.mp_weapon_grenade_emp )			// scriptDamageSourceIdentifier

			wait EMP_DAMAGE_TICK_RATE
		}
	}
	else
	{
		wait RandomFloat( EMP_DAMAGE_TICK_RATE )

		while ( true )
		{
			origin = titan.GetOrigin()

			RadiusDamage(
   				origin,									// center
   				titan,									// attacker
   				titan,									// inflictor
   				DAMAGE_AGAINST_PILOTS_EMPBOMB,					// damage
   				DAMAGE_AGAINST_TITANS_EMPBOMB,					// damageHeavyArmor
   				ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
   				ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
   				SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
   				0,										// distanceFromAttacker
   				DAMAGE_AGAINST_PILOTS_EMPBOMB,					// explosionForce
   				DF_ELECTRICAL | DF_STOPS_TITAN_REGEN,	// scriptDamageFlags
	   			eDamageSourceId.mp_weapon_grenade_emp )			// scriptDamageSourceIdentifier

			wait EMP_DAMAGE_TICK_RATE
		}
	}
}
