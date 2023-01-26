untyped
global function OnWeaponPrimaryAttack_titanweapon_salvo_rockets

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanweapon_salvo_rockets
#endif

global function OnProjectileCollision_titanweapon_mine_slavo

const SALVOROCKETS_MISSILE_SFX_LOOP			= "Weapon_Sidwinder_Projectile"
const SALVOROCKETS_NUM_ROCKETS_PER_SHOT 	= 1
const SALVOROCKETS_APPLY_RANDOM_SPREAD 		= true
const SALVOROCKETS_LAUNCH_OUT_ANG 			= 5
const SALVOROCKETS_LAUNCH_OUT_TIME 			= 0.20
const SALVOROCKETS_LAUNCH_IN_LERP_TIME 		= 0.2
const SALVOROCKETS_LAUNCH_IN_ANG 			= -10
const SALVOROCKETS_LAUNCH_IN_TIME 			= 0.10
const SALVOROCKETS_LAUNCH_STRAIGHT_LERP_TIME = 0.1
const SALVOROCKETS_DEBUG_DRAW_PATH 			= false

var function OnWeaponPrimaryAttack_titanweapon_salvo_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "tcp_mine" ) )
		return OnWeaponPrimaryAttack_titanweapon_mine_rockets( weapon, attackParams )
	bool shouldPredict = weapon.ShouldPredictProjectiles()

	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	entity player = weapon.GetWeaponOwner()

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	array<entity> firedMissiles = FireExpandContractMissiles( weapon, attackParams, attackParams.pos, attackParams.dir, damageTypes.projectileImpact, damageTypes.explosive, shouldPredict, SALVOROCKETS_NUM_ROCKETS_PER_SHOT, VANGUARD_SHOULDER_MISSILE_SPEED, SALVOROCKETS_LAUNCH_OUT_ANG, SALVOROCKETS_LAUNCH_OUT_TIME, SALVOROCKETS_LAUNCH_IN_ANG, SALVOROCKETS_LAUNCH_IN_TIME, SALVOROCKETS_LAUNCH_IN_LERP_TIME, SALVOROCKETS_LAUNCH_STRAIGHT_LERP_TIME, SALVOROCKETS_APPLY_RANDOM_SPREAD, -1, SALVOROCKETS_DEBUG_DRAW_PATH )
	foreach( missile in firedMissiles )
	{
		#if SERVER
			missile.SetOwner( player )
			EmitSoundOnEntity( missile, SALVOROCKETS_MISSILE_SFX_LOOP )
		#endif
		SetTeam( missile, player.GetTeam() )
	}

	if ( player.IsPlayer() )
		PlayerUsedOffhand( player, weapon )

	return firedMissiles.len() * weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


#if SERVER
var function OnWeaponNPCPrimaryAttack_titanweapon_salvo_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "tcp_mine" ) )
		return OnWeaponNPCPrimaryAttack_titanweapon_mine_rockets( weapon, attackParams )
	return OnWeaponPrimaryAttack_titanweapon_salvo_rockets( weapon, attackParams )
}
#endif

var function OnWeaponPrimaryAttack_titanweapon_mine_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	float velocity = TRIPLETHREAT_LAUNCH_VELOCITY * 1.2
	vector angularVelocity = Vector( RandomFloatRange( -velocity, velocity ), 100, 0 )

	FireTripleThreatGrenade( weapon, attackParams.pos, attackParams.dir * TRIPLETHREAT_LAUNCH_VELOCITY, angularVelocity, true, 30.0, damageTypes.explosive )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
var function OnWeaponNPCPrimaryAttack_titanweapon_mine_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	float velocity = TRIPLETHREAT_LAUNCH_VELOCITY * 1.2
	vector angularVelocity = Vector( RandomFloatRange( -velocity, velocity ), 100, 0 )

	FireTripleThreatGrenade( weapon, attackParams.pos, attackParams.dir * TRIPLETHREAT_LAUNCH_VELOCITY, angularVelocity, false, 30.0, damageTypes.explosive )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

function FireTripleThreatGrenade( entity weapon, origin, fwd, velocity, playerFired, float fuseTime, damageType = null )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( damageType == null )
		damageType = damageTypes.explosive

	entity nade = weapon.FireWeaponGrenade( origin, fwd, velocity, 0, damageType, damageType, playerFired, true, true )
	if ( nade )
	{
		//nade.InitMagnetic( 1000.0, "Explo_MGL_MagneticAttract" )
		nade.SetModel( $"models/weapons/titan_incendiary_trap/w_titan_incendiary_trap.mdl" )

		nade.kv.CollideWithOwner = false

		Grenade_Init( nade, weapon )
		#if SERVER
			nade.SetOwner( weaponOwner )
			thread EnableCollision( nade )
			thread AirPop( nade, fuseTime )
			thread TrapExplodeOnDamage( nade, 50, 0.0, 0.1 )

			nade.s.becomeProxMine <- true

		#else
			SetTeam( nade, weaponOwner.GetTeam() )
		#endif

		return nade
	}
}
function EnableCollision( entity grenade )
{
	grenade.EndSignal("OnDestroy")

	wait 1.0
	grenade.kv.CollideWithOwner = true
}
function AirPop( entity grenade, float fuseTime )
{
	grenade.EndSignal( "OnDestroy" )

	float popDelay = RandomFloatRange( 0.2, 0.3 )

	string waitSignal = "Planted" // Signal triggered when mine sticks to something
	local waitResult = WaitSignalTimeout( grenade, (fuseTime - (popDelay + 0.2)), waitSignal )

	// Only enter here if the mine stuck to something
	if ( waitResult != null && waitResult.signal == waitSignal )
	{
		fuseTime = 30
		waitSignal = "ProxMineTrigger"
		waitResult = WaitSignalTimeout( grenade, (fuseTime - (popDelay + 0.2)), waitSignal )

		// Mine was triggered via proximity
		if ( waitResult != null && waitResult.signal == waitSignal )
			EmitSoundOnEntity( grenade, "NPE_Missile_Alarm") // TEMP - Replace with a real sound
	}

	asset effect = $"wpn_grenade_TT_activate"
	if( "hasBurnMod" in grenade.s && grenade.s.hasBurnMod )
		effect = $"wpn_grenade_TT_activate"

	int fxId = GetParticleSystemIndex( effect )
	StartParticleEffectOnEntity( grenade, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	EmitSoundOnEntity( grenade, "Triple_Threat_Grenade_Charge" )

	float popSpeed = RandomFloatRange( 40.0, 64.0 )
	vector popVelocity = Vector ( 0, 0, popSpeed )
	vector normal = Vector( 0, 0, 1 )
	if( "becomeProxMine" in grenade.s && grenade.s.becomeProxMine == true )
	{
		//grenade.ClearParent()
		if( "collisionNormal" in grenade.s )
		{
			normal = expect vector( grenade.s.collisionNormal )
			popVelocity = expect vector( grenade.s.collisionNormal ) * popSpeed
		}
	}

	vector newPosition = grenade.GetOrigin() + popVelocity
	grenade.SetVelocity( GetVelocityForDestOverTime( grenade.GetOrigin(), newPosition, popDelay ) )

	wait popDelay
	TripleThreat_Explode( grenade )
}

function TripleThreat_Explode( entity grenade )
{
	vector normal = Vector( 0, 0, 1 )
	if( "collisionNormal" in grenade.s )
		normal = expect vector( grenade.s.collisionNormal )

	grenade.GrenadeExplode( normal )
}

void function OnProjectileCollision_titanweapon_mine_slavo( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if( !IsValid( hitEnt ) )
		return

	if( hitEnt.GetClassName() == "player" && !hitEnt.IsTitan() )
		return

	if( !IsValid( projectile ) )
		return

	if( "becomeProxMine" in projectile.s && projectile.s.becomeProxMine == true )
	{
		table collisionParams =
		{
			pos = pos,
			normal = normal,
			hitEnt = hitEnt,
			hitbox = hitbox
		}

		PlantStickyEntity( projectile, collisionParams )
		projectile.s.collisionNormal <- normal
		#if SERVER
			thread TripleThreatProximityTrigger( projectile )
		#endif
	}
}
function TripleThreatProximityTrigger( entity nade )
{
	//Hack, shouldn't be necessary with the IsValid check in OnProjectileCollision.
	if( !IsValid( nade ) )
		return

	nade.EndSignal( "OnDestroy" )
	EmitSoundOnEntity( nade, "Wpn_TripleThreat_Grenade_MineAttach" )

	wait TRIPLETHREAT_MINE_FIELD_ACTIVATION_TIME

	EmitSoundOnEntity( nade, "Weapon_Vortex_Gun.ExplosiveWarningBeep" )
	local rangeCheck = PROX_MINE_RANGE
	while( 1 )
	{
		local origin = nade.GetOrigin()
		int team = nade.GetTeam()

		local entityArray = GetScriptManagedEntArrayWithinCenter( level._proximityTargetArrayID, team, origin, PROX_MINE_RANGE )
		foreach( entity ent in entityArray )
		{
			if ( TRIPLETHREAT_MINE_FIELD_TITAN_ONLY )
				if ( !ent.IsTitan() )
					continue

			if ( IsAlive( ent ) )
			{
				nade.Signal( "ProxMineTrigger" )
				return
			}
		}
		WaitFrame()
	}
}
