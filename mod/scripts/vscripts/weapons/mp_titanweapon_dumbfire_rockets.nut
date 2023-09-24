untyped
global function OnWeaponPrimaryAttack_titanweapon_dumbfire_rockets
global function OnWeaponPrimaryAttack_titanweapon_multi_cluster
global function OnWeaponAttemptOffhandSwitch_titanweapon_dumbfire_rockets

#if SERVER
	global function OnWeaponNPCPrimaryAttack_titanweapon_dumbfire_rockets
#endif
//----------------
//Cluster Missile
//----------------

var function OnWeaponPrimaryAttack_titanweapon_multi_cluster( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return ammoReq
	#endif

	entity missile = FireClusterRocket( weapon, attackParams.pos, attackParams.dir, shouldPredict )

	return ammoReq
}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_dumbfire_rockets( entity weapon )
{
	int ammoPerShot = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoPerShot )
		return false

	return true
}

var function OnWeaponPrimaryAttack_titanweapon_dumbfire_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool shouldPredict = weapon.ShouldPredictProjectiles()
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	#if CLIENT
	if ( !shouldPredict )
		return weapon.GetAmmoPerShot()
	#endif
	entity owner = weapon.GetWeaponOwner()
	vector attackDir
	bool isTwinShot = weapon.HasMod( "fd_twin_cluster" ) //&& RandomIntRange( 1, 100 ) <= 25
	if ( isTwinShot )
	{
		int altFireIndex = weapon.GetBurstFireShotsPending() % 2
		float horizontalMultiplier
		if ( altFireIndex == 0 )
			horizontalMultiplier = RandomFloatRange( 0.25, 0.35 )
		else
			horizontalMultiplier = RandomFloatRange( -0.35, -0.25 )
		vector offset
		if ( owner.IsPlayer() )
			offset = AnglesToRight( owner.CameraAngles() ) * horizontalMultiplier
		#if SERVER
		else
			offset = owner.GetPlayerOrNPCViewRight() * horizontalMultiplier
		#endif

		attackDir = attackParams.dir + offset*0.1 // + <0,0,RandomFloatRange(-0.25,0.55)>
	}
	else
	{
		if ( owner.IsPlayer() )
			attackDir = GetVectorFromPositionToCrosshair( owner, attackParams.pos )
		else
			attackDir = attackParams.dir
	}

	entity missile = FireClusterRocket( weapon, attackParams.pos, attackDir, shouldPredict )

	if ( owner.IsPlayer() )
		PlayerUsedOffhand( owner, weapon )

	int ammoToSpend = weapon.GetAmmoPerShot()

	if ( isTwinShot && attackParams.burstIndex == 0 )
	{
		return 90
	}

	return ammoToSpend
}

entity function FireClusterRocket( entity weapon, vector attackPos, vector attackDir, bool shouldPredict )
{
	float missileSpeed = 3500.0

	bool doPopup = false

	if( weapon.HasMod( "tcp_arc_bomb" ) )
	{
		entity missile = weapon.FireWeaponMissile( attackPos, attackDir, 2500, damageTypes.projectileImpact, damageTypes.explosive, doPopup, shouldPredict )
		thread EMPSonarThinkConstant( missile, weapon.GetWeaponOwner() )
		thread EMPSonarThinkConstant( missile, weapon.GetWeaponOwner() )
		thread EMPSonarThinkConstant( missile, weapon.GetWeaponOwner() )
		thread EMPSonarThinkConstant( missile, weapon.GetWeaponOwner() )
		return missile
	}

	entity missile = weapon.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageTypes.projectileImpact, damageTypes.explosive, doPopup, shouldPredict )


	if ( missile )
	{
		missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )
	}

	return missile
}


#if SERVER
var function OnWeaponNPCPrimaryAttack_titanweapon_dumbfire_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_dumbfire_rockets( weapon, attackParams )
}
#endif

const DAMAGE_AGAINST_TITANS 			= 25
const DAMAGE_AGAINST_PILOTS 			= 20

const EMP_DAMAGE_TICK_RATE = 0.1
const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"

struct
{
	array<entity> empTitans
} file

void function EMPSonarThinkConstant( entity titan, entity owner )
{
	RegisterSignal( "empistimeout" )

	titan.EndSignal( "empistimeout" )
	//titan.EndSignal( "OnDeath" )
	//titan.EndSignal( "OnDestroy" )
	//titan.EndSignal( "Doomed" )
	//titan.EndSignal( "StopEMPField" )

	//We don't want pilots accidently rodeoing an electrified titan.
	//DisableTitanRodeo( titan )

	//Used to identify this titan as an arc titan
	// SetTargetName( titan, "empTitan" ) // unable to do this due to FD reasons
	file.empTitans.append( titan )

	//Wait for titan to stand up and exit bubble shield before deploying arc ability.
	WaitTillHotDropComplete( titan )

	/*if ( HasSoul( titan ) )
	{
		entity soul = titan.GetTitanSoul()
		soul.EndSignal( "StopEMPField" )
	}*/

	local attachment = "hijack"

	local attachID = titan.LookupAttachment( attachment )

	EmitSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )

	array<entity> particles = []

	//emp field fx
	vector origin = titan.GetOrigin()
	if ( titan.IsPlayer() )
	{
		entity particleSystem = CreateEntity( "info_particle_system" )
		particleSystem.kv.start_active = 1
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
		particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD_1P )

		particleSystem.SetOrigin( origin )
		particleSystem.SetOwner( owner )
		particleSystem.SetParent( titan )
		DispatchSpawn( particleSystem )
		//particleSystem.SetParent( titan, "" )
		particles.append( particleSystem )
	}

	entity particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	if ( titan.IsPlayer() )
		particleSystem.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	else
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD )
	particleSystem.SetOwner( owner )
	particleSystem.SetOrigin( origin )
	particleSystem.SetParent( titan )
	DispatchSpawn( particleSystem )
	//particleSystem.SetParent( titan, "" )
	particles.append( particleSystem )

	//titan.SetDangerousAreaRadius( ARC_TITAN_EMP_FIELD_RADIUS )

	OnThreadEnd(
		function () : ( titan, particles )
		{
			if ( IsValid( titan ) )
			{
				StopSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )
				//EnableTitanRodeo( titan ) //Make the arc titan rodeoable now that it is no longer electrified.
				if (file.empTitans.find( titan ) )
					file.empTitans.remove( file.empTitans.find( titan ) )
			}

			foreach ( particleSystem in particles )
			{
				if ( IsValid_ThisFrame( particleSystem ) )
				{
					particleSystem.ClearParent()
					particleSystem.Fire( "StopPlayEndCap" )
					particleSystem.Kill_Deprecated_UseDestroyInstead( 1.0 )
				}
			}
		}
	)


		wait RandomFloat( EMP_DAMAGE_TICK_RATE )

	while ( true )
	{
		origin = titan.GetOrigin()
		RadiusDamage(
			origin,									// center
			owner,									// attacker
			titan,									// inflictor
			DAMAGE_AGAINST_PILOTS,					// damage
			DAMAGE_AGAINST_TITANS,					// damageHeavyArmor
			ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
			ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
			SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
			0,										// distanceFromAttacker
			DAMAGE_AGAINST_PILOTS,					// explosionForce
			DF_ELECTRICAL | DF_STOPS_TITAN_REGEN,	// scriptDamageFlags
   			eDamageSourceId.mp_titancore_emp )			// scriptDamageSourceIdentifier
		wait EMP_DAMAGE_TICK_RATE
	}
}