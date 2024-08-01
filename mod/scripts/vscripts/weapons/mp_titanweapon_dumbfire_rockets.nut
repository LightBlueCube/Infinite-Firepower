untyped
global function MpTitanWeaponDumbfireRocket_Init
global function OnWeaponPrimaryAttack_titanweapon_dumbfire_rockets
global function OnWeaponPrimaryAttack_titanweapon_multi_cluster
global function OnWeaponAttemptOffhandSwitch_titanweapon_dumbfire_rockets

#if SERVER
	global function OnWeaponNPCPrimaryAttack_titanweapon_dumbfire_rockets
#endif
//----------------
//Cluster Missile
//----------------

void function MpTitanWeaponDumbfireRocket_Init()
{
	// stun impact
	RegisterWeaponDamageSource( "mp_titanweapon_stun_impact", "電漿爆破彈" )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_stun_impact, ImpactStun_OnDamagedTarget )
	// charge ball
	RegisterWeaponDamageSource( "mp_titanweapon_charge_ball", "球狀閃電" )
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_dumbfire_rockets, DumbfireRocket_OnDamagedTarget )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_charge_ball, ChargeBall_OnDamagedTarget )
	RegisterBallLightningDamage( eDamageSourceId.mp_titanweapon_charge_ball ) // doing check in stun laser damagesourceID

	Vortex_AddImpactDataOverride_WeaponMod(
		"mp_titanweapon_dumbfire_rockets", // weapon name
		"archon_stun_impact", // mod name
		GetWeaponInfoFileKeyFieldAsset_Global( "mp_weapon_grenade_emp", "vortex_absorb_effect" ), // absorb effect
		GetWeaponInfoFileKeyFieldAsset_Global( "mp_weapon_grenade_emp", "vortex_absorb_effect_third_person" ), // absorb effect 3p
		"grenade" // refire behavior
	)
}

var function OnWeaponPrimaryAttack_titanweapon_multi_cluster( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "charge_ball" ) )
		return OnWeaponPrimaryAttack_weapon_MpTitanWeaponChargeBall( weapon, attackParams )
	if ( weapon.HasMod( "archon_stun_impact" ) )
		return OnWeaponPrimaryAttack_titanweapon_stun_impact( weapon, attackParams )

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
	if( weapon.HasMod( "charge_ball" ) )
		return OnWeaponPrimaryAttack_weapon_MpTitanWeaponChargeBall( weapon, attackParams )
	if ( weapon.HasMod( "archon_stun_impact" ) )
		return OnWeaponPrimaryAttack_titanweapon_stun_impact( weapon, attackParams )

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



var function OnWeaponPrimaryAttack_titanweapon_stun_impact( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	return FireStunImpactProjectile( weapon, attackParams )
}

// projectile function, shuold keep up with FireSonarPulse() for client prediction
int function FireStunImpactProjectile( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	float STUN_IMPACT_PROJECTILE_FUSE_TIME = 5.0
	int STUN_IMPACT_DAMAGE_FLAGS = DF_RAGDOLL | DF_EXPLOSION | DF_ELECTRICAL
	entity projectile = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir, < 0, 0, 0 >, STUN_IMPACT_PROJECTILE_FUSE_TIME, STUN_IMPACT_DAMAGE_FLAGS, STUN_IMPACT_DAMAGE_FLAGS, shouldPredict, true, false )
	weapon.SetWeaponChargeFractionForced( 1.0 ) // this will end the pod sequence immediately
    if ( projectile )
    {
		projectile.kv.gravity = 0.1
		projectile.SetVelocity( attackParams.dir * 2000 )
        projectile.SetModel( $"models/weapons/grenades/arc_grenade_projectile.mdl" )
        #if SERVER
            projectile.ProjectileSetDamageSourceID( eDamageSourceId.mp_titanweapon_stun_impact )
            thread DelayedFixTrailEffect( projectile )
        #endif
    }

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER
void function HandleDisappearingParent( entity ent, entity parentEnt )
{
	parentEnt.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( ent )
		{
			ent.ClearParent()
		}
	)

	parentEnt.WaitSignal( "StartPhaseShift" )
}
#endif

#if SERVER
void function ImpactStun_OnDamagedTarget( entity victim, var damageInfo )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
    if ( !IsValid( inflictor ) )
        return
    if ( !inflictor.IsProjectile() )
        return

    EMP_DamagedPlayerOrNPC( victim, damageInfo )
}
void function DelayedFixTrailEffect( entity projectile )
{
    WaitFrame()
	if ( IsValid( projectile ) )
	{
		// don't use PlayFXOnEntity(), if the projectile not transmitted to client yet, it will crash
		int particleID = GetParticleSystemIndex( $"wpn_grenade_frag_blue" )
		StartParticleEffectOnEntity( projectile, particleID, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	}
}
#endif

// ChargeBall //

var function OnWeaponPrimaryAttack_weapon_MpTitanWeaponChargeBall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()


	#if SERVER
		if ( weaponOwner.IsPlayer() )
		{
			vector angles = VectorToAngles( weaponOwner.GetViewVector() )
			vector up = AnglesToUp( angles )
			PlayerUsedOffhand( weaponOwner, weapon )

			if ( weaponOwner.GetTitanSoulBeingRodeoed() != null )
				attackParams.pos = attackParams.pos + up * 20
			EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "Weapon_ArcLauncher_Fire_1P" )
		}
	#endif

	bool shouldPredict = weapon.ShouldPredictProjectiles()

	var fireMode = weapon.GetWeaponInfoFileKeyField( "fire_mode" )

	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir

	if ( fireMode == "offhand_instant" )
	{
		// Get missile firing information
		entity owner = weapon.GetWeaponOwner()
		if ( owner.IsPlayer() )
			attackDir = GetVectorFromPositionToCrosshair( owner, attackParams.pos )
	}

	float angleoffset = 0.05

	vector rightVec = AnglesToRight(VectorToAngles(attackDir))

	ChargeBall_FireArcBall( weapon, attackPos, attackDir, shouldPredict, BALL_LIGHTNING_DAMAGE, false, true )
	weapon.EmitWeaponSound_1p3p( "Weapon_ArcLauncher_Fire_1P", "Weapon_ArcLauncher_Fire_3P" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	if( weaponOwner.IsPlayer() )
		EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "Weapon_ArcLauncher_Fire_1P" )

	weapon.SetWeaponPrimaryClipCountAbsolute( 0 )

	return false
}

entity function ChargeBall_FireArcBall( entity weapon, vector pos, vector dir, bool shouldPredict, float damage = BALL_LIGHTNING_DAMAGE, bool isCharged = false, bool forceVisualFix = false )
{
	entity owner = weapon.GetWeaponOwner()

	float speed = 400.0

	if ( owner.IsPlayer() )
	{
		vector myVelocity = owner.GetVelocity()

		float mySpeed = Length( myVelocity )

		myVelocity = Normalize( myVelocity )

		float dotProduct = DotProduct( myVelocity, dir )

		dotProduct = max( 0, dotProduct )

		speed = speed + ( mySpeed*dotProduct )
	}

	int team = TEAM_UNASSIGNED
	if ( IsValid( owner ) )
		team = owner.GetTeam()

	entity projectile = weapon.FireWeaponMissile( pos, dir, speed, damageTypes.arcCannon | DF_IMPACT, damageTypes.arcCannon | DF_IMPACT, false, shouldPredict )
	if ( projectile )
    {
		projectile.kv.gravity = 0
		projectile.kv.rendercolor = "0 0 0"
		projectile.kv.renderamt = 0
		projectile.kv.fadedist = 1
		projectile.kv.lifetime = 16.0
		//projectile.SetVelocity( dir * speed )
		projectile.SetModel( $"models/dev/empty_model.mdl" )
		SetTeam( projectile, team )


		ChargeBall_AttachBallLightning( weapon, projectile )
		entity ballLightning = expect entity( projectile.s.ballLightning )
		ballLightning.e.ballLightningData.damage = damage
		thread DelayedStartParticleSystem( projectile )
	}

	return projectile
}

// trail fix
#if SERVER
void function DelayedStartParticleSystem( entity bolt )
{
    WaitFrame()
    if( IsValid( bolt ) )
	{
        StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"P_wpn_arcball_trail" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		EmitSoundOnEntity( bolt, "weapon_arc_ball_loop" )
	}
}
#endif

function ChargeBall_AttachBallLightning( entity weapon, entity projectile )
{
	Assert( !( "ballLightning" in projectile.s ) )

	entity owner

	if ( weapon.IsProjectile() )
		owner = weapon.GetOwner()
	else
		owner = weapon.GetWeaponOwner()

	entity ball = ChargeBall_CreateBallLightning( owner, projectile.GetOrigin(), projectile.GetAngles() )
	ball.SetParent( projectile )
	projectile.s.ballLightning <- ball
}

entity function ChargeBall_CreateBallLightning( entity owner, vector origin, vector angles )
{
	entity ballLightning = CreateScriptMover( origin, angles )
	ballLightning.SetOwner( owner )
	SetTeam( ballLightning, owner.GetTeam() )

	thread ChargeBall_BallLightningThink( ballLightning )
	thread ChargeBall_ZapFxToOwner( ballLightning, owner )
	return ballLightning
}

void function ChargeBall_ZapFxToOwner( entity ballLightning, entity owner )
{
	ballLightning.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "TitanEjectionStarted" )
	owner.EndSignal( "DisembarkingTitan" )


	for( ;; )
	{
		WaitFrame()

		string tag = "center"
		if ( IsHumanSized( owner ) )
			tag = "CHESTFOCUS"
		else if ( owner.IsTitan() )
			tag = "HIJACK"
		else if ( IsSuperSpectre( owner ) || IsAirDrone( owner ) )
			tag = "CHESTFOCUS"
		else if ( IsDropship( owner ) )
			tag = "ORIGIN"
		else if ( owner.GetClassName() == "npc_turret_mega" )
			tag = "ATTACH"

		if( !owner.IsTitan() )
			return

		thread BallLightningZapConnectionFX( ballLightning, owner, tag, ballLightning.e.ballLightningData )
		thread BallLightningZapFX( ballLightning, owner, tag, ballLightning.e.ballLightningData )
	}
}

void function ChargeBall_BallLightningThink( entity ballLightning )
{
	ballLightning.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( ballLightning, "Weapon_Arc_Ball_Loop" )

	OnThreadEnd(
		function() : ( ballLightning )
		{
			if ( IsValid( ballLightning ) )
				StopSoundOnEntity( ballLightning, "Weapon_Arc_Ball_Loop" )
		}
	)

	int inflictorTeam = ballLightning.GetTeam()
	ballLightning.e.ballLightningTargetsIdx = CreateScriptManagedEntArray()

	WaitEndFrame()

	while( 1 )
	{
		for( int i=0; i<BALL_LIGHTNING_BURST_NUM; i++ )
		{
			vector origin = ballLightning.GetOrigin()
			BallLightningData fxData = ballLightning.e.ballLightningData
			RadiusDamage(
		    	origin,							// origin
		    	ballLightning.GetOwner(),		// owner
		    	ballLightning,		 			// inflictor
		    	fxData.damageToPilots,			// normal damage
		    	fxData.damage,					// heavy armor damage
		    	fxData.radius,							// inner radius
		    	fxData.radius,							// outer radius
		    	SF_ENVEXPLOSION_NO_DAMAGEOWNER,	// explosion flags
		    	0, 								// distanceFromAttacker
		    	0, 								// explosionForce
		    	fxData.deathPackage,			// damage flags
		    	eDamageSourceId.mp_titanweapon_charge_ball					// damage source id
			)
		}
		wait BALL_LIGHTNING_BURST_DELAY
	}
}

void function ChargeBall_OnDamagedTarget( entity target, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if( !IsValid( attacker ) && !IsValid( target ) )
		return
	if( attacker.GetTeam() == target.GetTeam() || !attacker.IsTitan() || attacker == target || target.GetArmorType() != ARMOR_TYPE_HEAVY )
		return
	entity soul = attacker.GetTitanSoul()
	if( !IsValid( soul ) )
		return

	int shieldRestoreAmount = 250
	soul.SetShieldHealth( min( soul.GetShieldHealth() + shieldRestoreAmount, soul.GetShieldHealthMax() ) )
	if( !attacker.IsPlayer() )
		return
	MessageToPlayer( attacker, eEventNotifications.VANGUARD_ShieldGain, attacker )
}

void function DumbfireRocket_OnDamagedTarget( entity target, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if( !inflictor.IsProjectile() )
		return

	if( Vortex_GetRefiredProjectileMods( inflictor ).contains( "charge_ball" ) )
	{
		DamageInfo_SetDamageSourceIdentifier( damageInfo, eDamageSourceId.mp_titanweapon_charge_ball )
		DamageInfo_SetCustomDamageType( damageInfo, DF_DISSOLVE | DF_GIB | DF_ELECTRICAL | DF_STOPS_TITAN_REGEN )
		ChargeBall_OnDamagedTarget( target, damageInfo )
	}
}