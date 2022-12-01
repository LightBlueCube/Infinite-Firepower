global function OnWeaponActivate_titancore_flame_wave
global function MpTitanWeaponFlameWave_Init

global function OnAbilityCharge_FlameWave
global function OnAbilityChargeEnd_FlameWave

global function OnWeaponPrimaryAttack_titancore_flame_wave

const float PROJECTILE_SEPARATION = 128
const float FLAME_WALL_MAX_HEIGHT = 110
const asset FLAME_WAVE_IMPACT_TITAN = $"P_impact_exp_med_metal"
const asset FLAME_WAVE_IMPACT 		= $"P_impact_exp_xsmll_metal"
const asset FLAMEWAVE_EFFECT 		= $"P_wpn_meteor_wave"
const asset FLAMEWAVE_EFFECT_CONTROL = $"P_wpn_meteor_waveCP"

const string FLAME_WAVE_LEFT_SFX = "flamewave_blast_left"
const string FLAME_WAVE_MIDDLE_SFX = "flamewave_blast_middle"
const string FLAME_WAVE_RIGHT_SFX = "flamewave_blast_right"

const int TITAN_GROUND_SLAM_DAMAGE = 500
const int TITAN_GROUND_SLAM_DAMAGE_HEAVYARMOR = 2500
const float TITAN_GROUND_SLAM_INNER_RADIUS = 450
const float TITAN_GROUND_SLAM_RADIUS = 525

void function MpTitanWeaponFlameWave_Init()
{
	PrecacheParticleSystem( FLAME_WAVE_IMPACT_TITAN )
	PrecacheParticleSystem( FLAME_WAVE_IMPACT )
	PrecacheParticleSystem( FLAMEWAVE_EFFECT )
	PrecacheParticleSystem( FLAMEWAVE_EFFECT_CONTROL )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_flame_wave, FlameWave_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_flame_wave_secondary, FlameWave_DamagedPlayerOrNPC )
	#endif
}

void function OnWeaponActivate_titancore_flame_wave( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	if( owner.IsPlayer() && weapon.HasMod( "ground_slam" ) )
		return OnWeaponActivate_titancore_ground_slam( weapon )
	weapon.EmitWeaponSound_1p3p( "flamewave_start_1p", "flamewave_start_3p" )
	OnAbilityCharge_TitanCore( weapon )
}


bool function OnAbilityCharge_FlameWave( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	if( owner.IsPlayer() && weapon.HasMod( "ground_slam" ) )
		return OnAbilityCharge_GoundSlam( weapon )
	#if SERVER
		float chargeTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
		entity soul = owner.GetTitanSoul()
		if ( soul == null )
			soul = owner
		StatusEffect_AddTimed( soul, eStatusEffect.move_slow, 0.6, chargeTime, 0 )
		StatusEffect_AddTimed( soul, eStatusEffect.dodge_speed_slow, 0.6, chargeTime, 0 )
		StatusEffect_AddTimed( soul, eStatusEffect.damageAmpFXOnly, 1.0, chargeTime, 0 )

		if ( owner.IsPlayer() )
			owner.SetTitanDisembarkEnabled( false )
		else
			owner.Anim_ScriptedPlay( "at_antirodeo_anim_fast" )
	#endif

	return true
}

void function OnAbilityChargeEnd_FlameWave( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	if( owner.IsPlayer() && weapon.HasMod( "ground_slam" ) )
		return OnAbilityChargeEnd_GoundSlam( weapon )
	#if SERVER
		if ( owner.IsPlayer() )
			owner.SetTitanDisembarkEnabled( true )
		OnAbilityChargeEnd_TitanCore( weapon )
	#endif // #if SERVER
}

var function OnWeaponPrimaryAttack_titancore_flame_wave( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	if( owner.IsPlayer() && weapon.HasMod( "ground_slam" ) )
		return OnWeaponPrimaryAttack_titancore_ground_slam( weapon, attackParams )
	OnAbilityStart_TitanCore( weapon )

	#if SERVER
	OnAbilityEnd_TitanCore( weapon )
	#endif
	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	#if SERVER
	//This wave attack is spawning 3 waves, and we want them all to only do damage once to any individual target.
	entity inflictor = CreateDamageInflictorHelper( 10.0 )
	entity scorchedEarthInflictor = CreateOncePerTickDamageInflictorHelper( 10.0 )
	#endif

	array<float> offsets = [ -1.0, 0.0, 1.0 ]
	array<string> soundFXs = [ FLAME_WAVE_RIGHT_SFX, FLAME_WAVE_MIDDLE_SFX, FLAME_WAVE_LEFT_SFX ]
	Assert( offsets.len() == soundFXs.len(), "There should be a sound for each projectile." )
	int count = 0
	while ( count < offsets.len() )
	{
		//JFS - Bug 210617
		Assert( IsValid( weapon.GetWeaponOwner() ), "JFS returning out - need to investigate why the owner is invalid." )
		if ( !IsValid( weapon.GetWeaponOwner() ) )
			return

		vector right = CrossProduct( attackParams.dir, <0,0,1> )
		vector offset = offsets[count] * right * PROJECTILE_SEPARATION

		const float FUSE_TIME = 99.0
		entity projectile = weapon.FireWeaponGrenade( attackParams.pos + offset, attackParams.dir, < 0,0,0 >, FUSE_TIME, damageTypes.projectileImpact, damageTypes.explosive, shouldPredict, true, true )
		if ( IsValid( projectile ) )
		{
			#if SERVER
				EmitSoundOnEntity( projectile, soundFXs[count] )
				weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.5 )
				thread BeginFlameWave( projectile, count, inflictor, attackParams.pos + offset, attackParams.dir )
				if ( weapon.HasMod( "pas_scorch_flamecore" ) )
					thread BeginScorchedEarth( projectile, count, scorchedEarthInflictor, attackParams.pos + offset, attackParams.dir )
			#elseif CLIENT
				ClientScreenShake( 8.0, 10.0, 1.0, Vector( 0.0, 0.0, 0.0 ) )
			#endif
		}
		count++
	}

	return 1
}

#if SERVER
void function BeginFlameWave( entity projectile, int projectileCount, entity inflictor, vector pos, vector dir )
{
	projectile.EndSignal( "OnDestroy" )
	projectile.SetAbsOrigin( projectile.GetOrigin() )
	//projectile.SetAbsAngles( projectile.GetAngles() )
	projectile.SetVelocity( Vector( 0, 0, 0 ) )
	projectile.StopPhysics()
	projectile.SetTakeDamageType( DAMAGE_NO )
	projectile.Hide()
	projectile.NotSolid()
	waitthread WeaponAttackWave( projectile, projectileCount, inflictor, pos, dir, CreateFlameWaveSegment )
	projectile.Destroy()
}

void function BeginScorchedEarth( entity projectile, int projectileCount, entity inflictor, vector pos, vector dir )
{
	if ( !IsValid( projectile ) )
		return
	projectile.EndSignal( "OnDestroy" )
	waitthread WeaponAttackWave( projectile, projectileCount, inflictor, pos, dir, CreateThermiteWallSegment )
	projectile.Destroy()
}

bool function CreateFlameWaveSegment( entity projectile, int projectileCount, entity inflictor, entity movingGeo, vector pos, vector angles, int waveCount )
{
	array<string> mods = projectile.ProjectileGetMods()
	projectile.SetOrigin( pos + < 0, 0, 100 > )
	projectile.SetAngles( angles )

	int flags = DF_EXPLOSION | DF_STOPS_TITAN_REGEN | DF_DOOM_FATALITY | DF_SKIP_DAMAGE_PROT

	if( !( waveCount in inflictor.e.waveLinkFXTable ) )
	{
		entity waveEffectLeft = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FLAMEWAVE_EFFECT_CONTROL ), pos, angles )
		entity waveEffectRight = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FLAMEWAVE_EFFECT_CONTROL ), pos, angles )
		EntFireByHandle( waveEffectLeft, "Kill", "", 3.0, null, null )
		EntFireByHandle( waveEffectRight, "Kill", "", 3.0, null, null )
		vector leftOffset = pos + projectile.GetRightVector() * FLAME_WALL_MAX_HEIGHT
		vector rightOffset = pos + projectile.GetRightVector() * -FLAME_WALL_MAX_HEIGHT
		EffectSetControlPointVector( waveEffectLeft, 1, leftOffset )
		EffectSetControlPointVector( waveEffectRight, 1, rightOffset )
		array<entity> rowFxArray = [ waveEffectLeft, waveEffectRight ]
		inflictor.e.waveLinkFXTable[ waveCount ] <- rowFxArray
	}
	else
	{
		array<entity> rowFxArray = inflictor.e.waveLinkFXTable[ waveCount ]
		if ( projectileCount == 1 )
		{
			foreach( fx in rowFxArray )
			{
				fx.SetOrigin( pos )
				fx.SetAngles( angles )
			}
		}
		vector rightOffset = pos + projectile.GetRightVector() * -FLAME_WALL_MAX_HEIGHT
		EffectSetControlPointVector( rowFxArray[1], 1, rightOffset )

		//Catches the case where the middle projectile is destroyed and two outer waves continue forward.
		if ( Distance2D( rowFxArray[1].GetOrigin(), rightOffset ) > PROJECTILE_SEPARATION + FLAME_WALL_MAX_HEIGHT )
		{
			rowFxArray[0].SetOrigin( rowFxArray[0].GetOrigin() + rowFxArray[0].GetRightVector() * -FLAME_WALL_MAX_HEIGHT )
			vector leftOffset = pos + projectile.GetRightVector() * FLAME_WALL_MAX_HEIGHT
			rowFxArray[1].SetOrigin( leftOffset )
		}
	}

	// radiusHeight = sqr( FLAME_WALL_MAX_HEIGHT^2 + PROJECTILE_SEPARATION^2 )
	RadiusDamage(
			pos,
			projectile.GetOwner(), //attacker
			inflictor, //inflictor
			projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value ),
			projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor ),
			180, // inner radius
			180, // outer radius
			SF_ENVEXPLOSION_NO_DAMAGEOWNER | SF_ENVEXPLOSION_MASK_BRUSHONLY | SF_ENVEXPLOSION_NO_NPC_SOUND_EVENT,
			0, // distanceFromAttacker
			0, // explosionForce
			flags,
			eDamageSourceId.mp_titancore_flame_wave )

	return true
}

void function FlameWave_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	vector damagePosition = DamageInfo_GetDamagePosition( damageInfo )
	vector entOrigin = ent.GetOrigin()
	vector entCenter = ent.GetWorldSpaceCenter()
	float originDistanceZ = entOrigin.z - damagePosition.z
	float centerDistanceZ = entCenter.z - damagePosition.z
	float originDistance2D = Distance2D( entOrigin, damagePosition )

	if ( originDistanceZ > FLAME_WALL_MAX_HEIGHT && centerDistanceZ > FLAME_WALL_MAX_HEIGHT )
		ZeroDamageAndClearInflictorArray( ent, damageInfo )
	//else if ( originDistance2D > PROJECTILE_SEPARATION / 2 )
	//	ZeroDamageAndClearInflictorArray( ent, damageInfo )

	//Needs a unique impact sound.
	if ( ent.IsPlayer() )
	{
	 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "Flesh.ThermiteBurn_3P_vs_1P" )
		EmitSoundOnEntityExceptToPlayer( ent, ent, "Flesh.ThermiteBurn_1P_vs_3P" )
	}
	else
	{
	 	EmitSoundOnEntity( ent, "Flesh.ThermiteBurn_1P_vs_3P" )
	}

	if ( DamageInfo_GetDamage( damageInfo ) > 0 )
	{
		if ( ent.IsTitan() )
			PlayFXOnEntity( FLAME_WAVE_IMPACT_TITAN, ent, "exp_torso_main" )
		else
			PlayFXOnEntity( FLAME_WAVE_IMPACT, ent )

		Scorch_SelfDamageReduction( ent, damageInfo )
	}

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) || attacker.GetTeam() == ent.GetTeam() )
		return

	array<entity> weapons = attacker.GetMainWeapons()
	if ( weapons.len() > 0 )
	{
		if ( weapons[0].HasMod( "fd_fire_damage_upgrade" )  )
			DamageInfo_ScaleDamage( damageInfo, FD_FIRE_DAMAGE_SCALE )
		if ( weapons[0].HasMod( "fd_hot_streak" ) )
			UpdateScorchHotStreakCoreMeter( attacker, DamageInfo_GetDamage( damageInfo ) )
	}
}

void function ZeroDamageAndClearInflictorArray( entity ent, var damageInfo )
{
		DamageInfo_SetDamage( damageInfo, 0 )

		//This only works because Flame Wave doesn't leave lingering effects.
		entity inflictor = DamageInfo_GetInflictor( damageInfo )
		if ( inflictor.e.damagedEntities.contains( ent ) )
			inflictor.e.damagedEntities.fastremovebyvalue( ent )
}
#endif








void function MpTitanWeaponGoundSlam_Init()
{
	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_ground_slam, GroundSlam_DamagedPlayerOrNPC )
	#endif
}

void function OnWeaponActivate_titancore_ground_slam( entity weapon )
{
    thread GroundSlamThink( weapon )
}

void function GroundSlamThink( entity weapon )
{
    entity owner = weapon.GetWeaponOwner()
    if( !owner.IsPlayer() )
        return

#if SERVER
    StopSoundOnEntity( weapon, "flamewave_start_1p" ) // client fix
    owner.EndSignal( "OnDeath" )
    owner.EndSignal( "OnDestroy" )
    owner.EndSignal( "TitanEjectionStarted" )

    owner.SetTitanDisembarkEnabled( false )
    //owner.SetPredictionEnabled( false )
    HolsterAndDisableWeapons( owner )
    StopSoundOnEntity( weapon, "flamewave_start_1p" ) // client fix
    array<entity> fx

	OnThreadEnd(
		function () : ( owner, fx )
		{
            if( IsValid( owner ) )
            {
                DeployAndEnableWeapons( owner )
                //owner.SetPredictionEnabled( true ) // defensive fix
            }
			foreach ( effect in fx )
			{
				if ( !IsValid( effect ) )
					continue

				effect.ClearParent()
				effect.Destroy()
			}
		}
	)

	fx.append( PlayFXOnEntity( $"P_xo_jet_fly_small", owner, "thrust" ) )
	fx.append( PlayFXOnEntity( $"P_xo_jet_fly_large", owner, "vent_left" ) )
	fx.append( PlayFXOnEntity( $"P_xo_jet_fly_large", owner, "vent_right" ) )

    PlayImpactFXTable( owner.GetOrigin(), owner, "droppod_impact" )
    EmitSoundOnEntityOnlyToPlayer( owner, owner, "titan_flight_liftoff_1p" )
    EmitSoundOnEntityExceptToPlayer( owner, owner, "titan_flight_liftoff_3p" )
    vector baseVelocity = owner.GetViewVector() * BERSERKER_DASH_VELOCITY
    baseVelocity.z = -750
    owner.SetVelocity( baseVelocity )
    //wait BERSERKER_DASH_TIME
    //owner.SetVelocity( < 0, 0, -170 > )
	owner.GetOffhandWeapon( OFFHAND_ORDNANCE ).SetWeaponPrimaryClipCount( owner.GetOffhandWeapon( OFFHAND_ORDNANCE ).GetWeaponPrimaryClipCountMax() )
    while( true )
    {
        WaitFrame()
        TraceResults traceresult = TraceLine( owner.GetOrigin(), owner.GetOrigin() - < 0, 0, 300 >, owner, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
        if( IsValid( traceresult.hitEnt ) )
            break
    }
    //mitSoundOnEntityOnlyToPlayer( owner, owner, "titan_flight_descent_1p" )
    //EmitSoundOnEntityExceptToPlayer( owner, owner, "titan_flight_descent_3p" )
    StopSoundOnEntity( weapon, "flamewave_start_1p" ) // client fix
    //weapon.EmitWeaponSound_1p3p( "flamewave_start_1p", "flamewave_start_3p" )
    owner.SetActiveWeaponByName( "mp_titancore_flame_wave" )
    //owner.SetPredictionEnabled( true )
	OnAbilityCharge_TitanCore( weapon )
#endif
}

bool function OnAbilityCharge_GoundSlam( entity weapon )
{
#if SERVER
    entity owner = weapon.GetWeaponOwner()
    float chargeTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
    entity soul = owner.GetTitanSoul()
    if ( soul == null )
        soul = owner
    StatusEffect_AddTimed( soul, eStatusEffect.damageAmpFXOnly, 1.0, chargeTime, 0 )
    StatusEffect_AddTimed( soul, eStatusEffect.damage_reduction, BERSERKER_INCOMING_DAMAGE_DAMPEN, chargeTime, 0 )
#endif

	return true
}

void function OnAbilityChargeEnd_GoundSlam( entity weapon )
{
	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		if ( owner.IsPlayer() )
			owner.SetTitanDisembarkEnabled( true )
		OnAbilityChargeEnd_TitanCore( weapon )
	#endif // #if SERVER
}

var function OnWeaponPrimaryAttack_titancore_ground_slam( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnAbilityStart_TitanCore( weapon )

	#if SERVER
    entity weaponOwner = weapon.GetWeaponOwner()
    entity groundEntity = weaponOwner.GetGroundEntity()
    vector damageOrigin = weaponOwner.GetOrigin()
	if ( groundEntity != null && groundEntity.HasPusherRootParent() )
        damageOrigin = groundEntity.GetOrigin()
    PlayImpactFXTable( damageOrigin, weaponOwner, "titan_exp_ground" )
    PlayFX( FLIGHT_CORE_IMPACT_FX, weaponOwner.GetOrigin() )
    PlayFX( TURBO_WARP_FX, damageOrigin, <0,90,0> )
    CreateShake( damageOrigin, 16, 150, 2, 1500 )
    CreatePhysExplosion( damageOrigin + < 0,0,10 >, 512, PHYS_EXPLOSION_LARGE, 15 )
    //PlayHotdropImpactFX( weaponOwner ) // this one also trigger a titanfall damagedef????
    EmitDifferentSoundsAtPositionForPlayerAndWorld( "core_ability_land_1p", "core_ability_land_3p", damageOrigin, weaponOwner, weaponOwner.GetTeam())
    for( int i = 0; i < 3; i ++ )
		EmitDifferentSoundsAtPositionForPlayerAndWorld( "Titan_1P_Warpfall_WarpToLanding_fast", "Titan_3P_Warpfall_WarpToLanding_fast", damageOrigin, weaponOwner, weaponOwner.GetTeam())
    RadiusDamage(
        damageOrigin + < 0,0,10 >,						    // center
        weaponOwner,		                                // attacker
        weaponOwner,									    // inflictor
        TITAN_GROUND_SLAM_DAMAGE,		                    // damage
        TITAN_GROUND_SLAM_DAMAGE_HEAVYARMOR,			    // damageHeavyArmor
        TITAN_GROUND_SLAM_INNER_RADIUS,		                // innerRadius
        TITAN_GROUND_SLAM_RADIUS,				            // outerRadius
        0,			                                        // flags
        0,										            // distanceFromAttacker
        30000,				                                // explosionForce
        DF_GIB | DF_BYPASS_SHIELD | DF_NO_SELF_DAMAGE,  // scriptDamageFlags
        eDamageSourceId.mp_ability_ground_slam )            //damageSourceID

	OnAbilityEnd_TitanCore( weapon )
	#endif

	return 1
}

#if SERVER
void function GroundSlam_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

    VanguardEnergySiphon_DamagedPlayerOrNPC( ent, damageInfo )
}
#endif