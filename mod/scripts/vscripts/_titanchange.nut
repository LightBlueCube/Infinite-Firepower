untyped
global function TitanChange_Init

void function TitanChange_Init()
{
	AddSpawnCallback( "npc_titan", OnTitanfall )
	AddCallback_OnPilotBecomesTitan( OnPilotBecomesTitan )
	AddCallback_OnTitanBecomesPilot( OnTitanBecomesPilot )
	AddCallback_OnUpdateDerivedPlayerTitanLoadout( ApplyFDHealthUpgrades )
	AddCallback_OnTitanDoomed( OnTitanDoomed )
}

void function OnTitanDoomed( entity titan, var damageInfo )	//vanguard doom balance
{
	thread OnTitanDoomed_Threaded( titan )
}
void function OnTitanDoomed_Threaded( entity titan )
{
	WaitFrame()
	if( !IsValid( titan ) )
		return
	if( !IsAlive( titan ) )
		return
	if( titan.GetModelName() != $"models/titans/medium/titan_medium_vanguard.mdl" )
		return
	if( titan.GetCamo() == -1 && titan.GetSkin() == 3 )
		return
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	if( !SoulHasPassive( soul, ePassives.PAS_VANGUARD_DOOM ) )
		return
	titan.SetMaxHealth( 5000 )
	titan.SetHealth( 5000 )
}


void function ApplyFDHealthUpgrades( entity player, TitanLoadoutDef loadout )
{
	if( ( loadout.titanClass != "vanguard" && loadout.isPrime == "titan_is_not_prime" ) || ( loadout.titanClass == "vanguard" && loadout.skinIndex == 3 && loadout.camoIndex == -1 ) )
		loadout.setFileMods.append( "fd_health_upgrade" )
}

void function OnPilotBecomesTitan( entity player, entity titan )
{
    InitTitanTitle( player )
    InitSharedEnergy( player )
}
void function OnTitanBecomesPilot( entity player, entity titan )
{
    InitSharedEnergy( titan )
}

void function InitTitanTitle( entity titan )
{
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	if( !( "titanTitle" in soul.s ) )
        return

    if( soul.s.classicRodeoBatteryCount == 0 )
    {
        titan.SetTitle( soul.s.titanTitle + " - 反應爐外漏" )
        return
    }
    titan.SetTitle( soul.s.titanTitle )
}
void function InitSharedEnergy( entity titan )
{
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return

	if( "SharedEnergyRegenRate" in soul.s )
		titan.SetSharedEnergyRegenRate( soul.s.SharedEnergyRegenRate )
	if( "SharedEnergyRegenDelay" in soul.s )
		titan.SetSharedEnergyRegenDelay( soul.s.SharedEnergyRegenDelay )
	if( "SharedEnergyTotal" in soul.s )
	{
		titan.SetSharedEnergyTotal( soul.s.SharedEnergyTotal )
		if( titan.GetSharedEnergyCount() > soul.s.SharedEnergyTotal )
			titan.TakeSharedEnergy( titan.GetSharedEnergyCount() - soul.s.SharedEnergyTotal )
	}
}


void function OnTitanfall( entity titan )
{
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	if( "TitanHasBeenChanged" in soul.s )
		if( soul.s.TitanHasBeenChanged )
			return

	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
	{
		soul.s.titanTitle <- "野獸四號"
		soul.soul.titanLoadout.titanExecution = "execution_northstar_prime"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 333.3 )
		soul.s.SharedEnergyRegenRate <- 333.3
		soul.s.SharedEnergyRegenDelay <- 1.0

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream", [ "tcp_brute" ] )
	  	titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "tcp_dash_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER, [ "tcp_super_hover" ] )
        titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_ORDNANCE, [ "tcp_gravity" ] )
		titan.GiveOffhandWeapon( "mp_titancore_laser_cannon", OFFHAND_EQUIPMENT, [ "tcp_gravity" ] )

		array<int> passives = [ ePassives.PAS_NORTHSTAR_WEAPON,
								ePassives.PAS_NORTHSTAR_CLUSTER,
								ePassives.PAS_NORTHSTAR_TRAP,
								ePassives.PAS_NORTHSTAR_FLIGHTCORE,
								ePassives.PAS_NORTHSTAR_OPTICS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		soul.s.titanTitle <- "遠征"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 333.3 )
		soul.s.SharedEnergyRegenRate <- 333.3
		soul.s.SharedEnergyRegenDelay <- 1.0

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty", [ "tcp_sp_base" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL,["tcp_sp_base"] )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER )
		titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["tcp_sp_base"] )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT )

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
								ePassives.PAS_VANGUARD_SHIELD,
								ePassives.PAS_VANGUARD_REARM,
								ePassives.PAS_VANGUARD_DOOM,
								ePassives.PAS_VANGUARD_CORE1,
								ePassives.PAS_VANGUARD_CORE2,
								ePassives.PAS_VANGUARD_CORE3,
								ePassives.PAS_VANGUARD_CORE4,
								ePassives.PAS_VANGUARD_CORE5,
								ePassives.PAS_VANGUARD_CORE6,
								ePassives.PAS_VANGUARD_CORE7,
								ePassives.PAS_VANGUARD_CORE8,
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		soul.s.titanTitle <- "野牛"
		soul.soul.titanLoadout.titanExecution = "execution_scorch_prime"

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "tcp_parent_shield" ] )
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_TITAN_CENTER, [ "amped_tacticals", "tcp_super_dash" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE, [ "tcp_push_back" ] )
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT, [ "ground_slam" ] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, [ "berserker", "allow_as_primary" ] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )

		array<int> passives = [ ePassives.PAS_SCORCH_WEAPON,
								ePassives.PAS_SCORCH_FIREWALL,
								ePassives.PAS_SCORCH_SHIELD,
								ePassives.PAS_SCORCH_SELFDMG,
								ePassives.PAS_SCORCH_FLAMECORE ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
	{
		soul.s.titanTitle <- "執政官"
		soul.soul.titanLoadout.titanExecution = "execution_ion"
		titan.SetSharedEnergyRegenDelay( 2.0 )
		titan.SetSharedEnergyRegenRate( 200 )
		soul.s.SharedEnergyRegenRate <- 200
		soul.s.SharedEnergyRegenDelay <- 1.0

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.GiveWeapon( "mp_titanweapon_arc_cannon", [ "capacitor" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL, [ "tcp_vortex", "burn_mod_titan_vortex_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_laser_trip", OFFHAND_TITAN_CENTER, [ "pas_ion_tripwire", "tcp_arc_trip" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets", OFFHAND_ORDNANCE, [ "tcp_arc_bomb" ] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, [ "tcp_arc_wave" ] )

		array<int> passives = [ ePassives.PAS_ION_WEAPON,
								ePassives.PAS_ION_TRIPWIRE,
								ePassives.PAS_ION_VORTEX,
								ePassives.PAS_ION_LASERCANNON,
								ePassives.PAS_ION_WEAPON_ADS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}

	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
	{
		soul.s.titanTitle <- "游俠"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.GiveWeapon( "mp_titanweapon_triplethreat", [ "rolling_rounds" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER, [ "tcp_emp" ])
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, ["tcp_dash_core"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_northstar", OFFHAND_MELEE )

		array<int> passives = [ ePassives.PAS_RONIN_WEAPON,
								ePassives.PAS_RONIN_ARCWAVE,
								ePassives.PAS_RONIN_PHASE,
								ePassives.PAS_RONIN_SWORDCORE,
								ePassives.PAS_RONIN_AUTOSHIFT ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		soul.s.titanTitle <- "天圖"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true
		titan.SetSharedEnergyTotal( 550 )
		titan.SetSharedEnergyRegenRate( 30 )
		soul.s.SharedEnergyRegenRate <- 30
		soul.s.SharedEnergyTotal <- 550

		if( titan.GetSharedEnergyCount() > soul.s.SharedEnergyTotal )
			titan.TakeSharedEnergy( titan.GetSharedEnergyCount() - soul.s.SharedEnergyTotal )

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.GiveWeapon( "mp_titanweapon_sticky_40mm", [ "mortar_shots" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "tcp_color_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_rearm", OFFHAND_TITAN_CENTER, [ "tcp_no_gravity" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_laser_lite", OFFHAND_ORDNANCE, [ "tcp_mark_laser" ] )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT, ["damage_core"] )



		array<int> passives = [ ePassives.PAS_TONE_WEAPON,
								ePassives.PAS_TONE_ROCKETS,
								ePassives.PAS_TONE_SONAR,
								ePassives.PAS_TONE_WALL,
								ePassives.PAS_TONE_BURST ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
	{
		soul.s.titanTitle <- "巨妖"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true
		soul.SetTitanSoulNetInt( "upgradeCount", 4 )

        foreach( weapon in titan.GetMainWeapons() )
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )

        titan.GiveWeapon( "mp_titanweapon_xo16_shorty", [ "accelerator" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "brute4_bubble_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_TITAN_CENTER, [ "tcp_smoke" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_stun_laser", OFFHAND_ORDNANCE, [ "charge_ball" ] )
		titan.GiveOffhandWeapon( "mp_titancore_upgrade", OFFHAND_EQUIPMENT, [ "tcp_ammo_core" ] )

		array<int> passives = [ ePassives.PAS_LEGION_CHARGESHOT,
								ePassives.PAS_LEGION_GUNSHIELD,
								ePassives.PAS_LEGION_SMARTCORE,
								ePassives.PAS_LEGION_SPINUP,
								ePassives.PAS_LEGION_WEAPON ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}

	//// vanilla titans ////

	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( titan.GetCamo() != -1 || titan.GetSkin() != 3 ) )	//帝王
	{
		soul.s.titanTitle <- "帝王"
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_ajax.mdl" )	//离子
	{
		soul.s.titanTitle <- "離子"
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_ogre.mdl" )		//烈焰
	{
		soul.s.titanTitle <- "烈焰"
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_raptor.mdl" )	//北极星
	{
		soul.s.titanTitle <- "北極星"
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl" )	//浪人
	{
		soul.s.titanTitle <- "浪人"
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_wraith.mdl" )	//强力
	{
		soul.s.titanTitle <- "強力"
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_deadbolt.mdl" )	//军团
	{
		soul.s.titanTitle <- "軍團"
	}
    else
        return
    soul.s.TitanHasBeenChanged <- true
}
