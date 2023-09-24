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
	if( !target.IsNPC() && !target.IsPlayer() )
		return
	thread HighLightingTarget( target, attacker )
}

void function HighLightingTarget( entity target, entity owner )
{
	target.EndSignal( "OnDeath" )
	target.EndSignal( "OnDestroy" )

	int sonarTeam = owner.GetTeam()
	int statusEffect = StatusEffect_AddEndless( target, eStatusEffect.damage_received_multiplier, 0.5 )

	OnThreadEnd(
		function() : ( target, statusEffect, sonarTeam )
		{
			if ( IsValid( target ) )
			{
				Highlight_ClearEnemyHighlight( target )
				StatusEffect_Stop( target, statusEffect )
			}
		}
	)
	if( Hightlight_HasEnemyHighlight( target, "enemy_boss_bounty" ) )
		Highlight_ClearEnemyHighlight( target )
	Highlight_SetEnemyHighlight( target, "enemy_boss_bounty" )

	wait 6
}

#endif