untyped

global function MpTitanweaponVortexShield_Init

global function OnWeaponActivate_titanweapon_vortex_shield
global function OnWeaponDeactivate_titanweapon_vortex_shield
global function OnWeaponCustomActivityStart_titanweapon_vortex_shield
global function OnWeaponVortexHitBullet_titanweapon_vortex_shield
global function OnWeaponVortexHitProjectile_titanweapon_vortex_shield
global function OnWeaponPrimaryAttack_titanweapon_vortex_shield
global function OnWeaponChargeBegin_titanweapon_vortex_shield
global function OnWeaponChargeEnd_titanweapon_vortex_shield
global function OnWeaponAttemptOffhandSwitch_titanweapon_vortex_shield
global function OnWeaponOwnerChanged_titanweapon_vortex_shield

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_vortex_shield
#endif // #if SERVER

#if CLIENT
global function OnClientAnimEvent_titanweapon_vortex_shield
#endif // #if CLIENT


const ACTIVATION_COST_FRAC = 0.05 //0.2 //R1 was 0.1

function MpTitanweaponVortexShield_Init()
{
	VortexShieldPrecache()

	RegisterSignal( "DisableAmpedVortex" )
	RegisterSignal( "FireAmpedVortexBullet" )
	RegisterSignal( "TrackSharedEnergy" )
}

function VortexShieldPrecache()
{
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_titan_FP" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_titan_FP_replay" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_titan" )
	PrecacheParticleSystem( $"wpn_vortex_shield_impact_titan" )
	PrecacheParticleSystem( $"wpn_muzzleflash_vortex_titan_CP_FP" )

	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_FP" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_FP_replay" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod" )
	PrecacheParticleSystem( $"wpn_vortex_shield_impact_mod" )
	PrecacheParticleSystem( $"wpn_muzzleflash_vortex_mod_CP_FP" )

	PrecacheParticleSystem( $"P_impact_exp_emp_med_air" )
}

void function OnWeaponOwnerChanged_titanweapon_vortex_shield( entity weapon, WeaponOwnerChangedParams changeParams )
{
	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.fxChargingFPControlPoint <- $"wpn_vortex_chargingCP_titan_FP"
		weapon.s.fxChargingFPControlPointReplay <- $"wpn_vortex_chargingCP_titan_FP_replay"
		weapon.s.fxChargingControlPoint <- $"wpn_vortex_chargingCP_titan"
		weapon.s.fxBulletHit <- $"wpn_vortex_shield_impact_titan"

		weapon.s.fxChargingFPControlPointBurn <- $"wpn_vortex_chargingCP_mod_FP"
		weapon.s.fxChargingFPControlPointReplayBurn <- $"wpn_vortex_chargingCP_mod_FP_replay"
		weapon.s.fxChargingControlPointBurn <- $"wpn_vortex_chargingCP_mod"
		weapon.s.fxBulletHitBurn <- $"wpn_vortex_shield_impact_mod"

		weapon.s.fxElectricalExplosion <- $"P_impact_exp_emp_med_air"

		weapon.s.lastFireTime <- 0
		weapon.s.hadChargeWhenFired <- false


		#if CLIENT
			weapon.s.lastUseTime <- 0
		#endif

		weapon.s.initialized <- true
	}
}

void function OnWeaponActivate_titanweapon_vortex_shield( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	// just for NPCs (they don't do the deploy event)
	if ( !weaponOwner.IsPlayer() )
	{
		Assert( !( "isVortexing" in weaponOwner.s ), "NPC trying to vortex before cleaning up last vortex" )
		StartVortex( weapon )
	}

	#if SERVER
		if ( weapon.GetWeaponSettingBool( eWeaponVar.is_burn_mod ) )
			thread AmpedVortexRefireThink( weapon )
	#endif
}

void function OnWeaponDeactivate_titanweapon_vortex_shield( entity weapon )
{
	EndVortex( weapon )

	if ( weapon.GetWeaponSettingBool( eWeaponVar.is_burn_mod ) )
		weapon.Signal( "DisableAmpedVortex" )
}

void function OnWeaponCustomActivityStart_titanweapon_vortex_shield( entity weapon )
{
	EndVortex( weapon )
}

function StartVortex( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

#if CLIENT
	if ( weaponOwner != GetLocalViewPlayer() )
		return

	if ( IsFirstTimePredicted() )
		Rumble_Play( "rumble_titan_vortex_start", {} )
#endif

	Assert( IsAlive( weaponOwner ),  "ent trying to start vortexing after death: " + weaponOwner )

	if ( "shotgunPelletsToIgnore" in weapon.s )
		weapon.s.shotgunPelletsToIgnore = 0
	else
		weapon.s.shotgunPelletsToIgnore <- 0

	Vortex_SetBulletCollectionOffset( weapon, Vector( 110, -28, -22.0 ) )

	int sphereRadius = 150
	int bulletFOV = 120

	ApplyActivationCost( weapon, ACTIVATION_COST_FRAC )

	local hasBurnMod = weapon.GetWeaponSettingBool( eWeaponVar.is_burn_mod )
	if ( weapon.GetWeaponChargeFraction() < 1 )
	{
		weapon.s.hadChargeWhenFired = true
		CreateVortexSphere( weapon, false, false, sphereRadius, bulletFOV )
		EnableVortexSphere( weapon )
		weapon.EmitWeaponSound_1p3p( "vortex_shield_loop_1P", "vortex_shield_loop_3P" )
	}
	else
	{
		weapon.s.hadChargeWhenFired = false
		weapon.EmitWeaponSound_1p3p( "vortex_shield_empty_1P", "vortex_shield_empty_3P" )
	}

	#if SERVER
		thread ForceReleaseOnPlayerEject( weapon )
	#endif

	#if CLIENT
		weapon.s.lastUseTime = Time()
	#endif
}

function AmpedVortexRefireThink( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.EndSignal( "DisableAmpedVortex" )
	weapon.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		weapon.WaitSignal( "FireAmpedVortexBullet" )

		if ( IsValid( weaponOwner )	)
		{
			ShotgunBlast( weapon, weaponOwner.EyePosition(), weaponOwner.GetPlayerOrNPCViewVector(), expect int( weapon.s.ampedBulletCount ), damageTypes.shotgun | DF_VORTEX_REFIRE )
			weapon.s.ampedBulletCount = 0
		}
	}
}

function ForceReleaseOnPlayerEject( entity weapon )
{
	weapon.EndSignal( "VortexFired" )
	weapon.EndSignal( "OnDestroy" )

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsAlive( weaponOwner ) )
		return

	weaponOwner.EndSignal( "OnDeath" )

	weaponOwner.WaitSignal( "TitanEjectionStarted" )

	weapon.ForceRelease()
}

function ApplyActivationCost( entity weapon, float frac )
{
	if ( weapon.HasMod( "vortex_extended_effect_and_no_use_penalty" ) )
		return

	float fracLeft = weapon.GetWeaponChargeFraction()

	if ( fracLeft + frac >= 1 )
	{
		weapon.ForceRelease()
		weapon.SetWeaponChargeFraction( 1.0 )
	}
	else
	{
		weapon.SetWeaponChargeFraction( fracLeft + frac )
	}
}

function EndVortex( entity weapon )
{
	#if CLIENT
		weapon.s.lastUseTime = Time()
	#endif
	weapon.StopWeaponSound( "vortex_shield_loop_1P" )
	weapon.StopWeaponSound( "vortex_shield_loop_3P" )
	DestroyVortexSphereFromVortexWeapon( weapon )
}

bool function OnWeaponVortexHitBullet_titanweapon_vortex_shield( entity weapon, entity vortexSphere, var damageInfo )
{
	if ( weapon.HasMod( "shield_only" ) )
		return true

	#if CLIENT
		return true
	#else
		if ( !ValidateVortexImpact( vortexSphere ) )
			return false

		entity attacker				= DamageInfo_GetAttacker( damageInfo )
		vector origin				= DamageInfo_GetDamagePosition( damageInfo )
		int damageSourceID			= DamageInfo_GetDamageSourceIdentifier( damageInfo )
		entity attackerWeapon		= DamageInfo_GetWeapon( damageInfo )
		if ( PROTO_ATTurretsEnabled() && !IsValid( attackerWeapon ) )
			return true
		string attackerWeaponName	= attackerWeapon.GetWeaponClassName()
		int damageType				= DamageInfo_GetCustomDamageType( damageInfo )

		// tempfix ttf2 vanilla behavior: burn mod vortex shield
		// never try to catch a burn mod vortex's refiring bullets if we're using burn mod vortex shield
		// otherwise it may cause infinite refire and crash the server( indicates by SCRIPT ERROR Failed to Create Entity "info_particle_system", the failure is because we've created so much entities due to infinite refire )
		if ( weapon.HasMod( "burn_mod_titan_vortex_shield" ) && attackerWeapon.HasMod( "burn_mod_titan_vortex_shield" ) )
		{
			// build impact data
			local impactData = Vortex_CreateImpactEventData( weapon, attacker, origin, damageSourceID, attackerWeaponName, "hitscan" )
			// do vortex drain
			VortexDrainedByImpact( weapon, attackerWeapon, null, null )
			// like heat shield and TryVortexAbsorb() behavior: if it's absorb behavior, we don't do FX
			if ( impactData.refireBehavior == VORTEX_REFIRE_ABSORB )
				return true
			// generic shield ping FX, modified to globalize this function in _vortex.nut
			Vortex_SpawnShieldPingFX( weapon, impactData )
			return true
		}
		//

		TakeAmountIfIsRodeoAttack( attacker, weapon )
		if( weapon.HasMod( "tcp_vortex" ) )
		{
			TakeAmountOnVotexDamaged( weapon, attackerWeapon )
			weapon.s.trackEnergyCooldown <- 50
		}

		return TryVortexAbsorb( vortexSphere, attacker, origin, damageSourceID, attackerWeapon, attackerWeaponName, "hitscan", null, damageType, weapon.HasMod( "burn_mod_titan_vortex_shield" ) )
	#endif
}

void function TakeAmountIfIsRodeoAttack( entity attacker, entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	if( !IsAlive( owner ) || !owner.IsTitan() )
		return
	if( !IsValid( owner.GetTitanSoul() ) )
		return
	if( !IsValid( attacker ) )
		return
	if( !IsAlive( attacker ) || !attacker.IsPlayer() || attacker.IsTitan() )
		return
	if( attacker.GetTitanSoulBeingRodeoed() != owner.GetTitanSoul() )
		return

	if( weapon.GetWeaponClassName() == "mp_titanweapon_vortex_shield_ion" )
	{

		int totalEnergy = owner.GetSharedEnergyTotal()
		owner.TakeSharedEnergy( int( float( totalEnergy ) * 0.2 ) )
	}
	else
	{
		float frac = min ( weapon.GetWeaponChargeFraction() + 0.2, 1.0 )
		weapon.SetWeaponChargeFraction( frac )
	}
}

bool function OnWeaponVortexHitProjectile_titanweapon_vortex_shield( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	if ( weapon.HasMod( "shield_only" ) )
		return true

	#if CLIENT
		return true
	#else

		if( weapon.HasMod( "tcp_vortex" ) )
		{
			TakeAmountOnVotexDamaged( weapon, projectile )
			weapon.s.trackEnergyCooldown <- 50
		}

		if( Vortex_GetRefiredProjectileMods( projectile ).contains( "tcp_shotgun" ) )
		{
			OnProjectileCollision_FireWallShotGun( projectile )
			return false
		}
		if( Vortex_GetRefiredProjectileMods( projectile ).contains( "charge_ball" ) )
		{
			projectile.Destroy()
			return false
		}

		if ( !ValidateVortexImpact( vortexSphere, projectile ) )
			return false

		int damageSourceID = projectile.ProjectileGetDamageSourceID()
		string weaponName = projectile.ProjectileGetWeaponClassName()

		TakeAmountIfIsRodeoAttack( projectile.GetOwner(), weapon )

		return TryVortexAbsorb( vortexSphere, attacker, contactPos, damageSourceID, projectile, weaponName, "projectile", projectile, null, weapon.HasMod( "burn_mod_titan_vortex_shield" ) )
	#endif
}

var function OnWeaponPrimaryAttack_titanweapon_vortex_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	local hasBurnMod = weapon.GetWeaponSettingBool( eWeaponVar.is_burn_mod )
	int bulletsFired
	if ( hasBurnMod )
		bulletsFired = 1
	else
		bulletsFired = VortexPrimaryAttack( weapon, attackParams )
	// only play the release/refire endcap sounds if we started with charge remaining
	if ( weapon.s.hadChargeWhenFired )
	{
		string attackSound1p = "vortex_shield_end_1P"
		string attackSound3p = "vortex_shield_end_3P"
		if ( bulletsFired )
		{
			weapon.s.lastFireTime = Time()
			if ( hasBurnMod )
			{
				attackSound1p = "Vortex_Shield_Deflect_Amped"
				attackSound3p = "Vortex_Shield_Deflect_Amped"
			}
			else
			{
				attackSound1p = "vortex_shield_throw_1P"
				attackSound3p = "vortex_shield_throw_3P"
			}
		}

		//printt( "SFX attack sound:", attackSound )
		weapon.EmitWeaponSound_1p3p( attackSound1p, attackSound3p )
	}

	DestroyVortexSphereFromVortexWeapon( weapon )  // sphere ent holds networked ammo count, destroy it after predicted firing is done

	if ( hasBurnMod )
	{
		FadeOutSoundOnEntity( weapon, "vortex_shield_start_amped_1P", 0.15 )
		FadeOutSoundOnEntity( weapon, "vortex_shield_start_amped_3P", 0.15 )
	}
	else
	{
		FadeOutSoundOnEntity( weapon, "vortex_shield_start_1P", 0.15 )
		FadeOutSoundOnEntity( weapon, "vortex_shield_start_3P", 0.15 )
	}

	return bulletsFired
}


#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_vortex_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int bulletsFired = VortexPrimaryAttack( weapon, attackParams )

	DestroyVortexSphereFromVortexWeapon( weapon )  // sphere ent holds networked ammo count, destroy it after predicted firing is done

	return bulletsFired
}
#endif // #if SERVER

#if CLIENT
void function OnClientAnimEvent_titanweapon_vortex_shield( entity weapon, string name )
{
	if ( name == "muzzle_flash" )
	{
		asset fpEffect
		if ( weapon.GetWeaponSettingBool( eWeaponVar.is_burn_mod ) )
			fpEffect = $"wpn_muzzleflash_vortex_mod_CP_FP"
		else
			fpEffect = $"wpn_muzzleflash_vortex_titan_CP_FP"

		int handle
		if ( GetLocalViewPlayer() == weapon.GetWeaponOwner() )
		{
			handle = weapon.PlayWeaponEffectReturnViewEffectHandle( fpEffect, $"", "vortex_center" )
		}
		else
		{
			handle = StartParticleEffectOnEntity( weapon, GetParticleSystemIndex( fpEffect ), FX_PATTACH_POINT_FOLLOW, weapon.LookupAttachment( "vortex_center" ) )
		}

		Assert( handle )
		// This Assert isn't valid because Effect might have been culled
		// Assert( EffectDoesExist( handle ), "vortex shield OnClientAnimEvent: Couldn't find viewmodel effect handle for vortex muzzle flash effect on client " + GetLocalViewPlayer() )

		vector colorVec = GetVortexSphereCurrentColor( weapon.GetWeaponChargeFraction() )
		EffectSetControlPointVector( handle, 1, colorVec )
	}
}
#endif

bool function OnWeaponChargeBegin_titanweapon_vortex_shield( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	// just for players
	if ( weaponOwner.IsPlayer() )
	{
		PlayerUsedOffhand( weaponOwner, weapon )
		StartVortex( weapon )
		if( weapon.HasMod( "tcp_vortex" ) )
			thread TrackSharedEnergyOnVortexOn( weaponOwner, weapon )
	}
	return true
}

void function TakeAmountOnVotexDamaged( entity weapon, entity projectile )
{
	float amount
	if ( projectile.IsProjectile() )
		amount = float( projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor ) )
	else
		amount = float( projectile.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor ) )

	if( amount <= 0 )
	{
		if ( projectile.IsProjectile() )
			amount = float( projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor ) )
		else
			amount = float( projectile.GetWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor ) )
	}

	entity owner = weapon.GetWeaponOwner()
	int currentEnergy = owner.GetSharedEnergyCount()
	int val = int( amount * 0.4 )	// 2500 hp for shield
	if( currentEnergy - val <= 0 )
		val = currentEnergy
	if( val >= 0 )
		owner.TakeSharedEnergy( val )
}

void function TrackSharedEnergyOnVortexOn( entity owner, entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "TitanEjectionStarted" )
	owner.EndSignal( "DisembarkingTitan" )

	owner.Signal( "TrackSharedEnergy" )
	owner.EndSignal( "TrackSharedEnergy" )

	if( !owner.IsTitan() )
		return
	entity soul = owner.GetTitanSoul()
	if( !IsValid( soul ) )
		return

	OnThreadEnd(
		function() : ( owner, weapon )
		{
			thread ClearCooldown( owner, weapon )
		}
	)

	int delay = int( soul.s.SharedEnergyRegenDelay ) * 10
	float baseRefill = expect float( soul.s.SharedEnergyRegenRate ) / 60
	float amount = expect float( soul.s.SharedEnergyRegenRate ) / 10 + baseRefill
	for( ;; )
	{
		WaitFrame()
		if( "trackEnergyCooldown" in weapon.s )
		{
			if( weapon.s.trackEnergyCooldown )
			{
				weapon.s.trackEnergyCooldown -= 1
				if( owner.GetSharedEnergyCount() + baseRefill > owner.GetSharedEnergyTotal() - 50 )
					owner.AddSharedEnergy( max( 0, ( owner.GetSharedEnergyTotal() - 50 ) - owner.GetSharedEnergyCount() ) )
				else
					owner.AddSharedEnergy( baseRefill )
				continue
			}
		}

		if( owner.GetSharedEnergyCount() + amount > owner.GetSharedEnergyTotal() - 50 )
		{
			owner.AddSharedEnergy( max( 0, ( owner.GetSharedEnergyTotal() - 50 ) - owner.GetSharedEnergyCount() ) )
			continue
		}
		owner.AddSharedEnergy( amount )
	}
}

void function ClearCooldown( entity owner, entity weapon )
{
	if( !( "trackEnergyCooldown" in weapon.s ) )
		return

	owner.EndSignal( "TrackSharedEnergy" )
	weapon.EndSignal( "OnDestroy" )
	while( weapon.s.trackEnergyCooldown > 0 )
	{
		WaitFrame()
		weapon.s.trackEnergyCooldown -= 1
	}
}

void function OnWeaponChargeEnd_titanweapon_vortex_shield( entity weapon )
{
	if( IsValid( weapon.GetWeaponOwner() ) )
		weapon.GetWeaponOwner().Signal( "TrackSharedEnergy" )
	// if ( weapon.HasMod( "slow_recovery_vortex" ) )
	// {
	// 	weapon.SetWeaponChargeFraction( 1.0 )
	// }
}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_vortex_shield( entity weapon )
{

	bool allowSwitch
	entity weaponOwner = weapon.GetWeaponOwner()
	entity soul = weaponOwner.GetTitanSoul()
	Assert( IsValid( soul ) )
	entity activeWeapon = weaponOwner.GetActiveWeapon()
	int minEnergyCost = 100
	if ( IsValid( activeWeapon ) && activeWeapon.IsChargeWeapon() && activeWeapon.IsWeaponCharging() )
	{
		allowSwitch = false
	}
	else if ( weapon.GetWeaponClassName() == "mp_titanweapon_vortex_shield_ion" )
	{
		allowSwitch = weaponOwner.CanUseSharedEnergy( minEnergyCost )
	}
	else
	{
		//Assert( weapon.IsChargeWeapon(), weapon.GetWeaponClassName() + " should be a charge weapon." )
		// HACK: this is a temp fix for bug http://bugzilla.respawn.net/show_bug.cgi?id=131021
		// the bug happens when a non-ION titan gets a vortex shield in MP
		// should be fixed in a better way; possibly by giving ION a modded version of vortex?
		if ( GetConVarInt( "bug_reproNum" ) != 131242 && weapon.IsChargeWeapon() )
		{
			if ( weapon.HasMod( "slow_recovery_vortex" ) )
				allowSwitch = weapon.GetWeaponChargeFraction() == 0.0
			else
				allowSwitch = weapon.GetWeaponChargeFraction() < 0.9
		}
		else
		{
			allowSwitch = false
		}
	}


	if( !allowSwitch && IsFirstTimePredicted() )
	{
		// Play SFX and show some HUD feedback here...
		#if CLIENT
			FlashEnergyNeeded_Bar( minEnergyCost )
		#endif
	}
	// Return whether or not we can bring up the vortex
	// Only allow it if we have enough charge to do anything
	return allowSwitch
}
