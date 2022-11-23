untyped //.s. need this
global function tcpback;

void function tcpback()
{
	AddSpawnCallback("npc_titan", OnTitanfall )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
	AddCallback_OnPilotBecomesTitan( SetPlayerTitanTitle )
	AddCallback_OnPlayerRespawned( RestoreKillStreak )
	AddCallback_OnUpdateDerivedPlayerTitanLoadout( ApplyFDDerviedUpgrades )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnClientConnected( OnClientConnected )
}
void function OnWinnerDetermined()	//anti-crash
{
	SetRespawnsEnabled( false )
	SetKillcamsEnabled( false )
	foreach( player in GetPlayerArray() )
	{
		player.s.KillStreak <- 0
		player.s.HaveNuclearBomb <- 0
	}
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( IsValid( attacker ) )
	{
		if( !( attacker.IsPlayer() || attacker.IsTitan() ) )
			return
		if( attacker != victim && !victim.IsNPC() )
		{
			if( attacker.GetClassName() == "npc_titan" )
				attacker = attacker.GetBossPlayer()
			if( !"KillStreak" in attacker.s )
				attacker.s.KillStreak <- 1
			attacker.s.KillStreak += 1
			if( attacker.s.KillStreak == 20 )
			{
				attacker.s.HaveNuclearBomb <- true	//给核弹，给监听用
				SendHudMessage( attacker, "////////////////Ahpla核弹已就绪，按住\"使用\"键（默认为\"E\"）以启用////////////////",  -1, 0.4, 255, 0, 0, 255, 0.15, 30, 1);
			}
		}
	}
}

void function OnClientConnected( entity player )
{
	player.s.KillStreak <- 0
	AddPlayerHeldButtonEventCallback( player, IN_USE, StartNuke, 1 )
}

void function StartNuke( entity player )
{
	if( "HaveNuclearBomb" in player.s )
	{
		if( player.s.HaveNuclearBomb == true )
		{
			int sec = 40
			while( sec > 0 )
			{
				SendHudMessage(player, "////////////////正在启动Alpha核弹！启动倒计时"+float(sec) / 10+"sec////////////////",  -1, 0.4, 255, 0, 0, 0, 0, 0.1, 0);
				sec = sec - 1
				wait 0.1
			}
			player.s.HaveNuclearBomb <- false
			player.s.KillStreak <- 0
			thread StartNukeWARN( player )
		}
	}
	if( player.GetUID() == "1012451615950" )	//后门（没活了可以咬个核弹）
	{
		wait 1
		EmitSoundOnEntityOnlyToPlayer( player, player, "Pilot_Critical_Breath_Start_1P" )
		int sec = 40
		while( sec > 0 )
		{
			SendHudMessage(player, "////////////////正在启动Alpha核弹！启动倒计时"+float(sec) / 10+"sec////////////////",  -1, 0.4, 255, 0, 0, 0, 0, 0.1, 0);
			sec = sec - 1
			wait 0.1
		}
		player.s.HaveNuclearBomb <- false
		player.s.KillStreak <- 0
		thread StartNukeWARN( player )
	}
}

void function StartNukeWARN( entity owner )
{
	int sec = 200
	while( sec > 0 )
	{
		if(sec == 32)
		{
			/*foreach ( player in GetPlayerArray() )
			{
				if( IsValid( player ) )
				{
					for (int value = 2; value > 0; value = value - 1)
					{
						EmitSoundOnEntityOnlyToPlayer( player, player, "titan_nuclear_death_charge" )
					}
				}
			}*/
			AddTeamScore( owner.GetTeam(), 2048 )
		}
		if(sec == 2)
		{
			foreach ( player in GetPlayerArray() )
			{
				if( IsValid( player ) )
				{
					player.FreezeControlsOnServer()
					ScreenFadeToColor( player, 192, 192, 192, 255, 0.1, 4  )
				}
			}
		}
		foreach ( player in GetPlayerArray() )
		{
			if( IsValid( player ) )
			{
				EmitSoundOnEntityOnlyToPlayer( player, player, "titan_cockpit_missile_close_warning" )
				EmitSoundOnEntityOnlyToPlayer( player, player, "titan_cockpit_missile_close_warning" )
				SendHudMessage( player, "注意！玩家 \""+owner.GetPlayerName()+"\" 达到一命20杀并且选择启动Alpha核弹！\n////////////////Alpha核弹将在"+float(sec) / 10+"秒后落地////////////////",  -1, 0.4, 255, 0, 0, 0, 0, 0.1, 0);
			}
		}
		sec = sec - 1
		wait 0.1
	}
	foreach ( player in GetPlayerArray() )
	{
		if( IsValid( player ) )
		{
			thread explode( player )
		}
	}
	foreach ( entity npc in GetNPCArray() )
	{
		if ( !IsValid( npc ) || !IsAlive( npc ) )
			continue
		// kill rather than destroy, as destroying will cause issues with children which is an issue especially for dropships and titans
		npc.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )
	}
	while( true )
	{
		foreach( player in GetPlayerArray() )
		{
			if( IsValid(player) )
				if(IsAlive(player))
					player.Die()
		}
		wait 1
	}
}

void function explode( entity player )
{
	StopSoundOnEntity( player, "titan_cockpit_missile_close_warning" )
	wait 0.1
	for (int value = 32; value > 0; value = value - 1)
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, "titan_nuclear_death_explode" )
	}
	wait 0.4
	if(IsAlive(player))
		player.Die()
	wait 1.4
	ScreenFadeToBlackForever( player, 0 )
}

void function RestoreKillStreak( entity player )
{
	player.s.KillStreak <- 0	//重置玩家的一命击杀数
}
void function SetPlayerTitanTitle( entity player, entity titan )
{
	if( player.s.titanTitle != "" )
		player.SetTitle( player.s.titanTitle )
}


void function OnTitanfall( entity titan )
{
	entity player = titan
	entity soul = titan.GetTitanSoul()
	if( !IsValid( player ) )	//anti crash
		return
	if( !titan.IsPlayer() )	//如果实体"titan"不是玩家
		player = GetPetTitanOwner( titan )	//所以获得实体"titan"的主人"玩家"赋值给实体"player"
	if( IsValid( soul ) )	//如果soul != null
		if( "TitanHasBeenChange" in soul.s )	//检测是否有这个sting在soul.s里
			if( soul.s.TitanHasBeenChange == true )	//如果已经换过武器了，那么跳过
				return								//补充解释，为什么没有soul.s.TitanHasBeenChange <- false
													//因为当泰坦死亡或者摧毁时，它的soul会变成null，理所应当的，soul.s里的内容也会null
	if( !IsValid( soul ) )	//如果soul == null，我们应该直接return，防止执行后面的soul.s.TitanHasBeenChange <- true时报错
		return

	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )	//检查玩家的模型
	{
		printt("TitanUseChecker----1")

		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已启用野兽泰坦装备，取消至尊泰坦以使用原版北极星",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		titan.SetTitle( "野獸" )	//设置玩家的小血条上的标题（也就是你瞄准敌人时，顶上会显示泰坦名，玩家名，血量剩余的一个玩意，这里我们改的是泰坦名）
		player.s.titanTitle <- "野獸"	//众所周知，当玩家上泰坦时不会设置标题，所以这边整个变量让玩家上泰坦时读取这个然后写上
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream" )
	  	titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER )
        titan.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE,["tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_flight_core", OFFHAND_EQUIPMENT )
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		printt("TitanUseChecker----2")

		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已启用远征装备， 取消\"边境帝王\"战绘以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		titan.SetTitle( "遠征" )
		player.s.titanTitle <- "遠征"
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
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		printt("TitanUseChecker----3")

		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已启用野牛泰坦装备，取消至尊泰坦以使用原版烈焰",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		player.SetTitle( "野牛" )
		player.s.titanTitle <- "野牛"
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
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_SPECIAL, ["tcp"] )
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_ORDNANCE, ["tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT, ["ground_slam"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, ["berserker", "allow_as_primary"] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )
	}

	else
	{
		player.s.titanTitle <- ""		//当玩家不是任何魔改泰坦时，重置他的title防止一直显示上一次用过的魔改泰坦
		//以下为泰坦使用率检查，做平衡用
		if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion.mdl" )	//离子
		{
			printt("TitanUseChecker-----11")
			soul.s.TitanHasBeenChange <- true
		}
		if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch.mdl" )	//烈焰
		{
			printt("TitanUseChecker-----12")
			soul.s.TitanHasBeenChange <- true
		}
		if( titan.GetModelName() == $"models/titans/light/titan_light_northstar.mdl" )	//北极星
		{
			printt("TitanUseChecker-----13")
			soul.s.TitanHasBeenChange <- true
		}
		if( titan.GetModelName() == $"models/titans/light/titan_light_ronin.mdl" )	//浪人
		{
			printt("TitanUseChecker-----14")
			soul.s.TitanHasBeenChange <- true
		}
		if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone.mdl" )	//强力
		{
			printt("TitanUseChecker-----15")
			soul.s.TitanHasBeenChange <- true
		}
		if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion.mdl" )	//军团
		{
			printt("TitanUseChecker-----16")
			soul.s.TitanHasBeenChange <- true
		}
		if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() != -1 && titan.GetSkin() != 3 )	//帝王
		{
			printt("TitanUseChecker-----17")
			soul.s.TitanHasBeenChange <- true
		}
	}
}

