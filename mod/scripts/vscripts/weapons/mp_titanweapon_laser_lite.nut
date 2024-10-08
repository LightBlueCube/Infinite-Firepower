global function MpTitanWeaponLaserLite_Init

global function OnWeaponAttemptOffhandSwitch_titanweapon_laser_lite
global function OnWeaponPrimaryAttack_titanweapon_laser_lite

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanweapon_laser_lite
#endif

void function MpTitanWeaponLaserLite_Init()
{
	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_laser_lite, LaserLite_DamagedTarget )
	#endif

	RegisterSignal( "MarkLaserTagetThink" )
	RegisterSignal( "MarkLaserHudMsgStop" )
}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_laser_lite( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	int curCost = weapon.GetWeaponCurrentEnergyCost()
	bool canUse = owner.CanUseSharedEnergy( curCost )

	#if CLIENT
		if ( !canUse )
			FlashEnergyNeeded_Bar( curCost )
	#endif
	return canUse
}

var function OnWeaponPrimaryAttack_titanweapon_laser_lite( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return 1
	#endif

	entity weaponOwner = weapon.GetWeaponOwner()
	if( !weaponOwner.CanUseSharedEnergy( weapon.GetWeaponCurrentEnergyCost() ) )
		return 0

	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	weapon.SetWeaponChargeFractionForced(1.0)
	return 1
}
#if SERVER
var function OnWeaponNPCPrimaryAttack_titanweapon_laser_lite( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_laser_lite( weapon, attackParams )
}

void function LaserLite_DamagedTarget( entity target, var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if( !IsValid( weapon ) )
		return
	if( !IsValid( attacker ) )
		return
	if( !weapon.HasMod( "tcp_mark_laser" ) )
		return
	if ( attacker.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "HUD_40mm_TrackerBeep_Locked" )
	}
	if( !IsValid( target ) )
		return
	if( !target.IsNPC() && !target.IsTitan() )
		return
	thread HighLightingTarget( target )
}

void function HighLightingTarget( entity target )
{
	target.EndSignal( "OnDeath" )
	target.EndSignal( "OnDestroy" )
	target.EndSignal( "TitanEjectionStarted" )
	target.EndSignal( "DisembarkingTitan" )
	target.EndSignal( "player_embarks_titan" )
	target.Signal( "MarkLaserTagetThink" )
	target.EndSignal( "MarkLaserTagetThink" )

	int statusEffect = StatusEffect_AddEndless( target, eStatusEffect.damage_received_multiplier, 0.5 )
	int statusEffectHandle = StatusEffect_AddEndless( target, eStatusEffect.sonar_detected, 1.0 )

	OnThreadEnd(
		function() : ( target, statusEffect, statusEffectHandle )
		{
			if ( IsValid( target ) )
			{
				target.Signal( "MarkLaserHudMsgStop" )
				Highlight_ClearEnemyHighlight( target )
				StatusEffect_Stop( target, statusEffect )
				StatusEffect_Stop( target, statusEffectHandle )
			}
		}
	)
	Highlight_ClearEnemyHighlight( target )
	Highlight_SetSonarHighlightWithParam0( target, "enemy_sonar", <1, 0, 0> )

	if( target.IsPlayer() )
		thread MarkLaserHudMsgThink( target )
	wait 6
}

void function MarkLaserHudMsgThink( entity target )
{
	target.EndSignal( "OnDestroy" )
	target.EndSignal( "MarkLaserHudMsgStop" )

	for( ;; )
	{
		SendHudMessageWithPriority( target, 91, "被天图标记", -1, -0.4, < 255, 0, 0 >, < 0, 0.2, 0 > )
		WaitFrame()
		SendHudMessageWithPriority( target, 91, "被天图标记", -1, -0.4, < 255, 255, 0 >, < 0, 0.2, 0 > )
		WaitFrame()
	}
}

#endif