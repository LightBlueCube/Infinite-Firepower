#if SERVER
untyped
#endif

global function MpWeaponDeployableCloakfield_Init

global function OnWeaponTossReleaseAnimEvent_weapon_deployable_cloakfield

#if SERVER
global function DeployCloakfield
#endif

const DEPLOYABLE_CLOAKFIELD_DURATION = 25

const DEPLOYABLE_CLOAKFIELD_MODEL = $"models/lamps/exterior_walkway_light.mdl"
const DEPLOYABLE_CLOAKFIELD_FX_ALL = $"harvester_base_noise"
const DEPLOYABLE_CLOAKFIELD_FX_ALL2 = $"harvester_base_glowflat"
const DEPLOYABLE_CLOAKFIELD_FX_TEAM = $"ar_operator_target_idle"
const DEPLOYABLE_CLOAKFIELD_HEALTH = 300
const DEPLOYABLE_CLOAKFIELD_RADIUS = 500

void function MpWeaponDeployableCloakfield_Init()
{
	PrecacheModel( DEPLOYABLE_CLOAKFIELD_MODEL )
	PrecacheParticleSystem( DEPLOYABLE_CLOAKFIELD_FX_TEAM )
	PrecacheParticleSystem( DEPLOYABLE_CLOAKFIELD_FX_ALL )
	PrecacheParticleSystem( DEPLOYABLE_CLOAKFIELD_FX_ALL2 )
}

var function OnWeaponTossReleaseAnimEvent_weapon_deployable_cloakfield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity deployable = ThrowDeployable( weapon, attackParams, DEPLOYABLE_THROW_POWER, OnDeployableCloakfieldPlanted )
	PlayerUsedOffhand( weapon.GetWeaponOwner(), weapon )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnDeployableCloakfieldPlanted( entity projectile )
{
	#if SERVER
		DeployCloakfield( projectile )
	#endif
}

#if SERVER
void function DeployCloakfield( entity projectile )
{
	vector origin = projectile.GetOrigin()
	vector angles = projectile.proj.savedAngles
	entity owner = projectile.GetOwner()

	wait 0.25

	thread CreateCloakBeacon( owner, origin, angles )
	if( IsValid( projectile ) )
		projectile.GrenadeExplode( Vector(0, 0, 1) )
}

void function CreateCloakBeacon( entity owner, vector origin, vector angles )
{
	entity tower = CreatePropScript( DEPLOYABLE_CLOAKFIELD_MODEL, origin, angles, 2 )
	// tower.EnableAttackableByAI( 10, 0, AI_AP_FLAG_NONE )
	SetTeam( tower, owner.GetTeam() )
	tower.SetMaxHealth( DEPLOYABLE_CLOAKFIELD_HEALTH )
	tower.SetHealth( DEPLOYABLE_CLOAKFIELD_HEALTH )
	tower.SetTakeDamageType( DAMAGE_YES )
	tower.SetDamageNotifications( true )
	tower.SetDeathNotifications( true )
	SetVisibleEntitiesInConeQueriableEnabled( tower, true )//for arc cannon and emp titan
	SetObjectCanBeMeleed( tower, true )
	//temp fix
	AddEntityCallback_OnDamaged(tower, OnBeaconDamaged)

	OnThreadEnd(
		function() : ( tower )
		{
			tower.Destroy()
		}
	)

	tower.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "OnDestroy" )
	EmitSoundOnEntity( tower, CLOAKED_DRONE_WARP_IN_SFX )

	wait 0.5

	EmitSoundOnEntity( tower, CLOAKED_DRONE_LOOPING_SFX )
	thread CloakBeaconThink( tower )

	wait DEPLOYABLE_CLOAKFIELD_DURATION
}

void function CloakBeaconThink( entity tower )
{
	tower.EndSignal( "OnDestroy" )

	float radius = DEPLOYABLE_CLOAKFIELD_RADIUS

	array<entity> fx = []
	array<entity> cp = []

	entity cpRadius = CreateEntity( "info_placement_helper" )
	SetTargetName( cpRadius, UniqueString( "cloakBeacon_cpRadius" ) )
	cpRadius.SetOrigin( Vector(100,0,0) )
	DispatchSpawn( cpRadius )
	cp.append( cpRadius )

	// friendly fx
	entity cpColorF = CreateEntity( "info_placement_helper" )
	SetTargetName( cpColorF, UniqueString( "cloakBeacon_cpColorF" ) )
	cpColorF.SetOrigin( < 115, 174, 255 > )
	DispatchSpawn( cpColorF )
	cp.append( cpColorF )

	entity fxIdF1 = PlayFXWithControlPoint( DEPLOYABLE_CLOAKFIELD_FX_ALL, tower.GetOrigin() + Vector(0,0,3), cpColorF )
	SetTeam( fxIdF1, tower.GetTeam() )
	fxIdF1.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	fx.append( fxIdF1 )
	entity fxIdF2 = PlayFXWithControlPoint( DEPLOYABLE_CLOAKFIELD_FX_ALL2, tower.GetOrigin() + Vector(0,0,3), cpColorF )
	SetTeam( fxIdF2, tower.GetTeam() )
	fxIdF2.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	fx.append( fxIdF2 )

	entity fxIdF3 = CreateEntity( "info_particle_system" )
	fxIdF3.kv.start_active = 1
	fxIdF3.SetValueForEffectNameKey( DEPLOYABLE_CLOAKFIELD_FX_TEAM )
	SetTeam( fxIdF3, tower.GetTeam() )
	fxIdF3.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	SetTargetName( fxIdF3, UniqueString() )
	fxIdF3.kv.cpoint1 = cpColorF.GetTargetName()
	fxIdF3.kv.cpoint5 = cpRadius.GetTargetName()
	fxIdF3.SetOrigin( tower.GetOrigin() + Vector(0,0,3) )
	fx.append( fxIdF3 )

	// enemy fx
	entity cpColorE = CreateEntity( "info_placement_helper" )
	SetTargetName( cpColorE, UniqueString( "cloakBeacon_cpColorE" ) )
	cpColorE.SetOrigin( ENEMY_COLOR_FX )
	DispatchSpawn( cpColorE )
	cp.append( cpColorE )

	entity fxIdE1 = PlayFXWithControlPoint( DEPLOYABLE_CLOAKFIELD_FX_ALL, tower.GetOrigin() + Vector(0,0,3), cpColorE )
	SetTeam( fxIdE1, tower.GetTeam() )
	fxIdE1.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	fx.append( fxIdE1 )
	entity fxIdE2 = PlayFXWithControlPoint( DEPLOYABLE_CLOAKFIELD_FX_ALL2, tower.GetOrigin() + Vector(0,0,3), cpColorE )
	SetTeam( fxIdE2, tower.GetTeam() )
	fxIdE2.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	fx.append( fxIdE2 )

	entity fxIdE3 = CreateEntity( "info_particle_system" )
	fxIdE3.kv.start_active = 1
	fxIdE3.SetValueForEffectNameKey( DEPLOYABLE_CLOAKFIELD_FX_TEAM )
	SetTeam( fxIdE3, tower.GetTeam() )
	fxIdE3.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	SetTargetName( fxIdE3, UniqueString() )
	fxIdE3.kv.cpoint1 = cpColorE.GetTargetName()
	fxIdE3.kv.cpoint5 = cpRadius.GetTargetName()
	fxIdE3.SetOrigin( tower.GetOrigin() + Vector(0,0,3) )
	fx.append( fxIdE3 )

	OnThreadEnd(
		function() : ( tower, fx, cp )
		{
			StopSoundOnEntity( tower, CLOAKED_DRONE_LOOPING_SFX )
			PlayImpactFXTable( tower.GetOrigin(), tower, "exp_deployable_cover" )
			foreach ( fxId in fx )
			{
				if ( IsValid( fxId ) )
					fxId.Destroy()
			}
			foreach( controlPoint in cp )
			{
				if( IsValid( controlPoint ) )
					controlPoint.Destroy()
			}
		}
	)

	wait 0.25

	DispatchSpawn( fxIdF3 )
	DispatchSpawn( fxIdE3 )
	thread FriendlyColorUpdate( cpColorF )
	CloakFlieldThink( tower, radius, [ "players", "npc_soldier", "npc_spectre" ], Vector(0, 0, 40), CloakBeaconShouldCloakGuy )
}

void function FriendlyColorUpdate( entity cpColorF )
{
	cpColorF.EndSignal( "OnDestroy" )
	float duration = float( DEPLOYABLE_CLOAKFIELD_DURATION ) - 0.25
	for( ;; )
	{
		WaitFrame()
		duration -= 0.1
		cpColorF.SetOrigin( GetVortexSphereCurrentColor( GraphCapped( duration, DEPLOYABLE_CLOAKFIELD_DURATION, 0, 0, 1 ), < 115, 174, 255 > ) )
	}
}

void function OnBeaconDamaged(entity tower, var damageInfo)
{
	if( !IsValid( tower ) )
		return
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if( DamageInfo_GetCustomDamageType( damageInfo ) & ( DF_MELEE | DF_TITAN_STEP ) )
		DamageInfo_SetDamage( damageInfo, tower.GetHealth() )
    if ( attacker.IsPlayer() )
        attacker.NotifyDidDamage( tower, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
}

function CloakBeaconShouldCloakGuy( beacon, guy )
{
	expect entity( guy )

	if ( !IsHumanSized( guy ) )
		return false

	if ( IsTurret( guy ) )
		return false

	return true
}
#endif

function CloakFlieldThink( entity cloaker, float radius, array<string> ents = [ "any" ], vector offset = Vector(0,0,0), var shouldCloakGuyFunc = null, float waitTime = 0.25 )
{
	OnThreadEnd(
		function() : ( cloaker )
		{
			local cloakList = clone cloaker.s.cloakList
			foreach ( entity guy, value in cloakList )
			{
				CloakFlieldCloakerDeCloaksGuy( guy )
			}
		}
	)

	cloaker.s.cloakList <- {}
	cloaker.s.decloakList <- {}

	while( 1 )
	{
		vector origin = cloaker.GetOrigin() + offset
		array<entity> guys

		foreach ( entType in ents )
		{
			switch ( entType )
			{
				case "player":
				case "players":
					guys.extend( GetPlayerArrayEx( "any", cloaker.GetTeam(), TEAM_ANY, origin, radius ) )
					break;
				default:
					guys.extend( GetNPCArrayEx( entType, cloaker.GetTeam(), TEAM_ANY, origin, radius ) )
					break
			}
		}
		int index = 0

		float startTime = Time()

		table cloakList = expect table( cloaker.s.cloakList )
		cloaker.s.decloakList = clone cloakList

		foreach ( guy in guys )
		{
			//only do 5 distanceSqr / cansee checks per frame
			if ( index++ > 5 )
			{
				wait 0.1
				index = 0
				origin = cloaker.GetOrigin() + offset
			}

			bool shouldCloakGuy = CloakerShouldCloakGuy( cloaker, guy )

			if ( shouldCloakGuy )
				shouldCloakGuy = expect bool( shouldCloakGuyFunc( cloaker, guy ) )

			if ( shouldCloakGuy )
			{
				if ( guy in cloaker.s.decloakList )
					delete cloaker.s.decloakList[ guy ]

				if ( IsCloaked( guy ) )
					continue

				cloakList[ guy ] <- true
				CloakFlieldCloakerCloaksGuy( guy )
			}
		}

		foreach ( entity guy, value in cloaker.s.decloakList )
		{
			// any guys still in the decloakList shouldn't be decloaked ... if alive.
			Assert( guy in cloakList )
			delete cloakList[ guy ]

			if ( IsAlive( guy ) )
				CloakFlieldCloakerDeCloaksGuy( guy )
		}

		float endTime = Time()
		float elapsedTime = endTime - startTime
		if ( elapsedTime < waitTime )
			wait waitTime - elapsedTime
	}
}

void function CloakFlieldCloakerCloaksGuy( guy )
{
	guy.SetCloakDuration( 2.0, -1, 0 )
	EmitSoundOnEntity( guy, CLOAKED_DRONE_CLOAK_START_SFX )
	guy.Minimap_Hide( TEAM_IMC, null )
	guy.Minimap_Hide( TEAM_MILITIA, null )
}

void function CloakFlieldCloakerDeCloaksGuy( guy )
{
	guy.SetCloakDuration( 0, 0, 2.0 )
	EmitSoundOnEntity( guy, CLOAKED_DRONE_WARP_OUT_SFX )
	guy.Minimap_AlwaysShow( TEAM_IMC, null )
	guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
}