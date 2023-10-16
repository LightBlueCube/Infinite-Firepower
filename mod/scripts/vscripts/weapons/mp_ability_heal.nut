global function OnWeaponPrimaryAttack_ability_heal


var function OnWeaponPrimaryAttack_ability_heal( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	{
		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			return false

		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			return false
	}

	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
	if( weapon.HasMod( "tcp_super_dash" ) )
	{
		duration = 1.0
		EmitSoundOnEntityExceptToPlayer( ownerPlayer, ownerPlayer, "Stryder.Dash" )
		EmitSoundOnEntityOnlyToPlayer( ownerPlayer, ownerPlayer, "titan_flight_liftoff_1p" )
		float movestunEffect = 1.0 - StatusEffect_Get( ownerPlayer, eStatusEffect.dodge_speed_slow )
		float moveSpeed = 600 * movestunEffect
		if( ownerPlayer.IsOnGround() )
			SetPlayerVelocityFromInput( ownerPlayer, moveSpeed, ownerPlayer.GetVelocity() + < 0, 0, 400 > )
		else
			SetPlayerVelocityFromInput( ownerPlayer, moveSpeed * 0.5 , ownerPlayer.GetVelocity() + < 0, 0, 800 > )
		entity soul = ownerPlayer.GetTitanSoul()
		if ( soul == null )
			soul = ownerPlayer

		float fade = 0.5
		StatusEffect_AddTimed( soul, eStatusEffect.move_slow, 0.6, 1 + fade, fade )
	}

	StimPlayer( ownerPlayer, duration )

	PlayerUsedOffhand( ownerPlayer, weapon )

#if SERVER
#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}
