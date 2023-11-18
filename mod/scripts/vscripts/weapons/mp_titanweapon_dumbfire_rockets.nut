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
}

var function OnWeaponPrimaryAttack_titanweapon_multi_cluster( entity weapon, WeaponPrimaryAttackParams attackParams )
{
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
	projectile.kv.gravity = 0.1
	projectile.SetVelocity( attackParams.dir * 2000 )
	weapon.SetWeaponChargeFractionForced( 1.0 ) // this will end the pod sequence immediately
    if ( projectile )
    {
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