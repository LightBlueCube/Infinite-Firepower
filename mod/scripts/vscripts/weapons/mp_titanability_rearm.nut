untyped
//TODO: FIX REARM WHILE FIRING SALVO ROCKETS

global function OnWeaponPrimaryAttack_titanability_rearm
global function OnWeaponAttemptOffhandSwitch_titanability_rearm

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_rearm
#endif

var function OnWeaponPrimaryAttack_titanability_rearm( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	if( weapon.HasMod( "tcp_no_gravity" ) )
	{
		thread NoGravity40cm( weaponOwner, weapon )
		return 0
	}
	entity ordnance = weaponOwner.GetOffhandWeapon( OFFHAND_RIGHT )
	if ( IsValid( ordnance ) )
	{
		ordnance.SetWeaponPrimaryClipCount( ordnance.GetWeaponPrimaryClipCountMax() )
		#if SERVER
		if ( ordnance.IsChargeWeapon() )
			ordnance.SetWeaponChargeFractionForced( 0 )
		#endif
	}
	entity defensive = weaponOwner.GetOffhandWeapon( OFFHAND_LEFT )
	if ( IsValid( defensive ) )
		defensive.SetWeaponPrimaryClipCount( defensive.GetWeaponPrimaryClipCountMax() )
	#if SERVER
	if ( weaponOwner.IsPlayer() )//weapon.HasMod( "rapid_rearm" ) &&  )
			weaponOwner.Server_SetDodgePower( 100.0 )
	#endif
	weapon.SetWeaponPrimaryClipCount( 0 )//used to skip the fire animation
	return 0
}

void function NoGravity40cm( entity owner, entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "DisembarkingTitan" )
	owner.EndSignal( "TitanEjectionStarted" )

	if( !owner.IsTitan() )
		return
	if( owner.GetMainWeapons().len() == 0 )
		return
	entity mainWeapon = owner.GetMainWeapons()[0]
	mainWeapon.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( mainWeapon, owner, weapon )
		{
			if( !IsValid( weapon ) )
				return
			weapon.SetWeaponPrimaryClipCount( 0 )

			if( !IsValid( mainWeapon ) )
				return
			if( !IsValid( owner ) )
				return

			mainWeapon.RemoveMod( "tcp_no_gravity" )
			mainWeapon.AddMod( "mortar_shots" )
			if( TitanCoreInUse( owner ) )
				return

			foreach( mod in GetWeaponBurnMods( mainWeapon.GetWeaponClassName() ) )
				if( mainWeapon.HasMod( mod ) )
					mainWeapon.RemoveMod( mod )
		}
	)

	if( !TitanCoreInUse( owner ) )
		foreach( mod in GetWeaponBurnMods( mainWeapon.GetWeaponClassName() ) )
			mainWeapon.AddMod( mod )

	mainWeapon.RemoveMod( "mortar_shots" )
	mainWeapon.AddMod( "tcp_no_gravity" )

	int shots = 6
	mainWeapon.s.leftShots <- shots
	for( ;; )
	{
		if( mainWeapon.s.leftShots <= 0 )
			return
		weapon.SetWeaponPrimaryClipCountAbsolute( GraphCapped( mainWeapon.s.leftShots, 0, shots, 0, weapon.GetWeaponPrimaryClipCountMax() - 10 ) )
		WaitFrame()
	}
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanability_rearm( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanability_rearm( weapon, attackParams )
}
#endif

bool function OnWeaponAttemptOffhandSwitch_titanability_rearm( entity weapon )
{
	if( weapon.HasMod( "tcp_no_gravity" ) )
		return true

	bool allowSwitch = true
	entity weaponOwner = weapon.GetWeaponOwner()

	entity ordnance = weaponOwner.GetOffhandWeapon( OFFHAND_RIGHT )
	entity defensive = weaponOwner.GetOffhandWeapon( OFFHAND_LEFT )

	if ( ordnance.GetWeaponPrimaryClipCount() == ordnance.GetWeaponPrimaryClipCountMax() && defensive.GetWeaponPrimaryClipCount() == defensive.GetWeaponPrimaryClipCountMax() )
		allowSwitch = false

	if ( ordnance.IsBurstFireInProgress() )
		allowSwitch = false

	if ( ordnance.IsChargeWeapon() && ordnance.GetWeaponChargeFraction() > 0.0 )
		allowSwitch = true

	//if ( weapon.HasMod( "rapid_rearm" ) )
	//{
		if ( weaponOwner.GetDodgePower() < 100 )
			allowSwitch = true
	//}

	if( !allowSwitch && IsFirstTimePredicted() )
	{
		// Play SFX and show some HUD feedback here...
		#if CLIENT
			AddPlayerHint( 1.0, 0.25, $"rui/titan_loadout/tactical/titan_tactical_rearm", "#WPN_TITANABILITY_REARM_ERROR_HINT" )
			if ( weaponOwner == GetLocalViewPlayer() )
				EmitSoundOnEntity( weapon, "titan_dryfire" )
		#endif
	}

	return allowSwitch
}

//UPDATE TO RESTORE CHARGE FOR THE MTMS