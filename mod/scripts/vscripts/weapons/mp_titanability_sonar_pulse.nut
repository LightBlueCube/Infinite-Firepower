untyped
global function GravityNode_Init
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

void function GravityNode_Init()
{
	RegisterWeaponDamageSource( "mp_titanweapon_gravity_node", "重力場" )
	RegisterWeaponDamageSource( "mp_titanweapon_gravity_node_explode", "重力場" )
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_gravity_node, GravityNodeOnDamage )
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_gravity_node_explode, GravityNodeExplodeOnDamage )
	RegisterBallLightningDamage( eDamageSourceId.mp_titanweapon_gravity_node )
}

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

	if( weapon.HasMod( "tcp_gravity" ) )
		return OnWeaponPrimaryAttack_GravityNode( weapon, attackParams )
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
	if( projectile.ProjectileGetMods().contains( "tcp_gravity" ) )
		return OnProjectileCollision_weapon_deployable( projectile, pos, normal, hitEnt, hitbox, isCritical )
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

int function OnWeaponPrimaryAttack_GravityNode( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	if ( !owner.IsTitan() )
		return 0
	entity soul = owner.GetTitanSoul()
	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )

	entity node = ThrowDeployable( weapon, attackParams, 0, GravityNodePlanted )
	node.SetModel( $"models/weapons/titan_trip_wire/titan_trip_wire_projectile.mdl" )
	node.SetOrigin( owner.EyePosition() )
	vector baseVelocity = owner.GetViewVector()
	node.SetVelocity( baseVelocity * 3000 + < 0, 0, 400 > )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function GravityNodePlanted( entity projectile )
{
	thread GravityNodeThink( projectile )
}

const GRAVITYNODE_LIFETIME = 2.0
const GRAVITYNODE_BUILDUP_TIME = 1.0

void function GravityNodeThink( entity projectile )
{
	vector origin = projectile.GetOrigin() // - <0,0,40>
	vector angles = projectile.proj.savedAngles
	entity owner = projectile.GetOwner()
	entity inflictor = projectile.proj.inflictorOverride
	entity attachparent = projectile.GetParent()

	projectile.SetModel( $"models/dev/empty_model.mdl" )
	projectile.Hide()

	if ( !IsValid( owner ) )
	{
		projectile.Destroy()
		return
	}

	if ( IsNPCTitan( owner ) )
	{
		entity bossPlayer = owner.GetBossPlayer()
		if ( IsValid( bossPlayer ) )
			bossPlayer.EndSignal( "OnDestroy" )
	}
	else
	{
		owner.EndSignal( "OnDestroy" )
	}
	entity soul = owner.GetTitanSoul()
	if( IsValid( soul ) )
	{
		if( soul.IsEjecting() )
		{
			projectile.Destroy()
			return
		}
	}
	int team = owner.GetTeam()

	entity tower = CreatePropScript( $"models/weapons/titan_trip_wire/titan_trip_wire.mdl", origin, angles, SOLID_VPHYSICS )
	tower.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	tower.EnableAttackableByAI( 20, 0, AI_AP_FLAG_NONE )
	SetTargetName( tower, "Laser Tripwire Base" )
	tower.SetTakeDamageType( DAMAGE_NO )
	tower.SetTitle( "Laser Tripwire" )
	EmitSoundOnEntity( tower, "Wpn_LaserTripMine_Land" )
	tower.e.noOwnerFriendlyFire = true

	tower.Anim_Play( "trip_wire_closed_to_open" )
	tower.Anim_DisableUpdatePosition()

	if ( attachparent != null )
		tower.SetParent( attachparent )

	// hijacking this int so we don't create a new one
	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, GRAVITYNODE_LIFETIME, 400 )

	SetTeam( tower, team )
	thread TrapDestroyOnRoundEnd( owner, tower )

	entity ball = ChargeBall_CreateBallLightning( owner, origin, angles )
	entity mover = CreateScriptMover( origin, angles )
	ball.SetParent( mover )

	OnThreadEnd(
	function() : ( projectile, inflictor, tower, noSpawnIdx, team, ball, mover )
		{
			if( IsValid( projectile ) )
			{
				vector origin = projectile.GetOrigin()
				PlayImpactFXTable( origin, null, "exp_satchel" )
				EmitSoundAtPosition( team, origin, "Wpn_LaserTripMine_MineDestroyed" )

				entity owner = projectile.GetOwner()
				if ( IsValid( owner ) )
				{
					RadiusDamage(
						origin,											// center
						owner,											// attacker
						inflictor,										// inflictor
						20,												// damage
						400,											// damageHeavyArmor
						400,											// innerRadius
						400,											// outerRadius
						SF_ENVEXPLOSION_NO_DAMAGEOWNER,					// flags
						0,												// distanceFromAttacker
						0,												// explosionForce
						DF_EXPLOSION | DF_STOPS_TITAN_REGEN,			// scriptDamageFlags
						eDamageSourceId.mp_titanweapon_gravity_node_explode )		// scriptDamageSourceIdentifier
				}
			}
			foreach ( p in projectile.proj.projectileGroup )
			{
				if ( IsValid( p ) )
				{
					p.Destroy()
				}
			}

			DeleteNoSpawnArea( noSpawnIdx )

			if ( IsValid( tower ) )
			{
				tower.Destroy()
			}

			if ( IsValid( projectile ) )
				projectile.Destroy()

			if ( IsValid( inflictor ) )
				inflictor.Kill_Deprecated_UseDestroyInstead( 1.0 )

			if( IsValid( ball ) )
				ball.Destroy()
			if( IsValid( mover ) )
				mover.Destroy()
		}
	)
	owner.EndSignal( "TitanEjectionStarted" )
	tower.EndSignal( "OnDestroy" )


	mover.NonPhysicsMoveTo( mover.GetOrigin() + < 0, 0, 100 >, 1.0, 0.0, 0.0 )
	wait GRAVITYNODE_BUILDUP_TIME

	if ( !IsAlive( owner ) )
		return

	if ( !IsNPCTitan( owner ) )
		owner.EndSignal( "OnDeath" )


	wait GRAVITYNODE_LIFETIME
}


entity function ChargeBall_CreateBallLightning( entity owner, vector origin, vector angles )
{
	entity ballLightning = CreateScriptMover( origin, angles )
	ballLightning.SetOwner( owner )
	SetTeam( ballLightning, owner.GetTeam() )

	thread DelayedStartParticleSystem( ballLightning )
	thread ChargeBall_BallLightningThink( ballLightning, eDamageSourceId.mp_titanweapon_gravity_node )
	return ballLightning
}

void function DelayedStartParticleSystem( entity bolt )
{
    WaitFrame()
    if( IsValid( bolt ) )
        StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"P_wpn_arcball_trail_amp" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
}

void function ChargeBall_BallLightningThink( entity ballLightning, int damageSourceId )
{
	ballLightning.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( ballLightning, "Weapon_Arc_Ball_Loop" )
	EmitSoundOnEntity( ballLightning, "default_gravitystar_impact_3p" )
	entity FX = StartParticleEffectOnEntity_ReturnEntity( ballLightning, GetParticleSystemIndex( $"P_wpn_grenade_gravity" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	OnThreadEnd(
		function() : ( ballLightning, FX )
		{
			if ( IsValid( ballLightning ) )
			{
				StopSoundOnEntity( ballLightning, "Weapon_Arc_Ball_Loop" )
			}
			EntFireByHandle( FX, "kill", "", 1.5, null, null )
		}
	)

	int inflictorTeam = ballLightning.GetTeam()
	ballLightning.e.ballLightningTargetsIdx = CreateScriptManagedEntArray()

	wait GRAVITYNODE_BUILDUP_TIME
	EmitSoundOnEntity( ballLightning, "weapon_gravitystar_preexplo" )

	while( 1 )
	{
		vector origin = ballLightning.GetOrigin()
		BallLightningData fxData = ballLightning.e.ballLightningData
		RadiusDamage(
			origin,							// origin
			ballLightning.GetOwner(),		// owner
			ballLightning,		 			// inflictor
			1,								// normal damage
			20,								// heavy armor damage
			500,							// inner radius
			500,							// outer radius
			SF_ENVEXPLOSION_NO_DAMAGEOWNER,	// explosion flags
			0, 								// distanceFromAttacker
			0, 								// explosionForce
			fxData.deathPackage,			// damage flags
			damageSourceId					// damage source id
		)
		wait 0.1
	}
}

void function GravityNodeOnDamage( entity target, var damageInfo )
{
	entity ball = DamageInfo_GetInflictor( damageInfo )

	if( !IsValid( ball ) || !IsValid( target ) )
		return
	if( !target.IsNPC() && !target.IsPlayer() )
		return
	if( target.GetParent() )
		return

	vector origin = ball.GetOrigin()
	target.SetVelocity( origin - target.GetOrigin() )
	StatusEffect_AddTimed( target, eStatusEffect.emp, 0.4, 1.0, 0.5 )
	if( target.IsOnGround() )
		target.SetVelocity( target.GetVelocity() + < 0, 0, 210 > )
}

void function GravityNodeExplodeOnDamage( entity target, var damageInfo )
{
	if( !IsValid( target ) )
		return
	if( !target.IsNPC() && !target.IsPlayer() )
		return

	vector origin = DamageInfo_GetDamagePosition( damageInfo )

	target.SetVelocity( ( Normalize( target.GetOrigin() - origin ) * 600 ) + < 0, 0, 200 > )
}

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