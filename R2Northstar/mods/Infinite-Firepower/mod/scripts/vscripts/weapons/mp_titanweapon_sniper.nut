untyped


global function OnWeaponActivate_titanweapon_sniper
global function OnWeaponPrimaryAttack_titanweapon_sniper
global function OnWeaponChargeLevelIncreased_titanweapon_sniper
global function GetTitanSniperChargeLevel
global function MpTitanWeapon_SniperInit
global function OnWeaponStartZoomIn_titanweapon_sniper
global function OnWeaponStartZoomOut_titanweapon_sniper
global function OnWeaponOwnerChanged_titanweapon_sniper

//// arc cannon ////
global function OnWeaponActivate_titanweapon_arc_cannon
global function OnWeaponDeactivate_titanweapon_arc_cannon
global function OnWeaponReload_titanweapon_arc_cannon
global function OnWeaponOwnerChanged_titanweapon_arc_cannon
global function OnWeaponChargeBegin_titanweapon_arc_cannon
global function OnWeaponChargeEnd_titanweapon_arc_cannon
global function OnWeaponPrimaryAttack_titanweapon_arc_cannon

global function UpdateWeaponChargeTracker

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_arc_cannon
#endif // #if SERVER

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_sniper
#endif // #if SERVER

const INSTANT_SHOT_DAMAGE 				= 1200
//const INSTANT_SHOT_MAX_CHARGES		= 2 // can't change this without updating crosshair
//const INSTANT_SHOT_TIME_PER_CHARGE	= 0
const SNIPER_PROJECTILE_SPEED			= 10000

struct {
	float chargeDownSoundDuration = 1.0 //"charge_cooldown_time"
} file

void function OnWeaponActivate_titanweapon_sniper( entity weapon )
{
	if( weapon.HasMod( "arc_cannon" ) )
		OnWeaponActivate_titanweapon_arc_cannon( weapon )
	else
		file.chargeDownSoundDuration = expect float( weapon.GetWeaponInfoFileKeyField( "charge_cooldown_time" ) )
}

var function OnWeaponPrimaryAttack_titanweapon_sniper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "arc_cannon" ) )
		return OnWeaponPrimaryAttack_titanweapon_arc_cannon( weapon, attackParams )
	else
		return FireSniper( weapon, attackParams, true )
}

void function MpTitanWeapon_SniperInit()
{
	RegisterSignal( "OnWeaponPrimaryAttack_titanweapon_arc_cannon" )
	#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_sniper, OnHit_TitanWeaponSniper )
	#endif

	ArcCannon_PrecacheFX()

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_sniper, ArcCannonOnDamage )
	#endif
}
#if SERVER

void function OnHit_TitanWeaponSniper( entity victim, var damageInfo )
{
	OnHit_TitanWeaponSniper_Internal( victim, damageInfo )
}

void function OnHit_TitanWeaponSniper_Internal( entity victim, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return
	if ( !inflictor.IsProjectile() )
		return
	int extraDamage = int( CalculateTitanSniperExtraDamage( inflictor, victim ) )
	float damage = DamageInfo_GetDamage( damageInfo )

	float f_extraDamage = float( extraDamage )

	bool isCritical = IsCriticalHit( DamageInfo_GetAttacker( damageInfo ), victim, DamageInfo_GetHitBox( damageInfo ), damage, DamageInfo_GetDamageType( damageInfo ) )

	if ( isCritical )
	{
		array<string> projectileMods = inflictor.ProjectileGetMods()
		if ( projectileMods.contains( "fd_upgrade_crit" ) )
			f_extraDamage *= 2.0
		else
			f_extraDamage *= expect float( inflictor.ProjectileGetWeaponInfoFileKeyField( "critical_hit_damage_scale" ) )
	}

	//Check to see if damage has been see to zero so we don't override it.
	if ( damage > 0 && extraDamage > 0 )
	{
		damage += f_extraDamage
		DamageInfo_SetDamage( damageInfo, damage )
	}

	float nearRange = 1000
	float farRange = 1500
	float nearScale = 0.5
	float farScale = 0

	if ( victim.IsTitan() )
		PushEntWithDamageInfoAndDistanceScale( victim, damageInfo, nearRange, farRange, nearScale, farScale, 0.25 )
}

var function OnWeaponNpcPrimaryAttack_titanweapon_sniper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "arc_cannon" ) )
		return OnWeaponNpcPrimaryAttack_titanweapon_arc_cannon( weapon, attackParams )
	return FireSniper( weapon, attackParams, false )
}
#endif // #if SERVER


bool function OnWeaponChargeLevelIncreased_titanweapon_sniper( entity weapon )
{
	if( weapon.HasMod( "arc_cannon" ) )
		return false
	#if CLIENT
		if ( InPrediction() && !IsFirstTimePredicted() )
			return true
	#endif

	int level = weapon.GetWeaponChargeLevel()
	int maxLevel = weapon.GetWeaponChargeLevelMax()

	if ( level == maxLevel )
		weapon.EmitWeaponSound( "Weapon_Titan_Sniper_LevelTick_Final" )
	else
		weapon.EmitWeaponSound( "Weapon_Titan_Sniper_LevelTick_" + level )

	return true
}


function FireSniper( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	int chargeLevel = GetTitanSniperChargeLevel( weapon )
	entity weaponOwner = weapon.GetWeaponOwner()
	bool weaponHasInstantShotMod = weapon.HasMod( "instant_shot" )
	if ( chargeLevel == 0 )
		return 0

	//printt( "GetTitanSniperChargeLevel():", chargeLevel )

	if ( chargeLevel > 4 )
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Sniper_Level_4_1P", "Weapon_Titan_Sniper_Level_4_3P" )
	else if ( chargeLevel > 3 || weaponHasInstantShotMod )
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Sniper_Level_3_1P", "Weapon_Titan_Sniper_Level_3_3P" )
	else if ( chargeLevel > 2  )
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Sniper_Level_2_1P", "Weapon_Titan_Sniper_Level_2_3P" )
	else
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Sniper_Level_1_1P", "Weapon_Titan_Sniper_Level_1_3P" )

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 * chargeLevel )

	if ( chargeLevel > 5 )
	{
		weapon.SetAttackKickScale( 1.0 )
		weapon.SetAttackKickRollScale( 3.0 )
	}
	else if ( chargeLevel > 4 )
	{
		weapon.SetAttackKickScale( 0.75 )
		weapon.SetAttackKickRollScale( 2.5 )
	}
	else if ( chargeLevel > 3 )
	{
		weapon.SetAttackKickScale( 0.60 )
		weapon.SetAttackKickRollScale( 2.0 )
	}
	else if ( chargeLevel > 2 || weaponHasInstantShotMod )
	{
		weapon.SetAttackKickScale( 0.45 )
		weapon.SetAttackKickRollScale( 1.60 )
	}
	else if ( chargeLevel > 1 )
	{
		weapon.SetAttackKickScale( 0.30 )
		weapon.SetAttackKickRollScale( 1.35 )
	}
	else
	{
		weapon.SetAttackKickScale( 0.20 )
		weapon.SetAttackKickRollScale( 1.0 )
	}

	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	if ( !shouldCreateProjectile )
		return 1

	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, SNIPER_PROJECTILE_SPEED, DF_GIB | DF_BULLET | DF_ELECTRICAL, DF_EXPLOSION | DF_RAGDOLL, playerFired, 0 )
	if ( bolt )
	{
		bolt.kv.gravity = 0.001
		bolt.s.bulletsToFire <- chargeLevel

		bolt.s.extraDamagePerBullet <- weapon.GetWeaponSettingInt( eWeaponVar.damage_additional_bullets )
		bolt.s.extraDamagePerBullet_Titan <- weapon.GetWeaponSettingInt( eWeaponVar.damage_additional_bullets_titanarmor )
		if ( weaponHasInstantShotMod )
		{
			local damage_far_value_titanarmor = weapon.GetWeaponSettingInt( eWeaponVar.damage_far_value_titanarmor )
			Assert( INSTANT_SHOT_DAMAGE > damage_far_value_titanarmor )
			bolt.s.extraDamagePerBullet_Titan = INSTANT_SHOT_DAMAGE - damage_far_value_titanarmor
			bolt.s.bulletsToFire = 2
		}

		if ( chargeLevel > 4 )
			bolt.SetProjectilTrailEffectIndex( 2 )
		else if ( chargeLevel > 2 )
			bolt.SetProjectilTrailEffectIndex( 1 )

		#if SERVER
			Assert( weaponOwner == weapon.GetWeaponOwner() )
			bolt.SetOwner( weaponOwner )
		#endif
	}

	return 1
}

int function GetTitanSniperChargeLevel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return 0

	entity owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return 0

	if ( !owner.IsPlayer() )
		return 3

	if ( !weapon.IsReadyToFire() )
		return 0

	int charges = weapon.GetWeaponChargeLevel()
	return (1 + charges)
}

void function OnWeaponStartZoomIn_titanweapon_sniper( entity weapon )
{
	if( weapon.HasMod( "arc_cannon" ) )
	{
		weapon.s.InADS <- true
		return
	}
	#if SERVER
	if ( weapon.HasMod( "pas_northstar_optics" ) )
	{
		entity weaponOwner = weapon.GetWeaponOwner()
		if ( !IsValid( weaponOwner ) )
			return
		AddThreatScopeColorStatusEffect( weaponOwner )
	}
	#endif
}

void function OnWeaponStartZoomOut_titanweapon_sniper( entity weapon )
{
	if( weapon.HasMod( "arc_cannon" ) )
	{
		weapon.s.InADS <- false
		return
	}
	#if SERVER
	if ( weapon.HasMod( "pas_northstar_optics" ) )
	{
		entity weaponOwner = weapon.GetWeaponOwner()
		if ( !IsValid( weaponOwner ) )
			return
		RemoveThreatScopeColorStatusEffect( weaponOwner )
	}
	#endif
}

void function OnWeaponOwnerChanged_titanweapon_sniper( entity weapon, WeaponOwnerChangedParams changeParams )
{
	if( weapon.HasMod( "arc_cannon" ) )
		return OnWeaponOwnerChanged_titanweapon_arc_cannon( weapon, changeParams )
	else
	{
		#if SERVER
		if ( IsValid( changeParams.oldOwner ) && changeParams.oldOwner.IsPlayer() )
			RemoveThreatScopeColorStatusEffect( changeParams.oldOwner )
		#endif
	}
}


const FX_EMP_BODY_HUMAN			= $"P_emp_body_human"
const FX_EMP_BODY_TITAN			= $"P_emp_body_titan"

const BASE_ENERGY_GAIN = 25
const CRIT_COUNT_MULTIPLIER_ENERGY_GAIN = 5
const BONUS_ENERGY_GAIN = 75
#if SERVER
struct{
	int critShots = 0
	bool isCharging = false
	float weaponCharge = 0.0

}weaponData
#endif

void function UpdateWeaponChargeTracker(entity weapon)
{
#if SERVER
	wait 0.01

	entity player = weapon.GetWeaponOwner()

	while(weaponData.isCharging == true)
	{
		WaitFrame()

		if(IsAlive(player))
		{
			float chargeFrac = player.GetActiveWeapon().GetWeaponChargeFraction()

			//print(mainWeapon.GetWeaponChargeFraction())

			if(chargeFrac > 0)
			{
				weaponData.weaponCharge = chargeFrac
			}
			else
				weaponData.isCharging = false
		}

	}
	#endif
}


void function OnWeaponActivate_titanweapon_arc_cannon( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	thread DelayedArcCannonStart( weapon, weaponOwner )
	if( !("weaponOwner" in weapon.s) )
		weapon.s.weaponOwner <- weaponOwner
}

function DelayedArcCannonStart( entity weapon, entity weaponOwner )
{
	weapon.EndSignal( "WeaponDeactivateEvent" )

	WaitFrame()

	if ( IsValid( weapon ) && IsValid( weaponOwner ) && weapon == weaponOwner.GetActiveWeapon() )
	{
		if( weaponOwner.IsPlayer() )
		{
			entity modelEnt = weaponOwner.GetViewModelEntity()
	 		if( IsValid( modelEnt ) && EntHasModelSet( modelEnt ) )
				ArcCannon_Start( weapon )
		}
		else
		{
			ArcCannon_Start( weapon )
		}
	}
}

void function OnWeaponDeactivate_titanweapon_arc_cannon( entity weapon )
{
	if( !weapon.HasMod( "arc_cannon" ) )
		return
	ArcCannon_ChargeEnd( weapon, weapon.GetOwner() )
	ArcCannon_Stop( weapon )
}

void function OnWeaponReload_titanweapon_arc_cannon( entity weapon, int milestoneIndex )
{
	if( !weapon.HasMod( "arc_cannon" ) )
		return
	local reloadTime = weapon.GetWeaponInfoFileKeyField( "reload_time" )
	thread ArcCannon_HideIdleEffect( weapon, reloadTime ) //constant seems to help it sync up better
}

void function OnWeaponOwnerChanged_titanweapon_arc_cannon( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if CLIENT
		entity viewPlayer = GetLocalViewPlayer()
		if ( changeParams.oldOwner != null && changeParams.oldOwner == viewPlayer )
		{
			ArcCannon_ChargeEnd( weapon, changeParams.oldOwner )
			ArcCannon_Stop( weapon)
		}

		if ( changeParams.newOwner != null && changeParams.newOwner == viewPlayer )
			thread ArcCannon_HideIdleEffect( weapon, 0.25 )
	#else
		if ( changeParams.oldOwner != null )
		{
			ArcCannon_ChargeEnd( weapon, changeParams.oldOwner )
			ArcCannon_Stop( weapon )
		}

		if ( changeParams.newOwner != null )
			thread ArcCannon_HideIdleEffect( weapon, 0.25 )
	#endif
}

bool function OnWeaponChargeBegin_titanweapon_arc_cannon( entity weapon )
{
	if( weapon.HasMod( "arc_cannon" ) )
	{
		if( !( "InADS" in weapon.s ) )
			return true
		if( !weapon.s.InADS )
			return true

		local stub = "this is here to suppress the untyped message.  This can go away when the .s. usage is removed from this file."
		#if SERVER
		//if ( weapon.HasMod( "fastpacitor_push_apart" ) )
		//	weapon.GetWeaponOwner().StunMovementBegin( weapon.GetWeaponSettingFloat( eWeaponVar.charge_time ) )
		#endif
		#if SERVER
		weaponData.isCharging = true
		#endif
		//thread UpdateWeaponChargeTracker( weapon )

		thread StopWeaponSniperSound( weapon )

		ArcCannon_ChargeBegin( weapon )
	}

	return true
}

void function StopWeaponSniperSound( entity weapon )
{
	weapon.EndSignal( "OnWeaponPrimaryAttack_titanweapon_arc_cannon" )
	for( int i = 400; i > 0; i-- )
	{
		printt( "TryStopWeaponSniperSound" )
		WaitFrame()
		entity owner = weapon.GetWeaponOwner()
		entity soul = owner.GetTitanSoul()
		if( IsValid( weapon ) )
		{
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_1p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_1p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_3p_enemy_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_3p_enemy_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_3p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_1_3p_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_1p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_1p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_3p_enemy_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_3p_enemy_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_3p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_2_3p_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_1p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_1p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_3p_enemy_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_3p_enemy_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_3p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_3_3p_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_1p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_1p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_3p_enemy_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_3p_enemy_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_3p_int" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_level_4_3p_OLD" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_1" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_2" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_3" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_4" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_5" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_6" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_leveltick_final" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_sustainloop" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_sustainloop_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_sustainloop_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_winddown" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_winddown_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_winddown_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_windup" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_windup_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_windup_3p_enemy" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_windup_amped" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_windup_amped_3p" )
			StopSoundOnEntity( weapon, "weapon_titan_sniper_windup_amped_3p_enemy" )
		}
		if( IsValid( owner ) )
		{
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_1p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_1p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_3p_enemy_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_3p_enemy_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_3p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_1_3p_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_1p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_1p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_3p_enemy_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_3p_enemy_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_3p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_2_3p_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_1p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_1p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_3p_enemy_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_3p_enemy_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_3p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_3_3p_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_1p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_1p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_3p_enemy_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_3p_enemy_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_3p_int" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_level_4_3p_OLD" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_1" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_2" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_3" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_4" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_5" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_6" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_leveltick_final" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_sustainloop" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_sustainloop_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_sustainloop_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_winddown" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_winddown_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_winddown_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_windup" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_windup_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_windup_3p_enemy" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_windup_amped" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_windup_amped_3p" )
			StopSoundOnEntity( owner, "weapon_titan_sniper_windup_amped_3p_enemy" )
		}
		if( IsValid( soul ) )
		{
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_1p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_1p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_3p_enemy_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_3p_enemy_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_3p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_1_3p_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_1p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_1p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_3p_enemy_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_3p_enemy_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_3p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_2_3p_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_1p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_1p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_3p_enemy_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_3p_enemy_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_3p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_3_3p_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_1p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_1p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_3p_enemy_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_3p_enemy_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_3p_int" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_level_4_3p_OLD" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_1" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_2" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_3" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_4" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_5" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_6" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_leveltick_final" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_sustainloop" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_sustainloop_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_sustainloop_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_winddown" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_winddown_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_winddown_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_windup" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_windup_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_windup_3p_enemy" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_windup_amped" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_windup_amped_3p" )
			StopSoundOnEntity( soul, "weapon_titan_sniper_windup_amped_3p_enemy" )
		}
	}
}


void function OnWeaponChargeEnd_titanweapon_arc_cannon( entity weapon )
{
	if( weapon.HasMod( "arc_cannon" ) )
	{
		#if SERVER
		weaponData.isCharging = false
		#endif
		ArcCannon_ChargeEnd( weapon, weapon )
	}
}

var function OnWeaponPrimaryAttack_titanweapon_arc_cannon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.Signal( "OnWeaponPrimaryAttack_titanweapon_arc_cannon" )

	if ( weapon.HasMod( "capacitor" ) && weapon.GetWeaponChargeFraction() < GetArcCannonChargeFraction( weapon ) )
		return 0

	if ( !attackParams.firstTimePredicted )
		return

	local fireRate = weapon.GetWeaponInfoFileKeyField( "fire_rate" )
	thread ArcCannon_HideIdleEffect( weapon, (1 / fireRate) )
	int damageFlags = weapon.GetWeaponDamageFlags()

	return FireArcCannon( weapon, attackParams )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_arc_cannon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	local fireRate = weapon.GetWeaponInfoFileKeyField( "fire_rate" )
	thread ArcCannon_HideIdleEffect( weapon, fireRate )

	return FireArcCannon( weapon, attackParams )
}
#endif // #if SERVER


void function ArcCannonOnDamage( entity ent, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return
	if( inflictor.IsProjectile() )
		return

	vector pos = DamageInfo_GetDamagePosition( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	entity weapon = DamageInfo_GetWeapon( damageInfo )
	if( !IsValid( weapon ) )
		return
	if( !weapon.HasMod( "arc_cannon" ) )
		return

	float damageMultiplier = DamageInfo_GetDamage( damageInfo ) / weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )

	if ( ent.IsPlayer() || ent.IsNPC() )
	{
		entity entToSlow = ent
		entity soul = ent.GetTitanSoul()

		if ( soul != null )
			entToSlow = soul
		//StatusEffect_AddTimed( entToSlow, eStatusEffect.move_slow, 0.5, 1.0*damageMultiplier, 1.0 )
		//StatusEffect_AddTimed( entToSlow, eStatusEffect.dodge_speed_slow, 0.5, 2.0*damageMultiplier, 1.0 )

		const ARC_TITAN_EMP_DURATION			= 0.35
		const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

		StatusEffect_AddTimed( ent, eStatusEffect.emp, 0.2*damageMultiplier, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )

		entity offhandWeaponRI = attacker.GetOffhandWeapon( OFFHAND_RIGHT )
		entity offhandWeaponAR = attacker.GetOffhandWeapon( OFFHAND_ANTIRODEO )
		entity offhandWeaponSP = attacker.GetOffhandWeapon( OFFHAND_SPECIAL )


		if(weapon.HasMod("generator_mod"))
		{
			//Charge Ball Recharge
			if ( offhandWeaponRI.GetWeaponPrimaryClipCount() + 6 * damageMultiplier > 120 )
			{
				offhandWeaponRI.SetWeaponPrimaryClipCount( 120 )
			}
			else
			{
				offhandWeaponRI.SetWeaponPrimaryClipCount( offhandWeaponRI.GetWeaponPrimaryClipCount() + 6 * damageMultiplier)
			}

			//Tesla Node Recharge
			if ( offhandWeaponAR.GetWeaponPrimaryClipCount() + 12 * damageMultiplier > 200 )
			{
				offhandWeaponAR.SetWeaponPrimaryClipCount( 200 )
			}
			else if( offhandWeaponAR.HasMod( "dual_nodes" ) )
			{
				offhandWeaponAR.SetWeaponPrimaryClipCount( offhandWeaponAR.GetWeaponPrimaryClipCount() + 6 * damageMultiplier )
			}
			else
			{
				offhandWeaponAR.SetWeaponPrimaryClipCount( offhandWeaponAR.GetWeaponPrimaryClipCount() + 12 * damageMultiplier)
			}

			//Shock Shield Recharge
			if ( offhandWeaponSP.GetWeaponChargeFraction() - 0.05 * damageMultiplier < 0 )
			{
				//offhandWeaponSP.SetWeaponPrimaryClipCount( 100 )
				offhandWeaponSP.SetWeaponChargeFraction(0)
			}
			else
			{
				//offhandWeaponSP.SetWeaponPrimaryClipCount( offhandWeaponSP.GetWeaponPrimaryClipCount() + 0.2)
				offhandWeaponSP.SetWeaponChargeFraction(offhandWeaponSP.GetWeaponChargeFraction() - 0.05 * damageMultiplier)

			}
		}



	}


	#if SERVER
	string tag = ""
	asset effect

	if ( ent.IsTitan() )
	{
		tag = "exp_torso_front"
		effect = FX_EMP_BODY_TITAN
	}
	else if ( ChestFocusTarget( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = FX_EMP_BODY_HUMAN
	}
	else if ( IsAirDrone( ent ) )
	{
		tag = "HEADSHOT"
		effect = FX_EMP_BODY_HUMAN
	}
	else if ( IsGunship( ent ) )
	{
		tag = "ORIGIN"
		effect = FX_EMP_BODY_TITAN
	}

	if ( tag != "" )
	{
		float duration = 2.0
		//thread EMP_FX( effect, ent, tag, duration )
	}

	if ( ent.IsTitan() )
	{
		if ( ent.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "titan_energy_bulletimpact_3p_vs_1p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "titan_energy_bulletimpact_3p_vs_3p" )
		}
		else
		{
		 	EmitSoundOnEntity( ent, "titan_energy_bulletimpact_3p_vs_3p" )
		}
	}
	else
	{
		if ( ent.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "flesh_lavafog_deathzap_3p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "flesh_lavafog_deathzap_1p" )
		}
		else
		{
		 	EmitSoundOnEntity( ent, "flesh_lavafog_deathzap_1p" )
		}
	}
	#endif

}
#if SERVER
bool function ChestFocusTarget( entity ent )
{
	if ( IsSpectre( ent ) )
		return true
	if ( IsStalker( ent ) )
		return true
	if ( IsSuperSpectre( ent ) )
		return true
	if ( IsGrunt( ent ) )
		return true
	if ( IsPilot( ent ) )
		return true

	return false
}
#endif // #if SERVER