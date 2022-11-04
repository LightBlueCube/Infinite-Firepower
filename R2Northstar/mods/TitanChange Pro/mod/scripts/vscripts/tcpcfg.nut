untyped //.s. need this
global function tcpback;

void function tcpback()
{
	AddSpawnCallback("npc_titan", OnTitanfall )
	AddCallback_OnPilotBecomesTitan( OnPilotBecomesTitan )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnNPCKilled( OnNPCKilled )
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	AddButtonPressedPlayerInputCallback( player, IN_ATTACK, thread_SendHudMsg )	//当玩家按下左键。。
}
void function thread_SendHudMsg( entity player )
{
	thread SendHudMsg( player )			//跳转到这里，用thread执行下面用来伪装准心的hudmsg
}
void function SendHudMsg( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
    foreach( entity weapon in weapons )
    {
		if( "mp_weapon_turretlaser_mega_fort_war" == weapon.GetWeaponClassName() )	//检查武器是否为那个没准心的废稿武器。。。
		{
			SendHudMessage(player, "<------ · ------>",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
			wait 0.4
			SendHudMessage(player, "<-----| · |----->",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
			wait 0.4
			SendHudMessage(player, "<----|| · ||---->",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
			wait 0.4
			SendHudMessage(player, "<---||| · |||--->",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
			wait 0.4
			SendHudMessage(player, "<--|||| · ||||-->",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
			wait 0.4
			SendHudMessage(player, "<-||||| · |||||->",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
			wait 0.4
			SendHudMessage(player, "<|||||| · ||||||>",  -1, 0.483, 200, 200, 225, 255, 0.15, 0.4, 1);
		}
    }
}


void function OnTitanfall( entity titan )
{
	SetTitanLoadoutReplace( titan )
}

void function SetTitanLoadoutReplace( entity titan )
{
	entity player = GetPetTitanOwner( titan )
	if( !IsValid( player ) )
		return
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
	{
		SendHudMessage(player, "已启用野兽泰坦装备，取消至尊泰坦以使用原版北极星",  -1, 0.3, 200, 200, 225, 255, 0.15, 5, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream" )
	  	titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER )
        titan.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE,["tcp"] )
	}
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		SendHudMessage(player, "已启用野牛泰坦装备，取消至尊泰坦以使用原版烈焰\n温馨提示：野牛攻击请按近战键（默认为F键）\n核心:野牛冲刺核心:启动期间近战伤害提高",  -1, 0.3, 200, 200, 225, 255, 0.15, 12, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread","burn_mod_titan_vortex_shield"] )
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_ORDNANCE,["tcp"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, ["berserker", "allow_as_primary"] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )
	}
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		SendHudMessage(player, "已启用SB-7274装备， 取消\"边境帝王\"战绘以使用原版帝王",  -1, 0.2, 200, 200, 225, 255, 0.15, 12, 1);
		//titan.SetModel($"models/titans/buddy/titan_buddy.mdl")
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon("mp_titanweapon_xo16_shorty")
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon("mp_titanability_smoke", OFFHAND_TITAN_CENTER )
		titan.GiveOffhandWeapon("mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE,["tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT )
	}
	if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
	{
		SendHudMessage(player, "已启用电弧泰坦装备，取消至尊泰坦以使用原版浪人\n核心:电弧冲刺核心，启动期间电弧波伤害增加且无限使用",  -1, 0.3, 200, 200, 225, 255, 0.15, 8, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.GiveWeapon("mp_titanweapon_leadwall",["tcp"])
		titan.GiveOffhandWeapon( "mp_titanweapon_arc_wave", OFFHAND_SPECIAL,["tcp"] )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "melee_titan_sword", OFFHAND_MELEE )
	}
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
	{
		SendHudMessage(player, "已启用监察者泰坦装备，取消至尊泰坦以使用原版离子",  -1, 0.3, 200, 200, 225, 255, 0.15, 5, 1);
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon("mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE,["tcp"] )
		titan.GiveOffhandWeapon("mp_titanweapon_laser_lite", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon("mp_titanability_hover", OFFHAND_TITAN_CENTER, ["tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_salvo_core", OFFHAND_EQUIPMENT )
	}
	/*if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
	{
		SendHudMessage(player, "已启用壁垒泰坦装备，取消至尊泰坦以使用原版军团\n核心：壁垒超载核心，启用后冲刺加快，护盾无限使用，主武器连发，获得锁定导弹",  -1, 0.3, 200, 200, 225, 255, 0.15, 12, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon("mp_titanweapon_leadwall")
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["shield_only","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_stun_laser", OFFHAND_ORDNANCE,["energy_field_energy_transfer","tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT )
	}*/
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
	{
		SendHudMessage(player, "已启用壁垒泰坦装备，取消至尊泰坦以使用原版军团\n涡旋防护罩接到子弹会增加使用时间\n核心：壁垒超载核心，启用后冲刺加快，护盾无限使用，主武器全自动",  -1, 0.3, 200, 200, 225, 255, 0.15, 12, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon("mp_titanweapon_meteor")
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread","tcp_vortex"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_stun_laser", OFFHAND_ORDNANCE,["energy_field_energy_transfer","tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT )
	}
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		SendHudMessage(player, "已启用弧光泰坦装备，取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 255, 0.15, 5, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon("mp_weapon_turretlaser_mega_fort_war")
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread","burn_mod_titan_vortex_shield"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_laser_cannon", OFFHAND_EQUIPMENT )
	}
}

void function OnPilotBecomesTitan( entity player ,entity titan )
{
	if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
	{
		if( "TitanIsEmpTitan" in player.s )
		{
			if( player.s.TitanIsEmpTitan == false )
			{
				player.s.TitanIsEmpTitan <- true;
				thread EMPTitanThinkConstant( player );
			}
		}
		else
		{
			player.s.TitanIsEmpTitan <- true;
			thread EMPTitanThinkConstant( player );
		}
	}
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
    if( victim.IsTitan() )
    {
		victim.s.TitanIsEmpTitan <- false;
	}
	if( attacker == victim )
    {
		if( attacker.IsTitan() || victim.IsTitan() )
		{
			attacker.s.TitanIsEmpTitan <- false;
			victim.s.TitanIsEmpTitan <- false;
		}
	}
}
void function OnNPCKilled( entity victim, entity attacker, var damageInfo)
{
	if(victim.GetClassName() == "npc_titan" )
		if(IsValid(victim.GetBossPlayer()))
			victim.GetBossPlayer().s.TitanIsEmpTitan <- false;
}