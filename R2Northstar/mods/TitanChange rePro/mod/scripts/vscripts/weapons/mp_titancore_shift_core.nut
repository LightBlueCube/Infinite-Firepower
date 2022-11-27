global function OnWeaponPrimaryAttack_DoNothing

global function Shift_Core_Init
#if SERVER
global function Shift_Core_UseMeter
#endif

global function OnCoreCharge_Shift_Core
global function OnCoreChargeEnd_Shift_Core
global function OnAbilityStart_Shift_Core

void function Shift_Core_Init()
{
	RegisterSignal( "RestoreWeapon" )
	#if SERVER
	AddCallback_OnPlayerKilled( SwordCore_OnPlayedOrNPCKilled )
	AddCallback_OnNPCKilled( SwordCore_OnPlayedOrNPCKilled )
	#endif
}

#if SERVER
void function SwordCore_OnPlayedOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsTitan() )
		return

	if ( !attacker.IsPlayer() || !PlayerHasPassive( attacker, ePassives.PAS_SHIFT_CORE ) )
		return

	entity soul = attacker.GetTitanSoul()
	if ( !IsValid( soul ) || !SoulHasPassive( soul, ePassives.PAS_RONIN_SWORDCORE ) )
		return

	float curTime = Time()
	float highlanderBonus = 8.0
	float remainingTime = highlanderBonus + soul.GetCoreChargeExpireTime() - curTime
	float duration = soul.GetCoreUseDuration()
	float coreFrac = min( 1.0, remainingTime / duration )
	//Defensive fix for this sometimes resulting in a negative value.
	if ( coreFrac > 0.0 )
	{
		soul.SetTitanSoulNetFloat( "coreExpireFrac", coreFrac )
		soul.SetTitanSoulNetFloatOverTime( "coreExpireFrac", 0.0, remainingTime )
		soul.SetCoreChargeExpireTime( remainingTime + curTime )
	}
}
#endif

var function OnWeaponPrimaryAttack_DoNothing( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

bool function OnCoreCharge_Shift_Core( entity weapon )
{
	if ( !OnAbilityCharge_TitanCore( weapon ) )
		return false

#if SERVER
	entity owner = weapon.GetWeaponOwner()
	string swordCoreSound_1p
	string swordCoreSound_3p
	if ( weapon.HasMod( "fd_duration" ) )
	{
		swordCoreSound_1p = "Titan_Ronin_Sword_Core_Activated_Upgraded_1P"
		swordCoreSound_3p = "Titan_Ronin_Sword_Core_Activated_Upgraded_3P"
	}
	else
	{
		swordCoreSound_1p = "Titan_Ronin_Sword_Core_Activated_1P"
		swordCoreSound_3p = "Titan_Ronin_Sword_Core_Activated_3P"
	}
	if ( owner.IsPlayer() )
	{
		owner.HolsterWeapon() //TODO: Look into rewriting this so it works with HolsterAndDisableWeapons()
		thread RestoreWeapon( owner, weapon )
		EmitSoundOnEntityOnlyToPlayer( owner, owner, swordCoreSound_1p )
		EmitSoundOnEntityExceptToPlayer( owner, owner, swordCoreSound_3p )
	}
	else
	{
		EmitSoundOnEntity( weapon, swordCoreSound_3p )
	}
#endif

	return true
}

void function OnCoreChargeEnd_Shift_Core( entity weapon )
{
	#if SERVER
	entity owner = weapon.GetWeaponOwner()
	OnAbilityChargeEnd_TitanCore( weapon )
	if ( IsValid( owner ) && owner.IsPlayer() )
		owner.DeployWeapon() //TODO: Look into rewriting this so it works with HolsterAndDisableWeapons()
	else if ( !IsValid( owner ) )
		Signal( weapon, "RestoreWeapon" )
	#endif
}

#if SERVER
void function RestoreWeapon( entity owner, entity weapon )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "CoreBegin" )

	WaitSignal( weapon, "RestoreWeapon", "OnDestroy" )

	if ( IsValid( owner ) && owner.IsPlayer() )
	{
		owner.DeployWeapon() //TODO: Look into rewriting this so it works with DeployAndEnableWeapons()
	}
}
#endif

var function OnAbilityStart_Shift_Core( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnAbilityStart_TitanCore( weapon )

	entity owner = weapon.GetWeaponOwner()

	if ( !owner.IsTitan() )
		return 0

	if ( !IsValid( owner ) )
		return

	entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_MELEE )
	if ( !IsValid( offhandWeapon ) )
		return 0

	if ( offhandWeapon.GetWeaponClassName() != "melee_titan_sword" && !weapon.HasMod( "tcp_shield_core" ) && !weapon.HasMod( "tcp_dash_core" ) )
		return 0

#if SERVER
	if ( owner.IsPlayer() )
	{
		owner.Server_SetDodgePower( 100.0 )
		if( weapon.HasMod("tcp_dash_core") )
		{
			owner.SetPowerRegenRateScale( 40 )
			float delay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
			thread Shift_Core_End( weapon, owner, delay )
			return
		}
		else
			owner.SetPowerRegenRateScale( 6.5 )
		GivePassive( owner, ePassives.PAS_FUSION_CORE )
		GivePassive( owner, ePassives.PAS_SHIFT_CORE )
	}

	entity soul = owner.GetTitanSoul()

	if( weapon.HasMod("tcp_shield_core") )
	{
		// JFS the weapon owner should always have a soul, at least on the server
		if ( !IsValid( soul ) )
			return

		vector dir = owner.CameraAngles()
		dir.x = 0
		dir = AnglesToForward( dir )
		vector origin = owner.GetOrigin()
		vector safeSpot = origin
		vector angles = VectorToAngles( dir )

		if ( owner.IsNPC() )
		{
			// spawn in front of npc a bit
			origin += dir * 100
		}

		float duration = 120.0

		float endTime = Time() + duration
		soul.SetDefensivePlacement( endTime, SHIELD_WALL_WIDTH, 0, true, safeSpot, dir )

		int health = 2500
		entity vortexSphere = CreateShieldWithSettings( origin + < 0, 0, -64 >, angles, SHIELD_WALL_RADIUS, SHIELD_WALL_RADIUS * 2, SHIELD_WALL_FOV, duration, health, SHIELD_WALL_FX )
		vortexSphere.SetParent( owner )
		thread ShieldCoreDrainHealthOverTime( vortexSphere,  vortexSphere.e.shieldWallFX, duration, owner )
	}

	if ( soul != null )
	{
		entity titan = soul.GetTitan()

		if ( titan.IsNPC() )
		{
			titan.SetAISettings( "npc_titan_stryder_leadwall_shift_core" )
			titan.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
			titan.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, false )
			AddAnimEvent( titan, "shift_core_use_meter", Shift_Core_UseMeter_NPC )
		}

		titan.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "super_charged" )

		if ( IsSingleplayer() )
		{
			titan.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "super_charged_SP" )
		}

		titan.SetActiveWeaponByName( "melee_titan_sword" )

		entity mainWeapon = titan.GetMainWeapons()[0]
		mainWeapon.AllowUse( false )
	}

	float delay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
	thread Shift_Core_End( weapon, owner, delay )
#endif

	return 1
}

void function ShieldCoreDrainHealthOverTime( entity vortexSphere, entity shieldWallFX, float duration, entity owner )
{
	vortexSphere.EndSignal( "OnDestroy" )
	shieldWallFX.EndSignal( "OnDestroy" )

	float startTime = Time()
	float endTime = startTime + duration

	float tickRate = 0.1
	float dps = vortexSphere.GetMaxHealth() / duration
	float dmgAmount = dps * tickRate

	EmitSoundOnEntity( vortexSphere, "ShieldWall_Loop" )

	float endSoundTime = endTime - 3.0
	bool playedEndSound = false
	vector vortexOrigin = vortexSphere.GetOrigin()

	OnThreadEnd(
		function() : ( vortexSphere, vortexOrigin, endTime )
		{
			if ( endTime - Time() < 1.0 )
				return

			int teamNum = TEAM_UNASSIGNED

			if ( IsValid( vortexSphere ) )
			{
				StopSoundOnEntity( vortexSphere, "ShieldWall_Loop" )
				StopSoundOnEntity( vortexSphere, "ShieldWall_End" )

				teamNum = vortexSphere.GetTeam()
			}

			EmitSoundAtPosition( teamNum, vortexOrigin, "ShieldWall_Destroyed" )
		}
	)

	while ( Time() < endTime )
	{
		if ( Time() > endSoundTime && !playedEndSound )
		{
			EmitSoundOnEntity( vortexSphere, "ShieldWall_End" )
			playedEndSound = true
		}

		//vortexSphere.SetHealth( vortexSphere.GetHealth() - dmgAmount )
		UpdateShieldWallColorForFrac( shieldWallFX, GetHealthFrac( vortexSphere ) )

		if( owner.IsInputCommandHeld( IN_ZOOM ) || owner.IsInputCommandHeld( IN_ZOOM_TOGGLE ) )
		{
			vector dir = owner.CameraAngles()
			dir.x = 0
			dir = AnglesToForward( dir )
			vector origin = owner.GetOrigin()
			vector safeSpot = origin
			vector angles = VectorToAngles( dir )

			if ( owner.IsNPC() )
			{
				// spawn in front of npc a bit
				origin += dir * 100
			}
			entity vortexSphere = CreateShieldWithSettings( origin + < 0, 0, -64 >, angles, SHIELD_WALL_RADIUS, SHIELD_WALL_RADIUS * 2, SHIELD_WALL_FOV, endTime - Time(), vortexSphere.GetHealth(), SHIELD_WALL_FX )
		}

		wait tickRate
	}

	StopSoundOnEntity( vortexSphere, "ShieldWall_Loop" )
}

#if SERVER
void function Shift_Core_End( entity weapon, entity player, float delay )
{
	weapon.EndSignal( "OnDestroy" )

	if ( player.IsNPC() && !IsAlive( player ) )
		return

	player.EndSignal( "OnDestroy" )
	if ( IsAlive( player ) )
		player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "DisembarkingTitan" )
	player.EndSignal( "OnSyncedMelee" )
	player.EndSignal( "InventoryChanged" )

	OnThreadEnd(
	function() : ( weapon, player )
		{
			OnAbilityEnd_Shift_Core( weapon, player )

			if ( IsValid( player ) )
			{
				entity soul = player.GetTitanSoul()
				if ( soul != null )
					CleanupCoreEffect( soul )
			}
		}
	)

	entity soul = player.GetTitanSoul()
	if ( soul == null )
		return

	while ( 1 )
	{
		if ( soul.GetCoreChargeExpireTime() <= Time() )
			break;
		wait 0.1
	}
}

void function OnAbilityEnd_Shift_Core( entity weapon, entity player )
{
	OnAbilityEnd_TitanCore( weapon )

	if ( player.IsPlayer() )
	{
		player.SetPowerRegenRateScale( 1.0 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Ronin_Sword_Core_Deactivated_1P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "Titan_Ronin_Sword_Core_Deactivated_3P" )
		int conversationID = GetConversationIndex( "swordCoreOffline" )
		Remote_CallFunction_Replay( player, "ServerCallback_PlayTitanConversation", conversationID )
	}
	else
	{
		DeleteAnimEvent( player, "shift_core_use_meter" )
		EmitSoundOnEntity( player, "Titan_Ronin_Sword_Core_Deactivated_3P" )
	}

	RestorePlayerWeapons( player, weapon )
}

void function RestorePlayerWeapons( entity player, entity weapon = null )
{
	if ( !IsValid( player ) )
		return

	if ( player.IsNPC() && !IsAlive( player ) )
		return // no need to fix up dead NPCs

	entity soul = player.GetTitanSoul()

	if ( player.IsPlayer() )
	{
		TakePassive( player, ePassives.PAS_FUSION_CORE )
		TakePassive( player, ePassives.PAS_SHIFT_CORE )

		soul = GetSoulFromPlayer( player )
	}

	if( IsValid( weapon ) )
		if( weapon.HasMod("tcp_dash_core") )
			return

	if ( soul != null )
	{
		entity titan = soul.GetTitan()

		entity meleeWeapon = titan.GetOffhandWeapon( OFFHAND_MELEE )
		if ( IsValid( meleeWeapon ) )
		{
			meleeWeapon.RemoveMod( "super_charged" )
			if ( IsSingleplayer() )
			{
				meleeWeapon.RemoveMod( "super_charged_SP" )
			}
		}

		array<entity> mainWeapons = titan.GetMainWeapons()
		if ( mainWeapons.len() > 0 )
		{
			entity mainWeapon = titan.GetMainWeapons()[0]
			mainWeapon.AllowUse( true )
		}

		if ( titan.IsNPC() )
		{
			string settings = GetSpawnAISettings( titan )
			if ( settings != "" )
				titan.SetAISettings( settings )

			titan.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT )
			titan.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, true )
		}
	}
}

void function Shift_Core_UseMeter( entity player )
{
	if ( IsMultiplayer() )
		return

	entity soul = player.GetTitanSoul()
	float curTime = Time()
	float remainingTime = soul.GetCoreChargeExpireTime() - curTime

	if ( remainingTime > 0 )
	{
		const float USE_TIME = 5

		remainingTime = max( remainingTime - USE_TIME, 0 )
		float startTime = soul.GetCoreChargeStartTime()
		float duration = soul.GetCoreUseDuration()

		soul.SetTitanSoulNetFloat( "coreExpireFrac", remainingTime / duration )
		soul.SetTitanSoulNetFloatOverTime( "coreExpireFrac", 0.0, remainingTime )
		soul.SetCoreChargeExpireTime( remainingTime + curTime )
	}
}

void function Shift_Core_UseMeter_NPC( entity npc )
{
	Shift_Core_UseMeter( npc )
}
#endif