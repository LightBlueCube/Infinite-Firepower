global function AmpCore_Init
global function OnWeaponPrimaryAttack_AmpCore
global function OnWeaponActivate_AmpCore
global function OnWeaponDeactivate_AmpCore
global function OnWeaponChargeBegin_AmpCore
global function OnWeaponChargeEnd_AmpCore

#if SERVER
global function OnWeaponNPCPrimaryAttack_AmpCore
#endif

const FX_AMPED_XO16_3P = $"P_wpn_lasercannon_aim"
const FX_AMPED_XO16 = $"P_wpn_lasercannon_aim"


void function AmpCore_Init()
{
	PrecacheParticleSystem( FX_AMPED_XO16_3P )
	PrecacheParticleSystem( FX_AMPED_XO16 )
}

bool function OnWeaponChargeBegin_AmpCore( entity weapon )
{
	if( weapon.HasMod( "damage_core" ) )
		return OnCoreCharge_Damage_Core( weapon )
	return true
}

void function OnWeaponChargeEnd_AmpCore( entity weapon )
{
	if( weapon.HasMod( "damage_core" ) )
		return OnCoreChargeEnd_Damage_Core( weapon )
	weapon.PlayWeaponEffect( FX_AMPED_XO16, FX_AMPED_XO16_3P, "fx_laser" )
}

void function OnWeaponActivate_AmpCore( entity weapon )
{
	if( weapon.HasMod( "damage_core" ) )
		return
	OnAbilityCharge_TitanCore( weapon )

	weapon.EmitWeaponSound_1p3p( "Weapon_Predator_MotorLoop_1P", "Weapon_Predator_MotorLoop_3P" )
	weapon.EmitWeaponSound_1p3p( "Weapon_Predator_Windup_1P", "Weapon_Predator_Windup_3P" )

	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		entity soul = owner.GetTitanSoul()

		float stunDuration = weapon.GetCoreDuration()
		stunDuration += expect float( weapon.GetWeaponInfoFileKeyField( "chargeup_time" ) )
		float fadetime = 0.5
		weapon.w.statusEffects = [] // clear it out
		weapon.w.statusEffects.append( StatusEffect_AddTimed( soul, eStatusEffect.turn_slow, 0.25, stunDuration + fadetime, fadetime ) )
		weapon.w.statusEffects.append( StatusEffect_AddTimed( soul, eStatusEffect.move_slow, 0.4, stunDuration + fadetime, fadetime ) )
	#endif
}

void function OnWeaponDeactivate_AmpCore( entity weapon )
{
	if( weapon.HasMod( "damage_core" ) )
		return
	#if SERVER
	OnAbilityChargeEnd_TitanCore( weapon )
	if ( weapon.w.initialized )
	{
		weapon.w.initialized = false
		OnAbilityEnd_TitanCore( weapon )
		entity owner = weapon.GetWeaponOwner()
		if ( IsValid( owner ) && HasSoul( owner ) )
		{
			entity soul = owner.GetTitanSoul()
			foreach ( effect in weapon.w.statusEffects )
			{
				StatusEffect_Stop( soul, effect )
			}
		}

		weapon.w.statusEffects = [] // clear it out
	}
	#endif

	weapon.StopWeaponSound( "Weapon_Predator_MotorLoop_1P" )
	weapon.StopWeaponSound( "Weapon_Predator_MotorLoop_3P" )
	weapon.StopWeaponSound( "Weapon_Predator_Windup_1P" )
	weapon.StopWeaponSound( "Weapon_Predator_Windup_3P" )
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_AmpCore( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnWeaponPrimaryAttack_AmpCore( weapon, attackParams )
}
#endif

var function OnWeaponPrimaryAttack_AmpCore( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "damage_core" ) )
		return OnAbilityStart_Damage_Core( weapon, attackParams )
	entity owner = weapon.GetWeaponOwner()
	entity soul = owner.GetTitanSoul()

	if ( attackParams.burstIndex == 0 )
	{
		#if SERVER
			weapon.w.initialized = true
		#endif
		OnAbilityStart_TitanCore( weapon )
	}

#if SERVER
	if ( soul != null )
		CleanupCoreEffect( soul )
#endif

weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.largeCaliber | DF_STOPS_TITAN_REGEN )

if ( attackParams.burstIndex == 99 )
{
		weapon.StopWeaponEffect( FX_AMPED_XO16, FX_AMPED_XO16_3P )
		#if SERVER
			weapon.w.initialized = false
			OnAbilityEnd_TitanCore( weapon )
		#endif

		if( IsValid( soul ) )
			foreach ( effect in weapon.w.statusEffects )
				StatusEffect_Stop( soul, effect )
	}

	return 1
}

bool function OnCoreCharge_Damage_Core( entity weapon )
{
	if ( !OnAbilityCharge_TitanCore( weapon ) )
		return false

	return true
}

void function OnCoreChargeEnd_Damage_Core( entity weapon )
{
#if SERVER
	OnAbilityChargeEnd_TitanCore( weapon )
#endif
}

var function OnAbilityStart_Damage_Core( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	if ( !owner.IsTitan() )
		return 0
	entity soul = owner.GetTitanSoul()
	#if SERVER
	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
	thread DamageCoreThink( weapon, duration )

	OnAbilityStart_TitanCore( weapon )
	#endif

	return 1
}

void function DamageCoreThink( entity weapon, float coreDuration )
{
	#if SERVER
	weapon.EndSignal( "OnDestroy" )
	entity owner = weapon.GetWeaponOwner()
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "DisembarkingTitan" )
	owner.EndSignal( "TitanEjectionStarted" )

	if( !owner.IsTitan() )
		return

	if ( owner.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Legion_Smart_Core_Activated_1P" )
		EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Legion_Smart_Core_ActiveLoop_1P" )
		EmitSoundOnEntityExceptToPlayer( owner, owner, "Titan_Legion_Smart_Core_Activated_3P" )
	}
	else // npc
		EmitSoundOnEntity( owner, "Titan_Legion_Smart_Core_Activated_3P" )

	entity soul = owner.GetTitanSoul()
	int statusEffect = StatusEffect_AddEndless( soul, eStatusEffect.titan_damage_amp, 0.4 )
	if ( owner.IsPlayer() )
	{
		ScreenFade( owner, 100, 0, 0, 10, 0.1, coreDuration, FFADE_OUT | FFADE_PURGE )
		GivePassive( owner, ePassives.PAS_FUSION_CORE )
	}

	if( owner.GetMainWeapons().len() != 0 )
	{
		entity weapon = owner.GetMainWeapons()[0]
		foreach( mod in GetWeaponBurnMods( weapon.GetWeaponClassName() ) )
		{
			weapon.AddMod( mod )
		}
	}

	OnThreadEnd(
	function() : ( weapon, soul, owner, statusEffect )
		{
			if ( IsValid( owner ) )
			{
				StopSoundOnEntity( owner, "Titan_Legion_Smart_Core_ActiveLoop_1P" )

				if ( owner.IsPlayer() )
				{
					EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Legion_Smart_Core_Deactivated_1P" )
					ScreenFade( owner, 0, 0, 0, 0, 0.1, 0.1, FFADE_OUT | FFADE_PURGE )
					StatusEffect_Stop( owner, statusEffect )
					TakePassive( owner, ePassives.PAS_FUSION_CORE )
				}
				if( owner.GetMainWeapons().len() != 0 )
				{
					entity weapon = owner.GetMainWeapons()[0]
					foreach( mod in GetWeaponBurnMods( weapon.GetWeaponClassName() ) )
					{
						weapon.RemoveMod( mod )
					}
				}
			}

			if ( IsValid( weapon ) )
			{
				if ( IsValid( owner ) )
					CoreDeactivate( owner, weapon )
				OnAbilityEnd_TitanCore( weapon )
			}

			if ( IsValid( soul ) )
			{
				CleanupCoreEffect( soul )
				StatusEffect_Stop( soul, statusEffect )
			}
		}
	)

	wait coreDuration
	#endif
}