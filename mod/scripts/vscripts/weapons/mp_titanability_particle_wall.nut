untyped

global function MpTitanabilityBubbleShield_Init

global function OnWeaponPrimaryAttack_particle_wall

#if SERVER
global function OnWeaponNpcPrimaryAttack_particle_wall
#endif // #if SERVER

global function Brute4TitanHasBubbleShieldWeapon
global function Brute4LetTitanPlayerShootThroughBubbleShield
global function CreateParentedBrute4BubbleShield

global function DestroyBrute4BubbleShield
global function CreateBrute4BubbleShieldWithSettings
global function Brute4StopPlayerShootThroughBubbleShield
global function Brute4MonitorLastFireTime
//global function Brute4BubbleShieldSpeedLimit


global function OnWeaponPrimaryAttack_dome_shield

#if SERVER
global function OnWeaponNpcPrimaryAttack_dome_shield
#endif // #if SERVER


global const SP_PARTICLE_WALL_DURATION = 8.0
global const MP_PARTICLE_WALL_DURATION = 6.0

global const BRUTE4_DOME_SHIELD_HEALTH = 1500	//2500
global const PAS_DOME_SHIELD_HEALTH = 2000
global const BRUTE4_DOME_SHIELD_MELEE_MOD = 2.5

function MpTitanabilityBubbleShield_Init()
{
	RegisterSignal( "RegenAmmo" )
	RegisterSignal( "KillBruteShield" )

    #if CLIENT
	    PrecacheHUDMaterial( $"vgui/hud/dpad_bubble_shield_charge_0" )
	    PrecacheHUDMaterial( $"vgui/hud/dpad_bubble_shield_charge_1" )
	    PrecacheHUDMaterial( $"vgui/hud/dpad_bubble_shield_charge_2" )
    #endif
}

var function OnWeaponPrimaryAttack_particle_wall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

#if SERVER
    if( weapon.HasMod( "brute4_bubble_shield" ) )
    {
        OnWeaponPrimaryAttack_dome_shield( weapon, attackParams )
        return weapon.GetWeaponInfoFileKeyField( "ammo_per_shot" )
    }
	if( weapon.HasMod( "tcp_parent_shield" ) )
	{
		thread TitanPersonalShield_Threaded( weaponOwner, 2500, 8 )
		return weapon.GetWeaponInfoFileKeyField( "ammo_per_shot" )
	}
	if( weapon.HasMod( "tcp_color_shield" ) )
	{
		thread CreateColorBubbleShield( weaponOwner.GetTeam(), weaponOwner.GetOrigin(), weaponOwner.GetAngles(), 6 )
		return weapon.GetWeaponInfoFileKeyField( "ammo_per_shot" )
	}
	float duration
	if ( IsSingleplayer() )
		duration = SP_PARTICLE_WALL_DURATION
	else
		duration = MP_PARTICLE_WALL_DURATION

	CreateParticleWallFromOwner( weapon.GetWeaponOwner(), duration, attackParams )
#endif
	return weapon.GetWeaponInfoFileKeyField( "ammo_per_shot" )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_particle_wall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
    if( weapon.HasMod( "brute4_bubble_shield" ) )
    {
		OnWeaponNpcPrimaryAttack_dome_shield( weapon, attackParams )
        return weapon.GetWeaponInfoFileKeyField( "ammo_per_shot" )
    }
	float duration
	if ( IsSingleplayer() )
		duration = SP_PARTICLE_WALL_DURATION
	else
		duration = MP_PARTICLE_WALL_DURATION
	CreateParticleWallFromOwner( weapon.GetWeaponOwner(), duration, attackParams )
	return weapon.GetWeaponInfoFileKeyField( "ammo_per_shot" )
}
#endif // #if SERVER


void function CreateColorBubbleShield( int team, vector origin, vector angles, float duration = 9999.0 )
{
	entity bubbleShield = CreateColorBubbleShieldWithSettings( team, origin, angles, null, 9999 )
	entity friendlyColoredFX = expect entity ( bubbleShield.s.friendlyColoredFX )
	entity enemyColoredFX = expect entity ( bubbleShield.s.enemyColoredFX )
	friendlyColoredFX.SetAngles( angles )
	enemyColoredFX.SetAngles( angles )

	OnThreadEnd(
		function () : ( bubbleShield )
		{
			DestroyBubbleShield( bubbleShield )
		}
	)

	float endTime = duration + Time()
	int rgb = RandomInt( 30 ) + 1
	vector color = < 0, 0, 0 >
	int rgb1 = 0
	int rgb2 = 0
	int rgb3 = 0
	while( endTime > Time() )
	{
		WaitFrame()
		if( rgb / 5 == 0 )
		{
			rgb1 = rgb
			rgb2 = rgb1 * 50
			rgb3 = 250 - rgb2
			color = < 250, rgb2, 0 >
		}
		else if( rgb / 5 == 1 )
		{
			rgb1 = rgb - 5
			rgb2 = rgb1 * 50
			rgb3 = 250 - rgb2
			color = < rgb3, 250, 0 >
		}
		else if( rgb / 5 == 2 )
		{
			rgb1 = rgb - 10
			rgb2 = rgb1 * 50
			rgb3 = 250 - rgb2
			color = < 0, 250, rgb2 >
		}
		else if( rgb / 5 == 3 )
		{
			rgb1 = rgb - 15
			rgb2 = rgb1 * 50
			rgb3 = 250 - rgb2
			color = < 0, rgb3, 250 >
		}
		else if( rgb / 5 == 4 )
		{
			rgb1 = rgb - 20
			rgb2 = rgb1 * 50
			rgb3 = 250 - rgb2
			color = < rgb2, 0, 250 >
		}
		else
		{
			rgb1 = rgb - 25
			rgb2 = rgb1 * 50
			rgb3 = 250 - rgb2
			color = < 250, 0, rgb3 >
		}

		if( rgb + 1 > 30 )
			rgb = 0
		rgb += 1

		//SendHudMessageToAll( "debuginfo\n"+rgb+"\n"+rgb/10+"\n"+rgb1+"\n"+rgb2+"\nend", -1, 0.3, 200, 200, 225, 0, 0, 5, 1);


		EffectSetControlPointVector( friendlyColoredFX, 1, color )
		EffectSetControlPointVector( enemyColoredFX, 1, color )
	}
}

entity function CreateColorBubbleShieldWithSettings( int team, vector origin, vector angles, entity owner = null, float duration = 9999 )
{
	entity bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.SetValueForModelKey( $"models/fx/xo_shield.mdl" )
	bubbleShield.kv.solid = SOLID_VPHYSICS
	bubbleShield.kv.rendercolor = "81 130 151"
	bubbleShield.kv.contents = (int(bubbleShield.kv.contents) | CONTENTS_NOGRAPPLE)
	bubbleShield.SetOrigin( origin )
	bubbleShield.SetAngles( angles )
	 // Blocks bullets, projectiles but not players and not AI
	bubbleShield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	bubbleShield.SetBlocksRadiusDamage( true )
	DispatchSpawn( bubbleShield )
	bubbleShield.Hide()

	SetTeam( bubbleShield, team )
	array<entity> bubbleShieldFXs

	vector coloredFXOrigin = origin + Vector( 0, 0, 25 )
	table bubbleShieldDotS = expect table( bubbleShield.s )
	if ( team == TEAM_UNASSIGNED )
	{
		entity neutralColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
		SetTeam( neutralColoredFX, team )
		bubbleShieldDotS.neutralColoredFX <- neutralColoredFX
		bubbleShieldFXs.append( neutralColoredFX )
	}
	else
	{
		//Create friendly and enemy colored particle systems
		entity friendlyColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
		SetTeam( friendlyColoredFX, team )
		friendlyColoredFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
		EffectSetControlPointVector(  friendlyColoredFX, 1, FRIENDLY_COLOR_FX )

		entity enemyColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
		SetTeam( enemyColoredFX, team )
		enemyColoredFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
		EffectSetControlPointVector(  enemyColoredFX, 1, ENEMY_COLOR_FX )

		bubbleShieldDotS.friendlyColoredFX <- friendlyColoredFX
		bubbleShieldDotS.enemyColoredFX <- enemyColoredFX
		bubbleShieldFXs.append( friendlyColoredFX )
		bubbleShieldFXs.append( enemyColoredFX )
	}

	#if MP
	DisableTitanfallForLifetimeOfEntityNearOrigin( bubbleShield, origin, TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS )
	#endif

	EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )

	thread CleanupBubbleShield( bubbleShield, bubbleShieldFXs, duration )

	return bubbleShield
}

void function CleanupBubbleShield( entity bubbleShield, array<entity> bubbleShieldFXs, float fadeTime )
{
	bubbleShield.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( bubbleShield, bubbleShieldFXs )
		{
			if ( IsValid_ThisFrame( bubbleShield ) )
			{
				StopSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( bubbleShield, "BubbleShield_End" )
				DestroyBubbleShield( bubbleShield )
			}

			foreach ( fx in bubbleShieldFXs )
			{
				if ( IsValid_ThisFrame( fx ) )
				{
					EffectStop( fx )
				}
			}
		}
	)

	wait fadeTime
}

void function TitanPersonalShield_Threaded( entity owner, int vortexHealth, float duration )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "DisembarkingTitan" )
	owner.EndSignal( "TitanEjectionStarted" )


	if ( duration <= 0 )
		return
	//------------------------------
	// Shield vars
	//------------------------------
	vector origin = owner.GetOrigin()
	vector angles = VectorToAngles( owner.GetPlayerOrNPCViewVector() )
	angles.x = 0
	angles.z = 0

	float shieldWallRadius = SHIELD_WALL_RADIUS // 90
	asset shieldFx = SHIELD_WALL_FX
	float wallFOV = SHIELD_WALL_FOV
	float shieldWallHeight = SHIELD_WALL_RADIUS * 2

	//------------------------------
	// Vortex to block the actual bullets
	//------------------------------
	entity vortexSphere = CreateShieldWithSettings( origin + < 0, 0, -64 >, angles, SHIELD_WALL_RADIUS, SHIELD_WALL_RADIUS * 2, SHIELD_WALL_FOV, duration, vortexHealth, SHIELD_WALL_FX )
	thread DrainHealthOverTime( vortexSphere, vortexSphere.e.shieldWallFX, duration )

	//vortexSphere.SetAngles( angles ) // viewvec?
	//vortexSphere.SetOrigin( origin + Vector( 0, 0, shieldWallRadius - 64 ) )

	// update fx origin
	//vortexSphere.e.shieldWallFX.SetOrigin( Vector( 0, 0, shieldWallHeight ) )

	//-----------------------
	// Attach shield to owner
	//------------------------
	entity mover = CreateScriptMover()
	mover.SetOrigin( origin )
	mover.SetAngles( angles )

	vortexSphere.SetParent( mover )

	vortexSphere.EndSignal( "OnDestroy" )
	Assert( IsAlive( owner ) )
	owner.EndSignal( "ArcStunned" )
	mover.EndSignal( "OnDestroy" )
	#if MP
	vortexSphere.e.shieldWallFX.EndSignal( "OnDestroy" )
	#endif

	OnThreadEnd(
	function() : ( owner, mover, vortexSphere )
		{
			if ( IsValid( owner ) )
			{
				owner.kv.defenseActive = false
			}

			StopShieldWallFX( vortexSphere )

			if ( IsValid( vortexSphere ) )
				vortexSphere.Destroy()

			if ( IsValid( mover ) )
			{
				//PlayFX( SHIELD_BREAK_FX, mover.GetOrigin(), mover.GetAngles() )
				mover.Destroy()
			}
		}
	)

	owner.kv.defenseActive = true

	for ( ;; )
	{
		Assert( IsAlive( owner ) )
		UpdateShieldPosition( mover, owner )

		#if MP
		if ( IsCloaked( owner ) )
			EntFireByHandle( vortexSphere.e.shieldWallFX, "Stop", "", 0, null, null )
		else
			EntFireByHandle( vortexSphere.e.shieldWallFX, "Start", "", 0, null, null )
		#endif
	}
}

void function ShieldDestroyAfterTime( entity vortexSphere, entity owner, float delay )
{
	wait delay
	if( !IsValid(owner) )
		return
	if( !IsValid(vortexSphere) )
		return
	vortexSphere.SetHealth( 0 )
}

void function UpdateShieldPosition( entity mover, entity owner )
{
	mover.NonPhysicsMoveTo( owner.GetOrigin(), 0.2, 0.0, 0.0 )

	WaitFrame()
}

const vector BRUTE4_DOME_COLOR_PAS_MOLTING_SHELL = <92, 92, 200>
const vector BRUTE4_DOME_COLOR_CHARGE_FULL		 = <92, 92, 200>    //<92, 155, 200>	// blue
const vector BRUTE4_DOME_COLOR_CHARGE_MED		 = <255, 128, 80>	// orange
const vector BRUTE4_DOME_COLOR_CHARGE_EMPTY		 = <255, 80, 80>	// red

const float BRUTE4_DOME_COLOR_CROSSOVERFRAC_FULL2MED	= 0.75  // from zero to this fraction, fade between full and medium charge colors
const float BRUTE4_DOME_COLOR_CROSSOVERFRAC_MED2EMPTY	= 0.95  // from "full2med" to this fraction, fade between medium and empty charge colors


struct BubbleShieldDamageStruct
{
	float damageFloor
	float damageCeiling
	array<float> quadraticPolynomialCoefficients //Should actually be float[3], but because float[ 3 ] and array<float> are different types and this needs to be fed into EvaluatePolynomial make it an array<float> instead
}

void function CreateParentedBrute4BubbleShield( entity titan, vector origin, vector angles, float duration = 10 )
{
	if ( !IsAlive( titan ) )
		return

	entity soul = titan.GetTitanSoul()
	soul.Signal( "NewBubbleShield" )

#if SERVER
	bool shouldAmpDome = false
	entity shieldWeapon
	foreach( entity offhand in titan.GetOffhandWeapons() )
	{
		if( offhand.GetWeaponClassName() == "mp_titanability_particle_wall" )
		{
			if( offhand.HasMod( "brute4_bubble_shield" ) )
				shieldWeapon = offhand
		}
	}
	if( IsValid( shieldWeapon ) )
	{
		if ( shieldWeapon.HasMod( "bison_dome" ) )
			shouldAmpDome = true
	}

	entity bubbleShield = CreateBrute4BubbleShieldWithSettings( titan.GetTeam(), origin, angles, titan, duration, shouldAmpDome )

	soul.soul.bubbleShield = bubbleShield
	if ( titan.IsPlayer() )
		SyncedMelee_Disable( titan )

	// Normally, Dome Shield prevents the user from taking damage. We allow all damage to occur and use a callback to make sure only the damage we want goes through.
	AddEntityCallback_OnDamaged( titan, Brute4BubbleShield_OwnerTakeSpecialDamage )

	table bubbleShieldDotS = expect table( soul.soul.bubbleShield.s )
	bubbleShieldDotS.moltingShell <- false
	if( IsValid( shieldWeapon ) )
	{
		if ( shieldWeapon.HasMod( "molting_dome" ) )
			bubbleShieldDotS.moltingShell <- true
	}

	soul.soul.bubbleShield.SetParent( titan, "ORIGIN" )
	entity vortexColoredFX = expect entity (bubbleShieldDotS.vortexColoredFX )
	vortexColoredFX.SetParent( soul.soul.bubbleShield )

	// Update color here since the function that updates it waits a frame before its first iteration
	Brute4BubbleShield_ColorUpdate( bubbleShield, vortexColoredFX )
	thread WaitForCleanup(titan, soul, bubbleShield, duration)
#endif
}

void function WaitForCleanup(entity titan, entity soul, entity bubbleShield, float duration)
{
	bubbleShield.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnTitanDeath" )
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "TitanBrokeBubbleShield" )

	OnThreadEnd(
		function () : ( titan, soul, bubbleShield )
		{
			CleanupTitanBubbleShieldVars( titan, soul, bubbleShield )
		}
	)
	wait duration
}

void function CleanupTitanBubbleShieldVars( entity titan, entity soul, entity bubbleShield )
{
	DestroyBrute4BubbleShield( bubbleShield )
#if SERVER
	if( IsValid( titan ) )
	{
		if ( titan.IsPlayer() )
			SyncedMelee_Enable( titan )
		RemoveEntityCallback_OnDamaged( titan, Brute4BubbleShield_OwnerTakeSpecialDamage )
	}
	if ( IsValid( soul ) )
		soul.soul.bubbleShield = null
#endif
}

void function DestroyBrute4BubbleShield( entity bubbleShield )
{
	if ( IsValid( bubbleShield ) )
	{
#if SERVER
		ClearChildren( bubbleShield )
		bubbleShield.Destroy()
#endif
	}
}

entity function CreateBrute4BubbleShieldWithSettings( int team, vector origin, vector angles, entity owner = null, float duration = 10, bool isAmpedDome = false )
{
#if SERVER
	int health = BRUTE4_DOME_SHIELD_HEALTH
	if( isAmpedDome )
		health = PAS_DOME_SHIELD_HEALTH
	entity bubbleShield = CreatePropScript( $"models/fx/xo_shield.mdl", origin, angles, SOLID_VPHYSICS )
  	bubbleShield.kv.rendercolor = "81 130 151"
   	bubbleShield.kv.contents = (int(bubbleShield.kv.contents) | CONTENTS_NOGRAPPLE)
	 // Blocks bullets, projectiles but not players and not AI
	bubbleShield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	bubbleShield.SetMaxHealth( health )
	bubbleShield.SetHealth( health )
	bubbleShield.SetTakeDamageType( DAMAGE_YES )
	bubbleShield.SetBlocksRadiusDamage( false )
	bubbleShield.SetArmorType( ARMOR_TYPE_HEAVY )
	bubbleShield.SetDamageNotifications( true )
	bubbleShield.SetDeathNotifications( true )
	bubbleShield.Hide()

	SetObjectCanBeMeleed( bubbleShield, true )
	SetVisibleEntitiesInConeQueriableEnabled( bubbleShield, true ) // Needed for melee to see it
	SetCustomSmartAmmoTarget( bubbleShield, false )

	SetTeam( bubbleShield, team )
	AddEntityCallback_OnDamaged( bubbleShield, Brute4BubbleShield_HandleDamage )

	array<entity> bubbleShieldFXs

	vector coloredFXOrigin = origin + Vector( 0, 0, 25 )
	table bubbleShieldDotS = expect table( bubbleShield.s )

	entity vortexColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
	bubbleShieldDotS.vortexColoredFX <- vortexColoredFX
	bubbleShieldFXs.append( vortexColoredFX )

	#if MP
	DisableTitanfallForLifetimeOfEntityNearOrigin( bubbleShield, origin, TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS )
	#endif

	EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )

	bool shouldDrainHealth = true
	if( isAmpedDome )
		shouldDrainHealth = false

	thread DrainBubbleShield( bubbleShield, bubbleShieldFXs, 999, vortexColoredFX, shouldDrainHealth )

	return bubbleShield
#endif
}

#if SERVER
void function Brute4BubbleShield_ColorUpdate( entity bubbleShield, entity colorFXHandle = null )
{
	table bubbleShieldDotS = expect table( bubbleShield.s )
	if ( bubbleShieldDotS.moltingShell )
		EffectSetControlPointVector( colorFXHandle, 1, GetDomeCurrentColor( 1.0 - GetHealthFrac( bubbleShield ), BRUTE4_DOME_COLOR_PAS_MOLTING_SHELL ) )
	else
		EffectSetControlPointVector( colorFXHandle, 1, GetDomeCurrentColor( 1.0 - GetHealthFrac( bubbleShield ) ) )
}

void function Brute4BubbleShield_OwnerTakeSpecialDamage( entity owner, var damageInfo )
{
	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	int passFlags = DF_RODEO | DF_DOOMED_HEALTH_LOSS | DF_BYPASS_SHIELD
	if ( damageFlags & passFlags )
		return

	// If melees hit the user, we want to pass the damage to dome shield
	if ( damageFlags & DF_MELEE )
	{
		entity bubbleShield = owner.GetTitanSoul().soul.bubbleShield
		if( IsValid( bubbleShield ) )
		{
			entity attacker = DamageInfo_GetAttacker( damageInfo )
			table damageTable =
			{
				scriptType = damageFlags
				forceKill = false
				damageType = DamageInfo_GetDamageType( damageInfo )
				damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
				origin = DamageInfo_GetDamagePosition( damageInfo )
			}

			bubbleShield.TakeDamage( DamageInfo_GetDamage( damageInfo ), attacker, attacker, damageTable )
		}
	}

	DamageInfo_SetDamage( damageInfo, 0 )
}

void function Brute4BubbleShield_HandleDamage( entity bubbleShield, var damageInfo )
{
	if( DamageInfo_GetCustomDamageType( damageInfo ) & DF_MELEE )
		DamageInfo_ScaleDamage( damageInfo, BRUTE4_DOME_SHIELD_MELEE_MOD )

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( bubbleShield.GetTeam() != attacker.GetTeam() && attacker.IsPlayer() )
		attacker.NotifyDidDamage( bubbleShield, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
}
#endif

void function DrainBubbleShield( entity bubbleShield, array<entity> bubbleShieldFXs, float fadeTime, entity colorFXHandle = null, bool drainHealth = true )
{
#if SERVER
	bubbleShield.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( bubbleShield, bubbleShieldFXs )
		{
			if ( IsValid_ThisFrame( bubbleShield ) )
			{
				StopSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( bubbleShield, "BubbleShield_End" )
				DestroyBrute4BubbleShield( bubbleShield )
			}

			foreach ( fx in bubbleShieldFXs )
			{
				if ( IsValid_ThisFrame( fx ) )
				{
					EffectStop( fx )
				}
			}
		}
	)

	if( !drainHealth )
	{
		float lastTime = Time()
		while(true)
		{
			WaitFrame()
			if ( colorFXHandle != null )
				Brute4BubbleShield_ColorUpdate( bubbleShield, colorFXHandle )
			lastTime = Time()
		}
	}
	else
	{
		float healthPerSec = bubbleShield.GetMaxHealth() / fadeTime
		float lastTime = Time()
		while(true)
		{
			WaitFrame()
			bubbleShield.SetHealth( bubbleShield.GetHealth() - healthPerSec * ( Time() - lastTime ) )
			if ( colorFXHandle != null )
				Brute4BubbleShield_ColorUpdate( bubbleShield, colorFXHandle )
			lastTime = Time()
		}
	}
#endif
}

void function Brute4LetTitanPlayerShootThroughBubbleShield( entity titanPlayer, entity weapon )
{
#if SERVER
	Assert( titanPlayer.IsTitan() )

	entity soul = titanPlayer.GetTitanSoul()

	entity bubbleShield = soul.soul.bubbleShield


	if ( !IsValid( bubbleShield ) )
		return

	bubbleShield.SetOwner( titanPlayer ) //After this, player is able to fire out from shield. WATCH OUT FOR POTENTIAL COLLISION BUGS!

	if ( titanPlayer.IsPlayer() )
		thread Brute4MonitorMovement( titanPlayer, bubbleShield )
	thread Brute4MonitorLastFireTime( weapon, titanPlayer, bubbleShield )
	thread Brute4StopPlayerShootThroughBubbleShield( titanPlayer, bubbleShield )
#endif
}

void function Brute4StopPlayerShootThroughBubbleShield( entity player, entity bubbleShield )
{
#if SERVER
	player.EndSignal( "OnDeath" )
	bubbleShield.EndSignal("OnDestroy")
	player.WaitSignal( "OnChangedPlayerClass" ) //Kill this thread once player gets out of the Titan

	if ( !IsValid( bubbleShield ) )
		return

	bubbleShield.SetOwner( null )
#endif
}

void function Brute4MonitorLastFireTime( entity weapon, entity player, entity bubbleShield )
{
#if SERVER
	player.EndSignal( "OnDestroy" )
	bubbleShield.EndSignal("OnDestroy")
	entity soul = player.GetTitanSoul()

	WaitSignal( player, "DisembarkingTitan", "OnSyncedMelee", "KillBruteShield" ) //Sent when player fires his weapon/disembarks

	if ( !IsValid( soul ) )
		return

	soul.Signal( "TitanBrokeBubbleShield" ) //WaitUntilShieldFades will end when this signal is sent
#endif
}

void function Brute4MonitorMovement( entity player, entity bubbleShield )
{
	#if SERVER
	player.EndSignal( "OnDestroy" )
	bubbleShield.EndSignal("OnDestroy")

	float lastDodgePower = player.GetDodgePower()
	while( player.GetDodgePower() >= lastDodgePower )
	{
		lastDodgePower = player.GetDodgePower()
		WaitFrame()
	}

	entity soul = player.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	soul.Signal( "TitanBrokeBubbleShield" ) //WaitUntilShieldFades will end when this signal is sent
#endif
}

bool function Brute4TitanHasBubbleShieldWeapon( entity titan )
{
#if SERVER
	entity weapon = titan.GetActiveWeapon()
	if ( IsValid( weapon ) && IsValid( weapon.w.bubbleShield ) )
		return true
#endif
	return false
}

vector function GetDomeCurrentColor( float chargeFrac, vector fullHealthColor = BRUTE4_DOME_COLOR_CHARGE_FULL )
{
	return GetTriLerpColor( chargeFrac, fullHealthColor, BRUTE4_DOME_COLOR_CHARGE_MED, BRUTE4_DOME_COLOR_CHARGE_EMPTY )
}

// Copied from vortex, since it's not a global func
vector function GetTriLerpColor( float fraction, vector color1, vector color2, vector color3 )
{
	float crossover1 = BRUTE4_DOME_COLOR_CROSSOVERFRAC_FULL2MED  // from zero to this fraction, fade between color1 and color2
	float crossover2 = BRUTE4_DOME_COLOR_CROSSOVERFRAC_MED2EMPTY // from crossover1 to this fraction, fade between color2 and color3

	float r, g, b

	// 0 = full charge, 1 = no charge remaining
	if ( fraction < crossover1 )
	{
		r = Graph( fraction, 0, crossover1, color1.x, color2.x )
		g = Graph( fraction, 0, crossover1, color1.y, color2.y )
		b = Graph( fraction, 0, crossover1, color1.z, color2.z )
		return <r, g, b>
	}
	else if ( fraction < crossover2 )
	{
		r = Graph( fraction, crossover1, crossover2, color2.x, color3.x )
		g = Graph( fraction, crossover1, crossover2, color2.y, color3.y )
		b = Graph( fraction, crossover1, crossover2, color2.z, color3.z )
		return <r, g, b>
	}
	else
	{
		// for the last bit of overload timer, keep it max danger color
		r = color3.x
		g = color3.y
		b = color3.z
		return <r, g, b>
	}

	unreachable
}

const float BRUTE4_MOLTING_SHELL_MAX_REFUND = 2.0 // seconds

var function OnWeaponPrimaryAttack_dome_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	#if SERVER
	entity soul = weaponOwner.GetTitanSoul()

	if( weaponOwner.IsPlayer() && IsValid( soul )  && IsValid( soul.soul.bubbleShield ))
		return 0
	#endif //SERVER

	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	float duration = 6
	thread Brute4GiveShortDomeShield( weapon, weaponOwner, duration )

	return 1
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_dome_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	entity soul = weaponOwner.GetTitanSoul()
	if ( IsValid( soul ) && IsValid( soul.soul.bubbleShield ))
		return 0

	float duration = 6
	thread Brute4GiveShortDomeShield( weapon, weaponOwner, duration )

	return 1
}
#endif // #if SERVER

void function Brute4GiveShortDomeShield( entity weapon, entity owner, float duration = 6.0 )
{
	#if SERVER
	owner.EndSignal( "OnDeath" )

	entity soul = owner.GetTitanSoul()
	if ( soul == null )
		return

	soul.EndSignal( "OnTitanDeath" )
	soul.EndSignal( "OnDestroy" )

	// Prevents the owner from sprinting
	int slowID = StatusEffect_AddTimed( owner, eStatusEffect.move_slow, 0.5, duration, 0 )
	int speedID = StatusEffect_AddTimed( owner, eStatusEffect.speed_boost, 0.5, duration, 0 )
	Brute4DomeShield_AllowNPCWeapons( owner, false )

	CreateParentedBrute4BubbleShield( owner, owner.GetOrigin(), owner.GetAngles(), duration )

	soul.EndSignal( "TitanBrokeBubbleShield" )
	entity bubbleShield = soul.soul.bubbleShield
	bubbleShield.EndSignal( "OnDestroy" )

	bool rechargeDash = weapon.HasMod( "molting_dome" )
	if ( rechargeDash )
	{
		owner.s.bubbleShieldHealthFrac <- 1.0
		bubbleShield.s.ownerForDisembark <- owner
		AddEntityDestroyedCallback( bubbleShield, Brute4DomeShield_TrackHealth )
	}

	OnThreadEnd(
	function() : ( owner, weapon, rechargeDash, slowID, speedID )
		{
			if ( rechargeDash && IsValid( weapon ) && IsValid( owner ) )
			{
				float fireDuration = 6
				float remainingUseTime = float( weapon.GetWeaponPrimaryClipCount() ) / float( weapon.GetWeaponPrimaryClipCountMax() ) * fireDuration
				float remainingShieldTime = expect float( owner.s.bubbleShieldHealthFrac ) * fireDuration
				int refundAmmo = int( min( BRUTE4_MOLTING_SHELL_MAX_REFUND, remainingShieldTime ) * weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_rate ) )
				thread Brute4DomeShield_RefundDuration( weapon, owner, refundAmmo, remainingUseTime )
			}

			if ( IsValid( owner ) )
			{
				StatusEffect_Stop( owner, slowID )
				StatusEffect_Stop( owner, speedID )
				Brute4DomeShield_AllowNPCWeapons( owner, true )

				if ( owner.IsPlayer() && owner.IsTitan() && rechargeDash )
				{
					float amount = expect float( GetSettingsForPlayer_DodgeTable( owner )["dodgePowerDrain"] )
					owner.Server_SetDodgePower( min( 100.0, owner.GetDodgePower() + amount ) )
				}
			}
		}
	)

	Brute4LetTitanPlayerShootThroughBubbleShield( owner, weapon )

	wait duration
	#endif
}

#if SERVER
function Brute4DomeShield_TrackHealth( bubbleShield )
{
	// Bubble Shield can use GetParent() to get the titan, but this callback runs after soul transfer on disembark.
	// Alternatively, could track the health in the titan soul.
	expect entity( bubbleShield )
	entity owner = expect entity( bubbleShield.s.ownerForDisembark )
	if ( IsValid( owner ) )
		owner.s.bubbleShieldHealthFrac = max( 0, GetHealthFrac( bubbleShield ) )
}

void function Brute4DomeShield_RefundDuration( entity weapon, entity owner, int amount, float delay )
{
	wait delay
	if ( IsValid( weapon ) && IsValid( owner ) && weapon.GetWeaponOwner() == owner )
		weapon.SetWeaponPrimaryClipCountNoRegenReset( min( weapon.GetWeaponPrimaryClipCountMax(), weapon.GetWeaponPrimaryClipCount() + amount ) )
}

void function Brute4DomeShield_AllowNPCWeapons( entity npc, bool unlock = false )
{
	// Prevent NPCs from breaking their bubble shield early
	if ( npc.IsNPC() )
	{
		if ( npc.GetMainWeapons().len() > 0 )
			npc.GetMainWeapons()[0].AllowUse( unlock )

		entity ordnance = npc.GetOffhandWeapon( OFFHAND_RIGHT )
		if ( IsValid( ordnance ) )
			ordnance.AllowUse( unlock )

		entity utility = npc.GetOffhandWeapon( OFFHAND_TITAN_CENTER )
		if ( IsValid( utility ) )
			utility.AllowUse( unlock )
	}
}
#endif