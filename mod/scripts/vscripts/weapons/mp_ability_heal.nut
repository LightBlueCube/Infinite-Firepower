global function OnWeaponPrimaryAttack_ability_heal
// modified!
global function OnWeaponTossPrep_ability_heal
global function OnWeaponTossReleaseAnimEvent_ability_heal
global function OnProjectileCollision_ability_heal

var function OnWeaponPrimaryAttack_ability_heal( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "wrecking_ball" ) )
		return

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
		float height = 400
		if( !ownerPlayer.IsOnGround() )
		{
			moveSpeed *= 0.5
			height *= 2
		}

		float xAxis = ownerPlayer.GetInputAxisRight()
		float yAxis = ownerPlayer.GetInputAxisForward()
		if( xAxis == 0 && yAxis == 0 )
		{
			yAxis = 1

			vector playerAngles = ownerPlayer.EyeAngles()
			playerAngles.x = 0
			playerAngles.z = 0
			vector forward = AnglesToForward( playerAngles )
			vector right = AnglesToRight( playerAngles )

			vector directionVec = Vector(0,0,0)
			directionVec += right * xAxis
			directionVec += forward * yAxis

			vector directionAngles = VectorToAngles( directionVec )
			vector directionForward = AnglesToForward( directionAngles )

			ownerPlayer.SetVelocity( directionForward * moveSpeed + ownerPlayer.GetVelocity() + < 0, 0, height > )
		}
		else
			SetPlayerVelocityFromInput( ownerPlayer, moveSpeed, ownerPlayer.GetVelocity() + < 0, 0, height > )

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


// modified callbacks
void function OnWeaponTossPrep_ability_heal( entity weapon, WeaponTossPrepParams prepParams )
{
	if( weapon.HasMod( "wrecking_ball" ) )
		return OnWeaponTossPrep_weapon_wrecking_ball( weapon, prepParams )
}

var function OnWeaponTossReleaseAnimEvent_ability_heal( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "wrecking_ball" ) )
		return OnWeaponTossReleaseAnimEvent_weapon_wrecking_ball( weapon, attackParams )
}

void function OnProjectileCollision_ability_heal( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	array<string> mods = Vortex_GetRefiredProjectileMods( projectile )
	if ( mods.contains( "wrecking_ball" ) )
		return OnProjectileCollision_weapon_wrecking_ball( projectile, pos, normal, hitEnt, hitbox, isCritical )
}