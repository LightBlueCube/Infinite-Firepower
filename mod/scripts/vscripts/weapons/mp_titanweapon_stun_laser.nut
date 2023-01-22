untyped
global function MpTitanWeaponStunLaser_Init

global function OnWeaponAttemptOffhandSwitch_titanweapon_stun_laser
global function OnWeaponPrimaryAttack_titanweapon_stun_laser

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanweapon_stun_laser
global function AddStunLaserHealCallback
#endif

const FX_EMP_BODY_HUMAN			= $"P_emp_body_human"
const FX_EMP_BODY_TITAN			= $"P_emp_body_titan"
const FX_SHIELD_GAIN_SCREEN		= $"P_xo_shield_up"
const SHIELD_BODY_FX			= $"P_xo_armor_body_CP"

struct
{
	void functionref(entity,entity,int) stunHealCallback
} file

void function MpTitanWeaponStunLaser_Init()
{

	PrecacheParticleSystem( FX_SHIELD_GAIN_SCREEN )
	PrecacheParticleSystem( SHIELD_BODY_FX )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_stun_laser, StunLaser_DamagedTarget )
	#endif

	#if CLIENT
		AddEventNotificationCallback( eEventNotifications.VANGUARD_ShieldGain, Vanguard_ShieldGain )
	#endif

	PrecacheParticleSystem( $"Weapon_ArcLauncher_Fire_1P" )
	PrecacheParticleSystem( $"Weapon_ArcLauncher_Fire_3P" )
	PrecacheParticleSystem( CHARGEBALL_CHARGE_FX_1P )
	PrecacheParticleSystem( CHARGEBALL_CHARGE_FX_3P )

	PrecacheParticleSystem( $"P_impact_exp_emp_med_air" )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_stun_laser, ChargeBallOnDamage )
		RegisterBallLightningDamage( eDamageSourceId.mp_titanweapon_stun_laser ) // doing check in stun laser damagesourceID
	#endif
}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_stun_laser( entity weapon )
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

var function OnWeaponPrimaryAttack_titanweapon_stun_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if( weapon.HasMod( "charge_ball" ) && weapon.GetWeaponChargeFraction() == 1.0 )
		return OnWeaponPrimaryAttack_weapon_MpTitanWeaponChargeBall( weapon, attackParams )
	if( weapon.HasMod( "charge_ball" ) )
		weapon.s.NotBall <- true
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	#endif

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	if( weapon.HasMod( "tcp_flash" ) )
		weaponOwner.TakeSharedEnergy( max( 0, weaponOwner.GetSharedEnergyCount() / 2 ) )

	ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	weapon.SetWeaponChargeFractionForced(1.0)
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
#if SERVER
var function OnWeaponNPCPrimaryAttack_titanweapon_stun_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_stun_laser( weapon, attackParams )
}

void function StunLaser_DamagedTarget( entity target, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}
	if( target.GetArmorType() != ARMOR_TYPE_HEAVY && attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ).HasMod( "charge_ball" ) )
		return

	if ( attacker.GetTeam() == target.GetTeam() && !( attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ).HasMod("tcp_flash") ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		entity attackerSoul = attacker.GetTitanSoul()
		entity weapon = attacker.GetOffhandWeapon( OFFHAND_LEFT )
		if ( !IsValid( weapon ) )
			return
		bool hasEnergyTransfer = weapon.HasMod( "energy_transfer" ) || weapon.HasMod( "energy_field_energy_transfer" )
		if ( target.IsTitan() && IsValid( attackerSoul ) && hasEnergyTransfer )
		{
			entity soul = target.GetTitanSoul()
			if ( IsValid( soul ) )
			{
				int shieldRestoreAmount = 750
				if ( SoulHasPassive( soul, ePassives.PAS_VANGUARD_SHIELD ) )
					shieldRestoreAmount = int( 1.25 * shieldRestoreAmount )

				float shieldAmount = min( soul.GetShieldHealth() + shieldRestoreAmount, soul.GetShieldHealthMax() )
				shieldRestoreAmount = soul.GetShieldHealthMax() - int( shieldAmount )

				soul.SetShieldHealth( shieldAmount )

				if ( file.stunHealCallback != null && shieldRestoreAmount > 0 )
					file.stunHealCallback( attacker, target, shieldRestoreAmount )
			}
			if ( target.IsPlayer() )
				MessageToPlayer( target, eEventNotifications.VANGUARD_ShieldGain, target )

			if ( attacker.IsPlayer() )
				EmitSoundOnEntityOnlyToPlayer( target, attacker, "EnergySyphon_ShieldGive" )

			float shieldHealthFrac = GetShieldHealthFrac( target )
			if ( shieldHealthFrac < 1.0 )
			{
				int shieldbodyFX = GetParticleSystemIndex( SHIELD_BODY_FX )
				int attachID
				if ( target.IsTitan() )
					attachID = target.LookupAttachment( "exp_torso_main" )
				else
					attachID = target.LookupAttachment( "ref" )

				entity shieldFXEnt = StartParticleEffectOnEntity_ReturnEntity( target, shieldbodyFX, FX_PATTACH_POINT_FOLLOW, attachID )
				EffectSetControlPointVector( shieldFXEnt, 1, < 115, 247, 255 > )
			}
		}
	}
	else if ( target.IsNPC() || target.IsPlayer() )
	{
		if( attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ).HasMod("tcp_flash") && attacker.GetTeam() == target.GetTeam() )
			return
		int shieldRestoreAmount = target.GetArmorType() == ARMOR_TYPE_HEAVY ? 750 : 250
		entity soul = attacker.GetTitanSoul()
		entity weapon = attacker.GetOffhandWeapon( OFFHAND_ORDNANCE )
		if( IsValid( weapon ) && IsValid( soul ))
		{
			if( "NotBall" in weapon.s && weapon.HasMod( "charge_ball" ) )
			{
				if( weapon.s.NotBall )
				{
					shieldRestoreAmount = 2500
				}
				else if( soul.GetShieldHealth() == soul.GetShieldHealthMax() )
				{
					attacker.SetHealth( min( attacker.GetMaxHealth(), attacker.GetHealth() + 100 )  )
					shieldRestoreAmount = 0
				}
				else
				{
					shieldRestoreAmount = 300
				}
			}
		}
		if ( IsValid( soul ) )
		{
			if ( SoulHasPassive( soul, ePassives.PAS_VANGUARD_SHIELD ) )
				shieldRestoreAmount = int( 1.25 * shieldRestoreAmount )
			if( attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ).HasMod("tcp_flash") && ( target.IsPlayer() || ( target.GetClassName() != "npc_titan" && !target.IsNPC() ) ) )
			{
				ScreenFadeToColor( target, 0, 0, 0, 255, 0.1, 2 )
			}
			else
				soul.SetShieldHealth( min( soul.GetShieldHealth() + shieldRestoreAmount, soul.GetShieldHealthMax() ) )
		}
		if ( attacker.IsPlayer() && !( attacker.GetOffhandWeapon( OFFHAND_ORDNANCE ).HasMod("tcp_flash") ) )
			MessageToPlayer( attacker, eEventNotifications.VANGUARD_ShieldGain, attacker )
	}
}

void function AddStunLaserHealCallback( void functionref(entity,entity,int) func )
{
	file.stunHealCallback = func
}
#endif


#if CLIENT
void function Vanguard_ShieldGain( entity attacker, var eventVal )
{
	if ( attacker.IsPlayer() )
	{
		//FlashCockpitHealthGreen()
		EmitSoundOnEntity( attacker, "EnergySyphon_ShieldRecieved"  )
		entity cockpit = attacker.GetCockpit()
		if ( IsValid( cockpit ) )
			StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( FX_SHIELD_GAIN_SCREEN	), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		Rumble_Play( "rumble_titan_battery_pickup", { position = attacker.GetOrigin() } )
	}

}
#endif





const CHARGEBALL_CHARGE_FX_1P = $"wpn_arc_cannon_charge_fp"
const CHARGEBALL_CHARGE_FX_3P = $"wpn_arc_cannon_charge"

const int CHARGEBALL_LIGHTNING_DAMAGE = 250 // uncharged, only fires 1 ball
const int CHARGEBALL_LIGHTNING_DAMAGE_CHARGED = 100
const int CHARGEBALL_LIGHTNING_DAMAGE_CHARGED_MOD = 85

var function OnWeaponPrimaryAttack_weapon_MpTitanWeaponChargeBall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.s.NotBall <- false
	entity weaponOwner = weapon.GetWeaponOwner()


	#if SERVER
		if ( weaponOwner.IsPlayer() )
		{
			vector angles = VectorToAngles( weaponOwner.GetViewVector() )
			vector up = AnglesToUp( angles )
			PlayerUsedOffhand( weaponOwner, weapon )

			if ( weaponOwner.GetTitanSoulBeingRodeoed() != null )
				attackParams.pos = attackParams.pos + up * 20
		}
	#endif

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return
	#endif

	float speed = 200.0

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

	ChargeBall_FireArcBall( weapon, attackPos, attackDir, shouldPredict, CHARGEBALL_LIGHTNING_DAMAGE_CHARGED, false, true )
	weapon.EmitWeaponSound_1p3p( "Weapon_ArcLauncher_Fire_1P", "Weapon_ArcLauncher_Fire_3P" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "Weapon_ArcLauncher_Fire_1P" )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function ChargeBallOnDamage( entity ent, var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	if( !IsValid( weapon ) )
		return
	if( !weapon.HasMod( "charge_ball" ) )
		return
	if( ent.IsNPC() )
		return

	const ARC_TITAN_EMP_DURATION			= 0.35
	const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

	StatusEffect_AddTimed( ent, eStatusEffect.emp, 0.1, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )
}

entity function ChargeBall_FireArcBall( entity weapon, vector pos, vector dir, bool shouldPredict, float damage = BALL_LIGHTNING_DAMAGE, bool isCharged = false, bool forceVisualFix = false )
{
	entity owner = weapon.GetWeaponOwner()

	float speed = 200.0

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

	entity bolt = weapon.FireWeaponBolt( pos, dir, speed, damageTypes.arcCannon | DF_IMPACT, damageTypes.arcCannon | DF_EXPLOSION, shouldPredict, 0 )
	if ( bolt != null )
	{
		bolt.kv.rendercolor = "0 0 0"
		bolt.kv.renderamt = 0
		bolt.kv.fadedist = 1
		bolt.kv.gravity = 5
		SetTeam( bolt, team )

		float lifetime = 12.0

		if ( isCharged )
		{
			bolt.SetProjectilTrailEffectIndex( 1 )
			lifetime = 20.0
		}

		bolt.SetProjectileLifetime( lifetime )

		#if SERVER
			AttachBallLightning( weapon, bolt )

			entity ballLightning = expect entity( bolt.s.ballLightning )

			ballLightning.e.ballLightningData.damage = damage

			// fix for charge balls
			if( forceVisualFix )
				thread DelayedStartParticleSystem( bolt )

			/*{
				// HACK: bolts don't have collision so...
				entity collision = CreateEntity( "prop_script" )

				collision.SetValueForModelKey( ARC_BALL_COLL_MODEL )
				collision.kv.fadedist = -1
				collision.kv.physdamagescale = 0.1
				collision.kv.inertiaScale = 1.0
				collision.kv.renderamt = 255
				collision.kv.rendercolor = "255 255 255"
				collision.kv.rendermode = 10
				collision.kv.solid = SOLID_VPHYSICS
				collision.SetOwner( owner )
				collision.SetOrigin( bolt.GetOrigin() )
				collision.SetAngles( bolt.GetAngles() )
				SetTargetName( collision, "Arc Ball" )
				SetVisibleEntitiesInConeQueriableEnabled( collision, true )

				DispatchSpawn( collision )

				collision.SetParent( bolt )
				collision.SetMaxHealth( 250 )
				collision.SetHealth( 250 )
				AddEntityCallback_OnDamaged( collision, OnArcBallCollDamaged )

				thread TrackCollision( collision, bolt )
			}*/
		#endif
		return bolt
	}
}

// trail fix
#if SERVER
void function DelayedStartParticleSystem( entity bolt )
{
    WaitFrame()
    if( IsValid( bolt ) )
        StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"P_wpn_arcball_trail" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
}
#endif