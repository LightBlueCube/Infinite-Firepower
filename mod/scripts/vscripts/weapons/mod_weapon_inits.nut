untyped
global function ModWeaponInit

void function ModWeaponInit()
{
	MpTitanWeaponHomingRockets_Init()
}

void function MpTitanWeaponHomingRockets_Init()
{
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_homing_rockets, HomingRocketsOnDamage )
}

void function HomingRocketsOnDamage( entity target, var damageInfo )
{
	if( !IsValid( target ) )
		return

	StatusEffect_AddTimed( target, eStatusEffect.move_slow, 0.25, 1.0, 1.0 )
	if( target.IsPlayer() )
		Remote_CallFunction_Replay( target, "ServerCallback_TitanEMP", 0.1, 1.0, 1.0 )

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if( !IsValid( attacker ) )
		return
	if( !attacker.IsNPC() && !attacker.IsPlayer() )
		return
	if( !IsValid( attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ) ) )
		return
	if( !attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ).HasMod( "tcp_push_back" ) )
		return
	if( target.GetTeam() == attacker.GetTeam() )
		return

	target.SetVelocity( ( Normalize( attacker.GetOrigin() - target.GetOrigin() ) * 2400 ) + < 0, 0, 400 > )
}
